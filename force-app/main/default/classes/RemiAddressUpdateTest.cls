/*
@description       : Apex Test Class For RemiAddressUpdate 
@author            : Aditya Sinha, IBM India
@group             : 
@last modified on  : 17-08-2022
@last modified by  : Aditya Sinha
Modifications Log 
Ver   CreatedDate         Author         Modification
1.0   17-08-2022         Aditya Sinha   Initial Version
*/
@isTest
private class RemiAddressUpdateTest {
    
    static testMethod void invokeMethod(){
        case cId= new case();
        cId.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        insert cId;
        Map<String, Object> m;
        string sr='{ "APRAProvidedStreetAddressSetValue":"test","CaseID":"'+cId.Id+'","YourDetails": { "PhotoID": [{"filename": "DominoDuplInv.pdf","size": 4189,"data":"conDocIdcontact","contentDocumentId":"conDocIdcontact","vId":"0685P0000018fg0QAA"}]},"SuperannuationDetails": {"SMSFDocumentUpload": [{"filename": "DominoDuplInv.pdf","size": 4189,"data":"conDocIdcase","contentDocumentId": "0695P00000197JCQAY","vId": "0685P0000018fgFQAQ"}]}}';
        m = (Map<String, Object>) JSON.deserializeUntyped(sr);
        system.debug('mvalue>>'+m);
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Test.startTest();
        Boolean result=RemiAddressUpdate.invokeMethod('updateAddress',m, outputMap, options);
        Test.stopTest();
    }
   
}