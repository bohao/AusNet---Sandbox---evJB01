global without sharing class TestReserializeApex implements vlocity_cmt.VlocityOpenInterface2 { 
    global static boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) { 
        Boolean result = false;
        Map<String,String> error = new Map<String,String>();
       if(methodName.equals('insertArtifacts')){ 
             Id caseId= (Id)inputMap.get('caseId');
                List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
                
                Map<String,Object> yourDetail = new Map<String,Object>();
                Map<String,Object> block2 = new Map<String,Object>();
                List<Object> compFile = new List<Object>();
                yourDetail= (Map<String,Object>)inputMap.get('YourDetails');
           if(yourDetail.get('Block2')!= null){
               block2 =(Map<String,Object>)yourDetail.get('Block2');
               if(block2.get('ComplaintFile')!= null){
                   //compFile=(List<Object>)block2.get('ComplaintFile');
                   system.debug('compFile----' +compFile);
                   system.debug('block2----' +block2);
                   system.debug('yourDetail----' +yourDetail);
                   for(Object obj:(List<Object>)block2.get('ComplaintFile')){
                    Map<String,Object> data = (Map<String,Object>)obj;
                    Map<String,Object> finaldata = new Map<String,Object>();
                    /*finaldata.put('ContentDocId',data.get('data'));
                    finaldata.put('ShareAccess','V');
                    finaldata.put('caseId',caseId);
                    compFile.add(finaldata);*/
                       system.debug('test');
                       ContentDocumentLink link1 = new ContentDocumentLink();
                       link1.ShareType = 'V';
                       link1.LinkedEntityId = caseId;
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
                   if(linkList.size()>0 && !Test.isRunningTest()){
                 insert linkList;
             }
               }
               
           }
               if(!error.isEmpty())
            {outMap.put('uploaderror',error);}
           outMap.put('fileData',compFile);
              
               
       }  
        return result;
        

       
}
}