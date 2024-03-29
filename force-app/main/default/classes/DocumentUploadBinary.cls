@RestResource(urlMapping='/DocumentUploadBinary/*')
global class DocumentUploadBinary {

    @HttpPost
    global static void uploadDocument() {
    
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        Id caseId = req.params.get('caseId');
        String contenttype = req.params.get('contenttype');
        String name = req.params.get('name');

        try {
            //Insert ContentVersion
            ContentVersion cVersion = new ContentVersion();
            cVersion.PathOnClient = name;//File name with extention
            cVersion.Title = name;//Name of the file
            cVersion.VersionData = req.requestBody;//File content
            insert cVersion;

            //After saved the Content Verison, get the ContentDocumentId
            Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;

            //Insert ContentDocumentLink
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
            cDocLink.LinkedEntityId = caseId;//Add attachment parentId
            insert cDocLink;

            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(generateJSON('Success',conDocument,''));
        }
        catch(Exception e) {
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(generateJSON('Error','',e.getMessage()));
        }
    }

    // To generate JSON response
    private static string generateJSON(String Status,String Content,String error) {
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeStringField('Status',Status);
        jsGen.writeStringField('ContentID', Content);
        jsGen.writeStringField('Error', error);
        jsGen.writeEndObject();
        return jsGen.getAsString();
    }
}