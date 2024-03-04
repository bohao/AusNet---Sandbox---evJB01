/*
@author  : dave.pavan@in.ibm.com    
@created : 28 April 2020
@Description : Test class for TVE_SiteOwnerAuthRepUtil
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
@isTest
public class TVE_SiteOwnerAuthRepUtilTest {
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Payment pending (Application submitted)';
    public static final string PROGRESS_BAR_STATUS_DESIGN = 'Payment pending (Application submitted)';
    public static final string testUserEmail = 'testuser@SiteOwnerAuthRepUtilTest.com';
    public static final string extPersonAccEmail = 'johnshow@SiteOwnerAuthRepUtilTest.com';
    public static final string extBusiAccABN1 = '123456780';
    public static final string extBusiAccABN2 = '123456781';
    public static final string extBusiContEmail = 'k_dorgo@got.com';
    public static final string extBusiContEmail2 = 'c_lannister@got.com';

    public static testMethod void Customer_PersonAccount_TestCase_1()
    {
        String TestCase_1_email = 'testcase1@test.com';

        //Create Business Account
        Account extistingBusiAcc1 = TVE_TestUtility.createBusinessAccount('Acme Pvt Ltd');
        extistingBusiAcc1.ABN_CINCL__c = '6655444444';
        insert extistingBusiAcc1;
        
        //Create Busines Contact
        Contact extistingBusiCont1 = TVE_TestUtility.createContact(extistingBusiAcc1.Id, 'Khal', 'Dorgo', TestCase_1_email);
        insert extistingBusiCont1;
        
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'Yes';

        //Site Owner         
        projObj.OwnerFirstName__c = 'Arya';
        projObj.OwnerLastName__c = 'Stark';
        projObj.OwnerCompany__c = null;
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = TestCase_1_email;
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = null ;        //ABN is not applicable for PersonAccount

        //Auth Rep
        projObj.AgentFirstName__c = 'Sansa';
        projObj.AgentLastName__c = 'Stark';
        projObj.AgentCompany__c = null;
        projObj.AgentMobile__c = '8932438932';
        projObj.AgentEmail__c = TestCase_1_email;
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = null ;        //ABN is not applicable for PersonAccount

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }
    
    public static testMethod void Customer_PersonAccount_TestCase_3()
    {
        String testCase_email = 'testcase3@test.com';

        Account existingPersonAcc = TVE_TestUtility.createPersonAccount('Snow', testCase_email );
        existingPersonAcc.FirstName = 'John';
        existingPersonAcc.PersonMobilePhone='9998887777';
        insert existingPersonAcc;

        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'Yes';

        //Site Owner         
        projObj.OwnerFirstName__c = 'John';
        projObj.OwnerLastName__c = 'Snow';
        projObj.OwnerCompany__c = null;
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = testCase_email;
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = null ;        //ABN is not applicable for PersonAccount

        //Auth Rep
        projObj.AgentFirstName__c = 'John';
        projObj.AgentLastName__c = 'Snow';
        projObj.AgentCompany__c = null;
        projObj.AgentMobile__c = '9998887777';
        projObj.AgentEmail__c = testCase_email;
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = null ;        //ABN is not applicable for PersonAccount

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }

    public static testMethod void Customer_PersonAccount_TestCase_4()
    {
        String testCase_email = 'testcase4@test.com';

        Account existingPersonAcc = TVE_TestUtility.createPersonAccount('John Snow', testCase_email );
        existingPersonAcc.PersonMobilePhone='123456789';
        insert existingPersonAcc;

        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'Yes';

        //Site Owner         
        projObj.OwnerFirstName__c = 'Arya';
        projObj.OwnerLastName__c = 'Stark';
        projObj.OwnerCompany__c = null;
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = testCase_email;
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = null ;        //ABN is not applicable for PersonAccount

        //Auth Rep
        projObj.AgentFirstName__c = 'Sansa';
        projObj.AgentLastName__c = 'Stark';
        projObj.AgentCompany__c = null;
        projObj.AgentMobile__c = '8932438932';
        projObj.AgentEmail__c = testCase_email;
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = null ;        //ABN is not applicable for PersonAccount

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }

    public static testMethod void Customer_PersonAccount_TestCase_5()
    {
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'Yes';

        //Site Owner         
        projObj.OwnerFirstName__c = 'Arya';
        projObj.OwnerLastName__c = 'Stark';
        projObj.OwnerCompany__c = null;
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = 'a_stark@got.com';
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = null ;        //ABN is not applicable for PersonAccount

        //Auth Rep
        projObj.AgentFirstName__c = 'Sansa';
        projObj.AgentLastName__c = 'Stark';
        projObj.AgentCompany__c = null;
        projObj.AgentMobile__c = '8932438932';
        projObj.AgentEmail__c = 's_stark@got.com';
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = null ;        //ABN is not applicable for PersonAccount

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }
    
    public static testMethod void Customer_BusinessAccount_TestCase_17()
    {
        String testCase_email = 'testcase17@test.com';

        //Create Business Account
        Account extistingBusiAcc1 = TVE_TestUtility.createBusinessAccount('Acme Pvt Ltd');
        extistingBusiAcc1.ABN_CINCL__c = '6655444444';
        insert extistingBusiAcc1;
        
        //Create Busines Contact
        Contact extistingBusiCont1 = TVE_TestUtility.createContact(extistingBusiAcc1.Id, 'Khal', 'Dorgo', testCase_email);
        insert extistingBusiCont1;

        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'Yes';
        
        //Site Owner         
        projObj.OwnerFirstName__c = 'Arya';
        projObj.OwnerLastName__c = 'Stark';
        projObj.OwnerCompany__c = 'GOT';
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = testCase_email;
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = extBusiAccABN1;

        //Auth Rep
        projObj.AgentFirstName__c = 'Sansa';
        projObj.AgentLastName__c = 'Stark';
        projObj.AgentCompany__c = 'GOT';
        projObj.AgentMobile__c = '8932438932';
        projObj.AgentEmail__c = testCase_email;
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = extBusiAccABN2;

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }
    
    public static testMethod void ASP_PersonAccount_TestCase_20()
    {
        String testCase_email = 'testcase20@test.com';

        Account existingPersonAcc = TVE_TestUtility.createPersonAccount('Snow', testCase_email );
        existingPersonAcc.FirstName = 'John';
        existingPersonAcc.PersonMobilePhone='9998887777';
        insert existingPersonAcc;

        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'No';
        projObj.RelationshipToOwner__c = 'Accredited Service Provider - AusNet Services';
        
        //Site Owner         
        projObj.OwnerFirstName__c = 'Arya';
        projObj.OwnerLastName__c = 'Stark';
        projObj.OwnerCompany__c = null;
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = testCase_email;
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = null ;        //ABN is not applicable for PersonAccount

        //Auth Rep
        projObj.AgentFirstName__c = 'Sansa';
        projObj.AgentLastName__c = 'Stark';
        projObj.AgentCompany__c = null;
        projObj.AgentMobile__c = '8932438932';
        projObj.AgentEmail__c = testCase_email;
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = null ;        //ABN is not applicable for PersonAccount

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }

    public static testMethod void ASP_PersonAccount_TestCase_21()
    {
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'No';
        projObj.RelationshipToOwner__c = 'Accredited Service Provider - AusNet Services';
        
        //Site Owner         
        projObj.OwnerFirstName__c = 'Arya';
        projObj.OwnerLastName__c = 'Stark';
        projObj.OwnerCompany__c = null;
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = 'a_stark@got.com';
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = null ;        //ABN is not applicable for PersonAccount

        //Auth Rep
        projObj.AgentFirstName__c = 'Sansa';
        projObj.AgentLastName__c = 'Stark';
        projObj.AgentCompany__c = null;
        projObj.AgentMobile__c = '8932438932';
        projObj.AgentEmail__c = 's_stark@got.com';
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = null ;        //ABN is not applicable for PersonAccount

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }
    

    public static testMethod void ASP_BusinessAccount_TestCase_27()
    {
        String TestCase_27_email = 'testCase27@test.com';

        //Create Business Account
        Account extistingBusiAcc1 = TVE_TestUtility.createBusinessAccount('Acme Pvt Ltd');
        extistingBusiAcc1.ABN_CINCL__c = '6655444444';
        insert extistingBusiAcc1;
        
        //Create Busines Contact
        Contact extistingBusiCont1 = TVE_TestUtility.createContact(extistingBusiAcc1.Id, 'Khal', 'Dorgo', TestCase_27_email);
        insert extistingBusiCont1;
        

        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'No';
        projObj.RelationshipToOwner__c = 'Accredited Service Provider - AusNet Services';
        
        //Site Owner         
        projObj.OwnerFirstName__c = 'Arya';
        projObj.OwnerLastName__c = 'Stark';
        projObj.OwnerCompany__c = 'GOT';
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = TestCase_27_email;
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = '6655444444';

        //Auth Rep
        projObj.AgentFirstName__c = 'Sansa';
        projObj.AgentLastName__c = 'Stark';
        projObj.AgentCompany__c = 'GOT';
        projObj.AgentMobile__c = '8889998888';
        projObj.AgentEmail__c = TestCase_27_email;
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = '6655444444';

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }

    public static testMethod void ASP_BusinessAccount_TestCase_28()
    {
        String TestCase_28_email = 'testCase28@test.com';
        String TestCase_28_email_2 = 'testCase28_2@test.com';

        //Create Business Account
        Account extistingBusiAcc1 = TVE_TestUtility.createBusinessAccount('Acme Pvt Ltd');
        extistingBusiAcc1.ABN_CINCL__c = '6655444444';
        insert extistingBusiAcc1;
        
        //Create Busines Contact
        Contact extistingBusiCont1 = TVE_TestUtility.createContact(extistingBusiAcc1.Id, 'Khal', 'Dorgo', TestCase_28_email);
        insert extistingBusiCont1;
        

        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'No';
        projObj.RelationshipToOwner__c = 'Accredited Service Provider - AusNet Services';
        
        //Site Owner         
        projObj.OwnerFirstName__c = 'Arya';
        projObj.OwnerLastName__c = 'Stark';
        projObj.OwnerCompany__c = 'GOT';
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = TestCase_28_email_2;
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = '6655444444';

        //Auth Rep
        projObj.AgentFirstName__c = 'Sansa';
        projObj.AgentLastName__c = 'Stark';
        projObj.AgentCompany__c = 'GOT';
        projObj.AgentMobile__c = '8889998888';
        projObj.AgentEmail__c = TestCase_28_email_2;
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = '6655444444';

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }

    //Have existing person account
    public static testMethod void ASP_BusinessAccount_TestCase_29()
    {
        Account existingPersonAcc = TVE_TestUtility.createPersonAccount('John Snow', extPersonAccEmail );
        existingPersonAcc.PersonMobilePhone='123456789';
        insert existingPersonAcc;

        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'No';
        projObj.RelationshipToOwner__c = 'Accredited Service Provider - AusNet Services';
        
        //Site Owner         
        projObj.OwnerFirstName__c = 'Arya';
        projObj.OwnerLastName__c = 'Stark';
        projObj.OwnerCompany__c = 'GOT';
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = extPersonAccEmail;
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = '66554444433';

        //Auth Rep
        projObj.AgentFirstName__c = 'Sansa';
        projObj.AgentLastName__c = 'Stark';
        projObj.AgentCompany__c = 'GOT';
        projObj.AgentMobile__c = '8932438932';
        projObj.AgentEmail__c = extPersonAccEmail;
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = '6655444441';

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }

    //Have existing business account and with fuzzy match and ASPaccreditaionID__c
    public static testMethod void ASP_BusinessAccount_TestCase_30()
    {
        //Create Business Account
        Account extistingBusiAcc1 = TVE_TestUtility.createBusinessAccount('Acme Pvt Ltd');
        extistingBusiAcc1.ABN_CINCL__c = extBusiAccABN1;
        extistingBusiAcc1.ASPaccreditaionID__c  = 'Accr1234';
        insert extistingBusiAcc1;
        
        //Create Busines Contact
        Contact extistingBusiCont1 = TVE_TestUtility.createContact(extistingBusiAcc1.Id, 'Khal', 'Dorgo', extBusiContEmail);
        insert extistingBusiCont1;
                
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'No';
        projObj.RelationshipToOwner__c = 'Accredited Service Provider - AusNet Services';
        
        //Site Owner         
        projObj.OwnerFirstName__c = 'Khal';
        projObj.OwnerLastName__c = 'Dorgo';
        projObj.OwnerCompany__c = 'GOT';
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = extBusiContEmail;
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = '33222222';

        //Auth Rep
        projObj.AgentFirstName__c = 'Cersei';
        projObj.AgentLastName__c = 'Lannister';
        projObj.AgentCompany__c = 'GOT';
        projObj.AgentMobile__c = '8932438932';
        projObj.AgentEmail__c = extBusiContEmail;
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = '33224422211';

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }

    //Have existing business account and with fuzzy match but no ASPaccreditaionID__c
    public static testMethod void ASP_BusinessAccount_TestCase_31()
    {
        //Create Business Account
        Account extistingBusiAcc1 = TVE_TestUtility.createBusinessAccount('Acme Pvt Ltd');
        extistingBusiAcc1.ABN_CINCL__c = extBusiAccABN1;
        insert extistingBusiAcc1;
        
        //Create Busines Contact
        Contact extistingBusiCont1 = TVE_TestUtility.createContact(extistingBusiAcc1.Id, 'Khal', 'Dorgo', extBusiContEmail);
        insert extistingBusiCont1;
                
        // //Create Business Account
        // Account extistingBusiAcc2 = TVE_TestUtility.createBusinessAccount('Bingo Pvt Ltd');
        // extistingBusiAcc2.ABN_CINCL__c = extBusiAccABN2;
        // insert extistingBusiAcc2;
        
        // //Create Busines Contact
        // Contact extistingBusiCont2 = TVE_TestUtility.createContact(extistingBusiAcc2.Id, 'Cersei', 'Lannister', extBusiContEmail2);
        // insert extistingBusiCont2;        

        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'No';
        projObj.RelationshipToOwner__c = 'Accredited Service Provider - AusNet Services';
        
        //Site Owner         
        projObj.OwnerFirstName__c = 'Khal';
        projObj.OwnerLastName__c = 'Dorgo';
        projObj.OwnerCompany__c = 'GOT';
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = extBusiContEmail;
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = '33222222';

        //Auth Rep
        projObj.AgentFirstName__c = 'Cersei';
        projObj.AgentLastName__c = 'Lannister';
        projObj.AgentCompany__c = 'GOT';
        projObj.AgentMobile__c = '8932438932';
        projObj.AgentEmail__c = extBusiContEmail;
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = '33224422211';

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }

    //Have existing business account but no fuzzy match
    public static testMethod void ASP_BusinessAccount_TestCase_32()
    {
        //Create Business Account
        Account extistingBusiAcc1 = TVE_TestUtility.createBusinessAccount('Acme Pvt Ltd');
        //extistingBusiAcc1.ABN_CINCL__c = extBusiAccABN1;
        extistingBusiAcc1.ABN_CINCL__c = '6677888888';
        database.insert(extistingBusiAcc1,false) ;
        system.debug('extistingBusiAcc1'+extistingBusiAcc1);
        
        //Create Busines Contact
        Contact extistingBusiCont1 = TVE_TestUtility.createContact(extistingBusiAcc1.Id, 'Khal', 'Dorgo', extBusiContEmail);
        insert extistingBusiCont1;

        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'No';
        projObj.RelationshipToOwner__c = 'Accredited Service Provider - AusNet Services';
        
        //Site Owner         
        projObj.OwnerFirstName__c = 'Arya';
        projObj.OwnerLastName__c = 'Stark';
        projObj.OwnerCompany__c = 'GOT';
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = extBusiContEmail;
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = extBusiAccABN1;

        //Auth Rep
        projObj.AgentFirstName__c = 'Sansa';
        projObj.AgentLastName__c = 'Stark';
        projObj.AgentCompany__c = 'GOT';
        projObj.AgentMobile__c = '8932438932';
        projObj.AgentEmail__c = extBusiContEmail;
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = extBusiAccABN2;

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }

    public static testMethod void ASP_BusinessAccount_TestCase_33()
    {
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        
        projObj.IsPropertyOwner__c = 'No';
        projObj.RelationshipToOwner__c = 'Accredited Service Provider - AusNet Services';
        
        //Site Owner         
        projObj.OwnerFirstName__c = 'Arya';
        projObj.OwnerLastName__c = 'Stark';
        projObj.OwnerCompany__c = 'GOT';
        projObj.OwnerMobile__c = '9998887777';
        projObj.OwnerEmail__c = 'a_stark@got.com';
        projObj.OwnerStreet__c = '123 High Streets';
        projObj.OwnerABN__c = '6655555555';

        //Auth Rep
        projObj.AgentFirstName__c = 'Sansa';
        projObj.AgentLastName__c = 'Stark';
        projObj.AgentCompany__c = 'GOT';
        projObj.AgentMobile__c = '8932438932';
        projObj.AgentEmail__c = 's_stark@got.com';
        projObj.AgentStreet__c = '555 Wall Streets';
        projObj.AgentABN__c = '6655551111';

        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        System.runAs(testUser)
        {
            Database.Insert(projObj,false) ;                
        }
    }
    
    

    @TestSetup
    public static void setup() 
    {
        
        //Create User
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;        
    }
}