/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 23 Sep 2019
  @Description : Test class for Device Trigger and respective trigger logics
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/

@isTest
private class Trig_Device_Test {

	public static testMethod void device_insert_success(){
		User testUser = UtilDatabase_Test.getTestUser();
		DER_Application__c app = [SELECT Id, Name FROM DER_Application__c LIMIT 1];

		Test.startTest();
		System.runAs(testUser){

			Device__c testDevice;
			List<Device__c> lstDevice = new List<Device__c>();

			testDevice = DER_TestUtility.createDevice_L2(app.Id);
			testDevice.AC_Equip_Type__c = 'Inverter';
			testDevice.AC_Equip_Sub_Type__c = 'Solar';
			testDevice.Device_Phase__c = 'A';
			testDevice.Requested__c = true;
			testDevice.AC_Equip_Cap__c = 10;
			testDevice.AC_Equip_Exp__c = 20;
			lstDevice.add(testDevice);

			testDevice = DER_TestUtility.createDevice_L2(app.Id);
			testDevice.AC_Equip_Type__c = 'Inverter';
			testDevice.AC_Equip_Sub_Type__c = 'Solar';
			testDevice.Device_Phase__c = 'B';
			testDevice.Requested__c = true;
			testDevice.AC_Equip_Cap__c = 5;
			testDevice.AC_Equip_Exp__c = 15;
			lstDevice.add(testDevice);

			testDevice = DER_TestUtility.createDevice_L2(app.Id);
			testDevice.AC_Equip_Type__c = 'Inverter';
			testDevice.AC_Equip_Sub_Type__c = 'Solar';
			testDevice.Device_Phase__c = 'C';
			testDevice.Requested__c = true;
			testDevice.AC_Equip_Cap__c = 100;
			testDevice.AC_Equip_Exp__c = 200;
			lstDevice.add(testDevice);

			testDevice = DER_TestUtility.createDevice_L2(app.Id);
			testDevice.AC_Equip_Type__c = 'Inverter';
			testDevice.AC_Equip_Sub_Type__c = 'Solar';
			testDevice.Device_Phase__c = '3 Phase';
			testDevice.Requested__c = true;
			testDevice.AC_Equip_Cap__c = 90;
			testDevice.AC_Equip_Exp__c = 90;
			lstDevice.add(testDevice);

			testDevice = DER_TestUtility.createDevice_L2(app.Id);
			testDevice.AC_Equip_Type__c = 'Inverter';
			testDevice.AC_Equip_Sub_Type__c = 'Solar';
			testDevice.Device_Phase__c = '3 Phase';
			testDevice.Requested__c = true;
			testDevice.AC_Equip_Cap__c = 4;
			testDevice.AC_Equip_Exp__c = 4;
			lstDevice.add(testDevice);

			Insert lstDevice;
		}
		Test.stopTest();

		DER_Application__c appAfterUpdate = (DER_Application__c) UtilDatabase.getRecord(app.Id);
		System.assertEquals(81.33, appAfterUpdate.Ph_A_New_Capacity__c);
		//System.assertEquals(81.33, appAfterUpdate.Phase_A_Total_System_Export__c);
		System.assertEquals(36.33, appAfterUpdate.Ph_B_New_Capacity__c);
		//System.assertEquals(46.33, appAfterUpdate.Phase_B_Total_System_Export__c);
		System.assertEquals(131.34, appAfterUpdate.Ph_C_New_Capacity__c);
		//System.assertEquals(231.34, appAfterUpdate.Phase_C_Total_System_Export__c);

	}

	public static testMethod void device_update_success(){
		User testUser = UtilDatabase_Test.getTestUser();
		Device__c dev = [SELECT Id, DER_Application__c, Device_Phase__c, AC_Equip_Cap__c, AC_Equip_Exp__c
							FROM Device__c LIMIT 1];

		Test.startTest();
		System.runAs(testUser){
			dev.AC_Equip_Type__c = 'Inverter';
			dev.AC_Equip_Sub_Type__c = 'Solar';
			dev.Device_Phase__c = 'C';
			dev.Requested__c = true;
			dev.AC_Equip_Cap__c = 100;
			dev.AC_Equip_Exp__c = 150;

			update dev;
		}
		Test.stopTest();

		DER_Application__c appAfterUpdate = (DER_Application__c) UtilDatabase.getRecord(dev.DER_Application__c);
		System.assertEquals(0, appAfterUpdate.Ph_A_New_Capacity__c);
		//System.assertEquals(0, appAfterUpdate.Phase_A_Total_System_Export__c);
		System.assertEquals(0, appAfterUpdate.Ph_B_New_Capacity__c);
		//System.assertEquals(0, appAfterUpdate.Phase_B_Total_System_Export__c);
		System.assertEquals(100, appAfterUpdate.Ph_C_New_Capacity__c);
		//System.assertEquals(150, appAfterUpdate.Phase_C_Total_System_Export__c);
	}

	public static testMethod void device_insert_delete()
	{
		User testUser = UtilDatabase_Test.getTestUser();
		DER_Application__c app = [SELECT Id, Name FROM DER_Application__c LIMIT 1];

		Device__c testDevice;
		List<Device__c> lstDevice = new List<Device__c>();

		testDevice = DER_TestUtility.createDevice_L2(app.Id);
		testDevice.AC_Equip_Type__c = 'Inverter';
		testDevice.AC_Equip_Sub_Type__c = 'Solar';
		testDevice.Device_Phase__c = 'A';
		testDevice.Requested__c = true;
		testDevice.AC_Equip_Cap__c = 10;
		lstDevice.add(testDevice);

		testDevice = DER_TestUtility.createDevice_L2(app.Id);
		testDevice.AC_Equip_Type__c = 'Inverter';
		testDevice.AC_Equip_Sub_Type__c = 'Solar';
		testDevice.Device_Phase__c = 'B';
		testDevice.Requested__c = true;
		testDevice.AC_Equip_Cap__c = 5;
		lstDevice.add(testDevice);

		testDevice = DER_TestUtility.createDevice_L2(app.Id);
		testDevice.AC_Equip_Type__c = 'Inverter';
		testDevice.AC_Equip_Sub_Type__c = 'Solar';
		testDevice.Device_Phase__c = 'C';
		testDevice.Requested__c = true;
		testDevice.AC_Equip_Cap__c = 100;
		lstDevice.add(testDevice);

		UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = false;
		insert lstDevice;
		DER_Application__c appAfterUpdate = (DER_Application__c) UtilDatabase.getRecord(app.Id);

		Test.startTest();
			System.runAs(testUser)
			{
				UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = false;
				delete lstDevice[2];
			}
		Test.stopTest();

		appAfterUpdate = (DER_Application__c) UtilDatabase.getRecord(app.Id);
		System.assertEquals(50, appAfterUpdate.Ph_A_New_Capacity__c);
		System.assertEquals(5, appAfterUpdate.Ph_B_New_Capacity__c);
		System.assertEquals(0, appAfterUpdate.Ph_C_New_Capacity__c);
	}

	public static testMethod void device_update_undelete()
	{
		User testUser = UtilDatabase_Test.getTestUser();
		Device__c dev = [SELECT Id, DER_Application__c, Device_Phase__c, AC_Equip_Cap__c, AC_Equip_Exp__c
							FROM Device__c LIMIT 1];
		Id derAppId = dev.DER_Application__c;

		delete dev;

		Test.startTest();
		System.runAs(testUser){
			UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = false;
			undelete [SELECT Id FROM Device__c WHERE DER_Application__c =: derAppId ALL ROWS];
		}
		Test.stopTest();

		DER_Application__c appAfterUpdate = (DER_Application__c) UtilDatabase.getRecord(dev.DER_Application__c);
		System.assertEquals(40, appAfterUpdate.Ph_A_New_Capacity__c);
		//System.assertEquals(30, appAfterUpdate.Phase_A_Total_System_Export__c);
		System.assertEquals(0, appAfterUpdate.Ph_B_New_Capacity__c);
		//System.assertEquals(0, appAfterUpdate.Phase_B_Total_System_Export__c);
		System.assertEquals(0, appAfterUpdate.Ph_C_New_Capacity__c);
		//System.assertEquals(0, appAfterUpdate.Phase_C_Total_System_Export__c);

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

		// Create Connection Point
		Connection_Point__c testConnectionPoint = DER_TestUtility.createConnectionPoint(testCustomer.Id);
		Insert testConnectionPoint;


		// Create DER Application
		DER_Application__c testDERApp = DER_TestUtility.createDERApplication(testConnectionPoint.Id);
		Insert testDERApp;
		
		// Create Business Account's Contact
		Contact testRep = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Representative', 'test@test.com');
		insert testRep;
		
		// Create case with customer, installer & representative
		Case testCase = DER_TestUtility.createCaseWith_Installer_Customer_Rep(testDERApp.Id,
																		 DER_REST_Application_v1.CASE_RECORDTYPE_MANUAL, 
																		 'New', 'Email', 'Medium', 
																		 testInstaller.Id, testInstallerContact.Id, 
																		 testCustomer.Id, testRep.Id,
																		 Trig_Case.APPLICANT_REP, Trig_Case.RESP_PARTY_REP);
		insert testCase;

		//Create Device1
		Device__c testDevice = DER_TestUtility.createDevice_L2(testDERApp.Id);
		testDevice.AC_Equip_Type__c = 'Inverter';
		testDevice.AC_Equip_Sub_Type__c = 'Solar';
		testDevice.Requested__c = true;
		testDevice.Device_Phase__c = 'A';
		testDevice.AC_Equip_Cap__c = 40;
		Insert testDevice;



	}
}