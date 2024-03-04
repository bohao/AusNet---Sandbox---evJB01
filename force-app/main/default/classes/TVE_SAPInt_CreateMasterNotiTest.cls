@isTest
public class TVE_SAPInt_CreateMasterNotiTest  {
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
        TVE_Integration_Constants__c intConstant= TVE_TestUtility.createIntegrationConstant();
        insert intConstant;
        List<Project__c> projObj = TVE_TestUtility.createMultipleIntegrationProject('test',PROGRESS_BAR_STATUS,CON_TYPE,testInstaller.id);
        Insert projObj;
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
        Artefact__c art=TVE_TestUtility.createOfferArtefact('test',projObjP[0].id,testInstaller.id);
        insert art;
        //ConstructionMeasureSets__x cmset = TVE_TestUtility.createConstMeasureSet();
        
        
    }  
    public static testMethod void callCreateWorkAPI(){
        
        ConstructionMeasureSets__x cmset = TVE_TestUtility.createConstMeasureSet();
        TVE_IntegUtility.mockedConstMeasure= cmset;
        TVE_SAPInteg_CreateMasterNoti createNoti = new TVE_SAPInteg_CreateMasterNoti();
        List<Opportunity> opp=[select id from opportunity ];
        artefact__c art=[select id from artefact__c where name='test' limit 1]; 
        List<id>oppIds=new list<id>();
        List<id>cvList=new list<id>();
        list<String>numbers=new List<string>{'123','456'};
        Set<string>numberSet=new Set<String>{'123','456'};    
        Map<Id,String> oppNotinumberMap = new Map<Id,String>();
        Map<String,String> arcDocMap = new Map<String,String>();
        for(Opportunity op:opp)
        { oppIds.add(op.id);
         oppNotinumberMap.put(op.id,'100108471');}
         TVE_TestUtility.insertFile(opp[0].id);
         List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument ];
         for(ContentDocument cd:documents)
             cvList.add(cd.LatestPublishedVersionId);
            arcDocMap.put(art.id,documents[0].id);
        // enqueue the job for processing
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        ID jobID = System.enqueueJob(createNoti);
        List<Database.SaveResult> res=TVE_IntegUtility.updateOpp(oppIds,oppNotinumberMap);
        TVE_IntegUtility.getContentDocument(cvList);
        TVE_IntegUtility.GetCMs(numbers);
        TVE_IntegUtility.updateArcID(arcDocMap);
        TVE_IntegUtility.GetWOs(numberSet);
        TVE_IntegUtility.GetPMNoti(numberSet);
        Test.stopTest();
        System.debug('TVE_SAPInteg_CreateWork - Job Id : ' + jobID);
        
    }
    
      
}