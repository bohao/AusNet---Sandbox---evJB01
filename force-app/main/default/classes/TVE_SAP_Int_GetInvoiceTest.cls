@isTest
public class TVE_SAP_Int_GetInvoiceTest {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public static final string testUserEmail = 'testuser@TVEInvoicePreviewControllerTest.com';
  /*   private class RestMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"status\":\"201\",\"statusMessage\":\"Created\",\"payload\":{\"d\":{\"NotificationNumber\":\"100108471\"}}}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
     }*/
    @TestSetup
    public static void setup() {
        //Create User
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
        
        //Create Business Account
        Account testInstaller = TVE_TestUtility.createBusinessAccount('Business Account');
        insert testInstaller;
        
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        Insert projObj;
        
        Artefact__c art = TVE_TestUtility.createInvoiceArtefact('test artefact',projObj.id,testInstaller.id);
		insert art;
        
         Artefact__c artwithDoc = TVE_TestUtility.createInvoiceArtefact('test artefact2',projObj.id,testInstaller.id);
		insert artwithDoc;
        
        TVE_TestUtility.insertFile(artwithDoc.id);
        
        
        Id IntTaskRTId = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByDeveloperName().get('Artefact').getRecordTypeId();
        Integration_Task__c intTask =TVE_TestUtility.createIntegrationTask(art.id,'Get','Artefact__c','In Progress','GetInvoice');
        intTask.RecordtypeID=IntTaskRTId;
        insert intTask;
        Integration_Task__c intTask2 =TVE_TestUtility.createIntegrationTask(artwithDoc.id,'Get','Artefact__c','In Progress','GetInvoice');
        intTask2.RecordtypeID=IntTaskRTId;
        insert intTask2;
        
    } 
    static testMethod void getInvoice1(){ 
        Artefact__c art=[select id,name from Artefact__c where name='test artefact'];
        art.InvoiceNumber__c='9002950';
        update art;
        Artefact__c art2=[select id,name from Artefact__c where name='test artefact2'];
        art2.InvoiceNumber__c='9002950';
        update art2;
        InvoiceHeaderSets__x mockedInvHead = new InvoiceHeaderSets__x();
        mockedInvHead.CurrencyCode__c='AUD';
        mockedInvHead.DueDate__c='20200116';
        mockedInvHead.InvoiceNo__c='9002950';
        mockedInvHead.NetAmount__c='500.00';
        mockedInvHead.PaymentDate__c='20200129';
        mockedInvHead.TotalAmount__c='550.00';
        mockedInvHead.TotalGst__c='50.00';
        mockedInvHead.InvoicePdf__c='sRsTpK2ExIiIiIiIiIqJrEhYj4vSVsBgRERERERER0TUJixFx+kpYjIiIiIiIiIjomoTFiDh9JSxGRERERERERHRNwmJEnL4SFiMiIiIiIiIiuiZhMSJOXwmLERERERERERFdk7AYEaevhMWIiIiIiIiIiK5JWIyI01fCYkRERERERERE1yQsRsTpK2ExIiIiIiIiIqJrEhYj4vSVsBgRERERERFxOvgsgK0RZ5+ExYg4fSUsRkRERERERJwOEha/IBIWI+L0lbAYERERERERcTpIWPyCSFiMiNNXwmJERERERETE6SBh8QsiYTEiTl8JixERERERERGng4TFL4gTCIuvXLuBEbRNFyJOXsJiRERERERExOlgdMPixBqtJzQlhhy1mFVqdAtQkxXSIaJHSjuNM+2UpoZ0npD+yt67R0LaZ76ExVHTNl2IOHkJixERERERERGng5qx2hqduemxV6sZdJduCunjN7VJDnY+TjZbAhFz5HB5VP3nTjRrjiBhsaiR6NXrN1LTbt3J+NZNM77N/Dbzrph5955VbZSjtv6uKVMhE0JYjDhFEhYjIiIiIiIiTgcDsW5UwmJdLKxJa/Ldbv+bcOt8/d1C2/2Z72jhckQJi8fphMPiW+m3M77NvHf/gQvef5D1IOuhKC/u3n9gpsOmGhkHe2YHevo7W4tMqTIVMiGExYhTJGExIiIiIiIi4nTQn+lGJSzWrSGCga+uMrYuH1b97WFDYUtKq/lvYLlxgIghckhYnFUqdR77Fy8bq5V1YCaWztal0MZQrWGxcaLDJc/TzQmHxZl37z3IevgoJ3dKzcnNM18/zH507/6DOxnfpt1Kv5GaduNm6vUbN8UbN9NS025peH3/QVb2o5zsR9I/T84NnD5cYeqUqZAJISxGnCIJixERERERERGng4GkNBphcWBzieEo1vY26OgLgf2LkTWx1Zg4uPrYvxI5NHQ2DRcWW/PlkQuZA6PSt4GkeEQu7G83w+JAS4TrzjgnHBZnfHv3/oOHgSh2S';
        TVE_IntegUtility.mockedInvHead=mockedInvHead;
        
        TVE_SAP_Int_GetInvoice getinv = new TVE_SAP_Int_GetInvoice();
        	// enqueue the job for processing
        	ID jobID = System.enqueueJob(getinv);  
    }
    
     static testMethod void getInvoice2(){ 
        Artefact__c art=[select id,name from Artefact__c where name='test artefact'];
        art.InvoiceNumber__c='9002950';
        update art;
        Artefact__c art2=[select id,name from Artefact__c where name='test artefact2'];
        art2.InvoiceNumber__c='9002950';
        update art2;
        InvoiceHeaderSets__x mockedInvHead = new InvoiceHeaderSets__x();
        mockedInvHead.CurrencyCode__c='AUD';
        mockedInvHead.DueDate__c='20200116';
        mockedInvHead.InvoiceNo__c='9002950';
        mockedInvHead.NetAmount__c='500.00';
        mockedInvHead.PaymentDate__c='20200129';
        mockedInvHead.TotalAmount__c='550.00';
        mockedInvHead.TotalGst__c='50.00';
        mockedInvHead.InvoicePdf__c='sRsTpK2ExIiIiIiIiIqJrEhYj4vSVsBgRERERERER0TUJixFx+kpYjIiIiIiIiIjomoTFiDh9JSxGRERERERERHRNwmJEnL4SFiMiIiIiIiIiuiZhMSJOXwmLERERERERERFdk7AYEaevhMWIiIiIiIiIiK5JWIyI01fCYkRERERERERE1yQsRsTpK2ExIiIiIiIiIqJrEhYj4vSVsBgRERERERFxOvgsgK0RZ5+ExYg4fSUsRkRERERERJwOEha/IBIWI+L0lbAYERERERERcTpIWPyCSFiMiNNXwmJERERERETE6SBh8QsiYTEiTl8JixERERERERGng4TFL4gTCIuvXLuBEbRNFyJOXsJiRERERERExOlgdMPixBqtJzQlhhy1mFVqdAtQkxXSIaJHSjuNM+2UpoZ0npD+yt67R0LaZ76ExVHTNl2IOHkJixERERERERGng5qx2hqduemxV6sZdJduCunjN7VJDnY+TjZbAhFz5HB5VP3nTjRrjiBhsaiR6NXrN1LTbt3J+NZNM77N/Dbzrph5955VbZSjtv6uKVMhE0JYjDhFEhYjIiIiIiIiTgcDsW5UwmJdLKxJa/Ldbv+bcOt8/d1C2/2Z72jhckQJi8fphMPiW+m3M77NvHf/gQvef5D1IOuhKC/u3n9gpsOmGhkHe2YHevo7W4tMqTIVMiGExYhTJGExIiIiIiIi4nTQn+lGJSzWrSGCga+uMrYuH1b97WFDYUtKq/lvYLlxgIghckhYnFUqdR77Fy8bq5V1YCaWztal0MZQrWGxcaLDJc/TzQmHxZl37z3IevgoJ3dKzcnNM18/zH507/6DOxnfpt1Kv5GaduNm6vUbN8UbN9NS025peH3/QVb2o5zsR9I/T84NnD5cYeqUqZAJISxGnCIJixERERERERGng4GkNBphcWBzieEo1vY26OgLgf2LkTWx1Zg4uPrYvxI5NHQ2DRcWW/PlkQuZA6PSt4GkeEQu7G83w+JAS4TrzjgnHBZnfHv3/oOHgSh2S';
        TVE_IntegUtility.mockedInvHead=mockedInvHead;
        
        Database.SaveResult sr = (Database.SaveResult)JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);
        Database.SaveResult sr1 = (Database.SaveResult)JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);
        TVE_SAP_Int_GetInvoice.mockedResult.add(sr); 
        TVE_SAP_Int_GetInvoice.mockedResult.add(sr1);  
         
        TVE_SAP_Int_GetInvoice getinv = new TVE_SAP_Int_GetInvoice();
        // enqueue the job for processing
        Id jobID = System.enqueueJob(getinv);  
    }
}