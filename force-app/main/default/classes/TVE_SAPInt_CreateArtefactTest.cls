@isTest
public class TVE_SAPInt_CreateArtefactTest  {
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
        Account personAccount = TVE_TestUtility.createPersonAccount('Person Account','Test@gmail.com');
        insert personAccount;
               
        List<Project__c> projObj = TVE_TestUtility.createMultipleIntegrationProject('test',PROGRESS_BAR_STATUS,CON_TYPE,testInstaller.id);
        Insert projObj;
        projObj[5].CMNumber__c='0076555';
        update projObj[5];
        List<Opportunity> opp = TVE_TestUtility.createMultipleOpportunity(projObj,testInstaller.id);
        insert opp;
        List<Integration_Task__c> intTask =TVE_TestUtility.createMultipleIntegrationTask
            (projObj,'Create','Project__c','In Progress','CreateMasterNoti');
        insert intTask;
        List<Project__c> projObjP = TVE_TestUtility.createMultipleIntegrationProject('test',PROGRESS_BAR_STATUS,CON_TYPE,personAccount.id);
        Insert projObjP;
        List<Opportunity> oppP = TVE_TestUtility.createMultipleOpportunity(projObjP,personAccount.id);
        insert oppP;
        List<Integration_Task__c> intTaskP =TVE_TestUtility.createMultipleIntegrationTask
            (projObjP,'Create','Project__c','In Progress','CreateMasterNoti');
        insert intTaskP;
        //ConstructionMeasureSets__x cmset = TVE_TestUtility.createConstMeasureSet();
		Artefact__c art = TVE_TestUtility.createArtefact('test artefact',projObj[5].id,testInstaller.id);
        insert art;
        System.debug('Aretefact in setup'+projObj[4].CMNumber__c);
        ContentVersion CV = TVE_TestUtility.createCV(art.id);
         insert CV;
        Id IntTaskRTId = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByDeveloperName().get('Artefact').getRecordTypeId();
        Integration_Task__c intTaskC =TVE_TestUtility.createIntegrationTask(art.id,'Create','Artefact__c','In Progress','CreateArtefact');
        intTaskC.RecordtypeID=IntTaskRTId;
        insert intTaskC;    
        TVE_File_ext_Mapping__c fileExt =new TVE_File_ext_Mapping__c();
        fileExt.name='pdf';
        fileExt.Type__c='application/pdf';
        insert fileExt;
      
        
    }  
    public static testMethod void callCreateWorkAPI(){
        
        TVE_CreateCMArtResponse CAW = new TVE_CreateCMArtResponse();
        CAW=(TVE_CreateCMArtResponse)JSON.deserialize('{\"status\":\"201\",\"statusMessage\":\"Created\",\"payload\":{\"d\":{\"NotificationNumber\":\"100108471\"}}}',TVE_CreateCMArtResponse.class);
        CAW.status='200';
        CAW.statusMessage='Created';
        CAW.payload.d.ArcDocId='005056AE1CCF1EEA97F4075DABCB16EE';
        CAW.payload.d.SapObject ='object';  
        CAW.payload.d.ObjectId ='1234';   
        CAW.payload.d.ArObject ='testobj';   
        CAW.payload.d.Filename ='testFile';    
        CAW.payload.d.FileContent ='Content';
        CAW.payload.d.FileDesc ='desc';   
        CAW.payload.d.MimeType ='EEEE';   
        CAW.payload.d.OriginalUrl ='URL';
        CAW.payload.d.Url='url';         
        CAW.payload.d.ThumbnailUrl='thumbnail';
        CAW.payload.d.FileSize ='20000';   
        CAW.payload.d.CreatedDate ='2020-02-12';
        CAW.payload.d.Creator ='test';    
        CAW.payload.d.ImageResize='1234'; 
        TVE_CreateCMArtResponse.parse('{\"status\":\"201\",\"statusMessage\":\"Created\",\"payload\":{\"d\":{\"NotificationNumber\":\"100108471\"}}}');
        TVE_SAP_Int_APICalls.CAW=CAW;
        TVE_SAPInt_CreateArtefact createNoti = new TVE_SAPInt_CreateArtefact();
        // enqueue the job for processing
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        ID jobID = System.enqueueJob(createNoti);  
        Test.stopTest();
        System.debug('TVE_SAPInteg_CreateWork - Job Id : ' + jobID);
        
    }
    
      
}