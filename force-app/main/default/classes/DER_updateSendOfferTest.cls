/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 28 Oct 2019
@Description : Test Class for DER_updateSendOffer class
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
@isTest
public class DER_updateSendOfferTest {
@isTest static void teststatusChangeAndURLUpdate()
    {
       //Create Individual Account
        Account testCustomer = new Account();
        testCustomer.Name = 'test';
        testCustomer.ABN__c = '1234567890';
        insert testCustomer;
        DER_Application__c testDERApp = new DER_Application__c();
        insert testDERApp;
        DER_Agreement__c agr = DER_TestUtility.createAgreement(testDERApp.Id,testCustomer.id,null,null,null,null);
        agr.status__c = 'Offer Expired';
        insert agr;
        
        Contact instCont = DER_TestUtility.createBusinessAccountContact(testCustomer.Id, 'Test', 'Test', 'test@derapp1212121.com');
        insert instCont;
        eSignSettings__c esign = new eSignSettings__c();
        esign.AES_Key__c = 'kKxPMcESCQOueOnmX5B5xw==';
        esign.DER_Offer_URL__c = 'google.com';
        esign.Name = 'test';
        insert esign;
        //Create case for Customer
        Case testCaseForCustomer = DER_TestUtility.createCaseForInstaller(DER_REST_Application_v1.CASE_RECORDTYPE_AUTO, 'More Info Required', 'Email', 'Low', testCustomer.Id, instCont.Id);        
        testCaseForCustomer.DER_Application__c = testDERApp.Id;
        testCaseForCustomer.Send_DER_Offer__c = false;
        testCaseForCustomer.Invoice_Number__c = '12345';
        insert testCaseForCustomer;
        string isUpdated = '';
        test.startTest();
        isUpdated = DER_updateSendOffer.updateOfferOnManualPage(testCaseForCustomer.Id);
        //offer.updateOfferOnManualPage(testCaseForCustomer.Id);
        test.stopTest();
        Id manualRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('DER Application - Manual').getRecordTypeId();
        testCaseForCustomer.recordTypeId = manualRecordTypeId;
        testCaseForCustomer.Status = 'Closed';
        update testCaseForCustomer;
        isUpdated = DER_updateSendOffer.updateOfferOnManualPage(testCaseForCustomer.Id);       
    }
}