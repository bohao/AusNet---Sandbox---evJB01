/*
@author  : Arti.foglae@ausnetservices.com.au
@created : 13 Mar  2020
@Description : test class for TVE_InternalUsersLookupCtrl
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/
@istest
public class TVE_InternalUsersLookupCtrlTest {
    public static final string testUserEmail = 'testuser@TVEArtefactControllerTest.com';
    public static testMethod void testGetResults(){
        user u=[SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        Account testAcc = TVE_TestUtility.createBusinessAccount('Business Account');
        testAcc.ownerId=u.id;
        insert testAcc;
        List<Contact>conList=new List<Contact>();
        Contact con = TVE_TestUtility.createContact();
        con.AccountId=testAcc.id;
        contact con1=new contact(FirstName = 'test',
                                 LastName = 'user',
                                 email = 'Arti.Fogla@ausnetservices.com.au');
        con1.AccountId=testAcc.id;
        conList.add(con);
        conList.add(con1);
        insert conList;
        
        Id profileId =[select id,name from profile where Name='TVE-11 Customer User'].id;
        
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        testUser.profileid=profileId;
        testUser.contactId=conList[0].id;
        insert testUser;
        User testUser1 = TVE_TestUtility.createTestUser(testUserEmail);
        testUser1.profileid=profileId;
        testUser1.contactId=conList[1].id;
        insert testUser1;
        system.debug('testUser:'+testUser);
        system.debug('testUser1:'+testUser1);
        
        test.startTest();
        System.runAs(testUser){
            
            TVE_InternalUsersLookupCtrl.getResults('D');
            
        }
        test.stopTest();
    }
    
    @TestSetup
    public static void setup() {
        UserRole roleId=[SELECT Id,Name FROM UserRole where Name = 'DER TVE-11 User' limit 1];
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        testUser.UserRoleId=roleId.id;
        insert testUser;
    }
    
}