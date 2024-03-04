@isTest
public class TVE_SAPInteg_UpdateCMQueTest {
public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public static final string testUserEmail = 'testuser@TVEInvoicePreviewControllerTest.com';
     private class RestMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"status\":\"204\",\"statusMessage\":\"No Content\",\"payload\":{\"responsePayload\":\"\"}}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
     }
    @testSetup
    public static void setup() {
         Account testInstaller = TVE_TestUtility.createBusinessAccount('Business Account');
        insert testInstaller;
        
        Project__c projObj = TVE_TestUtility.createIntegrationProject('test',PROGRESS_BAR_STATUS,CON_TYPE,testInstaller.id);
        Insert projObj;
        
        Integration_Task__c intTask =TVE_TestUtility.createIntegrationTask
                                    (projObj.id,'Update','Project__c','In Progress','UpdateCM');
        insert intTask;
        
   }  

    public static testMethod void callUpdateCM(){
            TVE_SAPInteg_UpdateCMQue updateCM = new TVE_SAPInteg_UpdateCMQue();
            // enqueue the job for processing
            String fullJson = '{\"status\":\"204\",\"statusMessage\":\"No Content\",\"payload\":{\"responsePayload\":\"\"}}';
  
            Test.startTest();
        	TVE_SAP_Int_APICalls.UpdateCMResponse UPR = new TVE_SAP_Int_APICalls.UpdateCMResponse();
        	UPR.status='204';
        	UPR.statusMessage='No Content';
       		TVE_SAP_Int_APICalls.ucmp=UPR;
            //Test.setMock(HttpCalloutMock.class, new RestMock());
            ID jobID = System.enqueueJob(updateCM); 
            Test.stopTest();
         
    }
  

}