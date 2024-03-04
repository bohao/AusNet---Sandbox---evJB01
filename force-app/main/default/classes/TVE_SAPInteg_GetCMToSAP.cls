/*
  @author  : harshad.kumbhar@ausnetservices.com.au
  @created : 03 Mar 2020
  @Description : Class for Get CM to SAP system
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
public without sharing class TVE_SAPInteg_GetCMToSAP implements Queueable{
    
    @TestVisible private static List<ConstructionMeasureSets__x> mockedExtCM = new List<ConstructionMeasureSets__x>();    
    
    private static final String CREATECUST_CALLOUT = 'GetCM';
    public static Map<String,Id> mapAccUniqueIdProjId = new Map<String,Id>();
    
    public void execute(QueueableContext qc)
    {        
        List<Integration_Task__c> lstIntgTask = TVE_IntegUtility.getIntegrationTask( 'Get','Project__c','GetCM','In Progress');
		System.debug('Integration Task : ' + lstIntgTask);
      
        Boolean queryException = false;
        List<Project__c> ProjToUpdate = new List<Project__c>();
        List<Progress__c> ProgToUpdate = new List<Progress__c>();

        Map<Id, Id> parentToTask = new Map<Id, Id>();
        Map<String,Project__c> oldmapProj = new Map<String,Project__c>();
        Map<String,Project__c> newmapProj = new Map<String,Project__c>();

        Map<String,Progress__c> oldmapProg = new Map<String,Progress__c>();
        Map<Id,Progress__c> newmapProg = new Map<Id,Progress__c>();

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
            List<Project__c> lstProj = [SELECT Id,CMNumber__c,ProjectName__c,ContestabilityType__c,PlaningPermitNumber__c,SpearReferenceNumber__c,
                                        SubdivisionPlanNumber__c,Subdivision__c,ACCC_Form__c,CRAB_Form__c,SAPStatus__c,SAPStatusFlag__c
                                        FROM Project__c WHERE Id in: parentToTask.keySet() AND CmNumber__c != null];
            for(Project__c proj : lstProj) {
                oldmapProj.put(proj.CMNumber__c,proj);
            }
            
            wrapProjNProg wrapClass = getCMMapping(oldmapProj);

            newmapProj = wrapClass.project;           
            newmapProg = wrapClass.progress;


        } catch (Exception e) {
            queryException = true;
            //Fail all Integration_Task__c
            for(Integration_Task__c task : lstIntgTask) {
                failureMap.put(task.Id, e.getMessage() + '\r\n' + e.getStackTraceString());                
            }

        }

        if(!queryException) {
            for(String extId : oldmapProj.keySet()) {
                System.debug('External Id : '+ extId);
                System.debug('newMapProj :' + newmapProj);
                if(newmapProj.containsKey(extId)) {
                    //Compare newmapWorkOrder with oldmapWorkOrder
                    Project__c newProj = newmapProj.get(extId);
                    Project__c oldProj = oldmapProj.get(extId);
                
                    if(newProj.ProjectName__c == oldProj.ProjectName__c 
                    && newProj.PlaningPermitNumber__c == oldProj.PlaningPermitNumber__c 
                    && newProj.SpearReferenceNumber__c == oldProj.SpearReferenceNumber__c
                    && newProj.SubdivisionPlanNumber__c == oldProj.SubdivisionPlanNumber__c
                    && newProj.Subdivision__c == oldProj.Subdivision__c
                    && newProj.ContestabilityType__c == oldProj.ContestabilityType__c
                    && newProj.ACCC_Form__c == oldProj.ACCC_Form__c
                    && newProj.CRAB_Form__c == oldProj.CRAB_Form__c
                    && newProj.SAPStatus__c == oldProj.SAPStatus__c
                    && newProj.SAPStatusFlag__c == oldProj.SAPStatusFlag__c
                    ) {
                        //If no changes are required, set Integration_Task__c successful
                        successMap.put(parentToTask.get(newProj.Id), newProj.Id);
                    } else {
                        //To update
                        ProjToUpdate.add(newProj);
                    }
                } else {
                    //OrderNumber not found in SAP
                    failureMap.put(parentToTask.get(oldmapProj.get(extId).Id), 'Project related fields are not found in SAP');
                }
            }

            if(!ProjToUpdate.isEmpty()) {
                List<Database.SaveResult> lstSR = Database.update(ProjToUpdate, false);
                System.debug('lstSR Project:' + lstSR);
                List<Progress__c> lstProgInsert = new List<Progress__c>();
                for(Database.SaveResult res : lstSR) {
                    if (res.isSuccess()) {
                        System.debug('Project getId :' +parentToTask.get(res.getId()));
                        successMap.put(parentToTask.get(res.getId()), res.getId());
                        if(!newmapProg.isEmpty() && newmapProg.containsKey(res.getId()))
                        {
                            lstProgInsert.add(newmapProg.get(res.getId()));
                        }
                    } else {
                        List<String> errorMsg = new List<String>();
                        for(Database.Error err : res.getErrors()) {
                            errorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                        }
                        for (Project__c proj : ProjToUpdate) {                            
                            failureMap.put(parentToTask.get(proj.Id), String.join(errorMsg, '\r\n'));                        
                        }                        
                        
                    }                    
                }
                if(!lstProgInsert.isEmpty())
                {
                    insert lstProgInsert;
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
            System.System.debug('GetCMToSAP SuccessMap :' + successMap);    
            TVE_IntegUtility.UpdateInteTask(successMap,updateIntTaskMap);
            TVE_IntegUtility.createIntegLog(successMap,createIntglogmapS);
        }
        if(!failureMap.isEmpty()) {
            updateIntTaskMapFail.put('Status__c','Failed');
            createIntglogmapF.put('Status__c','Failed');
                
            TVE_IntegUtility.UpdateInteTask(failureMap,updateIntTaskMapFail);
            TVE_IntegUtility.createIntegLog(failureMap,createIntglogmapF);
        }

        lstIntgTask = TVE_IntegUtility.getIntegrationTask( 'Get','Project__c','GetCM','In Progress');
        if(!lstIntgTask.isEmpty()){
            TVE_SAPInteg_GetCMToSAP getCM = new TVE_SAPInteg_GetCMToSAP();
                        ID jobID = System.enqueueJob(getCM);  
        }

    }
    public class wrapProjNProg {
        public Map<String,Project__c> project {get; set;}
        public Map<Id,Progress__c> progress {get; set;} 
    }


   public static String getSplitStatus(String UserStatus)
   {
      String splitedstatus;
        if(String.isNotEmpty(UserStatus))
        {
            Integer lenOfStatus = UserStatus.length();
            if(lenOfStatus <= 4)
            {
                splitedstatus = UserStatus.substring(0, 4);                
            }
            if (lenOfStatus > 4){
                splitedstatus = UserStatus.left(4);                
            }
        }
        return splitedstatus;
   }
   public static String getSplitStatusLast(String UserStatus)
   {
      String splitedstatus;
        if(String.isNotEmpty(UserStatus))
        {
            Integer lenOfStatus = UserStatus.length();
            
            if (lenOfStatus > 4){
                splitedstatus = UserStatus.right(4);                
            }
        }
        return splitedstatus;
   }
    public static wrapProjNProg getCMMapping(Map<String,Project__c> mapProject)
    {
        
       List<ConstructionMeasureSets__x> lstCMs = new List<ConstructionMeasureSets__x>();
       Map<String, Project__c> newmapProj = new Map<String, Project__c>();
       Map<Id, Progress__c> newmapProg = new Map<Id, Progress__c>();
       
       List<String> CMNumbers = new List<String>();
        for (String Id : mapProject.keySet()) {
            CMNumbers.add(Id);
        }
        if(Test.isRunningTest())
        {
            lstCMs = (mockedExtCM.size() > 0) ? mockedExtCM : lstCMs; 
        }
        else {
            lstCMs = TVE_IntegUtility.GetCMs(CMNumbers);
        }
       
        List<Progress__c> lstProgress = new List<Progress__c>();
        wrapProjNProg wrapClass = new wrapProjNProg();
        wrapClass.progress = new Map<Id,Progress__c>();
        wrapClass.project = new Map<String,Project__c>();
        for (ConstructionMeasureSets__x cm : lstCMs) {
            if(mapProject.containsKey(cm.Cmnum__c))
            {
                System.debug('CMnumber :' + cm.Cmnum__c);
                Project__c newItem = new Project__c(
                    Id = mapProject.get(cm.Cmnum__c).Id
                );

                if(String.isNotBlank(cm.Cmnum__c))
                {
                    newItem.CMNumber__c = cm.Cmnum__c;    
                }
                
                if(String.isNotBlank(cm.Cmtxt__c))
                {
                    newItem.ProjectName__c = cm.Cmtxt__c;    
                }
                if(String.isNotBlank(cm.ZzTownPermit__c))
                {
                    newItem.PlaningPermitNumber__c = cm.ZzTownPermit__c;
                }
                if(String.isNotBlank(cm.ZzContestability__c))
                {
                    newItem.ContestabilityType__c = TVE_IntegUtility.getContesabilityInbound(cm.ZzContestability__c);
                }
                if(String.isNotBlank(cm.ZzLodgeSpear__c))
                {
                    newItem.SpearReferenceNumber__c = cm.ZzLodgeSpear__c;
                }
                if(String.isNotBlank(cm.ZzSubdivision__c))
                {
                    newItem.SubdivisionPlanNumber__c = cm.ZzSubdivision__c;
                }
                if(String.isNotBlank(cm.ZzSubDivi__c))
                {
                    newItem.Subdivision__c = cm.ZzSubDivi__c == 'Y' ? 'Yes' : 'No';
                }
                if(String.isNotBlank(cm.ZzAccc__c))
                {
                    newItem.ACCC_Form__c = cm.ZzAccc__c == 'Y' ? 'Yes' : 'No';
                }                        
                if(String.isNotBlank(cm.ZzCrab__c))
                {
                    newItem.CRAB_Form__c = cm.ZzCrab__c == 'Y' ? 'Yes' : 'No';
                } 
                if(String.isNotBlank(cm.UserStatus__c))
                {
                    //Updated by JTan on 20/04/2020 for TV-2883
                    newItem.SAPStatusFlag__c = (cm.UserStatus__c.length() > 4) ? getSplitStatusLast(cm.UserStatus__c) : '';

                    String newSAPStatus = (cm.UserStatus__c.length() >= 4) ? getSplitStatus(cm.UserStatus__c) : '';
                    String oldSAPStatus = mapProject.get(cm.Cmnum__c).SAPStatus__c;
                    Set<String> statusToPause = new Set<String>{'PREQ', 'DSNG', 'COMT'};
                    if(oldSAPStatus == 'REGI' && statusToPause.contains(newSAPStatus) && newItem.SAPStatusFlag__c != 'PREC') {
                        //Do Nothing
                    } else {
                        newItem.SAPStatus__c = newSAPStatus;
                    }
                }

                newItem.Updated_By_Integration__c = true;
                            
                Progress__c progress = new Progress__c();
                if(String.isNotBlank(cm.UserStatus__c))
                {
                    progress.SAPStatus__c = (cm.UserStatus__c.length() >= 4) ? getSplitStatus(cm.UserStatus__c) : '';               
                    progress.SAPStatusFlag__c = (cm.UserStatus__c.length() > 4) ? getSplitStatusLast(cm.UserStatus__c) : ''; 
                    progress.CMUserStatus__c = cm.UserStatus__c; 
                } 
                
                
                progress.StartDate__c =  Date.today();
                progress.Project__c = mapProject.get(cm.Cmnum__c).Id;
                if(String.isNotBlank(cm.ZzPrjOfficer__c))
                {
                    progress.ProjectAssignee__c = cm.ZzPrjOfficer__c;
                }
                if(String.isNotBlank(cm.ZzContestability__c))
                {
                    progress.SAPContestability__c = TVE_IntegUtility.getContesabilityInbound(cm.ZzContestability__c);
                }
                //lstProgress.add(progress);

                System.debug('GetCMToSAP Error Project:'+ newItem);
                System.debug('GetCMToSAP Error Progress:'+ progress);
                
                wrapClass.progress.put(progress.Project__c,progress); 
                
                wrapClass.project.put(newItem.CMNumber__c,newItem);              
                System.debug('GetCMToSAP CMNumber:'+ newItem.CMNumber__c);
                System.debug('GetCMToSAP Error wrap Progress:'+ wrapClass.project.size());
            }

            
        }
        System.debug('GetCMToSAP Wrap Project:'+ wrapClass.project);
        System.debug('GetCMToSAP Wrap Progress:'+ wrapClass.progress);
        return wrapClass;
    }
}