@isTest
public class TVE_SF_Azure_IntegrationTest {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public static final string testUserEmail = 'testuser@TVEInvoicePreviewControllerTest.com';
    public static final string PROGRESS_BAR_STATUS_DESIGN = 'Payment pending (Application submitted)';
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"id\":\"f70d2634-b112-4538-b35b-3af448119b64\",\"businessPhones\":[],\"displayName\":\"Test lname\",\"givenName\":null,\"jobTitle\":null,\"mail\":null,\"mobilePhone\":\"3433333334\",\"officeLocation\":null,\"preferredLanguage\":null,\"surname\":\"lname\",\"userPrincipalName\":\"negup115in@npausnetsalesforce.onmicrosoft.com\"}';
            String fullJson1 = '{\"token_type\":\"Bearer\",\"expires_in\":3599,\"ext_expires_in\":3599,\"access_token\":\"eyJ0eXAiOiJKV1QiLCJub25jZSI6ImdIbk1RUFljXzg0S1VtcEVDQ1I0Umh1b2hGV2w1OUFySWZTWDhOZC1QVDAiLCJhbGciOiJSUzI1NiIsIng1dCI6IllNRUxIVDBndmIwbXhvU0RvWWZvbWpxZmpZVSIsImtpZCI6IllNRUxIVDBndmIwbXhvU0RvWWZvbWpxZmpZVSJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83ZWE5OThmYi0yM2U3LTQxMGMtYWEzNC01Y2QwOWY3NzljMDEvIiwiaWF0IjoxNTg1MTQwMTg3LCJuYmYiOjE1ODUxNDAxODcsImV4cCI6MTU4NTE0NDA4NywiYWlvIjoiNDJkZ1lQZ1QwcmNxM3ZkSDNmNy92KzVYRzhndEF3QT0iLCJhcHBfZGlzcGxheW5hbWUiOiJTYWxlc2ZvcmNlLUNsaWVudC1BcHAiLCJhcHBpZCI6IjVhODA5Y2EzLTQzOTUtNDJjOS1iMmUzLWYyMzI3NzJiOTA3NyIsImFwcGlkYWNyIjoiMSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzdlYTk5OGZiLTIzZTctNDEwYy1hYTM0LTVjZDA5Zjc3OWMwMS8iLCJvaWQiOiIzZDVmZTc0ZC1lMTMzLTQwMTAtOGU5Mi1jYWIxODhlOGU3NjgiLCJyb2xlcyI6WyJVc2VyLlJlYWRXcml0ZS5BbGwiXSwic3ViIjoiM2Q1ZmU3NGQtZTEzMy00MDEwLThlOTItY2FiMTg4ZThlNzY4IiwidGlkIjoiN2VhOTk4ZmItMjNlNy00MTBjLWFhMzQtNWNkMDlmNzc5YzAxIiwidXRpIjoiWFFRcG5hMExjRXlva2JpNkczVjFBQSIsInZlciI6IjEuMCIsInhtc190Y2R0IjoxNTgzMTg4ODQ1fQ.aoT1oqSTRrOauePWxxFs_z2EhwhzdzXsFeaajuBhyVYdI7mbYfcnoSMnYi7PYhVZHKhr92bcfEbIaRjP61oCbJC9koc0QQNc2YlUb3R8xxv4HOH2GYPw2YWHS7W5Fye9dQzkKKEmsky5xQ2GoKokpNIjx8U7GcenS_gFvLXqglhmFdIof_onbRLbXnG2XpZ29TDkkFTYYWut709svV3Lql86739ZNzNkzMi6-7vPVCH6AVGz_MqHLcxBWiycMrVZ9q4DTbAsgQpTaui5Im3ym64d1ACu_C0QMQKTYjDykRi-nWru87wuTLfoUl1WGPacdYkc9gweY8_XM9fiqhvH_A\"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            if (req.getEndpoint().endsWith('users')) {
                res.setBody(fullJson);
                res.setStatusCode(201);
                return res;
            }
            else{
                res.setBody(fullJson1);
                res.setStatusCode(201);
                return res; 
            }
        }
    }
     
    
    public static testMethod void callAzureAPI(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
         Emailtemplate et=new Emailtemplate();
        	et.Name='Test';
            et.developername='Azure_Registration_Email';
            et.isActive=true;
        	et.Body='test';
        et.HtmlValue='test';
        TVE_SF_Azure_Utility.emailTemplate=et;
        List<Project__c>proj=new List<project__c>();
        test.startTest();
            Contact con = [select id,FirstName,email,name from Contact limit 1];
            Project__c projObj = [select id,Applicantcontact__c,WorkCode__c from Project__c limit 1];
            projObj.Applicantcontact__c=con.id;
            projObj.WorkCode__c='';
        update projObj;
        proj.add(projObj);
        TVE_SF_Azure_Utility.sendAzureEmail(con.Email,'password',con.FirstName);
        TVE_SF_Azure_Integration.createIntegrationLog('test',proj,con.id);
        system.debug('updated project:'+projObj);
        Test.stopTest();
    }
     @TestSetup
    public static void setup() {
        
        Contact con = new Contact();
        con.FirstName = 'testFname';
        con.LastName = 'test1';
        con.Email='test@test.com';
        con.MobilePhone = '0412345678';
        Database.insert(con,false);
        system.debug('con'+con);
        Project__c projObj = TVE_TestUtility.createProject('test4',PROGRESS_BAR_STATUS,CON_TYPE);
        projObj.WorkCode__c='1013';
        projObj.OwnerLastName__c = 'testLastName2';
        projObj.OwnerABN__c = '123456782';
        projObj.OwnerCompany__c = 'testOwnerComp2';
        projObj.AgentLastName__c = 'testLastName9823';
        projObj.IsPropertyOwner__c = 'No';
        projObj.OwnerMobile__c = '8932438942';
        projObj.Company__c = 'Test12';
        projObj.PaymentReferenceNumber__c = '123';
        projObj.RelationshipToOwner__c = 'Developer';
      
        Insert(projObj) ;
       
       
    }
   
}