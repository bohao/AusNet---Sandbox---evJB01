/*
@author  : dave.pavan@in.ibm.com
@created : 29 May 2020
@Description : Class for Account Util method for TVE team
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-------------------------------------------------------------------------------------------------------
NA                  NA                                NA
-------------------------------------------------------------------------------------------------------
*/

public without sharing class TVE_Account_Util {
    
    public static void UpdateProjectUrl_On_CustomerUpdate(Set<id>ContactIds)
    {
        eSignSettings__c eSign = eSignSettings__c.getInstance();
        System.debug('eSign' + eSign);
        if(eSign != null)
        {
            if(eSign.AES_Key__c != null)
            {   
                if(ContactIds!=null)
                {
                    system.debug('ContactIds:'+ContactIds);
                    
                    List<Project__c>projToUpdate=new List<Project__c>();

                    for(project__c proj :[SELECT Id, TVE_Project_URL__c, TriageDescription__c, WorkCode__c,
                                          ApplicantContact__c, ApplicantContact__r.UserCommunityLicense__c,
                                          IsPropertyOwner__c, RelationshipToOwner__c,
                                          CommunityChatterLink__c, UploadDocumentsLink__c, SitecoreAcceptanceLink__c
                                          FROM Project__c WHERE ApplicantContact__c IN : ContactIds
                                          AND ApplicantContact__r.UserCommunityLicense__c != null] )
                    {   
                        projToUpdate.add(TVE_Project_Utility.ProjectLinkMapping(proj, eSign, null));
                    }

                    if(!projToUpdate.isEmpty())
                    {
                        update projToUpdate;
                    }
                }
            }
            else 
            {
                System.debug('UpdateProjectUrl_On_CustomerUpdate----> eSign.AES_Key__c is NOT set');
                //throw new TVE_ConfigurationException('AES key is not set for custom setting eSignSettings__c');
            }            
        }else{
            System.debug('eSignSettings__c data not found');
            throw new TVE_ConfigurationException('No valid records found for custom setting eSignSettings__c');
        }
        
    }
}