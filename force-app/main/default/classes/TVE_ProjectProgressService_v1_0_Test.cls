/*
@author  : pavan.dave@ausnetservices.com.au
@created : 16 Dec 2019
@Description : Test class for TVE_ProjectProgressService_v1_0
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/
@isTest
public with sharing class TVE_ProjectProgressService_v1_0_Test {
    public static string PROGRESS_BAR_STATUS = 'Allocated for initial assessment';
    public static string PROGRESS_BAR_STATUS_2 = 'Prelim estimate accepted';
    public static string CONTESTATIBILITY_TYPE = 'IDEC';
	    
    @TestSetup
	public static void setup()
	{
        eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
        eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
        insert eSignObj;
		//Create Project Record
		Project__c testProject = TVE_TestUtility.createProject('test11',PROGRESS_BAR_STATUS,CONTESTATIBILITY_TYPE);
		insert testProject;	
	}

    // ===================================================== //
    // ============= Test methods for GET ================== //
    // ===================================================== //

    public static testMethod void testDoGet_Found_Paylater(){
        
        Project__c proj = [SELECT Id, OfferType__c, PaymentReferenceNumber__c
                            FROM Project__c 
                            LIMIT 1];            
        
        
        proj.OfferType__c = 'PREQ';
        proj.PaymentReferenceNumber__c = 'a0E2N000000GMQoUAO';
        update proj;

        String projId = proj.Id;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.httpMethod = 'GET';
        request.addParameter('id', projId);
        
        RestContext.request = request;            
        RestContext.response= response;
        Test.startTest();
        TVE_ProjectProgressService_v1_0.doGet();
        Test.stopTest();
    }

    public static testMethod void testDoGet_Found_Paynow(){
        
        Project__c proj = [SELECT Id, OfferType__c, PaymentReferenceNumber__c
                            FROM Project__c 
                            LIMIT 1];            
        
        
        proj.OfferType__c = 'PREQ';
        proj.PaymentReferenceNumber__c = null;
        update proj;

        String projId = proj.Id;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.httpMethod = 'GET';
        request.addParameter('id', projId);
        
        RestContext.request = request;            
        RestContext.response= response;
        Test.startTest();
        TVE_ProjectProgressService_v1_0.doGet();
        Test.stopTest();
    }

    public static testMethod void testDoGet_ProjectFieldMissing(){
        
        String projId = [SELECT Id
                            FROM Project__c 
                            LIMIT 1].Id;            

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();

        request.httpMethod = 'GET';
        request.addParameter('id', projId);
        
        RestContext.request = request;            
        RestContext.response= response;
        Test.startTest();
        TVE_ProjectProgressService_v1_0.doGet();
        Test.stopTest();
    }

    public static testMethod void testDoGet_NotFound(){           
        String projId = 'a0E2N000000GMQoUAO';
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
                        
        request.httpMethod = 'GET';
        request.addParameter('id', projId);

        RestContext.request = request;            
        RestContext.response= response;

        TVE_ProjectProgressService_v1_0.doGet();
    }
  
    public static testMethod void testDoGet_ParamMissing(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
                        
        request.httpMethod = 'GET';
        
        RestContext.request = request;            
        RestContext.response= response;

        TVE_ProjectProgressService_v1_0.doGet();
    }
}