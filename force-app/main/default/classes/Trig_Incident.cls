public with sharing class Trig_Incident implements UtilTrigHandle
{

	// *********************************************************************
	// *** Disable logic
	public static Boolean TrigDisabled = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().Incident_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}


	// *********************************************************************
	// *** Trigger contexts
	public void BeforeInsert(List<SObject> newSObjs)
	{
		setIncidentSubject(newSObjs); // Ensure this line is first in beforeInsert
		setIncidentStartDateTime(newSObjs);
		setIncidentCauseAndDelay(newSObjs);
		setIncidentStartTime(newSObjs);

		setIntegrationStatus(newSObjs);
	}

	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		setIncidentSubject(newSObjs.values()); // Ensure this line is first in before update
		setIncidentNotifs(newSObjs.values());
		setIncidentCauseAndDelay(newSObjs.values());
		setIncidentStartTime(newSObjs.values());

		setExceptionUpdate(newSObjs.values());
	}

	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		updateAffectedCustomers(oldSObjs, newSObjs);

		// LSC Tasks related
		// 	Query for LSC WC Tasks where Task is open, Task field Close_On_Incident_Resolved is true
		//	And for any Tasks returned, update the records: Status = Closed, Call Outcome = “Incident Resolved - task closed”
		updateLSCTasksOnIncidentClosure(newSObjs.values());
	}

	// if context is not implemented, condense into one-liners
	public void AfterInsert(Map<Id, SObject> newSObjs) {}
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> oldSObjs) {}


	// *********************************************************************
	// *** Trigger methods

	public static void updateAffectedCustomers(Map<Id, SObject> oldIncidents, Map<Id, SObject> newIncidents)
	{
		if (oldIncidents == null || oldIncidents.isEmpty() || newIncidents == null || newIncidents.isEmpty())
			return;

		System.debug(
			Outage_IncidentProcessor.incidentUpdAffCustomers((Map<Id, Incident>)oldIncidents, (Map<Id, Incident>)newIncidents)
		);
	}

	// setIncidentSubject profile:
	// Runs in before context
	// 0 SOQLs
	// 0 DMLs
	public static void setIncidentSubject(List<Incident> newIncs)
	{
		if (newIncs == null || newIncs.isEmpty())
			return;

		for (Incident inc: newIncs)
		{
			if (inc.Subject == null)
				inc.Subject = inc.uom_Incident_Id__c;
		}
	}

	// setExceptionUpdate profile:
	// Runs in before context
	// 0 SOQLs
	// 0 DMLs
	public static void setExceptionUpdate(List<Incident> newIncs)
	{
		if (newIncs == null || newIncs.isEmpty())
			return;

		// check flag
		Boolean runFix = DER_System__c.getInstance().UOM_Incident_Fix_Enabled__c;
		if (!runFix) return;

		Set<String> IncIds = new Set<String>{'INCD-122503-U', 'INCD-122504-U'};

		for (Incident inc: newIncs)
		{
			if (inc.uom_Incident_Id__c == null) continue;
			if (!IncIds.contains(inc.uom_Incident_Id__c)) continue;

			// here we go
			System.debug('Found a record to fix.');
			System.debug(JSON.serializePretty(inc));

			String Status = 'Awaiting Construction';
			DateTime ETR = DateTime.newInstance(2024, 02, 22, 18, 0, 0);

			inc.Status = Status;
			inc.uom_Estimated_restoration_date__c = ETR;

			System.debug('Status set to: ' + inc.Status);
			System.debug('ETR set to: ' + inc.uom_Estimated_restoration_date__c);
		}
	}

	// setIntegrationStatus profile:
	// Runs in before insert context
	// 0 SOQLs
	// 0 DMLs
	public static void setIntegrationStatus(List<Incident> newIncs)
	{
		if (newIncs == null || newIncs.isEmpty())
			return;

		for (Incident inc: newIncs)
		{
			if (inc.Integration_Status__c == Outage_IncidentProcessor.INT_STS_COMPLETE)
				inc.Integration_Status__c = null;
		}
	}

	// setIncidentStartDateTime profile:
	// Runs in before context
	// 0 SOQLs
	// 0 DMLs
	public static void setIncidentStartDateTime(List<Incident> newIncs)
	{
		if (newIncs == null || newIncs.isEmpty())
			return;

		for (Incident inc: newIncs)
		{
			if (inc.StartDateTime == null)
				inc.StartDateTime = inc.CreatedDate;
		}
	}

	// setIncidentCauseAndDelay profile:
	// Runs in before context
	// 0 SOQLs
	// 0 DMLs
	public static void setIncidentCauseAndDelay(List<Incident> newIncs)
	{
		if (newIncs == null || newIncs.isEmpty()) 
			return;

		Map<String, Incident_Cause_and_Delay__mdt> mcd = Incident_Cause_and_Delay__mdt.getAll();

		for (Incident inc: newIncs)
		{
			Incident_Cause_and_Delay__mdt incCD = null;

			// Cause logic
			if (String.isNotBlank(inc.uom_Cause__c) && inc.uom_Cause__c.length() == 4)
			{
				incCD = mcd.get(inc.uom_Cause__c);

				if (incCD != null )
				{
					inc.uom_Cause__c = incCD.Description__c;
					inc.Incident_Cause_SMS_Text__c = incCD.SMS_Text__c;
					inc.Incident_Cause_Email_Text__c = incCD.Email_Text__c;
				}
				else
				{
					inc.Incident_Cause_SMS_Text__c = '';
					inc.Incident_Cause_Email_Text__c = '';
				}
			} 
			else if (String.isBlank(inc.uom_Cause__c))
			{
				inc.Incident_Cause_SMS_Text__c = '';
				inc.Incident_Cause_Email_Text__c = '';
			}

			// Delay logic
			if (String.isNotBlank(inc.uom_Delay_Reason__c) && inc.uom_Delay_Reason__c.length() == 4)
			{
				incCD = null;
				incCD = mcd.get(inc.uom_Delay_Reason__c);

				if (incCD != null )
				{
					inc.uom_Delay_Reason__c = incCD.Description__c;
					inc.Delay_Reason_SMS_Text__c = incCD.SMS_Text__c;
					inc.Delay_Reason_Email_Header__c = incCD.Email_Header__c;
					inc.Delay_Reason_Email_Text__c = incCD.Email_Text__c;
				}
				else
				{
					inc.Delay_Reason_SMS_Text__c = '';
					inc.Delay_Reason_Email_Header__c = '';
					inc.Delay_Reason_Email_Text__c = '';
				}
			}
			else if (String.isBlank(inc.uom_Delay_Reason__c))
			{
				inc.Delay_Reason_SMS_Text__c = '';
				inc.Delay_Reason_Email_Header__c = '';
				inc.Delay_Reason_Email_Text__c = '';
			}
		}
	}

	// setIncidentNotifs profile:
	// Runs in before context
	// 0 SOQLs
	// 0 DMLs
	public static void setIncidentNotifs(List<Incident> newIncs)
	{
		if (newIncs == null || newIncs.isEmpty())
			return;

		for (Incident inc: newIncs)
		{
			if (inc.Incident_Notifications__c == null)
				inc.Incident_Notifications__c = Outage_IncidentProcessor.INC_NOTIFS_AUTO;
		}
	}

	// setIncidentStartTime profile:
	// Runs in before context
	// 0 SOQLs
	// 0 DMLs
	public static void setIncidentStartTime(List<Incident> newIncs)
	{
		if (newIncs == null || newIncs.isEmpty())
			return;

		for (Incident inc: newIncs)
		{
			if (inc.StartDateTime == null)
			{
				DateTime CreatedDate = inc.CreatedDate;
				if (CreatedDate == null) CreatedDate = System.now();

				inc.StartDateTime = CreatedDate.addMinutes(-10);
			}
		}
	}

	// updateLSCTasksOnIncidentClosure profile:
	// Runs in after update context
	// 2 SOQLs
	// 1 DMLs

	// 	Query for LSC WC Tasks where Task is open, Task field Close_On_Incident_Resolved is true
	//	And for any Tasks returned, update the records: Status = Closed, Call Outcome = “Incident Resolved - task closed”
	private void updateLSCTasksOnIncidentClosure(List<Incident> incidents)
	{
		if (incidents == null || incidents.isEmpty())
			return;

		Set<Id> incs = new Set<Id>();

		// Get All the incidents with Status equivallent to Closed.
		for (Incident inc: incidents)
		{
			// Is this incident closed?
			Boolean isIncClosed = (Outage_IncidentProcessor.INCIDENT_STS_CLSD.contains(inc.Status));

			if (isIncClosed)
			{
				// These are closed statuses for incidents.
				incs.add(inc.Id);
			}
		}

		// If the incident is not moved to closed, no need to check tasks on it.
		if (incs.isEmpty())
			return;

		// Task has Relate To field which is Affected Customer. Affected Customer has Incident Id.
		// So get the Affected Cusomers for the incidents closed. Then get the Tasks for those affected customers.
		List<Affected_Customer__c> acs = [SELECT Id FROM Affected_Customer__c WHERE uom_Incident__c IN :incs];
		Map<Id,Task> taskMap = new Map<Id, Task>([SELECT Id, Task_Age__c FROM Task WHERE WhatId IN :acs AND Close_On_Incident_Resolved__c = true AND IsClosed=false]);

		List<Task> taskListLifeSupp = new List<Task>();

		//If there are Open tasks for this incident which can be closed on incident closure ?
		for (Task tsk: taskMap.values())
		{
			// MArk Task Status as Closed.
			tsk.Status             = 'Closed';// will not happen in Trig_Task since Log A LSC Call is not set as true is checked..
			tsk.Call_Outcome__c    = 'Incident Resolved - task closed'; // MArk Call Outcome
			tsk.Task_Closed_Age__c = tsk.Task_Age__c; // Mark Task closed age.
			taskListLifeSupp.add(tsk);
		}

		if (!taskListLifeSupp.isEmpty())
			update taskListLifeSupp; // Update the Tasks for this incident.
	}
}