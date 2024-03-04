@isTest
public class UpdateSolarFormAttachmentCreateTest {
   
    @isTest 
    static void invokeMethod() {
        
        case cId= new case();
        cId.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        insert cId;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        // insert cv;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document';
        cv1.PathOnClient = 'TestDocument.pdf';
        cv1.VersionData = Blob.valueOf('Test Content');
        cv1.IsMajorVersion = true;
        // insert cv1;
        
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Test Document';
        cv2.PathOnClient = 'TestDocument.pdf';
        cv2.VersionData = Blob.valueOf('Test Content');
        cv2.IsMajorVersion = true;
        // insert cv2;

        ContentVersion fe_cv = new ContentVersion();
        fe_cv.Title = 'Test Document';
        fe_cv.PathOnClient = 'TestDocument.pdf';
        fe_cv.VersionData = Blob.valueOf('Test Content');
        fe_cv.IsMajorVersion = true;

        ContentVersion fe_cv1 = new ContentVersion();
        fe_cv1.Title = 'Test Document';
        fe_cv1.PathOnClient = 'TestDocument.pdf';
        fe_cv1.VersionData = Blob.valueOf('Test Content');
        fe_cv1.IsMajorVersion = true;

        insert new List<ContentVersion>{cv, cv1, cv2, fe_cv, fe_cv1};
        List<String> contentVersionId = new List<String>{cv.Id, cv1.Id, cv2.Id, fe_cv.Id, fe_cv1.Id};
        Map<Id,ContentVersion> cvById = new Map<Id,ContentVersion>([SELECT ContentDocumentId FROM ContentVersion WHERE Id In:contentVersionId]);

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('CaseId', cId.Id);
        gen.writeFieldName('Documents');
        gen.writeStartObject();
        gen.writeFieldName('Block11');
        gen.writeStartObject();

        gen.writeFieldName('File_CertificateOfElectricalSafety');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('data', cvById.get(cv.Id).ContentDocumentId);
        gen.writeStringField('deleteLabel', cv.Id+'.txt');
        gen.writeStringField('filename', cv.Id+'.txt');
        gen.writeStringField('size', '100000');
        gen.writeStringField('vId', cv.Id);
        gen.writeEndObject();
        gen.writeEndArray();

        gen.writeFieldName('File_ElectricalWorksRequest');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('data', cvById.get(cv1.Id).ContentDocumentId);
        gen.writeStringField('deleteLabel', cv1.Id+'.txt');
        gen.writeStringField('filename', cv1.Id+'.txt');
        gen.writeStringField('size', '100000');
        gen.writeStringField('vId', cv1.Id);
        gen.writeEndObject();
        gen.writeEndArray();

        gen.writeFieldName('File_OtherAttachments');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('data', cvById.get(cv2.Id).ContentDocumentId);
        gen.writeStringField('deleteLabel', cv2.Id+'.txt');
        gen.writeStringField('filename', cv2.Id+'.txt');
        gen.writeStringField('size', '100000');
        gen.writeStringField('vId', cv2.Id);
        gen.writeEndObject();
        gen.writeEndArray();

        // BEGIN: FE Block
        gen.writeFieldName('Block_FlexibleExport_Files');
        gen.writeStartObject();

        gen.writeFieldName('File_EvidenceDropletInstall');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('data', cvById.get(fe_cv.Id).ContentDocumentId);
        gen.writeStringField('deleteLabel', fe_cv.Id+'.txt');
        gen.writeStringField('filename', fe_cv.Id+'.txt');
        gen.writeStringField('size', '100000');
        gen.writeStringField('vId', fe_cv.Id);
        gen.writeEndObject();
        gen.writeEndArray();

        gen.writeFieldName('File_EvidenceInverterCompliance');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('data', cvById.get(fe_cv1.Id).ContentDocumentId);
        gen.writeStringField('deleteLabel', fe_cv1.Id+'.txt');
        gen.writeStringField('filename', fe_cv1.Id+'.txt');
        gen.writeStringField('size', '100000');
        gen.writeStringField('vId', fe_cv1.Id);
        gen.writeEndObject();
        gen.writeEndArray();

        gen.writeEndObject();
        // END: FE Block

        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject();

        Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(gen.getAsString());
        System.debug('inputMap>>:\n'+inputMap);
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Test.startTest();
        Boolean result = UpdateSolarFormAttachmentCreate.invokeMethod('updateAttachment',inputMap, outputMap, options);
        Test.stopTest();
    }

    @isTest 
    static void invokeMethodWithoutFlexibleExportFiles() {
        
        case cId= new case();
        cId.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Claim').getRecordTypeId();
        insert cId;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = 'Test Document';
        cv1.PathOnClient = 'TestDocument.pdf';
        cv1.VersionData = Blob.valueOf('Test Content');
        cv1.IsMajorVersion = true;
        
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Test Document';
        cv2.PathOnClient = 'TestDocument.pdf';
        cv2.VersionData = Blob.valueOf('Test Content');
        cv2.IsMajorVersion = true;

        insert new List<ContentVersion>{cv, cv1, cv2};
        List<String> contentVersionId = new List<String>{cv.Id, cv1.Id, cv2.Id};
        Map<Id,ContentVersion> cvById = new Map<Id,ContentVersion>([SELECT ContentDocumentId FROM ContentVersion WHERE Id In:contentVersionId]);

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('CaseId', cId.Id);
        gen.writeFieldName('Documents');
        gen.writeStartObject();
        gen.writeFieldName('Block11');
        gen.writeStartObject();

        gen.writeFieldName('File_CertificateOfElectricalSafety');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('data', cvById.get(cv.Id).ContentDocumentId);
        gen.writeStringField('deleteLabel', cv.Id+'.txt');
        gen.writeStringField('filename', cv.Id+'.txt');
        gen.writeStringField('size', '100000');
        gen.writeStringField('vId', cv.Id);
        gen.writeEndObject();
        gen.writeEndArray();

        gen.writeFieldName('File_ElectricalWorksRequest');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('data', cvById.get(cv1.Id).ContentDocumentId);
        gen.writeStringField('deleteLabel', cv1.Id+'.txt');
        gen.writeStringField('filename', cv1.Id+'.txt');
        gen.writeStringField('size', '100000');
        gen.writeStringField('vId', cv1.Id);
        gen.writeEndObject();
        gen.writeEndArray();

        gen.writeFieldName('File_OtherAttachments');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('data', cvById.get(cv2.Id).ContentDocumentId);
        gen.writeStringField('deleteLabel', cv2.Id+'.txt');
        gen.writeStringField('filename', cv2.Id+'.txt');
        gen.writeStringField('size', '100000');
        gen.writeStringField('vId', cv2.Id);
        gen.writeEndObject();
        gen.writeEndArray();

        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject();

        Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(gen.getAsString());
        System.debug('inputMap>>:\n'+inputMap);
        Map<String,Object> outputMap = new Map<String,Object>();
        Map<String,Object> options = new Map<String,Object>();
        Test.startTest();
        Boolean result = UpdateSolarFormAttachmentCreate.invokeMethod('updateAttachment',inputMap, outputMap, options);
        Test.stopTest();
    }
}