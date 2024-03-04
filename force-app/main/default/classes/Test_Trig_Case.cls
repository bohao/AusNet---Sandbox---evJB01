/*
@author  : vaughan.crole@ausnetservices.com.au
@created : 17 Sep 2019
@Description : Test Class for Case Triggers
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
@isTest
private class Test_Trig_Case
{
	public  static String Case_RT   = 'DER_App_Manual';
	public  static String Dev_RT   = 'Device_L2';
	public  static String Asset_RT   = 'Asset_DER_L2';
	public  static String derIssue_RT   = 'Exception';
	private static Id     Case_RTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Case_RT).getRecordTypeId();
	private static Id derIssue_RTID = Schema.SObjectType.DER_Issue__c.getRecordTypeInfosByDeveloperName().get(derIssue_RT).getRecordTypeId();
	private static Id  Dev_RTId = Schema.SObjectType.Device__c.getRecordTypeInfosByDeveloperName().get(Dev_RT).getRecordTypeId();
	private static Id  Asset_RTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Asset_RT).getRecordTypeId();
	private static String custEmailNotifLogic = 'customer@test12345.com';
	private static String NMI_NUMBER = '63050119176';
	private static String NMI_NUMBER_1 = '63050119175';
	private static String SERIAL_NUM = '1234';
	private static String SERIAL_NUM_1 = '1235';
	private static String TYPE_CODE = 'TEST';
	private static String repEmail = 'rep@test12345.com';

	@testSetup static void setup()
	{
		Case testCase = new Case(
			Subject = 'New Case',
			Origin = 'Web',
			RecordTypeId = Case_RTId,
			Invoice_Number__c = '12345'
		);
		insert testCase;

		System.assertNotEquals(null, testCase.Id, 'Failed to insert testCase');

		// ------------------------------------------------------------- //
		// -------- Data setup for Notification field: Start------------ //
		// ------------------------------------------------------------ //

		//Create Individual Account
		Account testCustomer = DER_TestUtility.createPersonAccount('Person Account', 'test@test12345.com');
		insert testCustomer;


		//Create Connection Point
		Connection_Point__c testConnectionPoint = DER_TestUtility.createConnectionPoint(testCustomer.Id);
		Insert testConnectionPoint;

		DER_Application__c testDERApp = DER_TestUtility.createDERApplication(testConnectionPoint.Id);
		Insert testDERApp;

		//Create Business Account
		Account testInstaller = DER_TestUtility.createBusinessAccount('Business Account');
		insert testInstaller;

		//Create Business Account's Contact
		Contact testInstallerContact = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Installer', custEmailNotifLogic);
		insert testInstallerContact;

		//Create Business Account
		Account testRepAcc = DER_TestUtility.createBusinessAccount('Representative Business Account');
		insert testRepAcc;

		//Create Business Account's Contact
		Contact testRep = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Representative', 'representative@test12345.com');
		insert testRep;

		//Create case with customer, installer & representative
		Case testCaseNotifLogic = DER_TestUtility.createCaseWith_Installer_Customer_Rep(testDERApp.Id,
																						DER_REST_Application_v1.CASE_RECORDTYPE_MANUAL,
																						'New', 'Email', 'Medium',
																						testInstaller.Id, testInstallerContact.Id,
																						testCustomer.Id, testRep.Id,
																						Trig_Case.APPLICANT_REP, Trig_Case.RESP_PARTY_REP);
		insert testCaseNotifLogic;

		// -------- Data setup for Notification field: End ------------ //

	}

	@isTest static void testSetCaseSubject()
	{
		String AppNumber;
		Case assertCase;

		// * Positive test
		Case testCase = new Case(
			Subject = null,
			Origin = 'Web',
			RecordTypeId = Case_RTId,
			Invoice_Number__c = '12345'
		);
		insert testCase;
		test.startTest();
		Case caseObj = [select id from case where id=: testCase.Id];
		assertCase = (Case)UtilDatabase.getRecord(caseObj.Id);

		// test app number formula
		AppNumber = assertCase.Application_Number__c;
		// System.assertEquals(AppNumber, 'CA1' + assertCase.CaseNumber + 'A');

		// test trigger
		System.assertEquals(assertCase.Subject, AppNumber);

		// test positive update trigger
		update caseObj;
		assertCase = (Case)UtilDatabase.getRecord(caseObj.Id);
		System.assertEquals(assertCase.Subject, AppNumber);

		// Test do not update (subject not null)
		caseObj.Subject = 'Subject 2';
		update caseObj;

		assertCase = (Case)UtilDatabase.getRecord(caseObj.Id);
		System.assertEquals(assertCase.Subject, 'Subject 2');

		// Test do not update (wrong RT)
		Trig_Case.CaseSubject_AllowedRTs.remove(Case_RT);
		caseObj.Subject = 'Subject 3';
		update caseObj;

		assertCase = (Case)UtilDatabase.getRecord(caseObj.Id);
		System.assertEquals(assertCase.Subject, 'Subject 3');
		Trig_Case.CaseSubject_AllowedRTs.add(Case_RT);

		// Test do not update (Apex trig disabled)
		Trig_Case.TrigDisabled = true;
		caseObj.Subject = null;
		update caseObj;
        
		assertCase = (Case)UtilDatabase.getRecord(caseObj.Id);
		System.assertEquals(assertCase.Subject, null);
		Trig_Case.TrigDisabled = false;

		// Test do not update (custom setting trig disabled)
		TrigSettings__c trigSet = new TrigSettings__c();
		trigSet.Case_Trigger_Disabled__c = true;
		trigSet.SetupOwnerId = UserInfo.getOrganizationId();
		insert trigSet;

		caseObj.Subject = null;
		update caseObj;

		assertCase = (Case)UtilDatabase.getRecord(caseObj.Id);
		test.stopTest();
		System.assertEquals(assertCase.Subject, null);

		delete caseObj;
		undelete caseObj;
	}

	@isTest static void testDerDefaultPlaceHolder()
	{
		List<Device__c> devList = new List<Device__c>();

		DER_Default__c derDef = new DER_Default__c();
		derDef.Field__c = 'DRED_Enabled__c';
		derDef.Object__c = 'Device__c';
		derDef.Equip_Inverter__c = true;
		derDef.Offer_MSO__c = true;
		derDef.Value__c = 'No';
		insert derDef;

		DER_Default__c derDef0 = new DER_Default__c();
		derDef0.Field__c = 'DRED_Enabled__c';
		derDef0.Object__c = 'Device__c';
		derDef0.Equip_Non_Inverter__c = true;
		derDef0.Offer_MSO__c = true;
		derDef0.Value__c = 'No';
		insert derDef0;

		DER_Default__c def = new DER_Default__c();
		def.Field__c = 'DRED_Enabled__c';
		def.Object__c = 'Device__c';
		def.Equip_Non_Inverter__c = true;
		def.Offer_Neg_0__c = true;
		def.Value__c = 'No';
		insert def;

		DER_Default__c def1 = new DER_Default__c();
		def1.Field__c = 'DRED_Enabled__c';
		def1.Object__c = 'Device__c';
		def1.Equip_Inverter__c = true;
		def1.Offer_Neg_0__c = true;
		def1.Value__c = 'No';
		insert def1;

		DER_Default__c derDef1 = new DER_Default__c();
		derDef1.Field__c = 'Under_Freq_Protection__c';
		derDef1.Object__c = 'DER_Application__c';
		derDef1.Equip_Non_Inverter__c = true;
		derDef1.Offer_Neg_0__c = true;
		derDef1.Value__c = '47.5';
		insert derDef1;

		DER_Default__c derDef2 = new DER_Default__c();
		derDef2.Field__c = 'Over_Freq_Protection__c';
		derDef2.Object__c = 'DER_Application__c';
		derDef2.Equip_Inverter__c = true;
		derDef2.Offer_Neg_0__c = true;
		derDef2.Value__c = '52';
		insert derDef2;

		DER_Application__c derApp = new DER_Application__c();
		derApp.Central_Protection_Control__c = 'Yes';
		insert derApp;

		DER_Application__c derAppnew = new DER_Application__c();
		derAppnew.Central_Protection_Control__c = 'Yes';
		insert derAppnew;

		DER_Application__c derApp0 = new DER_Application__c();
		derApp0.Central_Protection_Control__c = 'Yes';
		insert derApp0;

		DER_Application__c derAppnew0 = new DER_Application__c();
		derAppnew0.Central_Protection_Control__c = 'Yes';
		insert derAppnew0;

		Device__c dev = new Device__c();
		dev.DER_Application__c = derApp.Id;
		dev.AC_Equip_Type__c = 'Inverter';
		dev.RecordTypeId = Dev_RTId;
		dev.AC_Equip_Sub_Type__c = 'Solar';
		dev.Inv_Volt_Watt_Response_Mode__c = 'Enabled';

		insert dev;


		Device__c dev1 = new Device__c();
		dev1.DER_Application__c = derApp0.Id;
		dev1.AC_Equip_Type__c = 'Non-Inverter';
		dev1.RecordTypeId = Dev_RTId;
		dev1.AC_Equip_Sub_Type__c = 'Solar';


		insert dev1;

		Device__c dev2 = new Device__c();
		dev2.DER_Application__c = derAppnew.Id;
		dev2.AC_Equip_Type__c = 'Non-Inverter';
		dev2.RecordTypeId = Dev_RTId;
		dev2.AC_Equip_Sub_Type__c = 'Solar';


		insert dev2;

		Device__c devn = new Device__c();
		devn.DER_Application__c = derAppnew0.Id;
		devn.AC_Equip_Type__c = 'Inverter';
		devn.RecordTypeId = Dev_RTId;
		devn.AC_Equip_Sub_Type__c = 'Solar';
		devn.Inv_Volt_Watt_Response_Mode__c = 'Enabled';
		insert devn;

		test.startTest();
		Case c =  new Case();
		c.DER_Application__c = derApp.Id;
		c.RecordTypeId = Case_RTId;
		c.Agreement_Type__c = 'Basic Micro EG MSO';
		c.Invoice_Number__c = '12345';
		insert c;

		Case cnew =  new Case();
		cnew.DER_Application__c = derAppnew.Id;
		cnew.RecordTypeId = Case_RTId;
		cnew.Agreement_Type__c = 'Negotiated >5MW NEA';
		cnew.Invoice_Number__c = '12345';
		insert cnew;

		Case c1n =  new Case();
		c1n.DER_Application__c = derApp0.Id;
		c1n.RecordTypeId = Case_RTId;
		c1n.Agreement_Type__c = 'Basic Micro EG MSO';
		c1n.Invoice_Number__c = '12345';
		insert c1n;

		Case cnew1 =  new Case();
		cnew1.DER_Application__c = derAppnew0.Id;
		cnew1.RecordTypeId = Case_RTId;
		cnew1.Agreement_Type__c = 'Negotiated >5MW NEA';
		cnew1.Invoice_Number__c = '12345';
		insert cnew1;
		test.stopTest();


	}

	@isTest static void testderDefaultsWhenDeviceInserted()
	{
		List<Device__c> devList2 = new List<Device__c>();
		test.startTest();
		DER_Application__c derApp1 = new DER_Application__c();
		insert derApp1;

		Case c1 =  new Case();
		c1.DER_Application__c = derApp1.Id;
		c1.RecordTypeId = Case_RTId;
		c1.Agreement_Type__c = 'Negotiated >5MW NEA';
		c1.Invoice_Number__c = '12345';
		insert c1;

		DER_Application__c derApp2 = new DER_Application__c();
		insert derApp2;

		Case c2 =  new Case();
		c2.DER_Application__c = derApp2.Id;
		c2.RecordTypeId = Case_RTId;
		c2.Agreement_Type__c = 'Basic Micro EG MSO';
		c2.Invoice_Number__c = '12345';
		insert c2;

		Device__c dev3 = new Device__c();
		dev3.DER_Application__c = derApp1.Id;
		dev3.AC_Equip_Type__c = 'Inverter';
		dev3.RecordTypeId = Dev_RTId;
		dev3.AC_Equip_Sub_Type__c = 'Solar';
		devList2.add(dev3);


		Device__c dev4 = new Device__c();
		dev4.DER_Application__c = derApp1.Id;
		dev4.AC_Equip_Type__c = 'Non-Inverter';
		dev4.AC_Equip_Sub_Type__c = 'Solar';
		dev4.RecordTypeId = Dev_RTId;
		devList2.add(dev4);


		Device__c dev7 = new Device__c();
		dev7.DER_Application__c = derApp2.Id;
		dev7.AC_Equip_Type__c = 'Inverter';
		dev7.AC_Equip_Sub_Type__c = 'Solar';
		dev7.RecordTypeId = Dev_RTId;
		devList2.add(dev7);

		Device__c dev8 = new Device__c();
		dev8.DER_Application__c = derApp2.Id;
		dev8.AC_Equip_Type__c = 'Non-Inverter';
		dev8.AC_Equip_Sub_Type__c = 'Solar';
		dev8.RecordTypeId = Dev_RTId;
		devList2.add(dev8);


		insert devList2;
		test.stopTest();
	}

	@isTest static void testAssetTrigger()
	{
			DER_Submission_Settings__c setting = new DER_Submission_Settings__c();
			setting.Batch_Size__c = 2;
			setting.Domain__c = 'https://cadeaidev.ausnetservices.com.au:5443';
			setting.Endpoint__c = 'devder/submitDERSvc';
			setting.Certificate_Name__c = 'eains';
			insert setting;

			//Create Individual Account
			Account testCustomer = DER_TestUtility.createPersonAccount('Person Account', 'test@test12345.com');
			insert testCustomer;


			//Create Connection Point
			Connection_Point__c testConnectionPoint = (Connection_Point__c) UtilDatabase.getRecord([SELECT Id FROM Connection_Point__c LIMIT 1].Id);


			DER_Application__c testDERApp = DER_TestUtility.createDERApplication(testConnectionPoint.Id);
			Insert testDERApp;

			//Create Business Account
			Account testInstaller = DER_TestUtility.createBusinessAccount('Business Account');
			insert testInstaller;

			//Create Business Account's Contact
			Contact testInstallerContact = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Installer', 'test@test12345.com');
			insert testInstallerContact;
			//Create case for Customer
			Case testCaseForCustomer = DER_TestUtility.createCaseForCustomer(testDERApp.Id,
																			DER_REST_Application_v1.CASE_RECORDTYPE_AUTO,
																			'New', 'Email', 'Medium', testCustomer.Id);
			insert testCaseForCustomer;
			//Create Device1
			Device__c testDevice = DER_TestUtility.createDevice(testDERApp.Id);
			testDevice.Installed__c = true;
			Insert testDevice;

			//Create Device2
			Device__c testDevice2 = DER_TestUtility.createDevice(testDERApp.Id);
			testDevice2.Installed__c = true;
			Insert testDevice2;
			List<Case> caseList = new List<Case>();
			List<Case> caseListToUpdate = new List<Case>();
			Case testCase = DER_TestUtility.createCaseForCustomer(testDERApp.Id,
																DER_REST_Application_v1.CASE_RECORDTYPE_AUTO,
																'New', 'Email', 'Medium', testCustomer.Id);
			testCase.AccountId = testInstaller.Id;
			testCase.ContactId = testInstallerContact.Id;
			testCase.Invoice_Number__c = '12345';
			caseList.add(testCase);
			insert caseList;

		test.startTest();
			Asset asset1 = new Asset();
			asset1.RecordTypeId = Asset_RTId;
			asset1.Conn_Point__c = testConnectionPoint.Id;
			asset1.Name = 'test';
			insert asset1;
		test.stopTest();
	}

	@isTest static void testgetValidCasesForAemo()
	{
		test.startTest();
			DER_Submission_Settings__c setting = new DER_Submission_Settings__c();
			setting.Batch_Size__c = 2;
			setting.Domain__c = 'https://cadeaidev.ausnetservices.com.au:5443';
			setting.Endpoint__c = 'devder/submitDERSvc';
			setting.Certificate_Name__c = 'eains';
			insert setting;

			//Create Individual Account
			Account testCustomer = DER_TestUtility.createPersonAccount('Person Account', 'test@test12345.com');
			insert testCustomer;


			//Create Connection Point
			Connection_Point__c testConnectionPoint = (Connection_Point__c) UtilDatabase.getRecord([SELECT Id FROM Connection_Point__c LIMIT 1].Id);


			DER_Application__c testDERApp = DER_TestUtility.createDERApplication(testConnectionPoint.Id);
			Insert testDERApp;

			// (Id derAppId, Id installerAccId, String agmtStatus, Date offerAccptDate, Date offerMadeDate, String offerType){
			DER_Agreement__c agr = DER_TestUtility.createAgreement(testDERApp.Id, testCustomer.id, 'Contract Active', System.today(), System.today(), 'Basic Micro EG MSO');
			insert agr;

			//Create Business Account
			Account testInstaller = DER_TestUtility.createBusinessAccount('Business Account');
			insert testInstaller;

			//Create Business Account's Contact
			Contact testInstallerContact = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Installer', 'test@test12345.com');
			insert testInstallerContact;
			//Create case for Customer
			Case testCaseForCustomer = DER_TestUtility.createCaseForCustomer(testDERApp.Id,
																			DER_REST_Application_v1.CASE_RECORDTYPE_AUTO,
																			'New', 'Email', 'Medium', testCustomer.Id);
			insert testCaseForCustomer;

			//Create Device1
			Device__c testDevice = DER_TestUtility.createDevice(testDERApp.Id);
			testDevice.RecordTypeId = UtilDatabase.getRecordTypeNames('Device__c').get('Device_L2');
			testDevice.Installed__c = true;
			System.assert(testDevice.RecordTypeId != null, 'Record Type not found.');
			insert testDevice;

			//Create Device2
			Device__c testDevice2 = DER_TestUtility.createDevice(testDERApp.Id);
			testDevice2.RecordTypeId = UtilDatabase.getRecordTypeNames('Device__c').get('Device_L2');
			testDevice2.Installed__c = true;
			System.assert(testDevice.RecordTypeId != null, 'Record Type not found.');
			insert testDevice2;

			List<Case> caseList = new List<Case>();
			List<Case> caseListToUpdate = new List<Case>();
			Case testCase = DER_TestUtility.createCaseForCustomer(testDERApp.Id,
																DER_REST_Application_v1.CASE_RECORDTYPE_AUTO,
																'New', 'Email', 'Medium', testCustomer.Id);
			testCase.Submission_Status__c = 'Ready To Submit';
			testCase.AccountId = testInstaller.Id;
			testCase.Status = 'Publish';
			testCase.ContactId = testInstallerContact.Id;
			testCase.Invoice_Number__c = '12345';
			testCase.Contract_Status__c = agr.Status__c;
			testCase.Contract_Active_Date__c = agr.Contract_Active_Date__c;
			caseList.add(testCase);
			insert caseList;


			DER_Issue__c derissue = new Der_Issue__c();
			derissue.Name = '000001';
			derissue.Case__c = testCase.id;
			derissue.RecordTypeId = derIssue_RTID;
			derissue.AEMO_Connection_ID__c = 'Exception001';
			insert derissue;

			testCase.Submission_Status__c = null;
			update testCase;
			testCase.Submission_Status__c = 'Ready To Submit';

			caseListToUpdate.add(testCase);

			update caseListToUpdate;
			testCase.Submission_Status__c = 'Submitted Successfully';
			update testCase;

			testCase.Status = 'Complete';
			update testCase;
		test.stopTest();
	}

	@isTest static void teststatusChangeAndURLUpdate()
	{
		//Create Individual Account
		eSignSettings__c eSignObj = eSignSettings__c.getInstance();
		eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
		insert eSignObj;
		Account testCustomer = new Account();
		testCustomer.Name = 'test';
        testCustomer.ABN__c = DER_TestUtility.getUniqueABN();
		insert testCustomer;
		DER_Application__c testDERApp = new DER_Application__c();
		UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = false;
		insert testDERApp;
		test.startTest();
		Device__C deviceObj = DER_TestUtility.createDevice_L2(testDERApp.Id);
		deviceObj.Device_Phase__c = 'A';
		deviceObj.AC_Equip_Cap__c = 10;
		deviceObj.Requested__c = true;
		deviceObj.Approved__c = true;
		UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = false;
		insert deviceObj;
		Device__c dev = (Device__c)UtilDatabase.getRecord(deviceObj.Id);
		DER_Agreement__c agr = DER_TestUtility.createAgreement(testDERApp.Id,testCustomer.id,null,null,null,null);
		agr.status__c = 'Offer Expired';
		insert agr;

		Contact instCont = DER_TestUtility.createBusinessAccountContact(testCustomer.Id, 'Test', 'Test', 'test@derapp1212121.com');
		insert instCont;

		Case testCaseForCustomer = DER_TestUtility.createCaseForInstaller(DER_REST_Application_v1.CASE_RECORDTYPE_MANUAL, 'New', 'Email', 'Low', testCustomer.Id, instCont.Id);
		testCaseForCustomer.Agreement_Type__c = 'Basic Micro EG MSO';
		testCaseForCustomer.DER_Application__c = testDERApp.Id;
		testCaseForCustomer.Send_DER_Offer__c = false;
		testCaseForCustomer.Invoice_Number__c = '123456';
		insert testCaseForCustomer;
		deviceObj.Requested__c = true;
		deviceObj.Approved__c = true;
		deviceObj.AC_Equip_Cap__c = 20;
		UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = false;
		update deviceObj;
		test.stopTest();

		DER_Application__c app = (DER_Application__c)UtilDatabase.getRecord(testDERApp.Id);
		System.assertEquals(deviceObj.AC_Equip_Cap__c, app.Total_New_Capacity__c);
		testCaseForCustomer.Send_DER_Offer__c = true;
		update testCaseForCustomer;

	}
    
    
    @isTest static void teststatusFEChangeAndURLUpdate()
	{
		
		Account testCustomer = new Account();
		testCustomer.Name = 'test';
        testCustomer.ABN__c = DER_TestUtility.getUniqueABN();
		insert testCustomer;
		DER_Application__c testDERApp = new DER_Application__c();
		UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = false;
		insert testDERApp;
		test.startTest();
		Device__C deviceObj = DER_TestUtility.createDevice_L2(testDERApp.Id);
		deviceObj.Device_Phase__c = 'A';
		deviceObj.AC_Equip_Cap__c = 10;
		deviceObj.Requested__c = true;
		deviceObj.Approved__c = true;
		UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = false;
		insert deviceObj;
		Device__c dev = (Device__c)UtilDatabase.getRecord(deviceObj.Id);
		DER_Agreement__c agr = DER_TestUtility.createAgreement(testDERApp.Id,testCustomer.id,null,null,null,null);
		agr.status__c = 'Offer Expired';
		insert agr;

		Contact instCont = DER_TestUtility.createBusinessAccountContact(testCustomer.Id, 'Test', 'Test', 'test@derapp1212121.com');
		insert instCont;
		
		String recordTypeDeveloperName = DER_REST_Application_v1.CASE_RECORDTYPE_MANUAL;
		Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
        Case testCaseForCustomerFE =   new Case(
            Status = 'New',
            RecordTypeId = caseRTId,
            Origin = 'Web',
            Priority = 'Low',
            AccountId = testCustomer.Id,
            ContactId = instCont.Id,
            Invoice_Number__c = '12345',Agreement_Type__c = 'Basic Micro EG MSO', 
            FE_Is_Flexible_Export_Assessment_Opt_in__c = true, Send_DER_Offer__c = false,
			DER_Application__c = testDERApp.Id );

		insert testCaseForCustomerFE;		
		eSignSettings__c eSignObj = eSignSettings__c.getInstance();
		eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
		insert eSignObj;
		deviceObj.Requested__c = true;
		deviceObj.Approved__c = true;
		deviceObj.AC_Equip_Cap__c = 20;
		UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = false;
		update deviceObj;
        
        testCaseForCustomerFE.Send_DER_Offer__c = true;
		update testCaseForCustomerFE;
		test.stopTest();
        
        DER_Application__c app = (DER_Application__c)UtilDatabase.getRecord(testDERApp.Id);
		System.assertEquals(deviceObj.AC_Equip_Cap__c, app.Total_New_Capacity__c);
		

	}
	@isTest static void testCaseMatchingUpdate()
	{
		User testUser = UtilDatabase_Test.getTestUser();

		Connection_Point__c conPoint = [SELECT Id, NMI__c FROM Connection_Point__c limit 1];
		NmiDataSets__x testExtNMI = DER_TestUtility.createEXTNMI(NMI_NUMBER_1);
		Trig_Case.mockedExtNMI.add(testExtNMI);
		conPoint.NMI__c = NMI_NUMBER_1;
		update conPoint;
		DER_Application__c derApp = [SELECT Id, Meter_Number__c , NMI__c
									 FROM DER_Application__c
									 LIMIT 1];
		derApp.Meter_Number__c = SERIAL_NUM_1;
		update derApp;
		derApp.NMI__c = conPoint.Id;
		update derApp;

		Case derCase = (Case)UtilDatabase.getRecord([SELECT Id FROM Case WHERE ContactEmail =: custEmailNotifLogic LIMIT 1].Id);
		derCase.DER_Application__c = derApp.Id;
		derCase.Status = 'New';
		update derCase;

		DER_Application__c derApp1 = [SELECT Id,NMI__c, Meter_Number__c
									  FROM DER_Application__c
									  LIMIT 1];
		derApp1.NMI__c = conPoint.Id;
		derApp1.Meter_Number__c = SERIAL_NUM_1;
		update derApp1;
		Case derCase1 = [select id,Status,DER_Application__c from Case where ContactEmail =: custEmailNotifLogic limit 1];
		derCase1.DER_Application__c = derApp1.Id;
		derCase1.Status = 'New';
		update derCase1;
		test.startTest();
		derCase1.Status = Trig_Case.CASE_STATUS_COMPLETE;
		update derCase1;
		Case caseObj = [select id,Status,Cancelled_Reason__c from Case where id=: derCase.Id];
		//system.assertEquals('Cancelled', caseObj.Status);
		//system.assertEquals('Applicant Declined',caseObj.Cancelled_Reason__c);
		test.stopTest();

	}

	@isTest static void test_applicant_type_INSTALLER()
	{
		String queryCase = '';
		queryCase += UtilDatabase.getAllFields('Case');
		queryCase += ' FROM Case ';
		queryCase += ' WHERE ContactEmail =\''+ custEmailNotifLogic + '\' LIMIT 1';

		List<Case> lstCase = Database.query(queryCase);

		System.assertNotEquals(null, lstCase[0].ContactId);

		test.startTest();

		lstCase[0].Applicant_Type__c = Trig_Case.APPLICANT_INSTALLER;
		update lstCase[0];

		test.stopTest();

		Contact installerContact = [SELECT Id, FirstName, LastName
									FROM Contact
									WHERE Id =: lstCase[0].ContactId LIMIT 1];

		lstCase = Database.query(queryCase);

		System.assertEquals(installerContact.FirstName + ' ' + installerContact.LastName, lstCase[0].Applicant_Name__c);
	}

	@isTest static void test_applicant_type_CUSTOMER()
	{
		String queryCase = '';
		queryCase += UtilDatabase.getAllFields('Case');
		queryCase += ' FROM Case ';
		queryCase += ' WHERE ContactEmail =\''+ custEmailNotifLogic + '\' LIMIT 1';

		List<Case> lstCase = Database.query(queryCase);

		System.assertNotEquals(null, lstCase[0].Customer__c);
		lstCase[0].Status = 'New';
		lstCase[0].Send_DER_Offer__c = false;
		update lstCase[0];

		test.startTest();

		lstCase[0].Applicant_Type__c = Trig_Case.APPLICANT_CUSTOMER;
		update lstCase[0];

		test.stopTest();

		Contact customer = [SELECT Id, FirstName, LastName
							FROM Contact
							WHERE AccountId =: lstCase[0].Customer__c LIMIT 1];

		lstCase = Database.query(queryCase);

		System.assertEquals(customer.LastName, lstCase[0].Applicant_Name__c);
	}

	@isTest static void test_applicant_type_REP()
	{
		String queryCase = '';
		queryCase += UtilDatabase.getAllFields('Case');
		queryCase += ' FROM Case ';
		queryCase += ' WHERE ContactEmail =\''+ custEmailNotifLogic + '\' LIMIT 1';

		List<Case> lstCase = Database.query(queryCase);
		lstCase[0].Applicant_Type__c = Trig_Case.APPLICANT_REP;
		update lstCase[0];

		Contact rep = DER_TestUtility.createBusinessAccountContact(lstCase[0].AccountId, 'Rep', 'Test', 'test@testapplicanttypeREP.com');
		Insert rep;

		test.startTest();

		lstCase[0].Representative__c = rep.Id;
		update lstCase[0];

		test.stopTest();

		lstCase = Database.query(queryCase);

		System.assertEquals(rep.FirstName + ' ' + rep.LastName, lstCase[0].Applicant_Name__c);
	}


	@isTest static void test_applicant_type_CLEAR()
	{
		String queryCase = '';
		queryCase += UtilDatabase.getAllFields('Case');
		queryCase += ' FROM Case ';
		queryCase += ' WHERE ContactEmail =\''+ custEmailNotifLogic + '\' LIMIT 1';

		List<Case> lstCase = Database.query(queryCase);

		test.startTest();
		// Installer is set as Applicant_Type__c from testSetup
		// Now let's clear the Applicant_Type__c picklist
		lstCase[0].Applicant_Type__c = '';
		update lstCase[0];

		test.stopTest();

		lstCase = Database.query(queryCase);
		System.assertEquals(null, lstCase[0].Applicant_Name__c);

	}

	@isTest static void test_resp_party_INSTALLER()
	{
		String queryCase = '';
		queryCase += UtilDatabase.getAllFields('Case');
		queryCase += ' FROM Case ';
		queryCase += ' WHERE ContactEmail =\''+ custEmailNotifLogic + '\' LIMIT 1';

		List<Case> lstCase = Database.query(queryCase);

		System.assertNotEquals(null, lstCase[0].ContactId);

		test.startTest();

		lstCase[0].Responsible_Party__c = Trig_Case.RESP_PARTY_INSTALLER;
		update lstCase[0];

		test.stopTest();

		Contact installerContact = [SELECT Id, FirstName, LastName
									FROM Contact
									WHERE Id =: lstCase[0].ContactId LIMIT 1];

		lstCase = Database.query(queryCase);

		System.assertEquals(installerContact.FirstName + ' ' + installerContact.LastName, lstCase[0].Resp_Party_Name__c);
	}

	@isTest static void test_resp_party_CUSTOMER()
	{
		String queryCase = '';
		queryCase += UtilDatabase.getAllFields('Case');
		queryCase += ' FROM Case ';
		queryCase += ' WHERE ContactEmail =\''+ custEmailNotifLogic + '\' LIMIT 1';

		List<Case> lstCase = Database.query(queryCase);

		System.assertNotEquals(null, lstCase[0].Customer__c);

		test.startTest();

		lstCase[0].Responsible_Party__c = Trig_Case.RESP_PARTY_CUSTOMER;
		update lstCase[0];

		test.stopTest();

		Contact customer = [SELECT Id, FirstName, LastName
							FROM Contact
							WHERE AccountId =: lstCase[0].Customer__c LIMIT 1];

		lstCase = Database.query(queryCase);

		System.assertEquals(customer.LastName, lstCase[0].Resp_Party_Name__c);
	}

	@isTest static void test_resp_party_REP()
	{
		String queryCase = '';
		queryCase += UtilDatabase.getAllFields('Case');
		queryCase += ' FROM Case ';
		queryCase += ' WHERE ContactEmail =\''+ custEmailNotifLogic + '\' LIMIT 1';

		List<Case> lstCase = Database.query(queryCase);
		lstCase[0].Responsible_Party__c = Trig_Case.RESP_PARTY_REP;
		update lstCase[0];

		Contact rep = DER_TestUtility.createBusinessAccountContact(lstCase[0].AccountId, 'Rep', 'Test', 'test@testapplicanttypeREP.com');
		Insert rep;

		test.startTest();

		lstCase[0].Representative__c = rep.Id;
		update lstCase[0];

		test.stopTest();

		lstCase = Database.query(queryCase);

		System.assertEquals(rep.FirstName + ' ' + rep.LastName, lstCase[0].Resp_Party_Name__c);
	}

	@isTest static void test_resp_party_CLEAR()
	{
		String queryCase = '';
		queryCase += UtilDatabase.getAllFields('Case');
		queryCase += ' FROM Case ';
		queryCase += ' WHERE ContactEmail =\''+ custEmailNotifLogic + '\' LIMIT 1';

		List<Case> lstCase = Database.query(queryCase);

		test.startTest();
		// Installer is set as Responsible_Party__c from testSetup
		// Now let's clear the Responsible_Party__c picklist
		lstCase[0].Responsible_Party__c = '';
		update lstCase[0];

		test.stopTest();

		lstCase = Database.query(queryCase);

		System.assertEquals(null, lstCase[0].Resp_Party_Name__c);
	}

}