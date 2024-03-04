@IsTest
private class DocumentUploadBinaryTest {
    
    @IsTest
    static void test_uploadDocument() {

        Case c = new Case();
        c.Origin = 'Web';
        insert c;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest//DocumentUploadBinary';
        req.httpMethod = 'POST';
        req.addParameter('caseId', c.Id);
        req.addParameter('contenttype', null);
        req.addParameter('name', 'TEST');
        req.requestBody = Blob.valueOf('test request body in text form');
    
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();

        DocumentUploadBinary.uploadDocument();

        Test.stopTest();
    }

    @IsTest
    static void test_uploadDocumentException() {

        Case c = new Case();
        c.Origin = 'Web';
        insert c;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest//DocumentUploadBinary';
        req.httpMethod = 'POST';
    
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();

        DocumentUploadBinary.uploadDocument();

        Test.stopTest();
    }
}