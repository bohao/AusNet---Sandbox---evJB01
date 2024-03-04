/*
@author  : arti.fogla@ausnetservices.com.au
@created : 20 feb 2019
@Description : Test class for TVE_EmailHelper and TVE_EmailHelperInvoice
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
@isTest
public class TVE_EmailHelperTest {
    public static final string testUserEmail = 'testuser@TVEArtefactControllerTest.com';
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Payment pending (Application submitted)';
    public static final string PROGRESS_BAR_STATUS_DESIGN = 'Payment pending (Application submitted)';
    @isTest
    static void sendEmails_withTask(){
        setup();
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        Contact con = [select id from Contact limit 1];
        Project__c proj = [select id,ApplicantContact__c from Project__c  limit 1];
        Task t =[select id from task limit 1];
        emailTemplate template =[select id,developername from emailTemplate where Name ='Test' limit 1];        
        TVE_EmailHelper.EmailActionRequest request = new TVE_EmailHelper.EmailActionRequest();
        request.emailTemplateDevName=template.developername;
        request.toEmailsSemiColonSeperatedOptional='test@gmail.com';
        request.recordId=t.id;
        
        
        List<TVE_EmailHelper.EmailActionRequest> requests = new List<TVE_EmailHelper.EmailActionRequest>();
        requests.add(request);
        if(requests!=null)
        List<TVE_EmailHelper.EmailActionResult> results = TVE_EmailHelper.sendEmails(requests);
        Test.stoptest();
        
    }
    @isTest
    static void sendEmailswithInvoice(){
        
        setup();
        
        // arrange
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        Contact con = [select id from Contact limit 1];
        Project__c proj = [select id from Project__c limit 1];
        emailTemplate template =[select id,developername from emailTemplate where Name ='Test' limit 1];
        account acc= TVE_TestUtility.createBusinessAccount('test');
        insert acc;
        
        TVE_TestUtility.insertFile(acc.id);
        TVE_EmailHelperInvoice.EmailActionRequest request = new TVE_EmailHelperInvoice.EmailActionRequest();
        request.primaryRecipientContactRequired = con.id;
        request.recordId = acc.Id;
        request.emailTemplateDevName=template.developername;
        request.toEmailsSemiColonSeperatedOptional='test@gmail.com';
        Test.startTest();
        List<TVE_EmailHelperInvoice.EmailActionRequest> requests = new List<TVE_EmailHelperInvoice.EmailActionRequest>();
        requests.add(request);
        if(requests!=null)    
        List<TVE_EmailHelperInvoice.EmailActionResult> results = TVE_EmailHelperInvoice.sendEmailWithInvoice(requests);
        Test.stoptest();
    }
    
    @isTest static void test_setOrgWideEmailAddr()
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String emailAddrDisplayName = '';

        for (OrgWideEmailAddress owe: [SELECT Id, DisplayName FROM OrgWideEmailAddress LIMIT 1])
            emailAddrDisplayName = owe.DisplayName;

        System.assert(emailAddrDisplayName != null, 'Could not find OrgWideEmailAddress');
        TVE_EmailHelper.setOrgWideEmailAddr(mail, emailAddrDisplayName);  
    }
    
    @TestSetup
    public static void setup() {
        
        
        //Create User
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
        system.runAs(testUser){
            Emailtemplate et=new Emailtemplate(Name='Test',
                                           FolderId=UserInfo.getUserId(), 
                                           TemplateType='text',
                                           developername='test',
                                           isActive=true);
            insert et;
            
            //Create Business Account
            Account testInstaller = TVE_TestUtility.createBusinessAccount('Business Account');
            database.insert(testInstaller,false) ;
            system.debug('testInstaller'+testInstaller);
            Contact con = new Contact();
            con.LastName = 'test1';
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
            projObj.JobType__c='R-NEXT-M-106-00';
            projObj.ApplicationType__c='Residential';
            projObj.SignatureStatus__c='';
            projObj.SAPStatus__c='COMT';
            projObj.ProjectAssigmentStatus__c='Accepted';
            projObj.PreliminaryOfferAcceptanceDate__c=System.today();
            projObj.SAPStatusFlag__c='';
            
            Trig_Project.TrigDisabled=true;
            
            Database.Insert(projObj,false) ;
            system.debug('projObj'+projObj);
            Task t= TVE_TestUtility.createTask(projObj.id,testUser.Id,'test');
            insert t;
        }
    } 
}