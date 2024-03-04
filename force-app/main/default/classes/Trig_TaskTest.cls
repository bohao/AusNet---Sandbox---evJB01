/*
  @author  :
  @created : 11-Sep-2023
  @Description : Task Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
@isTest
public class Trig_TaskTest
{

	public static testMethod void task_insert_success()
	{
		User testUser = [SELECT Id FROM User LIMIT 1];

//		Test.startTest();
//		System.runAs(testUser)
//		{
			Task newTask = new Task();
			newTask.Priority = 'Normal';
			newTask.Status = 'Not Started';
			newTask.OwnerId = testUser.Id;
			newTask.Subject = 'Upload File';

			insert newTask;
			update newTask;
			delete newTask;

			newTask = new Task();
			newTask.Priority = 'Normal';
			newTask.Status = 'Not Started';
			newTask.OwnerId = testUser.Id;
			newTask.Subject = 'Accept Firm Offer';

			insert newTask;

			// LSC Test changes
			Outage_DataFactory odf = Outage_DataFactory.getODF();
			odf.generateCustomers(1);
			odf.generateIncidents(1);
			odf.generateTasks(1);

			odf.tasks[0].Call_Outcome__c = 'Spoke to customer - backup plan enacted, customer currently safe';
			odf.tasks[0].Log_a_LSC_Call__c = true;
			update odf.tasks[0];

			odf.tasks[0].Call_Outcome__c =  'Spoke to customer - sent to DEECA';
			odf.tasks[0].Log_a_LSC_Call__c = true;
			update odf.tasks[0];
			odf.tasks[0].Call_Outcome__c = 'No answer - left voicemail' ;
			odf.tasks[0].Log_a_LSC_Call__c = true;
			update odf.tasks[0];
			odf.tasks[0].Call_Outcome__c =  'No answer - no voicemail';
			odf.tasks[0].Log_a_LSC_Call__c = true;
			update odf.tasks[0];
			odf.tasks[0].Call_Outcome__c = 'No answer - sent LSC SMS';
			odf.tasks[0].Log_a_LSC_Call__c = true;
			update odf.tasks[0];
			odf.tasks[0].Call_Outcome__c = 'Spoke to customer - life support no longer required';
			odf.tasks[0].Log_a_LSC_Call__c = true;
			update odf.tasks[0];
			odf.tasks[0].Log_a_LSC_Call__c = true;
			odf.tasks[0].Call_Outcome__c = 'Multiple calls no answer - welfare check required, sent to DEECA';
			update odf.tasks[0];
			odf.tasks[0].Log_a_LSC_Call__c = true;
			odf.tasks[0].Call_Outcome__c = 'Incorrect number - welfare check required, no contact details';
			update odf.tasks[0];
			odf.tasks[0].Log_a_LSC_Call__c = true;
			odf.tasks[0].Call_Outcome__c = 'Incident Resolved - task closed';
			update odf.tasks[0];

//		}
//		Test.stopTest();
	}


	@TestSetup public static void setup()
	{
		//Create User
		User testUser = DER_TestUtility.createTestUser();
		insert testUser;
	}
}