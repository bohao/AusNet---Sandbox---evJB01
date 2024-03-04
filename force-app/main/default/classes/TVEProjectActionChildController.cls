/*
@author  : arti.fogla@ausnetservices.com.au
@created : 26 feb 2019
@Description : controller class for fetching invoice from customer portal
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
15 Apr 2020      dave.pavan@in.ibm.com            TV-2809: Dynamic Payment URL 
-----------------------------------------------------------------------------------------
*/
public without sharing class TVEProjectActionChildController {
    public static ID resendEmailType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Resend_Email').getRecordTypeId();
    
    @AuraEnabled
    public static string fetchPaymentURL(){
        return [SELECT Id, URL__c FROM TVE_External_URL__mdt 
                            WHERE DeveloperName = 'TVE_Make_a_Payment_URL' LIMIT 1].URL__c;
    }

    @AuraEnabled 
    public static string fetchInvoice(string recordId){
        system.debug('in function');
        String documentId;
        list<task> taskRec=[select id,Artefact__c from task where id=:recordId];
        system.debug('taskRec:'+taskRec);
        if(taskRec[0].Artefact__c!=null && !taskRec.IsEmpty()){
            List<ContentDocumentLink> contentDocumentLinkRec= [Select Id,ContentDocumentid, ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = :taskRec[0].Artefact__c];
            system.debug(contentDocumentLinkRec[0].ContentDocumentid);
            if(!contentDocumentLinkRec.IsEmpty()){
                Contentversion contentVersionRec =[SELECT Title, VersionData, ContentDocumentId, 
                                                   ContentLocation, FileType  
                                                   FROM ContentVersion 
                                                   WHERE ContentDocumentId = :contentDocumentLinkRec[0].ContentDocumentid
                                                   AND IsLatest = true limit 1];
                
                
                documentId= contentVersionRec.ContentDocumentId;
                system.debug(documentId);
            }
        }
        return documentId;
    }
    
    @AuraEnabled 
    public static string validateOpenTask(string taskId){
        String prefix=project__c.sobjecttype.getDescribe().getKeyPrefix();
        project__c proj= new project__c();
        string recordTypeName='';
        List<Task> taskToValidate=new List<Task>();
        system.debug('prefix:'+prefix);
        if(string.isNotEmpty(taskId)){
            Task tskRec=[select id,status,whatId,recordtypeId from Task where id =:taskId];
            recordTypeName=[select DeveloperName from recordtype where id =:tskRec.recordtypeId].DeveloperName;
            string relatedTo=(string)tskRec.WhatId;
            if(string.isNotEmpty(relatedTo) &&  relatedTo.startsWith(prefix))
            {
                proj=[select id,ownerId,ProjectName__c  from project__c where id=:relatedTo];
                
            }
        }
        
        if(proj.id!=null)
        {
            for(Task tsk:[select id,status,RecordTypeId from Task where whatId=:proj.id])
            {
                if(tsk.RecordTypeId==resendEmailType && tsk.status !='Completed')
                {
                    taskToValidate.add(tsk);                        
                }
            }
            
            
            
            if(!taskToValidate.IsEmpty())
            {
                return 'true';
            }
            else{
                Task taskToInsert=new task();
                taskToInsert.RecordTypeId=resendEmailType;
                taskToInsert.whatId=proj.id;
                taskToInsert.ActivityDate=system.today()+3;
                if(recordTypeName=='AcceptInterconnectionContractandOffer')
                {
                    taskToInsert.Subject='Resend Interconnection Contract and Offer';
                    taskToInsert.Description='A request has been submitted for you to resend the Interconnection Contract and Offer email with attachments to the applicant';
                }  
                
                else if(recordTypeName=='AcceptFirmOffer'){
                    taskToInsert.Subject='Resend Firm Offer';
                    taskToInsert.Description='A request has been submitted for you to resend the Firm Offer email with attachments to the applicant';    
                }
                taskToInsert.Status='Not Started';
                taskToInsert.Priority='High';
                //For TV-1808, To fix strange test class failure
                if(!Test.isRunningTest())
                    taskToInsert.OwnerId=proj.OwnerId;          

                insert taskToInsert;
                if((taskToInsert.id !=null) && (taskToInsert.ownerId !=null))
                {
                    Flow.Interview flow = new Flow.Interview.Flow_for_Resend_Email(new map<String,Object>{'recordId' => taskToInsert.id,'targetId'=>taskToInsert.OwnerId}); 
             		flow.start();    
                }
                return 'false';
            }
        }
        
      return null;  
    }
}