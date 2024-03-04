@isTest
public class TVE_SAPInteg_CreateWorkTest {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public static final string testUserEmail = 'testuser@TVEInvoicePreviewControllerTest.com';
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
    @TestSetup
    public static void setup() {
        //Create Business Account
        Account testInstaller = TVE_TestUtility.createBusinessAccount('Business Account');
        insert testInstaller;
        TVE_Integration_Constants__c intConstant= TVE_TestUtility.createIntegrationConstant();
        insert intConstant;
        Project__c projObj;
        List<Project__c> lstProj = new List<Project__c>();
        projObj = TVE_TestUtility.createIntegrationProject('test',PROGRESS_BAR_STATUS,CON_TYPE,testInstaller.id);
        lstProj.add(projObj);
        projObj = TVE_TestUtility.createIntegrationProject('test',PROGRESS_BAR_STATUS,CON_TYPE,testInstaller.id);
        projObj.ApplicationType__c = 'Public Lighting';
        projObj.IsPropertyOwner__c = 'Yes';
        lstProj.add(projObj);
        projObj = TVE_TestUtility.createIntegrationProject('test',PROGRESS_BAR_STATUS,CON_TYPE,testInstaller.id);
        projObj.ApplicationType__c = 'Public Lighting';
        projObj.SiteOwner__c = null;
        lstProj.add(projObj);
        projObj = TVE_TestUtility.createIntegrationProject('test',PROGRESS_BAR_STATUS,CON_TYPE,testInstaller.id);
        projObj.ApplicationType__c = 'Public Lighting';
        projObj.AuthorisedRepresentative__c = null;
        lstProj.add(projObj);        
        projObj = TVE_TestUtility.createIntegrationProject('test',PROGRESS_BAR_STATUS,CON_TYPE,testInstaller.id);
        projObj.PaymentReferenceNumber__c = null;        
        lstProj.add(projObj);
        Insert lstProj;
        
        Opportunity opp = TVE_TestUtility.createOpportunity(projObj.id,testInstaller.id);
        insert opp;
        
        Integration_Task__c intTask;
        List<Integration_Task__c> lstIntgTsk = new List<Integration_Task__c>();
        intTask =TVE_TestUtility.createIntegrationTask
            (lstProj[0].id,'Create','Project__c','In Progress','CreateWork');
        lstIntgTsk.add(intTask);
        intTask =TVE_TestUtility.createIntegrationTask
            (lstProj[1].id,'Create','Project__c','In Progress','CreateWork');
        lstIntgTsk.add(intTask);
        intTask =TVE_TestUtility.createIntegrationTask
            (lstProj[2].id,'Create','Project__c','In Progress','CreateWork');
        lstIntgTsk.add(intTask);
        intTask =TVE_TestUtility.createIntegrationTask
            (lstProj[3].id,'Create','Project__c','In Progress','CreateWork');
        lstIntgTsk.add(intTask);
        intTask =TVE_TestUtility.createIntegrationTask
            (lstProj[4].id,'Create','Project__c','In Progress','CreateWork');
        lstIntgTsk.add(intTask);
        insert lstIntgTsk;
        
        
    }  
    public static testMethod void callCreateNotiAPI(){
        
        TVE_SAPInteg_CreateWork createNoti = new TVE_SAPInteg_CreateWork();
        // enqueue the job for processing
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        ID jobID = System.enqueueJob(createNoti);   
        Test.stopTest();
        System.debug('TVE_SAPInteg_CreateWork - Job Id : ' + jobID);
    }
    
    public static testMethod void callCreateNotiAPI2(){
        TVE_SAPInteg_CreateWork createNoti = new TVE_SAPInteg_CreateWork();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        ID jobID = System.enqueueJob(createNoti);
        Test.stopTest();
        System.debug('TVE_SAPInteg_CreateWork - Job Id : ' + jobID);
    }
    
    public static testMethod void callCreateNotiAPIPRblank(){
        TVE_SAPInteg_CreateWork createNoti = new TVE_SAPInteg_CreateWork();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        ID jobID = System.enqueueJob(createNoti);  
        Test.stopTest();
        System.debug('TVE_SAPInteg_CreateWork - Job Id : ' + jobID);
        
    }
    
}