public with sharing class Outage_AccountContactUtils {

	public static final String CON_MATCHED_MULTIPLE = 'Multiple Contacts Found';
	public static final String CON_MATCHED_FOUND = 'Contact Found';
	public static final String CON_MATCHED_NONE = 'No Contacts Found';

	/********** Constructor **********/

	// public Outage_AccountContactUtils() { /* No Constructor required atm*/ }


	/********** Main methods **********/

	public static void handleMarketingCloudContactByContactIds(Set<Id> contactIds)
	{
		Id serviceRecordTypeId =  UtilDatabase.getRecordTypeNames('Account').get(Outage_IncidentProcessor.ACC_SERVICE_RT);
		List<Contact> contactsToUpdate = new List<Contact>();

		for (Contact con : [SELECT Id, Name, MC_Contact__c, Account.vlocity_cmt__PrimaryContactId__c, Account.RecordTypeId,

								(SELECT Id, ContactId, AccountId, Roles
								 FROM AccountContactRelations
								 WHERE Account.Market_Identifier__c != null
								 AND Account.Market_Identifier__r.vlocity_cmt__Status__c = :Outage_IncidentProcessor.SERV_POINT_STS_ACTIVE
								 AND Account.Market_Identifier__r.vlocity_cmt__ServiceType__c = 'Electricity'
								 AND Account.Market_Identifier__r.dcp_NMIStatus_To_Date__c = null
								 AND (Roles includes(:Outage_IncidentProcessor.ACR_ROLE_MKT_CON) OR Roles includes(:Outage_IncidentProcessor.ACR_ROLE_SEC_CON))
								 LIMIT 1),

								 (SELECT Id, Name FROM vlocity_cmt__Accounts__r
								 WHERE RecordType.Name = :Outage_IncidentProcessor.ACC_SERVICE_RT
								 AND Market_Identifier__c != null
								 AND Market_Identifier__r.vlocity_cmt__Status__c = :Outage_IncidentProcessor.SERV_POINT_STS_ACTIVE
								 AND Market_Identifier__r.vlocity_cmt__ServiceType__c = 'Electricity'
								 AND Market_Identifier__r.dcp_NMIStatus_To_Date__c = null
								 LIMIT 1)

							FROM Contact
							WHERE Id IN :contactIds])
		{
			if (con.AccountContactRelations.size() >= 1 || con.vlocity_cmt__Accounts__r.size() >= 1) {

				if (!con.MC_Contact__c) {
					con.MC_Contact__c = true;
					contactsToUpdate.add(con);
				}

			} else if (con.MC_Contact__c) {
				con.MC_Contact__c = false;
				contactsToUpdate.add(con);
			}
		}

		if (!contactsToUpdate.isEmpty()) {
			update contactsToUpdate;
		}
	}

	public static void runAccountContactMatching()
	{
		String query = Outage_AccountContactBatch.getBatchQuery();
		List<AccountContactRelation> ACRsList = Database.query(query);

		Set<Id> accIds = new Set<Id>();
		for (AccountContactRelation acr: ACRsList)
			accIds.add(acr.AccountId);

		List<Account> accountsAndACRsList = [SELECT Id, Name, vlocity_cmt__PrimaryContactId__c, Contact_Matched__c,
											(SELECT Id, ContactId, AccountId, Roles
												FROM AccountContactRelations
												LIMIT 2)
											FROM Account 
											WHERE Id IN :accIds];

		if (accountsAndACRsList == null || accountsAndACRsList.isEmpty())
		{
			// crash
			System.debug('bad');
			return ;
		}

		processAccountContactMatching(accountsAndACRsList);
	}

	public static void processAccountContactMatching(List<Account> accountsAndACRsList)
	{
		if (accountsAndACRsList == null || accountsAndACRsList.isEmpty()) return;

		List<Account> accountsToUpdate = new List<Account>();

		for (Account acc : accountsAndACRsList)
		{
			// Grab prior values
			Id     PrimConId  = acc.vlocity_cmt__PrimaryContactId__c;
			String ConMatched = acc.Contact_Matched__c;

			if (acc.AccountContactRelations.isEmpty())
			{
				acc.vlocity_cmt__PrimaryContactId__c = null;
				acc.Contact_Matched__c = CON_MATCHED_NONE;
			}
			else if (acc.AccountContactRelations.size() == 1 && String.isBlank(acc.vlocity_cmt__PrimaryContactId__c))
			{
				acc.vlocity_cmt__PrimaryContactId__c = acc.AccountContactRelations[0].ContactId;
				acc.Contact_Matched__c = CON_MATCHED_FOUND;

			}
			else if (acc.AccountContactRelations.size() >= 1)
			{

				if (String.isNotBlank(acc.vlocity_cmt__PrimaryContactId__c))
				{
					acc.Contact_Matched__c = CON_MATCHED_FOUND;
				}
				else
				{
					acc.Contact_Matched__c = CON_MATCHED_MULTIPLE;
				}
			}

			// Only update if values have changed
			if (acc.vlocity_cmt__PrimaryContactId__c != PrimConId ||
				acc.Contact_Matched__c != ConMatched)
			{
				accountsToUpdate.add(acc);
			}
		}

		if (!accountsToUpdate.isEmpty())
			update accountsToUpdate;
	}

	public static void processMCContactCheckbox(List<Account> argAccs)
	{
		Set<Id> contactIds = new Set<Id>();

		for (Account acc: [SELECT Id, vlocity_cmt__PrimaryContactId__c
							FROM Account
							WHERE Id IN :argAccs])
		{
			if (acc.vlocity_cmt__PrimaryContactId__c != null)
				contactIds.add(acc.vlocity_cmt__PrimaryContactId__c);
		}

		for (AccountContactRelation acr: [SELECT Id, ContactId, AccountId, Roles 
											FROM AccountContactRelation
											WHERE AccountId IN :argAccs
											AND Account.RecordType.Name = :Outage_IncidentProcessor.ACC_SERVICE_RT
											AND Account.Market_Identifier__c != null
											AND Account.Market_Identifier__r.vlocity_cmt__Status__c = :Outage_IncidentProcessor.SERV_POINT_STS_ACTIVE
											AND Account.Market_Identifier__r.vlocity_cmt__ServiceType__c = 'Electricity'
											AND Account.Market_Identifier__r.dcp_NMIStatus_To_Date__c = null
											AND Contact.IsPersonAccount = false
											AND (Roles INCLUDES(:Outage_IncidentProcessor.ACR_ROLE_MKT_CON) 
												 OR Roles INCLUDES(:Outage_IncidentProcessor.ACR_ROLE_SEC_CON))])
		{
			contactIds.add(acr.ContactId);
		}

		handleMarketingCloudContactByContactIds(contactIds);
	}

	public static void optOutContactPhoneNumbers(Set<String> stopNumbers)
	{
		String STOP_REASON = 'Consent Removed: Number on Stop List';

		// Ensure numbers are formated correctly, or they won't match
		//		eg 61400123456

		for (String phNum: stopNumbers)
		{
			String newPhNum = CE_ContactPointSync2.getMobileFormat(phNum);
			if (phNum != newPhNum)
			{
				stopNumbers.add(newPhNum);
				stopNumbers.remove(phNum);
			}
		}

		UtilDatabase db = new UtilDatabase();

		for (ContactPointConsent CPC: [SELECT Id, Name, Contact__r.Name, Status__c, Contact_Point__c, EffectiveFrom
										FROM ContactPointConsent
										WHERE Contact_Point__c IN :stopNumbers
										AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE
										AND DataUsePurpose.Name = :Outage_IncidentProcessor.DATAUSE_OUTAGES
										AND EngagementChannelType.Name = :Outage_IncidentProcessor.CHANNEL_SMS])
		{
			CPC.EffectiveTo = CPC.EffectiveFrom;
			CPC.CaptureSource = STOP_REASON;
			CPC.CaptureDate = System.now();

			db.addObjForUpsert(CPC);
		}

		db.upsertObjs();
	}

	/********** Helper methods **********/
}