/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 12th Dec 2019
@Description : Controller class for Aura TVE_FilePreview
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
public with sharing class TVE_ArtefactController {
    public static String Artefact_OFFER_RT = 'Offer';
    //public static String Artefact_Design_RT_Id = 'Design';
    public static String Artefact_Other_RT_Id = 'Other';
    public static String Artefact_Contract_RT_Id = 'Contract';
    
    @AuraEnabled(cacheable=true)
    public static list<wrapContentVersionDoc> getArtefactList(string recordId) {
        Id Artefact_Offer_RT_Id = Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get(Artefact_OFFER_RT).getRecordTypeId();
       // Id Artefact_Design_RT_Id = Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get(Artefact_Design_RT_Id).getRecordTypeId();
        Id Artefact_Other_RT_Id = Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get(Artefact_Other_RT_Id).getRecordTypeId();
        Id Artefact_Contract_RT_Id = Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get(Artefact_Contract_RT_Id).getRecordTypeId();
       

        wrapContentVersionDoc offerWrpItem = new wrapContentVersionDoc();
        list<wrapContentVersionDoc> listWrapper = new list<wrapContentVersionDoc>();
        set<id> conDocId = new set<id>();
        Set<id> artfctIds = new Set<id>();
        set<id> validRecordTypeIds = new set<id>{Artefact_Offer_RT_Id,Artefact_Other_RT_Id,Artefact_Contract_RT_Id };
        
        List<Artefact__c> lstArtfct =  new List<Artefact__c>([SELECT Id, Name , Classification__c,CreatedBy.Name,
                                                              Project__r.Name
                                                              FROM Artefact__c 
                                                              WHERE Project__c = :recordId
                                                              AND RecordTypeId IN :validRecordTypeIds
                                                             ]);
        if(!lstArtfct.isEmpty()) 
        {  
            for(Artefact__c item: lstArtfct){
                artfctIds.add(item.Id);
            }
            List<ContentDocumentLink> lstConDocLink = [SELECT ContentDocumentId, LinkedEntityId 
                                                       FROM ContentDocumentLink 
                                                       WHERE LinkedEntityId IN :artfctIds];
            for(Artefact__c artfcItem: lstArtfct)                 
            {
                for(ContentDocumentLink conDocLinkItem : lstConDocLink) 
                {
                    conDocId.add(conDocLinkItem.ContentDocumentId);
                    if(artfcItem.Id == conDocLinkItem.LinkedEntityId)
                    {
                        offerWrpItem = new wrapContentVersionDoc();
                        offerWrpItem.Classification = artfcItem.Classification__c;
                        offerWrpItem.Createdby= artfcItem.CreatedBy.Name;
                        offerWrpItem.contentDocObj = conDocLinkItem.ContentDocumentId;
                        listWrapper.add(offerWrpItem);
                    }                    
                }  
            }
        }
        map<id,ContentVersion> mapOfDoc = new map<id,ContentVersion>();
        for(ContentVersion cv: [SELECT VersionData ,Title,ContentDocumentId,CreatedDate
                                FROM ContentVersion 
                                WHERE ContentDocumentId IN:conDocId 
                                AND IsLatest = true
                               ]){
                                   mapOfDoc.put(cv.ContentDocumentId,cv);
                               }
        for(wrapContentVersionDoc wrap : listWrapper){
            if(mapOfDoc.containsKey(wrap.contentDocObj)){
                String splitedTitle = mapOfDoc.get(wrap.contentDocObj).Title;
                if (splitedTitle.contains('.')) { 
                wrap.Title = splitedTitle.split('\\.')[0];
                }
                else {
                    wrap.Title = mapOfDoc.get(wrap.contentDocObj).Title;
                }
                DateTime myDateTime;
                myDateTime = mapOfDoc.get(wrap.contentDocObj).CreatedDate;
                Date myDate = date.newinstance(myDateTime.year(), myDateTime.month(), myDateTime.day());
                wrap.CreatedDate = myDate;
            }
        }
     System.debug('listWrapper'+listWrapper);
        return listWrapper;
    }
    
    public class wrapContentVersionDoc{
        @AuraEnabled public string Name{get; set;}
        @AuraEnabled public string contentDocObj {get; set;}
        @auraEnabled public string Classification {get; set;}
        @auraEnabled public string projectName {get; set;}
        @auraEnabled public string Title {get; set;}
        @auraEnabled public Date CreatedDate {get; set;}
        @auraEnabled public String Createdby {get; set;}
    }
}