public with sharing class Trig_AffectedNMI implements UtilTrigHandle
{

	// *********************************************************************
	// *** Disable logic
	public static Boolean TrigDisabled = false;
	public static Boolean MultiIncModeDisabled = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().Affected_Market_Ident_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}



	// *********************************************************************
	// *** Trigger contexts
	public void BeforeInsert(List<SObject> newSObjs)
	{
		insertCheckIncidentLookup(newSObjs); // must be first.
		insertUpdateCheckNMILength(newSObjs);

		insertSetStatusField(newSObjs);
		insertCheckNMIMultiIncident(newSObjs);
	}

	public void AfterInsert(Map<Id, SObject> newSObjs)
	{
		// System.debug('*** Trig_AffectedNMI.AfterInsert');
		createAffectedCustomer(newSObjs.values());
	}

	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		insertUpdateCheckNMILength(newSObjs.values());

		updateSetStatusField(newSObjs.values(), (Map<Id, Affected_Market_Identifier__c>)oldSObjs);
	}

	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		updateCheckNMIMultiIncident(newSObjs.values(), (Map<Id, Affected_Market_Identifier__c>)oldSObjs);
		updateAffectedCustomer(oldSObjs, newSObjs);
	}

	public void BeforeDelete(Map<Id, SObject> oldSObjs)
	{
		deleteAffectedCustomer(oldSObjs.values());
	}

	// if context is not implemented, condense into one-liners
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> oldSObjs) {}


	// *********************************************************************
	// *** Trigger methods

	// setStatusField profile:
	// Runs in before context
	// 0 SOQLs
	// 0 DMLs
	public static void insertSetStatusField(List<Affected_Market_Identifier__c> affNMIs)
	{
		if (affNMIs == null || affNMIs.isEmpty())
			return;

		// We are now setting the AffectNMI Status field based on the Status Code value.
		for (Affected_Market_Identifier__c affNMI: affNMIs)
		{
			String statusCode = affNMI.uom_Status_Code__c;

			if (statusCode == null)
			{
				affNMI.uom_Status_Code__c.addError('Error: uom_Status_Code__c is null.');
				continue;
			}

			if (!Outage_IncidentProcessor.AFF_NMI_CODE_STATUS.containsKey(statusCode) &&
				affNMI.uom_Status__c == null)
			{
				// affNMI.uom_Status_Code__c.addError('Error: Unknown uom_Status_Code__c value.');
				affNMI.uom_Status__c = Outage_IncidentProcessor.AFF_NMI_IN_PROG; // default value.
				continue;
			}

			affNMI.uom_Status__c = Outage_IncidentProcessor.AFF_NMI_CODE_STATUS.get(statusCode);
		}
	}

	public static void insertUpdateCheckNMILength(List<Affected_Market_Identifier__c> affNMIs)
	{
		if (affNMIs == null || affNMIs.isEmpty())
			return;

		for (Affected_Market_Identifier__c affNMI: affNMIs)
		{
			if (affNMI.Name == null || affNMI.Name.length() != 10) continue;

			String nmiNum10 = affNMI.Name;
			String nmiNum11 = Outage_NMITools.getNMI11(nmiNum10);
			affNMI.Name = nmiNum11;
		}
	}

	public static void insertCheckIncidentLookup(List<Affected_Market_Identifier__c> affNMIs)
	{
		if (affNMIs == null || affNMIs.isEmpty())
			return;

		// Check for field 
		Map<String, Id> IncIds = new Map<String, Id>();
		for (Affected_Market_Identifier__c affNMI: affNMIs)
		{
			if (affNMI.IncidentIdText__c != null && affNMI.uom_Incident__c == null)
				IncIds.put(affNMI.IncidentIdText__c, null);
		}

		if (IncIds.isEmpty())
		{
			// nothing to do
			return;
		}

		for (Incident inc: [SELECT Id, uom_Incident_Id__c FROM Incident WHERE uom_Incident_Id__c IN :IncIds.keySet()])
		{
			IncIds.put(inc.uom_Incident_Id__c, inc.Id);
		}

		for (Affected_Market_Identifier__c affNMI: affNMIs)
		{
			if (affNMI.IncidentIdText__c != null && affNMI.uom_Incident__c == null)
			{
				if (!IncIds.containsKey(affNMI.IncidentIdText__c))
				{
					affNMI.addError('Incident Id not found.');
					continue;
				}

				affNMI.uom_Incident__c = IncIds.get(affNMI.IncidentIdText__c);
				affNMI.IncidentIdText__c = null;
			}
		}
	}

	public static void updateSetStatusField(List<Affected_Market_Identifier__c> newAffNMIs, Map<Id, Affected_Market_Identifier__c> oldAffNMIs)
	{
		if (newAffNMIs == null || newAffNMIs.isEmpty() || oldAffNMIs == null || oldAffNMIs.isEmpty())
			return;

		// We are now setting the AffectNMI Status field based on the Status Code value.
		for (Affected_Market_Identifier__c newAffNMI: newAffNMIs)
		{
			Affected_Market_Identifier__c oldAffNMI = oldAffNMIs.get(newAffNMI.Id);

			// check which has changed
			if (newAffNMI.uom_Status_Code__c != oldAffNMI.uom_Status_Code__c)
			{
				String statusCode = newAffNMI.uom_Status_Code__c;

				if (statusCode == null)
				{
					newAffNMI.uom_Status_Code__c.addError('Error: uom_Status_Code__c is null.');
					continue;
				}

				if (!Outage_IncidentProcessor.AFF_NMI_CODE_STATUS.containsKey(statusCode) &&
					newAffNMI.uom_Status__c == null)
				{
					// affNMI.uom_Status_Code__c.addError('Error: Unknown uom_Status_Code__c value.');
					newAffNMI.uom_Status__c = Outage_IncidentProcessor.AFF_NMI_IN_PROG; // default value.
					continue;
				}

				newAffNMI.uom_Status__c = Outage_IncidentProcessor.AFF_NMI_CODE_STATUS.get(statusCode);
			}

			else if (newAffNMI.uom_Status__c != oldAffNMI.uom_Status__c)
			{
				String status = newAffNMI.uom_Status__c;

				if (status == null)
				{
					newAffNMI.uom_Status__c.addError('Error: uom_Status__c is null.');
					continue;
				}

				if (!Outage_IncidentProcessor.AFF_NMI_STATUS_CODE.containsKey(status))
				{
					newAffNMI.uom_Status__c.addError('Error: Unknown uom_Status__c value.');
					continue;
				}

				newAffNMI.uom_Status_Code__c = Outage_IncidentProcessor.AFF_NMI_STATUS_CODE.get(status);
			}
		}
	}

	public static void createAffectedCustomer(List<Affected_Market_Identifier__c> newAffNMIs)
	{
		if (newAffNMIs == null || newAffNMIs.isEmpty())
			return;

		System.debug(
			Outage_IncidentProcessor.AffNMICreateAffCust(newAffNMIs)
		);
	}

	public static void updateAffectedCustomer(Map<Id, SObject> oldAffNMIs, Map<Id, SObject> newAffNMIs)
	{
		if (oldAffNMIs == null || oldAffNMIs.isEmpty() || newAffNMIs == null || newAffNMIs.isEmpty())
			return;

		System.debug(
			Outage_IncidentProcessor.AffNMIUpdAffCust((Map<Id, Affected_Market_Identifier__c>)oldAffNMIs, (Map<Id, Affected_Market_Identifier__c>)newAffNMIs)
		);
	}

	public static void deleteAffectedCustomer(List<Affected_Market_Identifier__c> delAffNMIs)
	{
		if (delAffNMIs == null || delAffNMIs.isEmpty())
			return;

		List<Affected_Customer__c> delAffCusts = new List<Affected_Customer__c>();
		for (Affected_Customer__c affCust: [SELECT Id FROM Affected_Customer__c WHERE uom_Affected_Market_Identifier__c IN :delAffNMIs])
		{
			delAffCusts.add(affCust);
		}

		if (!delAffCusts.isEmpty())
			delete delAffCusts;
	}

	public static void insertCheckNMIMultiIncident(List<Affected_Market_Identifier__c> affNMIs)
	{
		if (affNMIs == null || affNMIs.isEmpty())
			return;

		if (Incident_Setup__c.getInstance().Multi_Incident_Mode_Disabled__c || MultiIncModeDisabled)
		{
			System.debug('* Multi-Incident Mode is Disabled');
			return;
		}

		Outage_IncidentProcessor.insertCheckNMIMultiIncident(affNMIs);
	}

	public static void updateCheckNMIMultiIncident(List<Affected_Market_Identifier__c> newAffNMIs, Map<Id, Affected_Market_Identifier__c> oldAffNMIs)
	{
		if (newAffNMIs == null || newAffNMIs.isEmpty())
			return;

		if (Incident_Setup__c.getInstance().Multi_Incident_Mode_Disabled__c || MultiIncModeDisabled)
		{
			System.debug('* Multi-Incident Mode is Disabled');
			return;
		}

		Outage_IncidentProcessor.updateCheckNMIMultiIncident(newAffNMIs, oldAffNMIs);
	}
}