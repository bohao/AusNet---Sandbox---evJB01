public with sharing class Trig_DataUsePurpose implements UtilTrigHandle {

    /********** Disable logic **********/

	public static Boolean TrigDisabled = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().DataUsePurpose_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}


    /********** Trigger contexts **********/

    // Insert trigger contexts
    public void BeforeInsert(List<SObject> newSObjs) {
        handleDuplicateNameCheck(newSObjs, null);
    }
    
    // Update trigger contexts
    public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) {
        handleDuplicateNameCheck(newSObjs.values(), (Map<Id, DataUsePurpose>) oldSObjs);
    }

    /* if context is not implemented, condense into one-liners */
    public void AfterInsert(Map<Id, SObject> newSObjs) {}
    public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) {}
    public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
    public void AfterDelete(Map<Id, SObject> oldSObjs) {}
    public void AfterUndelete(Map<Id, SObject> newSObjs) {}


    /********** Trigger methods **********/

    private static void handleDuplicateNameCheck(List<DataUsePurpose> newRecordsList, Map<Id, DataUsePurpose> oldRecordsMap) {
        List<DataUsePurpose> dupsToCheck = new List<DataUsePurpose>();

        if (newRecordsList.isEmpty()) return;

        if (Trigger.isInsert) {
            dupsToCheck = newRecordsList;
        } else if (Trigger.isUpdate && !oldRecordsMap.isEmpty()) {

            for (DataUsePurpose dup : newRecordsList) {
                
                DataUsePurpose oldDup = oldRecordsMap.get(dup.Id);
                if (oldDup == null) continue;
    
                if (oldDup.Name.toLowercase() != dup.Name.toLowercase()) {
                    dupsToCheck.add(dup);
                }
            }   
        }

        if (!dupsToCheck.isEmpty()) {
            checkForDuplicateName(dupsToCheck);
        }
    }

    private static void checkForDuplicateName(List<DataUsePurpose> dupsToCheck) {
        Set<String> existingNames = new Set<String>();
        
        for (DataUsePurpose existingDup : [SELECT Name FROM DataUsePurpose]) {
            existingNames.add(existingDup.Name.toLowercase());
        }

        for (DataUsePurpose dup : dupsToCheck) {

            if (existingNames.contains(dup.Name.toLowercase())) {
                dup.Name.addError('A Data Use Purpose with this Name already exists.');
            }
        }
    }
}