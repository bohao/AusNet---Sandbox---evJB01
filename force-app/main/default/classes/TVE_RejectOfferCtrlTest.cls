/*
@author  : pavan.dave@ausnetservices.com.au
@created : 01 Mar  2020
@Description : Test class for TVE_RejectOfferCtrl
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/
@isTest
public with sharing class TVE_RejectOfferCtrlTest {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Payment pending (Application submitted)';
    public static final string testUserEmail = 'testuser@TVERejectOfferCtrlTest.com';
    public static final string ARTFCT_RT = 'Upload_File';
    
    @TestSetup
    public static void setup() {
        
        //Create User
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
        
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        Insert projObj;
        
        Task taskRec = TVE_TestUtility.createTask(projObj.Id, testUser.Id, 'Test');
        taskRec.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =: ARTFCT_RT].Id;
        taskrec.subject='TEST TASK';
        Insert taskRec;
        
    } 
    
    public static testMethod void getRejReasonsTest(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];        
        System.runAs(testUser){            
            test.startTest();
            TVE_RejectOfferCtrl.getRejReasons();
            test.stopTest();            
        }
    }
    
    public static testMethod void saveRejectedReasonTest_1(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];     
        Task testTask = [SELECT Id,whatid FROM Task Where subject ='TEST TASK' ];
        project__c proj=[select id,status__c,sapstatus__c,recordtype.name from project__c where id=:testTask.whatid];
        System.runAs(testUser){            
            test.startTest();
            system.debug('project status-->'+proj.status__c);
            system.debug('project record type-->'+proj.recordtype.name);
            system.debug('project sap status-->'+proj.sapstatus__c);
            TVE_RejectOfferCtrl.saveRejectedReason(testTask.Id, 'My workload is at capacity', '');
            
            test.stopTest();            
        }
    }
    
    public static testMethod void saveRejectedReasonTest_2(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];     
        Task testTask = [SELECT Id FROM Task Where subject ='TEST TASK' ];
        System.runAs(testUser){            
            test.startTest();
            TVE_RejectOfferCtrl.saveRejectedReason(testTask.Id, 'I have upcoming leave','Test value');
            test.stopTest();            
        }
    }
    
    public static testMethod void saveRejectedReasonTest_Exception(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];     
        Task testTask = [SELECT Id FROM Task Where OwnerId =: testUser.Id ];
        System.runAs(testUser){            
            test.startTest();
            try{
            	TVE_RejectOfferCtrl.saveRejectedReason(testTask.Id, 'Other', '');    
            }catch(Exception e){
                
            }            
            test.stopTest();            
        }
    }
}