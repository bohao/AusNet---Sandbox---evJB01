public with sharing class Trig_SegmentLoader implements UtilTrigHandle
{
	public static Boolean TrigDisabled = false;

	// *********************************************************************
	// *** Disable logic
	public Boolean IsDisabled()
	{
		return TrigSettings__c.getInstance().SegmentLoader_Trigger_Disabled__c ? true : TrigDisabled;
	}

	// *********************************************************************
	// *** Trigger contexts
	public void BeforeInsert(List<SObject> newSObjs)
	{
		Outage_NMITools.SL_CreateCampaigns(newSObjs);
	}

	// if context is not implemented, condense into one-liners
	public void AfterInsert(Map<Id, SObject> newSObjs) {}
	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) {}
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> oldSObjs) {}
	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) {}


	// *********************************************************************
	// *** Methods

}