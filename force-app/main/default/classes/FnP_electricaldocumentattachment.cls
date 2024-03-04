global without sharing class FnP_electricaldocumentattachment implements vlocity_cmt.VlocityOpenInterface2 {
    global static boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        Boolean result = false;
        try {
            Map<String,String> error = new Map<String,String>();
            
            if (methodName.equals('FnP_uploadattachment')) {
                System.debug('test1');
                Id ProjectId= (Id)inputMap.get('ProjectId');
                system.debug('test3'+ProjectId);
                List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
                List<Artefact__c> ArtefactList = new List<Artefact__c>();
                Map<String,Object> yourDetail = new Map<String,Object>();
                Map<String,Id> ArtefactMap = new Map<String,Id>();
                Map<String,Object> block2 = new Map<String,Object>();
                Map<String,Object> block = new Map<String,Object>();
                List<Object> compFile = new List<Object>();
                
                yourDetail= (Map<String,Object>)inputMap.get('DocumentsDetails_Residential');
                system.debug('test2'+yourDetail);
                if(yourDetail != null) {
                    // This means, no documents uploaded in Documents tab. If they are entered only this block is executed.. 
                    // DCE-2767 : Modified for fixing Exception handling.
                    
                    if(yourDetail.get('Block_Attachments')!= null) {

                        block2 =(Map<String,Object>)yourDetail.get('Block_Attachments');
                        
                        if(block2.get('Block_UploadAttachment1')!= null) {
                            block =(Map<String,Object>)block2.get('Block_UploadAttachment1');
                            if(block.get('File_PropertySiteplan')!= null){
                                for(Object obj:(List<Object>)block.get('File_PropertySiteplan')){
                                    Map<String,Object> data = (Map<String,Object>)obj;
                                    Map<String,Object> finaldata = new Map<String,Object>();
                                    Artefact__c Artefact = new Artefact__c();
                                    Artefact.Classification__c = 'Property Sketch/Site Plan';
                                    Artefact.Name = 'Property Sketch/Site Plan';
                                    Artefact.Project__c = ProjectId;
                                    Artefact.RecordTypeId = Schema.SObjectType.Artefact__c.getRecordTypeInfosByName().get('Other').getRecordTypeId();
                                    ArtefactList.add(Artefact);
                                    
                                }
                            }
                        }

                        if(block2.get('Block_UploadAttachment2')!= null){   
                            block =(Map<String,Object>)block2.get('Block_UploadAttachment2');
                            if(block.get('File_PlanofSubdivision')!= null){
                                for(Object obj:(List<Object>)block.get('File_PlanofSubdivision')){
                                    Map<String,Object> data = (Map<String,Object>)obj;
                                    Map<String,Object> finaldata = new Map<String,Object>();
                                    Artefact__c Artefact = new Artefact__c();
                                    Artefact.Classification__c = 'Plan Of Subdivision';
                                    Artefact.Name = 'Plan Of Subdivision';
                                    Artefact.Project__c = ProjectId;
                                    Artefact.RecordTypeId = Schema.SObjectType.Artefact__c.getRecordTypeInfosByName().get('Other').getRecordTypeId();
                                    ArtefactList.add(Artefact);
                                }
                            }
                        }
                        if(block2.get('Block_UploadAttachment3')!= null){   
                            block =(Map<String,Object>)block2.get('Block_UploadAttachment3');
                            if(block.get('File_LoadCalculation')!= null){
                                for(Object obj:(List<Object>)block.get('File_LoadCalculation')){
                                    Map<String,Object> data = (Map<String,Object>)obj;
                                    Map<String,Object> finaldata = new Map<String,Object>();
                                    Artefact__c Artefact = new Artefact__c();
                                    Artefact.Classification__c = 'Load Calculation';
                                    Artefact.Name = 'Load Calculation';
                                    Artefact.Project__c = ProjectId;
                                    Artefact.RecordTypeId = Schema.SObjectType.Artefact__c.getRecordTypeInfosByName().get('Other').getRecordTypeId();
                                    ArtefactList.add(Artefact);
                                }
                            }
                        }
                        if(block2.get('Block_UploadAttachment4')!= null){   
                            block =(Map<String,Object>)block2.get('Block_UploadAttachment4');
                            if(block.get('File_DevelopmentPlans')!= null){
                                for(Object obj:(List<Object>)block.get('File_DevelopmentPlans')){
                                    Map<String,Object> data = (Map<String,Object>)obj;
                                    Map<String,Object> finaldata = new Map<String,Object>();
                                    Artefact__c Artefact = new Artefact__c();
                                    Artefact.Classification__c = 'Development Plans';
                                    Artefact.Name = 'Development Plans';
                                    Artefact.Project__c = ProjectId;
                                    Artefact.RecordTypeId = Schema.SObjectType.Artefact__c.getRecordTypeInfosByName().get('Other').getRecordTypeId();
                                    ArtefactList.add(Artefact);
                                }
                            }
                        }

                        if(block2.get('Block_UploadAttachment5')!= null){   
                            block =(Map<String,Object>)block2.get('Block_UploadAttachment5');
                            if(block.get('File_OtherAttachments')!= null){
                                for(Object obj:(List<Object>)block.get('File_OtherAttachments')){
                                    Map<String,Object> data = (Map<String,Object>)obj;
                                    Map<String,Object> finaldata = new Map<String,Object>();
                                    Artefact__c Artefact = new Artefact__c();
                                    Artefact.Classification__c = 'Other';
                                    Artefact.Name = 'Other';
                                    Artefact.Project__c = ProjectId;
                                    Artefact.RecordTypeId = Schema.SObjectType.Artefact__c.getRecordTypeInfosByName().get('Other').getRecordTypeId();
                                    ArtefactList.add(Artefact);
                                }
                            }
                        }
                        
                        system.debug('ArtefactList----'+ArtefactList);
                        if(ArtefactList.size()>0 && !Test.isRunningTest()){
                            insert ArtefactList;
                        }
                    } 
        
                    for(Artefact__c Item :[Select Id, Name from Artefact__c WHERE Project__c =:ProjectId]) {   
                        ArtefactMap.put(Item.Name,Item.Id);
                    }

                    if(yourDetail.get('Block_Attachments')!= null) {

                        block2 =(Map<String,Object>)yourDetail.get('Block_Attachments');
                        
                        if(block2.get('Block_UploadAttachment1')!= null) {   
                            
                            block =(Map<String,Object>)block2.get('Block_UploadAttachment1');
                            if(block.get('File_PropertySiteplan')!= null) {
                                for(Object obj:(List<Object>)block.get('File_PropertySiteplan')){
                                    Map<String,Object> data = (Map<String,Object>)obj;
                                    Map<String,Object> finaldata = new Map<String,Object>();
                                    
                                    ContentDocumentLink link1 = new ContentDocumentLink();
                                    link1.ShareType = 'V';
                                    link1.LinkedEntityId = (Id)ArtefactMap.get('Property Sketch/Site Plan');
                                    link1.ContentDocumentId = (Id)data.get('data');
                                    String fileName = (String)data.get('filename');
                                    String fileNameithExtension = fileName.split('\\.').get(1);
                                    
                                    if(fileNameithExtension == 'EXE' ){
                                        error.put('UploadError', 'Error::: File format not supported. Please upload pdf/Doc/Docx');
                                    }
                                    else {
                                        system.debug(link1);
                                        linkList.add(link1);
                                    }
                                }
                            }
                        }
                        if(block2.get('Block_UploadAttachment2')!= null) {
                            block =(Map<String,Object>)block2.get('Block_UploadAttachment2');

                            if(block.get('File_PlanofSubdivision')!= null){
                                for(Object obj:(List<Object>)block.get('File_PlanofSubdivision')){
                                    Map<String,Object> data = (Map<String,Object>)obj;
                                    Map<String,Object> finaldata = new Map<String,Object>();
                                
                                    ContentDocumentLink link2 = new ContentDocumentLink();
                                    link2.ShareType = 'V';
                                    link2.LinkedEntityId = (Id)ArtefactMap.get('Plan Of Subdivision');
                                    link2.ContentDocumentId = (Id)data.get('data');
                                    String fileName = (String)data.get('filename');
                                    String fileNameithExtension = fileName.split('\\.').get(1);
                                    
                                    if(fileNameithExtension == 'EXE' ){
                                        error.put('UploadError', 'Error::: File format not supported. Please upload pdf/Doc/Docx');
                                    }
                                    else{
                                        system.debug(link2);
                                        linkList.add(link2);
                                    }
                                }
                            }
                        }
                        if(block2.get('Block_UploadAttachment3')!= null){   
                            block =(Map<String,Object>)block2.get('Block_UploadAttachment3');
                            if(block.get('File_LoadCalculation')!= null){
                                for(Object obj:(List<Object>)block.get('File_LoadCalculation')){
                                    Map<String,Object> data = (Map<String,Object>)obj;
                                    Map<String,Object> finaldata = new Map<String,Object>();
                                
                                    ContentDocumentLink link3 = new ContentDocumentLink();
                                    link3.ShareType = 'V';
                                    link3.LinkedEntityId = (Id)ArtefactMap.get('Load Calculation');
                                    link3.ContentDocumentId = (Id)data.get('data');
                                    String fileName = (String)data.get('filename');
                                    String fileNameithExtension = fileName.split('\\.').get(1);

                                    if(fileNameithExtension == 'EXE' ) {
                                        error.put('UploadError', 'Error::: File format not supported. Please upload pdf/Doc/Docx');
                                    }
                                    else{
                                        system.debug(link3);
                                        linkList.add(link3);
                                    }
                                }
                            }
                        }
                        if(block2.get('Block_UploadAttachment4')!= null){   
                            block =(Map<String,Object>)block2.get('Block_UploadAttachment4');
                            if(block.get('File_DevelopmentPlans')!= null){
                                for(Object obj:(List<Object>)block.get('File_DevelopmentPlans')){
                                    Map<String,Object> data = (Map<String,Object>)obj;
                                    Map<String,Object> finaldata = new Map<String,Object>();
                                
                                    ContentDocumentLink link4 = new ContentDocumentLink();
                                    link4.ShareType = 'V';
                                    link4.LinkedEntityId = (Id)ArtefactMap.get('Development Plans');
                                    link4.ContentDocumentId = (Id)data.get('data');
                                    String fileName = (String)data.get('filename');
                                    String fileNameithExtension = fileName.split('\\.').get(1);
                                    
                                    if(fileNameithExtension == 'EXE' ) {
                                        error.put('UploadError', 'Error::: File format not supported. Please upload pdf/Doc/Docx');
                                    }
                                    else{
                                        system.debug(link4);
                                        linkList.add(link4);
                                    }
                                }
                            }
                        }
                        
                        if(block2.get('Block_UploadAttachment5')!= null) {   
                            block =(Map<String,Object>)block2.get('Block_UploadAttachment5');
                            if(block.get('File_OtherAttachments')!= null){
                                for(Object obj:(List<Object>)block.get('File_OtherAttachments')){
                                    Map<String,Object> data = (Map<String,Object>)obj;
                                    Map<String,Object> finaldata = new Map<String,Object>();
                                
                                    ContentDocumentLink link5 = new ContentDocumentLink();
                                    link5.ShareType = 'V';
                                    link5.LinkedEntityId = (Id)ArtefactMap.get('Other');
                                    link5.ContentDocumentId = (Id)data.get('data');
                                    String fileName = (String)data.get('filename');
                                    String fileNameithExtension = fileName.split('\\.').get(1);
                                    if(fileNameithExtension == 'EXE' ){
                                        error.put('UploadError', 'Error::: File format not supported. Please upload pdf/Doc/Docx');
                                    }
                                    else{
                                        system.debug(link5);
                                        linkList.add(link5);
                                    }
                                }
                            }
                        }

                        System.debug('linkList----'+linkList);
                        
                        if(linkList.size()>0 && !Test.isRunningTest()){
                            insert linkList;
                        }

                        if(!error.isEmpty()) {
                            outMap.put('uploaderror',error);
                        }
                    }
                }
            }  
        }
        catch(Exception excep) {
            // Prepare a response body and set the output. 
            String exceptionResult = excep.getMessage()+'\n'+excep.getStackTraceString()+'\n'+excep.getLineNumber();
            System.debug(LoggingLevel.ERROR, 'Exception upsertRecordData :\n'+exceptionResult);
            FnP_ExtUserObjAccessUtility.integrationlog(exceptionResult,'ElectricalFormRecordType', 'FnP_electricaldocumentattachment',JSON.serialize(inputMap), 'Create');
            outMap.put('DMLError',exceptionResult); 
        }

        return result;
    }
}