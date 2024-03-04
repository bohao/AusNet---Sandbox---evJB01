public without sharing class TVE_SAPInteg_CreateMasterNoti implements Queueable,Database.AllowsCallouts
{
    List<Integration_Task__c> lstIntgTask = new  List<Integration_Task__c>();
    public void execute(QueueableContext qc)
    {
        Map<Id,String> successMap = new Map<Id,String>();
        Map<Id,String> failureMap = new Map<Id,String>();
        Map<Id,String> oppNotinumberMap = new Map<Id,String>();
        Map<Id,Id> oppIdToProjIdMap = new Map<Id,Id>();
        Map<Id,Id> projIdToTaskIdMap = new Map<Id,Id>();
        List<Id> projIdList = new List<id>();
        Map<Id,Project__c> projectInfoMap = new Map<Id,Project__c>();
        Map<Id,Opportunity> projOppMap = new Map<Id,Opportunity>();
        Map<Id,Map<String,string>> BillToSoldToMap = new Map<id,Map<String,string>>();
        Project__c projRecord;
        Opportunity oppRecord;
        Map<String,String> BtStMap;
        String SoldTo;
        TVE_SAP_Int_APICalls.NotiResponse response;
        Map<String,String> creatIntTaskMap = new Map<String,String>();
        Map<String,String> updateIntTaskMap = new Map<String,String>();
        Map<String,String> updateIntTaskMapfail = new Map<String,String>();
        Map<String,String> createIntglogmapS = new Map<String,String>();
        Map<String,String> createIntglogmapF = new Map<String,String>();
        API_Callout_Headers__mdt apiCallHea = new  API_Callout_Headers__mdt();
        TVE_SAP_Int_APICalls.PartnerResponse PRAG; 
        TVE_SAP_Int_APICalls.PartnerResponse PRVW;
        API_Callout_Headers__mdt UpdateNotificationPartner= [SELECT key__c, sourceSystem__c, targetSystem__c, 
                                                             objectName__c, endpoint__c FROM API_Callout_Headers__mdt 
                                                             WHERE DeveloperName ='PartnerAG_VW_Callout' ];
        
        TVE_Integration_Constants__c intConstant = [select Integration_Method_Name__c,Assembly__c,Partner_Role_1__c,Partner_Role_2__c,MessageID__c
                                                    from TVE_Integration_Constants__c 
                                                    where Integration_Method_Name__c='TVE_SAPInteg_CreateMasterNoti' limit 1];//TVE_Integration_Constants__c.getall().values();
        
        System.debug('callSAPreq');
        
        lstIntgTask = TVE_IntegUtility.getIntegrationTask( 'Create','Project__c','CreateMasterNoti','In Progress');
        if(!lstIntgTask.isEmpty()){
            System.debug('callSAPreq eexecute'+lstIntgTask.size());
            for(Integration_Task__c intTask: lstIntgTask)
            {
                projIdList.add(intTask.ParentId__c);
                projIdToTaskIdMap.put(intTask.ParentId__c, intTask.Id);
            }
            if(projIdList.size()>0)
            {
                BillToSoldToMap=TVE_IntegUtility.getSoldToBillTO(projIdList);
                
                List<Project__c> lstProjects=TVE_IntegUtility.getProject(projIdList);
                
                for(Project__c proj:lstProjects){
                    projectInfoMap.put(proj.id,proj);
                }
                
                for(Opportunity opp:[select id,Notification_Number__c,Notification_Type__c,Project__c,System_Status__c
                                     from Opportunity where Project__c IN:projIdList and Type='Design']){
                    projOppMap.put(opp.Project__c,opp);
                    oppIdToProjIdMap.put(opp.Id, opp.Project__c);
                }
            }
            for(Integration_Task__c iTask: lstIntgTask)
            {
                if(projectInfoMap.containsKey(iTask.ParentId__c) && projOppMap.containsKey(iTask.ParentId__c)){
                    projRecord = projectInfoMap.get(iTask.ParentId__c);
                    oppRecord = projOppMap.get(iTask.ParentId__c);
                    
                    BtStMap = BillToSoldToMap.get(iTask.ParentId__c);
                    System.debug('BtStMap333333'+BtStMap);
                    if(BtStMap!=null && BtStMap.size()>0)
                    {
                        if(BtStMap.containsKey('SoldTo'))
                            SoldTo = BtStMap.get('SoldTo');
                    }
                    if(projRecord.CMNumber__c==null){
                        apiCallHea = [SELECT key__c, sourceSystem__c, targetSystem__c, 
                                      objectName__c, endpoint__c FROM API_Callout_Headers__mdt 
                                      WHERE DeveloperName ='CreateMasterNoti_Callout' ];
                        
                        response=TVE_SAP_Int_APICalls.callCreateNotireq(projRecord,oppRecord,
                                                                        SoldTo,intConstant,apiCallHea,false,'');
                        
                        if(response.isSuccess==false){
                            failureMap.put(iTask.id,response.errorMessage);
                        }else{
                            oppNotinumberMap.put(projOppMap.get(iTask.ParentId__c).Id,response.notiNumber);
                        }
                    }
                    else{
                        apiCallHea = [SELECT key__c, sourceSystem__c, targetSystem__c, 
                                      objectName__c, endpoint__c FROM API_Callout_Headers__mdt 
                                      WHERE DeveloperName ='UpdateMasterNoti_Callout'];
                        
                        TVE_IntegUtility.ConstMeasureWrapper CMWrapper=TVE_IntegUtility.getConstMeasureSet(projRecord.CMNumber__c);
                        if(CMWrapper.cmset!=null){
                            response=TVE_SAP_Int_APICalls.callCreateNotireq(projRecord,oppRecord,
                                                                            SoldTo,intConstant,apiCallHea,true,CMWrapper.cmset.Qmnum__c);
                            if(response.isSuccess==false){
                                failureMap.put(iTask.id,response.errorMessage);
                            }else{
                                PRAG=TVE_SAP_Int_APICalls.callPartnerAG_VW(UpdateNotificationPartner,response.notiNumber,projRecord.id,SoldTo,'AG');
                                if(PRAG.status.startsWith('2')){
                                    PRVW=TVE_SAP_Int_APICalls.callPartnerAG_VW(UpdateNotificationPartner,
                                                                               response.notiNumber,
                                                                               projRecord.id,
                                                                               projRecord.ProjectAssignee__r.Employee_ID__c,
                                                                               'VW');
                                    if(PRVW.status.startsWith('2')){
                                        oppNotinumberMap.put(projOppMap.get(iTask.ParentId__c).Id,response.notiNumber);
                                    }else{
                                        failureMap.put(iTask.id,PRVW.statusMessage);
                                    }
                                }else{
                                    failureMap.put(iTask.id,PRAG.statusMessage);
                                }
                            }
                        }else{
                            failureMap.put(iTask.id,CMWrapper.errorMessage);
                        }
                    }
                } else {
                    failureMap.put(iTask.id, 'Error: Cannot find the related Project or Opportunity record.');
                }
            }
            
            if(!oppNotinumberMap.isEmpty()){
                List<Id> oppIds = new List<Id>(oppNotinumberMap.keySet());
                List<Database.SaveResult> srList = TVE_IntegUtility.updateOpp(oppIds, oppNotinumberMap);
                for(Integer i = 0; i < srList.size(); i++) {
                    Database.SaveResult sr = srList.get(i);
                    if (!sr.isSuccess()) {
                        List<String> errorMsg = new List<String>();
                        for(Database.Error err : sr.getErrors()) {
                            errorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                        }
                        failureMap.put(projIdToTaskIdMap.get(oppIdToProjIdMap.get(oppIds.get(i))), 'Error on Opportunity update: ' + String.join(errorMsg, '\r\n'));
                    }
                }
            }
            
            for(Integration_Task__c iTask: lstIntgTask){
                if(!failureMap.containsKey(iTask.Id)){
                    successMap.put(iTask.id,iTask.ParentId__c);
                }
            }
            
            if(successMap.size()>0){
                creatIntTaskMap.put('SObject__c','Project__c');
                creatIntTaskMap.put('Type__c','CreateWork');
                creatIntTaskMap.put('Status__c','In Progress');
                creatIntTaskMap.put('Operation__c','Create');
                
                updateIntTaskMap.put('Status__c','Successful');
                createIntglogmapS.put('Status__c','Successful');
                
                
                TVE_IntegUtility.UpdateInteTask(successMap,updateIntTaskMap);
                TVE_IntegUtility.createIntegLog(successMap,createIntglogmapS);
                TVE_IntegUtility.CreateInteTask(successMap,creatIntTaskMap);
            }
            
            if(failureMap.size()>0){
                updateIntTaskMapFail.put('Status__c','Failed');
                createIntglogmapF.put('Status__c','Failed');
                
                TVE_IntegUtility.UpdateInteTask(failureMap,updateIntTaskMapFail);
                TVE_IntegUtility.createIntegLog(failureMap,createIntglogmapF);
            }
        }
            
        lstIntgTask=TVE_IntegUtility.getIntegrationTask( 'Create','Project__c','CreateMasterNoti','In Progress');
        if(!Test.isRunningTest()){
            if(!lstIntgTask.isEmpty()){
                TVE_SAPInteg_CreateMasterNoti createMasterNoti = new TVE_SAPInteg_CreateMasterNoti();
                Id jobID = System.enqueueJob(createMasterNoti);  
            }else{
                TVE_SAPInteg_CreateWork createWork = new TVE_SAPInteg_CreateWork();
                // enqueue the job for processing
                Id jobID = System.enqueueJob(createWork);
            } 
        }
    }
}