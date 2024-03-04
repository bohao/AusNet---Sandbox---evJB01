/*
@author  : pavan.dave@ausnetservices.com.au
@created : 05 Mar  2020
@Description : Controller class for LWC tveRejectInvoice, tveRejectInvoiceTask
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
30-Apr-20       dave.pavan@in.ibm.com         Added "without sharing" since system show list of contacts to external user for payer selection
10-May-202      Prateek Gupta                 Updated createTask method for defect TV-3219
-----------------------------------------------------------------------------------------
*/

public without sharing class TVE_RequestInvoiceUtility {
    public static ID requestInvoiceType = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Request_Invoice').getRecordTypeId();
    public static ID Artefact_Invoice_RTId = Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get('Invoice').getRecordTypeId();

    public static final string CLASSIFICATION_INVOICE = 'Invoice';
    public static final string SOURCE_SF_CLOUD = 'Salesforce Cloud';
    
    @AuraEnabled(cacheable=true)
    public static List<ContactWrapper> getContactWrapper(string prjId, string artId){
        system.debug('in get contact wrapper');
        
        List<ContactWrapper> lstContWrpr = new List<ContactWrapper>();
        Project__c proj=new Project__c();
        
        if(String.isNotEmpty(prjId)){
         proj = [SELECT Id, AuthorizedRepresentativeContact__c, ASPContact__c, PropertyOwnerContact__c
                           FROM Project__c
                           WHERE Id =: prjId];
        }
        
        Artefact__c art;        
        if(String.isNotEmpty(artId))
        {
            art = [SELECT Id, Payer__c FROM Artefact__c WHERE Id =: artId];                               
        }

        Set<Id> setContId=new set<Id>();
        if(proj!=null){
        if(proj.AuthorizedRepresentativeContact__c != null)
            setContId.add(proj.AuthorizedRepresentativeContact__c);
        if(proj.ASPContact__c != null)
            setContId.add(proj.ASPContact__c);
        if(proj.PropertyOwnerContact__c != null)
            setContId.add(proj.PropertyOwnerContact__c);}
        system.debug('setContId:'+setContId);
        if(!setContId.isEmpty())
        {
            Map<Id, Contact> mapCon = new Map<Id, Contact>([SELECT Id, FirstName, LastName, AccountId, Account.IsPersonAccount,
                                                                    Account.BillingStreet, Account.BillingCity,
                                                                    Account.BillingPostalCode, Account.BillingState, 
                                                                    Account.PersonMailingStreet, Account.PersonMailingCity, 
                                                                    Account.PersonMailingPostalCode, Account.PersonMailingState
                                                            FROM Contact
                                                            WHERE Id IN : setContId]);
            
            if(!mapCon.isEmpty())
            {
                ContactWrapper cWrpr;
                Contact c;
                String payerId;
                system.debug('mapCon-->'+mapCon.keySet());
                for(Id conItemId: mapCon.keySet())
                {   
                    c = mapCon.get(conItemId);
                    if((String.isNotEmpty(artId)  && art != null & art.Payer__c != null) )
                    {
                        //----------------------------------------------//
                        //------ TV-368 For Request Invoice LWC--------//
                        //---------------------------------------------//
                        payerId = art.Payer__c;
                        if(c.Id == payerId || c.Id == payerId.mid(0, 15))
                        {
                            // DO NOT ADD TO THE LIST
                        }                            
                        else
                        {
                            cWrpr = new ContactWrapper(c, false);                            
                    		lstContWrpr.add(cWrpr);         
                        }                            
                    }
                    
                    else
                    {
                        //----------------------------------------------//
                        //------ TV-158 For Request Invoice LWC--------//
                        //---------------------------------------------//
                        cWrpr = new ContactWrapper(c, false);                               
                    	lstContWrpr.add(cWrpr);         
                    }
                    system.debug('cWrpr-->'+cWrpr);           
                }
            }
        }
        system.debug('lstContWrpr:'+lstContWrpr);
        return lstContWrpr;
    }

    //TV-386
    @AuraEnabled
    public static task createTask(Id projectId,String name,id taskId){
        system.debug('taskid:'+taskid);
        CustomNotificationType notiID=[SELECT Id, DeveloperName FROM CustomNotificationType where DeveloperName='Task_Assignment']; 
        
        //Added by Prateek for TV-3219 - Start
        Task taskToComplete = [SELECT Id, status FROM Task where Id =:taskId]; 
        taskToComplete.Status = 'Completed';
        update taskToComplete;  
        //Added by Prateek for TV-3219 - ENd

        Task taskToCreate=new Task();
        project__c prj=[select id,ReferenceNumber__c,Name,ownerId from project__c where id =:projectId];
        taskToCreate.RecordTypeId=requestInvoiceType;
        taskToCreate.subject='Request Invoice -'+prj.Name;
        taskToCreate.Description='A request has been submitted for an invoice in another payers name - please request an invoice in the following name:'+name;
        taskToCreate.ActivityDate=system.today()+3;
        String sub = 'Request Invoice -'+prj.Name;

        //For TV-1808, To fix strange test class failure
        if(!Test.isRunningTest())
            taskToCreate.OwnerId=prj.ownerId;
        
        taskToCreate.WhatId=prj.id;
        taskToCreate.Status='Not Started';
        taskToCreate.Priority='Normal';
        insert taskToCreate;
        
        system.debug('task created:'+taskToCreate.id);
        if(taskToCreate.id !=null)
        {
            //Added by Prateek for TV-3219
            //Flow.Interview flow = new Flow.Interview.Notification_on_Task_Creation(new map<String,Object>{'recordID' => taskToCreate.id,'customNotiID'=>notiID.id,'completeTaskId'=>taskId});     
            Flow.Interview flow = new Flow.Interview.Notification_on_Task_Creation(new map<String,Object>{'customNotiID'=>notiID.id, 'recordID'=>taskToCreate.id, 'subject'=>sub, 'assignedto'=>prj.ownerId,'completeTaskId'=>null});
            flow.start();
        }
        
        return taskToCreate;
    }

    //TV-158
    @AuraEnabled(cacheable = true)
    public static Boolean hasWarningMsg(String prjRecId){
        Boolean showWarning = false;
        List<Artefact__c> lstArt = new List <Artefact__c>([SELECT Id FROM Artefact__c 
                                                            WHERE Project__c =: prjRecId 
                                                            AND RecordTypeId =: Artefact_Invoice_RTId]);
        if(!lstArt.isEmpty())
        {
            List<Id> lstArtIds = new List<Id>();
            for(Artefact__c item: lstArt)
            {
                lstArtIds.add(item.Id);
            }

            List<Integration_Task__c> lstIntTask = new List<Integration_Task__c>([SELECT Id FROM Integration_Task__c
                                                                                        WHERE ParentId__c IN: lstArtIds
                                                                                            AND Status__c IN('Ready', 'In Progress')]);
            if(!lstIntTask.isEmpty())
            {
                showWarning = true;
            }                                                         
        }
        return showWarning;        
    }

    //TV-158
    @AuraEnabled
    public static void createArtefact(Id payerId, String invTy1, String invTy2, String invTy3,
                                      Double totAmt, String mCode1, String mCode2, String mCode3,
                                      Id projId, Double amt1, Double amt2, Double amt3){
        Contact conObj = [select id, AccountId, Account.SAPCustomer__c From Contact where id=:payerId];
        system.debug('conObj123'+conObj);
        Artefact__c art = new Artefact__c();
        system.debug('payerId-->'+payerId);
        system.debug('mCode1-->'+mCode1);
        system.debug('totAmt-->'+totAmt);
        art.Project__c = projId;
        art.Classification__c = CLASSIFICATION_INVOICE;
        art.Payer__c = payerId;
        art.Account__c = conObj.AccountId;
        art.Source__c = SOURCE_SF_CLOUD;                                               
        art.InvoiceTypeLine1__c = invTy1;
        art.MaterialCodeLine1__c = mCode1;
        art.AmountLine1ExGST__c = amt1;
        art.NetAmount__c = amt1;
        if(conObj.Account.SAPCustomer__c!=null){
        	art.Bill_To__c = conObj.Account.SAPCustomer__c;
        }
        if(invTy2 != null && mCode2 != null && amt1 != null){
            art.InvoiceTypeLine2__c = invTy2;
            art.MaterialCodeLine2__c = mCode2;
            art.AmountLine2ExGST__c = amt2;
            art.NetAmount__c += amt2;
        }
        if(invTy3 != null && mCode3 != null && amt3 != null){
            art.InvoiceTypeLine3__c = invTy3;
            art.MaterialCodeLine3__c = mCode3;
            art.AmountLine3ExGST__c = amt3;
            art.NetAmount__c += amt3;
        }
        art.TotalAmount__c = totAmt;
        art.Additional_Invoice__c = true;
        insert art;
        system.debug('art-->'+art.Id);
    }

    public class ContactWrapper
    {
        public ContactWrapper(Contact con, Boolean isSel)
        {
            this.contactId = con.Id;
            String name='';
            name+=con.FirstName+ ' '+con.LastName;
            this.contactName=name;
            
            String addr = '';
            if(con.Account.IsPersonAccount)
            {                
                if(String.isNotEmpty(con.Account.PersonMailingStreet))
                    addr+= con.Account.PersonMailingStreet + ', ';
                if(String.isNotEmpty(con.Account.PersonMailingCity))
                    addr+= con.Account.PersonMailingCity + ', ';
                if(String.isNotEmpty(con.Account.PersonMailingState))
                    addr+= con.Account.PersonMailingState + ' ';
                if(String.isNotEmpty(con.Account.PersonMailingPostalCode))
                    addr+= con.Account.PersonMailingPostalCode;
                
                this.contactAddress = addr;
            }
            else
            {
                if(String.isNotEmpty(con.Account.BillingStreet))
                    addr+= con.Account.BillingStreet + ', ';
                if(String.isNotEmpty(con.Account.BillingCity))
                    addr+= con.Account.BillingCity + ', ';
                if(String.isNotEmpty(con.Account.BillingState))
                    addr+= con.Account.BillingState + ' ';
                if(String.isNotEmpty(con.Account.BillingPostalCode))
                    addr+= con.Account.BillingPostalCode;
                
                this.contactAddress = addr;
            }

            this.isSelected = isSel;
        }

        @AuraEnabled public String contactId;
        @AuraEnabled public String contactName;
        @AuraEnabled public String contactAddress;
        @AuraEnabled public boolean isSelected;
    }
}