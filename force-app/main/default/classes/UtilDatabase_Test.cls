/*
  @author  : vaughan.crole@ausnetservices.com.au, pavan.dave@ausnetservices.com.au
  @created : 04 Sep 2019
  @Description : Test class for UtilDatabase
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/

@isTest
public class UtilDatabase_Test
{
	private static Account Account;

	public static testMethod void testUtilDatabase()
	{
		generateData();

		SObject SObj;

		SObj = UtilDatabase.getRecord(null);
		SObj = UtilDatabase.getRecord(Account.Id);

		String str = UtilDatabase.getObjectNameFromId(Account.Id);
	}

	private static void generateData()
	{
		Account = new Account();
		//Account.RecordTypeId = UtilDatabase.getRecordTypeMap('Account').get('Individual');
		Account.Name = 'Test';
		Account.ABN__c = '1234567890';
		insert Account;
	}

	public static User getTestUser()
	{
		return [SELECT Id FROM User WHERE IsActive=true LIMIT 1];
	}
}