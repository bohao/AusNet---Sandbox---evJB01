@isTest
public class TVE_CustomerDetailsToEAIService_Test {
	@isTest
	public static void testGetCustomerDetails() {
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		List<Contact> conList = [Select Id From Contact];
		req.requestURI = '/services/apexrest/customers';
		req.addParameter('id', conList[0].Id);
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		TVE_CustomerDetailsToEAIService.wrapAccountContactDetails wrapper = TVE_CustomerDetailsToEAIService.doGet();
		System.assertNotEquals(null, wrapper);
	}

	@isTest
	public static void testGetPersonCustomerDetails() {
		Id acctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(DER_REST_Application_v1.ACCOUNT_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        Account personAcc = new Account(
            LastName = 'testLast',
            RecordTypeId = acctRTId,
            PersonEmail = 'test@test12345.com',
            ABN_CINCL__c = '1234567890');
        insert personAcc;

        RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		List<Contact> conList = [Select Id From Contact Where AccountId = :personAcc.Id];
		req.requestURI = '/services/apexrest/customers';
		req.addParameter('id', conList[0].Id);
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		TVE_CustomerDetailsToEAIService.wrapAccountContactDetails wrapper = TVE_CustomerDetailsToEAIService.doGet();
		System.assertNotEquals(null, wrapper);
	}

	@TestSetup
	public static void setup()
	{
		//Create User
		User testUser = DER_TestUtility.createTestUser();
		insert testUser;

		//Create Business Account
		Account testInstaller = DER_TestUtility.createBusinessAccount('Business Account');
		insert testInstaller;

		//Create Business Account's Contact
		Contact testInstallerContact = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Installer', 'test@test12345.com');
		insert testInstallerContact;
	}
}