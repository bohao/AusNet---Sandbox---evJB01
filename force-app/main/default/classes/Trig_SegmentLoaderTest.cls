@isTest
public with sharing class Trig_SegmentLoaderTest
{
	private static List<String> NMIs = new List<String>
	{
		'63100000001',
		'63100000002',
		'63100000003',
		'63100000004',
		'63100000005'
	};

	@TestSetup
	public static void createTestData()
	{
		Campaign cTest = new Campaign();
		cTest.Name = 'Test12';
		insert cTest;

		Outage_DataFactory.getODF().strNMIs = NMIs;
		Outage_DataFactory.getODF().generateCustomers(5);
	}

	@IsTest public static void testMethod1()
	{
		List<Segment_Loader__c> lstInsert = new List<Segment_Loader__c>();

		User testUser = UtilDatabase_Test.getTestUser();
		testUser.UserPermissionsMarketingUser = true;
		//update testUser;

		System.runAs(testUser)
		{
			Test.startTest();

				lstInsert.add(new Segment_Loader__c(
					Campaign_Name__c = 'Test12',
					NMI__c = NMIs[0]
				));

				lstInsert.add(new Segment_Loader__c(
					Campaign_Name__c = 'Test12',
					NMI__c = NMIs[1]
				));

				lstInsert.add(new Segment_Loader__c(
					Campaign_Name__c = 'Test13',
					NMI__c = NMIs[2]
				));

				lstInsert.add(new Segment_Loader__c(
					Campaign_Name__c = 'Test13',
					NMI__c = '123'
				));

				insert lstInsert;

			Test.stopTest();
		}
	}
}