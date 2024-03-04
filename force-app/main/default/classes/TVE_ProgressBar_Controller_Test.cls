/*
@author  : pavan.dave@ausnetservices.com.au
@created : 18 Dec 2019
@Description : Test class for TVE_ProgressBar_Controller
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/
@isTest
public with sharing class TVE_ProgressBar_Controller_Test {
    public static string PROGRESS_BAR_STATUS = 'Allocated for initial assessment';
    public static string CONTESTATIBILITY_TYPE = 'IDEC';
	
    @TestSetup
	public static void setup()
	{
        eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
        eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
        insert eSignObj;
		//Create Project Record
		Project__c testProject = TVE_TestUtility.createProject('test11',PROGRESS_BAR_STATUS,CONTESTATIBILITY_TYPE);
		insert testProject;	
	}

    public static testMethod void testGetProgressBarMessage(){
        
        Test.startTest();
        TVE_ProgressBar_Controller.getProgressBarMessage();
        Test.stopTest();
    }
    
    // ===================================================== //
    // ============= Test methods for GET ================== //
    // ===================================================== //

    public static testMethod void terstGetProjProgressJSON(){
        
        String projId = [SELECT Id
                            FROM Project__c 
                            LIMIT 1].Id;            

        Test.startTest();
        TVE_ProgressBar_Controller.getProjProgressJSON(projId);
        Test.stopTest();
    }

}