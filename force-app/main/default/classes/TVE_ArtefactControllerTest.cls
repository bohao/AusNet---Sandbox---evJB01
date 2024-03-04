/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 19th Dec 2019
@Description : test class for Aura TVE_ArtefactController
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
@isTest
public class TVE_ArtefactControllerTest {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public static final string testUserEmail = 'testuser@TVEArtefactControllerTest.com';
    public static testMethod void testDoPost_Exception(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        Test.startTest();
        System.runAs(testUser){
            TVE_ArtefactController.wrapContentVersionDoc lstWrap = new TVE_ArtefactController.wrapContentVersionDoc();
            Project__c projObj = [select id from Project__c limit 1];
            Artefact__c artObj = [select id from Artefact__c LIMIT 1];
            system.debug('artObj'+artObj);
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins',
                PathOnClient = 'Penguins.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            insert contentVersion;    
            List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
            
            //create ContentDocumentLink  record 
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = artObj.id;
            cdl.ContentDocumentId = documents[0].Id;
            cdl.shareType = 'V';
            insert cdl;
            list<TVE_ArtefactController.wrapContentVersionDoc> listWrapper = new list<TVE_ArtefactController.wrapContentVersionDoc>();
            listWrapper = TVE_ArtefactController.getArtefactList(projObj.id);
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
        
        Artefact__c artObj = TVE_TestUtility.createOfferArtefact('NameTest',projObj.Id,testInstaller.Id);
        insert artObj;
        
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = artObj.Id;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = documents[0].Id;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
    }  
}