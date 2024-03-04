global class AffectedCustomerFixBatchClass implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC) {
     return Database.getQueryLocator('SELECT Id FROM Affected_Customer__c WHERE Notification_Pref__c = NULL AND CreatedDate = TODAY AND Last_Message_Template_Name__c = NULL');

   } 

   global void execute(Database.BatchableContext BC, List<Affected_Customer__c> scope) {

       for (Affected_Customer__c ac : scope) {

           ac.Last_Message_Template_Name__c = 'Incident Fix';

       }        update scope;
    

   }
    global void finish(Database.BatchableContext BC) {

       // Optional: Code to execute after all batches finish, such as sending an email notification

   }
   
}