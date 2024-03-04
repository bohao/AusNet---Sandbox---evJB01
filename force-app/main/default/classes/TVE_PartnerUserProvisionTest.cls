/*
@author  : arti.fogla@ausnetservices.com.au
@created : 07 May 2020
@Description : test class for Partner User Provisioning
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/

@istest
public class TVE_PartnerUserProvisionTest {
    public static final string testUserEmail = 'testuser123_unique@gmail.com';
    public static final string testuserRole  = 'DER TVE-11 Manager'; 
    
    
    public static testmethod void UserProvisiontest(){
        UserRole uRole=new UserRole(name=testuserRole);
        insert uRole;
        User currentUser =[select id ,name from user where Email =:testUserEmail];
        currentUser.userRoleId=uRole.id;
        update currentUser;
        System.runAs(currentUser){
        String soql;
        DateTime DTTM = DateTime.now().addHours(-1);
        String sDTTM = DTTM.formatGMT('yyyy-MM-dd') + 'T' + dttm.formatGMT('HH:mm:ss.SSS') + 'Z';
        String soql_acc = 'SELECT Id FROM ACCOUNT';// WHERE id =\''+ acc.id + '\' '   ;
        TVE_PartnerUserProvision userProvision = new TVE_PartnerUserProvision(soql_acc, true, true);
        userProvision.enableAccountAsPartner();
        userProvision.createPartnerUser();
        }
        
    }
    
    @TestSetup
    public static void setup() {
        User testUser=TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
        Account testInstaller = TVE_TestUtility.createBusinessAccount('Business Account');
        testInstaller.ABN__c = '123456789';
        testInstaller.ownerid=testUser.id;
        insert testInstaller ;
        Contact con = TVE_TestUtility.createContact();
        con.Email=testUserEmail;
        con.AccountId=testInstaller.id;
        con.Phone='123456789';
        con.MobilePhone='12345678';
        con.MailingStreet='testStreet';
        con.MailingCity='City';
        con.MailingState='State';
        con.MailingPostalCode='Postalcode';
        insert con;
    }  
}