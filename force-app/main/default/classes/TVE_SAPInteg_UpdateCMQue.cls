public without sharing class TVE_SAPInteg_UpdateCMQue implements Queueable,Database.AllowsCallouts{
    List<Integration_Task__c> lstIntgTask = new List<Integration_Task__c>();
    /*public TVE_SAPInteg_UpdateCMQue(List<Integration_Task__c> lstIntgTask){
        this.lstIntgTask=lstIntgTask;
    }*/
     public void execute(QueueableContext qc)
    {
        List<Id> projIdList = new List<id>();
        Map<id,Project__c> projectInfoMap = new Map<Id,Project__c>();
        Project__c projRecord;
        TVE_SAP_Int_APICalls.UpdateCMResponse response;
         Map<id,String> successMap = new Map<Id,String>();
        Map<id,String> failureMap = new Map<Id,String>();
        //Map<String,String> creatIntTaskMap = new Map<String,String>();
        Map<String,String> updateIntTaskMap = new Map<String,String>();
         Map<String,String> updateIntTaskMapfail = new Map<String,String>();
        Map<String,String> createIntglogmapS = new Map<String,String>();
        Map<String,String> createIntglogmapF = new Map<String,String>();
        
        API_Callout_Headers__mdt apiCallHea = [SELECT key__c, sourceSystem__c, targetSystem__c, 
                                               objectName__c, endpoint__c FROM API_Callout_Headers__mdt 
                                               WHERE objectName__c ='UpdateConstructionMeasure' ];
        
     	lstIntgTask = TVE_IntegUtility.getIntegrationTask( 'Update','Project__c','UpdateCM','In Progress');
        if(!lstIntgTask.isEmpty()){
             for(Integration_Task__c intTask: lstIntgTask)
            {
                Boolean checkId = (intTask.ParentId__c InstanceOf Id);
                if(checkId)
                {
                    projIdList.add(intTask.ParentId__c);
                }
                else {
                    failureMap.put(intTask.Id, 'Error: invalid ParentId on Integration Task');
                }
            }
            if(projIdList.size()>0)
            {
                 List<Project__c> projIds=TVE_IntegUtility.getProject(projIdList);
                
                for(Project__c proj:projIds)
                	projectInfoMap.put(proj.id,proj);
           }
             for(Integration_Task__c iTask: lstIntgTask)
            {
                projRecord = new project__c();
                projRecord = projectInfoMap.get(iTask.ParentId__c);
                response=TVE_SAP_Int_APICalls.callCMUpdateReq(projRecord,apiCallHea);
               // System.debug('Response status message'+response.statusMessage);
               if(response!=null)
               {
                if(response.statusMessage=='No Content')
                   successMap.put(iTask.id,'success');
                else
                {
                    if(response.payloadUpCM!=null)
                	failureMap.put(iTask.id,response.statusMessage+response.payloadUpCM);
                    else
                        failureMap.put(iTask.id,response.statusMessage);
                }
               }
            }

            for (Integration_Task__c task : lstIntgTask) {
                if(!successMap.containsKey(task.Id) && !failureMap.containsKey(task.Id)) {
                    failureMap.put(task.Id,'Error: Integration Task could not proceed');
                }
            }
            if(successMap.size()>0)
            {
                    updateIntTaskMap.put('Status__c','Successful');
                    createIntglogmapS.put('Status__c','Successful');

                TVE_IntegUtility.UpdateInteTask(successMap,updateIntTaskMap);
                TVE_IntegUtility.createIntegLog(successMap,createIntglogmapS);
                            
            }
            if(FailureMap.size()>0)
            {
                updateIntTaskMapFail.put('Status__c','Failed');
                
                createIntglogmapF.put('Status__c','Failed');
                
                TVE_IntegUtility.UpdateInteTask(FailureMap,updateIntTaskMapFail);
                TVE_IntegUtility.createIntegLog(FailureMap,createIntglogmapF);
            }
        }
        
        lstIntgTask=TVE_IntegUtility.getIntegrationTask( 'Update','Project__c','UpdateCM','In Progress');
        if(!lstIntgTask.isEmpty()){
            TVE_SAPInteg_UpdateCMQue updateCM = new TVE_SAPInteg_UpdateCMQue();
                        ID jobID = System.enqueueJob(updateCM);  
        }
    }
}