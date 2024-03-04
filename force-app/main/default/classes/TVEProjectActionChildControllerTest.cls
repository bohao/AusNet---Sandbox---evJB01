/*
@author  : arti.fogla@ausnetservices.com.au
@created : 20 feb 2019
@Description : Test class for TVEProjectActionChildControllerTest
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
@isTest
public class TVEProjectActionChildControllerTest {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Payment pending (Application submitted)';
    public static final string PROGRESS_BAR_STATUS_DESIGN = 'Payment pending (Application submitted)';
    public static final string testUserEmail = 'testuser@TVEArtefactControllerTest.com';
    public static final string TASK_RT = 'AcceptFirmOffer';
    public static final string TASKICC_RT = 'AcceptInterconnectionContractandOffer';
    
     public static testMethod void TestvalidateOpenTask()
    {
        Task tsk=[select id,status,OfferStatus__c from Task limit 1];
        test.startTest();
        TVEProjectActionChildController.validateOpenTask(tsk.id);
        Test.stopTest();
    }
    
    @isTest
    static void testFetchInvoiceMethod(){
        account acc= TVE_TestUtility.createBusinessAccount('test');
        insert acc;
        Project__c proj = [select id from Project__c limit 1];
        Artefact__c artRec = [select id from Artefact__c];
        TVE_TestUtility.insertFile(artRec.id);
        Task t =TVE_TestUtility.createTask(proj.id,userinfo.getUserId(),'test');
        t.Artefact__c=artRec.id;
        t.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =: TASKICC_RT].Id;
        insert t;
        test.startTest();
        TVEProjectActionChildController.validateOpenTask(t.id);
        TVEProjectActionChildController.fetchInvoice(t.id);
        TVEProjectActionChildController.fetchPaymentURL();
        test.stopTest();
    }
    @TestSetup
    public static void setup() {
        
        //Create User
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
        //Create Business Account
        Account testInstaller = TVE_TestUtility.createBusinessAccount('Business Account');
        database.insert(testInstaller,false) ;
        system.debug('testInstaller'+testInstaller);
        Contact con = new Contact();
        con.LastName = 'test1';
        Database.insert(con,false);
        system.debug('con'+con);
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        Database.Insert(projObj,false) ;
        Task taskRec = TVE_TestUtility.createTask(projObj.Id, testUser.Id, 'Test');
        taskRec.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =: TASK_RT].Id;
        Insert taskRec;
    } 
}