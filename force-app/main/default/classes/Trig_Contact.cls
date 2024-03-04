/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 27 Sep 2019
  @Description : Class for Contact Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
public with sharing class Trig_Contact implements UtilTrigHandle
{
	// *********************************************************************
	// *** Disable logic

	public static Boolean TrigDisabled = false;
	public static Boolean isRunningHandleMarketingCloudContact = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().Contact_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}

	// *********************************************************************
	// *** Trigger contexts

	public void BeforeInsert(List<SObject> newSObjs) {

		List<SObject> newDERSObjs = new List<SObject>();
		for (SObject newSObj : newSObjs) {

			String rtName = UtilDatabase.getRecordTypes().get((Id)newSObj.get('RecordTypeId'));
			if (rtName != 'REMI Contact') {
				newDERSObjs.add(newSObj);
			}
		}

		qualifyContact_CustomerTypeUpdate(newDERSObjs, null);
	}

	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) {

		Map<Id,SObject> newDERSObjs = new Map<Id,SObject>();
		Map<Id,SObject> oldDERSObjs = new Map<Id,SObject>();
		for (Id sObjId : newSObjs.keySet()) {

			SObject newSObj = newSObjs.get(sObjId);
			String rtName = UtilDatabase.getRecordTypes().get((Id)newSObj.get('RecordTypeId'));
			if (rtName != 'REMI Contact') {
				newDERSObjs.put(sObjId,newSObj);
				oldDERSObjs.put(sObjId,oldSObjs.get(sObjId));
			}
		}

		qualifyContact_CustomerTypeUpdate(newDERSObjs.values(), oldDERSObjs);
	}

	public void AfterInsert(Map<Id, SObject> newSObjs)
	{
		setDCPSecondaryContact(newSObjs.values());

		// Sync Contact Point Phone and Email records.
		CE_ContactPointSync2.syncCPPCPEFields((List<Contact>)newSObjs.values(), null);
	}

	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{

		Map<Id,SObject> newDERSObjs = new Map<Id,SObject>();
		Map<Id,SObject> oldDERSObjs = new Map<Id,SObject>();
		for (Id sObjId : newSObjs.keySet()) {

			SObject newSObj = newSObjs.get(sObjId);
			String rtName = UtilDatabase.getRecordTypes().get((Id)newSObj.get('RecordTypeId'));
			if (rtName != 'REMI Contact') {
				newDERSObjs.put(sObjId,newSObj);
				oldDERSObjs.put(sObjId,oldSObjs.get(sObjId));
			}
		}

		qualifyContact_NotifFieldUpdate(newDERSObjs, oldDERSObjs);
		qualifyContact_CustomerEmailUpdate(newDERSObjs, oldDERSObjs);
		qualifyContact_CustomerLicenseUpdate(newDERSObjs, oldDERSObjs);
		handleMarketingCloudContact(newSObjs.values(), (Map<Id, Contact>) oldSObjs);

		// Sync Contact Point Phone and Email records.
		CE_ContactPointSync2.syncCPPCPEFields((List<Contact>)newSObjs.values(), (Map<Id, Contact>)oldSObjs);
	}


	// if context is not implemented, condense into one-liners
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> newSObjs) {}
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}

	// *********************************************************************
	// *** Trigger methods

	private static void setDCPSecondaryContact(List<Contact> newCons)
	{
		Set<Id> conIds = new Set<Id>();

		for (Contact con: newCons)
		{
			String RT_Name = UtilDatabase.getRecordTypes().get(con.RecordTypeId);

			if (RT_Name == Outage_IncidentProcessor.CON_DCP_RT &&
				con.DCP_Secondary_Contact__c)
			{
				// do stuff here.
				conIds.add(con.Id);
			}
		}

		if (conIds.isEmpty())
		{
			// nothing to do
			return;
		}

		List<AccountContactRelation> ACRs = [SELECT Id, AccountId, ContactId, Roles FROM AccountContactRelation WHERE ContactId IN :conIds];

		for (AccountContactRelation acr: ACRs)
		{
			acr.Roles = Outage_IncidentProcessor.ACR_ROLE_SEC_CON;
		}

		Trig_AccountContactRelationship.isRunningHandleMarketingCloudContact = false;
		update ACRs;
	}

	private static void handleMarketingCloudContact(List<Contact> contactsListNew, Map<Id, Contact> contactsMapOld) {
		// Catch to stop trigger re-running (isRunningHandleMarketingCloudContact)
		if (isRunningHandleMarketingCloudContact) return;
		isRunningHandleMarketingCloudContact = true;
		System.debug('*** Trig_Contact.handleMarketingCloudContact()');

		if (!Trigger.isUpdate || contactsMapOld == null) return;

		Id dcpRecordTypeId =  UtilDatabase.getRecordTypeNames('Contact').get(Outage_IncidentProcessor.CON_DCP_RT);
		Set<Id> dcpContactIdSet = new Set<Id>();

		for (Contact conNew : contactsListNew)
		{
			if (conNew.RecordTypeId != dcpRecordTypeId) continue;

			Contact conOld = contactsMapOld.get(conNew.Id);
			if (conNew.AccountId == conOld.AccountId) continue;

			dcpContactIdSet.add(conNew.id);
		}

		if (!dcpContactIdSet.isEmpty())
			Outage_AccountContactUtils.handleMarketingCloudContactByContactIds(dcpContactIdSet);
	}


	//----------------------------------------------------------------------------//
	//----- Validate Contact reocrds for Notification fields update on Contact ---//
	//----------------------------------------------------------------------------//

	private void qualifyContact_NotifFieldUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		System.debug('*** Trig_Contact.qualifyContact_NotifFieldUpdate()');
		Map<Id, Id> validAccContIds = new Map<Id, Id>();

		Map<Id, String> validContPop_Name = new Map<Id, String>();
		Map<Id, String> validContPop_Email = new Map<Id, String>();
		List<Id> validContClear_Email = new List<Id>();

		switch on Trigger.operationType {
			when AFTER_UPDATE {
				for(sObject sObjItem: newSObjs.values())
				{
					Contact newContact = (Contact)sObjItem;
					Contact oldContact = (Contact)oldSObjs.get(newContact.Id);

					if(isPopulated('FirstName', newContact, oldContact) || isPopulated('LastName', newContact, oldContact))
					{
						validContPop_Name.put(newContact.Id, newContact.FirstName + ' ' + newContact.LastName);
						validAccContIds.put(newContact.AccountId, newContact.Id);

					}

					if(isCleared('FirstName', newContact, oldContact))
					{
						validContPop_Name.put(newContact.Id, newContact.LastName);
						validAccContIds.put(newContact.AccountId, newContact.Id);
					}

					if(isPopulated('Email', newContact, oldContact))
					{
						validContPop_Email.put(newContact.Id, newContact.Email);
						validAccContIds.put(newContact.AccountId, newContact.Id);
					}
					else if(isCleared('Email', newContact, oldContact))
					{
						validContClear_Email.add(newContact.Id);
						validAccContIds.put(newContact.AccountId, newContact.Id);
					}
				}
			}
		}
		if(!validContPop_Name.isEmpty() || !validContPop_Email.isEmpty() || !validContClear_Email.isEmpty())
			DER_Notification_Util.UpdateNotifFields(validContPop_Name, validContPop_Email, validContClear_Email, validAccContIds);

	}

	//----------------------------------------------------------------------------//
	//----- Validate Contact reocrds for Customer email field update on Case -----//
	//----------------------------------------------------------------------------//

	private void qualifyContact_CustomerEmailUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		System.debug('*** Trig_Contact.qualifyContact_CustomerEmailUpdate()');

		Map<Id, String> validEmail_Pop = new Map<Id, String>();
		List<Id> validEmail_Clear = new List<Id>();

		switch on Trigger.operationType {
			when AFTER_UPDATE {
				for(sObject sObjItem: newSObjs.values())
				{
					Contact newCont = (Contact)sObjItem;
					Contact oldCont = (Contact)oldSObjs.get(newCont.Id);

					if(isPopulated('Email', newCont, oldCont) && newCont.AccountId != null)
					{
						validEmail_Pop.put(newCont.AccountId, newCont.Email);
					}

					if(isCleared('Email', newCont, oldCont) && newCont.AccountId != null)
					{
						validEmail_Clear.add(newCont.AccountId);
					}
				}
			}
		}
		if(!validEmail_Pop.isEmpty() || !validEmail_Clear.isEmpty())
			DER_Notification_Util.UpdateCustomerEmail_BusinessAcc(validEmail_Pop, validEmail_Clear);

	}
	//----------------------------------------------------------------------------//
	//----- Validate Contact reocrds for Customer License field update on Contact -----//
	//----------------------------------------------------------------------------//

	private void qualifyContact_CustomerLicenseUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		System.debug('*** Trig_Contact.qualifyContact_CustomerLicenseUpdate()');


		Set<Id> validContact = new Set<Id>();

		switch on Trigger.operationType {
			when AFTER_UPDATE {
				for(sObject sObjItem: newSObjs.values())
				{
					Contact newCont = (Contact)sObjItem;
					Contact oldCont = (Contact)oldSObjs.get(newCont.Id);
					system.debug('old community license:'+oldCont.UserCommunityLicense__c);
					system.debug('new community license:'+newCont.UserCommunityLicense__c);
					if(oldCont.UserCommunityLicense__c!=newCont.UserCommunityLicense__c)
					{
						system.debug('in if');
						validContact.add(newCont.id);
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

	private void qualifyContact_CustomerTypeUpdate(List<SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		Map<Id, Contact> validContacts = new Map<Id, Contact>();

		switch on Trigger.operationType {
			when BEFORE_INSERT {
				for(sObject sObjItem: newSObjs)
				{
					Contact newCont = (Contact)sObjItem;
					if(String.isNotBlank(newCont.AccountId))
					{
						validContacts.put(newCont.AccountId, newCont);
					}
				}
			}
			when BEFORE_UPDATE {
				for(sObject sObjItem: newSObjs)
				{
					Contact newCont = (Contact)sObjItem;
					Contact oldCont = (Contact)oldSObjs.get(newCont.Id);
					if(isPopulated('AccountId', newCont, oldCont))
					{
						validContacts.put(newCont.AccountId, newCont);
					}
				}
			}
		}
		if(!validContacts.isEmpty())
			TVE_Contact_Utility.updateCustomerTypeByContacts(validContacts);
	}

	// ---------------------------------------------------//
	//------- Contact Trigger utility methods ---------------//
	// ---------------------------------------------------//

	private static Boolean isCleared(String f, Contact newContact, Contact oldContact)
	{
		return String.isBlank((String)newContact.get(f)) && ((String)newContact.get(f)) != ((String)oldContact.get(f));
	}

	private static Boolean isPopulated(String f, Contact newContact, Contact oldContact)
	{
		return String.isNotBlank((String)newContact.get(f)) && ((String)newContact.get(f)) != ((String)oldContact.get(f));
	}
}