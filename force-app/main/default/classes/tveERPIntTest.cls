/*
@author  : Lakshay Sharma <Lakshay.Sharma@ausnetservices.com.au>
@created : 11th Feb 2020
@Description :Test class for Controller class of LWC component tveERPIntegrationAppPage
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/
@isTest
public class tveERPIntTest {
     public static final string testUserEmail = 'testuser@TVEIntegInitiationControllerTest.com';
    public static ID intTask_arte_Id = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByName().get('Artefact').getRecordTypeId();
    public static ID intTask_opp_Id = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByName().get('Opportunity').getRecordTypeId();
    public static ID intTask_workord_Id = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByName().get('WorkOrder').getRecordTypeId();

    @testSetup
    public static void setup() {
        Integration_Task__c intTask=new Integration_Task__c();
        intTask.Status__c='In Progress';
        intTask.Type__c	='CreateCustomer';
        
        insert intTask;
                Integration_Task__c intTask4=new Integration_Task__c();
        intTask.Status__c='Ready';
        intTask4.Type__c	='CreateCustomer';
        insert intTask4;
        
        Integration_Task__c intTask2=new Integration_Task__c();
        intTask2.Status__c='In Progress';
        intTask2.Type__c ='GetInvoice';
        intTask2.RecordTypeID=intTask_arte_Id;
        insert intTask2;
        
        Integration_Task__c intTask3=new Integration_Task__c();
        intTask3.Status__c='In Progress';
        intTask3.Type__c='UpdateCM';
        insert intTask3;
    }
    @isTest
    public static void testtveERPIntchecklist(){
        List<Integration_Task__c> intlist = [SELECT Id,Status__c  FROM Integration_Task__c WHERE Status__c='In Progress'];
        test.startTest();
        tveERPInt.tveERPIntchecklist();
        test.stopTest();
    }
    @isTest
    public static void testQueueableApex(){
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
		
        PermissionSet psa = [SELECT Id FROM PermissionSet WHERE Name = 'Execute_SAP_Integration'];
        insert new PermissionSetAssignment(AssigneeId = testUser.id, PermissionSetId = psa.Id);
        
         List<Integration_task__c> listintTask=[SELECT Id, Status__c,Type__c FROM Integration_Task__c
                                                                                   WHERE Status__c ='In Progress'];
        List<Integration_task__c> listintTask2=[SELECT Id, Status__c,Type__c FROM Integration_Task__c
                                                                                   WHERE Status__c ='Ready'];
        System.runAs(testUser){
        test.startTest();
        tveERPInt.callqueueableapex();
        test.stopTest();
        }
    
}
}