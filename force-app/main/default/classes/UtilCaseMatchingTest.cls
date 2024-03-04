@isTest
private class UtilCaseMatchingTest
{
	public  static String Case_RT   = DER_REST_Application_v1.CASE_RECORDTYPE_AUTO;
	private static Id     Case_RTId = UtilDatabase.getRecordTypeNames('Case').get(Case_RT);

	@testSetup static void setup()
	{
		// ------------------------------------------------------------- //
		// -------- Data setup for Notification field: Start------------ //
		// ------------------------------------------------------------ //

		//Create Individual Account
		Account testCustomer = DER_TestUtility.createPersonAccount('Person Account', 'test@test12345.com');
		insert testCustomer;


		//Create Connection Point
		Connection_Point__c testConnectionPoint = DER_TestUtility.createConnectionPoint(testCustomer.Id);
		testConnectionPoint.NMI__c = '6350682640';
		Insert testConnectionPoint;

		DER_Application__c testDERApp = DER_TestUtility.createDERApplication(testConnectionPoint.Id);
		testDERApp.Meter_Number__c = '12345';
		testDERApp.NMI__c = testConnectionPoint.Id;
		Insert testDERApp;

		 Case testCase = new Case(
			Subject = 'New Case',
			Origin = 'Web',
			RecordTypeId = Case_RTId,
			Invoice_Number__c = '12345',
			DER_Application__c = testDERApp.Id,
			Status ='Publish'
		);
		insert testCase;

		System.assertNotEquals(null, testCase.Id, 'Failed to insert testCase');
		// -------- Data setup for Notification field: End ------------ //
	}

	public static testMethod void testupdateCaseMatchingNmiMeter()
	{
		Map<String,String> mapNMIMeter = new Map<String,String>();
		DER_Application__c derApp = [Select Id,Meter_Number__c,NMI__c from DER_Application__c ][0];
		mapNMIMeter.put(derApp.NMI__c,derApp.Meter_Number__c);
		UtilCaseMatching.updateCaseMatchingNmiMeter(mapNMIMeter);
	}
}