public with sharing class Trig_AccountContactRelationship implements UtilTrigHandle
{

	/********** Disable logic **********/

	public static Boolean TrigDisabled = false;
	public static Boolean isRunningHandleMarketingCloudContact = false;

	public Boolean IsDisabled() {
		if (TrigSettings__c.getInstance().AccountContactRelation_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}


	/********** Trigger contexts **********/

	// Insert trigger contexts
	public void AfterInsert(Map<Id, SObject> newSObjs) {
		handleMarketingCloudContact(newSObjs.values(), null);
	}

	// Update trigger contexts
	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) {
		handleMarketingCloudContact(newSObjs.values(), (Map<Id, AccountContactRelation>) oldSObjs);
	}

	/* if context is not implemented, condense into one-liners */
	public void BeforeInsert(List<SObject> newSObjs) {}
	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) {}
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> newSObjs) {}


	/********** Trigger methods **********/

	private static void handleMarketingCloudContact(List<AccountContactRelation> acrsListNew, Map<Id, AccountContactRelation> acrsMapOld)
	{
		// Catch to stop trigger re-running (isRunningHandleMarketingCloudContact)
		if (isRunningHandleMarketingCloudContact) return;
		if (Trigger.isUpdate && acrsMapOld == null) return;
		isRunningHandleMarketingCloudContact = true;

		System.debug('*** Trig_AccountContactRelationship.handleMarketingCloudContact()');

		Id dcpRecordTypeId =  UtilDatabase.getRecordTypeNames('Contact').get(Outage_IncidentProcessor.CON_DCP_RT);
		Set<Id> validContactIdSet = new Set<Id>();
		Set<String> Outage_Roles = new Set<String>{ Outage_IncidentProcessor.ACR_ROLE_MKT_CON, Outage_IncidentProcessor.ACR_ROLE_SEC_CON };

		for (AccountContactRelation acrNew: acrsListNew)
		{
			if (Trigger.isInsert)
			{
				if (containsRole(acrNew.Roles, Outage_Roles))
				{
					validContactIdSet.add(acrNew.ContactId);
				}
			}
			else if (Trigger.isUpdate)
			{
				AccountContactRelation acrOld = acrsMapOld.get(acrNew.Id);
				// if (acrNew.Roles == acrOld.Roles) continue; // VC disabled this

				// check if the roles we are interested in are amended in some way (added or removed)
				// for new:
				if (containsRole(acrNew.Roles, Outage_Roles))
				{
					validContactIdSet.add(acrNew.ContactId);
				}
				// for old
				else if (containsRole(acrOld.Roles, Outage_Roles))
				{
					validContactIdSet.add(acrNew.ContactId);
				}
			}
		}

		if (!validContactIdSet.isEmpty()) {
			Outage_AccountContactUtils.handleMarketingCloudContactByContactIds(validContactIdSet);
		}
	}

	private static Boolean containsRole(String multiPL, Set<String> Roles)
	{
		Boolean output = false;
		if (multiPL == null || Roles == null) return output;

		for (String r: Roles)
		{
			if (multiPL.contains(r))
			{
				output = true;
				break;
			}
		}

		return output;
	}
}