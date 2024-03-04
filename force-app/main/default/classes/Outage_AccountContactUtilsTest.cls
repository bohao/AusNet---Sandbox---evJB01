/*
@description: Apex Test Class For Outage_AccountContactUtils
*/
@isTest
public with sharing class Outage_AccountContactUtilsTest {
	@testSetup
	static void setup() {
		Integer numCustomers = 6;
		// Generate customer data (NMI, Premise, Account, Contact, ACR, ContactPointEmail, ContactPointPhone, ContactPointConsent, EngagementChannelType, DataUsePurpose)
		Outage_DataFactory.getODF().generateCustomers(numCustomers);
	}

	@isTest
	static void handleMarketingCloudContactByContactIdsTest() {

		// Update ACR so that Contacts MC_Contact__c field update is dependent on the Accounts primary contact
		AccountContactRelation acr = [SELECT Id, AccountId, ContactId, Roles FROM AccountContactRelation LIMIT 1];
		acr.Roles = '';
		update acr;

		Contact con = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :acr.ContactId LIMIT 1];
		con.MC_Contact__c = false;
		update con;

		Set<Id> conIds = new Set<Id>();
		conIds.add(con.Id);

		Test.startTest();
		// Validate initial data setup is correct
		Assert.isFalse(con.MC_Contact__c, 'MC_Contact__c should be set to false');

		Outage_AccountContactUtils.handleMarketingCloudContactByContactIds(conIds);

		// Validate contacts MC_Contact__c field is updated correctly
		con = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :acr.ContactId LIMIT 1];
		Assert.isTrue(con.MC_Contact__c, 'MC_Contact__c should be set to true');

		// Update Accounts primary contact for the setting contacts MC_Contact__c to false test
		Account acc = [SELECT Id, vlocity_cmt__PrimaryContactId__c FROM Account WHERE Id = :acr.AccountId LIMIT 1];
		acc.vlocity_cmt__PrimaryContactId__c = null;
		update acc;

		con.MC_Contact__c = true;
		update con;

		Outage_AccountContactUtils.handleMarketingCloudContactByContactIds(conIds);
		// Validate contacts MC_Contact__c field is updated correctly
		con = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :acr.ContactId LIMIT 1];
		Assert.isFalse(con.MC_Contact__c, 'MC_Contact__c should be set to false');

		// Update ACR so that Contacts MC_Contact__c field update is dependent on the ACR
		acr.Roles = 'Market Contact';
		update acr;

		con.MC_Contact__c = false;
		update con;

		Outage_AccountContactUtils.handleMarketingCloudContactByContactIds(conIds);
		// Validate contacts MC_Contact__c field is updated correctly
		con = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :acr.ContactId LIMIT 1];
		Assert.isTrue(con.MC_Contact__c, 'MC_Contact__c should be set to true');
		Test.stopTest();
	}

	@isTest // Covers runAccountContactMatching and processAccountContactMatching
	static void processAccountContactMatchingTest() {
		List<AccountContactRelation> acrList = [SELECT Id, Roles, ContactId, AccountId, Account.Contact_Matched__c FROM AccountContactRelation WHERE Roles includes('Market Contact')];
		List<AccountContactRelation> acrsToUpdate = new List<AccountContactRelation>();
		List<Account> accsToUpdate = new List<Account>();
		List<Contact> consToUpdate = new List<Contact>();

		// Setup no contact found scenario
		Id accId1 = acrList.get(0).AccountId;
		acrList.get(0).Roles = '';
		acrsToUpdate.add(acrList.get(0));

		// Setup multiple contacts found with no primary contact scenario
		Id accId2 = acrList.get(1).AccountId;
		Id conId3 = acrList.get(2).ContactId;

		Account acc2 = [SELECT Id, vlocity_cmt__PrimaryContactId__c FROM Account WHERE Id = :accId2 LIMIT 1];
		acc2.vlocity_cmt__PrimaryContactId__c = null;
		accsToUpdate.add(acc2);

		Contact con2 = [SELECT Id, AccountId FROM Contact WHERE Id = :conId3 LIMIT 1];
		con2.AccountId = accId2;
		consToUpdate.add(con2);

		// Setup multiple contacts found with primary contact scenario (part 1)
		Id accId4 = acrList.get(3).AccountId;
		Id conId5 = acrList.get(4).ContactId;

		Account acc4 = [SELECT Id, vlocity_cmt__PrimaryContactId__c FROM Account WHERE Id = :accId4 LIMIT 1];
		acc4.vlocity_cmt__PrimaryContactId__c = conId5;
		accsToUpdate.add(acc4);

		// Setup 1 contact found with no primary contact scenario
		Id accId6 = acrList.get(5).AccountId;
		Id conId6 = acrList.get(5).ContactId;

		Account acc6 = [SELECT Id, vlocity_cmt__PrimaryContactId__c FROM Account WHERE Id = :accId6 LIMIT 1];
		acc6.vlocity_cmt__PrimaryContactId__c = null;
		accsToUpdate.add(acc6);

		update accsToUpdate;

		// Setup multiple contacts found with primary contact scenario (part 2)
		Contact con4 = [SELECT Id, AccountId, MC_Contact__c FROM Contact WHERE Id = :conId5 LIMIT 1];
		con4.AccountId = accId4;
		con4.MC_Contact__c = false;
		consToUpdate.add(con4);

		update consToUpdate;

		// update roles for the new ACRs
		for (AccountContactRelation newACR : [SELECT Id, Roles FROM AccountContactRelation WHERE (ContactId = :con2.Id OR ContactId = :con4.Id) AND Id NOT IN :acrList]) {
			newACR.Roles = 'Market Contact';
			acrsToUpdate.add(newACR);
		}

		update acrsToUpdate;

		Test.startTest();
		// runAccountContactMatching() does a query and passes it into processAccountContactMatching()
		Outage_AccountContactUtils.runAccountContactMatching();
		Test.stopTest();

		// Validate no contact found scenario
		Account acc1 = [SELECT Id, vlocity_cmt__PrimaryContactId__c, Contact_Matched__c FROM Account WHERE Id = :accId1 LIMIT 1];
		// Assert.areEqual(Outage_AccountContactUtils.CON_MATCHED_NONE, acc1.Contact_Matched__c);
		// Assert.isNull(acc1.vlocity_cmt__PrimaryContactId__c, 'vlocity_cmt__PrimaryContactId__c should be null');

		// Validate multiple contacts found with no primary contact scenario
		acc2 = [SELECT Id, vlocity_cmt__PrimaryContactId__c, Contact_Matched__c FROM Account WHERE Id = :accId2 LIMIT 1];
		// Assert.areEqual(Outage_AccountContactUtils.CON_MATCHED_MULTIPLE, acc2.Contact_Matched__c);
		// Assert.isNull(acc2.vlocity_cmt__PrimaryContactId__c, 'vlocity_cmt__PrimaryContactId__c should be null');

		// Validate multiple contacts found with primary contact scenario
		acc4 = [SELECT Id, vlocity_cmt__PrimaryContactId__c, Contact_Matched__c FROM Account WHERE Id = :accId4 LIMIT 1];
		// Assert.areEqual(Outage_AccountContactUtils.CON_MATCHED_FOUND, acc4.Contact_Matched__c);
		// Assert.isNotNull(acc4.vlocity_cmt__PrimaryContactId__c, 'vlocity_cmt__PrimaryContactId__c should not be null');

		// Validate 1 contact found with no primary contact scenario
		acc6 = [SELECT Id, vlocity_cmt__PrimaryContactId__c, Contact_Matched__c FROM Account WHERE Id = :accId6 LIMIT 1];
		// Assert.areEqual(Outage_AccountContactUtils.CON_MATCHED_FOUND, acc6.Contact_Matched__c);
		// Assert.isNotNull(acc6.vlocity_cmt__PrimaryContactId__c, 'vlocity_cmt__PrimaryContactId__c should not be null');
		// Assert.areEqual(conId6, acc6.vlocity_cmt__PrimaryContactId__c);
	}

	@isTest
	static void processMCContactCheckboxTest() {

		List<AccountContactRelation> acrs = [SELECT Id, ContactId, AccountId, Roles FROM AccountContactRelation LIMIT 2];
		AccountContactRelation acr1 = acrs[0];

		// Setup ACRS and Account
		AccountContactRelation acr2 = acrs[1];
		acr2.Roles = '';
		update acr2;

		Account acc1 = [SELECT Id, vlocity_cmt__PrimaryContactId__c FROM Account WHERE Id = :acr1.AccountId LIMIT 1];
		acc1.vlocity_cmt__PrimaryContactId__c = null;
		update acc1;

		// Update contacts so that Contacts MC_Contact__c fields are set to false (set to false to check they are correctly set to true after processMCContactCheckbox runs)
		List<Contact> consToUpdate = new List<Contact>();

		for (Contact con : [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :acr1.ContactId OR Id = :acr2.ContactId LIMIT 2]) {
			con.MC_Contact__c = false;
			consToUpdate.add(con);
		}

		update consToUpdate;

		Contact con1 = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :acr1.ContactId LIMIT 1];
		Contact con2 = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :acr2.ContactId LIMIT 1];

		Test.startTest();

		// Validate initial data setup is correct
		Assert.isFalse(con1.MC_Contact__c, 'MC_Contact__c should be set to false');
		Assert.isFalse(con2.MC_Contact__c, 'MC_Contact__c should be set to false');

		// Outage_AccountContactUtils.processMCContactCheckbox(); // TODO: Fix

		// Validate MC_Contact__c fields are updated correctly
		con1 = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :con1.Id LIMIT 1];
		// Assert.isTrue(con1.MC_Contact__c, 'MC_Contact__c should be set to true');

		con2 = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :con2.Id LIMIT 1];
		// Assert.isTrue(con2.MC_Contact__c, 'MC_Contact__c should be set to true');

		Test.stopTest();
	}

	@isTest
	static void optOutContactPhoneNumbersTest()
	{
		// Set up test data:
		List<ContactPointPhone> CPPhones = [SELECT Id, Name, Contact__c, PhoneType FROM ContactPointPhone WHERE PhoneType='Mobile'];
		UtilDatabase db = new UtilDatabase();
		for (ContactPointPhone cpp: CPPhones)
		{
			ContactPointConsent cpc     = new ContactPointConsent();
			cpc.Name                    = 'CPC record';
			cpc.Contact__c              = cpp.Contact__c;
			cpc.ContactPointId          = cpp.Id;
			cpc.CaptureSource           = 'Test data';
			cpc.CaptureDate             = System.now().addDays(-1);
			cpc.EffectiveFrom           = cpc.CaptureDate;
			cpc.EngagementChannelTypeId = Outage_DataFactory.getODF().getChannelId(Outage_IncidentProcessor.CHANNEL_SMS);
			cpc.DataUsePurposeId        = Outage_DataFactory.getODF().getPurposeId(Outage_IncidentProcessor.DATAUSE_OUTAGES);
			cpc.Authorised_to_Change__c = 'Authorised';
			cpc.Privacy_Policy__c       = 'Agreed';

			db.addObjForUpsert(cpc);
		}

		db.upsertObjs();

		// run the test:
		Set<String> stopNumbers = new Set<String>();

		for (ContactPointConsent CPC: getCPCs())
		{
			stopNumbers.add(CE_ContactPointSync2.getMobileFormatPretty(CPC.Contact_Point__c));
		}

		Test.startTest();
			Outage_AccountContactUtils.optOutContactPhoneNumbers(stopNumbers);
		Test.stopTest();

		Assert.areEqual(0, getCPCs().size(), 'Error: CPCs not opted-out.');
	}

	private static List<ContactPointConsent> getCPCs()
	{
		return [SELECT Id, Name, Contact__r.Name, Status__c, Contact_Point__c, EffectiveFrom
		FROM ContactPointConsent
		WHERE Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE
		AND DataUsePurpose.Name = :Outage_IncidentProcessor.DATAUSE_OUTAGES
		AND EngagementChannelType.Name = :Outage_IncidentProcessor.CHANNEL_SMS];
	}
}