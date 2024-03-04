@isTest
private class UtilFieldCalcsTest
{
	@isTest static void test_SetRegionEmailAddressProd()
	{
		Id ProdId = UtilFieldCalcs.PROD_ORG_ID;
		String TestEmail = 'apextest@ausnet.com';

		// Set up a prod email addr
		String org = 'Prod';
		UtilFieldCalcs.PROD_ORG_ID = UserInfo.getOrganizationId();
		for (String value: getRegionSet())
		{
			String key = org + '-' + value;
			String email = TestEmail + '.' + org + '.' + value;
			UtilFieldCalcs.RegionEmailAddresses.put(key, email);
		}

		Case derCase = new Case();
		derCase.RecordTypeId = UtilDatabase.getRecordTypeNames('Case').get(DER_REST_Application_v1.CASE_RECORDTYPE_MANUAL);
		derCase.Status = 'New';
		derCase.Type = 'New';
		derCase.DER_Application_Scenario__c = 'Manual';
		derCase.Enable_Notifications__c = false;
		insert derCase;

		for (String value: getRegionSet())
		{
			derCase.Region__c = value;
			update derCase;

			Case checkCase = (Case)UtilDatabase.getRecord(derCase.Id);
			String email = TestEmail + '.' + org + '.' + value;
			System.assertEquals(email.toLowerCase(), checkCase.Region_Email_Address__c, 'Exception: Region Email Address error.');
		}
	}

	@isTest static void test_SetRegionEmailAddressNonProd()
	{
		Id ProdId = UtilFieldCalcs.PROD_ORG_ID;
		String TestEmail = 'apextest@ausnet.com';

		// Set up a non-prod email addr
		String org = 'NonProd';
		UtilFieldCalcs.PROD_ORG_ID = '00D5L0000000000000'; // not this org id, that's for sure.
		for (String value: getRegionSet())
		{
			String key = org + '-' + value;
			String email = TestEmail + '.' + org + '.' + value;
			UtilFieldCalcs.RegionEmailAddresses.put(key, email);
		}

		Case derCase = new Case();
		derCase.RecordTypeId = UtilDatabase.getRecordTypeNames('Case').get(DER_REST_Application_v1.CASE_RECORDTYPE_MANUAL);
		derCase.Status = 'New';
		derCase.Type = 'New';
		derCase.DER_Application_Scenario__c = 'Manual';
		derCase.Enable_Notifications__c = false;
		insert derCase;

		for (String value: getRegionSet())
		{
			derCase.Region__c = value;
			update derCase;

			Case checkCase = (Case)UtilDatabase.getRecord(derCase.Id);
			String email = TestEmail + '.' + org + '.' + value;
			System.assertEquals(email.toLowerCase(), checkCase.Region_Email_Address__c, 'Exception: Region Email Address error.');
		}
	}

	private static Set<String> getRegionSet()
	{
		// Reads the Region__c picklist from the Case object,
		// and returns the values.
		Set<String> picklistvalues = new Set<String>();

		for (Schema.PicklistEntry ple: Case.Region__c.getDescribe().getPicklistValues())
			picklistvalues.add(ple.getLabel());

		return picklistvalues;
	}
}