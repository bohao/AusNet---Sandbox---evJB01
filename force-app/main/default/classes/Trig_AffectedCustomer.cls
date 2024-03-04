public with sharing class Trig_AffectedCustomer implements UtilTrigHandle
{

	// *********************************************************************
	// *** Disable logic
	public static Boolean TrigDisabled = false;
	public static Boolean LSCTaskGenDisabled = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().Affected_Customer_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}

	public static Boolean isRunningSetMCSyncField = false;
	public static UtilDebug de;


	// *********************************************************************
	// *** Trigger contexts

	public void BeforeInsert(List<SObject> newSObjs)
	{
		// setCustomerPreferences(newSObjs); // moved to IncidentProcessor
		setLifeSupportFlag(newSObjs);
	}

	public void AfterInsert(Map<Id, SObject> newSObjs)
	{
		// Creating LSC Task for Lifesupport customer.
		createLifeSupTask(newSObjs.values());

		setSuburbList(newSObjs.values());

		insertSetMCSyncField(newSObjs.values()); // Ensure this line is last in AfterInsert
	}

	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		queueUpdatesForMCSync(newSObjs.values(), (Map<Id, Affected_Customer__c>)oldSObjs); // Ensure this line is first please

		setCustomerPreferences(newSObjs.values());
		setLifeSupportFlag(newSObjs.values());

		updateSetMCSyncField(newSObjs.values()); // Ensure this line is last in BeforeUpdate
	}

	// if context is not implemented, condense into one-liners
	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) {}
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> oldSObjs) {}


	// *********************************************************************
	// *** Trigger methods

	// setCustomerPreferences profile:
	// Runs in before context
	// Calls Outage_GetPreferences.getCustomerPreference
	// 1 SOQLs
	// 0 DMLs
	public static void setCustomerPreferences(List<Affected_Customer__c> newAffCusts) { setCustomerPreferences(newAffCusts, null); }
	public static void setCustomerPreferences(List<Affected_Customer__c> newAffCusts, UtilDebug de)
	{
		if (de == null) de = new UtilDebug();

		if (newAffCusts == null || newAffCusts.isEmpty())
		{
			de.bug('newAffCusts == null || newAffCusts.isEmpty()');
			return;
		}

		if (Outage_IncidentProcessor.isRunningCreateAffCust)
		{
			de.bug('Outage_IncidentProcessor.isRunningCreateAffCust == true');
			return;
		}


		// Make preference request
		de.bug('Make preference request');
		List<Outage_GetPreferences.Preference> Prefs = new List<Outage_GetPreferences.Preference>();

		for (Affected_Customer__c Cust: newAffCusts)
		{
			if (Cust.uom_Contact__c == null)
				continue;

			Outage_GetPreferences.Preference Pref = new Outage_GetPreferences.Preference();
			Pref.ContactId = Cust.uom_Contact__c;
			Prefs.add(Pref);
		}

		if (Prefs.isEmpty())
		{
			// nothing to do
			de.bug('Prefs is Empty');
			return;
		}

		Map<String, Outage_GetPreferences.Preference> mapPrefs = Outage_GetPreferences.toMap(Outage_GetPreferences.getCustomerPreference(Prefs, Outage_IncidentProcessor.DATAUSE_OUTAGES));

		// Get debug stuff
		Map<Id, Contact> ContactIds = new Map<Id, Contact>();

		for (Outage_GetPreferences.Preference Pref: mapPrefs.values())
		{
			if (Pref.Active) continue;
			ContactIds.put(Pref.ContactId, null);
		}

		if (!ContactIds.isEmpty())
		{
			ContactIds = new Map<Id, Contact>([SELECT Id, Name, RecordType.Name,
												CE_Email_Address__c, CE_Phone_Number__c,
												Phone, Email, MobilePhone, OtherPhone
												FROM Contact WHERE Id IN :ContactIds.keySet()]);
		}

		for (Affected_Customer__c Cust: newAffCusts)
		{
			Cust.Notification_Pref__c = null;
			Cust.Phone__c             = null;
			Cust.Email__c             = null;

			if (Cust.uom_Contact__c == null)
				continue;

			de.bug('Contact: ' + Cust.uom_Contact__c);

			String key = Cust.uom_Contact__c;
			if (!mapPrefs.containsKey(key)) continue;

			Outage_GetPreferences.Preference Pref = mapPrefs.get(key);
			de.bug('Pref.Active: ' + Pref.Active);

			if (Pref.Active)
			{
				de.bug('Notification_Pref__c: ' + Pref.Channel);
				Cust.Notification_Pref__c = Pref.Channel;
				Cust.Phone__c             = Pref.PhoneNum;
				Cust.Email__c             = Pref.Email;
			}
			else
			{
				de.bug('*** Notification_Pref__c: ' + Cust.Notification_Pref__c + ' ***');
				de.bugSubject('No preference');

				// Grab the contact info for debug
				if (ContactIds.containsKey(Pref.ContactId))
				{
					Contact con = ContactIds.get(Pref.ContactId);
					Set<String> fields = new Set<String>{ 'CE_Email_Address__c', 'CE_Phone_Number__c', 'Phone', 'Email', 'MobilePhone', 'OtherPhone' };
					for (String f: fields)
					{
						if (con.get(f) != null)
						{
							de.bugSubject('No preference - check field');
							de.bug('***');
							de.bug(f + ': ' + (String)con.get(f));
						}
					}
				}
			}

			de.bug('Phone__c: ' + (Cust.Phone__c == null ? 'null' : 'set'));
			de.bug('Email__c: ' + (Cust.Email__c == null ? 'null' : 'set'));

			if (Cust.Notif_Duplication_Note__c != null)
			{
				de.bug('Notif_Duplication_Note__c: ' + Cust.Notif_Duplication_Note__c);
				if (Cust.Notif_Duplication_Note__c.contains('Phone number omitted'))
					Cust.Phone__c = null;
				if (Cust.Notif_Duplication_Note__c.contains('Email address omitted'))
					Cust.Email__c = null;

				Cust.Notification_Pref__c = null;
				if (Cust.Phone__c != null && Cust.Email__c != null)
					Cust.Notification_Pref__c = Outage_IncidentProcessor.CHANNEL_SMS_EMAIL;
				else if (Cust.Phone__c != null)
					Cust.Notification_Pref__c = Outage_IncidentProcessor.CHANNEL_SMS;
				else if (Cust.Email__c != null)
					Cust.Notification_Pref__c = Outage_IncidentProcessor.CHANNEL_EMAIL;
			}
			de.bug('');
		}
	}

	// setLifeSupportFlag profile:
	// Runs in before context
	// 0 SOQLs
	// 0 DMLs
	public static void setLifeSupportFlag(List<Affected_Customer__c> newAffCusts)
	{
		if (newAffCusts == null || newAffCusts.isEmpty())
			return;

		for (Affected_Customer__c Cust: newAffCusts)
		{
			Cust.uom_Life_Support__c = (Cust.uom_SupplyGuaranteeReason1__c != null && Cust.uom_SupplyGuaranteeReason1__c == 'Life Support');
		}
	}

	// setSuburbList profile:
	// Runs in after insert context
	// 0 SOQLs
	// 0 DMLs
	public static void setSuburbList(List<Affected_Customer__c> newAffCusts)
	{
		if (newAffCusts == null || newAffCusts.isEmpty())
			return;

		Set<Id> IncIds = new Set<Id>();

		for (Affected_Customer__c Cust: newAffCusts)
		{
			if (Cust.uom_Incident__c == null) continue;

			IncIds.add(Cust.uom_Incident__c);
		}

		// launch as future
		if (!IncIds.isEmpty())
			Outage_IncidentProcessor.applySuburbs(IncIds);
	}


	// queueUpdatesForMCSync profile:
	// Runs in before update context
	// 0 SOQLs
	// 0 DMLs
	public static void queueUpdatesForMCSync(List<Affected_Customer__c> newAffCusts, Map<Id, Affected_Customer__c> oldAffCusts)
	{
		System.debug('*** Trig_AffectedCustomer.queueUpdatesForMCSync');
		if (newAffCusts == null || newAffCusts.isEmpty() || oldAffCusts == null || oldAffCusts.isEmpty())
			return;

		for (Affected_Customer__c newCust: newAffCusts)
		{
			Affected_Customer__c oldCust = oldAffCusts.get(newCust.Id);

			// If MC_Sync__c = Sync &&
			// MC_Sync__c is unchanged
			// and Incident Status is changed.

			// then

			// Capture new Incident Status into MC_Sync_Queue__c
			// Restore old Inc Status

			if (newCust.MC_Sync__c == Outage_IncidentProcessor.SYNC_MC_SYNC &&
				!isFieldChanged(newCust, oldCust, 'MC_Sync__c')             &&
				isFieldChanged(newCust, oldCust, 'uom_Incident_Status__c'))
			{
				System.debug('Capture new Incident Status into MC_Sync_Queue__c');

				String newIncStatus = newCust.uom_Incident_Status__c;
				String oldIncStatus = oldCust.uom_Incident_Status__c;

				// System.debug('old value: '+newCust.MC_Sync_Queue__c);

				newCust.MC_Sync_Queue__c = addToJSONList(newCust.MC_Sync_Queue__c, newIncStatus);
				newCust.uom_Incident_Status__c = oldIncStatus;

				// System.debug('new value: '+newCust.MC_Sync_Queue__c);

				// pop it off the history list (if found)
				List<String> MCSyncHistory = getJSONList(newCust.MC_Sync_History__c);

				// check last value
				if (!MCSyncHistory.isEmpty() && MCSyncHistory.get(MCSyncHistory.size()-1) == newIncStatus)
				{
					MCSyncHistory.remove(MCSyncHistory.size()-1);
					newCust.MC_Sync_History__c = getJSONField(MCSyncHistory);
				}
			}
		}
	}


	// updateSetMCSyncField profile:
	// Runs in before update context
	// 0 SOQLs
	// 0 DMLs
	public static void updateSetMCSyncField(List<Affected_Customer__c> newAffCusts)
	{
		System.debug('*** Trig_AffectedCustomer.updateSetMCSyncField');
		if (newAffCusts == null || newAffCusts.isEmpty())
			return;

		if (isRunningSetMCSyncField) return;
		List<Affected_Customer__c> checkMCSyncQueue = new List<Affected_Customer__c>();

		for (Affected_Customer__c newCust: newAffCusts)
		{
			// This will
			// - reset the flag when MC completes a task

			if (newCust.MC_Sync__c == Outage_IncidentProcessor.SYNC_MC_COMPLETE)
			{
				newCust.MC_Sync__c = null;

				// Check MCSync Queue
				List<String> MCSyncQueue = getJSONList(newCust.MC_Sync_Queue__c);
				if (!MCSyncQueue.isEmpty())
					checkMCSyncQueue.add(newCust);
			}
		}

		if (!checkMCSyncQueue.isEmpty())
			applyMCSyncQueue(checkMCSyncQueue);
	}

	private static void applyMCSyncQueue(List<Affected_Customer__c> affCustomers)
	{
		System.debug('*** Trig_AffectedCustomer.applyMCSyncQueue');
		if (affCustomers == null || affCustomers.isEmpty()) return;

		Map<Id, Incident> mapIncidents = new Map<Id, Incident>();

		for (Affected_Customer__c affCust: affCustomers)
		{
			mapIncidents.put(affCust.uom_Incident__c, null);
		}

		for (Incident inc: [SELECT Id, Subject, Status, uom_Estimated_assessment_date__c, uom_Estimated_restoration_date__c, Integration_Status__c
							FROM Incident
							WHERE Id IN :mapIncidents.keySet()])
		{
			mapIncidents.put(inc.Id, inc);
		}

		Map<Id, Outage_IncidentProcessor.IncidentUpdate> incUpdates = new Map<Id, Outage_IncidentProcessor.IncidentUpdate>();

		for (Affected_Customer__c affCust: affCustomers)
		{
			List<String> MCSyncQueue = getJSONList(affCust.MC_Sync_Queue__c);
			if (MCSyncQueue.isEmpty()) continue;

			Incident inc = mapIncidents.get(affCust.uom_Incident__c);
			inc.Status = MCSyncQueue.remove(0);
			Outage_IncidentProcessor.IncidentUpdate incUpdate = new Outage_IncidentProcessor.IncidentUpdate(inc);
			incUpdates.put(incUpdate.incidentId, incUpdate);

			affCust.MC_Sync_Queue__c = getJSONField(MCSyncQueue);
		}

		if (!incUpdates.isEmpty())
		{
			Outage_AsyncProcessor Async = new Outage_AsyncProcessor(incUpdates);
			Id jobId = System.enqueueJob(Async);
		}
	}

	// setMCSyncField profile:
	// Runs in after insert context
	// 0 SOQLs
	// 0 DMLs
	// 1 future
	public static void insertSetMCSyncField(List<Affected_Customer__c> newAffCusts)
	{
		System.debug('*** Trig_AffectedCustomer.insertSetMCSyncField');
		if (newAffCusts == null || newAffCusts.isEmpty())
			return;

		Set<Id> syncAffCustIds = new Set<Id>();

		for (Affected_Customer__c Cust: newAffCusts)
		{
			syncAffCustIds.add(Cust.Id);
		}

		if (!syncAffCustIds.isEmpty()) futureSetMCSyncField(syncAffCustIds);
	}

	public static void futureSetMCSyncField(Set<Id> affCustIds)
	{
		if (Test.isRunningTest() || !Outage_IncidentProcessor.enableFutures)
			setMCSyncField(affCustIds);
		else
			fSetMCSyncField(affCustIds);
	}

	@future public static void fSetMCSyncField(Set<Id> affCustIds)
	{
		setMCSyncField(affCustIds);
	}

	// setMCSyncField profile:
	// Runs in future context
	// 0 SOQLs
	// 1 DMLs
	public static void setMCSyncField(Set<Id> affCustIds)
	{
		if (de == null) de = new UtilDebug();
		de.bug('** Trig_AffectedCustomer.setMCSyncField', true);

		if (affCustIds == null || affCustIds.isEmpty())
			return;

		if (isRunningSetMCSyncField) return;
		isRunningSetMCSyncField = true;

		List<Affected_Customer__c> updAffCusts = new List<Affected_Customer__c>();

		for (Affected_Customer__c cust: [SELECT Id, Name, uom_Incident_Status__c, uom_Affected_Market_Identifier__c, uom_Incident__c,
										 uom_Aff_NMI_Status__c, uom_Estimated_assessment_date__c, uom_Estimated_restoration_date__c,
										 MC_Sync__c, MC_Sync_History__c, Incident_Notifications__c,
										 Multi_Incident__c
										 FROM Affected_Customer__c
										 WHERE Id IN :affCustIds])
		{
			de.bug(JSON.serializePretty(cust));
			Outage_IncidentProcessor.CustomerUpdate CustUpdate = new Outage_IncidentProcessor.CustomerUpdate(cust);

			CustUpdate.updateIncidentStatus(cust.uom_Incident_Status__c);
			String SyncOutcome = CustUpdate.runUpdateIncidentStatus();
			de.bug('SyncOutcome: ' + SyncOutcome);
			de.bug(JSON.serializePretty(CustUpdate.affCustomer));

			if (!SyncOutcome.startsWith('Sync'))
			{
				de.bug('Aff Cust ['+cust.Id+']: Skipping MC Sync...', true);
				de.bug(SyncOutcome, true);
				continue;
			}

			updAffCusts.add(CustUpdate.affCustomer);
		}

		if (!updAffCusts.isEmpty()) update updAffCusts;

		if (Outage_IncidentProcessor.vcDebug)
			de.bugSend();
	}


	// createLifeSupTask profile:
	// Runs in current context
	// 3 SOQLs
	// 1 DMLs
	public static void createLifeSupTask(List<Affected_Customer__c> newAffCusts)
	{
		System.debug('*** createLifeSupTask');

		if (newAffCusts == null || newAffCusts.isEmpty())
			return;

		// Check disabled Flag
		if (IsLSCTaskGenDisabled())
		{
			System.debug('LSC Task Gen is Disabled.');
			return;
		}

		List<Task> taskListLifeSupp = new List<Task>();
		Set<Id> conts = new Set<Id>();
		Set<Id> incs = new Set<Id>();
		Task lifeSupTask = new Task();
		List<Affected_Customer__c> qualifiedAffCusts = new List<Affected_Customer__c>();

		for (Affected_Customer__c Cust: newAffCusts)
		{
			// Check if the affected customer is on life support.
			if (Cust.Customer_Type__c == Outage_IncidentProcessor.AFF_CUST_TYPE_PRIM && Cust.uom_Life_Support__c)
			{
				qualifiedAffCusts.add(Cust);
				conts.add(Cust.uom_Contact__c); // The Contact of the affected customer.
				incs.add(Cust.uom_Incident__c); // The incident which has affected this customer
			}
		}

		// If there are no life support customers then stop execution
		if (qualifiedAffCusts.isEmpty())
		{
			// nothing to do.
			return;
		}

		// Get the Name and Incident Created Date for these afffected customers.
		Map<Id,Contact> cont = new Map<Id,Contact>([SELECT Id,Name FROM Contact WHERE Id IN :conts]);
		Map<Id,Incident> inc = new Map<Id,Incident>([SELECT Id,CreatedDate FROM Incident WHERE Id IN :incs]);
		Id recType = UtilDatabase.getRecordTypeNames('Task').get(Outage_IncidentProcessor.LSC_TASK_RT_NAME);
		Group grp = [SELECT Id , Name , Type FROM Group WHERE Type='Queue' AND DeveloperName = :Outage_IncidentProcessor.LSC_TASK_QUEUE_NAME];

		for (Affected_Customer__c Cust: qualifiedAffCusts)
		{
			// For each life support customer, create a LSC task and assign to the queue.
			lifeSupTask = new Task();
			lifeSupTask.RecordTypeId = recType; // LSC Wellbeing Check record type
			lifeSupTask.WhoId = Cust.uom_Contact__c; // Contact Id
			lifeSupTask.Subject = 'LSC Wellbeing Check - '+cont.get(Cust.uom_Contact__c).Name; // Contact Name
			lifeSupTask.OwnerId = grp.Id; // LSC Wellbeing Check Queue
			lifeSupTask.WhatId = Cust.Id; // Affected Customer
			lifeSupTask.Status = 'Not Started';

			DateTime taskDT = inc.get(Cust.uom_Incident__c).CreatedDate.addHours(12); // 12 hrs from created date
			lifeSupTask.ActivityDate = taskDT.date(); // IncidentCreated Date + 12 Hrs
			lifeSupTask.Priority = 'Normal'; //Mandatory field for Task creation.
			lifeSupTask.ReminderDateTime = taskDT; // 12 hrs from Due date
			taskListLifeSupp.add(lifeSupTask);
		}

		// Insert all the records.
		if (!taskListLifeSupp.isEmpty())
			insert taskListLifeSupp;
	}


	// *********************************************************************
	// *** Helper methods
	private static Boolean IsLSCTaskGenDisabled()
	{
		if (TrigSettings__c.getInstance().LSC_Task_Generation_Disabled__c)
			return true;
		else
			return LSCTaskGenDisabled;
	}


	private static Boolean isFieldChanged(SObject obj1, SObject obj2, String field)
	{
		Boolean isChanged = false;

		if (obj1 == null || obj2 == null || field == null)
			return isChanged;

		Object value1, value2;

		if (obj1.get(field) != null) value1 = obj1.get(field);
		if (obj2.get(field) != null) value2 = obj2.get(field);

		if (value1 != value2)
			isChanged = true;

		return isChanged;
	}

	private static String addToJSONList(String field, String newValue)
	{
		if (newValue == null) return field;

		// get MC_Sync_Queue__c value
		List<String> MCSyncQueue = new List<String>();

		if (field != null)
		{
			try
			{
				MCSyncQueue = (List<String>)JSON.deserialize(field, List<String>.class);
			}
			catch (Exception e) {}
		}

		MCSyncQueue.add(newValue);
		field = JSON.serialize(MCSyncQueue);

		return field;
	}

	private static List<String> getJSONList(String field)
	{
		List<String> MCSyncQueue = new List<String>();
		if (field == null) return MCSyncQueue;

		try
		{
			MCSyncQueue = (List<String>)JSON.deserialize(field, List<String>.class);
		}
		catch (Exception e) {}

		return MCSyncQueue;
	}

	private static String getJSONField(List<String> MCSyncQueue)
	{
		if (MCSyncQueue == null || MCSyncQueue.isEmpty()) return null;
		return JSON.serialize(MCSyncQueue);
	}

}