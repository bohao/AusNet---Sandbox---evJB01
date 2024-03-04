/*
@author  : arti.fogla@ausnetservices.com.au
@created : 10 march  2020
@Description : Test class for Accept offer LWC-TVE_AcceptOfferCtrl
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/

@isTest
public with sharing class TVEAcceptOfferCtrlTest {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Payment pending (Application submitted)';
    public static final string testUserEmail = 'testuser@TVERejectOfferCtrlTest.com';
    public static final string TASK_RT = 'AcceptPreliminaryEstimate';
    
    public static testMethod void TestUpdateTask()
    {
        Task tsk=[select id,status,OfferStatus__c from Task limit 1];
        test.startTest();
        TVE_AcceptOfferCtrl.updateTask(tsk.id);
        Test.stopTest();
    }
    
    @TestSetup
    public static void setup() {
        
        //Create User
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
        
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        Insert projObj;
        
        Task taskRec = TVE_TestUtility.createTask(projObj.Id, testUser.Id, 'Test');
        taskRec.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =: TASK_RT].Id;
        Insert taskRec;
        
    } 
}