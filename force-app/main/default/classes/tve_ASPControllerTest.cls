/*
@author  : Lakshay Sharma <Lakshay.Sharma@ausnetservices.com.au>
@created : 31st Jan 2020
@Description : Test class for tve_ASPController
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/
@isTest
public class tve_ASPControllerTest {

    Private static Account acc;
    Private static Project__c prj;
    Private static string PROGRESS_BAR_STATUS = 'Allocated for initial assessment';
    Private static string CONTESTATIBILITY_TYPE = 'IDEC';
    Private static string aspManualText='Test01';
    Private static string extId='abc123456789012';
    private static final string userEmail = 'testuser@tveASPControllerTest.com';
    public static final string TASK_RT = 'Select_ASP';
    @testSetup static void setup(){
        eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
        eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
        insert eSignObj;
        acc=TVE_TestUtility.createBusinessAccount('TestAccount');
        acc.ASPAccreditaionId__c='12345xyz12';
        insert acc;
    	prj=TVE_TestUtility.createProject('TestRef1',PROGRESS_BAR_STATUS,CONTESTATIBILITY_TYPE);
        prj.ASP__c=acc.Id;
        insert prj;
        User tstUsr = TVE_TestUtility.createTestUser(userEmail);
        insert tstUsr;
        Task t = TVE_TestUtility.createTask(prj.id, tstUsr.Id, 'tve_ASPControllerTest');
        t.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =: TASK_RT].Id;
        insert t;
        
    }
        
    @istest static void updateManualASPtest(){
		Project__c prj=[SELECT Id FROM Project__c WHERE Name='TestRef1'LIMIT 1];
        Task tsk = [SELECT Id FROM Task WHERE Subject='tve_ASPControllerTest' LIMIT 1];

        test.startTest();
        tve_ASPController.updateManualASP(prj.Id,aspManualText,tsk.Id);
        test.stopTest();
        }
		    
    @istest static void updateFromASPListTest(){
        Account acc=[SELECT Id,ASPAccreditaionId__c FROM Account WHERE ASPAccreditaionId__c='12345xyz12'LIMIT 1]; 
        Project__c prj=[SELECT Id FROM Project__c WHERE Name='TestRef1'LIMIT 1];
        
        
        
        test.startTest();
        tve_ASPController.updateFromASPList(prj.Id,acc.ASPAccreditaionId__c,null);
        test.stopTest();
        }
}