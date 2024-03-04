/*
@author  : lakshay.sharma@ausnetservices.com.au
@created : 06 Mar 2020
@Description : Test Class for TVE_SAPInteg_Initiation
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/
@isTest
public class TVE_SAPInteg_InitiationTest {
    public static final string testUserEmail = 'testuser@TVEIntegInitiationControllerTest.com';
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public static ID invoiceRecordType = Schema.SObjectType.Artefact__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
    public static ID intTask_arte_Id = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByName().get('Artefact').getRecordTypeId();
    public static ID intTask_opp_Id = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId();
    public static ID intTask_workord_Id = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByName().get('WorkOrder').getRecordTypeId();
    
    //public static final string myAssigneeId='';
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
    @testSetup
    public static void setup() {
    
        
        Account testAcc = TVE_TestUtility.createBusinessAccount('Business Account');
        
        List<Project__c> lstProj = new List<Project__c>();
		lstProj.add(TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE));
		lstProj[0].CMNumber__c = '12345';	
        lstProj[0].SalesOrder__c='123345';
        lstProj[0].sap_integration_status__c='Ready to Create';
        lstProj.add(TVE_TestUtility.createProject('test1',PROGRESS_BAR_STATUS,CON_TYPE));
        Insert lstProj;
        
        
        
        List<Artefact__c> lstArt=new List<Artefact__c>();
        lstArt.add(TVE_TestUtility.createArtefact('test',lstProj[0].Id,testAcc.Id));
        
        Insert lstArt;
        
        List<Artefact__c> atrlistproj= new List<Artefact__c>();
        atrlistproj=[SELECT Id,Project__c,RecordTypeId FROM Artefact__c WHERE Project__c=:lstProj[0].Id and RecordTypeId=:invoiceRecordType];
        for(Artefact__c item:atrlistproj){
            item.MaterialCodeLine1__c='CCAAA001';
        	item.InvoiceTypeLine1__c='Other';
            item.Bill_To__c='Test';
            item.AmountLine1ExGST__c=19.23;
            item.MaterialCodeLine2__c='CCAAA001';
            item.InvoiceTypeLine2__c='Other';
            item.AmountLine2ExGST__c=20.25;
            item.MaterialCodeLine3__c='CCAAA001';
            item.InvoiceTypeLine3__c='Other';
            item.AmountLine3ExGST__c=30.25;
        	system.debug('artforproj'+item);
            
            
        }
        update atrlistproj;
        
        
        
        Map<Id,String> recordMapReady = new Map<Id,String>(); 
        recordMapReady.put(lstProj[1].Id, 'ParentId');
        Map<String,String> creatIntTaskMapReady = new Map<String,String>();
        creatIntTaskMapReady.put('Operation__c', 'Get');
        creatIntTaskMapReady.put('SObject__c', 'Project__c');       
        creatIntTaskMapReady.put('Type__c', 'CreateCustomer');
        creatIntTaskMapReady.put('Status__c', 'Ready');  
        
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady);
        
        Map<String,String> creatIntTaskMapReady1 = new Map<String,String>();
        creatIntTaskMapReady1.put('Operation__c', 'Get');
        creatIntTaskMapReady1.put('SObject__c', 'Project__c');       
        creatIntTaskMapReady1.put('Type__c', 'CreateCustomer');
        creatIntTaskMapReady1.put('Status__c', 'Ready');  
       
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady1);
        
        
        
        Map<String,String> creatIntTaskMapReady3 = new Map<String,String>();
        creatIntTaskMapReady3.put('Operation__c', 'Get');
        creatIntTaskMapReady3.put('SObject__c', 'Artefact__c');       
        creatIntTaskMapReady3.put('Type__c', 'GetInvoice');
        creatIntTaskMapReady3.put('RecordTypeID',intTask_arte_Id);
        creatIntTaskMapReady3.put('Status__c', 'Ready');
        
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady3);
        
        Map<String,String> creatIntTaskMapReady4 = new Map<String,String>();
        creatIntTaskMapReady4.put('Operation__c', 'Get');
        creatIntTaskMapReady4.put('SObject__c', 'Project__c');       
        creatIntTaskMapReady4.put('Type__c', 'CreateCustomer');
        creatIntTaskMapReady4.put('Status__c', 'Ready'); 
        
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady4);
        
        Map<String,String> creatIntTaskMapReady5 = new Map<String,String>();
        creatIntTaskMapReady5.put('Operation__c', 'Get');
        creatIntTaskMapReady5.put('SObject__c', 'Project__c');       
        creatIntTaskMapReady5.put('Type__c', 'UpdateCM');
        creatIntTaskMapReady5.put('Status__c', 'Ready');
        
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady5);
        
        Map<String,String> creatIntTaskMapReady6 = new Map<String,String>();
        creatIntTaskMapReady6.put('Operation__c', 'Get');
        creatIntTaskMapReady6.put('SObject__c', 'Project__c');       
        creatIntTaskMapReady6.put('Type__c', 'CreateMasterNoti');
        creatIntTaskMapReady6.put('Status__c', 'Ready'); 
        
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady6);
        
        Map<String,String> creatIntTaskMapReady7 = new Map<String,String>();
        creatIntTaskMapReady7.put('Operation__c', 'Create');
        creatIntTaskMapReady7.put('SObject__c', 'Project__c');       
        creatIntTaskMapReady7.put('Type__c', 'CreateWork');
        creatIntTaskMapReady7.put('Status__c', 'Ready');  
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady7);
        
        Map<String,String> creatIntTaskMapReady8 = new Map<String,String>();
        creatIntTaskMapReady8.put('Operation__c', 'Get');
        creatIntTaskMapReady8.put('SObject__c', 'Artefact__c');       
        creatIntTaskMapReady8.put('Type__c', 'GetCMArtefact');
        creatIntTaskMapReady8.put('Status__c', 'Ready');
        creatIntTaskMapReady8.put('RecordTypeID',intTask_arte_Id);
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady8);
        
       
        
        Map<String,String> creatIntTaskMapReady12 = new Map<String,String>();
        creatIntTaskMapReady12.put('Operation__c', 'Get');
        creatIntTaskMapReady12.put('SObject__c', 'Project__c');       
        creatIntTaskMapReady12.put('Type__c', 'GetCustomer');
        creatIntTaskMapReady12.put('Status__c', 'Ready');  
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady12);
        
        Map<String,String> creatIntTaskMapReady13 = new Map<String,String>();
        creatIntTaskMapReady13.put('Operation__c', 'Get');
        creatIntTaskMapReady13.put('SObject__c', 'Opportunity');       
        creatIntTaskMapReady13.put('Type__c', 'GetConstNoti');
        creatIntTaskMapReady13.put('Status__c', 'Ready');
        creatIntTaskMapReady13.put('RecordTypeID',intTask_opp_Id);
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady13);
        
        
        Map<String,String> creatIntTaskMapReady14 = new Map<String,String>();
        creatIntTaskMapReady14.put('Operation__c', 'Get');
        creatIntTaskMapReady14.put('SObject__c', 'WorkOrder');       
        creatIntTaskMapReady14.put('Type__c', 'GetConstWO');
        creatIntTaskMapReady14.put('Status__c', 'Ready');
        creatIntTaskMapReady14.put('RecordTypeID',intTask_workord_Id);
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady14);
        
        Map<String,String> creatIntTaskMapReady15 = new Map<String,String>();
        creatIntTaskMapReady15.put('Operation__c', 'Get');
        creatIntTaskMapReady15.put('SObject__c', 'Project__c');       
        creatIntTaskMapReady15.put('Type__c', 'GetCM');
        creatIntTaskMapReady15.put('Status__c', 'Ready');
        //creatIntTaskMapReady15.put('RecordTypeID',intTask_workord_Id);
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady15);
        
        Map<String,String> creatIntTaskMapReady16 = new Map<String,String>();
        creatIntTaskMapReady16.put('Operation__c', 'Get');
        creatIntTaskMapReady16.put('SObject__c', 'Artefact');       
        creatIntTaskMapReady16.put('Type__c', 'RequestInvoice');
        creatIntTaskMapReady16.put('Status__c', 'Ready');
        creatIntTaskMapReady16.put('RecordTypeID',intTask_arte_Id);
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady16);
    }
   
    
    @istest public static void testInitiation(){
            
       

        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
        
        PermissionSet psa = [SELECT Id FROM PermissionSet WHERE Name = 'Execute_SAP_Integration'];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psa.Id);
        
        
        List<Integration_task__c> listintTask=[SELECT Id, Status__c,Type__c FROM Integration_Task__c
                                                                                   WHERE Status__c ='In Progress'];
        List<Integration_task__c> listintTask2=[SELECT Id, Status__c,Type__c FROM Integration_Task__c
                                                                                   WHERE Status__c ='Ready'];
        System.runAs(testUser){
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new RestMock());
        TVE_SAPInteg_Initiation.startInitiation();
        test.stopTest();
        
        }
        
    }
    @istest static void testInitiationwithoutpermission(){
            
       

        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
		
  
        List<Integration_task__c> listintTask=[SELECT Id, Status__c,Type__c FROM Integration_Task__c
                                                                                   WHERE Status__c ='In Progress'];
        List<Integration_task__c> listintTask2=[SELECT Id, Status__c,Type__c FROM Integration_Task__c
                                                                                   WHERE Status__c ='Ready'];
        System.runAs(testUser){
        try {
             TVE_SAPInteg_Initiation.startInitiation();
        } catch(Exception e) {
            
        }
      
        
        
        }
        
    } 
    
}