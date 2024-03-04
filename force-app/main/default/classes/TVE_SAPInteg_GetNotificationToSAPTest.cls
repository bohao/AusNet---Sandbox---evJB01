/*
  @author  : harshad.kumbhar@ausnetservices.com.au
  @created : 09 Mar 2020
  @Description : Test Class for Get PM Notificatio to SAP system
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
@isTest
private class TVE_SAPInteg_GetNotificationToSAPTest{

	public static final string testUserEmail = 'testuser@TVECustomerDetailsSAP.com';
    public static final string CON_TYPE = 'IDIC';
	public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
	public  static String Opp_RT   = 'Opportunity';
    private static Id  OPP_RTId = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByDeveloperName().get(Opp_RT).getRecordTypeId();
    

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
        
        List<Opportunity> lstOpp = new List<Opportunity>();
        lstOpp.add(TVE_TestUtility.createOpportunityType(lstProj[0].Id,testAccount.Id,'Construction'));
        lstOpp[0].Notification_Number__c = '222222';
        Insert lstOpp;
		
        
		Map<Id,String> recordMap = new Map<Id,String>(); 
		for (Opportunity opp : lstOpp) {
			recordMap.put(opp.id, opp.id);	
		}        
        Map<String,String> creatIntTaskMap = new Map<String,String>();
        creatIntTaskMap.put('Operation__c', 'Get');
        creatIntTaskMap.put('SObject__c', 'Opportunity');       
        creatIntTaskMap.put('Type__c', 'GetConstNoti');
		creatIntTaskMap.put('Status__c', 'In Progress');  
		creatIntTaskMap.put('RecordTypeID', OPP_RTId);         
		TVE_IntegUtility.CreateInteTask(recordMap,creatIntTaskMap); 
		
	}

    @isTest static void testMethod1() {
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        PMNotificationSets__x mockedPMNoti1 = new PMNotificationSets__x(
            RequiredEndDate__c = '1382166999',                            
            SystemStatus__c = 'Success',
            NotificationNumber__c = '222222'
        );
        
        PMNotificationSets__x mockedPMNoti2 = new PMNotificationSets__x(
            RequiredEndDate__c = '1382166999',                         
            SystemStatus__c = 'Success',
            NotificationNumber__c = '222222'
        );
        
        TVE_SAPInteg_GetNotificationToSAP.mockedExtPMNoti.add(mockedPMNoti1);
        TVE_SAPInteg_GetNotificationToSAP.mockedExtPMNoti.add(mockedPMNoti2);
        
        TVE_SAPInteg_GetNotificationToSAP getPMNoti =  new TVE_SAPInteg_GetNotificationToSAP();       
        system.runas(testUser){                        
            System.enqueueJob(getPMNoti);
        }  
    }

    @isTest static void testMethod2() {
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        PMNotificationSets__x mockedPMNoti1 = new PMNotificationSets__x(
            RequiredEndDate__c = 'hghjgj',                            
            SystemStatus__c = 'Success',
            NotificationNumber__c = '222222'
        );
        
        PMNotificationSets__x mockedPMNoti2 = new PMNotificationSets__x(
            RequiredEndDate__c = 'hjhgjh',                         
            SystemStatus__c = 'Success',
            NotificationNumber__c = '222222'
        );
        
        TVE_SAPInteg_GetNotificationToSAP.mockedExtPMNoti.add(mockedPMNoti1);
        TVE_SAPInteg_GetNotificationToSAP.mockedExtPMNoti.add(mockedPMNoti2);
        
        TVE_SAPInteg_GetNotificationToSAP getPMNoti =  new TVE_SAPInteg_GetNotificationToSAP();       
        system.runas(testUser){                        
            System.enqueueJob(getPMNoti);
        }  
    }
    
    @isTest static void testMethod3() {
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        PMNotificationSets__x mockedPMNoti1 = new PMNotificationSets__x();
        TVE_SAPInteg_GetNotificationToSAP.mockedExtPMNoti.add(mockedPMNoti1);
        
        TVE_SAPInteg_GetNotificationToSAP getPMNoti =  new TVE_SAPInteg_GetNotificationToSAP();       
        system.runas(testUser){                        
            System.enqueueJob(getPMNoti);
        }  
    }


}