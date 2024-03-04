@isTest
private class CreateSolarFormAttachmentCreateTest {

    @isTest static void invokeMethod() {
        case cId= new case();
        insert cId;
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //String sr ='{"CaseId":\"'+cId.id+'\",\"Review and Confirmation\":{\"UploadConstructionDocument\":[{\"data\":\"'+conDocId+'\",\"vId\":\"'+cdl.Id+'\"},{\"data\":\"0695P0000015I7sQAE\",\"deleteLabel\":\"DeleteTestpdf.pdf\",\"filename\":\"apex-07L5P000005KeQuUAK.log\",\"size\":\"372059\",\"vId\":\"0685P0000014qjkQAR\"}]}}';
        String sr ='{"CaseId":\"'+cId.id+'\",\"Review and Confirmation\":{\"UploadConstructionDocument\":[{\"data\":\"'+conDocId+'\",\"filename\":\"test.png\"}]}}';
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(sr); 
        System.debug('mvalue>>'+m);
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Test.startTest();
        Boolean result = CreateSolarFormAttachmentCreate.invokeMethod('createAttachment',m, outputMap, options);
        Test.stopTest();
    }

   
}