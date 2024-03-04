/*
@author  : Arti.foglae@ausnetservices.com.au
@created : 13 Mar  2020
@Description : test class for TVE_CreateTaskUtility
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/
@istest
public class TVE_CreateTaskUtilityTest {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Payment pending (Application submitted)';
    public static final string testUserEmail = 'testuser@TVEArtefactControllerTest.com';
    
    public static testMethod void testCreateNewTask(){
        Project__c proj = [select id from Project__c limit 1];
        Task tskRec=[select id,ownerid,subject from Task limit 1];
        Test.startTest();
        TVE_CreateTaskUtility.createNewTask(proj.id,tskRec.Subject,system.today(),'desc',tskRec.ownerid);
        Test.stopTest();
    }
    
    @TestSetup
    public static void setup() {
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        insert projObj;
        Task tsk=TVE_TestUtility.createTask(projobj.id,testUser.id,'Other');
        insert tsk;
    }

}