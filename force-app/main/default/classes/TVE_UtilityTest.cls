/*
@author  : dave.pavan@in.ibm.com
@created : 24 Mar 2020
@Description : Test Class for TVE_Utility class
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
@isTest
public class TVE_UtilityTest  {
@isTest 
    static void getUniqueId_test()
    {
        test.startTest();
        TVE_Utility.getUniqueId(UserInfo.getOrganizationId());
        test.stopTest();
    }
    @isTest
    static void updateTVEeSignURL_test()
    {
        eSignSettings__c eSignObj = new eSignSettings__c(); 
        eSignObj.AES_Key__c = '';
        eSignObj.SetupOwnerId=UserInfo.getOrganizationId();
        insert eSignObj;
        
        test.startTest();
        TVE_Utility.updateTVEeSignURL(eSignObj);
        test.stopTest();
    }
    
}