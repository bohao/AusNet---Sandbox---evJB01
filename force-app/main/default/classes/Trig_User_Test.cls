/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 10 Feb 2020
@Description : Test class for User Trigger and respective trigger logics
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/

@isTest
public class Trig_User_Test {
    public static final string testUserEmail = 'testuser@TVEArtefactControllerTest.com';
    public static final string testUserEmail2 = 'standarduser998@testorg.com';
    
    static testMethod void communityLicensetest(){
        test.startTest();  
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        User usr = [SELECT Id FROM User WHERE email=:testUserEmail2 LIMIT 1];
        System.runAs(testUser){
        User userObj = [select id,isActive from User where id = :usr.Id];
        userObj.IsActive = false;
        update userObj;
        userObj.IsActive = true;
        update userObj;
        }
        test.stopTest();
    }
    static testMethod void communityLicensePartnertest(){
      test.startTest();  
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        User usr = [SELECT Id FROM User WHERE email='standarduser@testorg.com' LIMIT 1];
        System.runAs(testUser){
        User userObj = [select id,isActive from User where id = :usr.Id];
        userObj.IsActive = false;
        update userObj;
        userObj.IsActive = true;
        update userObj;
        }
        test.stopTest();
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
        Contact contactNewInsert1 = new Contact(LastName ='testCon1',ownerId=testUser.Id,AccountId = accountNewInsert.Id,email='test12111@tgd.com');
        insert contactNewInsert1;
        Profile p1 = [SELECT Id FROM Profile WHERE Name='TVE-11 Partner User'];
        User usr1= new User(
            Alias = 'standt1',
            Email=testUserEmail2,
            EmailEncodingKey='UTF-8',
            LastName='Testing1',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p1.Id,
            contactId=contactNewInsert1.id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=testUserEmail2,
            isActive = true
        );
        insert usr1;
        }
    } 
}