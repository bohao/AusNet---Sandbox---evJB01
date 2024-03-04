/*
  @author  : harshad.kumbhar@ausnetservices.com.au
  @created : 04 Mar 2020
  @Description : Test Class for Get CM to SAP system
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/

@isTest
private class TVE_SAPInteg_GetCMToSAPTest{

	public static final string testUserEmail = 'testuser@TVECustomerDetailsSAP.com';
    public static final string CON_TYPE = 'IDIC';
	public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
	public  static String CM_RT   = 'Project';
    private static Id  CM_RTId = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByDeveloperName().get(CM_RT).getRecordTypeId();
  
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
		lstProj[0].ProjectName__c = 'ProjTest';				
		lstProj[0].CMNumber__c = '11111';				
		lstProj[0].PlaningPermitNumber__c = 'AAA';
		lstProj[0].SpearReferenceNumber__c ='34324';
		lstProj[0].SubdivisionPlanNumber__c = '4343';
		lstProj[0].Subdivision__c = 'Yes';
		lstProj[0].ACCC_Form__c = 'Yes';
		lstProj[0].CRAB_Form__c = 'No';
		lstProj[0].SAPStatus__c = 'PREQ';
		lstProj[0].SAPStatusFlag__c = 'CLSE';
		lstProj[0].ContestabilityType__c = 'IDIC';
		lstProj.add(TVE_TestUtility.createProject('test1',PROGRESS_BAR_STATUS,CON_TYPE));
		lstProj[1].ProjectName__c = 'ProjTest1';	
		lstProj[1].CMNumber__c = '22222';	
		lstProj[1].ContestabilityType__c = 'IDIC';
		lstProj[1].PlaningPermitNumber__c = 'AAA';
		lstProj[1].SpearReferenceNumber__c ='34324';
		lstProj[1].SubdivisionPlanNumber__c = 'dsdsf';
		lstProj[1].Subdivision__c = 'No';
		lstProj[1].ACCC_Form__c = 'No';
		lstProj[1].CRAB_Form__c = 'Yes';
		lstProj[1].SAPStatus__c = 'PRLP';
		lstProj[1].SAPStatusFlag__c = 'CLSE';
		Insert lstProj;
        
		Map<Id,String> recordMap = new Map<Id,String>(); 
		for (Project__c proj : lstProj) {
			recordMap.put(Proj.id, Proj.id);	
		}        
        Map<String,String> creatIntTaskMap = new Map<String,String>();
        creatIntTaskMap.put('Operation__c', 'Get');
        creatIntTaskMap.put('SObject__c', 'Project__c');       
        creatIntTaskMap.put('Type__c', 'GetCM');
		creatIntTaskMap.put('Status__c', 'In Progress');        
		creatIntTaskMap.put('RecordTypeID', CM_RTId);        
        TVE_IntegUtility.CreateInteTask(recordMap,creatIntTaskMap); 
		 
	}

	@isTest static void testMethod1() {
		User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];

		ConstructionMeasureSets__x mockedCM1 = new ConstructionMeasureSets__x(
							Cmnum__c = '11111',
							Cmtxt__c = 'Test',
							ZzPrjOfficer__c = 'ABC',
							ZzContestability__c = 'IDIC',
							ZzTownPermit__c = 'xxx',
							ZzLodgeSpear__c = 'DEF',
							ZzSubdivision__c = 'Y',
							ZzSubDivi__c = 'Y',
							ZzAccc__c = 'N',
							ZzCrab__c = 'Y',
							UserStatus__c = 'CLSE CERC CERE PPRC'
		);

		ConstructionMeasureSets__x mockedCM2 = new ConstructionMeasureSets__x(
							Cmnum__c = '22222',
							Cmtxt__c = 'Test',
							ZzPrjOfficer__c = 'ABC',
							ZzContestability__c = 'IDIC',
							ZzTownPermit__c = 'xxx',
							ZzLodgeSpear__c = 'DEF',
							ZzSubdivision__c = 'Y',
							ZzSubDivi__c = 'Y',
							ZzAccc__c = 'N',
							ZzCrab__c = 'Y',
							UserStatus__c = 'CLSE'
		);

		TVE_SAPInteg_GetCMToSAP.mockedExtCM.add(mockedCM1);
		TVE_SAPInteg_GetCMToSAP.mockedExtCM.add(mockedCM2);

		TVE_SAPInteg_GetCMToSAP getCM =  new TVE_SAPInteg_GetCMToSAP();       
            system.runas(testUser){                        
                System.enqueueJob(getCM);
			}  
			
	}

	@isTest static void testMethod2() {
		User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];

		ConstructionMeasureSets__x mockedCM1 = new ConstructionMeasureSets__x(
							Cmnum__c = '55555',
							Cmtxt__c = 'Test11',
							ZzPrjOfficer__c = 'ABC',
							ZzContestability__c = 'IDIC',
							ZzTownPermit__c = 'xxx',
							ZzLodgeSpear__c = 'DEF',
							ZzSubdivision__c = 'Y',
							ZzSubDivi__c = 'Y',
							ZzAccc__c = 'N',
							ZzCrab__c = 'Y',
							UserStatus__c = 'CLSE CERC CERE PPRC'
		);

		ConstructionMeasureSets__x mockedCM2 = new ConstructionMeasureSets__x(
							Cmnum__c = '44444',
							Cmtxt__c = 'Test22',
							ZzPrjOfficer__c = 'ABC',
							ZzContestability__c = 'IDIC',
							ZzTownPermit__c = 'xxx',
							ZzLodgeSpear__c = 'DEF',
							ZzSubdivision__c = 'Y',
							ZzSubDivi__c = 'Y',
							ZzAccc__c = 'N',
							ZzCrab__c = 'Y',
							UserStatus__c = 'CLSE'
		);

		TVE_SAPInteg_GetCMToSAP.mockedExtCM.add(mockedCM1);
		TVE_SAPInteg_GetCMToSAP.mockedExtCM.add(mockedCM2);

		TVE_SAPInteg_GetCMToSAP getCM =  new TVE_SAPInteg_GetCMToSAP();       
            system.runas(testUser){                        
                System.enqueueJob(getCM);
			}  
			
	}

	@isTest static void testMethod3() {
		User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];

		ConstructionMeasureSets__x mockedCM1 = new ConstructionMeasureSets__x(
							Cmnum__c = '99999',
							Cmtxt__c = 'Test1',
							ZzPrjOfficer__c = 'ABC',
							ZzContestability__c = 'Invoice',
							ZzTownPermit__c = 'xxx',
							ZzLodgeSpear__c = 'DEF',
							ZzSubdivision__c = 'Y',
							ZzSubDivi__c = 'Y',
							ZzAccc__c = 'N',
							ZzCrab__c = 'Y',
							UserStatus__c = 'CLSE CERC CERE PPRC'
		);

		ConstructionMeasureSets__x mockedCM2 = new ConstructionMeasureSets__x(
							Cmnum__c = '88888',
							Cmtxt__c = 'Test1',
							ZzPrjOfficer__c = 'ABC',
							ZzContestability__c = 'Invoice',
							ZzTownPermit__c = 'xxx',
							ZzLodgeSpear__c = 'DEF',
							ZzSubdivision__c = 'Y',
							ZzSubDivi__c = 'Y',
							ZzAccc__c = 'N',
							ZzCrab__c = 'Y',
							UserStatus__c = 'CLSE'
		);

		TVE_SAPInteg_GetCMToSAP.mockedExtCM.add(mockedCM1);
		TVE_SAPInteg_GetCMToSAP.mockedExtCM.add(mockedCM2);

		TVE_SAPInteg_GetCMToSAP getCM =  new TVE_SAPInteg_GetCMToSAP();       
            system.runas(testUser){                        
                System.enqueueJob(getCM);
			}  
			
	}

}