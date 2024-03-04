/*
  @author  : harshad.kumbhar@ausnetservices.com.au
  @created : 06 Mar 2020
  @Description : Class for Get Notification to SAP system
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/

public without sharing class TVE_SAPInteg_GetNotificationToSAP implements Queueable {
    
    @TestVisible private static List<PMNotificationSets__x> mockedExtPMNoti = new List<PMNotificationSets__x>();    
    
    private static final String CREATECUST_CALLOUT = 'GetConstNoti';
    
    public void execute(QueueableContext qc)
    {        
        List<Integration_Task__c> lstIntgTask = TVE_IntegUtility.getIntegrationTask( 'Get','Opportunity','GetConstNoti','In Progress');
		System.debug('Integration Task : ' + lstIntgTask);
      
        Boolean queryException = false;
        List<Opportunity> OppToUpdate = new List<Opportunity>();

        Map<Id, Id> parentToTask = new Map<Id, Id>();
        Map<String,Opportunity> oldmapOpp = new Map<String,Opportunity>();
        Map<String,Opportunity> newmapOpp = new Map<String,Opportunity>();

        Map<Id,String> successMap = new Map<Id,String>();
        Map<Id,String> failureMap = new Map<Id,String>();
        Map<String,String> updateIntTaskMap = new Map<String,String>();
        Map<String,String> updateIntTaskMapFail = new Map<String,String>();
        Map<String,String> createIntglogmapS = new Map<String,String>();
        Map<String,String> createIntglogmapF = new Map<String,String>();

        for(Integration_Task__c item: lstIntgTask)
        {
            Boolean checkId = (item.ParentId__c InstanceOf Id);
            if(checkId)
            { 
                parentToTask.put(item.ParentId__c, item.Id);
            }
            else {
                failureMap.put(item.Id, 'Error: invalid ParentId on Integration Task');
            }
        }

          
        try {
            List<Opportunity> lstOpp = [SELECT Id,Notification_Number__c,System_Status__c, Project__c,Required_End_Date__c
                                     FROM Opportunity WHERE Id in: parentToTask.keySet()];
            for(Opportunity opp : lstOpp) {
                oldmapOpp.put(opp.Notification_Number__c,opp);
            }
            newmapOpp = getOpportunities(oldmapOpp);
        } catch (Exception e) {
            queryException = true;
            //Fail all Integration_Task__c
            for(Integration_Task__c task : lstIntgTask) {
                failureMap.put(task.Id, e.getMessage());
            }
        }
        
        if(!queryException) {
            for(String extId : oldmapOpp.keySet()) {
                if(newmapOpp.containsKey(extId)) {
                    //Compare newmapWorkOrder with oldmapWorkOrder
                    Opportunity newOpp = newmapOpp.get(extId);
                    Opportunity oldOpp = oldmapOpp.get(extId);
                
                    if(newOpp.Required_End_Date__c == oldOpp.Required_End_Date__c && newOpp.System_Status__c == oldOpp.System_Status__c) {
                        //If no changes are required, set Integration_Task__c successful
                        successMap.put(parentToTask.get(newOpp.Id), newOpp.Id);
                    } else {
                        //To update
                        OppToUpdate.add(newOpp);
                    }
                } else {
                    //OrderNumber not found in SAP
                    failureMap.put(parentToTask.get(oldmapOpp.get(extId).Id), 'Notification Number not found in SAP');
                }
            }
        
            if(!OppToUpdate.isEmpty()) {
                List<Database.SaveResult> lstSR = Database.update(OppToUpdate, false);
                for(Database.SaveResult res : lstSR) {
                    if (res.isSuccess()) {
                        successMap.put(parentToTask.get(res.getId()), res.getId());
                    } else {
                        List<String> errorMsg = new List<String>();
                        for(Database.Error err : res.getErrors()) {
                            errorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                        }
                        failureMap.put(parentToTask.get(res.getId()), String.join(errorMsg, '\r\n'));
                    }
                }
            }
        }
        for (Integration_Task__c task : lstIntgTask) {
            if(!successMap.containsKey(task.Id) && !failureMap.containsKey(task.Id)) {
                failureMap.put(task.Id,'Error: Integration Task could not proceed');
            }
        }
        if(!successMap.isEmpty()) {
            updateIntTaskMap.put('Status__c','Successful');
            createIntglogmapS.put('Status__c','Successful');
                
            TVE_IntegUtility.UpdateInteTask(successMap,updateIntTaskMap);
            TVE_IntegUtility.createIntegLog(successMap,createIntglogmapS);
        }
        if(!failureMap.isEmpty()) {
            updateIntTaskMapFail.put('Status__c','Failed');
            createIntglogmapF.put('Status__c','Failed');
                
            TVE_IntegUtility.UpdateInteTask(failureMap,updateIntTaskMapFail);
            TVE_IntegUtility.createIntegLog(failureMap,createIntglogmapF);
        }

        lstIntgTask=TVE_IntegUtility.getIntegrationTask( 'Get','Opportunity','GetConstNoti','In Progress');
        if(!lstIntgTask.isEmpty()){
            TVE_SAPInteg_GetNotificationToSAP getNoti = new TVE_SAPInteg_GetNotificationToSAP();
                        ID jobID = System.enqueueJob(getNoti);  
        }

    }
    public static Map<String,Opportunity> getOpportunities(Map<String,Opportunity> oldmapOpp)
    {
        List<PMNotificationSets__x> lstPMNoti = new List<PMNotificationSets__x>(); 
        Map<String, Opportunity> newmapOpp = new Map<String, Opportunity>();      
       
        if(Test.isRunningTest())
        {
            lstPMNoti = (mockedExtPMNoti.size() > 0) ? mockedExtPMNoti : lstPMNoti; 
        }
        else {
            lstPMNoti = TVE_IntegUtility.GetPMNoti(oldmapOpp.keySet());
        }       
    
        for (PMNotificationSets__x opp : lstPMNoti) {     
            Opportunity newItem = new Opportunity(
                Id = oldmapOpp.get(opp.NotificationNumber__c).Id
            );

            if(String.isNotBlank(opp.RequiredEndDate__c))
            {
                newItem.Required_End_Date__c =  TVE_IntegUtility.dateConversionSAPtoSF(opp.RequiredEndDate__c);                               
            }
            if(String.isNotBlank(opp.SystemStatus__c))
            {   
                newItem.System_Status__c = opp.SystemStatus__c;
            }        
            newmapOpp.put(opp.NotificationNumber__c, newItem);       
        }
       
        return newmapOpp;
    }
}