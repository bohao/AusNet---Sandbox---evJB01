/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 04 March 2020
@Description : Test class for apex class TVE_LandingBannerController
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/

@isTest
public class TVE_LandingBannerController_Test {
    public static final string testUserEmail = 'testuser@TVEArtefactControllerTest.com';
    public static testMethod void contactAssignedToUser()
    {
        string sitecoreUrl = '';
        try
        {
            User usr = [select id from User where email='standarduser@testorg.com'];
            System.runAs(usr){
                eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
                eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
                eSignObj.TVE_Project_URL_Sitecore__c = 'https://der.ausnetservices.com.au/New-connections/Electricity-Connections-New?Id=';
                insert eSignObj;
                
                test.startTest();
                sitecoreUrl = TVE_LandingBannerController.getSitecoreEncryptedUrl();
                test.stopTest();
            }
        }
        catch(Exception e){
            System.debug(e);
        }
    }
    @TestSetup
    public static void setup() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
		insert r;
        //Create User
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        testUser.UserRoleId = r.Id;
        insert testUser;
        system.runAs(testUser){
        //Create Business Account
        Contact con = new Contact();
        con.LastName = 'test1';
        Database.insert(con,false);
        system.debug('con'+con);
        Account accountNewInsert = new Account(name ='test') ;
        insert accountNewInsert;
        Contact contactNewInsert = new Contact(LastName ='testCon',ownerId=testUser.Id,AccountId = accountNewInsert.Id,email='test1211@tgd.com');
        
        insert contactNewInsert;
        
        
        system.debug('Test Contact'+ contactNewInsert);
        Profile p = [SELECT Id FROM Profile WHERE Name='TVE-11 Customer User'];
        
        User usr= new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            contactId=contactNewInsert.id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standarduser@testorg.com',
            isActive = true
        );
        insert usr;
        }
        
    }
}