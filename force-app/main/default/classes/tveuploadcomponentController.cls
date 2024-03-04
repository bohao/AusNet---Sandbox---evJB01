/*
@author  : lakshay.sharma@ausnetservices.com.au
@created : 3rd Jan 2020
@Description : Controller class for tveuploadcomponent
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
public with sharing class tveuploadcomponentController {
    
    @AuraEnabled
    public static id getArtefact (id projectId)
    {
        system.debug('in artefact method');
        Artefact__c artRec=new Artefact__c();
        artRec.Classification__c='Contract';
        artRec.Project__c=projectId;
        artRec.Name='Dummy';
        insert artRec;
        system.debug(artRec);
        return artRec.id;
            
    }
    @AuraEnabled
    public static boolean deleteArtefact(id projectId,string docId)
    {
        List<Artefact__c> dummyArtList = [SELECT Id, Name FROM Artefact__c WHERE project__c =: projectId AND Name = 'Dummy'];
        if(!dummyArtList.isEmpty())
            delete dummyArtList;
        if(String.isNotEmpty(docId)) {
            List<ContentDocument> cd = [SELECT Id FROM ContentDocument WHERE Id =: docId];
            if(!cd.isEmpty())
                delete cd;
        }
        
        return true;
    }
    
    @AuraEnabled
    public static Artefact__c saveFile(Id idParent, String strFileName,string artID,String classification,Id accountId) {
        // Decoding base64Data
        system.debug('idParent' +idParent);
        system.debug('accountId' +accountId);
        system.debug('classification' +classification);
        Artefact__c art = [select id,Classification__c,Account__c,Name,Project__c from Artefact__c where id=:artId];
        art.Classification__c= classification;
        art.Account__c=accountId;
        art.Project__c=idParent;
        art.Name=strFileName;
        //Record type has been handled using classification field in before insert/update artefact trigger 
        // art.RecordTypeId = Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get('Other').getRecordTypeId();
        update art;
        system.debug('updated Artefact:'+art);
        return art;
 }
    @AuraEnabled 
    public static Id fetchProject(string recordId){
        Id ProjectId;
        Task t = [select id,WhatId from Task where id=:recordId];
        ProjectId=t.Whatid;
        return ProjectId;
    }
    
}