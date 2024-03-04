@IsTest
public class CE_ContactSyncBatch_Test {

    public static testMethod void ContactSync_Test1()
	{
		Test.startTest();
			CE_ContactSyncBatch.runContactSync(' Phone!=\'\'');
		Test.stopTest();
	}
}