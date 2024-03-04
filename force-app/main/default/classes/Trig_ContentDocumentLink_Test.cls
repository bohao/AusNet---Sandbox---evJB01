/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 27 Jan 2020
@Description : test class for Aura Trig_ContentDocumentLink
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
@isTest
public class Trig_ContentDocumentLink_Test {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public static final string testUserEmail = 'testuser@TVEArtefactControllerTest.com';
    public static testMethod void testDocCreation(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        eSignSettings__c eSign = [Select id, AES_Key__c from eSignSettings__c];
        Test.startTest();
        System.runAs(testUser){
            Project__c projObj = [select id from Project__c limit 1];
            Artefact__c artObj = [select id from Artefact__c LIMIT 1];
            system.debug('artObj'+artObj);
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguin.jpg',
                VersionData = Blob.valueOf('Test Content1'),
                IsMajorVersion = true,
                ContentLocation='S '
            );
            insert contentVersion;
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = artObj.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            Database.insert(cdl);
            test.stopTest();
        }
    }
    public static testMethod void testDocDeletion(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        eSignSettings__c eSign = [Select id, AES_Key__c from eSignSettings__c];
        Test.startTest();
        System.runAs(testUser){
            Project__c projObj = [select id from Project__c limit 1];
            Artefact__c artObj = [select id from Artefact__c LIMIT 1];
            system.debug('artObj'+artObj);
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins1.jpg',
                VersionData = Blob.valueOf('Test Content2'),
                IsMajorVersion = true,
                ContentLocation='S '
            );
            insert contentVersion; 
            List<ContentDocumentLink> linkToDel = new List<ContentDocumentLink>();
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = artObj.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            delete cdl;
            test.stopTest();
        }
    }
    @TestSetup
    public static void setup() {
        
        //Create User
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
		eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
        eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
        insert eSignObj;        
        //Create Business Account
        Account testInstaller = TVE_TestUtility.createBusinessAccount('Business Account');
        insert testInstaller;
        Contact con = new Contact();
        con.LastName = 'Test';
        insert con;
        
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        projObj.OwnerLastName__c = 'testLastName2';
        projObj.OwnerCompany__c = 'testOwnerComp2';
        projObj.PropertyOwnerContact__c = con.Id;
        projObj.IsPropertyOwner__c = 'No';
        projObj.Company__c = 'Test12';
        projObj.PaymentReferenceNumber__c = '123';
        projObj.RelationshipToOwner__c = 'Developer';
        Insert projObj;
        
        Artefact__c artObj = TVE_TestUtility.createInvoiceArtefact('NameTest',projObj.Id,testInstaller.Id);
        artObj.Status__c='Pending Payment';
        artObj.InvoicePaidDate__c=null;
        artObj.ElectronicPaymentReferenceNumber__c=null;
        insert artObj;
        
    }  

}