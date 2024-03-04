// *****************************************************************
// ** Trig_Premises
// ** Description : This premise trigger handler class
// *****************************************************************
public with sharing class Trig_Premises implements UtilTrigHandle {

	public static Boolean TrigDisabled = false;
	 // *********************************************************************
	// *** Disable logic
	public Boolean IsDisabled()
	{
		return TrigSettings__c.getInstance().Trig_Premises_Disabled__c ? true : TrigDisabled;
	}

	 // if context is not implemented, condense into one-liners
	public void BeforeInsert(List<SObject> newSObjs) {
		Volume_TestingTools.generatePremises(newSObjs);
	}

	public void AfterInsert(Map<Id, SObject> newSObjs) {
		Volume_TestingTools.createAllRelatedRecords(newSObjs);
	}

	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) {
	   	Volume_TestingTools.deleteAllTestData(newSObjs);
	}

// if context is not implemented, condense into one-liners
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> oldSObjs) {}
	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) {}

}