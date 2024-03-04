@isTest
public with sharing class Outage_ServicePointBatchTest
{
	@testSetup static void setup()
	{
		Trig_ServicePoint.isRunningCheckforDuplicates = true;

		Integer numCustomers = 100;
		Outage_DataFactory.getODF().generateCustomers(numCustomers);

		Trig_ServicePoint.isRunningCheckforDuplicates = false;
	}

	@isTest static void runBatchTest1()
	{
		Test.startTest();
			Outage_ServicePointBatch.runServPointSync();
		Test.stopTest();
	}

	@isTest static void runBatchTest2()
	{
		Test.startTest();
			Outage_ServicePointBatch.runServPointSync('Id != \'\'');
		Test.stopTest();
	}
}