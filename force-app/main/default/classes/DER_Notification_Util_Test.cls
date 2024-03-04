/*
@author  : palash.awasthi@ausnetservices.com.au
@created : 18 Nov 2019
@Description : Test Class for createbusinessAccount
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
@isTest
public with sharing class DER_Notification_Util_Test {
    private static String customerEmail = 'customer@test12345.com';
    private static String installerEmail = 'installer@test12345.com';
    private static String repEmail = 'rep@test12345.com';
    
    @testSetup static void setup()
    {
        Id testDERAppId = DER_TestUtility.loadDERAppRecords(customerEmail, installerEmail, repEmail);
    }
    
    @isTest static void testBusinessAccountEmailUpdate(){
        
        //Create a new Business Account
        Account  businessAccount = DER_TestUtility.createBusinessAccount('New Business Account');
        insert businessAccount;
        
        //Create a new BusinessAccount Contact
        Contact businessAccountContact = DER_TestUtility.createBusinessAccountContact(businessAccount.Id,'Ved','Prakash','businesscustomer@gmail.com');
        insert businessAccountContact;
        
        //fetch the Case created from testsetup method
        List<Case> caseList = [Select Id, Customer__c, Customer_Email__c from Case LIMIT 1 ];
        if(caseList.size()>0){
            caseList[0].Customer__c = businessAccount.Id;
            update caseList;
            List<Case> caseListUpdated = [Select Id, Customer__c, Customer_Email__c from Case LIMIT 1 ];
            System.assertEquals('businesscustomer@gmail.com',caseListUpdated[0].Customer_Email__c);
        }
    }
    
    @isTest static void testBusinessAccountDelete(){
        
        List<Case> caseList = [Select Id, Customer__c from Case LIMIT 1 ];
        caseList[0].Customer__c = null;
        update caseList;
        List<Case> caseListUpdated = [Select Id, Customer__c, Customer_Email__c from Case LIMIT 1 ];
        System.assertEquals(null,caseListUpdated[0].Customer_Email__c);
    }
}