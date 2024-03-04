/*
  @author  : vaughan.crole@au1.ibm.com
  @created : 30 April 2020
  @Description : Task Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
public with sharing class Trig_Task implements UtilTrigHandle
{

	// *********************************************************************
	// *** Members
	public static Map<String, String> OutcomeStatusMap = new Map<String, String>
	{
		'Spoke to customer - backup plan enacted, customer currently safe' => 'Completed',
		'Spoke to customer - life support no longer required'              => 'Completed',
		'Incident Resolved - task closed'                                  => 'Closed',

		'Spoke to customer - sent to DEECA'                                => 'Send to DEECA',
		'No answer - left voicemail'                                       => 'Voicemail',
		'No answer - no voicemail'                                         => 'No Answer',
		'No answer - sent LSC SMS'                                         => 'Left Message',
		'Multiple calls no answer - welfare check required, sent to DEECA' => 'Send to DEECA',
		'Incorrect number - welfare check required, no contact details'    => 'Wrong Number'
	};

	public static Set<String> WelfareCheckReqd = new Set<String>
	{
		'Spoke to customer - sent to DEECA',
		'Multiple calls no answer - welfare check required, sent to DEECA',
		'Incorrect number - welfare check required, no contact details'
	};


	// *********************************************************************
	// *** Disable logic

	public static Boolean TrigDisabled = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().Task_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}

	// *********************************************************************
	// *** Trigger contexts
	public void BeforeInsert(List<SObject> newSObjs)
	{
		// Set Task Record Type based on Subject
		setRecordTypes(newSObjs);
		setDueDateTime(newSObjs);
	}

	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		//update LSCTasks details.
		updateLSCTaskDtls((List<Task>)newSObjs.values(), (Map<Id, Task>)oldSObjs);
	}


	// if context is not implemented, condense into one-liners
	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) {}
	public void AfterInsert(Map<Id, SObject> newSObjs) {}
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> newSObjs) {}
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}

	// *********************************************************************
	// *** Trigger methods
	private void setDueDateTime(List<Task> newTasks)
	{
		Id LSC_Wellbeing_CheckRTId = UtilDatabase.getRecordTypeNames('Task').get(Outage_IncidentProcessor.LSC_TASK_RT_NAME);

		for (Task tsk: newTasks)
		{
			if (tsk.RecordTypeId != LSC_Wellbeing_CheckRTId)
				continue;

			if (tsk.Due_Date_Time__c == null && tsk.ReminderDateTime != null)
				tsk.Due_Date_Time__c = tsk.ReminderDateTime;
		}
	}

	private void setRecordTypes(List<SObject> newSObjs)
	{
		Map<String, String> SubjectRTs = new Map<String, String>
		{
			'Accept Firm Offer'                         => 'AcceptFirmOffer',
			'Accept Interconnection Contract and Offer' => 'AcceptInterconnectionContractandOffer',
			'Accept Preliminary Estimate'               => 'AcceptPreliminaryEstimate',
			'Select ASP'                                => 'Select_ASP',
			'Upload File'                               => 'Upload_File',
			'Outstanding Invoice'                       => 'Make_a_Payment',
			'Other'                                     => 'Other'
		};
		Id ResendEmailRTId = UtilDatabase.getRecordTypeNames('Task').get('Resend_Email');
		Id RequestInvoiceRTId= UtilDatabase.getRecordTypeNames('Task').get('Request_Invoice');
		Id ProjectAssignmentRTId = UtilDatabase.getRecordTypeNames('Task').get('ProjectAssignment');
		Id LSC_Wellbeing_CheckRTId = UtilDatabase.getRecordTypeNames('Task').get(Outage_IncidentProcessor.LSC_TASK_RT_NAME);

		switch on Trigger.operationType
		{
			when BEFORE_INSERT
			{
				for (sObject sObjItem: newSObjs)
				{
					Task newTask = (Task) sObjItem;
					ID recID = newTask.RecordTypeId;
					if (recID == LSC_Wellbeing_CheckRTId) {
						return; // For LSC RT dont run below code.
					}

					//added to avoid overrides of recordtypes for below 3 record types(TV-3268)
					if(recID != ProjectAssignmentRTId  && recID != RequestInvoiceRTId && recID !=ResendEmailRTId)
					{

						// Check subject line - does it match our list
						if (newTask.Subject != null && SubjectRTs.containsKey(newTask.Subject))
						{

							String RTName = SubjectRTs.get(newTask.Subject);

							// Get record types
							Id RTId = UtilDatabase.getRecordTypeNames('Task').get(RTName);

							// Set record type
							newTask.RecordTypeId = RTId;
							newTask.ProjectAssigmentStatus__c = null;

						}
						else if(newTask.Subject != null)
						{
							// Set other record type
							newTask.RecordTypeId = UtilDatabase.getRecordTypeNames('Task').get('Other');
							newTask.ProjectAssigmentStatus__c = null;

						}
					}
				}
			}
		}
	}

	private void updateLSCTaskDtls(List<Task> newSObjs, Map<Id, Task> oldSObjs)
	{
		Id LSC_Wellbeing_CheckRTId = UtilDatabase.getRecordTypeNames('Task').get(Outage_IncidentProcessor.LSC_TASK_RT_NAME);

		List<Task> qualifiedTasks = new List<Task>();
		List<Id>   AffCustIds = new List<Id>();

		// Qualify tasks
		for (Task lscTask: newSObjs)
		{
			if (lscTask.RecordTypeId == LSC_Wellbeing_CheckRTId)
			{
				qualifiedTasks.add(lscTask);
				AffCustIds.add(lscTask.WhatId);
			}
		}

		if (qualifiedTasks.isEmpty())
		{
			// nothing to do
			return;
		}

		Map<Id, Affected_Customer__c> acs = new Map<Id, Affected_Customer__c>([SELECT Id, uom_Incident_Status__c, uom_Aff_NMI_Status__c FROM Affected_Customer__c WHERE Id IN :AffCustIds]);
		Group grp = [SELECT Id, Name, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = :Outage_IncidentProcessor.LSC_TASK_QUEUE_NAME];

		List<Task> taskListLifeSupp = new List<Task>();
		Task       lifeSupTask = new Task();

		for (Task lscTask : qualifiedTasks)
		{
			Task oldLSCTask = (Task)oldSObjs.get(lscTask.Id);

			Boolean incrAttemptsForStatus = false;
			Boolean ownerIsAUser = false;
			Boolean isOwnerChanged = false;

			// Owner is a user (not the queue)
			if (lscTask.OwnerId.getSObjectType().getDescribe().getName() == 'User')
			{
				ownerIsAUser = true;
				if (oldLSCTask.OwnerId != lscTask.OwnerId)
				{
					isOwnerChanged = true; // Self Assign migt have changed the user. So, dont assign back to queue.
				}
			}

			if (lscTask.Log_a_LSC_Call__c)
			{
				// If Log a LSC Call is set to true, only then update the status.
				// Based on Call Outcome selected, the system will set the Task Status
				String newStatus = 'Not Started';

				if (OutcomeStatusMap.containsKey(lscTask.Call_Outcome__c))
					newStatus = OutcomeStatusMap.get(lscTask.Call_Outcome__c);

				lscTask.Status = newStatus;
				lscTask.LSC_Welfare_Check__c = false;

				if (WelfareCheckReqd.contains(lscTask.Call_Outcome__c))
					lscTask.LSC_Welfare_Check__c = true;
			}

			// If Status is not Completed or Closed
			//  Task remains open, Is reassigned back into queue, Owner = (LSC WBC Queue)
			if (lscTask.Status == 'Completed' || lscTask.Status == 'Closed')
			{
				// Task Closed Age = Task Age
				lscTask.Task_Closed_Age__c = lscTask.Task_Age__c;

				//If Incident linked is still open - Create a new Task record
				Affected_Customer__c affCust = acs.get(lscTask.WhatId);
				Boolean isAffCustRestored = false;

				if (Outage_IncidentProcessor.INCIDENT_STS_CLSD.contains(affCust.uom_Incident_Status__c) ||
					Outage_IncidentProcessor.AFF_NMI_STS_CLSD.contains(affCust.uom_Aff_NMI_Status__c))
				{
					isAffCustRestored = true;
				}

				// Incident Status Cancelled || Merged || Power Restored Closed statuses
				if (!isAffCustRestored)
				{
					lifeSupTask = createLifeSupTask(lscTask, grp.Id);

					if (lifeSupTask != null)
						taskListLifeSupp.add(lifeSupTask);
				}
			}
			else if (!isOwnerChanged && ownerIsAUser && lscTask.Status != 'Completed' && lscTask.Status  != 'Closed')
			{
				lscTask.OwnerId = grp.Id;
				// Assign it back to queue when its with user, some action took place and task is not closed.
				// Queue : LSC Wellbeing Check
			}

			// All other cases, be it what it is.
			// Status is (No Answer, Left Message, Voicemail, Wrong Number, Send to DEECA, Completed)
			if (lscTask.Status == 'No Answer' ||
				lscTask.Status == 'Left Message' ||
				lscTask.Status == 'Voicemail' ||
				lscTask.Status == 'Wrong Number' ||
				lscTask.Status == 'Send to DEECA' ||
				lscTask.Status == 'Completed')
			{
				incrAttemptsForStatus = true;
			}

			// Number of Attempts field is incremented by 1
			// If owner is not user and callout come was manually changed.
			if (incrAttemptsForStatus && lscTask.Log_a_LSC_Call__c && ownerIsAUser)
			{
				lscTask.Attempt_Number__c++;
				lscTask.Log_a_LSC_Call__c = false; // Reset to false once attempts is incremented.
			}
		}

		if (taskListLifeSupp.size() > 0)
			insert taskListLifeSupp;
	}

	private Task createLifeSupTask(Task oldTask, Id groupId)
	{
		if (oldTask == null) return null;
		DateTime taskDT = DateTime.now().addHours(12);

		Task lifeSupTask = new Task();
		lifeSupTask.RecordTypeId     = oldTask.RecordTypeId;
		lifeSupTask.WhoId            = oldTask.WhoId; // Contact Id
		lifeSupTask.Subject          = oldTask.Subject; // Contact Name
		lifeSupTask.OwnerId          = groupId; // Queue
		lifeSupTask.WhatId           = oldTask.WhatId; // Affected Customer
		lifeSupTask.Status           = 'Not Started';
		lifeSupTask.ActivityDate     = taskDT.date(); // Old Task Closed Date + 12 Hrs
		lifeSupTask.Priority         = 'Normal'; //Mandatory field for Task creation.
		lifeSupTask.ReminderDateTime = taskDT;

		return lifeSupTask;
	}
}