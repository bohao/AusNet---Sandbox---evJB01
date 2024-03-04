/*
@author  : pavan.dave@ausnetservices.com.au
@created : 23th Dec 2019
@Description : test class for Aura TVE_InvoicePreviewController
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
@isTest
public class TVEProjectActionControllerTest {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public static final string testUserEmail = 'testuser@TVEInvoicePreviewControllerTest.com';
    public static final string taskRT = 'Upload_File';
    public static testMethod void testGetTask(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        Test.startTest();
        System.runAs(testUser){
            Project__c projObj = [select id from Project__c limit 1];
            Task tsk =[select id from Task limit 1];
            TVEProjectActionController.TaskWrapper tskWrp=TVEProjectActionController.fetchTask(projObj.id, true);
            TVEProjectActionController.ProjectWrapper projID=TVEProjectActionController.fetchProject(tsk.id);
             }
    }
    @TestSetup
    public static void setup() {
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
        
        //Create Business Account
        Account testInstaller = TVE_TestUtility.createBusinessAccount('Business Account');
        insert testInstaller;
        
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        Insert projObj;
        
        Artefact__c artObj = TVE_TestUtility.createInvoiceArtefact('NameTest',projObj.Id,testInstaller.Id);
        insert artObj;
        
        Task tsk = TVE_TestUtility.createTask(projObj.id,testUser.id,'Upload File');
        insert tsk;
        
    }  
}