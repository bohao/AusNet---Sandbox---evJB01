public without sharing class TVE_SAPInteg_RequestInvoice implements Queueable,Database.AllowsCallouts{
    public void execute(QueueableContext qc) {     
		
        requestInvoiceInteg();
        
    }
    public static void requestInvoiceInteg()
    {
          List<Id> artefactIdList = new List<Id>();
        Map<Id,Artefact__c> artefactInfoMap = new Map<Id,Artefact__c>();
        Artefact__c artfctRecord;
        HttpResponse response;
        Map<id,String> successMap = new Map<Id,String>();
        Map<id,String> failureMap = new Map<Id,String>();
        Map<String,String> updateIntTaskMap = new Map<String,String>();
        Map<String,String> updateIntTaskMapfail = new Map<String,String>();
        Map<String,String> createIntglogmapS = new Map<String,String>();
        Map<String,String> createIntglogmapF = new Map<String,String>();
        
        API_Callout_Headers__mdt apiCallHea = [SELECT key__c, sourceSystem__c, targetSystem__c, 
                                               objectName__c, endpoint__c FROM API_Callout_Headers__mdt 
                                               WHERE objectName__c ='RequestInvoice' ];
        System.debug('EndPoint Check :' +apiCallHea.endpoint__c);
        List<Integration_Task__c> lstIntgTask = TVE_IntegUtility.getIntegrationTask( 'GET','Artefact__c','RequestInvoice','In Progress');
        if(!lstIntgTask.isEmpty())
        {
            for(Integration_Task__c intTask: lstIntgTask)
            {
                Boolean checkId = (intTask.ParentId__c InstanceOf Id);
                if(checkId)
                {
                artefactIdList.add(intTask.ParentId__c);
                }
                else {
                    failureMap.put(intTask.Id, 'Error: invalid ParentId on Integration Task');
                }

            }
            if(artefactIdList.size()>0)
            {
                List<Artefact__c> artefactLst=TVE_IntegUtility.getArtefactList(artefactIdList);

                for(Artefact__c artfct:artefactLst)
                {
                    artefactInfoMap.put(artfct.Id,artfct);
                    
                }
                
            }
            for(Integration_Task__c iTask: lstIntgTask)
            {
                try 
                {
                    artfctRecord = new Artefact__c();
                    artfctRecord = artefactInfoMap.get(iTask.ParentId__c);
                    response=TVE_SAPInteg_RequestInvoiceUtil.callRequestInvoice(artfctRecord,apiCallHea);
                    Map<String, Object> resp = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());

                    if(response!=null)
                    {
                        if(response.getstatusCode() == 200 && response.getbody() != null){
    
                            if(resp.get('status') == '201'){
                                successMap.put(iTask.id,'success');
                            }
                            else{
                                failureMap.put(iTask.id, (String)resp.get('statusMessage'));
                            }
                        }
                        else{
                            failureMap.put(iTask.id, (String)response.getStatus());                        
                            }
                    }
                } 
                catch (Exception e) {
                    failureMap.put(iTask.id, e.getMessage() + '\r\n' + e.getStackTraceString());
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
        
        lstIntgTask = TVE_IntegUtility.getIntegrationTask( 'GET','Artefact__c','RequestInvoice','In Progress');
        if(!lstIntgTask.isEmpty()){
            TVE_SAPInteg_RequestInvoice reqInvoice = new TVE_SAPInteg_RequestInvoice();
            
            ID jobID = System.enqueueJob(reqInvoice);  
            
        }
    }
}