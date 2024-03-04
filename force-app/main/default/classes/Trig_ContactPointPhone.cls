public with sharing class Trig_ContactPointPhone implements UtilTrigHandle
{

	// *********************************************************************
	// *** Disable logic
	public static Boolean TrigDisabled = false;
	public static Boolean isRunningCheckIsPrimary = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().ContactPointPhone_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}


	// *********************************************************************
	// *** Trigger contexts
	public void BeforeInsert(List<SObject> newSObjs)
	{
		setMobilePhoneFormat(newSObjs);
		setPrimaryKey(newSObjs);
		checkIsPrimary((List<ContactPointPhone>)newSObjs, null);
	}

	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		setMobilePhoneFormat(newSObjs.values());
		setPrimaryKey(newSObjs.values());
		checkIsPrimary((List<ContactPointPhone>)newSObjs.values(), (Map<Id, ContactPointPhone>)oldSObjs);
		updateUndeliveredDtls(newSObjs, oldSObjs);
	}

	public void AfterInsert(Map<Id, SObject> newSObjs)
	{
		CE_ContactPointSync2.syncCPPCPEContactFields(newSObjs.values(), null);

	}
	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		CE_ContactPointSync2.syncCPPCPEContactFields(newSObjs.values(), oldSObjs);

		// Update Consent records when endpoint updated
		checkPhoneUpdated((List<ContactPointPhone>)newSObjs.values(), (Map<Id, ContactPointPhone>)oldSObjs);
	}

	// if context is not implemented, condense into one-liners
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> oldSObjs) {}


	// *********************************************************************
	// *** Trigger methods

	// setMobilePhoneFormat profile:
	// Runs in before context
	// 0 SOQLs
	// 0 DMLs
	public static void setMobilePhoneFormat(List<ContactPointPhone> newCPPhones)
	{
		if (newCPPhones == null || newCPPhones.isEmpty())
		{
			System.debug('Error: newCPPhones is null or empty.');
			return;
		}

		Set<String> mobilePrefixes = new Set<String>{'04', '+614', '614'};

		for (ContactPointPhone CPP: newCPPhones)
		{
			if (CPP.TelephoneNumber == null) continue;
			Boolean isMobile = false;
			CPP.TelephoneNumber = CPP.TelephoneNumber.trim();

			// check TelephoneNumber - standardise prefix
			for (String prefix: mobilePrefixes)
			{
				// Quick fix
				if (CPP.TelephoneNumber.startsWith('4') && CPP.TelephoneNumber.length() == 9)
				{
					CPP.TelephoneNumber = '0' + CPP.TelephoneNumber;
				}

				if (CPP.TelephoneNumber.startsWith(prefix))
				{
					CPP.TelephoneNumber = '614' + CPP.TelephoneNumber.removeStart(prefix);
					CPP.PhoneType = Outage_IncidentProcessor.CPP_PHONE_TYPE_MOBILE;
					isMobile = true;
					break;
				}
			}

			if (!isMobile && CPP.PhoneType == Outage_IncidentProcessor.CPP_PHONE_TYPE_MOBILE)
				CPP.PhoneType = Outage_IncidentProcessor.CPP_PHONE_TYPE_HOME;

			// Strip spaces
			if (isMobile && CPP.TelephoneNumber.contains(' '))
			{
				CPP.TelephoneNumber = CPP.TelephoneNumber.replace(' ', '');
			}
		}
	}

	// setPrimaryKey profile:
	// Runs in before context
	// 0 SOQLs
	// 0 DMLs
	public static void setPrimaryKey(List<ContactPointPhone> newCPPhones)
	{
		if (newCPPhones == null || newCPPhones.isEmpty())
		{
			System.debug('Error: newCPPhones is null or empty.');
			return;
		}

		for (ContactPointPhone CPP: newCPPhones)
		{
			String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
			CPP.PrimaryKey__c = key;
		}
	}


	// checkIsPrimary profile:
	// Runs in before context
	// 1 SOQLs
	// 1 DMLs
	public static void checkIsPrimary(List<ContactPointPhone> newCPPhonesList, Map<Id, ContactPointPhone> oldCPPhones)
	{
		// Catch to stop trigger re-running (isRunningCheckIsPrimary)
		if (isRunningCheckIsPrimary) return;
		isRunningCheckIsPrimary = true;

		if (newCPPhonesList == null || newCPPhonesList.isEmpty())
		{
			System.debug('Error: newCPPhonesList is null or empty.');
			return;
		}

		if (Trigger.isUpdate)
		{
			if (oldCPPhones == null || oldCPPhones.isEmpty())
			{
				System.debug('Error: oldCPPhones is null or empty. (isUpdate)');
				return;
			}

			// Validate - check for updated isPrimary field values where updated to true
			List<ContactPointPhone> validCPPs = new List<ContactPointPhone>();

			for (ContactPointPhone newCPP: newCPPhonesList)
			{
				if (newCPP.Contact__c == null) continue;
				ContactPointPhone oldCPP = oldCPPhones.get(newCPP.Id);

				if (oldCPP.isPrimary != newCPP.isPrimary && newCPP.isPrimary)
					validCPPs.add(newCPP);
			}

			if (validCPPs.isEmpty())
			{
				System.debug('Do nothing: Field values we are watching have not changed.');
				return;
			}
			
			newCPPhonesList = validCPPs; // Set the newCPPhonesList to only have the valid records
		}

		Map<Id, List<ContactPointPhone>> contactCPPs = createContactToCPPhonesMap(newCPPhonesList);

		// Query CPPs
		for (ContactPointPhone cpp: [SELECT Id, Name, Contact__c, IsPrimary, Data_Type__c
									 FROM ContactPointPhone
									 WHERE Contact__c IN :contactCPPs.keySet()
									 AND Id NOT IN :newCPPhonesList])
		{
			contactCPPs.get(cpp.Contact__c).add(cpp);
		}

		// Iterate full list now per contact.
		List<ContactPointPhone> cppListToUpdate = new List<ContactPointPhone>();

		for (ContactPointPhone newCPP: newCPPhonesList)
		{
			if (newCPP.Contact__c == null) continue;
			String dataType = newCPP.Data_Type__c;

			List<ContactPointPhone> contactCPPsList = contactCPPs.get(newCPP.Contact__c);
			if (contactCPPsList.isEmpty()) continue;

			if (newCPP.isPrimary)
			{
				Integer primaryCount = countPrimaries(contactCPPsList, dataType);
				if (primaryCount <= 1) continue;

				// Multiple Primary CPPhone record(s) found
				for (ContactPointPhone cpp : contactCPPsList)
				{
					// Set isPrimary field to false from true for old records of the same data type.
					if (newCPP.Id != cpp.Id && dataType == cpp.Data_Type__c && cpp.isPrimary)
					{
						cpp.isPrimary = false;
						cppListToUpdate.add(cpp);
					}
				}

			}
			else
			{	
				// Trigger.isUpdate wont make it here (no valid records)
				Integer numCPPs = countCPPs(contactCPPsList, dataType);

				// New record is Not Primary and 0 other CPPhone records are found (Primary or otherwise)
				// set isPrimary to true (auto-fix)
				if (numCPPs == 1)
					newCPP.isPrimary = true;
			}
		}
		
		if (!cppListToUpdate.isEmpty())
			update cppListToUpdate;
	}

	// Update Consent records when endpoint updated
	public static void checkPhoneUpdated(List<ContactPointPhone> newCPPhones, Map<Id, ContactPointPhone> oldCPPhones)
	{
		if (newCPPhones == null || newCPPhones.isEmpty())
		{
			System.debug('Error: newCPPhones is null or empty.');
			return;
		}

		Set<Id> CPPIds = new Set<Id>();
		for (ContactPointPhone newCPPhone: newCPPhones)
		{
			ContactPointPhone oldCPEmail = oldCPPhones.get(newCPPhone.Id);

			if (oldCPEmail.TelephoneNumber != newCPPhone.TelephoneNumber)
			{
				CPPIds.add(newCPPhone.Id);
			}
		}

		if (!CPPIds.isEmpty())
		{
			List<SObject> Consents = [SELECT Id FROM ContactPointConsent WHERE ContactPointId IN :CPPIds AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE];
			if (Consents != null && !Consents.isEmpty())
				update Consents;
		}
	}





	// *********************************************************************
	// *** Helper methods

	private static Map<Id, List<ContactPointPhone>> createContactToCPPhonesMap(List<ContactPointPhone> cppList)
	{
		Map<Id, List<ContactPointPhone>> contactCPPs = new Map<Id, List<ContactPointPhone>>();

		for (ContactPointPhone cpp: cppList)
		{
			if (cpp.Contact__c == null) continue;
			Id conId = cpp.Contact__c;

			if (!contactCPPs.containsKey(conId))
				contactCPPs.put(conId, new List<ContactPointPhone>());

			contactCPPs.get(conId).add(cpp); // note: could be one or many inserts/updates here on same contact
		}

		return contactCPPs;
	}

	private static Integer countPrimaries(List<ContactPointPhone> CPPhones, String dataType)
	{
		Integer count = 0;
		if (CPPhones == null || CPPhones.isEmpty())
			return count;

		for (ContactPointPhone CPP: CPPhones)
		{
			if (CPP.isPrimary && CPP.Data_Type__c==dataType)
				count++;
		}

		return count;
	}

	private static Integer countCPPs(List<ContactPointPhone> CPPhones, String dataType)
	{
		Integer count = 0;
		if (CPPhones == null || CPPhones.isEmpty())
			return count;

		for (ContactPointPhone CPP: CPPhones)
		{
			if (CPP.Data_Type__c==dataType)
				count++;
		}

		return count;
	}
    
	private static void updateUndeliveredDtls(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
    {
        for(Id cpeId : newSObjs.keySet())
        {
            ContactPointPhone cpp = (ContactPointPhone) newSObjs.get(cpeId);
            if(cpp.Undelivered__c)
            {
                cpp.Undelivered_Count__c = (cpp.Undelivered_Count__c==null)?1:cpp.Undelivered_Count__c+1;
                cpp.Undelivered__c = false;
            }
        }
    }	
}