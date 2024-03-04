/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 27 Sep 2019
  @Description : Class for Account Trigger
  -----------------------------------------------------------------------------------------
  Change log
 -----------------------------------------------------------------------------------------
Date                Name                           		    Description
-----------------------------------------------------------------------------------------
11-APR-22	        syed.muhammadali@ausnetservices.com.au  Record type seggregation changes for Org Merge. AfterUpdate changed.
-----------------------------------------------------------------------------------------
*/
public with sharing class Trig_Account implements UtilTrigHandle
{
	// *********************************************************************
	// *** Disable logic

	public static Boolean TrigDisabled = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().Account_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}

	// *********************************************************************
	// *** Trigger contexts
	@testvisible private static Set<String> recordTypesDER = new Set<String>{'Customer_Business', 'Service_Provider', 'PersonAccount', 'Business_Account', 'Customer_Individual'};
	@testvisible private static Set<String> recordTypesMVP = new Set<String>{'Advertiser', 'Agency', 'Billing', 'BillingAggregator', 'Brand', 'Business', 'Consumer', 'MobilePhoneAccount', 'Other', 'Service', 'ServiceAggregator', 'dcp_Suggested_Contact'};

	public void AfterInsert(Map<Id, SObject> newSObjs)
	{
		handleMarketingCloudContact(newSObjs.values(), null);
		newDCPPrimaryContact(newSObjs.values(), null);
	}

	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		handleMarketingCloudContact(newSObjs.values(), (Map<Id, Account>) oldSObjs);
		newDCPPrimaryContact(newSObjs.values(), (Map<Id, Account>)oldSObjs);
		
		something(newSObjs.values(), oldSObjs.values()); // old crap code - I put it into a separate method because lazy dev trashed the AfterUpdate method.
	}

	// if context is not implemented, condense into one-liners
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> newSObjs) {}
	public void BeforeInsert(List<SObject> newSObjs) {}
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs){}

	// *********************************************************************
	// *** Trigger methods

	private static void newDCPPrimaryContact(List<Account> newAccounts, Map<Id, Account> oldAccounts)
	{
		if (newAccounts == null || newAccounts.isEmpty())
			return;

		Boolean isUpdate = false;
		if (Trigger.isUpdate != null)
		{
			// check which object is triggered.
			if (Trigger.new[0] instanceOf Account)
				isUpdate = Trigger.isUpdate;
		}

		Set<Id> qualifiedCons = new Set<Id>();

		for (Account acc: newAccounts)
		{
			if (acc.RecordTypeId == null) continue;

			if (UtilDatabase.getRecordTypes().get(acc.RecordTypeId) != Outage_IncidentProcessor.ACC_SERVICE_RT)
				continue;

			if (!isUpdate)
			{
				// is insert
				if (acc.vlocity_cmt__PrimaryContactId__c != null)
					qualifiedCons.add(acc.vlocity_cmt__PrimaryContactId__c);

				continue;
			}

			Account oldAcc = oldAccounts.get(acc.Id);

			if (acc.vlocity_cmt__PrimaryContactId__c != null &&
				acc.vlocity_cmt__PrimaryContactId__c != oldAcc.vlocity_cmt__PrimaryContactId__c)
			{
				qualifiedCons.add(acc.vlocity_cmt__PrimaryContactId__c);
			}
		}

		if (!qualifiedCons.isEmpty())
			CE_ContactPointSync2.createRetailerDefaultConsents(qualifiedCons);
	}

	private static void handleMarketingCloudContact(List<Account> accountsListNew, Map<Id, Account> accountsMapOld) {
		System.debug('*** Trig_Account.handleMarketingCloudContact()');
		Id serviceRecordTypeId =  UtilDatabase.getRecordTypeNames('Account').get(Outage_IncidentProcessor.ACC_SERVICE_RT);
		Map<Id, Account> serviceAccountIdtoAccountMapNew = new Map<Id, Account>();
		Map<Id, Account> serviceAccountIdtoAccountMapOld = new Map<Id, Account>();

		for (Account accNew : accountsListNew) {

			if (accNew.RecordTypeId == serviceRecordTypeId) {

				serviceAccountIdtoAccountMapNew.put(accNew.id, accNew);
				if (accountsMapOld == null) continue;

				Account accOld = accountsMapOld.get(accNew.Id);
				serviceAccountIdtoAccountMapOld.put(accOld.id, accOld);
			}
		}

		if (serviceAccountIdtoAccountMapNew.isEmpty()) return;

		if (Trigger.isInsert && accountsMapOld == null) {
			handleMarketingCloudContactAfterInsert(serviceAccountIdtoAccountMapNew.values());
		} else if (Trigger.isUpdate && !serviceAccountIdtoAccountMapOld.isEmpty()) {
			handleMarketingCloudContactAfterUpdate(serviceAccountIdtoAccountMapNew, serviceAccountIdtoAccountMapOld);
		}
	}

	private static void handleMarketingCloudContactAfterInsert (List<Account> accountsList) {
		Set<Id> validContactIdSet = new Set<Id>();

		for (Account acc : accountsList) {
			if (String.isNotBlank(acc.vlocity_cmt__PrimaryContactId__c)) {
				validContactIdSet.add(acc.vlocity_cmt__PrimaryContactId__c);
			}
		}

		if (!validContactIdSet.isEmpty()) {
			Outage_AccountContactUtils.handleMarketingCloudContactByContactIds(validContactIdSet);
		}
	}

	private static void handleMarketingCloudContactAfterUpdate (Map<Id, Account> accountIdtoAccountMapNew, Map<Id, Account> accountIdtoAccountMapOld) {
		Set<Id> validContactIdSet = new Set<Id>();

		for (Account accNew : accountIdtoAccountMapNew.values()) {

			Account accOld = accountIdtoAccountMapOld.get(accNew.Id);

			if (String.isBlank(accOld.vlocity_cmt__PrimaryContactId__c) && String.isBlank(accNew.vlocity_cmt__PrimaryContactId__c)) {
				continue;
			} else if (String.isBlank(accOld.vlocity_cmt__PrimaryContactId__c) && String.isNotBlank(accNew.vlocity_cmt__PrimaryContactId__c)) {
				validContactIdSet.add(accNew.vlocity_cmt__PrimaryContactId__c);
			} else if (String.isNotBlank(accOld.vlocity_cmt__PrimaryContactId__c) && String.isBlank(accNew.vlocity_cmt__PrimaryContactId__c)) {
				validContactIdSet.add(accOld.vlocity_cmt__PrimaryContactId__c);
			} else if (accOld.vlocity_cmt__PrimaryContactId__c != accNew.vlocity_cmt__PrimaryContactId__c) {
				validContactIdSet.add(accOld.vlocity_cmt__PrimaryContactId__c);
				validContactIdSet.add(accNew.vlocity_cmt__PrimaryContactId__c);
			}
		}

		if (!validContactIdSet.isEmpty()) {
			Outage_AccountContactUtils.handleMarketingCloudContactByContactIds(validContactIdSet);
		}
	}

	//----------------------------------------------------------------------------//
	//----- Validate Account reocrds for Notification fields update on Account ---//
	//----------------------------------------------------------------------------//

	private void something(List<Account> accountsNew, List<Account> accountsOld)
	{

		//Segregating new records
		List<Account> accountsDERNew = new List<Account>(); List<Account> accountsMVPNew = new List<Account>(); Map<Id, Account> accountsFromIdDERNew=new Map<Id, Account>();

		for (Account c: accountsNew){
			// If no record type, skip record.
			if (c.RecordTypeId == null) {
				System.debug('**NULL record type encountered.');
			}
			// If record type not listed in recordTypesDER or recordTypesMVP, skip record.
			String RTName = UtilDatabase.getRecordTypes().get(c.RecordTypeId);
			if (recordTypesDER.contains(RTName)){
				accountsDERNew.add(c);
				accountsFromIdDERNew.put(c.id, c);
			}
			if (recordTypesMVP.contains(RTName)){
				accountsMVPNew.add(c);
			}
		}
		//Segregating old records
		List<Account> accountsDEROld = new List<Account>(); List<Account> accountsMVPOld = new List<Account>(); Map<Id, Account> accountsFromIdDEROld=new Map<Id, Account>();

		for (Account c: accountsOld){
			// If no record type, skip record.
			if (c.RecordTypeId == null) {
				System.debug('**NULL record type encountered.');
			}
			// If record type not listed in recordTypesDER or recordTypesMVP, skip record.
			String RTName = UtilDatabase.getRecordTypes().get(c.RecordTypeId);
			if (recordTypesDER.contains(RTName)){
				accountsDEROld.add(c);
				accountsFromIdDEROld.put(c.id, c);
			}
			if (recordTypesMVP.contains(RTName)){
				accountsMVPOld.add(c);
			}
		}

		if(accountsDERNew.size()>0 && accountsDEROld.size()>0){ System.debug('*** Trig_Account. DER - AfterInsert');
		}

		if(accountsFromIdDERNew.size()>0 && accountsFromIdDEROld.size()>0){
			QualifyPersonAcc_NotifFieldUpdate(accountsFromIdDERNew, accountsFromIdDEROld);
			QualifyPersonAcc_CustomerEmailUpdate(accountsFromIdDERNew, accountsFromIdDEROld);
			QualifyPersonAcc_CustomerLicenseUpdate(accountsFromIdDERNew, accountsFromIdDEROld);

			QualifyBizAcc_ContactCustomerTypeUpdate(accountsFromIdDERNew, accountsFromIdDEROld);
		}

		if(accountsMVPNew.size() > 0 && accountsMVPOld.size() > 0) {
			System.debug('*** Trig_Account. DCP - AfterInsert');
		}
	}

	private void  QualifyPersonAcc_NotifFieldUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		System.debug('*** Trig_Account.QualifyPersonAcc_NotifFieldUpdate()');

		Map<Id, String> validAccPop_Name = new Map<Id, String>();
		Map<Id, String> validAccPop_Email = new Map<Id, String>();
		List<Id> validAccClear_Email = new List<Id>();

		switch on Trigger.operationType {
			when AFTER_UPDATE {
				for(sObject sObjItem: newSObjs.values())
				{
					Account newAcc = (Account)sObjItem;
					Account oldAcc = (Account)oldSObjs.get(newAcc.Id);

					if(newAcc.isPersonAccount){
						if(isPopulated('FirstName', newAcc, oldAcc) || isPopulated('LastName', newAcc, oldAcc))
						{
							validAccPop_Name.put(newAcc.Id, newAcc.FirstName + ' ' + newAcc.LastName);
						}

						if(isCleared('FirstName', newAcc, oldAcc))
						{
							validAccPop_Name.put(newAcc.Id, newAcc.LastName);
						}

						if(isPopulated('PersonEmail', newAcc, oldAcc))
						{
							validAccPop_Email.put(newAcc.Id, newAcc.PersonEmail);
						}
						else if(isCleared('PersonEmail', newAcc, oldAcc))
						{
							validAccClear_Email.add(newAcc.Id);
						}
					}
				}
			}
		}
		if(!validAccPop_Name.isEmpty() || !validAccPop_Email.isEmpty() || !validAccClear_Email.isEmpty())
			DER_Notification_Util.UpdateNotifFields_PersonAcc(validAccPop_Name, validAccPop_Email, validAccClear_Email);

	}

	//----------------------------------------------------------------------------//
	//----- Validate Account reocrds for Customer email field update on Case -----//
	//----------------------------------------------------------------------------//

	private void  QualifyPersonAcc_CustomerEmailUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		System.debug('*** Trig_Account.QualifyPersonAcc_CustomerEmailUpdate()');

		Map<Id, String> validAccPop_Email = new Map<Id, String>();
		List<Id> validAccClear_Email = new List<Id>();

		switch on Trigger.operationType {
			when AFTER_UPDATE {
				for(sObject sObjItem: newSObjs.values())
				{
					Account newAcc = (Account)sObjItem;
					Account oldAcc = (Account)oldSObjs.get(newAcc.Id);

					if(newAcc.isPersonAccount)
					{
						if(isPopulated('PersonEmail', newAcc, oldAcc))
						{
							validAccPop_Email.put(newAcc.Id, newAcc.PersonEmail);
						}

						if(isCleared('PersonEmail', newAcc, oldAcc))
						{
							validAccClear_Email.add(newAcc.Id);
						}
					}
				}
			}
		}
		if(!validAccPop_Email.isEmpty() || !validAccClear_Email.isEmpty())
			DER_Notification_Util.UpdateCustomerEmail_PersonAcc(validAccPop_Email, validAccClear_Email);

	}

	//----------------------------------------------------------------------------//
	//----- Validate Contact reocrds for Customer License field update on Contact -----//
	//----------------------------------------------------------------------------//

	private void QualifyPersonAcc_CustomerLicenseUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		System.debug('*** Trig_Account.QualifyContact_CustomerLicenseUpdate()');


		Set<Id> validContact = new Set<Id>();

		switch on Trigger.operationType {
			when AFTER_UPDATE {
				for(sObject sObjItem: newSObjs.values())
				{
					Account newAcc = (Account)sObjItem;
					Account oldAcc = (Account)oldSObjs.get(newAcc.Id);
					system.debug('old community license:'+oldAcc.UserCommunityLicense__pc );
					system.debug('new community license:'+newAcc.UserCommunityLicense__pc );
					if(oldAcc.UserCommunityLicense__pc!=newAcc.UserCommunityLicense__pc)
					{
						system.debug('in if');
						validContact.add(newAcc.personcontactid );
					}

					system.debug('Valid contact:'+validContact);
				}
			}
		}
		if(!validContact.isEmpty())
			TVE_Account_Util.UpdateProjectUrl_On_CustomerUpdate(validContact);

	}
	//----------------------------------------------------------------------------//
	//----- Validate Contact reocrds for Customer Type field update on Contact ---//
	//----------------------------------------------------------------------------//

	private void QualifyBizAcc_ContactCustomerTypeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		Set<Id> validAccount = new Set<Id>();

		switch on Trigger.operationType {
			when AFTER_UPDATE {
				for(sObject sObjItem: newSObjs.values())
				{
					Account newAcc = (Account)sObjItem;
					Account oldAcc = (Account)oldSObjs.get(newAcc.Id);
					if(!newAcc.IsPersonAccount && isPopulated('Customer_Type__c', newAcc, oldAcc))
					{
						validAccount.add(newAcc.Id);
					}
				}
			}
		}
		if(!validAccount.isEmpty())
			TVE_Contact_Utility.updateCustomerTypeByAccountIds(validAccount);
	}
	// ---------------------------------------------------//
	//------- Account Trigger utility methods ---------------//
	// ---------------------------------------------------//

	private static Boolean isCleared(String f, Account newAcc, Account oldAcc)
	{
		return String.isBlank((String)newAcc.get(f)) && ((String)newAcc.get(f)) != ((String)oldAcc.get(f));
	}

	private static Boolean isPopulated(String f, Account newAcc, Account oldAcc)
	{
		return String.isNotBlank((String)newAcc.get(f)) && ((String)newAcc.get(f)) != ((String)oldAcc.get(f));
	}

}