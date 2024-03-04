/*
  @author  : lakshay.sharma@ausnetservices.com.au
  @created : 2 March 2020
  @Description : Class for executing SAP Integration - Get CM Artefact to SAP
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/

public without sharing class TVE_SAP_Int_GetCMArtefact implements Queueable,Database.AllowsCallouts {
    public void execute(QueueableContext qc)
    {
        Map<String,String> arteInteMap = new Map<String,String>();

        Map<id,String> successMap = new Map<Id,String>();
        Map<id,String> failureMap = new Map<Id,String>();
        Map<String,String> createIntglogmapS = new Map<String,String>();
        Map<String,String> createIntglogmapF = new Map<String,String>();
        Map<String,String> UpdateIntTaskMap = new Map<String,String>();
        Map<String,String> updateIntTaskMapFail = new Map<String,String>();

        List<Integration_Task__c> lstIntgTask = TVE_IntegUtility.getIntegrationTask('Get','Artefact__c','GetCMArtefact','In Progress');
        if(!lstIntgTask.isEmpty()){
            
            for(Integration_Task__c intTask : lstIntgTask)
            {
                Boolean checkId = (intTask.ParentId__c InstanceOf Id);
                if(checkId)
                {
                    arteInteMap.put(intTask.ParentId__c, intTask.Id);
                }
                else    
                {
                    failureMap.put(intTask.Id, 'Invalid ParentId' + intTask.ParentId__c);
                }
            }

            if(!arteInteMap.isEmpty())
            {
                Map<Id, Artefact__c> arteMap = new Map<Id, Artefact__c>([SELECT Id,SAPNumber__c,Project__r.CMNumber__c,Classification__c FROM Artefact__c WHERE Id IN :arteInteMap.keySet()]);
                

                for(Id art : arteInteMap.keySet()){
                    if(!arteMap.keySet().contains(art)){
                        failureMap.put(arteInteMap.get(art), 'ParentId not found');
                    }
                }
                
                if(!arteMap.isEmpty()) {
                    Map<String,String> CMMap = new Map<String,String>();
                    for(TVE_File_Classification_Mapping__mdt key : [SELECT DocumentType__c ,Classification__c FROM TVE_File_Classification_Mapping__mdt]){
                        CMMap.put(key.Classification__c, key.documenttype__c);
                    }
                    
                    for(Artefact__c artefact : arteMap.values()){
                        try {
                            AttachmentSets__x attachsets = TVE_IntegUtility.getArtefact(artefact.SAPNumber__c,artefact.Project__r.CMNumber__c,CMMap.get(artefact.Classification__c));
                        } catch (Exception e) {
                            failureMap.put(arteInteMap.get(artefact.Id), e.getMessage());
                        }
                    }
                }
            }

            for(Integration_Task__c intTask : lstIntgTask) {
                if(!failureMap.containsKey(intTask.Id)) {
                    successMap.put(intTask.Id, intTask.ParentId__c);
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

            lstIntgTask = TVE_IntegUtility.getIntegrationTask('Get','Artefact__c','GetCMArtefact','In Progress');
            if(!lstIntgTask.isEmpty()){
                TVE_SAP_Int_GetCMArtefact getCMart = new TVE_SAP_Int_GetCMArtefact();
                ID jobID = System.enqueueJob(getCMart);
            }
        }
    }
}