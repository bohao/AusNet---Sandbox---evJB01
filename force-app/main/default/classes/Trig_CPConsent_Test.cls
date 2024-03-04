@isTest
private class Trig_CPConsent_Test
{
	private static Integer numCustomers = 1;

	public static testMethod void test_Trig_CPConsent()
	{
		User testUser = UtilDatabase_Test.getTestUser();

		Test.startTest();
		System.runAs(testUser)
		{
			// Generate customer data (NMI, Premise, Account, Contact, ACR)
			Outage_DataFactory.getODF().generateCustomers(numCustomers);

			List<ContactPointConsent> CPCs = Outage_DataFactory.getODF().CPConsents;
			update CPCs;
		}

		Test.stopTest();
	}
}