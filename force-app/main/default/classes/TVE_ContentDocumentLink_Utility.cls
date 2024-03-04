/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 27 Jan 2020
@Description : Class for ContentDocumentLink Utility
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
27/1/2020                  Brajesh Tiwary                              Added method processDocCreationAndDeletion
-----------------------------------------------------------------------------------------
*/
public with sharing class TVE_ContentDocumentLink_Utility {
     public static ID invoiceRecordType = Schema.SObjectType.Artefact__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
    
    public static void processDocCreationAndDeletion(set<id> artefactId, List<ContentDocumentLink> cdlToProcess,
                                                     List<ContentDocumentLink> deletedcdlToProcess,set<Id> contentDocumentIds){
        Map<Id, Artefact__c> artefactMap = new Map<Id, Artefact__c>();
        Set<Id> projectIds = new Set<Id>();
        List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();
        
        for(Artefact__c art : [Select id, Project__c from Artefact__c where id IN : artefactId]){
            artefactMap.put(art.Id, art) ;      
            projectIds.add(art.Project__c);
        }
        if(!artefactId.isEmpty()){
            for(ContentDocumentLink cdl : cdlToProcess){
                ContentDocumentLink newCDL = cdl.clone();
                newCDL.LinkedEntityId = artefactMap.get(cdl.LinkedEntityId).Project__c;
                cdlToInsert.add(newCDL);
            }
            system.debug('cdlToInsert'+cdlToInsert);
            database.insert(cdlToInsert);
        }
        if(!contentDocumentIds.isEmpty()){
            TVE_ContentDocument_Utility.changeDocumentOwner(contentDocumentIds);
        }
        if(!contentDocumentIds.isEmpty() && ! projectIds.isEmpty()){
            Map<String, ContentDocumentLink> projDocLinks = new Map<String, ContentDocumentLink>();
            for(ContentDocumentLink cdl : [Select id , LinkedEntityId, ContentDocumentId from ContentDocumentLink 
                                      Where ContentDocumentId in : contentDocumentIds and LinkedEntityId in : projectIds]){
                string key = string.valueOf(cdl.LinkedEntityId) + string.valueOf(cdl.ContentDocumentId);
                projDocLinks.put(key, cdl);                      
            }
            
            Map<Id,ContentDocumentLink> cdlToRemove = new  Map<Id,ContentDocumentLink>();
            for(ContentDocumentLink cdl: deletedcdlToProcess){
                string key = string.valueOf(artefactMap.get(cdl.LinkedEntityId).Project__c) +
                    			string.valueOf(cdl.ContentDocumentId);
                if(projDocLinks.containsKey(key)){
                    cdlToRemove.put(projDocLinks.get(key).Id, projDocLinks.get(key));
                }
            }
            system.debug('cdlToRemove'+cdlToRemove);
            if(!cdlToRemove.isEmpty()){
                Database.delete(cdlToRemove.values());
            }
         }
        
    }
    
    public static void processTaskCreation(set<id> artefactId)
    {
        set<id> validArtefactIds=new set<id>();
        for(Artefact__c art:[select id,Status__c,InvoicePaidDate__c ,ElectronicPaymentReferenceNumber__c from artefact__c where id in:artefactId and RecordTypeId=:invoiceRecordType])
        {
            if(art.Status__c=='Pending Payment' && art.InvoicePaidDate__c==null && art.ElectronicPaymentReferenceNumber__c==null )
            {
                  validArtefactIds.add(art.id);                
            }
        }
        system.debug('validArtefactIds:'+validArtefactIds);
         if(!validArtefactIds.isEmpty() && !test.isRunningTest()){
             for(id i:validArtefactIds){
                 Flow.Interview flow = new Flow.Interview.TVE11_Automatic_Make_a_Payment_Task_Creation(new map<String,Object>{'recordID' => i});     
                 flow.start();
             }
         }
    }
    public static void enableHasFile(set<id> artefactId)
    {
        List<Artefact__c> artefactToUpdate=new List<Artefact__c>();
        for(Artefact__c art:[select id,HasFiles__c from artefact__c where id in:artefactId and RecordTypeId=:invoiceRecordType])
        {
            art.HasFiles__c=true;
            artefactToUpdate.add(art);
        }
        system.debug('artefactToUpdate:'+artefactToUpdate);
        if(!artefactToUpdate.isEmpty())
        {
            update artefactToUpdate;
        }
    }
    
    public static void disableHasFile(set<id> artefactId,set<Id> contentDocumentIds)
    {
        List<Artefact__c> artefactToUpdate=new List<Artefact__c>();
        Set <id> hasRelatedFiles=new set<id>();
        for(ContentDocumentLink cdl:[Select Id,ContentDocumentid,LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId in:artefactId and contentDocumentId not in:contentDocumentIds])
        {
            hasRelatedFiles.add(cdl.LinkedEntityId);
            
        }
        system.debug('hasRelatedFiles:'+hasRelatedFiles);
        for(Artefact__c art :[Select id,HasFiles__c from artefact__c where id in:artefactId and id not in :hasRelatedFiles and RecordTypeId=:invoiceRecordType])
        {
            art.HasFiles__c=false;
            artefactToUpdate.add(art);
        }
         system.debug('artefactToUpdate:'+artefactToUpdate);
        if(!artefactToUpdate.isEmpty())
        {
            update artefactToUpdate;
        }
            
    }
}