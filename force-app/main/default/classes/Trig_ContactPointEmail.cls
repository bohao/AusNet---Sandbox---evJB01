public with sharing class Trig_ContactPointEmail implements UtilTrigHandle
{

	// *********************************************************************
	// *** Disable logic
	public static Boolean TrigDisabled = false;
	public static Boolean isRunningCheckIsPrimary = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().ContactPointEmail_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}


	// *********************************************************************
	// *** Trigger contexts

	public void BeforeInsert(List<SObject> newSObjs)
	{
		setPrimaryKey(newSObjs);
		checkIsPrimary((List<ContactPointEmail>)newSObjs, null);
	}

	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		setPrimaryKey(newSObjs.values());
		checkIsPrimary((List<ContactPointEmail>)newSObjs.values(), (Map<Id, ContactPointEmail>)oldSObjs);
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
		checkEmailUpdated((List<ContactPointEmail>)newSObjs.values(), (Map<Id, ContactPointEmail>)oldSObjs);
	}
	
	// if context is not implemented, condense into one-liners
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> oldSObjs) {}


	// *********************************************************************
	// *** Trigger methods


	// checkIsPrimary profile:
	// Runs in before context
	// 1 SOQLs
	// 1 DMLs
	public static void checkIsPrimary(List<ContactPointEmail> newCPEmailsList, Map<Id, ContactPointEmail> oldCPEmails)
	{
		// Catch to stop trigger re-running (isRunningCheckIsPrimary)
		if (isRunningCheckIsPrimary) return;
		isRunningCheckIsPrimary = true;

		if (newCPEmailsList == null || newCPEmailsList.isEmpty())
		{
			System.debug('Error: newCPEmailsList is null or empty.');
			return;
		}

		if (Trigger.isUpdate)
		{
			if (oldCPEmails == null || oldCPEmails.isEmpty())
			{
				System.debug('Error: oldCPEmails is null or empty. (isUpdate)');
				return;
			}

			// Validate - check for updated isPrimary field values where updated to true
			List<ContactPointEmail> validCPEs = new List<ContactPointEmail>();

			for (ContactPointEmail newCPE: newCPEmailsList)
			{
				if (newCPE.Contact__c == null) continue;
				ContactPointEmail oldCPE = oldCPEmails.get(newCPE.Id);

				if (oldCPE.isPrimary != newCPE.isPrimary && newCPE.isPrimary)
					validCPEs.add(newCPE);
			}

			if (validCPEs.isEmpty())
			{
				System.debug('Do nothing: Field values we are watching have not changed.');
				return;
			}

			newCPEmailsList = validCPEs; // Set the newCPEmailsList to only have the valid records
		}

		Map<Id, List<ContactPointEmail>> contactCPEs = createContactToCPEmailsMap(newCPEmailsList);

		// Query CPEs
		for (ContactPointEmail cpe: [SELECT Id, Name, Contact__c, IsPrimary, Data_Type__c
									 FROM ContactPointEmail
									 WHERE Contact__c IN :contactCPEs.keySet()
									 AND Id NOT IN :newCPEmailsList])
		{
			contactCPEs.get(cpe.Contact__c).add(cpe);
		}

		// Iterate full list now per contact.
		List<ContactPointEmail> cpeListToUpdate = new List<ContactPointEmail>();

		for (ContactPointEmail newCPE: newCPEmailsList)
		{
			if (newCPE.Contact__c == null) continue;
			String dataType = newCPE.Data_Type__c;

			List<ContactPointEmail> contactCPEsList = contactCPEs.get(newCPE.Contact__c);
			if (contactCPEsList.isEmpty()) continue;

			if (newCPE.isPrimary)
			{
				Integer primaryCount = countPrimaries(contactCPEsList, dataType);
				if (primaryCount <= 1) continue;

				// Multiple Primary CPEmail record(s) found
				for (ContactPointEmail cpe : contactCPEsList)
				{
					// Set isPrimary field to false from true for old records of the same data type.
					if (newCPE.Id != cpe.Id && dataType == cpe.Data_Type__c && cpe.isPrimary)
					{
						cpe.isPrimary = false;
						cpeListToUpdate.add(cpe);
					}
				}
			}
			else
			{
				// Trigger.isUpdate wont make it here (no valid records)
				Integer numCPEs = countCPEs(contactCPEsList, dataType);

				// New record is Not Primary and 0 other CPEmail records are found (Primary or otherwise)
				// set isPrimary to true (auto-fix)
				if (numCPEs == 1)
					newCPE.isPrimary = true;
			}
		}

		if (!cpeListToUpdate.isEmpty())
			update cpeListToUpdate;
	}


	// setPrimaryKey profile:
	// Runs in before context
	// 0 SOQLs
	// 0 DMLs
	public static void setPrimaryKey(List<ContactPointEmail> newCPEmails)
	{
		if (newCPEmails == null || newCPEmails.isEmpty())
		{
			System.debug('Error: newCPEmails is null or empty.');
			return;
		}

		for (ContactPointEmail CPE: newCPEmails)
		{
			String key = CE_ContactPointSync2.getPrimaryKeyValue(CPE);
			CPE.PrimaryKey__c = key;
		}
	}

	// Update Consent records when endpoint updated
	public static void checkEmailUpdated(List<ContactPointEmail> newCPEmails, Map<Id, ContactPointEmail> oldCPEmails)
	{
		if (newCPEmails == null || newCPEmails.isEmpty())
		{
			System.debug('Error: newCPEmails is null or empty.');
			return;
		}

		Set<Id> CPEIds = new Set<Id>();
		for (ContactPointEmail newCPEmail: newCPEmails)
		{
			ContactPointEmail oldCPEmail = oldCPEmails.get(newCPEmail.Id);

			if (oldCPEmail.EmailAddress != newCPEmail.EmailAddress)
			{
				CPEIds.add(newCPEmail.Id);
			}
		}

		if (!CPEIds.isEmpty())
		{
			List<SObject> Consents = [SELECT Id FROM ContactPointConsent WHERE ContactPointId IN :CPEIds AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE];
			if (Consents != null && !Consents.isEmpty())
				update Consents;
		}
	}


	// *********************************************************************
	// *** Helper methods
	private static Map<Id, List<ContactPointEmail>> createContactToCPEmailsMap(List<ContactPointEmail> cpeList)
	{
		Map<Id, List<ContactPointEmail>> contactCPEs = new Map<Id, List<ContactPointEmail>>();

		for (ContactPointEmail cpe: cpeList)
		{
			if (cpe.Contact__c == null) continue;
			Id conId = cpe.Contact__c;

			if (!contactCPEs.containsKey(conId))
				contactCPEs.put(conId, new List<ContactPointEmail>());

			contactCPEs.get(conId).add(cpe); // note: could be one or many inserts/updates here on same contact
		}

		return contactCPEs;
	}

	private static Integer countPrimaries(List<ContactPointEmail> CPEmails, String dataType)
	{
		Integer count = 0;
		if (CPEmails == null || CPEmails.isEmpty())
			return count;

		for (ContactPointEmail CPE: CPEmails)
		{
			if (CPE.isPrimary && CPE.Data_Type__c==dataType)
				count++;
		}

		return count;
	}

	private static Integer countCPEs(List<ContactPointEmail> CPEmails, String dataType)
	{
		Integer count = 0;
		if (CPEmails == null || CPEmails.isEmpty())
			return count;

		for (ContactPointEmail CPE: CPEmails)
		{
			if (CPE.Data_Type__c==dataType)
				count++;
		}

		return count;
	}

	private static void updateUndeliveredDtls(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		for(Id cpeId : newSObjs.keySet())
		{
			ContactPointEmail cpe = (ContactPointEmail) newSObjs.get(cpeId);
			if(cpe.Undelivered__c)
			{
				cpe.Undelivered_Count__c = (cpe.Undelivered_Count__c==null)?1:cpe.Undelivered_Count__c+1;
				cpe.Undelivered__c = false;
			}
		}
	}
}