// *****************************************************************
// ** Volume_TestingTools
// ** Description : This class is used to create premise records for volume testing
// Created by: Rahul Singh
// Owner: IBM
// *****************************************************************
public with sharing class Volume_TestingTools {

	public static List<vlocity_cmt__ServicePoint__c> nmis;
	public static List<Account> accs;
	public static Integer recordSize=0;
	public static List<Contact> cons;
	public static List<AccountContactRelation> ACRs;
	static List<ContactPointEmail>  CPEmails;
	static List<ContactPointPhone> CPPhones;
	static List<ContactPointConsent> CPConsents;

	 public static void generatePremises(List<vlocity_cmt__Premises__c> newSObjs){
		System.debug('GeneratePrem');
		for(vlocity_cmt__Premises__c itr: newSObjs)
		{
			if(itr.Test_Data__c){
				itr.Name = itr.vlocity_cmt__StreetAddress__c = Outage_DataFactory.randomNum(4) + ' ' + Outage_DataFactory.randomLastName() + ' Street';
				itr.vlocity_cmt__City__c = 'Melbourne';
				itr.vlocity_cmt__State__c = 'VIC';
				itr.vlocity_cmt__PostalCode__c = '3001';
				itr.vlocity_cmt__Status__c = 'Connected';
			}
		}
	}

	public static void createAllRelatedRecords(Map<Id, SObject> newSObjs)
	{
		CE_ContactPointSync2.isRunningContactUpdate    = true;
		CE_ContactPointSync2.isRunningCPPCPEUpdate     = true;
		CE_ContactPointSync2.disableAccountPrimConTrig = true;

		List<vlocity_cmt__Premises__c> premiselst = new List<vlocity_cmt__Premises__c>();
		nmis = new List<vlocity_cmt__ServicePoint__c>();

		for(Id itr : newSObjs.keySet())
		{
			if(((vlocity_cmt__Premises__c)newSObjs.get(itr)).Test_Data__c){
				vlocity_cmt__ServicePoint__c nmi = new vlocity_cmt__ServicePoint__c();
				nmi.Name = nmi.vlocity_cmt__MarketIdentifier__c = ((vlocity_cmt__Premises__c)newSObjs.get(itr)).Test_NMI__c;
				nmi.vlocity_cmt__ServiceType__c = 'Electricity';
				nmi.vlocity_cmt__Status__c = 'Connected';
				nmi.vlocity_cmt__PremisesId__c = itr;
				recordSize++;
				premiselst.add((vlocity_cmt__Premises__c)newSObjs.get(itr));
				nmis.add(nmi);
			}

		}

		insert nmis;

		accs = new List<Account>();
		Integer numRecords = 0;
		for(vlocity_cmt__Premises__c itr : premiselst)
		{
			if(numRecords<recordSize){
				Account a = new Account();

				// recordtype
				a.RecordTypeId = UtilDatabase.getRecordTypeNames('Account').get(Outage_IncidentProcessor.ACC_SERVICE_RT);

				a.Name = Outage_DataFactory.randomName() + ' Service Account';
				a.Market_Identifier__c = nmis.get(numRecords).Id;
				a.vlocity_cmt__PremisesId__c = itr.Id;
				a.ShippingStreet = itr.vlocity_cmt__StreetAddress__c;
				a.ShippingCity = itr.vlocity_cmt__City__c;
				a.ShippingState = itr.vlocity_cmt__State__c;
				a.ShippingPostalCode = itr.vlocity_cmt__PostalCode__c;

				accs.add(a);

				numRecords++;
			}

		}

		insert accs;

		cons = new List<Contact>();

		while (recordSize > 0)
		{
			recordSize--;

			Contact con = new Contact();

			// recordtype
			con.RecordTypeId = UtilDatabase.getRecordTypeNames('Contact').get(Outage_IncidentProcessor.CON_DCP_RT);
			String accName = accs.get(recordSize).Name.removeEnd(' Service Account');

			con.FirstName = accName.split(' ').get(0);
			con.LastName  = accName.split(' ').get(1);
			con.AccountId = accs.get(recordSize).Id;

			con.MobilePhone = Outage_DataFactory.getMobileNum();
			con.Phone = '039' + Outage_DataFactory.randomNum(7);
			con.Email = con.FirstName.toLowerCase() + '@' + con.LastName.toLowerCase() + '.com.invalid';
			con.MailingStreet     = accs.get(recordSize).ShippingStreet;
			con.MailingCity       = accs.get(recordSize).ShippingCity;
			con.MailingState      = accs.get(recordSize).ShippingState;
			con.MailingPostalCode = accs.get(recordSize).ShippingPostalCode;

			cons.add(con);
		}

		insert cons;

		// Primary contact Id here
		Map<Id, Account> mapAccs = new Map<Id, Account>(accs);
		List<Account> updAccs = new List<Account>();

		for (Contact con: cons)
		{
			Account acc = mapAccs.get(con.AccountId);
			acc.vlocity_cmt__PrimaryContactId__c = con.Id;
			acc.Contact_Matched__c = Outage_AccountContactUtils.CON_MATCHED_FOUND;
			updAccs.add(acc);
		}

		update updAccs;

		ACRs = [SELECT Id, AccountId, ContactId, Roles FROM AccountContactRelation WHERE ContactId IN :cons];

		for (AccountContactRelation acr: ACRs)
		{
			acr.Roles = Outage_IncidentProcessor.ACR_ROLE_MKT_CON;
		}

		update ACRs;

		System.debug('generateContactPoints');
		CPEmails = new List<ContactPointEmail>();
		CPPhones = new List<ContactPointPhone>();

		for (Contact con: cons)
		{
			if (con.MobilePhone != null)
			{
				CPPhones.add(Outage_DataFactory.generateCPP(con.Id, con.MobilePhone, true, 'MobilePhone'));
			}

			if (con.Phone != null)
			{
				CPPhones.add(Outage_DataFactory.generateCPP(con.Id, con.Phone, true, 'Phone'));
			}

			if (con.Email != null)
				CPEmails.add(Outage_DataFactory.generateCPE(con.Id, con.Email, true, 'Email'));
		}

		if (!CPEmails.isEmpty()) insert CPEmails;
		if (!CPPhones.isEmpty()) insert CPPhones;

		System.debug('GeneratePrem');
		CPConsents = new List<ContactPointConsent>();
		Outage_DataFactory odVar = new Outage_DataFactory();
		for (ContactPointEmail cpe: CPEmails)
		{
			ContactPointConsent cpc = new ContactPointConsent();
			cpc.Name = 'CPC record';
			cpc.Contact__c = cpe.Contact__c;
			cpc.ContactPointId = cpe.Id;
			cpc.CaptureSource = 'Test data';
			cpc.CaptureDate = System.now().addDays(-1);
			cpc.EffectiveFrom = cpc.CaptureDate;
			cpc.EngagementChannelTypeId = odVar.getChannelId(Outage_IncidentProcessor.CHANNEL_EMAIL);
			cpc.DataUsePurposeId = odVar.getPurposeId(Outage_IncidentProcessor.DATAUSE_OUTAGES);

			CPConsents.add(cpc);
		}

		for (ContactPointPhone cpp: CPPhones)
		{
			if (cpp.PhoneType != 'Mobile') continue;

			ContactPointConsent cpc = new ContactPointConsent();
			cpc.Name = 'CPC record';
			cpc.Contact__c = cpp.Contact__c;
			cpc.ContactPointId = cpp.Id;
			cpc.CaptureSource = 'Test data';
			cpc.CaptureDate = System.now().addDays(-1);
			cpc.EffectiveFrom = cpc.CaptureDate;
			cpc.EngagementChannelTypeId = odVar.getChannelId(Outage_IncidentProcessor.CHANNEL_SMS);
			cpc.DataUsePurposeId = odVar.getPurposeId(Outage_IncidentProcessor.DATAUSE_OUTAGES);
			// CPConsents.add(cpc);
		}

		if (!CPConsents.isEmpty()) insert CPConsents;

	}

	public static void deleteAllTestData(Map<Id, SObject> newSObjs)
	{
		List<Id> premiseIdlst = new List<Id>();

		for(Id itr : newSObjs.keySet())
		{
			if (((vlocity_cmt__Premises__c)newSObjs.get(itr)).Test_Data__c && 
				((vlocity_cmt__Premises__c)newSObjs.get(itr)).Delete_Test_Data__c)
			{
				premiseIdlst.add(itr);
			}
		}

		if (premiseIdlst.isEmpty()) return;

		List<vlocity_cmt__ServicePoint__c> servPointlst = [SELECT ID FROM vlocity_cmt__ServicePoint__c WHERE vlocity_cmt__PremisesId__c=: premiseIdlst];
		List<Id> accountIdLst = new List<Id>();
		List<Id> contatctIdLst = new List<Id>();
		List<Account> accountLst = new List<Account>();
		List<Contact> contatctLst = new List<Contact>();

		for(Account itr : [SELECT ID FROM Account WHERE vlocity_cmt__PremisesId__c=: premiseIdlst]){
		  	accountIdLst.add(itr.ID);
			accountLst.add(itr);
		}

		for(Contact itr : [SELECT ID FROM Contact WHERE AccountId=:accountIdLst]){
			contatctIdLst.add(itr.ID);
			contatctLst.add(itr);
		}

		List<Affected_Market_Identifier__c> lstAMIs = [SELECT ID FROM Affected_Market_Identifier__c WHERE uom_Service_Account__c =: accountIdLst];

		List<ContactPointEmail> cpEmail = [SELECT ID FROM ContactPointEmail WHERE Contact__c =: contatctIdLst];
		List<ContactPointPhone> cpPhones = [SELECT ID FROM ContactPointPhone WHERE Contact__c =: contatctIdLst];
		List<ContactPointConsent> cpConsent = [SELECT ID FROM ContactPointConsent WHERE Contact__c =: contatctIdLst];

		if(!cpConsent.isEmpty()) DELETE cpConsent;
		if(!cpPhones.isEmpty()) DELETE cpPhones;
		if(!cpEmail.isEmpty()) DELETE cpEmail;
		if(!contatctLst.isEmpty()) DELETE contatctLst;
		if(!lstAMIs.isEmpty()) DELETE lstAMIs;
		if(!accountLst.isEmpty()) DELETE accountLst;
		if(!servPointlst.isEmpty()) DELETE servPointlst;
		deletePremise(premiseIdlst);

	}

	@future
	public static void deletePremise(List<ID> recordIds){
		List<vlocity_cmt__Premises__c> premiselst = [SELECT Id FROM vlocity_cmt__Premises__c WHERE Id IN :recordIds];
		if(!premiselst.isEmpty()) DELETE premiselst;
	}
}