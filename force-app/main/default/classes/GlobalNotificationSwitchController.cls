// *****************************************************************
// ** GlobalNotificationSwitchController
// ** Description : This class is used to retrieve and update Incident_Setup__c custom settings field values
// Created by: Rahul Singh
// Owner: IBM
// *****************************************************************
public with sharing class GlobalNotificationSwitchController {
    
    //Method to retrieve Incident_Setup__c field values
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> fetchIncidentSetup(){
        Map<String, Object> resultMap = new Map<String, Object>();
        
        Incident_Setup__c incidentSetup = Incident_Setup__c.getOrgDefaults();
        resultMap.put('automationStatus',!incidentSetup.Incident_Notifs_Disabled__c);
        resultMap.put('setByTime',incidentSetup.Incident_Notifs_Last_Set_Time__c);
        
        if(incidentSetup.Incident_Notifs_Last_Set_By_Id__c!=null)
        resultMap.put('setByName',[select Name from User where Id=: incidentSetup.Incident_Notifs_Last_Set_By_Id__c].Name);
        resultMap.put('setById',incidentSetup.Incident_Notifs_Last_Set_By_Id__c);
        return resultMap;
    }
    //Method to upsert Incident_Setup__c field values
    @AuraEnabled
    public static Map<String, Object> setIncidentSetup(Boolean setAutomationStatus){
    	Map<String, Object> resultMap = new Map<String, Object>();
        
        Incident_Setup__c incidentSetup = Incident_Setup__c.getOrgDefaults();
        
        incidentSetup.Incident_Notifs_Disabled__c=!setAutomationStatus;
		incidentSetup.Incident_Notifs_Last_Set_By_Id__c=UserInfo.getUserId();
		incidentSetup.Incident_Notifs_Last_Set_Time__c=System.now();

		upsert incidentSetup;
        
        resultMap.put('isSuccess',true);
        return resultMap;
    }
}