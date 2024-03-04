/*
@author  : rohit.middha@ausnetservices.com.au
@created : 23 Sep 2019
@Description : Test Class for AEMO_Results_v1
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                     NA                             NA

-----------------------------------------------------------------------------------------
*/
@isTest
private class AEMO_Results_v1_Test {
    
    public static testMethod void testDoPost_Exception(){
        User testUser = UtilDatabase_Test.getTestUser();
        Case c1 = [SELECT Id, Application_Number__c, DER_Application__c FROM Case WHERE DER_Application__c != NULL LIMIT 1];
        Device__c d1 = [SELECT Id FROM Device__c WHERE DER_Application__c =: c1.DER_Application__c LIMIT 1];

        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
            
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;');
            
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'AEMOResults_Exception' LIMIT 1];
            AemoResultsPayload payload = (AemoResultsPayload)JSON.deserialize(sr.Body.toString(), AemoResultsPayload.class);
            payload.results[0].name = c1.Application_Number__c;
            payload.results[0].acConnections[0].connectionId = '200000004813440';
            payload.results[0].acConnections[0].nspConnectionId = d1.Id;
            payload.results[0].acConnections[0].status = 'Active';
            payload.results[0].acConnections[0].devices = NULL;
            
            
            request.requestBody = Blob.valueOf(payload.getJSON());
            
            RestContext.request = request;            
            RestContext.response= response;

            AEMO_Results_v1.doPost();
        }
        Test.stopTest();
        
    }
    
    public static testMethod void testDoPost_Error(){
        User testUser = UtilDatabase_Test.getTestUser();
        Case c1 = [SELECT Id, Application_Number__c, DER_Application__c FROM Case WHERE DER_Application__c != NULL LIMIT 1];
        Device__c d1 = [SELECT Id FROM Device__c WHERE DER_Application__c =: c1.DER_Application__c LIMIT 1];

        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
            
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;');
            
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'AEMOResults_Error' LIMIT 1];
            AemoResultsPayload payload = (AemoResultsPayload)JSON.deserialize(sr.Body.toString(), AemoResultsPayload.class);
            payload.results[0].name = c1.Application_Number__c;
            payload.results[0].acConnections[0].connectionId = '200000004813440';
            payload.results[0].acConnections[0].nspConnectionId = d1.Id;
            payload.results[0].acConnections[0].status = 'Active';
            payload.results[0].acConnections[0].devices = NULL;
            
            
            request.requestBody = Blob.valueOf(payload.getJSON());
            
            RestContext.request = request;            
            RestContext.response= response;
            AEMO_Results_v1.doPost();
        }
        Test.stopTest();
        
    }
    public static testMethod void testDoPost_Success(){
        User testUser = UtilDatabase_Test.getTestUser();
        Case c1 = [SELECT Id, Application_Number__c, DER_Application__c FROM Case WHERE DER_Application__c != NULL LIMIT 1];
        Device__c d1 = [SELECT Id FROM Device__c WHERE DER_Application__c =: c1.DER_Application__c LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser){
            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();            
            
            request.httpMethod = 'POST';
            request.addHeader('Content-Type', 'application/json;');
            
            StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'AEMOResults_Success' LIMIT 1];
            AemoResultsPayload payload = (AemoResultsPayload)JSON.deserialize(sr.Body.toString(), AemoResultsPayload.class);
            payload.results[0].name = c1.Application_Number__c;
            payload.results[0].acConnections[0].connectionId = '200000004813440';
            payload.results[0].acConnections[0].nspConnectionId = d1.Id;
            payload.results[0].acConnections[0].status = 'Active';
            payload.results[0].acConnections[0].devices = NULL;
            
            
            request.requestBody = Blob.valueOf(payload.getJSON());
            String reqBody1=        '{'+
                '  "results": ['+
                '    {'+
                '      "name": "string",'+
                '      "acConnections": ['+
                '        {'+
                '          "connectionld": " number ",'+
                '          "nspConnectionId": "string",'+
                '          "devices": ['+
                '            {'+
                '              "deviceld": " number",'+
                '              "nspDeviceId": "string "'+
                '            }'+
                '          ]'+
                '        }'+
                '      ],'+
                '      "exceptions": ['+
                '        {'+
                '          "exceptionld": " number",'+
                '          "code": "number",'+
                '          "name": "string",'+
                '          "details": "string",'+
                '          "status": "string",'+
                '          "deviceld": " number",'+
                '          "connectionld": "number",'+
                '          "nspAcknowIedged": " string "'+
                '        }'+
                '      ],'+
                '      "errors": ['+
                '        {'+
                '          "code": "string",'+
                '          "title": "string",'+
                '          "detail": "string",'+
                '          "source": "string "'+
                '        }'+
                '      ]'+
                '    }'+
                '  ]'+
                '}';
            AemoResultsPayload.parse(reqBody1);
            RestContext.request = request;            
            RestContext.response= response;
            AEMO_Results_v1.doPost();
        }
        Test.stopTest();
        
    }
    @TestSetup
    public static void setup() {
        
        //Create User
        User testUser = DER_TestUtility.createTestUser();
        insert testUser;
        
        //Create Individual Account
        Account testCustomer = DER_TestUtility.createPersonAccount('Person Account', 'test@test12345.com');
        insert testCustomer;
        
        //Create Business Account
        Account testInstaller = DER_TestUtility.createBusinessAccount('Business Account');
        insert testInstaller;
        
        //Create Business Account's Contact
        Contact testInstallerContact = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Installer', 'test@test12345.com');
        insert testInstallerContact;
        
        //Create case for Installer
        Case testCaseForInstaller = DER_TestUtility.createCaseForInstaller(DER_REST_Application_v1.CASE_RECORDTYPE_AUTO, 
                                                                           'New', 'Email', 'Medium', 
                                                                           testInstaller.Id, testInstallerContact.Id);
        insert testCaseForInstaller;
        
        
        //Create Connection Point
        Connection_Point__c testConnectionPoint = DER_TestUtility.createConnectionPoint(testCustomer.Id);
        Insert testConnectionPoint;
        
        
        //Create DER Application
        DER_Application__c testDERApp = DER_TestUtility.createDERApplication(testConnectionPoint.Id);
        Insert testDERApp;
        
        //Create case for Customer
        Case testCaseForCustomer = DER_TestUtility.createCaseForCustomer(testDERApp.Id,
                                                                         DER_REST_Application_v1.CASE_RECORDTYPE_AUTO, 
                                                                         'New', 'Email', 'Medium', testCustomer.Id);
        insert testCaseForCustomer;
        
        Case testCaseForDerGetMethod = DER_TestUtility.createCaseForDerGetMethod(testDERApp.Id,
                                                                                 DER_REST_Application_v1.CASE_RECORDTYPE_AUTO, 
                                                                                 'New', 'Email', 'Medium', 
                                                                                 testInstaller.Id, testInstallerContact.Id, 
                                                                                 testCustomer.Id);
        insert testCaseForDerGetMethod;
        
        
        //Create Device1
        Device__c testDevice = DER_TestUtility.createDevice(testDERApp.Id);
        Insert testDevice;  
        
        //Create Device2
        Device__c testDevice2 = DER_TestUtility.createDevice(testDERApp.Id);
        Insert testDevice2;
    }      
    
}