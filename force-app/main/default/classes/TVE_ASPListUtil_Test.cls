/*
  @author  : brajesh.tiwary@ausnetservices.com.au
  @created : 29 Jan 2020
  @Description : Test class for TVE_ASPListUtil_Test class
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
@isTest
public class TVE_ASPListUtil_Test {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public static final string testUserEmail = 'testuser@TVEArtefactControllerTest.com';
    
    /*
    public static testMethod void testAspPdf(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new RestMock());
        System.runAs(testUser){
            Project__c projObj = [select id from Project__c];
            TVE_ASPListUtil.ASPWrapper wrapObj = new TVE_ASPListUtil.ASPWrapper();
            id contentId;
            test.startTest();
            contentId = TVE_ASPListUtil.callGetPDFIntBlob(projObj.id);
            test.stopTest();
            
        }
    }
    */

    /*
    
    public static testMethod void testASPList(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new RestMock());
        System.runAs(testUser){
            Project__c projObj = [select id from Project__c];
            list<string> workCodeList = new list<string>{'External Design'};
            TVE_ASPListUtil.ASPWrapper wrapObj = new TVE_ASPListUtil.ASPWrapper();
            wrapObj.status='Success';
            wrapObj.statusMessage='Success';
            wrapObj.initiating_msgId='1234';
            wrapObj.msgId='1234';
            list<TVE_ASPListUtil.ServiceProvider> listOfSP = new list<TVE_ASPListUtil.ServiceProvider>();
            TVE_ASPListUtil.ServiceProvider SP= new TVE_ASPListUtil.ServiceProvider();
            SP.CompanyName='company';
            SP.Address='testAddress';
            SP.AusNetServicesAccreditationIDNo='123';
            SP.Category='test';
            SP.ContactDetails='contact';
            SP.Phone='123456';
            SP.Email='test@test.com';  
            SP.VEDNAccreditationIDNo='123';
            SP.ExpiryDate='123';
            SP.Grade='A';
            test.startTest();
            listOfSP = TVE_ASPListUtil.callGetAspListInt(workCodeList,projObj.id);
            TVE_ASPListUtil.callGetAspListIntWCode('1013',projObj.id);
            test.stopTest();
            
        }
    }
    */ 
    
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"status": "OK","statusMessage": "Load ECM file completed successfully.","initiating_msgId": "123456","msgId": "123456","payload": {    "PDF": "your json response"  }}';            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    @TestSetup
    public static void setup() {
        //Create User
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
        Contact con = new Contact();
        con.LastName = 'test1';
        Database.insert(con,false);
        
        //Create Business Account
        Account testInstaller = TVE_TestUtility.createBusinessAccount('Business Account');
        insert testInstaller;
        
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        Insert projObj;
        Account testPerson = TVE_TestUtility.createPersonAccount('Person Account','email@test.com');
        insert testPerson;
        Account testPersonPartner = TVE_TestUtility.createPersonAccount('Person Account Partner','email@test.com');
        insert testPersonPartner;
        
    }
}