/*
@author  : arti.fogla@ausnetservices.com.au
@created : 12 Mar  2020
@Description : Controller class for LWC tveRejectInvoice, tveRejectInvoiceTask
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
10-May-2020           Prateek Gupta                  Updated flow invocation parameters
-----------------------------------------------------------------------------------------
*/
public without sharing class TVE_CreateTaskUtility {
    public static ID otherRecordType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Other').getRecordTypeId();
    
    @AuraEnabled
    public static task  createNewTask(string projectId, string Subject,Date Duedate,String Description,String AssignedTo){
        CustomNotificationType notiID=[SELECT Id, DeveloperName FROM CustomNotificationType where DeveloperName='Task_Assignment'];
        Task newtask=new Task();
        newtask.RecordTypeId=otherRecordType;
        newtask.ActivityDate=Duedate;
        newtask.Subject=Subject;
        newtask.Description=Description;
        newtask.WhatId=projectId;
        newtask.ownerId=AssignedTo;
        insert newtask;
        system.debug(newtask);
        
        
         if(newtask.id !=null)
        {
            //Commented below line and updated the flow invocation parameters for defect TV-3219
            //Flow.Interview flow = new Flow.Interview.Notification_on_Task_Creation(new map<String,Object>{'recordID' => newtask.id,'customNotiID'=>notiID.id,'completeTaskId'=>null});     
            Flow.Interview flow = new Flow.Interview.Notification_on_Task_Creation(new map<String,Object>{'customNotiID'=>notiID.id, 'recordID'=>newtask.id, 'subject'=>Subject, 'assignedto'=>AssignedTo,'completeTaskId'=>null});
            flow.start();
        }
        
      return newtask;  
        
    }
}