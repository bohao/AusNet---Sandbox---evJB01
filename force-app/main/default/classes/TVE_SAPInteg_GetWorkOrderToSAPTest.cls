/*
  @author  : harshad.kumbhar@ausnetservices.com.au
  @created : 05 Mar 2020
  @Description : Test Class for Get WO to SAP system
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
@isTest
public with sharing class TVE_SAPInteg_GetWorkOrderToSAPTest {
    public static final string testUserEmail = 'testuser@TVECustomerDetailsSAP.com';
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public  static String WO_RT   = 'WorkOrder';
    private static Id  WO_RTId = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByDeveloperName().get(WO_RT).getRecordTypeId();
    
	@testSetup static void setup(){

		//Create User
		User testUser = TVE_TestUtility.createTestUser(testUserEmail);
		insert testUser;

		Account testAccount = TVE_TestUtility.createPersonAccount('acctName', testUserEmail);
		insert testAccount;
		
		eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
		eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
		insert eSignObj;
            
        List<Project__c> lstProj = new List<Project__c>();
		lstProj.add(TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE));
		lstProj[0].CMNumber__c = '11111';					
        Insert lstProj;
        
        List<WorkOrder> lstWO = new List<WorkOrder>();
        lstWO.add(TVE_TestUtility.createWorkOrder(lstProj[0].Id,'Construction'));
        lstWO[0].OrderNumber__c = '222222';
        Insert lstWO;
		
        
		Map<Id,String> recordMap = new Map<Id,String>(); 
		for (WorkOrder wo : lstWO) {
			recordMap.put(wo.id, wo.Id);	
		}        
        Map<String,String> creatIntTaskMap = new Map<String,String>();
        creatIntTaskMap.put('Operation__c', 'Get');
        creatIntTaskMap.put('SObject__c', 'WorkOrder');       
        creatIntTaskMap.put('Type__c', 'GetConstWO');
        creatIntTaskMap.put('Status__c', 'In Progress');     
        creatIntTaskMap.put('RecordTypeID', WO_RTId);        
        TVE_IntegUtility.CreateInteTask(recordMap,creatIntTaskMap); 
		 
	}

	@isTest static void testMethod1() {
		User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];

		WorkOrderSets__x mockedWO1 = new WorkOrderSets__x(
                            StartDate__c = '1382166999',
                            FinishDate__c = '1382166999',
                            SystemStatus__c = 'Success',
            				OrderNumber__c = '222222'
		);

		WorkOrderSets__x mockedWO2 = new WorkOrderSets__x(
                            StartDate__c = '1382166999',
                            FinishDate__c = '1382166999',
                            SystemStatus__c = 'Success',
            				OrderNumber__c = '222222'
		);

		TVE_SAPInteg_GetWorkOrderToSAP.mockedExtWO.add(mockedWO1);
		TVE_SAPInteg_GetWorkOrderToSAP.mockedExtWO.add(mockedWO2);

		TVE_SAPInteg_GetWorkOrderToSAP getWO =  new TVE_SAPInteg_GetWorkOrderToSAP();       
            system.runas(testUser){                        
                System.enqueueJob(getWO);
			}  
			
	}
    @isTest static void testMethod2() {
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        WorkOrderSets__x mockedWO1 = new WorkOrderSets__x(
            StartDate__c = '34535',
            FinishDate__c = '1382166999',
            SystemStatus__c = 'Success',
            OrderNumber__c = '222222'
        );
        
        WorkOrderSets__x mockedWO2 = new WorkOrderSets__x(
            StartDate__c = '4543545',
            FinishDate__c = '1382166999',
            SystemStatus__c = 'Success',
            OrderNumber__c = '222222'
        );
        
        TVE_SAPInteg_GetWorkOrderToSAP.mockedExtWO.add(mockedWO1);
        TVE_SAPInteg_GetWorkOrderToSAP.mockedExtWO.add(mockedWO2);
        
        TVE_SAPInteg_GetWorkOrderToSAP getWO =  new TVE_SAPInteg_GetWorkOrderToSAP();       
        system.runas(testUser){                        
            System.enqueueJob(getWO);
        }  
        
    }
}