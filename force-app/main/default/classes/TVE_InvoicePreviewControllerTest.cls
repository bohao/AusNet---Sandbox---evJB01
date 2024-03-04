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
public class TVE_InvoicePreviewControllerTest {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public static final string testUserEmail = 'testuser@TVEInvoicePreviewControllerTest.com';
    public static testMethod void testGetInvoices(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        Test.startTest();
        System.runAs(testUser){
            Project__c projObj = [select id from Project__c limit 1];
            Artefact__c artObj = [select id from Artefact__c LIMIT 1];
            system.debug('artObj'+artObj);

            TVE_TestUtility.insertFile(artObj.id);

            TVE_InvoicePreviewController.InvoiceWrapper listWrapper = TVE_InvoicePreviewController.getInvoices(projObj.id);
        }
    }

    @TestSetup
    public static void setup() {
        eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
        eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
        insert eSignObj;
        
        //Create User
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
        
        //Create Business Account
        Account testInstaller = TVE_TestUtility.createBusinessAccount('Business Account');
        insert testInstaller;
        
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        Insert projObj;
        
        Artefact__c artObj = TVE_TestUtility.createInvoiceArtefact('NameTest',projObj.Id,testInstaller.Id);
        insert artObj;
        
    }  
}