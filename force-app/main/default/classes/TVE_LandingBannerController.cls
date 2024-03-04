/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 3 March 2020
@Description : Class for landing banner component
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
public with sharing class TVE_LandingBannerController {
    @AuraEnabled(cacheable=true)
    public static string getSitecoreEncryptedUrl(){
        string encryptedUrlProject = '';
        eSignSettings__c siteCoreAppUrl = eSignSettings__c.getInstance();
        system.debug('siteCoreAppUrl'+siteCoreAppUrl.AES_Key__c);
        if(siteCoreAppUrl!=null && siteCoreAppUrl.AES_Key__c!=null){
            system.debug('testUer'+UserInfo.getUserId());
            User userObj = [select id,ContactId from User where id= :UserInfo.getUserId()];
            Blob key;
            if(siteCoreAppUrl.AES_Key__c!=null){
                key = EncodingUtil.base64Decode(siteCoreAppUrl.AES_Key__c);
            }
            Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(userObj.ContactId));
            String base64EncryptedString = EncodingUtil.base64Encode(encrypted);
            if(siteCoreAppUrl.TVE_Project_URL_Sitecore__c != null){
                //Added by JTan on 07/04/2020 for TV-2456
                base64EncryptedString = base64EncryptedString.replace('+','-').replace('/', '_');
                encryptedUrlProject = siteCoreAppUrl.TVE_Project_URL_Sitecore__c + base64EncryptedString;
            }
            return encryptedUrlProject;
        }else{
            throw new TVE_ConfigurationException('No valid records found for custom setting API named eSignSettings__c');
        }
     }
}