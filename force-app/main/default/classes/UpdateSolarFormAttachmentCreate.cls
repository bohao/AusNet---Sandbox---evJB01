global without sharing class UpdateSolarFormAttachmentCreate implements vlocity_cmt.VlocityOpenInterface2 {
    
    private static final Set<String> FILE_LABELS = new Set<String>{
        'File_CertificateOfElectricalSafety',
        'File_ElectricalWorksRequest',
        'File_OtherAttachments',
        'File_EvidenceDropletInstall',
        'File_EvidenceInverterCompliance'
    };

    global static boolean invokeMethod(String methodName, Map<String, Object> inputMap, Map<String, Object> outMap, Map<String, Object> options) {
        
        Boolean result = false;
        Map<String, String> error = new Map<String, String>();

        if (methodName.equals('updateAttachment')) {

            Id caseId = (Id) inputMap.get('CaseId');
            List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();
            List<Object> compFile = new List<Object>();
            Map<String, Object> documentBlock = (Map<String, Object>) inputMap.get('Documents');
            
            if (documentBlock != null && documentBlock.get('Block11') != null) {

                Map<String, Object> fileBlock = (Map<String, Object>) documentBlock.get('Block11');

                // include Flexible Export files where possible
                if (fileBlock.get('Block_FlexibleExport_Files') != null) {
                    fileBlock.putAll((Map<String, Object>) fileBlock.get('Block_FlexibleExport_Files'));
                }

                for (String fileLabel : FILE_LABELS) {
                    if (fileBlock.get(fileLabel) != null) {
                        for (Object obj : (List<Object>) fileBlock.get(fileLabel)) {

                            Map<String, Object> data = (Map<String, Object>) obj;
                            ContentDocumentLink cdl = new ContentDocumentLink();
                            cdl.ShareType = 'V';
                            cdl.LinkedEntityId = caseId;
                            cdl.ContentDocumentId = (Id) data.get('data');
                            String fileName = (String) data.get('filename');
                            String fileExt = fileName.split('\\.').get(1);
                            if (fileExt == 'EXE') {
                                error.put('UploadError', 'Error::: File format not supported. Please upload pdf/Doc/Docx');
                            } else {
                                contentDocLinks.add(cdl);
                            }
                        }
                    }
                }
            }
            
            try {
                if (!contentDocLinks.isEmpty()) {
                    insert contentDocLinks;
                }
            } catch (Exception e) {
                // Prepare a response body and set the output.
                String exceptionResult = e.getMessage() + '\n' + e.getStackTraceString() + '\n' + e.getLineNumber();
                System.debug(LoggingLevel.ERROR, 'Exception UpdateSolarFormAttachmentCreate :\n' + exceptionResult);
                FnP_ExtUserObjAccessUtility.integrationlog(exceptionResult, 'SolarFormRecordType', 'updateAttachment', JSON.serialize(inputMap), 'Create');
                outMap.put('DMLError', exceptionResult);
            }

            if (!error.isEmpty()) {
                outMap.put('uploaderror', error);
            }

            outMap.put('fileData', compFile);
        }

        return result;
    }
}