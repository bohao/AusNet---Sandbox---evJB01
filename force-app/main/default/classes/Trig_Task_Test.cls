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
@isTest private class Trig_Task_Test
{
	public static testMethod void task_insert_success()
	{
		User testUser =  DER_TestUtility.createTestUser();

		Test.startTest();
		System.runAs(testUser)
		{
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
		}
		Test.stopTest();
	}


	@TestSetup public static void setup()
	{
		//Create User
		User testUser = DER_TestUtility.createTestUser();
		insert testUser;
	}
}