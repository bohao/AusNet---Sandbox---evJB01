/*
  @author  : harshad.kumbhar@ausnetservices.com.au
  @created : 03 Mar 2020
  @Description : Class for Get WorkOrder to SAP system
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
public without sharing class TVE_SAPInteg_GetWorkOrderToSAP implements Queueable{
   
    @TestVisible private static List<WorkOrderSets__x> mockedExtWO = new List<WorkOrderSets__x>();
    
    private static final String CREATECUST_CALLOUT = 'GetConstWO';
    
    public void execute(QueueableContext qc)
    {        
        List<Integration_Task__c> lstIntgTask = TVE_IntegUtility.getIntegrationTask('Get','WorkOrder','GetConstWO','In Progress');
        System.debug('Integration Task : ' + lstIntgTask);
        
        Boolean queryException = false;
        List<WorkOrder> woToUpdate = new List<WorkOrder>();

        Map<Id, Id> parentToTask = new Map<Id, Id>();
        Map<String,WorkOrder> oldmapWorkOrder = new Map<String,WorkOrder>();
        Map<String,WorkOrder> newmapWorkOrder = new Map<String,WorkOrder>();

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
            List<WorkOrder> lstWO = [SELECT Id,OrderNumber__c,StartDate,EndDate,System_Status__c
                                     FROM WorkOrder WHERE Id in: parentToTask.keySet()];
            for(WorkOrder wo : lstWO) {
                oldmapWorkOrder.put(wo.OrderNumber__c,wo);
            }
            newmapWorkOrder = getConstWOMapping(oldmapWorkOrder);
        } catch (Exception e) {
            queryException = true;
            //Fail all Integration_Task__c
            for(Integration_Task__c task : lstIntgTask) {
                failureMap.put(task.Id, e.getMessage());
            }
        }
        
        if(!queryException) {
            for(String extId : oldmapWorkOrder.keySet()) {
                if(newmapWorkOrder.containsKey(extId)) {
                    //Compare newmapWorkOrder with oldmapWorkOrder
                    WorkOrder newWO = newmapWorkOrder.get(extId);
                    WorkOrder oldWO = oldmapWorkOrder.get(extId);
                
                    if(newWO.StartDate == oldWO.StartDate && newWO.EndDate == oldWO.EndDate && newWO.System_Status__c == oldWO.System_Status__c) {
                        //If no changes are required, set Integration_Task__c successful
                        successMap.put(parentToTask.get(newWO.Id), newWO.Id);
                    } else {
                        //To update
                        woToUpdate.add(newWO);
                    }
                } else {
                    //OrderNumber not found in SAP
                    failureMap.put(parentToTask.get(oldmapWorkOrder.get(extId).Id), 'OrderNumber not found in SAP');
                }
            }
        
            if(!woToUpdate.isEmpty()) {
                List<Database.SaveResult> lstSR = Database.update(woToUpdate, false);
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

        lstIntgTask = TVE_IntegUtility.getIntegrationTask( 'Get','WorkOrder','GetConstWO','In Progress');
        if(!lstIntgTask.isEmpty()){
            TVE_SAPInteg_GetWorkOrderToSAP getWO = new TVE_SAPInteg_GetWorkOrderToSAP();
                        ID jobID = System.enqueueJob(getWO);  
        }
    }
    
    public static Map<String, WorkOrder>  getConstWOMapping(Map<String,WorkOrder> mapWorkOrder)
    {
        List<WorkOrderSets__x> lstWOs = new List<WorkOrderSets__x>();
        Map<String, WorkOrder> newmapWorkOrder = new Map<String, WorkOrder>();
        if(Test.isRunningTest())
        {
            lstWOs = (mockedExtWO.size() > 0) ? mockedExtWO : lstWOs;
        }
        else {
            lstWOs = TVE_IntegUtility.GetWOs(mapWorkOrder.keySet());
        }
        
        for (WorkOrderSets__x wo : lstWOs) {
            WorkOrder newItem = new WorkOrder(
                Id = mapWorkOrder.get(wo.OrderNumber__c).Id
            );
            if(String.isNotBlank(wo.StartDate__c))
            {
                newItem.StartDate = TVE_IntegUtility.dateConversionSAPtoSF(wo.StartDate__c);                               
            }
            if(String.isNotBlank(wo.FinishDate__c))
            {   
                newItem.EndDate = TVE_IntegUtility.dateConversionSAPtoSF(wo.FinishDate__c);
            }
            if(String.isNotBlank(wo.SystemStatus__c))
            {
                newItem.System_Status__c = wo.SystemStatus__c;                
            }
            newmapWorkOrder.put(wo.OrderNumber__c, newItem);
        }
        return newmapWorkOrder;
    }
    
}