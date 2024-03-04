/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 05 Dec 2019
  @Description : Controller class for LWC tveProjectStatusBar
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/

public with sharing class TVE_ProgressBar_Controller {
    
    @AuraEnabled(cacheable=true)
    public static String getProjProgressJSON(String projId){
        String progressJSON = JSON.serialize(TVE_ProjectProgressService_v1_0.getProgress(projId));
        System.debug('progressJSON--->'+progressJSON);        
        return progressJSON;
    }

    @AuraEnabled(cacheable=true)
    public static String getProgressBarMessage(){
        String message; 
        List<TVEMessages__mdt> lstMsgs = new List<TVEMessages__mdt>([SELECT Id, Message__c
                                                                    FROM TVEMessages__mdt
                                                                    WHERE DeveloperName =: 'ProgressBarMessage']);
        if(!lstMsgs.isEmpty() && lstMsgs[0].Message__c != null)
        {
          message = lstMsgs[0].Message__c;
        }
        else
        {
          throw new TVE_ConfigurationException('No valid records found for custom metadata type named TVEMessages__mdt!!');
        }
        System.debug('message--->'+message);        
        return message;
    }
}