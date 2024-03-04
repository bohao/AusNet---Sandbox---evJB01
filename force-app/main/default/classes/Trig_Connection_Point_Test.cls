/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 16 Oct 2019
  @Description : Test class for Connection_Point__c trigger logics
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/

@isTest
private class Trig_Connection_Point_Test
{
	private static String NMI_NUMBER = '123456789';
	private static String NMI_BUILDNAME = '123456789';
	private static String NMI_HOUSEN1 = '123456789';
	private static String NMI_HOUSENO2 = '123456789';
	private static String NMI_HAUSN2 = '123456789';
	private static String NMI_FLOOR = '123456789';
	private static String NMI_STREET = '123456789';
	private static String NMI_POSTCODE = '123456789';
	private static String NMI_CITY = '123456789';
	private static String NMI_COUNTRY = '123456789';
	private static String NMI_STATE = '123456789';
	private static String customerEmail = 'customer@test12345.com';
	private static String installerEmail = 'installer@test12345.com';
	private static String repEmail = 'rep@test12345.com';

	public static testMethod void nmi_ref_update()
	{
		User testUser = UtilDatabase_Test.getTestUser();
		Connection_Point__c conPoint = [SELECT Id, NMI_Ref__c, NMI__c, Name, NMI_Ref__r.Nmi__c,
										Building_Name__c,House_Num_1__c,House_Num_2__c, Haus_Num_2__c,Floor__c,Street__c,
										Post_Code__c,City__c,Country__c,State__c
										FROM Connection_Point__c
										WHERE Account__r.PersonEmail =: customerEmail
										LIMIT 1];

		Test.startTest();
		System.runAs(testUser){
			//Create NmiDataSets__x
			NmiDataSets__x testExtNMI = DER_TestUtility.createEXTNMI(NMI_NUMBER);
			testExtNMI.StrSuppl1__c=NMI_BUILDNAME;
			testExtNMI.HouseNum1__c=NMI_HOUSEN1;
			testExtNMI.HouseNum2__c=NMI_HOUSENO2;
			testExtNMI.HausNum2__c=NMI_HAUSN2;
			testExtNMI.Floor__c=NMI_FLOOR;
			testExtNMI.Street__c=NMI_STREET;
			testExtNMI.PostCode1__c=NMI_POSTCODE;
			testExtNMI.City1__c=NMI_CITY;
			testExtNMI.Country__c=NMI_COUNTRY;
			testExtNMI.Region__c=NMI_STATE;
			DER_Connection_Point_Util.mockedExtNMI.add(testExtNMI);

			conPoint.NMI__c = NMI_NUMBER;
			conPoint.Building_Name__c= NMI_BUILDNAME;
			conPoint.House_Num_1__c=NMI_HOUSEN1;
			conPoint.House_Num_2__c=NMI_HOUSENO2;
			conPoint.Haus_Num_2__c=NMI_HAUSN2;
			conPoint.Floor__c=NMI_FLOOR;
			conPoint.Street__c=NMI_STREET;
			conPoint.Post_Code__c=NMI_POSTCODE;
			conPoint.City__c=NMI_CITY;
			conPoint.Country__c=NMI_COUNTRY;
			conPoint.State__c=NMI_STATE;
			update conPoint;
		}
		Test.stopTest();

		Connection_Point__c appAfterUpdate =  [SELECT Id, NMI_Ref__c, NMI__c, Name, NMI_Ref__r.Nmi__c,
											   Building_Name__c,House_Num_1__c,House_Num_2__c, Haus_Num_2__c,Floor__c,Street__c,
													Post_Code__c,City__c,Country__c,State__c
													FROM Connection_Point__c
													WHERE Id =: conPoint.Id
													LIMIT 1];
		System.assertEquals('NMI: '+NMI_NUMBER, appAfterUpdate.Name);

	}

	public static testMethod void nmi_ref_clear()
	{
		User testUser = UtilDatabase_Test.getTestUser();
		Connection_Point__c conPoint = [SELECT Id, NMI_Ref__c, NMI__c, Name, NMI_Ref__r.Nmi__c,
										Building_Name__c,House_Num_1__c,House_Num_2__c, Haus_Num_2__c,Floor__c,Street__c,
													Post_Code__c,City__c,Country__c,State__c
										FROM Connection_Point__c
										WHERE Account__r.PersonEmail =: customerEmail
										LIMIT 1];

		Test.startTest();
		System.runAs(testUser){
			//Create NmiDataSets__x
			NmiDataSets__x testExtNMI = DER_TestUtility.createEXTNMI(NMI_NUMBER);
			DER_Connection_Point_Util.mockedExtNMI.add(testExtNMI);

			conPoint.NMI__c = NMI_NUMBER;
			DER_Connection_Point_Util.isRunning_PopulateExternalNMIRef = false;
			update conPoint;

			conPoint.NMI__c = null;
			DER_Connection_Point_Util.isRunning_PopulateExternalNMIRef = false;
			update conPoint;
		}
		Test.stopTest();

		Connection_Point__c appAfterUpdate =  [SELECT Id, NMI_Ref__c, NMI__c, Name, NMI_Ref__r.Nmi__c,
											   Building_Name__c,House_Num_1__c,House_Num_2__c, Haus_Num_2__c,Floor__c,Street__c,
													Post_Code__c,City__c,Country__c,State__c
													FROM Connection_Point__c
													WHERE Id =: conPoint.Id
													LIMIT 1];
		System.assertEquals(null, appAfterUpdate.NMI_Ref__c);

	}

	@TestSetup
	public static void setup() {

		//Create User
		User testUser = DER_TestUtility.createTestUser();
		insert testUser;

		Id testDERAppId = DER_TestUtility.loadDERAppRecords(customerEmail, installerEmail, repEmail);
	}
}