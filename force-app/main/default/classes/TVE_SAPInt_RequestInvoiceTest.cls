@isTest
public with sharing class TVE_SAPInt_RequestInvoiceTest {

    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public static final string CON_TYPE = 'IDIC';
    public static final string CLASSIFICATION_INVOICE = 'Invoice';
    public static ID invoiceRecordType = Schema.SObjectType.Artefact__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
    public static final string testUserEmail = 'testuser@TVEArtefactControllerTest.com';

    private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"status\":\"201\",\"statusMessage\":\"Created\",\"payload\":{\"d\":{\"NotificationNumber\":\"100108471\"}}}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private class RestMockFailure implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"status\":\"400\"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(401);
            res.setStatus('Unauthorized');
            return res;
        }
    }

    @TestSetup
    public static void setup() {
        
         //Create User
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;

        Account testInstaller = TVE_TestUtility.createBusinessAccount('Business Account');
        insert testInstaller;
        
        //Project__c projObj = TVE_TestUtility.createIntegrationProject('test',PROGRESS_BAR_STATUS,CON_TYPE,testInstaller.id);
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        projObj.SalesOrder__c = '123456';
        insert projObj;

        List<Artefact__c> artObjList = new list<Artefact__c>();

        artObjList.add(TVE_TestUtility.createInvoiceArtefact('test1',projObj.Id,testInstaller.id));
        artObjList.add(TVE_TestUtility.createInvoiceArtefact('test2',projObj.Id,testInstaller.id));
        artObjList[0].Source__c='Salesforce Cloud';
        artObjList[0].MaterialCodeLine1__c='CCAAA001';
        artObjList[0].AmountLine1ExGST__c=123456;
        artObjList[0].InvoiceTypeLine1__c='Site Assessment Fee';
        artObjList[0].MaterialCodeLine2__c='CCAAA001';
        artObjList[0].AmountLine2ExGST__c=123456;
        artObjList[0].InvoiceTypeLine2__c='Site Assessment Fee';
        artObjList[0].MaterialCodeLine3__c='CCAAA001';
        artObjList[0].AmountLine3ExGST__c=123456;
        artObjList[0].InvoiceTypeLine3__c='Site Assessment Fee';
        artObjList[0].Bill_To__c='123456';
        artObjList[0].Additional_Invoice__c= true;
        artObjList[1].Source__c='Salesforce Cloud';
        artObjList[1].MaterialCodeLine1__c='CCAAA001';
        artObjList[1].AmountLine1ExGST__c=123456;
        artObjList[1].InvoiceTypeLine1__c='Site Assessment Fee';
        artObjList[1].MaterialCodeLine2__c='CCAAA001';
        artObjList[1].AmountLine2ExGST__c=123456;
        artObjList[1].InvoiceTypeLine2__c='Site Assessment Fee';
        artObjList[1].MaterialCodeLine3__c='CCAAA001';
        artObjList[1].AmountLine3ExGST__c=123456;
        artObjList[1].InvoiceTypeLine3__c='Site Assessment Fee';
        artObjList[1].Bill_To__c='123456';
        artObjList[1].Additional_Invoice__c= true;
        insert artObjList;

        List<Integration_Task__c> IntgnTsklist = [SELECT Operation__c, SObject__c, ParentId__c, Type__c, Status__c FROM Integration_Task__c
                                                  WHERE ParentId__c =:artObjList[0].Id OR ParentId__c =:artObjList[1].Id];
        
        IntgnTsklist[0].Status__c = 'In Progress';
        IntgnTsklist[1].Status__c = 'In Progress';
        update IntgnTsklist;
    }
    public static testMethod void RequestInvoiceSApInteg(){
        
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){            
            TVE_SAPInteg_RequestInvoice reqInv = new TVE_SAPInteg_RequestInvoice();
            
            Test.setMock(HttpCalloutMock.class, new RestMock());    
            // enqueue the job for processing                
            TVE_SAPInteg_RequestInvoice.requestInvoiceInteg();
            //System.debug('TVE_SAPInteg_RequestInvoice - Job Id : ' + jobID);  
        }
        Test.stopTest();
    }
    public static testMethod void RequestInvoiceSApIntegFailure(){
     User testUser = UtilDatabase_Test.getTestUser();
        Test.startTest();
        System.runAs(testUser){  
            TVE_SAPInteg_RequestInvoice reqInv = new TVE_SAPInteg_RequestInvoice();
            Test.setMock(HttpCalloutMock.class, new RestMockFailure());
            // enqueue the job for processing        
			TVE_SAPInteg_RequestInvoice.requestInvoiceInteg();
            //ID jobID = System.enqueueJob(reqInv);              
            //System.debug('TVE_SAPInteg_RequestInvoice - Job Id : ' + jobID);
        }
        Test.stopTest();
        
    }
}