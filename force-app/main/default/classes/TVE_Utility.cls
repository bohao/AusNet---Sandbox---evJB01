/*
@author  : Brajesh Tiwary
@created : 13 Jan 2020
@Description : To populate custom setting data
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
23-OCT-19           brajesh.tiwary@ausnetservices.com.au   Added method getEsignData
24-MAR-20           dave.pavan@in.ibm.com               TV-2473, TV-2456, Fixed alignment
-----------------------------------------------------------------------------------------
*/
public class TVE_Utility {
    
    public static eSignSettings__c updateTVEeSignURL(eSignSettings__c eSignObj){
        
        //------------------------------------//
        //----URLs fo un-regsitred users------//
        //------------------------------------//

        List<TVE_External_URL__mdt> lstExtUrl = new List<TVE_External_URL__mdt>([SELECT Id, DeveloperName, URL__c FROM TVE_External_URL__mdt]);
        Map<String, String> mapExternalURL = new Map<String, String>();
        
        for(TVE_External_URL__mdt item: lstExtUrl)
        {
            if(item.URL__c != null){
                mapExternalURL.put(item.DeveloperName, item.URL__c);
            }
        }

        if(!lstExtUrl.isEmpty() && !mapExternalURL.isEmpty())
        {        
            eSignObj.TVE_Project_URL_Unregistered__c = mapExternalURL.get('TVE_Project_URL_Unregistered');
            eSignObj.TVE_Doc_Upload_URL_Unregistered__c = mapExternalURL.get('TVE_Doc_Upload_URL_Unregistered');
            eSignObj.TVE_Project_URL_Sitecore__c = mapExternalURL.get('TVE_Project_URL_Sitecore');
            eSignObj.TVE_Sitecore_Acceptance_URL__c = mapExternalURL.get('TVE_Sitecore_Acceptance_URL');            
        }
        else
        {
            throw new TVE_ConfigurationException('No valid records found for custom setting TVE_External_URL__mdt');
        }

        //------------------------------------//
        //----URLs fo regsitred users---------//
        //------------------------------------//
        
        List<Network> listNet = [SELECT id, Name FROM Network]; 
        Map<String, Id> mapCommunity = new Map<String, Id>();

        if(!listNet.isEmpty())
        {
            for(Network item: listNet){
                mapCommunity.put(item.Name, item.Id);
            }

            // -------------------------------------------------------------//
            //-- Customer Community - Replacing login from he network URL --//
            // -------------------------------------------------------------//

            string communityLink = Network.getLoginUrl(mapCommunity.get('CustomerCommunity'));
            string cc_login_link;         

            if(communityLink.contains('/s/login')){
                cc_login_link =  communityLink.replace('login','');
                cc_login_link += 'project/';
            }else{
                cc_login_link = communityLink.replace('login','');
                cc_login_link += 's/project/';
            }

            if(mapCommunity.containsKey('CustomerCommunity'))
                eSignObj.TVE_Project_URL_Customer_Community__c = cc_login_link;
            
            // -------------------------------------------------------------//
            // ---Partner Community - Replacing login from he network URL --//
            // -------------------------------------------------------------//

            string pc_login_link;
            string partnerLink = Network.getLoginUrl(mapCommunity.get('PartnerCommunity'));
            
            if(partnerLink.contains('/s/login')){
                pc_login_link = partnerLink.replace('login','');
                pc_login_link += 'project/';
            }else{
                pc_login_link = partnerLink.replace('login','');
                pc_login_link += 's/project/';
            }
            
            if(mapCommunity.containsKey('PartnerCommunity'))
                eSignObj.TVE_Project_URL_Partner_Community__c = pc_login_link;
        }
        return eSignObj;
    }

    // To create unique msg Id for callouts
    public static string getUniqueId(Id recordId){
        string msgId = '';
        DateTime dtNow = DateTime.now();
        msgId = (String)recordId + dtNow.getTime();
        return msgId;
    }
}