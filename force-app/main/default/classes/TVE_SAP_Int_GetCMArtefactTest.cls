@isTest
public with sharing class TVE_SAP_Int_GetCMArtefactTest { 
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
        
        Id IntTaskRTId = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByDeveloperName().get('Artefact').getRecordTypeId();
        Integration_Task__c intTask =TVE_TestUtility.createIntegrationTask(art.id,'Get','Artefact__c','In Progress','GetCMArtefact');
        intTask.RecordtypeID=IntTaskRTId;
        insert intTask;
        
    } 
    static testMethod void getArtefactCM1(){ 
        Artefact__c art=[select id,name from Artefact__c where name='test artefact'];
        art.InvoiceNumber__c='9002950';
        update art;
        AttachmentSets__x mockedArt = new AttachmentSets__x();
        mockedArt.ArcDocId__c='AUD';
        mockedArt.ArObject__c='20200116';
        mockedArt.Creator__c='9002950';
        mockedArt.FileContent__c='500.00';
        mockedArt.CreatedDate__c='20200129';
        mockedArt.SapObject__c='550.00';
        mockedArt.ObjectId__c='50.00';
        mockedArt.Filename__c ='test file';
        mockedArt.FileContent__c='sRsTpK2ExIiIiIiIiIqJrEhYj4vSVsBgRERERERER0TUJixFx+kpYjIiIiIiIiIjomoTFiDh9JSxGRERERERERHRNwmJEnL4SFiMiIiIiIiIiuiZhMSJOXwmLERERERERERFdk7AYEaevhMWIiIiIiIiIiK5JWIyI01fCYkRERERERERE1yQsRsTpK2ExIiIiIiIiIqJrEhYj4vSVsBgRERERERFxOvgsgK0RZ5+ExYg4fSUsRkRERERERJwOEha/IBIWI+L0lbAYERERERERcTpIWPyCSFiMiNNXwmJERERERETE6SBh8QsiYTEiTl8JixERERERERGng4TFL4gTCIuvXLuBEbRNFyJOXsJiRERERERExOlgdMPixBqtJzQlhhy1mFVqdAtQkxXSIaJHSjuNM+2UpoZ0npD+yt67R0LaZ76ExVHTNl2IOHkJixERERERERGng5qx2hqduemxV6sZdJduCunjN7VJDnY+TjZbAhFz5HB5VP3nTjRrjiBhsaiR6NXrN1LTbt3J+NZNM77N/Dbzrph5955VbZSjtv6uKVMhE0JYjDhFEhYjIiIiIiIiTgcDsW5UwmJdLKxJa/Ldbv+bcOt8/d1C2/2Z72jhckQJi8fphMPiW+m3M77NvHf/gQvef5D1IOuhKC/u3n9gpsOmGhkHe2YHevo7W4tMqTIVMiGExYhTJGExIiIiIiIi4nTQn+lGJSzWrSGCga+uMrYuH1b97WFDYUtKq/lvYLlxgIghckhYnFUqdR77Fy8bq5V1YCaWztal0MZQrWGxcaLDJc/TzQmHxZl37z3IevgoJ3dKzcnNM18/zH507/6DOxnfpt1Kv5GaduNm6vUbN8UbN9NS025peH3/QVb2o5zsR9I/T84NnD5cYeqUqZAJISxGnCIJixERERERERGng4GkNBphcWBzieEo1vY26OgLgf2LkTWx1Zg4uPrYvxI5NHQ2DRcWW/PlkQuZA6PSt4GkeEQu7G83w+JAS4TrzjgnHBZnfHv3/oOHgSh2S';
        TVE_IntegUtility.mockedArt=mockedArt;
        
        
        TVE_SAP_Int_GetCMArtefact getinv = new TVE_SAP_Int_GetCMArtefact();
            // enqueue the job for processing
            ID jobID = System.enqueueJob(getinv);  
    }

            

        }