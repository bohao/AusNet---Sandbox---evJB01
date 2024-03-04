/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 20th Dec 2019
  @Description : Controller class for Aura TVE_InvoicePreview
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  15 Apr 2020      dave.pavan@in.ibm.com            TV-2809: Dynamic Payment URL 
  -----------------------------------------------------------------------------------------
*/
public with sharing class TVE_InvoicePreviewController {
    public static String Artefact_Invoice_RT = 'Invoice';

    @AuraEnabled(cacheable=true)
    public static InvoiceWrapper getInvoices(string recordId) {
        id loggedInUser= UserInfo.getUserId();
        User u =[select isPortalenabled from user where id=:loggedInUser limit 1];
        System.debug('u.isPortalEnabled'+u.isPortalEnabled);
        InvoiceInfo invWrpItem = new InvoiceInfo();
        list<InvoiceInfo> listWrapper = new list<InvoiceInfo>();
        InvoiceWrapper invwrapper= new InvoiceWrapper();

        Id Artefact_Invoice_RT_Id = Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get(Artefact_Invoice_RT).getRecordTypeId();

        List<Artefact__c> lstArtfct =  new List<Artefact__c>([SELECT Id, Name , Classification__c , DueDate__c, 
                                                                    InvoiceDate__c, TotalAmount__c,
                                                                    InvoiceNumber__c, Status__c
                                                                FROM Artefact__c 
                                                                WHERE Project__c = :recordId
                                                                AND RecordTypeId = :Artefact_Invoice_RT_Id
                                                                ]);
        System.debug('lstArtfct in class'+ lstArtfct+'record id'+recordId);
        
        if(!lstArtfct.isEmpty())
        {
            Set<id> artfctIds = new Set<id>();
            for(Artefact__c item: lstArtfct){
                artfctIds.add(item.Id);
            }

            List<ContentDocumentLink> lstConDocLink = [SELECT ContentDocumentId, LinkedEntityId 
                                                    FROM ContentDocumentLink 
                                                    WHERE LinkedEntityId IN: artfctIds];
                        
            for(Artefact__c artfcItem: lstArtfct)                 
            {
                for(ContentDocumentLink conDocLinkItem : lstConDocLink) 
                {
                    if(artfcItem.Id == conDocLinkItem.LinkedEntityId)
                    {
                        invWrpItem = new InvoiceInfo();
                        invWrpItem.invNumber = artfcItem.InvoiceNumber__c;
                        invWrpItem.status = artfcItem.Status__c;
                        invWrpItem.invDate = artfcItem.InvoiceDate__c;
                        invWrpItem.dueDate = artfcItem.DueDate__c;   
                        invWrpItem.totAmount = artfcItem.TotalAmount__c;                    
                        invWrpItem.contentDocId = conDocLinkItem.ContentDocumentId;
                        listWrapper.add(invWrpItem);
                        break;
                    }                    
                }                                                     
            }           
        }
        
        if(u.IsPortalEnabled==true)
            invwrapper.isPortalUser=true;
        else
            invwrapper.isPortalUser=false;
        invwrapper.invList=listWrapper;

        String pymtURL = [SELECT Id, URL__c FROM TVE_External_URL__mdt 
                            WHERE DeveloperName = 'TVE_Make_a_Payment_URL' LIMIT 1].URL__c;
        invwrapper.paymentURL = pymtURL;
        return invwrapper;
    }
    
    public class InvoiceWrapper{
        @AuraEnabled public Boolean isPortalUser{get; set;}
        @AuraEnabled public List<InvoiceInfo> invList{get;set;}
        @AuraEnabled public string paymentURL{get;set;}
    }
    public class InvoiceInfo{
        @auraEnabled public string invNumber {get; set;}
        @auraEnabled public Date invDate {get; set;}
        @auraEnabled public Decimal totAmount {get; set;}
        @auraEnabled public Date dueDate {get; set;}
        @auraEnabled public String status {get; set;}
        @AuraEnabled public string contentDocId {get; set;}   
        @AuraEnabled public Boolean isPortalUser{get; set;}
    }
  

}