@isTest
private class Device_Hierarchy_Test
{
	public static testMethod void device_insert_success()
	{
		User testUser = UtilDatabase_Test.getTestUser();
		Case derCase = [SELECT Id, Subject FROM Case LIMIT 1];

		Test.startTest();
		System.runAs(testUser)
		{
			Device_Hierarchy.getDeviceHierarchy(derCase.Id);
		}
		Test.stopTest();


	}



	@TestSetup
	public static void setup()
	{

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

		//Create Connection Point
		Connection_Point__c testConnectionPoint = DER_TestUtility.createConnectionPoint(testCustomer.Id);
		insert testConnectionPoint;


		//Create DER Application
		DER_Application__c testDERApp = DER_TestUtility.createDERApplication(testConnectionPoint.Id);
		insert testDERApp;

		// case
		Case derCase = DER_TestUtility.createCaseWith_Installer_Customer_Rep(testDERApp.Id,
															'DER_App_Auto',
															'New', 'Web', null,
															null, null,
															null, null,
															null, null);
		insert derCase;


		//Create Device1
		Device__c testDeviceL2 = DER_TestUtility.createDevice_L2(testDERApp.Id);
		testDeviceL2.Device_Phase__c = 'A';
		testDeviceL2.AC_Equip_Cap__c = 40;
		testDeviceL2.AC_Equip_Exp__c = 30;
		testDeviceL2.AC_Equip_Type__c = 'Inverter';
		testDeviceL2.AC_Equip_Sub_Type__c = 'Solar';
		testDeviceL2.Device_Count__c = 2;
		insert testDeviceL2;

		//Create Device L3
		Device__c testDeviceL3 = DER_TestUtility.createDevice_L3(testDeviceL2.Id);
		testDeviceL3.Device_Type__c = 'Solar PV';
		testDeviceL3.Device_Sub_Type__c = 'Monocrystalline';
		testDeviceL3.Device_Count__c = 5;
		insert testDeviceL3;
	}

	@isTest
	public static void testSearchInverter() {
		Boolean result = Device_Hierarchy.searchDevice('samplemockstring', 'Inverter');
		System.assertEquals(false, result);
	}

	@isTest
	public static void testSearchModule() {
		Boolean result = Device_Hierarchy.searchDevice('samplemockstring', 'Module');
		System.assertEquals(false, result);
	}
}