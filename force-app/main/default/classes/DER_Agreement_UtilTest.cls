/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 29 Oct 2019
@Description : Test Class for DER_Agreement_Util class
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
@isTest
public class DER_Agreement_UtilTest {
@isTest 
    static void teststatusChangeAndURLUpdate()
    {
        eSignSettings__c eSignObj = new eSignSettings__c(); 
        eSignObj.AES_Key__c = '';
        eSignObj.SetupOwnerId=UserInfo.getOrganizationId();
        insert eSignObj;
        test.startTest();
        DER_Agreement_Util.getEsignData();
        test.stopTest();
    }
    @isTest
    static void testEmptyCustomSettingRecord()
    {
        eSignSettings__c eSignObj = new eSignSettings__c(); 
        test.startTest();
        DER_Agreement_Util.getEsignData();
        test.stopTest();
    }
    
}