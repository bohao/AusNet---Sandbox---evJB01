public without sharing class TVEProjectActionController 
{
    
    @AuraEnabled 
    public static TaskWrapper fetchTask(string recordId,Boolean projectDetailPage)
    {
        User curr_user = [Select id, Profile.Name, Profile.UserLicense.Name   
                            FROM User where Id=: UserInfo.getUserId() 
                            LIMIT 1][0];
                            
        String License = curr_user.Profile.UserLicense.Name;
        String usrProfile = curr_user.Profile.Name;

        TaskWrapper tskWrpLists = new TaskWrapper();
        List<TaskWrapperInfo> tskWrpInfo = new List<TaskWrapperInfo>();
        List<TaskWrapperInfo> tskWrpInfoCompleted = new List<TaskWrapperInfo>();
        Map<String,List<TVE_Actions_by_Activity__mdt>> mapCMd= new Map<String,List<TVE_Actions_by_Activity__mdt>>();
        List<task> taskList = new List<Task>();
        
        string condition;
        
        string cols = 'Id,Subject,Description,ActivityDate,Who.Name,WhoId,Priority,recordtypeID,'+
                    'recordtype.Name,recordtype.DeveloperName,Status,WhatId,What.Name,Artefact__c';
       	Id UserID=UserInfo.getUserId();
        
        if(projectDetailPage==true)
        	condition='whatId ='+'\''+recordId+'\''+ ' and OwnerId='+'\''+UserID+'\'';
        else
            condition='OwnerId='+'\''+UserID+'\'';
        
        string query = 'select '+cols+' from Task where '+condition;
        
        System.debug('query'+query);
        taskList = Database.query(query);        
        System.debug('taskList'+taskList.size()+taskList);
        
        List<TVE_Actions_by_Activity__mdt> actionActivity= [SELECT ActionLabel__c, Component_Name__c, Object__c,Order__c,
                                                            RecordTypeDeveloperName__c ,DeveloperName
                                                            FROM TVE_Actions_by_Activity__mdt];
        for(TVE_Actions_by_Activity__mdt actAvt:actionActivity)
        {
            List<TVE_Actions_by_Activity__mdt> records = new List<TVE_Actions_by_Activity__mdt>();
            if(mapCMD.containsKey(actAvt.RecordTypeDeveloperName__c))
            {
                records= mapCMD.get(actAvt.RecordTypeDeveloperName__c);
                records.add(actAvt);
                System.debug('records in if'+records);
                 mapCMd.put(actAvt.RecordTypeDeveloperName__c,records);
            }
            else
            {
                records.add(actAvt);
                System.debug('records in else'+records);
                 mapCMd.put(actAvt.RecordTypeDeveloperName__c,records);
            }
            
            System.debug('mapCMd'+mapCMd);
        }

        for(Task tsk:taskList)
        {            
            List<TVE_Actions_by_Activity__mdt> customdata = new List<TVE_Actions_by_Activity__mdt>();
            System.debug('Task Recordtype name'+tsk.RecordType.DeveloperName);
            if(mapCMd.containsKey(tsk.RecordType.DeveloperName))
            {
                customdata = mapCMd.get(tsk.RecordType.DeveloperName);
                System.debug('customdata'+customdata);
                TaskWrapperInfo tskWrp = new TaskWrapperInfo();
                tskWrp.TaskId=tsk.ID;
                tskWrp.Subject=tsk.Subject;
                tskWrp.Description=tsk.Description;
                tskWrp.ActivityDate=tsk.ActivityDate;
                tskWrp.Priority=tsk.Priority;
                tskWrp.taskRecordType=tsk.recordtype.DeveloperName;
                tskWrp.RelatedTo=tsk.WhatId;
                tskWrp.ProjectName=tsk.What.Name;//projIDNameMap.get(tsk.WhatId);
                tskWrp.ArtefactId=tsk.Artefact__c;
                tskWrp.Status=tsk.Status;

                for(TVE_Actions_by_Activity__mdt data:customdata)
                {
                    if(data.RecordTypeDeveloperName__c==tsk.RecordType.DeveloperName && data.Order__c==02)
                	    	tskWrp.actionLabel2=data.ActionLabel__c;
                    else
                        tskWrp.actionLabel1=data.ActionLabel__c;
                }
                if(tsk.Status!='Completed')
                    tskWrpInfo.add(tskWrp);
                else
                    tskWrpInfoCompleted.add(tskWrp);
            }
            
        }
        System.debug('tskWrpInfo'+tskWrpInfo);
        tskWrpLists.PendingTask=tskWrpInfo;
        tskWrpLists.HistoricalTask=tskWrpInfoCompleted;
        tskWrpLists.userLicense=License;
        tskWrpLists.userProfile = usrProfile;
        system.debug('License:'+License);
        return tskWrpLists;
    }   
    
     @AuraEnabled 
    public static ProjectWrapper fetchProject(string recordId){
        ProjectWrapper pw= new ProjectWrapper();
        if(recordId.startsWithIgnoreCase('00T'))
        {
        Task t = [select id,WhatId from Task where id=:recordId];
            pw.ProjectId=t.Whatid;
            pw.fromTask = true;
        
        }
        else 
        {
            pw.ProjectId=recordId;
            pw.fromTask = false;
        }
        return pw;
    }
    public class TaskWrapperInfo{
        @auraEnabled public string actionLabel1 {get; set;}
        @auraEnabled public string actionLabel2 {get; set;}
        @auraEnabled public string componentName {get; set;}
        @auraEnabled public String objectName {get; set;}
        @AuraEnabled public decimal order {get; set;}   
        @AuraEnabled public string taskRecordType{get; set;}
        @AuraEnabled public string Subject{get; set;}
        @AuraEnabled public string Status{get; set;}
        @AuraEnabled public string Description{get; set;}
        @AuraEnabled public Date ActivityDate{get; set;}
        @AuraEnabled public string Priority{get; set;}
        @AuraEnabled public string RelatedTo{get; set;}
        @AuraEnabled public string TaskId{get; set;}
        @AuraEnabled public string ProjectName{get; set;}
        @AuraEnabled public string ArtefactId{get; set;}
    }
     public class TaskWrapper{
        @auraEnabled public List<TaskWrapperInfo> PendingTask {get; set;}
        @auraEnabled public List<TaskWrapperInfo> HistoricalTask {get; set;}
        @AuraEnabled public string userLicense{get;set;}
        @AuraEnabled public string userProfile{get;set;}        
     }
     public class ProjectWrapper{
        @auraEnabled public String ProjectId {get; set;}
        @auraEnabled public boolean fromTask {get; set;}
     }
}