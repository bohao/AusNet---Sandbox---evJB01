/*
@author  : Lakshay Sharma <Lakshay.Sharma@ausnetservices.com.au>
@created : 29th Jan 2020
@Description : class for LWC component tve_getasplist
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
30th Jan 2020    pavan.dave@ausnetservices.com.au    Code review & finishing touch
-----------------------------------------------------------------------------------------
*/

public without sharing class tve_ASPController {
    @AuraEnabled
    public static Project__c updateManualASP(Id prjId, String aspManualText, String taskId) {
        System.debug('tve_ASPController------>prjId)---->'+prjId);
        System.debug('tve_ASPController------>aspManualText-->'+aspManualText);
        Project__c prj = [SELECT Id, ASP__c, ASPnotDisplayedonList__c 
                          FROM Project__c 
                          WHERE Id=: prjId];
        prj.ASPnotDisplayedonList__c = aspManualText;
        update prj;
        markTaskComplete(taskId);
        return prj;
    }

    @AuraEnabled
    public static Account findAccount(String extId){
        Account acc=[SELECT Id, ASPAccreditaionId__c 
                     FROM Account 
                     WHERE ASPAccreditaionId__c =: extId];
        return acc;
    }

    @AuraEnabled
    public static Project__c updateFromASPList(Id prjId, String extId, String taskId){
        Project__c proj= [SELECT Id, ASP__c, ASPnotDisplayedonList__c 
                           FROM Project__c 
                           WHERE Id=: prjId];
        proj.ASP__c = findAccount(extId).Id;
        update proj;
        markTaskComplete(taskId);        
        return proj;
        
    }

    //TV-2248 If taskId has a value then complete the task & send notification to project owner using flow
    public static void markTaskComplete(String taskId){        
        if(taskId != null && taskId != '' && taskId != 'undefined')
        {
            Task markComp = [SELECT Id, Status FROM Task WHERE Id =: taskId LIMIT 1];
            markComp.Status = 'Completed';
            update markComp;
        }
    }
}