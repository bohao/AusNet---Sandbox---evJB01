@isTest
private class claimFormAttachmentCreateTest {
    
    static testMethod void invokeMethod(){
        case cId= new case();
        cId.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        insert cId;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        
        Map<String, Object> m;
        string sr='{"CaseId\":\"'+cId.id+'\",\"ClaimDetails\":{\"ClaimItem\":[{\"ClaimedItem\":\"test\",\"Make\":\"test\",\"Amount\":3000,\"Age\":\"38\",\"Model\":\"test\",\"Attachments\":[{\"ClaimedItem\":\"test\",\"data\":\"'+conDocId+'\",\"filename\":\"test.png\"}]}]}}';
        m = (Map<String, Object>) JSON.deserializeUntyped(sr);
        system.debug('mvalue>>'+m);
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Test.startTest();
        Boolean result=claimFormAttachmentCreate.invokeMethod('createAttachment',m, outputMap, options);
        Test.stopTest();
    }
    static testMethod void Method(){
        case cId= new case();
        cId.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        insert cId;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        Map<String, Object> m;
        string sr='{"CaseId\":\"'+cId.Id+'\",\"ClaimDetails\":{\"ClaimItem\":{\"ClaimedItem\":\"test\",\"Make\":\"test\",\"Amount\":3000,\"Age\":\"38\",\"Model\":\"test\",\"Attachments\":[{\"ClaimedItem\":\"test\",\"data\":\"'+conDocId+'\",\"filename\":\"test.png\"}]}}}';
        m = (Map<String, Object>) JSON.deserializeUntyped(sr);
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Test.startTest();
        Boolean result=claimFormAttachmentCreate.invokeMethod('createAttachment',m, outputMap, options);
        Test.stopTest();
    }
}