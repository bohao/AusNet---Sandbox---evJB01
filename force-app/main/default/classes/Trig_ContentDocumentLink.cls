/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 27 Jan 2020
@Description : Class for ContentDocumentLink Trigger
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-------------------------------------------------------------------------------------------------------
27/1/19          Brajesh Tiwary             Added method Qualify_createContentDocumentOnProject() on  After insert and delete
-------------------------------------------------------------------------------------------------------
*/
public with sharing class Trig_ContentDocumentLink implements UtilTrigHandle{
    public static Boolean TrigDisabled = false;
   
    
    public Boolean IsDisabled()
    {
        if (TrigSettings__c.getInstance().ContentDocumentLink_Trigger_Disabled__c)
            return true;
        else
            return TrigDisabled;
    }
    public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
    {
    }
    // if context is not implemented, condense into one-liners
    public void AfterInsert(Map<Id, SObject> newSObj){  
        Qualify_createContentDocumentOnProject(newSObj,null);
        Qualify_processTaskCreation(newSObj);
        Qualify_hasInvoiceAttached(newSObj,null);
    }
    public void AfterDelete(Map<Id, SObject> oldSObjs) {
        Qualify_createContentDocumentOnProject(null,oldSObjs);
        Qualify_hasInvoiceAttached(null,oldSObjs);
       
    }
    public void AfterUndelete(Map<Id, SObject> newSObjs) {}
    public void BeforeInsert(List<SObject> newSObjs) {
        makeFileVisibleToAllUser(newSObjs);
    }
    public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
    public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs){}
    // *********************************************************************
    // *** Trigger methods
    // 
    // 
    private static void makeFileVisibleToAllUser(List<Sobject> newSobj)
    {
         ContentDocumentLink newContentDoc;
        for( Sobject cdl:newSobj)
        {
            newContentDoc  = (ContentDocumentLink)cdl;
            if(newContentDoc.LinkedEntityId != null && 
                       'Artefact__c'.equalsIgnoreCase(newContentDoc.LinkedEntityId.getSObjectType().getDescribe().getName()))
            newContentDoc.Visibility='AllUsers';
        }
        
    }
    private static void Qualify_createContentDocumentOnProject(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        ContentDocumentLink newContentDoc;
        List<ContentDocumentLink> cdlToProcess = new List<ContentDocumentLink>();
        List<ContentDocumentLink> deletedcdlToProcess = new List<ContentDocumentLink>();
        set<Id> artefactId = new set<Id>();
        set<Id> contentDocumentIds = new set<Id>();
        set<Id> conTentDocIds = new set<Id>();
        List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();
        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for(Id i : newSObj.keySet()){
                    newContentDoc  = (ContentDocumentLink)newSObj.get(i);
                    
                    if(newContentDoc.LinkedEntityId != null && 
                       'Artefact__c'.equalsIgnoreCase(newContentDoc.LinkedEntityId.getSObjectType().getDescribe().getName())){
                           cdlToProcess.add(newContentDoc);
                           artefactId.add(newContentDoc.LinkedEntityId);
                           contentDocumentIds.add(newContentDoc.ContentDocumentId);
                       }
                       
                }
            }
            when AFTER_DELETE
            {
                for (Id j: oldSObj.keySet())
                {
                    ContentDocumentLink newDocItem = (ContentDocumentLink)oldSObj.get(j);
                    if (newDocItem.LinkedEntityId != null && 'Artefact__c'.equalsIgnoreCase(newDocItem.LinkedEntityId.getSObjectType().getDescribe().getName()))
                    {   deletedcdlToProcess.add(newDocItem);
                        artefactId.add(newDocItem.LinkedEntityId);
                        contentDocumentIds.add(newDocItem.ContentDocumentId);
                    }
                }
            }
        }
        if(!artefactId.isEmpty()){
            TVE_ContentDocumentLink_Utility.processDocCreationAndDeletion(artefactId,cdlToProcess,deletedcdlToProcess,contentDocumentIds);
        }
    }
    private static void Qualify_processTaskCreation(Map<Id, SObject> newSObj)
    {
        ContentDocumentLink newContentDoc;
        set<Id> artefactId = new set<Id>();
        switch on Trigger.operationType {
            when AFTER_INSERT {
                for(Id i : newSObj.keySet()){
                    newContentDoc  = (ContentDocumentLink)newSObj.get(i);
                    if(newContentDoc.LinkedEntityId != null && 
                       'Artefact__c'.equalsIgnoreCase(newContentDoc.LinkedEntityId.getSObjectType().getDescribe().getName()))
                    {
                        artefactId.add(newContentDoc.LinkedEntityId);
                        
                    }
                }
            }
        }
        if(!artefactId.isEmpty()){
            
            TVE_ContentDocumentLink_Utility.processTaskCreation(artefactId);
        }
    }
    
    private static void Qualify_hasInvoiceAttached(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        ContentDocumentLink newContentDoc;
        set<Id> artefactIdOnInsert = new set<Id>();
        set<Id> artefactIdOnDelete = new set<Id>();
        set<Id> contentDocumentIds = new set<Id>();
        switch on Trigger.operationType {
            when AFTER_INSERT {
                for(Id i : newSObj.keySet()){
                    newContentDoc  = (ContentDocumentLink)newSObj.get(i);
                    if(newContentDoc.LinkedEntityId != null && 
                       'Artefact__c'.equalsIgnoreCase(newContentDoc.LinkedEntityId.getSObjectType().getDescribe().getName()))
                    {
                        artefactIdOnInsert.add(newContentDoc.LinkedEntityId);
                    }
                    
                }
            }
            when AFTER_DELETE{
                
                for (Id j: oldSObj.keySet())
                {
                    ContentDocumentLink newDocItem = (ContentDocumentLink)oldSObj.get(j);
                    if (newDocItem.LinkedEntityId != null && 'Artefact__c'.equalsIgnoreCase(newDocItem.LinkedEntityId.getSObjectType().getDescribe().getName()))
                    {   
                        artefactIdOnDelete.add(newDocItem.LinkedEntityId);
                        contentDocumentIds.add(newDocItem.ContentDocumentId);
                    }
                }
            }
        }
        
        if(!artefactIdOnInsert.isEmpty()){
            
            TVE_ContentDocumentLink_Utility.enableHasFile(artefactIdOnInsert);
        }
        if(!artefactIdOnDelete.isEmpty()){
            
            TVE_ContentDocumentLink_Utility.disableHasFile(artefactIdOnDelete,contentDocumentIds);
        }
        
    }
    
}