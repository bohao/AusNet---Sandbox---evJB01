public without sharing class TVE_SAPInteg_CreateWork implements Queueable,Database.AllowsCallouts
{
    List<Integration_Task__c> lstIntgTask = new List<Integration_Task__c>();
    public void execute(QueueableContext qc)
    {
        Map<id,String> successMap = new Map<Id,String>();
        Map<id,String> failureMap = new Map<Id,String>();
        List<Id> projIdList = new List<id>();
        Map<id,Project__c> projectInfoMap = new Map<Id,Project__c>();
        Map<id,Opportunity> projOppMap = new Map<Id,Opportunity>();
        Map<id,Map<String,string>> BillToSoldToMap = new Map<id,Map<String,string>>();
        Project__c projRecord;
        Opportunity oppRecord;
        Map<String,String> BtStMap;
        Map<String,String> billToSoldToInfo;
        Map<String,String> creatIntTaskMap = new Map<String,String>();
        Map<String,String> updateIntTaskMap = new Map<String,String>();
        Map<String,String> updateIntTaskMapfail = new Map<String,String>();
        Map<String,String> createIntglogmapS = new Map<String,String>();
        Map<String,String> createIntglogmapF = new Map<String,String>();
        Map<String,string> WOprojMap = new Map<String,string>();
        // TVE_SAP_Int_APICalls.CreateWorkResponse response;
        String response;
        TVE_Integration_Constants__c intConstant = [select Integration_Method_Name__c,Assembly__c,Partner_Role_1__c,Partner_Role_2__c,MessageID__c
                                                    from TVE_Integration_Constants__c 
                                                    where Integration_Method_Name__c='TVE_SAPInteg_CreateMasterNoti' limit 1];//TVE_Integration_Constants__c.getall().values();
        
        API_Callout_Headers__mdt apiCallHea = [SELECT key__c, sourceSystem__c, targetSystem__c, 
                                               objectName__c, endpoint__c FROM API_Callout_Headers__mdt 
                                               WHERE objectName__c ='CreateWork' ];
        lstIntgTask = TVE_IntegUtility.getIntegrationTask( 'Create','Project__c','CreateWork','In Progress');
        
        if(!lstIntgTask.isEmpty()){
            System.debug('callSAPreq eexecute');
            
            for(Integration_Task__c intTask: lstIntgTask)
            {
                projIdList.add(intTask.ParentId__c);
            }
            if(projIdList.size()>0)
            {
                BillToSoldToMap=TVE_IntegUtility.getSoldToBillTO(projIdList);
                WOprojMap= TVE_IntegUtility.getCMType(projIdList);
                List<Project__c> lstProjs=TVE_IntegUtility.getProject(projIdList);
                for(Project__c proj:lstProjs)
                {
                    projectInfoMap.put(proj.id,proj);
                }
                
                List<Opportunity> oppList=[select id,Notification_Number__c,Notification_Type__c,Project__c,System_Status__c
                                           from Opportunity where Project__c IN:projIdList and Type='Design'];
                System.debug('oppList list map'+oppList);
                if(oppList.size()>0)
                {
                    for(Opportunity opp:oppList)
                    {
                        projOppMap.put(opp.Project__c,opp);
                    }
                }
            }
            
            for(Integration_Task__c iTask: lstIntgTask)
            {
                if(projectInfoMap.containsKey(iTask.ParentId__c) && projOppMap.containsKey(iTask.ParentId__c)){
                    projRecord = projectInfoMap.get(iTask.ParentId__c);
                    oppRecord = projOppMap.get(iTask.ParentId__c);
                    
                    BtStMap = BillToSoldToMap.get(iTask.ParentId__c);
                    response=TVE_SAP_Int_APICalls.callcreateWorkreq(projRecord,oppRecord,BtStMap,
                                                                    intConstant,apiCallHea,WOprojMap);
                    System.debug('response in execute'+response);
                    //After response is received
                    if(response=='Created')
                        successMap.put(iTask.id,iTask.ParentId__c);
                    else
                        failureMap.put(iTask.id,response);
                } else {
                    failureMap.put(iTask.id, 'Error: Cannot find the related Project or Opportunity record.');
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
        lstIntgTask=TVE_IntegUtility.getIntegrationTask( 'Create','Project__c','CreateWork','In Progress');
        if(!lstIntgTask.isEmpty()){
            TVE_SAPInteg_CreateWork updateCM = new TVE_SAPInteg_CreateWork();
            ID jobID = System.enqueueJob(updateCM);  
        }
    }
    
}