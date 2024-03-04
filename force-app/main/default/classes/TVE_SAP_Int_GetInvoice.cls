public without sharing class TVE_SAP_Int_GetInvoice implements Queueable,Database.AllowsCallouts
{
    @TestVisible private static List<Database.SaveResult> mockedResult = new List<Database.SaveResult>();
    
    List<Integration_Task__c> lstIntgTask= new List<Integration_Task__c>();
    public void execute(QueueableContext qc)
    {
        Map<Id,String> successMap = new Map<Id,String>();
        Map<Id,String> failureMap = new Map<Id,String>();
        Map<String,String> updateIntTaskMap = new Map<String,String>();
        Map<String,String> updateIntTaskMapfail = new Map<String,String>();
        Map<String,String> createIntglogmapS = new Map<String,String>();
        Map<String,String> createIntglogmapF = new Map<String,String>();
        Map<Id,InvoiceHeaderSets__x> arteInvoicemap = new Map<Id,InvoiceHeaderSets__x>();
        List<Artefact__c> updateArteList = new List<Artefact__c>();
        List<Id> updatedArteListSuccess = new List<Id>();
        Map<String,String> arteInteMap = new Map<String,String>();
        List<Id> arteIdsToAddDoc = new List<Id>();
        
        lstIntgTask = TVE_IntegUtility.getIntegrationTask( 'Get','Artefact__c','GetInvoice','In Progress');
        if(!lstIntgTask.isEmpty()){
            for(Integration_Task__c intTask: lstIntgTask)
            {
                boolean checkId = (intTask.ParentId__c InstanceOf Id);
                if(checkId)
                {
                    arteInteMap.put(intTask.ParentId__c,intTask.id);            
                }
                else {
                    failureMap.put(intTask.Id, 'Invalid ParentId'+ intTask.ParentId__c);
                }
            }
            if(!arteInteMap.isEmpty())
            {
                List<Artefact__c> arteList = [select id,InvoiceNumber__c from Artefact__c where ID IN :arteInteMap.keySet()];
                for(Artefact__c artefact:arteList)
                {
                    try {
                        TVE_IntegUtility.InvHeaderWrapper invHeadW;
                        invHeadW = TVE_IntegUtility.getInvoiceHeaderSet(artefact.InvoiceNumber__c);
                        if(invHeadW.invHSet != null) {
                            arteInvoicemap.put(artefact.id,invHeadW.invHSet);
                        }
                        else
                           failureMap.put(arteInteMap.get(artefact.id),invHeadW.errorMessage);  
                    } catch (Exception e) {
                        failureMap.put(arteInteMap.get(artefact.id), e.getMessage() + '\r\n' + e.getStackTraceString());
                    }
                }

                if(!arteInvoicemap.isEmpty())
                {
                    updateArteList=TVE_IntegUtility.updateArtefact(arteInvoicemap);

                    List<Database.SaveResult> res = Database.update(updateArteList, false);
                    if(Test.isRunningTest() && mockedResult.size()>0)
                    {                    
                       res = mockedResult;
                    }
                    for (Integer i = 0; i < res.size(); i++) {
                        Database.SaveResult s = res[i];
                        if (s.isSuccess()) {
                            updatedArteListSuccess.add(s.getId()); 
                        } else {
                            List<String> errorMsg = new List<String>();
                            for(Database.Error err : s.getErrors()) {
                                errorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                            }
                            failureMap.put(arteInteMap.get(updateArteList.get(i).Id), 'Error on Artefact update: ' + String.join(errorMsg, '\r\n'));
                        }
                    }
                }
                System.debug('updatedArteListSuccess'+updatedArteListSuccess);
                if(!updatedArteListSuccess.isEmpty())
                {
                    Set<Id> existingDocs = new Set<Id>();
                    for(ContentDocumentLink cdl:[select ContentDocumentId,LinkedEntityId,id from ContentDocumentLink where LinkedEntityId IN :arteInteMap.keySet()]) {
                        existingDocs.add(cdl.LinkedEntityId);
                    }

                    for(Id artId:updatedArteListSuccess)
                    {
                        if(!existingDocs.contains(artId))
                            arteIdsToAddDoc.add(artId);
                        else
                            SuccessMap.put(arteInteMap.get(artId),'Success');
                    }
                    List<ContentVersion> cvToInsert = TVE_IntegUtility.createContentVersion(arteIdsToAddDoc, arteInvoicemap);  
                    
                    if(!cvToInsert.isEmpty())
                    {
                        Map<Id, Id> mapCVIdToArtId = new Map<Id, Id>();
                        Map<Id, Id> mapCVIdToCDId = new Map<Id, Id>();

                        List<Database.SaveResult> res = Database.insert(cvToInsert, false);
                        
                        if(Test.isRunningTest() && mockedResult.size()>0)
                        {                         
                            res = mockedResult;
                        }
                        
                        for(Integer i = 0; i < res.size(); i++) {
                            Database.SaveResult s = res[i];
                            if (s.isSuccess()) {
                                mapCVIdToArtId.put(s.getId(), arteIdsToAddDoc.get(i));
                            }
                            else{
                                List<String> errorMsg = new List<String>();
                                for(Database.Error err : s.getErrors()) {
                                    errorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                                }
                                failureMap.put(arteInteMap.get(arteIdsToAddDoc.get(i)), 'Error on ContentVersion creation: ' + String.join(errorMsg, '\r\n'));
                            }
                        }
                        if(!mapCVIdToArtId.isEmpty()) {
                            for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :mapCVIdToArtId.keySet()]) {
                                mapCVIdToCDId.put(cv.Id, cv.ContentDocumentId);
                            }

                            List<ContentDocumentLink> conDocinkList = new List<ContentDocumentLink>();
                            for(Id key : mapCVIdToCDId.keySet()) {
                                conDocinkList.add(
                                    new ContentDocumentLink(
                                        ContentDocumentId = mapCVIdToCDId.get(key),
                                        LinkedEntityId = mapCVIdToArtId.get(key),
                                        ShareType = 'V'
                                    )
                                );
                            }
                            
                            List<Database.SaveResult> srList = Database.insert(conDocinkList, false);
                            for(Integer i = 0; i < srList.size(); i++) {
                                Database.SaveResult s = srList[i];
                                
                                if (s.isSuccess()) {
                                    SuccessMap.put(arteInteMap.get(conDocinkList.get(i).LinkedEntityId),'Success');
                                }
                                else{
                                    List<String> errorMsg = new List<String>();
                                    for(Database.Error err : s.getErrors()) {
                                        errorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                                    }
                                    failureMap.put(arteInteMap.get(conDocinkList.get(i).LinkedEntityId), 'Error on ContentDocumentLink creation: ' + String.join(errorMsg, '\r\n'));
                                }
                            }
                        }
                    }   
                }
            }
        }
        
        for (Integration_Task__c task : lstIntgTask) {
            if(!successMap.containsKey(task.Id) && !failureMap.containsKey(task.Id)) {
                failureMap.put(task.Id,'Error: Integration Task could not proceed');
            }
        }
        
        System.debug('SuccessMap :'+SuccessMap);
        System.debug('FailureMap :'+failureMap);
        if(successMap.size()>0)
        {
            updateIntTaskMap.put('Status__c','Successful');
            
            createIntglogmapS.put('Status__c','Successful');
            createIntglogmapS.put('Get','Get');
            
            TVE_IntegUtility.UpdateInteTask(successMap,updateIntTaskMap);
            TVE_IntegUtility.createIntegLog(successMap,createIntglogmapS);
        }
        if(FailureMap.size()>0)
        {
            updateIntTaskMapFail.put('Status__c','Failed');
            
            createIntglogmapF.put('Status__c','Failed');
            createIntglogmapF.put('Get','Get');
            
            TVE_IntegUtility.UpdateInteTask(FailureMap,updateIntTaskMapFail);
            TVE_IntegUtility.createIntegLog(FailureMap,createIntglogmapF);
        }
        
        lstIntgTask=TVE_IntegUtility.getIntegrationTask( 'Get','Artefact__c','GetInvoice','In Progress');
        if(!lstIntgTask.isEmpty()){
            TVE_SAP_Int_GetInvoice getInv = new TVE_SAP_Int_GetInvoice();
            ID jobID = System.enqueueJob(getInv);  
        }
    }
}