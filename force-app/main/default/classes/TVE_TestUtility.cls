/*
@author  : pavan.dave@ausnetservices.com.au
@created : 16 Dec 2019
@Description : Utility class for TVE test classes
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
public with sharing class TVE_TestUtility {
    public static final string CLASSIFICATION_INVOICE = 'Invoice';
    public static final string CLASSIFICATION_FIRM_OFFER_LETTER = 'Firm Offer Letter';
    public static String ACCOUNT_RECORDTYPE_INDIVIDUAL = 'Customer_Individual';
    public static String ACCOUNT_RECORDTYPE_BUSINESS  = 'Customer_Business';
    public static Project__c createProject(String referenceNum, String status, string ConType) {
        return new Project__c(
            Name = referenceNum,
            CMProgressBar__c = status,
            ContestabilityType__c = ConType,
            OwnerMobile__c = '8932438932',
            OwnerLastName__c = 'testLastName',
            OwnerCompany__c = 'testOwnerComp',
            AgentLastName__c = 'testLastName9822',
            IsPropertyOwner__c = 'Yes');
    }
    public static Account createPersonAccount(String acctName, String emailAddr) {
        Id acctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        return new Account(
            LastName = acctName,
            RecordTypeId = acctRTId,
            PersonEmail = emailAddr,
            Customer_Type__c = 'ELE - CINCL'
        );
    }
    public static Account createBusinessAccount(String acctName) {
        Id acctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_BUSINESS).getRecordTypeId();
        system.debug('acctRTId'+acctRTId);
        return new Account(
            Name = acctName,
            RecordTypeId = acctRTId,
            SAPCustomer__c='10263',
            Customer_Type__c = 'ELE - CINCL',
            BillingStreet='Test BillingStreet to see of split function work n it split the data into array of string. Length should be greater than 35'
        );
    }
    public static Artefact__c createOfferArtefact(String name, Id project, Id account) {
        Id offerRTId = Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get('Offer').getRecordTypeId();
        return new Artefact__c(
            Name = name,
            Project__c = project,
            Account__c = account,
            RecordTypeId=offerRTId,
            Classification__c = CLASSIFICATION_FIRM_OFFER_LETTER);
    }
    public static Emailtemplate createEmailtemplate()
    {
        return new Emailtemplate(Name='test',
                                 FolderId=userinfo.getuserid(), 
                                 TemplateType='text',
                                 developername='test',
                                 isActive=true);
        
    }
    
    public static contact createContact(){
        return new contact(FirstName = 'Dee',
                           LastName = 'Licious',
                           email = 'Arti.Fogla@ausnetservices.com.au',
                           AD_User_ID__c='sd33dd');
    }
    
    public static contact createContact(Id accId, String fName, String lName, String email){
        return new contact(AccountId = accId,
                           FirstName = fName,
                           LastName = lName,
                           Email = email);
    }

    public static Artefact__c createInvoiceArtefact(String name, Id project, Id account) {
        Id offerRTId = Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get('Invoice').getRecordTypeId();
        return new Artefact__c(
            Name = name,
            Project__c = project,
            Account__c = account,
            RecordTypeId=offerRTId,
            Classification__c = CLASSIFICATION_INVOICE);
    }
    
    public static Artefact__c createArtefact(String name, Id project, Id account) {
        Id offerRTId = Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get('Invoice').getRecordTypeId();
        return new Artefact__c(
            Name = name,
            Project__c = project,
            Account__c = account,
            RecordTypeId=offerRTId,
            Classification__c = 'Audit reports');
    }
    
    public static User createTestUser(String userEmail){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        System.assert(p != null, 'Profile not found.');
        
        return new User(
            ProfileId = p.Id,
            LastName = 'Doe',
            Email = userEmail,
            Username = userEmail + '.'+  System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            SAP_ID__c='TRAI',
            IsActive=true
        );
    }
    
    public static void insertFile(String parentId){
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = parentId;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;    
    }
    
    //added by Neha
    public static task createTask(String projID, String Userid,String sub) {
        return new Task(
            WhatID = projID,
            Subject=sub,
            Status='In Progress',
            Priority='Normal',
            OwnerID = Userid);
    }
    
    //added by Neha
    public static Opportunity createOpportunity(ID projId,ID accId){
        return new Opportunity(Name='Test opp',
                               Project__c=projId,
                               Type='Design',
                               StageName='Prospecting',
                               AccountId= accId,
                               CloseDate=System.today()
                              );
        
    }

    public static Opportunity createOpportunityType(ID projId,ID accId, String Type){	
        return new Opportunity(Name='Test opp',	
                              Project__c=projId,	
                              Type=Type,	
                              StageName='Prospecting',	
                              AccountId= accId,	
                              CloseDate=System.today()	
                              );	
        	
    }

    //added by Neha
    public static Integration_Task__c createIntegrationTask(ID parentID,String Operation,String sobj,String status,String type){
        return new Integration_Task__c(Operation__c=Operation,
                                       ParentId__c=parentID,
                                       SObject__c=sobj,
                                       Status__c=status,
                                       Type__c=type);
    }
    
      //added by Harshad	
      public static WorkOrder createWorkOrder(ID projId,String Type){	
        return new WorkOrder(Project__c=projId,Type__c = Type );	
        	
    }
    
    public static TVE_Integration_Constants__c createIntegrationConstant()
    {
        return new TVE_Integration_Constants__c(Assembly__c='40000481',
                                                Integration_Method_Name__c='TVE_SAPInteg_CreateMasterNoti',
                                                MessageID__c='000011111',
                                                Partner_Role_1__c='AG',
                                                Partner_Role_2__c='VW',
                                                Name='TVE_SAPInteg_CreateMasterNoti');
    }
    
    public static Project__c createIntegrationProject(String referenceNum, String status, string ConType ,id accid)
    {
        return new Project__c(Name = referenceNum,
                              CMProgressBar__c = status,
                              ContestabilityType__c = ConType,
                              PropertyAccessInstructions__c='Test Property Access Instruction',
                              HazardDetails__c='Test hazard detail',
                              FunctionalLocation__c='DL-BN009-2601730307',
                              //projObj.EstimatedCompletionDate__c='2020-02-12T12:34:56';
                              SiteOwner__c=accid,
                              ApplicationType__c='Residential',
                              PaymentReferenceNumber__c='test',
                              IsPropertyOwner__c='No',
                              AuthorisedRepresentative__c=accid);
    }
    
    public static List<Project__c> createMultipleIntegrationProject(String referenceNum, String status, string ConType ,id accid)
    {
        List<Project__c> projList = new List<Project__c>();
        Project__c proj1 = new Project__c();
        Project__c proj2 = new Project__c();
        Project__c proj3 = new Project__c();
        Project__c proj4 = new Project__c();
        Project__c proj5 = new Project__c();
        Project__c proj6 = new Project__c();
        
        proj1.Name = referenceNum;
        proj1.CMProgressBar__c = status;
        proj1.ContestabilityType__c = ConType;
        proj1.PropertyAccessInstructions__c='Test Property Access Instruction';
        proj1.HazardDetails__c='Test hazard detail';
        proj1.FunctionalLocation__c='DL-BN009-2601730307';
        proj1.SiteOwner__c=accid;
        proj1.ApplicationType__c='Residential';
        proj1.PaymentReferenceNumber__c='test';
        proj1.IsPropertyOwner__c='No';
        proj1.AuthorisedRepresentative__c=accid;
        proj1.CMNumber__c='100108663';
		projList.add(proj1);   
        
        proj2.Name = referenceNum;
        proj2.CMProgressBar__c = status;
        proj2.ContestabilityType__c = ConType;
        proj2.PropertyAccessInstructions__c='Test Property Access Instruction';
        proj2.HazardDetails__c='Test hazard detail';
        proj2.FunctionalLocation__c='DL-BN009-2601730307';
        //proj2.SiteOwner__c=accid;
        proj2.ApplicationType__c='New Estate';
        proj2.PaymentReferenceNumber__c='test';
        proj2.IsPropertyOwner__c='No';
        proj2.AuthorisedRepresentative__c=accid;
        projList.add(proj2);
        
        proj3.Name = referenceNum;
        proj3.CMProgressBar__c = status;
        proj3.ContestabilityType__c = ConType;
        proj3.PropertyAccessInstructions__c='Test Property Access Instruction';
        proj3.HazardDetails__c='Test hazard detail';
        proj3.FunctionalLocation__c='DL-BN009-2601730307';
        proj3.SiteOwner__c=accid;
        proj3.ApplicationType__c='Residential';
        proj3.PaymentReferenceNumber__c='test';
        proj3.IsPropertyOwner__c='Yes';
        proj3.AuthorisedRepresentative__c=accid;
		projList.add(proj3);   
        
        proj4.Name = referenceNum;
        proj4.CMProgressBar__c = status;
        proj4.ContestabilityType__c = ConType;
        proj4.PropertyAccessInstructions__c='Test Property Access Instruction';
        proj4.HazardDetails__c='Test hazard detail';
        proj4.FunctionalLocation__c='DL-BN009-2601730307';
        proj4.SiteOwner__c=accid;
        proj4.ApplicationType__c='Residential';
        proj4.PaymentReferenceNumber__c='';
        proj4.IsPropertyOwner__c='Yes';
        proj4.AuthorisedRepresentative__c=accid;
		projList.add(proj4); 
        
        proj5.Name = referenceNum;
        proj5.CMProgressBar__c = status;
        proj5.ContestabilityType__c = ConType;
        proj5.PropertyAccessInstructions__c='Test Property Access Instruction';
        proj5.HazardDetails__c='Test hazard detail';
        proj5.FunctionalLocation__c='DL-BN009-2601730307';
        proj5.SiteOwner__c=accid;
        proj5.ApplicationType__c='Residential';
        proj5.PaymentReferenceNumber__c='';
        proj5.IsPropertyOwner__c='Yes';
        proj5.AuthorisedRepresentative__c=accid;
        proj5.Ready_for_SAP_Integration__c=true;
        proj5.CMNumber__c='75002168';
        projList.add(proj5); 
        
        proj6.Name = referenceNum;
        proj6.CMProgressBar__c = status;
        proj6.ContestabilityType__c = ConType;
        proj6.PropertyAccessInstructions__c='Test Property Access Instruction';
        proj6.HazardDetails__c='Test hazard detail';
        proj6.FunctionalLocation__c='DL-BN009-2601730307';
        proj6.SiteOwner__c=accid;
        proj6.ApplicationType__c='Residential';
        proj6.PaymentReferenceNumber__c='';
        proj6.IsPropertyOwner__c='Yes';
        proj6.AuthorisedRepresentative__c=accid;
        proj6.Ready_for_SAP_Integration__c=true;
        //proj5.CMNumber__c='75002168';
        projList.add(proj6); 
        
        
        
        return projList;
    }
    
    public static List<Opportunity> createMultipleOpportunity(List<Project__c> projList,ID accId){
        List<Opportunity> oppList = new List<Opportunity>();
       
        for(Project__c proj:projList){
             Opportunity opp = new Opportunity();
             opp.Name='Test opp';
             opp.Project__c=proj.Id;
             opp.Type='Design';
             opp.StageName='Prospecting';
             opp.AccountId= accId;
             opp.CloseDate=System.today();
            OppList.add(opp);
        }
       return oppList;
    }
    
    public static List<Integration_Task__c> createMultipleIntegrationTask(List<Project__c> projList,String Operation,String sobj,String status,String type){
        List<Integration_Task__c> intTaskList = new List<Integration_Task__c>();
       
        for(Project__c proj:projList)
        {
            Integration_Task__c intTask = new Integration_Task__c();
        	intTask.Operation__c=Operation;
            intTask.ParentId__c=proj.id;
            intTask.SObject__c=sobj;
            intTask.Status__c=status;
            intTask.Type__c=type;
			intTaskList.add(intTask);            
        }
       return intTaskList;
        
    }
    
     public static ConstructionMeasureSets__x  createConstMeasureSet(){
         return new ConstructionMeasureSets__x(Qmnum__c='100108664',
                                              Cmnum__c='100108663');
     }
    
    public static ContentVersion createCV(String artId){
        return new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true,
            	FirstPublishLocationId=artId
            );
    }
       
    
}