/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 04 Sep 2019
  @Description : Test class for DER_REST_Application_v1
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/

@isTest
private class DER_REST_Application_v1_Test{    
    private static String customerEmail = 'customer@test12345.com';
    private static String installerEmail = 'installer@test12345.com';
    private static String repEmail = 'rep@test12345.com';
	
    @testSetup static void setup()
    {
		Id testDERAppId = DER_TestUtility.loadDERAppRecords(customerEmail, installerEmail, repEmail);
	}

    // ===================================================== //
    // ============= Test methods for GET ================== //
    // ===================================================== //

    public static testMethod void testDoGet_Found(){
		Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
//        System.runAs(testUser){    
                      
            String appNumber = [SELECT Id, CaseNumber , ContactEmail , AccountId , Customer__c, Application_Number__c
                                  FROM Case  where ContactId != null and Customer__c != null and AccountId != null
                                  LIMIT 1].Application_Number__c;
            String nmiNumber = [SELECT Id, Name, NMI__c 
                                  FROM Connection_Point__c 
                                  LIMIT 1].NMI__c;
            String email = [SELECT Id, ContactId , ContactEmail 
                              FROM Case where ContactId != null  and Customer__c != null and AccountId != null
                              LIMIT 1].ContactEmail;            

            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();

            request.httpMethod = 'GET';
            request.addParameter('email', email);
            request.addParameter('nmiNumber', nmiNumber);
            request.addParameter('appNumber', appNumber);

            RestContext.request = request;            
            RestContext.response= response;
  //          Test.startTest();
            DER_REST_Application_v1.doGet();
            Test.stopTest();
//        }
    }

    public static testMethod void testDoGet_NotFound(){           
		Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
 //       System.runAs(testUser){    
                        
            String appNumber = 'test';
            String nmiNumber = 'test';
            String email = 'test@test12345.com';
            
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
                         
            request.httpMethod = 'GET';
            request.addParameter('email', email);
            request.addParameter('nmiNumber', nmiNumber);
            request.addParameter('appNumber', appNumber);

            RestContext.request = request;            
            RestContext.response= response;

            DER_REST_Application_v1.doGet();
//        }
        Test.stopTest();
    }
  
    public static testMethod void testDoGet_ParamMissing(){
		Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
//        System.runAs(testUser){    
            
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
                         
            request.httpMethod = 'GET';
            
            RestContext.request = request;            
            RestContext.response= response;

            DER_REST_Application_v1.doGet();
//        }
			Test.stopTest();        
    }

    // ===================================================== //
    // ============= Test methods for PATCH ================ //
    // ===================================================== //

    public static testMethod void testDoPatch_BodyNotFound(){
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
//        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            request.httpMethod = 'PATCH';
            request.addHeader('Content-Type', 'application/json;');
            String JSONRequest = '';
            request.requestBody = Blob.valueOf(JSONRequest);

            RestContext.request = request;            
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPatch();
//        }
        Test.stopTest();

    }

    public static testMethod void testDoPatch_InvalidContextType(){
		Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();

//        Test.startTest();
//        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
                         
            request.httpMethod = 'PATCH';
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Update_Auto' LIMIT 1];
			DER_Payload payload = (DER_Payload)JSON.deserialize(sr.Body.toString(), DER_Payload.class);

            request.requestBody = Blob.valueOf(payload.getJSON());

            RestContext.request = request;            
            RestContext.response= response;

            DER_REST_Application_v1.doPatch();
//        }
        Test.stopTest();
    }

    public static testMethod void testDoPatch_Auto_Exception(){
        Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
        Case casRec = [SELECT Id, DER_Application__c FROM Case LIMIT 1];
        DER_Application__c app = [SELECT Id FROM DER_Application__c WHERE Id =: casRec.DER_Application__c];

//        Test.startTest();
//        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            request.httpMethod = 'PATCH';
            request.addHeader('Content-Type', 'application/json;');

			StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Update_Auto' LIMIT 1];
			DER_Payload payload = (DER_Payload)JSON.deserialize(sr.Body.toString(), DER_Payload.class);
            // Trying to update without id
            // payload.derCase.Id = casRec.Id; 
            // payload.derApp.Id = app.Id; 

            request.requestBody = Blob.valueOf(payload.getJSON());

            RestContext.request = request;            
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPatch();
//        }
        Test.stopTest();
    }
    public static testMethod void testDoPatch_Auto_Success(){
		Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
        
        // Let's first create an auto application
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();            
                        
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json;');

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Create_Auto' LIMIT 1];
        DER_Payload payload = (DER_Payload)JSON.deserialize(sr.Body.toString(), DER_Payload.class);			
        
        request.requestBody = Blob.valueOf(payload.getJSON());

        RestContext.request = request;            
        RestContext.response= response;
        System.debug('test request--->'+RestContext.request);
        DER_REST_Application_v1.doPost();
        
        // Now lets fetch the der case from above integration call
        Case caseRec = [SELECT Id, Status, AccountId, DER_Application__c, Invoice_Required__c, Region__c
                        FROM Case 
                        WHERE ContactEmail =: payload.installerContact.Email 
                        LIMIT 1];        
        
        DER_Application__c app = [SELECT Id, NMI__c FROM DER_Application__c WHERE Id =: caseRec.DER_Application__c];
        Connection_Point__c cp = [SELECT Id FROM Connection_Point__c WHERE Id =: app.NMI__c LIMIT 1];

//        Test.startTest();
//        System.runAs(testUser){
            RestRequest request_2 = new RestRequest();
            RestResponse response_2 = new RestResponse();            
                         
            request_2.httpMethod = 'PATCH';
            request_2.addHeader('Content-Type', 'application/json;');

			StaticResource sr_2 = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Update_Auto' LIMIT 1];
			DER_Payload payload_2 = (DER_Payload)JSON.deserialize(sr_2.Body.toString(), DER_Payload.class);
            payload_2.installer.ABN__c = '9999999999';
            payload_2.derCase.Id = caseRec.Id; 
            payload_2.derApp.Id = app.Id; 
            payload_2.nmi.Id = cp.Id;

            request_2.requestBody = Blob.valueOf(payload_2.getJSON());

            RestContext.request = request_2;            
            RestContext.response= response_2;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPatch();
//        }
        Test.stopTest();
    }

    public static testMethod void testDoPatch_Manual_Success(){
		Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();

        // Let's first create an manual application
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();            
                        
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json;');

        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Create_Manual' LIMIT 1];
        DER_Payload payload = (DER_Payload)JSON.deserialize(sr.Body.toString(), DER_Payload.class);
        
        request.requestBody = Blob.valueOf(payload.getJSON());

        RestContext.request = request;            
        RestContext.response = response;
        System.debug('test request--->'+RestContext.request);
        DER_REST_Application_v1.doPost();
        System.debug(RestContext.response.statusCode);

        if (RestContext.response.statusCode != 200)
        {
            String errorMsg = 'Error: Response not 200. Received instead: '+ RestContext.response.statusCode + '.\n' + RestContext.response.responseBody.toString();
            System.assert(RestContext.response.statusCode == 200, errorMsg);
        }

        // Now lets fetch the der case from above integration call
        Case caseRec = [SELECT Id, Status, DER_Application__c, DER_Application__r.NMI__c, 
                               Customer__c, Representative__c, AccountId, ContactId
                        FROM Case 
                        WHERE ContactEmail =: payload.installerContact.Email 
                        LIMIT 1];        
        
        Connection_Point__c cp = [SELECT Id FROM Connection_Point__c 
                                    WHERE Id =: caseRec.DER_Application__r.NMI__c LIMIT 1];

        Device__c dev = [SELECT Id FROM Device__c 
                         WHERE DER_Application__c =: caseRec.DER_Application__c 
                         LIMIT 1];

//        Test.startTest();
//        System.runAs(testUser){
            request = new RestRequest();
            response = new RestResponse();            
                         
            request.httpMethod = 'PATCH';
            request.addHeader('Content-Type', 'application/json;');

			StaticResource sr_2 = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Update_Manual' LIMIT 1];
			DER_Payload payload_2 = (DER_Payload)JSON.deserialize(sr_2.Body.toString(), DER_Payload.class);
			payload_2.derCase.Id = caseRec.Id;
            payload_2.derApp.Id = caseRec.DER_Application__c;
            payload_2.customer.Id = caseRec.Customer__c;
            payload_2.representative.Id = caseRec.Representative__c;
            payload_2.installer.Id = caseRec.AccountId; 
            payload_2.installerContact.Id = caseRec.ContactId;
            payload_2.nmi.Id = cp.Id;
            payload_2.devices[0].Id = dev.Id;
            
            request.requestBody = Blob.valueOf(payload_2.getJSON());

            RestContext.request = request;            
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPatch();
//        }
        Test.stopTest();
    }

    public static testMethod void testDoPatch_DERApplicationAPIException(){
Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
        Case casRec = [SELECT Id, DER_Application__c FROM Case LIMIT 1];
        DER_Application__c app = [SELECT Id FROM DER_Application__c WHERE Id =: casRec.DER_Application__c];
        Connection_Point__c cp = [SELECT Id FROM Connection_Point__c LIMIT 1];

//        Test.startTest();
//        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            request.httpMethod = 'PATCH';
            request.addHeader('Content-Type', 'application/json;');

			StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Update_Auto' LIMIT 1];
			DER_Payload payload = (DER_Payload)JSON.deserialize(sr.Body.toString(), DER_Payload.class);
            payload.installer.ABN__c = '9999999999';
            payload.derCase.Id = casRec.Id; 
            payload.derApp.Id = app.Id; 
            payload.nmi.Id = cp.Id;
            // alter the payload for API exception
            payload.devices[0].EAI_Type__c = null;
            payload.devices[0].EAI_Ref__c = payload.devices[1].EAI_Ref__c;
            
            request.requestBody = Blob.valueOf(payload.getJSON());

            RestContext.request = request;            
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPatch();
//        }
        Test.stopTest();
    }

    public static testMethod void testDoPatch_More_DERApplicationAPIException(){
		Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
        Case casRec = [SELECT Id, DER_Application__c FROM Case LIMIT 1];
        DER_Application__c app = [SELECT Id FROM DER_Application__c WHERE Id =: casRec.DER_Application__c];
        Connection_Point__c cp = [SELECT Id FROM Connection_Point__c LIMIT 1];

//        Test.startTest();
//        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            request.httpMethod = 'PATCH';
            request.addHeader('Content-Type', 'application/json;');

			StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Update_Auto' LIMIT 1];
			DER_Payload payload = (DER_Payload)JSON.deserialize(sr.Body.toString(), DER_Payload.class);
            payload.installer.ABN__c = '9999999999';
            payload.derCase.Id = casRec.Id; 
            payload.derApp.Id = app.Id; 
            payload.nmi.Id = cp.Id;
            // alter the payload for API exception
            payload.devices[0].EAI_Type__c = 'Device_L99';

            request.requestBody = Blob.valueOf(payload.getJSON());

            RestContext.request = request;            
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPatch();

            // alter the payload for API exception
            payload.devices[0].EAI_Type__c = 'Device_L2';
            payload.devices[0].EAI_Parent__c = 'EAI-Ref-01';
            payload.devices[1].EAI_Parent__c = null;

            request.requestBody = Blob.valueOf(payload.getJSON());

            RestContext.request = request;            
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPatch();
//        }
        Test.stopTest();
    }

    // ===================================================== //
    // ============= Test methods for post ================= //
    // ===================================================== //
    public static testMethod void testDoPost_InvalidContType(){
        Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
        
        
//        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'text;');

			StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Update_Auto' LIMIT 1];
			request.requestBody = Blob.valueOf(sr.Body.toString());

            RestContext.request = request;            
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPost();
//        }
        Test.stopTest();

    }

    public static testMethod void testDoPost_MissingAttribute(){
        Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
        
        
//        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;');

			StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Update_Auto' LIMIT 1];
			DER_Payload payload = (DER_Payload)JSON.deserialize(sr.Body.toString(), DER_Payload.class);
			payload.derCase.DER_Application_Scenario__c = null;

            request.requestBody = Blob.valueOf(payload.getJSON());

            RestContext.request = request;            
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPost();
//        }
        Test.stopTest();
    }

    public static testMethod void testDoPost_BodyNotFound(){
        Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
        
        
//        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;');
            String JSONRequest = '';
            request.requestBody = Blob.valueOf(JSONRequest);

            RestContext.request = request;            
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPost();
//        }
        Test.stopTest();
    }


    public static testMethod void testDoPost_Auto_Success(){
        Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
        
        
//        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;');

			StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Create_Auto' LIMIT 1];
			DER_Payload payload = (DER_Payload)JSON.deserialize(sr.Body.toString(), DER_Payload.class);			
            
            request.requestBody = Blob.valueOf(payload.getJSON());

            RestContext.request = request;            
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPost();
//        }
        Test.stopTest();
    }

    public static testMethod void testDoPost_Exception(){
        Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
        
        
//        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;');

			StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Create_Auto' LIMIT 1];
			DER_Payload payload = (DER_Payload)JSON.deserialize(sr.Body.toString(), DER_Payload.class);			
            
            // In order to get exception, use invalid picklist value
            payload.derCase.Agreement_Type__c = 'Basic Micro EG MSO Invalid Postfix';

            request.requestBody = Blob.valueOf(payload.getJSON());

            RestContext.request = request;            
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPost();
//        }
        Test.stopTest();
    }
    public static testMethod void testDoPost_DERApplicationAPIException(){
        Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
        
        
//        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;');

			StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Create_Auto' LIMIT 1];
			DER_Payload payload = (DER_Payload)JSON.deserialize(sr.Body.toString(), DER_Payload.class);			
            payload.devices[0].EAI_Ref__c = null;

            request.requestBody = Blob.valueOf(payload.getJSON());

            RestContext.request = request;            
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPost();
//        }
        Test.stopTest();
    }

    public static testMethod void testDoPost_Manual_Success(){
        User testUser = UtilDatabase_Test.getTestUser();
        
        Test.startTest();
//        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
                         
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;');

			StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DER_App_Create_Manual' LIMIT 1];
			DER_Payload payload = (DER_Payload)JSON.deserialize(sr.Body.toString(), DER_Payload.class);
			
            request.requestBody = Blob.valueOf(payload.getJSON());

            RestContext.request = request;            
            RestContext.response= response;
            System.debug('test request--->'+RestContext.request);
            DER_REST_Application_v1.doPost();
//        }
        Test.stopTest();
    }

    // @TestSetup
    // public static void setup() {
        
    //     //Create User
    //     User testUser = DER_TestUtility.createTestUser();
    //     insert testUser;

    //     //Create Individual Account
    //     Account testCustomer = DER_TestUtility.createPersonAccount('Person Account', 'test@test12345.com');
    //     insert testCustomer;

    //     //Create Business Account
    //     Account testInstaller = DER_TestUtility.createBusinessAccount('Business Account');
    //     insert testInstaller;

    //     //Create Business Account's Contact
    //     Contact testInstallerContact = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Installer', 'test@test12345.com');
    //     insert testInstallerContact;

    //     //Create case for Installer
    //     Case testCaseForInstaller = DER_TestUtility.createCaseForInstaller(DER_REST_Application_v1.CASE_RECORDTYPE_AUTO, 
    //                                                                         'New', 'Email', 'Medium', 
    //                                                                         testInstaller.Id, testInstallerContact.Id);
    //     insert testCaseForInstaller;
  
        
    //     //Create Connection Point
    //     Connection_Point__c testConnectionPoint = DER_TestUtility.createConnectionPoint(testCustomer.Id);
    //     Insert testConnectionPoint;

      
    //     //Create DER Application
    //     DER_Application__c testDERApp = DER_TestUtility.createDERApplication(testConnectionPoint.Id);
    //     Insert testDERApp;
        
    //     //Create case for Customer
    //     Case testCaseForCustomer = DER_TestUtility.createCaseForCustomer(testDERApp.Id,
    //                                                                         DER_REST_Application_v1.CASE_RECORDTYPE_AUTO, 
    //                                                                         'New', 'Email', 'Medium', testCustomer.Id);
    //     insert testCaseForCustomer;
        
    //     Case testCaseForDerGetMethod = DER_TestUtility.createCaseForDerGetMethod(testDERApp.Id,
    //                                                                                 DER_REST_Application_v1.CASE_RECORDTYPE_AUTO, 
    //                                                                                 'New', 'Email', 'Medium', 
    //                                                                                 testInstaller.Id, testInstallerContact.Id, 
    //                                                                                 testCustomer.Id);
    //     insert testCaseForDerGetMethod;

        
    //     //Create Device1
    //     Device__c testDevice = DER_TestUtility.createDevice(testDERApp.Id);
    //     Insert testDevice;  
        
    //     //Create Device2
    //     Device__c testDevice2 = DER_TestUtility.createDevice(testDERApp.Id);
    //     Insert testDevice2;
    // }      

}