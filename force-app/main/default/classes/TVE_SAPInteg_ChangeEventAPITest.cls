/*
@author  : harshad.kumbhar@ausnetservices.com.au
@created : 28 Feb 2020
@Description : Test class for ChangeEvent API
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
 
-----------------------------------------------------------------------------------------
*/
@isTest
public with sharing class TVE_SAPInteg_ChangeEventAPITest {
    
    public static final string testUserEmail = 'testuser@TVECustomerDetailsSAP.com';
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public static ID intTask_arte_Id = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByName().get('Artefact').getRecordTypeId();
 
	@testSetup static void setup(){
		//Create User
		User testUser = TVE_TestUtility.createTestUser(testUserEmail);
		insert testUser;

		Account testAccount = TVE_TestUtility.createPersonAccount('acctName', testUserEmail);
		testAccount.PersonMailingStreet = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean m';   
		
		insert testAccount;
		
		Account testAcc1 = TVE_TestUtility.createPersonAccount('acctName1', testUserEmail);
		insert testAcc1;       
		
		eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
		eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
		insert eSignObj;
			
		List<Project__c> lstProj = new List<Project__c>();
		lstProj.add(TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE));
		lstProj[0].CMNumber__c = '12345';		
        lstProj.add(TVE_TestUtility.createProject('test1',PROGRESS_BAR_STATUS,CON_TYPE));
        Insert lstProj;
          
        // List<Artefact__c> lstArtefact = new List<Artefact__c>();
        // lstArtefact.add(TVE_TestUtility.createInvoiceArtefact('Test',lstProj[0].Id,testAcc1.id));
        // lstArtefact[0].SAPNumber__c = '4444';
        // //lstArtefact.add(TVE_TestUtility.createInvoiceArtefact('Test',lstProj[1].Id,testAcc1.id));
        // //lstArtefact[1].InvoiceNumber__c = '4444';
        // insert lstArtefact;
 
    }

    static testMethod void testPostMethod_CM_Update1()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_CM_Update1());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Project__c'  AND                                              
                                        Type__c =: 'GetCM' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(1, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_CM_Update1()
    {
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.CM_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId='12345';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='1111';
        payload.request.payload.constNotiId='';
        payload.request.payload.constWOId='';
        payload.request.payload.invoiceId='';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }

    static testMethod void testPostMethod_CM_Update2()
    {
        User testUser = UtilDatabase_Test.getTestUser();

        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
        Map<Id,String> creatIntTaskMapKey = new Map<Id,String>();
        Map<String,String> creatIntTaskMap = new Map<String,String>();
        creatIntTaskMapKey.put(lstProj[0].Id, lstProj[0].Id);
        creatIntTaskMap.put('Operation__c','Get');
        creatIntTaskMap.put('SObject__c','Project__c');
        creatIntTaskMap.put('Type__c','GetCM');
        creatIntTaskMap.put('Status__c','Ready');
        creatIntTaskMap.put('RecordTypeID', TVE_SAPInteg_ChangeEventAPI.Proj_RTId);
        TVE_IntegUtility.CreateInteTask(creatIntTaskMapKey,creatIntTaskMap);
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_CM_Update2());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Project__c'  AND                                              
                                        Type__c =: 'GetCM' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(1, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_CM_Update2()
    {
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.CM_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId='12345';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='1111';
        payload.request.payload.constNotiId='';
        payload.request.payload.constWOId='';
        payload.request.payload.invoiceId='';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }

    static testMethod void testPostMethod_CM_Update3()
    {
        User testUser = UtilDatabase_Test.getTestUser();

        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
        Map<Id,String> creatIntTaskMapKey = new Map<Id,String>();
        Map<String,String> creatIntTaskMap = new Map<String,String>();
        creatIntTaskMapKey.put(lstProj[0].Id, lstProj[0].Id);
        creatIntTaskMap.put('Operation__c','Update');
        creatIntTaskMap.put('SObject__c','Project__c');
        creatIntTaskMap.put('Type__c','UpdateCM');
        creatIntTaskMap.put('Status__c','Ready');
        creatIntTaskMap.put('RecordTypeID', TVE_SAPInteg_ChangeEventAPI.Proj_RTId);
        TVE_IntegUtility.CreateInteTask(creatIntTaskMapKey,creatIntTaskMap);
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_CM_Update3());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Project__c'  AND                                              
                                        Type__c =: 'GetCM' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_CM_Update3()
    {
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.CM_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId='12345';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='1111';
        payload.request.payload.constNotiId='';
        payload.request.payload.constWOId='';
        payload.request.payload.invoiceId='';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }

    static testMethod void testPostMethod_CM_Update4()
    {
        User testUser = UtilDatabase_Test.getTestUser();

        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
        Map<Id,String> creatIntTaskMapKey = new Map<Id,String>();
        Map<String,String> creatIntTaskMap = new Map<String,String>();
        creatIntTaskMapKey.put(lstProj[0].Id, lstProj[0].Id);
        creatIntTaskMap.put('Operation__c','Create');
        creatIntTaskMap.put('SObject__c','Project__c');
        creatIntTaskMap.put('Type__c','CreateCustomer');
        creatIntTaskMap.put('Status__c','Ready');
        creatIntTaskMap.put('RecordTypeID', TVE_SAPInteg_ChangeEventAPI.Proj_RTId);
        TVE_IntegUtility.CreateInteTask(creatIntTaskMapKey,creatIntTaskMap);
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_CM_Update4());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Project__c'  AND                                              
                                        Type__c =: 'GetCM' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_CM_Update4()
    {
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.CM_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId='12345';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='1111';
        payload.request.payload.constNotiId='';
        payload.request.payload.constWOId='';
        payload.request.payload.invoiceId='';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_WoUpdate1()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
        WorkOrder wo = [SELECT Id FROM WorkOrder WHERE Type__c =: 'Construction' and Project__c =: lstProj[0].Id
                           LIMIT 1];
        wo.OrderNumber__c = '12345';
        update wo;
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_WOUpdate1());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'WorkOrder'  AND                                              
                                        Type__c =: 'GetConstWO' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(1, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_WOUpdate1()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];

        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.WorkOrder_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'WorkOrder';
        payload.request.payload.objectId='12345';
        payload.request.payload.eventType='Update';
        payload.request.payload.sfrefno=lstProj[0].Id;

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_WoUpdate2()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_WOUpdate2());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'WorkOrder'  AND                                              
                                        Type__c =: 'GetConstWO' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(1, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_WOUpdate2()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];

        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.WorkOrder_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'WorkOrder';
        payload.request.payload.objectId='12345';
        payload.request.payload.eventType='Update';
        payload.request.payload.sfrefno=lstProj[0].Id;

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_WoUpdate3()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_WOUpdate3());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'WorkOrder'  AND                                              
                                        Type__c =: 'GetConstWO' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_WOUpdate3()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];

        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.WorkOrder_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'WorkOrder';
        payload.request.payload.eventType='Update';
        payload.request.payload.sfrefno=lstProj[0].Id;

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_Work_Create1()
    {
        User testUser = UtilDatabase_Test.getTestUser();

        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Work_Create1());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c' AND
                                        Type__c =: 'GetInvoice' AND
                                        Status__c =: 'Ready'];
            System.assertEquals(1, lsttask.size());
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Work_Create1()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
               
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Work_Create';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'Work';
        payload.request.payload.objectId= lstProj[0].Id;
        payload.request.payload.eventType='Create';
        payload.request.payload.cmId='55555';
        payload.request.payload.constNotiId='111111';
        payload.request.payload.constWOId='222222';
        payload.request.payload.invoiceId='333333';
        payload.request.payload.salesOrderId='444444';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_Work_Create2()
    {
        User testUser = UtilDatabase_Test.getTestUser();

        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Work_Create2());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c' AND
                                        Type__c =: 'GetInvoice' AND
                                        Status__c =: 'Ready'];
            System.assertEquals(0, lsttask.size());
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Work_Create2()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
               
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Work_Create';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'Work';
        payload.request.payload.objectId= lstProj[0].Id;
        payload.request.payload.eventType='Create';
        payload.request.payload.cmId='55555';
        payload.request.payload.constNotiId='111111';
        payload.request.payload.constWOId='222222';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }

    static testMethod void testPostMethod_Work_Create3()
    {
        User testUser = UtilDatabase_Test.getTestUser();

        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Work_Create3());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c' AND
                                        Type__c =: 'GetInvoice' AND
                                        Status__c =: 'Ready'];
            System.assertEquals(0, lsttask.size());
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Work_Create3()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test1'];
               
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Work_Create';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'Work';
        payload.request.payload.objectId= lstProj[0].Id;
        payload.request.payload.eventType='Create';
        payload.request.payload.cmId='55555';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_PMNotification_Update1()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Type =: 'Construction' and Project__c =: lstProj[0].Id
                           LIMIT 1];
        opp.Notification_Number__c = '22222';
        update opp;
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_PMNotification_Update1());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Opportunity'  AND                                              
                                        Type__c =: 'GetConstNoti' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(1, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_PMNotification_Update1()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];

        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.PMNotification_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'PMNotification';
        payload.request.payload.objectId= '22222';
        payload.request.payload.eventType='Update';
        payload.request.payload.sfrefno=lstProj[0].Id;

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_PMNotification_Update2()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_PMNotification_Update2());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Opportunity'  AND                                              
                                        Type__c =: 'GetConstNoti' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(1, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_PMNotification_Update2()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];

        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.PMNotification_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'PMNotification';
        payload.request.payload.objectId= '22222';
        payload.request.payload.eventType='Update';
        payload.request.payload.sfrefno=lstProj[0].Id;

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_PMNotification_Update3()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_PMNotification_Update3());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Opportunity'  AND                                              
                                        Type__c =: 'GetConstNoti' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(0, lsttask.size());
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_PMNotification_Update3()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];

        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.PMNotification_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00';
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'PMNotification';
        payload.request.payload.eventType='Update';
        payload.request.payload.sfrefno=lstProj[0].Id;

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_Invoice_Update1()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Invoice_Update1());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetInvoice' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(1, lsttask.size());
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Invoice_Update1()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
        Artefact__c Art = [SELECT Id FROM Artefact__c WHERE Project__c =: lstProj[0].Id 
                                    AND RecordType.DeveloperName =: 'Invoice' LIMIT 1];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Invoice_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'Invoice';
        payload.request.payload.objectId= '44444';
        payload.request.payload.eventType='Update';
        payload.request.payload.sfrefno = Art.Id;

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_Invoice_Update2()
    {
        User testUser = UtilDatabase_Test.getTestUser();

        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
       
        
        Artefact__c art = [SELECT Id FROM Artefact__c WHERE Project__c =: lstProj[0].Id 
                            AND RecordType.DeveloperName =: 'Invoice' LIMIT 1];
        art.InvoiceNumber__c = '44444';
        update art;
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Invoice_Update2());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetInvoice' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(1, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Invoice_Update2()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Invoice_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'Invoice';
        payload.request.payload.objectId= '44444';
        payload.request.payload.eventType='Update';
        payload.request.payload.sfrefno = lstProj[0].Id;

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_Invoice_Update3()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Invoice_Update3());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetInvoice' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(1, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Invoice_Update3()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Invoice_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'Invoice';
        payload.request.payload.objectId= '44444';
        payload.request.payload.eventType='Update';
        payload.request.payload.salesOrderId='555555';
        payload.request.payload.sfrefno = lstProj[0].Id;

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }

    static testMethod void testPostMethod_Invoice_Update4()
    {
        User testUser = UtilDatabase_Test.getTestUser();

        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
       
        
        Artefact__c art = [SELECT Id FROM Artefact__c WHERE Project__c =: lstProj[0].Id 
                            AND RecordType.DeveloperName =: 'Invoice' LIMIT 1];
        art.InvoiceNumber__c = '44444';
        update art;
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Invoice_Update4());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetInvoice' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(1, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Invoice_Update4()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Invoice_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'Invoice';
        payload.request.payload.objectId= '55555';
        payload.request.payload.salesOrderId='666666';
        payload.request.payload.eventType='Update';
        payload.request.payload.sfrefno = lstProj[0].Id;

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }

    static testMethod void testPostMethod_Invoice_Update5()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Invoice_Update5());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetInvoice' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Invoice_Update5()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test'];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Invoice_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'Invoice';
        payload.request.payload.salesOrderId='666666';
        payload.request.payload.eventType='Update';
        payload.request.payload.sfrefno = lstProj[0].Id;

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }

    static testMethod void testPostMethod_Invoice_Update6()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Invoice_Update6());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetInvoice' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Invoice_Update6()
    {
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Invoice_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'Invoice';
        payload.request.payload.objectId= '55555';
        payload.request.payload.salesOrderId='666666';
        payload.request.payload.eventType='Update';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }

    static testMethod void testPostMethod_Invoice_Update7()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Invoice_Update7());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetInvoice' AND                           
                                        Status__c =: 'Ready'];
            System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Invoice_Update7()
    {
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Invoice_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'Invoice';
        payload.request.payload.objectId= '55555';
        payload.request.payload.salesOrderId='666666';
        payload.request.payload.eventType='Update';
        payload.request.payload.sfrefno = '001000000ABCDEF';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_CMArtefact_Create()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_CMArtefact_Create());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetCMArtefact' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(1, lsttask.size()); 
            
        }
        Test.stopTest();
    }
    
    static testMethod void testPostMethod_CMArtefact_Create_2()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        List<Project__c> lstProj = [SELECT Id FROM Project__c LIMIT 2];
        
        Map<Id,String> recordMapReady = new Map<Id,String>(); 
        recordMapReady.put(lstProj[1].Id, 'ParentId');
        Map<String,String> creatIntTaskMapReady = new Map<String,String>();
        creatIntTaskMapReady.put('Operation__c', 'Get');
        creatIntTaskMapReady.put('SObject__c', 'Artefact__c');       
        creatIntTaskMapReady.put('Type__c', 'GetCMArtefact');
        creatIntTaskMapReady.put('Status__c', 'In Progress');
        creatIntTaskMapReady.put('RecordTypeID',intTask_arte_Id);

        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady); 
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_CMArtefact_Create());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetCMArtefact' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(1, lsttask.size()); 
            
        }
        Test.stopTest();
    }
    @isTest Static String GenerateJSON_CMArtefact_Create()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test1'];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.CMArtefact_Create';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId= '4444';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='12345';
        payload.request.payload.constNotiId='111111';
        payload.request.payload.constWOId='222222';
        payload.request.payload.invoiceId='333333';
        payload.request.payload.docId='ZCU_DRRE';
        payload.request.payload.cmNum='12345';
        payload.request.payload.fileName='a002O000001EQmO';
        payload.request.payload.sapObject='/CUM/CONSM';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_Invoice_Update_Failed()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Invoice_Update_Failed());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetInvoice' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Invoice_Update_Failed()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test1'];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Invoice_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId= '';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='55555';
        payload.request.payload.constNotiId='111111';
        payload.request.payload.constWOId='222222';
        payload.request.payload.invoiceId='333333';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_Invoice_Update_Failed1()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Invoice_Update_Failed1());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetInvoice' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Invoice_Update_Failed1()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test1'];
        
        Artefact__c Art = [SELECT Id FROM Artefact__c WHERE Project__c =: lstProj[0].Id 
                                    AND RecordType.DeveloperName =: 'Invoice' LIMIT 1];
        
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Invoice_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId= '4444';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='55555';
        payload.request.payload.constNotiId='111111';
        payload.request.payload.constWOId='222222';
        payload.request.payload.invoiceId='333333';
        payload.request.payload.sfrefno = '00000';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    } 
    
    static testMethod void testPostMethod_WoUpdate_Failed()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_WOUpdate_Failed());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'WorkOrder'  AND                                              
                                        Type__c =: 'GetConstWO' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_WOUpdate_Failed()
    {
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.WorkOrder_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId='9999999';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='1111';
        payload.request.payload.constNotiId='';
        payload.request.payload.constWOId='';
        payload.request.payload.invoiceId='';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_WoUpdate_Failed1()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_WOUpdate_Failed1());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'WorkOrder'  AND                                              
                                        Type__c =: 'GetConstWO' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_WOUpdate_Failed1()
    {
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.WorkOrder_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId='';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='1111';
        payload.request.payload.constNotiId='';
        payload.request.payload.constWOId='';
        payload.request.payload.invoiceId='';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_PMNotification_Failed()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_PMNotification_Failed());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Opportunity'  AND                                              
                                        Type__c =: 'GetConstNoti' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_PMNotification_Failed()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test1'];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.PMNotification_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId= '';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='55555';
        payload.request.payload.constNotiId='111111';
        payload.request.payload.constWOId='222222';
        payload.request.payload.invoiceId='333333';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_PMNotification_Failed1()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_PMNotification_Failed1());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Opportunity'  AND                                              
                                        Type__c =: 'GetConstNoti' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_PMNotification_Failed1()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test1'];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.PMNotification_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId= '878787878';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='55555';
        payload.request.payload.constNotiId='111111';
        payload.request.payload.constWOId='222222';
        payload.request.payload.invoiceId='333333';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_Work_CreateFailed()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Work_CreateFailed());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetCMArtefact' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Work_CreateFailed()
    {        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Work_Create';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId=  '00000000';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='34343';
        payload.request.payload.constNotiId='45454';
        payload.request.payload.constWOId='886756788';
        payload.request.payload.invoiceId='6757';
        payload.request.payload.docId='ZCU_DRRE';
        payload.request.payload.cmNum='2223432422';
        payload.request.payload.fileName='a002O000001EQmO';
        payload.request.payload.sapObject='/CUM/CONSM';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_Wrk_CreateFailed()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Wrk_CreateFailed());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetCMArtefact' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Wrk_CreateFailed()
    {
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.Work_Create';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId= '';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='9999';
        payload.request.payload.constNotiId='0000';
        payload.request.payload.constWOId='8888';
        payload.request.payload.invoiceId='9999';
        payload.request.payload.docId='ZCU_DRRE';
        payload.request.payload.cmNum='2222';
        payload.request.payload.fileName='a002O000001EQmO';
        payload.request.payload.sapObject='/CUM/CONSM';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_CM_UpdateFailed()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_CM_UpdateFailed());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetCMArtefact' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_CM_UpdateFailed()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test1'];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.CM_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId= '';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='9999';
        payload.request.payload.constNotiId='0000';
        payload.request.payload.constWOId='8888';
        payload.request.payload.invoiceId='9999';
        payload.request.payload.docId='ZCU_DRRE';
        payload.request.payload.cmNum='';
        payload.request.payload.fileName='a002O000001EQmO';
        payload.request.payload.sapObject='/CUM/CONSM';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }

    static testMethod void testPostMethod_CM_UpdateProjectFailed()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_CM_UpdateProjectFailed());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetCMArtefact' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_CM_UpdateProjectFailed()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test1'];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.CM_Update';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId= '121212121';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='9999';
        payload.request.payload.constNotiId='0000';
        payload.request.payload.constWOId='8888';
        payload.request.payload.invoiceId='9999';
        payload.request.payload.docId='ZCU_DRRE';
        payload.request.payload.cmNum='';
        payload.request.payload.fileName='a002O000001EQmO';
        payload.request.payload.sapObject='/CUM/CONSM';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_CMArtefact_CreateFailed()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_CMArtefact_CreateFailed());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetCMArtefact' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_CMArtefact_CreateFailed()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test1'];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.CMArtefact_Create';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId= '';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='9999';
        payload.request.payload.constNotiId='0000';
        payload.request.payload.constWOId='8888';
        payload.request.payload.invoiceId='9999';
        payload.request.payload.docId='ZCU_DRRE';
        payload.request.payload.cmNum='12345';
        payload.request.payload.fileName='a002O000001EQmO';
        payload.request.payload.sapObject='/CUM/CONSM';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_CMArt_CreateFailed()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_CMArt_CreateFailed());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetCMArtefact' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(1, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_CMArt_CreateFailed()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test1'];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.CMArtefact_Create';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId= '4444';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='12345';
        payload.request.payload.constNotiId='111111';
        payload.request.payload.constWOId='222222';
        payload.request.payload.invoiceId='333333';
        payload.request.payload.docId='ZCU_DRRE';
        payload.request.payload.cmNum='12345';
        payload.request.payload.fileName='a002O000001EQmO';
        payload.request.payload.sapObject='/CUM/CONSM';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
    
    static testMethod void testPostMethod_Failed()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(GenerateJSON_Failed());
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
            
            List<Integration_Task__c> lsttask = [SELECT Id, ParentId__c FROM Integration_Task__c WHERE
                                        Operation__c =: 'Get' AND
                                        SObject__c =: 'Artefact__c'  AND                                              
                                        Type__c =: 'GetCMArtefact' AND                           
                                        Status__c =: 'Ready'];
           System.assertEquals(0, lsttask.size()); 
            
        }
        Test.stopTest();
    }

    @isTest Static String GenerateJSON_Failed()
    {
        List<Project__c> lstProj = [SELECT Id FROM Project__c WHERE Name =: 'test1'];
        
        TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
        payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
        payload.request.key = 'NC';
        payload.request.msgId = '1233';
        payload.request.sourceSystem = 'ERP';
        payload.request.targetSystem = 'Salesforce';
        payload.request.objectName = 'Event.XXXX';
        payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
        payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
        payload.request.payload.objectName = 'CM';
        payload.request.payload.objectId= '4444';
        payload.request.payload.eventType='UpdateCM';
        payload.request.payload.cmId='12345';
        payload.request.payload.constNotiId='111111';
        payload.request.payload.constWOId='222222';
        payload.request.payload.invoiceId='333333';
        payload.request.payload.docId='ZCU_DRRE';
        payload.request.payload.cmNum='12345';
        payload.request.payload.fileName='a002O000001EQmO';
        payload.request.payload.sapObject='/CUM/CONSM';

        String jsonString = JSON.serialize(payload);
        System.debug('jsonString : ' + jsonString);
        return jsonString;
    }
	
    static testMethod void testPostMethod_PayloadClass()
    {
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            
            TVE_SAPInteg_ChangeEvent_Payload payload = new TVE_SAPInteg_ChangeEvent_Payload();
            payload.request = new TVE_SAPInteg_ChangeEvent_Payload.Request();
            payload.request.key = 'NC';
            payload.request.msgId = '1233';
            payload.request.sourceSystem = 'ERP';
            payload.request.targetSystem = 'Salesforce';
            payload.request.objectName = 'Event.XXXX';
            payload.request.dateAndTime = '2020-02-12T09:51:58.000+10:00'; 
            payload.request.payload = new TVE_SAPInteg_ChangeEvent_Payload.Payload();
            payload.request.payload.objectName = 'CM';
            payload.request.payload.objectId= '4444';
            payload.request.payload.eventType='UpdateCM';
            payload.request.payload.cmId='12345';
            payload.request.payload.constNotiId='111111';
            payload.request.payload.constWOId='222222';
            payload.request.payload.invoiceId='333333';
            payload.request.payload.docId='ZCU_DRRE';
            payload.request.payload.cmNum='12345';
            payload.request.payload.fileName='a002O000001EQmO';
            payload.request.payload.sapObject='/CUM/CONSM';
            String jsonString = JSON.serialize(payload);
            
            String jsonStr = payload.getJSON();
            
            RestContext.request = request;   
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;charset=UTF-8');            
			request.requestBody = Blob.valueOf(jsonString);
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            TVE_SAPInteg_ChangeEventAPI.doPost();          
            System.debug('test response --->'+ RestContext.response.responseBody.toString());
          
        }
        Test.stopTest();      
        
    }
    
    
}