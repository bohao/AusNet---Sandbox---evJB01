global without sharing class CreateSolarFormAttachmentCreate implements vlocity_cmt.VlocityOpenInterface2 {
    global static boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = false;
        Map<String,String> error = new Map<String,String>();
        if(methodName.equals('createAttachment')){
            Id CaseId= (Id)inputMap.get('CaseId');
            
            system.debug('CaseIdchecorf>>'+inputMap);
            List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
            Map<String,Object> yourDetail = new Map<String,Object>();
            List<Object> compFile = new List<Object>();
           // system.debug('inputmap get>>'+(Map<String,Object>)inputMap.get('ApplicationType'));
            yourDetail= (Map<String,Object>)inputMap.get('Review and Confirmation');
            if(yourDetail.get('UploadConstructionDocument')!= null){
                system.debug('compFile----' +compFile);
                system.debug('yourDetail----' +yourDetail);
                for(Object obj:(List<Object>)yourDetail.get('UploadConstructionDocument')){
                    Map<String,Object> data = (Map<String,Object>)obj;
                    system.debug('data'+data);
                    Map<String,Object> finaldata = new Map<String,Object>();
                    //finaldata.put('ShareAccess','V');
                    //finaldata.put('CaseId',CaseId);
                    //compFile.add(finaldata);
                        system.debug('test');
                    ContentDocumentLink link1 = new ContentDocumentLink();
                    link1.ShareType = 'V';
                    link1.LinkedEntityId = CaseId;
                    system.debug('>>>>>>>>>>>>>>>>>>>>>>');
                    link1.ContentDocumentId = (Id)data.get('data');
                     String fileName = (String)data.get('filename');
                       String fileNameithExtension = fileName.split('\\.').get(1);
                       if(fileNameithExtension == 'EXE' ){
                       	error.put('UploadError', 'Error::: File format not supported. Please upload pdf/Doc/Docx');
                       }else{
                    system.debug(link1);
                    linkList.add(link1);
                       }
                }
                system.debug('linkList----'+linkList);
                if(linkList.size()>0 ){  //&& !Test.isRunningTest()
                    insert linkList;
                }
            }
            if(!error.isEmpty())
            {outMap.put('uploaderror',error);}
            outMap.put('fileData',compFile);
        }
        return result;
     
    }
}