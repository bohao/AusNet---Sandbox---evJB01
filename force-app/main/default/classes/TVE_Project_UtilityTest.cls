/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 30 Dec 2019
@Description : Test class for Project Trigger and respective trigger logics
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
28/05/19          Pavan Dave                 Renamed TVE_Trig_ProjectTest to TVE_Project_UtilityTest
-----------------------------------------------------------------------------------------
*/

@isTest
public class TVE_Project_UtilityTest {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Payment pending (Application submitted)';
    public static final string PROGRESS_BAR_STATUS_DESIGN = 'Payment pending (Application submitted)';
    public static final string testUserEmail = 'testuser@TVEArtefactControllerTest.com';
    
    public static testMethod void testDoPost(){
       

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser){
            test.startTest();
            eSignSettings__c eSign = [Select id, AES_Key__c from eSignSettings__c];
            Test.setMock(HttpCalloutMock.class, new RestMock());
            Account acc = [select id,PersonMobilePhone from Account where LastName='testLastName34Person'];
            Project__c projObj = [select id from Project__c limit 1];
            System.debug('projObj in test do Post' +projObj);
            projObj.AuthorisedRepresentative__c = acc.Id;
            projObj.CMProgressBar__c = PROGRESS_BAR_STATUS_DESIGN;
            update projObj;
            test.stopTest();
            
        }
    }
    public static testMethod void testAfterInsertAuthorisedPartner(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new RestMock());
        System.runAs(testUser){
            test.startTest();
            eSignSettings__c eSign = [Select id, AES_Key__c from eSignSettings__c];
            Account acc = [select id,PersonMobilePhone from Account where  LastName='testLastName34Partner'];
            system.debug('testtt123'+acc.PersonMobilePhone);
            Contact con = [select id from Contact limit 1];
            Project__c projObj = [select id from Project__c limit 1];
            projObj.PropertyOwnerContact__c = con.Id;
            projObj.CMProgressBar__c = PROGRESS_BAR_STATUS;
            projObj.AuthorisedRepresentative__c = acc.Id;
            projObj.IsPropertyOwner__c = 'No';
            projObj.RelationshipToOwner__c = 'Accredited Service Provider - AusNet Services';
            update projObj;
            projObj.CMProgressBar__c = PROGRESS_BAR_STATUS_DESIGN;
            update projObj;
            test.stopTest();
            
        }
    }
    public static testMethod void testAfterInsertAuthorised(){
       
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new RestMock());
        System.runAs(testUser){
            test.startTest();
            eSignSettings__c eSign = [Select id, AES_Key__c from eSignSettings__c];
            //Account acc = [select id,PersonMobilePhone from Account where LastName='test2'];
            //Contact con = [select id from Contact limit 1];
            Project__c projObj = [select id from Project__c limit 1];
            projObj.Name='testProj';
            projObj.CMProgressBar__c = PROGRESS_BAR_STATUS;
            //projObj.AuthorisedRepresentative__c = acc.Id;
            //projObj.PropertyOwnerContact__c = con.Id;
            projObj.RelationshipToOwner__c = 'Developer';
            projObj.IsPropertyOwner__c = 'No';
            update projObj;
            
            projObj.CMProgressBar__c = PROGRESS_BAR_STATUS_DESIGN;
            update projObj;
            test.stopTest();
            
        }
    }
   
    public static testMethod void InsertWorkCode()
    {
        
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
       
        Account acc = [select id from Account where Name='testLastName34Person'];
        System.runAs(testUser){
            
            eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
            eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
            insert eSignObj;
            
            
            test.startTest();
            Contact con = [select id from Contact limit 1];
            Project__c projObj = [select id from Project__c limit 1];
            projObj.JobType__c = 'R-NPTP-M-001-00';      
            projObj.SiteOwner__c = acc.Id;
            projObj.OwnerLastName__c = 'testLastName';
            projObj.OwnerCompany__c = 'testOwnerComp';
            projObj.PropertyOwnerContact__c = con.Id;
            projObj.IsPropertyOwner__c = 'Yes';
            update projObj;
            test.stopTest();            
        }
    }
    
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"status":"202","statusMessage":"Accepted","msgId":"76EE0F148D6D14CA9AA1CD418C00CB37"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
            
        }
    }
   
    //added by Neha
    public static testMethod void createIntegrationTask()
    {
        
        test.startTest();
        Project__c projObj = new Project__c();
        projObj.Name='testProj';
        projObj.JobType__c = 'R-NPTP-M-001-00';      
        projObj.SAP_Integration_Status__c='Ready to Create';
        insert projObj;
        test.stopTest();            
        
    }
    
    public static testMethod void createIntegrationTaskafterupdate()
    {
        
        test.startTest();
        Project__c projObj = new Project__c();
        projObj.Name='testProj';
        projObj.PaymentType__c='Firm';
        projObj.JobType__c = 'R-NPTP-A-001-00';      
        projObj.SAP_Integration_Status__c='Ready to Get';
        insert projObj; 
        projObj.SAP_Integration_Status__c='Ready to Create';
        update projObj;
        test.stopTest();            
        
    }
    
    public static testMethod void checkProfileFieldsChanged()
    {
       
        try
        {
            test.startTest();
            List<Project__c> projObj = [select id from Project__c];
            if(projObj.size()>0)
            {
                for(Project__c proj:projObj)
                    proj.ProjectName__c='updatecm test';
            }
            update projObj;
            test.stopTest();
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    
    /*
    public static testMethod void validPrgressBrChng(){
        
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new RestMock());
        System.runAs(testUser){
            Contact con=[select id,CommunicationPreference__c from contact where LastName = 'test1'];
            Account acc=[select id,PersonMobilePhone from account where LastName='Person Account'];
            Project__c projObj = [select id,ApplicantContact__r.CommunicationPreference__c,ApplicantAccount__r.PersonMobilePhone,CMProgressBar__c,ContestabilityType__c from Project__c WHERE Name = 'test2'];
            projObj.CMProgressBar__c = 'Allocated for detailed design';
            projObj.ContestabilityType__c = 'IDIC';
            projObj.ApplicantContact__c=con.id;
            projObj.ApplicantAccount__c=acc.id;
            projObj.ApplicantAccount__r.PersonMobilePhone='123456789';
            projObj.ApplicantContact__r.CommunicationPreference__c='SMS';
            test.startTest();
            update projObj;
            system.debug('after update proj id:'+projObj);
            system.debug('communication preference:'+projObj.ApplicantContact__r.CommunicationPreference__c);
            test.stopTest();
        }
    }
    */

    @IsTest
    static void validateAspApplicant_UpdateProject(){
        Test.startTest();
        Account acct = [SELECT Id, ASPAccreditaionId__c, OwnerId FROM Account WHERE IsPersonAccount = false LIMIT 1];
        Project__c proj = [SELECT Id, ApplicantAccount__c FROM Project__c WHERE ApplicantAccount__c = :acct.Id LIMIT 1];
        User testUser = [SELECT Id, UserRoleId FROM User WHERE email=: testUserEmail LIMIT 1];
        User partnerUsr = [SELECT Id, UserRoleId FROM User WHERE email=: 'asp@noemail.com' LIMIT 1];
        
        acct.OwnerId = testUser.Id;
        acct.ASPAccreditaionId__c = '13579';
        update acct;
        
        
        proj.ApplicantAccount__c = null;
        update proj;

        List<Project__Share> lstProjShare = [SELECT Id FROM Project__Share WHERE ParentId = :proj.Id];
        Integer shareSize = lstProjShare.size();

        proj.ApplicantAccount__c = acct.Id;
        update proj;
		
        lstProjShare = [SELECT Id FROM Project__Share WHERE ParentId = :proj.Id];
        Test.stopTest();
        
        System.assertEquals(++shareSize, lstProjShare.size());
    }

    @IsTest
    static void validateAspApplicant_UpdateUser(){
        Test.startTest();
        Account acct = [SELECT Id, ASPAccreditaionId__c, OwnerId FROM Account WHERE IsPersonAccount = false LIMIT 1];
        Project__c proj = [SELECT Id, ApplicantAccount__c FROM Project__c WHERE ApplicantAccount__c = :acct.Id LIMIT 1];
        User testUser = [SELECT Id, UserRoleId FROM User WHERE email=: testUserEmail LIMIT 1];
        User partnerUsr = [SELECT Id, UserRoleId FROM User WHERE email=: 'asp@noemail.com' LIMIT 1];
        acct.OwnerId = testUser.Id;
        acct.ASPAccreditaionId__c = '13579';
        update acct;

        List<Project__Share> lstProjShare = [SELECT Id FROM Project__Share WHERE ParentId = :proj.Id];
        Integer shareSize = lstProjShare.size();

        
        proj.ApplicantAccount__c = null;
        update proj;

        proj.ApplicantAccount__c = acct.Id;
        update proj;
		
        System.runAs(testUser) {
            partnerUsr.IsActive = false;
            update partnerUsr;
        }
        
        Test.stopTest();
        
        lstProjShare = [SELECT Id FROM Project__Share WHERE ParentId = :proj.Id];
        System.assertEquals(--shareSize, lstProjShare.size());
    }
    //Method by Salesforce Support
     public static void createPartnerUser()
    {
        Account acct = [SELECT Id, ASPAccreditaionId__c, OwnerId FROM Account WHERE IsPersonAccount = false LIMIT 1];
        Project__c proj = [SELECT Id, ApplicantAccount__c FROM Project__c WHERE ApplicantAccount__c = :acct.Id LIMIT 1];
        User testUser = [SELECT Id, UserRoleId FROM User WHERE email=: testUserEmail LIMIT 1];
        acct.OwnerId = testUser.Id;
        acct.ASPAccreditaionId__c = '13579';
        update acct;
        
        System.runAs(testUser){
            UserRole role = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert role;

            testUser.UserRoleId = role.Id;
            update testUser;
            
            User partnerUsr = new User(
                alias = 'asp',
                email = 'asp@noemail.com',
                emailencodingkey = 'UTF-8',
                lastname = 'applicant',
                languagelocalekey = 'en_US',
                localesidkey = 'en_US',
                profileid = [SELECT Id FROM Profile WHERE Name = 'TVE-11 Partner User' LIMIT 1].Id,
                country = 'United States',
                IsActive = true,
                ContactId = [SELECT Id FROM Contact WHERE AccountId = :acct.Id LIMIT 1].Id,
                timezonesidkey = 'America/Los_Angeles',
                username='asp@noemail.com'
            );
            insert partnerUsr; 
        }
        
    }    
    @TestSetup
    public static void setup() {
        
        //Create User
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
        eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
        eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
        insert eSignObj;
        //Create Business Account
        Account testInstaller = TVE_TestUtility.createBusinessAccount('Business Account');
        testInstaller.ABN__c = '123456789';
        testInstaller.LastName = 'testLastName98';
        database.insert(testInstaller,false) ;
        system.debug('testInstaller'+testInstaller);
        Account personAccount = TVE_TestUtility.createPersonAccount('Person Account',testUserEmail);
        personAccount.PersonMobilePhone='123456789';
        insert personAccount;
        Contact con = new Contact();
        con.LastName = 'test1';
        con.AD_User_ID__c='adsdss';
        con.CommunicationPreference__c='SMS';
        Database.insert(con,false);
        system.debug('con'+con);
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        projObj.OwnerLastName__c = 'testLastName';
        projObj.AgentLastName__c = 'testLastName98';
        projObj.OwnerABN__c = '123456789';
        projObj.OwnerCompany__c = 'testOwnerComp';
        projObj.OwnerMobile__c = '8932438932';
        projObj.IsPropertyOwner__c = 'Yes';
        projObj.OwnerCompany__c = '';
        projObj.OwnerEmail__c = 'abc@email.com';
        projObj.ApplicantContact__c=con.id;
        projObj.PaymentType__c='Prelim';
        projObj.WorkCode__c='1013';
        projObj.JobType__c='R-NPTP-A-001-00';
        Database.Insert(projObj,false) ;
        system.debug('projObj'+projObj);
        
        Project__c projObj12 = TVE_TestUtility.createProject('test12',PROGRESS_BAR_STATUS,CON_TYPE);
        projObj12.OwnerLastName__c = 'testLast12Name';
        projObj12.OwnerFirstName__c = 'testFirst12Name';
        projObj12.AgentLastName__c = 'testLastName98';
        projObj12.OwnerABN__c = '123456789';
        projObj12.OwnerCompany__c = 'qwerty';
        projObj12.OwnerMobile__c = '8932438932';
        projObj12.OwnerEmail__c = 'abc@email.com';
        projObj12.IsPropertyOwner__c = 'Yes';
        projObj12.ApplicantContact__c=con.id;
        projObj12.WorkCode__c='1014';
        Database.Insert(projObj12,false) ;
        
        Project__c projObj1 = TVE_TestUtility.createProject('test2',PROGRESS_BAR_STATUS,CON_TYPE);
        projObj1.OwnerLastName__c = 'testLastName2';
        projObj1.AgentLastName__c = 'testLastName982';
        projObj1.OwnerCompany__c = 'testOwnerComp2';
        projObj1.OwnerMobile__c = '8932438532';
        projObj1.OwnerABN__c = '123456781';
        projObj1.IsPropertyOwner__c = 'No';
        projObj1.Company__c = 'Test12';
        projObj.RelationshipToOwner__c = 'Developer';
        projObj1.AgentEmail__c = 'agent@email.com';
        projObj1.AgentCompany__c = null;
        projObj1.ContestabilityType__c = 'IDIC';
        projObj1.CMProgressBar__c= 'Issued for construction';
        projObj1.ApplicantContact__c=con.id;
        projObj1.ApplicantAccount__c=personAccount.id;
        projObj1.PaymentType__c='Firm';
        projObj1.WorkCode__c='1514';
        projObj1.JobType__c = 'E-PMPL-M-001-00';    
        Database.Insert(projObj1,false) ;
        
        Project__c projObj2 = TVE_TestUtility.createProject('test3',PROGRESS_BAR_STATUS,CON_TYPE);
        projObj2.OwnerLastName__c = 'testLastName2';
        projObj2.OwnerABN__c = '123456782';
        projObj2.OwnerCompany__c = 'testOwnerComp2';
        projObj2.AgentLastName__c = 'testLastName9823';
        projObj2.IsPropertyOwner__c = 'No';
        projObj2.OwnerMobile__c = '8932438942';
        projObj2.Company__c = 'Test12';
        projObj2.PaymentReferenceNumber__c = '123';
        projObj2.RelationshipToOwner__c = 'Developer';
        projObj2.AgentEmail__c = 'agent1@email.com';
        projObj2.AgentCompany__c = 'qwerty';
        projObj2.ApplicantContact__c=con.id;
        projObj2.WorkCode__c='1012';
        projObj2.JobType__c='E-NMDS-M-001-00';
        Database.Insert(projObj2,false) ;
        
        Account testPerson = TVE_TestUtility.createPersonAccount('Person Account','email@test.com');
        testPerson.PersonMobilePhone = '987654324';
        testPerson.LastName = 'testLastName34Person';
        Database.insert(testPerson,false) ;
        system.debug('testPerson'+testPerson);
        Account testPersonPartner = TVE_TestUtility.createPersonAccount('Person Account Partner','email@test.com');
        testPersonPartner.PersonMobilePhone = '987654321';
        testPersonPartner.LastName = 'testLastName34Partner';
        Database.insert(testPersonPartner,false);
        //insert testPersonPartner;
        Integration_Task__c intTask =TVE_TestUtility.createIntegrationTask
            (projObj.id,'Create','Project__c','Ready','GetCM');
        insert intTask;
        Project__c projObj3 = TVE_TestUtility.createProject('test10',PROGRESS_BAR_STATUS,CON_TYPE);
        projObj3.OwnerABN__c = '123456785';
        projObj3.AgentLastName__c = 'testLastName9822';
        projObj3.OwnerLastName__c = 'testLastName34';
        Insert projObj3;
        Integration_Task__c intTask2 =TVE_TestUtility.createIntegrationTask
            (projObj3.id,'Create','Project__c','Ready','UpdateCM');
        insert intTask2;
        
        createPartnerUser();
    } 
}