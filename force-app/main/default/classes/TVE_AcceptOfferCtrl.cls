/*
@author  : arti.fogla@ausnetservices.com.au
@created : 10 march  2020
@Description : Controller class for Accept Offer LWC 
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/
public with sharing class TVE_AcceptOfferCtrl {
     @AuraEnabled
    public static void updateTask(String tskId)
    {
        
        if(String.isNotEmpty(tskId)){
            Task tskRec=[select id,status,OfferStatus__c from Task where id =:tskId];
            tskRec.status='Completed';
            tskRec.OfferStatus__c='Accepted';
            if(tskRec!=null)
            update tskRec;
        }
        
    }

}