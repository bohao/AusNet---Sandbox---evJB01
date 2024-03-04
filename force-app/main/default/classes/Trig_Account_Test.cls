/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 29 Sep 2019
  @Description : Test Class for Account Triggers
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                                 NA
  -----------------------------------------------------------------------------------------
*/
@isTest
private class Trig_Account_Test
{
    private static String custEmailNotifLogic = 'customer@test12345.com';
	
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
        Insert testConnectionPoint;
                
        DER_Application__c testDERApp = DER_TestUtility.createDERApplication(testConnectionPoint.Id);
        Insert testDERApp;
        
        //Create Business Account
        Account testInstaller = DER_TestUtility.createBusinessAccount('Business Account');
        insert testInstaller;
        
        //Create Business Account's Contact
        Contact testInstallerContact = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Installer', custEmailNotifLogic);
        insert testInstallerContact;

        //Create Business Account
        Account testRepAcc = DER_TestUtility.createBusinessAccount('Representative Business Account');
        insert testRepAcc;
        
        //Create Business Account's Contact
        Contact testRep = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Representative', 'representative@test12345.com');
        insert testRep;

        //Create case with customer, installer & representative
        Case testCaseNotifLogic = DER_TestUtility.createCaseWith_Installer_Customer_Rep(testDERApp.Id,
                                                                         DER_REST_Application_v1.CASE_RECORDTYPE_AUTO, 
                                                                         'New', 'Email', 'Medium', 
                                                                         testInstaller.Id, testInstallerContact.Id, 
                                                                         testCustomer.Id, testRep.Id,
                                                                         Trig_Case.APPLICANT_REP, Trig_Case.RESP_PARTY_REP);
        insert testCaseNotifLogic;

        // -------- Data setup for Notification field: End ------------ //
	}

	@isTest static void test_CUSTOMER_UPDATE()
	{
		String queryCase = '';
            queryCase += UtilDatabase.getAllFields('Case');
            queryCase += ' FROM Case ';
			queryCase += ' WHERE ContactEmail =\''+ custEmailNotifLogic + '\' LIMIT 1';  

		List<Case> lstCase = Database.query(queryCase);
		
		System.assertNotEquals(null, lstCase[0].Customer__c);
        
        lstCase[0].Applicant_Type__c = Trig_Case.APPLICANT_CUSTOMER;
        lstCase[0].Responsible_Party__c = Trig_Case.RESP_PARTY_CUSTOMER;
		update lstCase[0];
		
		test.startTest();
        Account customer = [SELECT Id, FirstName, LastName, PersonEmail
									FROM Account 
									WHERE Id =: lstCase[0].Customer__c LIMIT 1];

        customer.FirstName = 'Test';
        customer.LastName = 'Test';
        customer.PersonEmail = 'test@testinstallerupdate.com';
        
        update customer;       
		
		test.stopTest();           		
		
		lstCase = Database.query(queryCase);

		System.assertEquals('Test' + ' ' + 'Test', lstCase[0].Applicant_Name__c);
        System.assertEquals('Test' + ' ' + 'Test', lstCase[0].Resp_Party_Name__c);
        System.assertEquals('test@testinstallerupdate.com', lstCase[0].Applicant_Email__c);
        System.assertEquals('test@testinstallerupdate.com', lstCase[0].Resp_Party_Email__c);
	}

    @isTest // Covers handleMarketingCloudContact and handleMarketingCloudContactAfterInsert
    static void AfterInsertHandleMarketingCloudContactTest() {
        Integer numCustomers = 2;
        Outage_DataFactory.getODF().generateCustomers(numCustomers);
        List<Contact> consODF = Outage_DataFactory.getODF().cons;
        List<Account> accsODF = Outage_DataFactory.getODF().accs;
        List<AccountContactRelation> acrsODF = Outage_DataFactory.getODF().ACRs;
        
        // Update ACRS and Account so that Contacts MC_Contact__c fields are set to false
        List<AccountContactRelation> acrsToUpdate = new List<AccountContactRelation>();
        for (AccountContactRelation acr : acrsODF) {
            acr.Roles = '';
            acrsToUpdate.add(acr);
        }
        update acrsToUpdate;

        List<Account> accsToUpdate = new List<Account>();
        for (Account acc : accsODF) {
            acc.vlocity_cmt__PrimaryContactId__c = null;
            accsToUpdate.add(acc);
        }
        update accsToUpdate;

        // Get Contacts and Accounts
        List<Contact> conList = [SELECT Id, AccountId, MC_Contact__c FROM Contact WHERE Id IN :consODF];
        Id con1Id = conList.get(0).Id;
        Id con2Id = conList.get(1).Id;

        List<Account> accServiceForCloneList = [SELECT Name, RecordTypeId, vlocity_cmt__PrimaryContactId__c, Market_Identifier__c, vlocity_cmt__PremisesId__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode FROM Account WHERE Id IN :accsODF LIMIT 2];

        // Create Business Account (non service account) to be inserted during test (RT listed in recordTypesMVP)
        Account accBusiness = accServiceForCloneList.get(0).clone(false, true, false, false);
        accBusiness.RecordTypeId = UtilDatabase.getRecordTypeNames('Account').get('Business');
        accBusiness.vlocity_cmt__PrimaryContactId__c = con1Id;

        // Create Service Account to be inserted during test
        Account accService = accServiceForCloneList.get(1).clone(false, true, false, false);
        accService.vlocity_cmt__PrimaryContactId__c = con2Id;
        
        Test.startTest();

        // Validate initial data setup is correct
        Assert.isFalse(conList.get(0).MC_Contact__c, 'MC_Contact__c should be set to false');
        Assert.isFalse(conList.get(1).MC_Contact__c, 'MC_Contact__c should be set to false');
        
        // insert new non service account record and retrieve the primary contact
        insert accBusiness;
        Contact busCon = [SELECT Id, MC_Contact__c FROM Contact WHERE id = :con1Id LIMIT 1];

        // Validate MC_Contact__c service account logic did not run on a non Service Account
        Assert.isFalse(busCon.MC_Contact__c, 'MC_Contact__c should be set to false');

        // insert new service account record and retrieve the primary contact
        insert accService;
        Contact serCon = [SELECT Id, MC_Contact__c FROM Contact WHERE id = :con2Id LIMIT 1];

        // Validate service account logic ran on the Service Account - primary contact record is updated correctly (new primary contact MC_Contact__c field true)
        Assert.isTrue(serCon.MC_Contact__c, 'MC_Contact__c should be set to true');

        Test.stopTest();
	}

    @isTest // Covers handleMarketingCloudContact and handleMarketingCloudContactAfterUpdate
    static void AfterUpdateHandleMarketingCloudContactTest() {
        Integer numCustomers = 2;
        Outage_DataFactory.getODF().generateCustomers(numCustomers);
        List<Contact> consODF = Outage_DataFactory.getODF().cons;
        List<Account> accsODF = Outage_DataFactory.getODF().accs;
        List<AccountContactRelation> acrsODF = Outage_DataFactory.getODF().ACRs;
        
        // Update ACRS and Account so that Contacts MC_Contact__c fields are set to false
        List<AccountContactRelation> acrsToUpdate = new List<AccountContactRelation>();
        for (AccountContactRelation acr : acrsODF) {
            acr.Roles = '';
            acrsToUpdate.add(acr);
        }
        update acrsToUpdate;

        List<Account> accsToUpdate = new List<Account>();
        for (Account acc : accsODF) {
            acc.vlocity_cmt__PrimaryContactId__c = null;
            accsToUpdate.add(acc);
        }
        update accsToUpdate;
        
        // Get Contacts and Accounts
        List<Contact> conList = [SELECT Id, AccountId, MC_Contact__c FROM Contact WHERE Id IN :consODF];
        Id con1Id = conList.get(0).Id;
        Id con2Id = conList.get(1).Id;

        List<Account> accServiceList = [SELECT Name, RecordTypeId, vlocity_cmt__PrimaryContactId__c, Market_Identifier__c, vlocity_cmt__PremisesId__c, ShippingStreet, ShippingCity, ShippingState, ShippingPostalCode, Contact_Matched__c FROM Account WHERE Id IN :accsODF LIMIT 2];

        // Create Business Account (non service account) to be updated during test (RT listed in recordTypesMVP)
        Account accBusiness = accServiceList.get(0).clone(false, true, false, false);
        accBusiness.RecordTypeId = UtilDatabase.getRecordTypeNames('Account').get('Business');
        insert accBusiness;
        
        Test.startTest();

        // Run for blank values skip scenario on service account
        Account accService = accServiceList.get(1);
        accService.Contact_Matched__c = '';
        update accService;

        // Validate initial data setup is correct
        Assert.isFalse(conList.get(0).MC_Contact__c, 'MC_Contact__c should be set to false');
        Assert.isFalse(conList.get(1).MC_Contact__c, 'MC_Contact__c should be set to false');
        
        // Update the non service account record and retrieve the primary contact
        accBusiness.vlocity_cmt__PrimaryContactId__c = con1Id;
        update accBusiness;
        Contact busCon = [SELECT Id, MC_Contact__c FROM Contact WHERE id = :con1Id LIMIT 1];

        // Validate MC_Contact__c service account logic did not run on a non Service Account
        Assert.isFalse(busCon.MC_Contact__c, 'MC_Contact__c should be set to false');

        // Update service account record and retrieve the primary contact - Set primary contact from null to con2
        accService.vlocity_cmt__PrimaryContactId__c = con2Id;
        update accService;
        Contact serCon = [SELECT Id, MC_Contact__c FROM Contact WHERE id = :con2Id LIMIT 1];

        // Validate MC_Contact__c service account logic ran on the Service Account - primary contact record is updated correctly (new primary contact MC_Contact__c field true)
        Assert.isTrue(serCon.MC_Contact__c, 'MC_Contact__c should be set to true');

        // Set primary contact from con2 to con1
        accService.vlocity_cmt__PrimaryContactId__c = con1Id;
        update accService;
        
        // Validate contact records are updated correctly (old primary contact MC_Contact__c field false and new primary contact MC_Contact__c field true)
        Contact updatedCon2 = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :con2Id LIMIT 1];
        Assert.isFalse(updatedCon2.MC_Contact__c, 'MC_Contact__c should be set to false');

        Contact updatedCon1 = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :con1Id LIMIT 1];
        Assert.isTrue(updatedCon1.MC_Contact__c, 'MC_Contact__c should be set to true');
        
        // Set primary contact from con1 to null
        accService.vlocity_cmt__PrimaryContactId__c = null;
        update accService;
        
        // Validate primary contact record is updated correctly (old primary contact MC_Contact__c field false)
        updatedCon1 = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :con1Id LIMIT 1];
        Assert.isFalse(updatedCon1.MC_Contact__c, 'MC_Contact__c should be set to false');

        Test.stopTest();
	}
}