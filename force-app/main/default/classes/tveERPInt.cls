/*
@author  : Lakshay Sharma <Lakshay.Sharma@ausnetservices.com.au>
@created : 11th Feb 2020
@Description : class for LWC component tveERPIntegrationAppPage
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/
public with sharing class tveERPInt {
    @AuraEnabled
    public static Boolean tveERPIntchecklist() {
        List<Integration_Task__c> intlist = [SELECT Id,Status__c  FROM Integration_Task__c WHERE Status__c='In Progress'];
        Boolean listempty = false;
        if(intlist.isEmpty()) {
            listempty= true;
        }else{
            listempty= false;   
        }
         return listempty;
}
    @AuraEnabled
    public static void callqueueableapex(){
        TVE_SAPInteg_Initiation.startInitiation();
       
    }

}