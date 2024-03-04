public without sharing class TVE_SAPInt_CreateArtefact implements Queueable,Database.AllowsCallouts{
    
    List<Integration_Task__c> lstIntgTask = new  List<Integration_Task__c>();
    public void execute(QueueableContext qc)
    {
        List<id> ArtefactIdList = new List<id>();
        Map<id,Artefact__c> artefactMap = new Map<id,Artefact__c>();
        Map<id,ContentVersion> artCVMap = new Map<id,ContentVersion>();
        TVE_CreateCMArtResponse CAW;
        Map<id,String> successMap = new Map<Id,String>();
        Map<id,String> failureMap = new Map<Id,String>();
        Map<String,String> creatIntTaskMap = new Map<String,String>();
        Map<String,String> updateIntTaskMap = new Map<String,String>();
         Map<String,String> updateIntTaskMapfail = new Map<String,String>();
        Map<String,String> createIntglogmapS = new Map<String,String>();
        Map<String,String> createIntglogmapF = new Map<String,String>();
        Map<String,String> CMMap = new Map<String,String>();
        Map<String,String> artDocIdMap = new Map<String,String>();
        Map<String,String> fileextMap = new Map<String,String>();
        
        API_Callout_Headers__mdt apiCallHea = [SELECT key__c, sourceSystem__c, targetSystem__c, 
                                  objectName__c, endpoint__c FROM API_Callout_Headers__mdt 
                                  WHERE DeveloperName ='Create_Attachment_Callout' ];
         List<TVE_File_Classification_Mapping__mdt> classificationMapping = [SELECT DeveloperName,Classification__c,documenttype__c
                                                                       FROM TVE_File_Classification_Mapping__mdt  ];
        for(TVE_File_Classification_Mapping__mdt cm:classificationMapping)
            CMMap.put(cm.Classification__c,cm.documenttype__c);
        
        List<TVE_File_ext_Mapping__c> fileExt =[select name,Type__c from 	TVE_File_ext_Mapping__c];
        for(TVE_File_ext_Mapping__c FE : fileExt)
            fileextMap.put(FE.name,FE.Type__c);
        
        //get Integration task
        lstIntgTask = TVE_IntegUtility.getIntegrationTask( 'Create','Artefact__c','CreateArtefact','In Progress');
        System.debug('lstIntgTask in main class'+lstIntgTask);
        if(!lstIntgTask.isEmpty()){
            for(Integration_Task__c intTask: lstIntgTask)
            {
                Boolean checkId = (intTask.ParentId__c InstanceOf Id);
                if(checkId)
                {
                    ArtefactIdList.add(intTask.ParentId__c);
                }
                else {
                    failureMap.put(intTask.Id, 'Error: invalid ParentId on Integration Task');
                }
            }
            if(ArtefactIdList.size()>0)
            {
                artefactMap=TVE_IntegUtility.getArtefact(ArtefactIdList);
                artCVMap=TVE_IntegUtility.getContentVersion(ArtefactIdList);
            }
        }
        
        for(Integration_Task__c iTask: lstIntgTask){
            Artefact__c artTemp = artefactMap.get(iTask.ParentId__c);
            CAW=TVE_SAP_Int_APICalls.callCreateAttachment(artefactMap.get(iTask.ParentId__c),artCVMap.get(iTask.ParentId__c),apiCallHea,CMMap.get(artTemp.Classification__c),fileextMap);
            //System.debug('CAW.payloadAW'+CAW.payload.d.ArcDocId);
            if(CAW.status.startsWith('2')){
                successMap.put(iTask.id,iTask.ParentId__c);
                if(CAW.payload!=null)
                	artDocIdMap.put(iTask.ParentId__c,CAW.payload.d.ArcDocId);
            }
            else
                failureMap.put(iTask.id,CAW.statusMessage);
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
        if(artDocIdMap.size()>0)
            TVE_IntegUtility.updateArcID(artDocIdMap);
        lstIntgTask=TVE_IntegUtility.getIntegrationTask('Create','Artefact__c','CreateArtefact','In Progress');
        System.debug('lstIntgTask in create Artefact'+lstIntgTask.size());
        if(!lstIntgTask.isEmpty()){
            TVE_SAPInt_CreateArtefact createArte = new TVE_SAPInt_CreateArtefact();
             if(!Test.isRunningTest())
                 ID jobID = System.enqueueJob(createArte);  
        }
    }
    

}