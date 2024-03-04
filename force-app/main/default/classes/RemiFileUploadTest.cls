/*
@description       : Apex Test Class For RemiFileUpload 
@author            : Aditya Sinha, IBM India
@group             : 
@last modified on  : 05-08-2022
@last modified by  : Aditya Sinha
Modifications Log 
Ver   CreatedDate         Author         Modification
1.0   05-08-2022         Aditya Sinha   Initial Version
*/
@isTest
private class RemiFileUploadTest {
    
    static testMethod void invokeMethod(){
        case cId= new case();
        cId.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        insert cId;
       
        Contact conId= new Contact();
        conId.FirstName='first';
        conId.LastName='last';
        insert conId;
        
        ContentVersion cvcase = new ContentVersion();
        cvcase.Title = 'Test Document Case';
        cvcase.PathOnClient = 'TestDocumentCase.pdf';
        cvcase.VersionData = Blob.valueOf('Test Content Case');
        cvcase.IsMajorVersion = true;
        Insert cvcase;
        Id conDocIdcase = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cvcase.Id].ContentDocumentId;
        
        ContentVersion cvcontact = new ContentVersion();
        cvcontact.Title = 'Test Document Contact';
        cvcontact.PathOnClient = 'TestDocumentContact.pdf';
        cvcontact.VersionData = Blob.valueOf('Test Content Contact');
        cvcontact.IsMajorVersion = true;
        Insert cvcontact;
        Id conDocIdcontact = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cvcontact.Id].ContentDocumentId;
        
        
        Map<String, Object> m;
        string sr='{ "ContactID":"'+conId.Id+'","CaseID":"'+cId.Id+'","YourDetails": { "PhotoID": [{"filename": "DominoDuplInv.pdf","size": 4189,"data":"'+conDocIdcontact+'","contentDocumentId":"'+conDocIdcontact+'","vId":"0685P0000018fg0QAA"}]},"SuperannuationDetails": {"SMSFDocumentUpload": [{"filename": "DominoDuplInv.pdf","size": 4189,"data":"'+conDocIdcase+'","contentDocumentId": "0695P00000197JCQAY","vId": "0685P0000018fgFQAQ"}]}}';
        m = (Map<String, Object>) JSON.deserializeUntyped(sr);
        system.debug('mvalue>>'+m);
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Test.startTest();
        Boolean result=RemiFileUpload.invokeMethod('createAttachment',m, outputMap, options);
        Test.stopTest();
    }
   
}