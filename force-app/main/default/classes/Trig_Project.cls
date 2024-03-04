/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 23 dec 2019
@Description : Class for Project Trigger
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-------------------------------------------------------------------------------------------------------
23/12/19          Brajesh Tiwary             Added method ValidateStatusChangeSMS() on  After Update
28/05/19          Pavan Dave                 Renamed TVE_Trig_Project to Trig_Project
-------------------------------------------------------------------------------------------------------
*/
public without sharing class Trig_Project implements UtilTrigHandle{
    public static Boolean TrigDisabled = false;
    
    public Boolean IsDisabled()
    {
        if (TrigSettings__c.getInstance().Project_Trigger_Disabled__c)
            return true;
        else
            return TrigDisabled;
    }
    public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
    {
        ValidateStatusChangeSMS(newSObjs,oldSObjs);
        Qualify_CreateIntegTask(newSObjs,oldSObjs);
        Qualify_CreateAzureUser(newSObjs,oldSObjs);
        Qualify_HandleSharing(newSObjs,oldSObjs);
    }
    // if context is not implemented, condense into one-liners
    public void AfterInsert(Map<Id, SObject> newSObj){
        Qualify_CreateIntegTask(newSObj,null);
        Qualify_UpdateProj_AccContLookups(newSObj,null);
        Qualify_PopulateProjUrls(newSObj,null);
        Qualify_ArtefactCreation(newSObj,null);
        Qualify_WorkOrderCreation(newSObj,null);
        Qualify_OpportunityCreation(newSObj,null);
    }
    public void AfterDelete(Map<Id, SObject> oldSObjs) {}
    public void AfterUndelete(Map<Id, SObject> newSObjs) {}
    public void BeforeInsert(List<SObject> newSObjs) {
        Qualify_PrePopulateProject(newSObjs);
        Qualify_InsertProjectWorkCodeAndMore(newSObjs);
        Qualify_SiteOwnerAuthRepCreation(newSObjs);
    }
    public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
    public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs){
        Qualify_UpdateIntegTasks(newSObjs,oldSObjs);
        Qualify_PopulateProjUrls(newSObjs,oldSObjs);
        Qualify_RemoveProjectUrl(newSObjs,oldSObjs);
	}
    // *********************************************************************
    // *** Trigger methods
    
    // ---------------------------------------------------//
    //-----------  Trigger utility methods ---------------//
    // ---------------------------------------------------//
    
    private static Boolean isPopulated(String f, Project__c newProj, Project__c oldProj)
    {
        Boolean isFieldPopulated = false;
        isFieldPopulated = String.isNotBlank((String)newProj.get(f)) && ((String)newProj.get(f)) != ((String)oldProj.get(f));
        return isFieldPopulated;
    }
    
    private static Boolean isCleared(String f, Project__c newAcc, Project__c oldAcc)
	{
		return String.isBlank((String)newAcc.get(f)) && ((String)newAcc.get(f)) != ((String)oldAcc.get(f));					
    }
    
    //----------------------------------------------------------------------------//
    //----- Validate project reocrds for status update on project ---//
    //----------------------------------------------------------------------------//
    
    private void ValidateStatusChangeSMS(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
    {
        List<Id> validProjectId = new List<Id>();
        switch on Trigger.operationType {
            when AFTER_UPDATE {
                for(sObject sObjItem: newSObjs.values())
                {  
                    Project__c newProj = (Project__c)sObjItem;
                    Project__c oldProj = (Project__c)oldSObjs.get(newProj.Id);
                    if(isPopulated('CMProgressBar__c', newProj, oldProj)
                     && newProj.ContestabilityType__c != null && newProj.ContestabilityType__c != ''
                     && TVE_Project_Utility.isValidProgressStatusBarChange(newProj.CMProgressBar__c, oldProj.CMProgressBar__c, newProj.ContestabilityType__c))
                    {
                        validProjectId.add(newProj.Id);                         
                    }
                }
            }
        }

        // Added by JTan on 06/04/2020 for TV-2792
        if(!validProjectId.isEmpty()) {
            Map<Id, Project__c> validProjects = new Map<Id, Project__c>(
                [SELECT Id FROM Project__c WHERE Id IN :validProjectId AND ApplicantContact__r.CommunicationPreference__c = 'SMS']
            );
            validProjectId.clear();
            validProjectId.addAll(validProjects.keySet());
        
            List<Id> tempList;
            List<List<Id>> lstWrapper = new List<List<Id>>();
            Integer groupSize = 100;
            Integer size = (Integer)Math.ceil(
                (Double)validProjectId.size()/groupSize
            );
            Integer j=0;
            for(Integer i=0; i<size; i++){
                tempList = new List<Id>();
                for(j=i*groupSize; j<(i*groupSize)+groupSize && j<validProjectId.size(); j++){
                    tempList.add(validProjectId[j]);
                }
                lstWrapper.add(tempList);
            }
            for(List<Id> lstWrap : lstWrapper){
                TVE_Project_Utility.processStatusNotification(lstWrap);
            }
        }
    }    
   
    // ---------------------------------------------------//
    private static void Qualify_InsertProjectWorkCodeAndMore(List<SObject> newSObj)
    {
        System.debug('*** Trig_Project.InsertProjectWorkCode()');        
        List<Project__c> listValidProj = new List<Project__c>(); 
        Project__c newProj;
        System.debug('*** newSObj : ' + newSObj);        
        switch on Trigger.operationType
        {
            when BEFORE_INSERT
            {
                for(sObject sObjItem: newSObj)
                {					
                    newProj = (Project__c)sObjItem;
                    if(newProj.JobType__c != null)
                    {
                        listValidProj.add((Project__c)newProj);
                    }                    
                }
            }
        }
        if(!listValidProj.isEmpty()){
            TVE_Project_Utility.insertProjectWorkCodeAndMore(listValidProj);
        }
    }

    // ---------------------------------------------------//
    private static void Qualify_PopulateProjUrls(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        System.debug('*** Trig_Project.Qualify_PopulateProjUrls()');
        Map<Id, Project__c> mapValidProj = new Map<Id, Project__c>();        
        Project__c newRecord;
        Project__c oldRecord;
        Boolean doDML;
        
        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for(SObject newSObjItem: newSObj.values())
                {
                    newRecord=(Project__c)newSObjItem;
                    if(newRecord.ApplicantContact__c != null)
                    {
                        mapValidProj.put(newRecord.Id, (Project__c)newRecord);
                    }
                }
                doDML = true;
            }
            when BEFORE_UPDATE 
            {
                for(sObject newSObjItem: newSObj.values())
                {  
                    oldRecord=(Project__c)oldSObj.get(newSObjItem.id);
                    newRecord=(Project__c)newSObjItem;
                    System.debug('newRecord.ApplicantContact__c--->'+newRecord.ApplicantContact__c );
                    if(isPopulated('ApplicantContact__c', newRecord, oldRecord))
                    {
                        mapValidProj.put(newRecord.Id, (Project__c)newRecord);
                    }
                }
                doDML = false;
            }
        }
        
        System.debug('Qualify_PopulateProjUrls mapValidProj size---->'+mapValidProj.size());

        if(!mapValidProj.isEmpty())
        {
            if(doDML)
            {
                TVE_Project_Utility.PopulateProjUrls_AfterEvent(mapValidProj);    
            }
            else 
            {
                TVE_Project_Utility.PopulateProjUrls_BeforeEvent(mapValidProj);                        
            }            
        }        
    }

    private static void Qualify_RemoveProjectUrl(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        System.debug('*** Trig_Project.Qualify_RemoveProjectUrl()');
        Map<Id, Project__c> mapValidProj = new Map<Id, Project__c>();        
        Project__c newRecord;
        Project__c oldRecord;

        switch on Trigger.operationType
        {
            when BEFORE_UPDATE 
            {
                for(sObject newSObjItem: newSObj.values())
                {  
                    oldRecord=(Project__c)oldSObj.get(newSObjItem.id);
                    newRecord=(Project__c)newSObjItem;
                    System.debug('newRecord.ApplicantContact__c--->'+newRecord.ApplicantContact__c );
                    if(isCleared('ApplicantContact__c', newRecord, oldRecord))
                    {
                        mapValidProj.put(newRecord.Id, (Project__c)newRecord);
                    }
                }
            }
        }
        
        System.debug('Qualify_RemoveProjectUrl mapValidProj size---->'+mapValidProj.size());

        if(!mapValidProj.isEmpty())
        {
            TVE_Project_Utility.RemoveProjectUrl(mapValidProj);
        }
    }

    //--------Method to creat Integration Task object record--------//
    private static void Qualify_CreateIntegTask(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        List<Project__c> createIntRecList = new List<Project__c>();
         Project__c sObjItem;
        Project__c oldRecord;
        switch on Trigger.operationType {
            when AFTER_UPDATE {
                for(sObject sObjItems: newSObj.values())
                {  
                    oldRecord=(Project__c)oldSObj.get(sObjItems.id);
                    sObjItem=(Project__c)sObjItems;
                    System.debug('sObjItem.Ready_for_SAP_Integration__c'+sObjItem.Ready_for_SAP_Integration__c);
                    if(sObjItem.SAP_Integration_Status__c=='Ready to Create'
                       && sObjItem.SAP_Integration_Status__c!=oldRecord.SAP_Integration_Status__c)
                    {
                        createIntRecList.add((Project__c)sObjItem);
                    }
                }
            }
        }
        
        switch on Trigger.operationType {
            when AFTER_INSERT {
                for(sObject sObjItems: newSObj.values())
                {  
                    sObjItem=(Project__c)sObjItems;
                    if(sObjItem.SAP_Integration_Status__c=='Ready to Create')
                    {
                        createIntRecList.add((Project__c)sObjItem);
                    }
                }
            }
        }
        if(createIntRecList.size()>0)
            TVE_Project_Utility.CreateIntegTask(createIntRecList);  
    }
    
	//TVE-1201
    private static void Qualify_UpdateIntegTasks(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        Boolean hasPermission = FeatureManagement.checkPermission('Update_SAP_Status');
        List<id> ProjectIdlist = new List<id>();
        Project__c proj;
        Project__c projold;
        for(id key : newSObj.keySet()){
            proj = (Project__c)newSObj.get(key);
            projold = (Project__c)oldSObj.get(key);
            //Updated by JTan on 21/04/2020 for TV-2898
            if(
                !proj.Updated_By_Integration__c
                &&
                (
                    proj.ProjectName__c!=projold.ProjectName__c
                    ||
                    proj.ProjectAssignee__c!=projold.ProjectAssignee__c
                    ||
                    proj.ContestabilityType__c!=projold.ContestabilityType__c
                    ||
                    proj.SAPStatus__c!=projold.SAPStatus__c
                )
            ) {
                if(proj.SAPStatus__c!=projold.SAPStatus__c && !TVE_Constants.ALLOWED_STATUS.contains(proj.SAPStatus__c) && !hasPermission) {
                    proj.addError('You cannot update SAP Status to ' + proj.SAPStatus__c + ' in Salesforce');
                } else {
                    ProjectIdlist.add(proj.id);
                }
            }
            if(proj.Updated_By_Integration__c) {
                proj.Updated_By_Integration__c = false;
            }
        }
        if(ProjectIdlist.size()>0)
            TVE_SAP_updateCM.checkProject(ProjectIdlist,newSObj);
    }

    //Method for Account and Contact creation
    public static void Qualify_SiteOwnerAuthRepCreation(List<SObject> newSObj)
    {
        System.debug('**********');        
        List<Project__c> listValidProj = new List<Project__c>();
        Project__c newProj;
        System.debug('*** newSObj : ' + newSObj);        
        switch on Trigger.operationType
        {
            when BEFORE_INSERT
            {
                for(sObject sObjItem: newSObj)
                {					
                    newProj = (Project__c)sObjItem;
                    if(String.isNotBlank(newProj.OwnerEmail__c) || String.isNotBlank(newProj.AgentEmail__c)){
                        listValidProj.add(newProj);
                    }
                }                    
            }
        }
        if(!listValidProj.isEmpty()){
            TVE_Project_Utility.SiteOwnerAuthRepCreation(listValidProj);
            //TVE_Project_Utility.PrePopulateProject(listValidProj);
        }
	}
    
    public static void Qualify_PrePopulateProject(List<Project__c> newSObj)
    {
        System.debug('*** Trig_Project.PrePopulateProject()');
        switch on Trigger.operationType
        {
            when BEFORE_INSERT
            {
                TVE_Project_Utility.PrePopulateProject(newSObj);
            }
        }
    }

    public static void Qualify_UpdateProj_AccContLookups(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        System.debug('*** Trig_Project.UpdateProj_AccContLookups()');
        //map<Id,Project__c> validProjIds = new map<Id,Project__c>();
        List<Project__c> validProjIds = new List<Project__c>();
        Project__c newProj;
        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for(sObject sObjItem: newSObj.values())
                {
                    newProj = (Project__c)sObjItem;
                        validProjIds.add(newProj); 
                }
            }
        }
        if(!validProjIds.isEmpty()){
            TVE_Project_Utility.UpdateProj_AccContLookups(validProjIds);
        }
    }
    public static void Qualify_ArtefactCreation(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        System.debug('*** Trig_Project.Qualify_ArtefactCreation()');
        map<Id,Project__c> validProjIds = new map<Id,Project__c>();
        List<Project__c> listValidProj = new List<Project__c>();
        Project__c newProj;
        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for(sObject sObjItem: newSObj.values())
                {
                    newProj = (Project__c)sObjItem;
                    if(newProj.ApplicationPaymentMethod_fx__c != 'NOPAYMENT')
                    {
                        listValidProj.add(newProj);  
                    }                        
                }
            }
        }
        system.debug('listValidProjQualify_ArtefactCreation'+listValidProj);
        if(!listValidProj.isEmpty()){
            TVE_Project_Utility.ArtefactCreation(listValidProj);
        }
    }

    public static void Qualify_WorkOrderCreation(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        System.debug('*** Trig_Project.WorkOrderCreation()');
        //map<Id,Project__c> validProjIds = new map<Id,Project__c>();
        List<Project__c> validProjIds = new List<Project__c>();
        Project__c newProj;
        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for(sObject sObjItem: newSObj.values())
                {
                    newProj = (Project__c)sObjItem;
                    
                        validProjIds.add(newProj);                                                            
                                      
                }
            }
        }
        if(!validProjIds.isEmpty()){
            TVE_Project_Utility.WorkOrderCreation(validProjIds);
        }
    }

    public static void Qualify_OpportunityCreation(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        System.debug('*** Trig_Project.OpportunityCreation()');
        //map<Id,Project__c> validProjIds = new map<Id,Project__c>();
        List<Id> validProjIds = new List<Id>();
        Project__c newProj;
        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for(sObject sObjItem: newSObj.values())
                {
                    newProj = (Project__c)sObjItem;
                    
                        validProjIds.add(newProj.Id);                                                            
                                       
                }
            }
        }
        if(!validProjIds.isEmpty()){
            TVE_Project_Utility.OpportunityCreation(validProjIds);
        }
    }
    
    public static void Qualify_CreateAzureUser(Map<Id, SObject> newSObj,Map<Id, SObject> oldSObj)
    {
     	//List<Project__c> validProjIds = new List<Project__c>();
     	List<Id> conIdList = new List<id>();   
        map<Id,Project__c> validProjIds = new map<Id,Project__c>();
        switch on Trigger.operationType
        { 
            when AFTER_UPDATE
            {
                for(sObject sObjItem: newSObj.values()){
                    Project__c newProj;
                    Project__c oldProj;
                	newProj = (Project__c)sObjItem;
                    oldProj = (Project__c)oldSObj.get(sObjItem.id);                	                	
                    if((oldProj.WorkCode__c=='1013' && newProj.WorkCode__c!=oldProj.WorkCode__c) || 
                       			(oldProj.ApplicantContact__c==null && newProj.ApplicantContact__c!=null && newProj.WorkCode__c != '1013'))
                    {                        
                        validProjIds.put(newProj.Id, newProj);                                                                                   
                    
                        if(newProj.RelationshipToOwner__c!='Accredited Service Provider - AusNet Services'){
                            System.debug('Inside applicant contact statement'); 
                            conIdList.add(newProj.ApplicantContact__c);
                        }  
                    }           		 
                }                                   
            }           
        }

        if(validProjIds.size()>0)
            TVE_Project_Utility.PopulateProjUrls_AfterEvent(validProjIds);
        
        System.debug('conIdList in trigger'+conIdList);                 
        if(conIdList.size()>0){
            TVE_SF_Azure_Utility.azureInteg(conIdList);   
        }                
    }

    public static void Qualify_HandleSharing(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        Map<Id, Id> mapToDelete = new Map<Id, Id>();
        Map<Id, Id> mapToCreate = new Map<Id, Id>();

        switch on Trigger.operationType
        { 
            when AFTER_UPDATE
            {
                Set<Id> acctIds = new Set<Id>();
                for(sObject sObjItem: newSObj.values()){
                    Project__c newProj;
                    Project__c oldProj;
                	newProj = (Project__c)sObjItem;
                    oldProj = (Project__c)oldSObj.get(sObjItem.id);
                    if(oldProj.ApplicantAccount__c != newProj.ApplicantAccount__c)
                    {
                        if(oldProj.ApplicantAccount__c != null) {
                            acctIds.add(oldProj.ApplicantAccount__c);
                        }
                        if(newProj.ApplicantAccount__c != null) {
                            acctIds.add(newProj.ApplicantAccount__c);
                        }
                    }
                }
                Map<Id, Account> mapAccts = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :acctIds AND ASPAccreditaionId__c != null]);

                for(sObject sObjItem: newSObj.values()){
                    Project__c newProj;
                    Project__c oldProj;
                	newProj = (Project__c)sObjItem;
                    oldProj = (Project__c)oldSObj.get(sObjItem.id);
                    if(oldProj.ApplicantAccount__c != newProj.ApplicantAccount__c)
                    {
                        if(oldProj.ApplicantAccount__c != null && mapAccts.containsKey(oldProj.ApplicantAccount__c)) {
                            mapToDelete.put(oldProj.Id, oldProj.ApplicantAccount__c);
                        }
                        if(newProj.ApplicantAccount__c != null && mapAccts.containsKey(newProj.ApplicantAccount__c)) {
                            mapToCreate.put(newProj.Id, newProj.ApplicantAccount__c);
                        }
                    }
                }
            }
        }

        if(!mapToDelete.isEmpty()) {
            TVE_SharingUtility.deleteSharingByAccount(mapToDelete);
        }
        if(!mapToCreate.isEmpty()) {
            TVE_SharingUtility.createSharingByAccount(mapToCreate);
        }
    }
}