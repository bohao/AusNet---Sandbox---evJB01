global class UpdateChildDeviceRecordsBatch implements Database.Batchable<SObject>,Schedulable {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, DER_Application__c, (SELECT Id,CreatedDate, Parent_Device__c, DER_Application__c FROM Devices__r) FROM Device__c WHERE Parent_Device__c = null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Device__c> parentRecords) {
        List<Device__c> childRecordsToUpdate = new List<Device__c>();
		List<DER_Application__c> derRecordsToUpdate = new List<DER_Application__c>();
        Map<Id,Datetime> idDateMap = new Map<Id,Datetime>();
        for (Device__c parentRecord : parentRecords) {
            if(!parentRecord.Devices__r.isEmpty()) {
               for (Device__c childRecord : parentRecord.Devices__r) {
                idDateMap.put(parentRecord.DER_Application__c,childRecord.CreatedDate); 
                childRecord.DER_Application__c = parentRecord.DER_Application__c; // Update child record data from parent record data
                childRecordsToUpdate.add(childRecord);
               }
            }
        }
        for (Id s : idDateMap.keySet()) {
                            
                           
                               DER_Application__c dApp = new DER_Application__c(); 
                               dApp.Id =s;
                               dApp.Post_Installation_Date__c = idDateMap.get(s);              			 
                               derRecordsToUpdate.add(dApp);
                            
         }
        if(!childRecordsToUpdate.isEmpty()) { 
           update childRecordsToUpdate;
        }  
        if(!derRecordsToUpdate.isEmpty()) { 
           UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = true;
           update derRecordsToUpdate;
        }  
    }

    global void finish(Database.BatchableContext BC) {
        // Optional finish logic
    }
    
     global void execute(SchedulableContext sc)
     {
      	UpdateChildDeviceRecordsBatch b = new UpdateChildDeviceRecordsBatch(); 
        database.executeBatch(b,200);
     }
}