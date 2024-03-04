global without sharing class claimFormAttachmentCreate implements vlocity_cmt.VlocityOpenInterface2 { 
    global static boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) { 
        Boolean result = false;
        Map<String,String> error = new Map<String,String>();
        if(methodName.equals('createAttachment')){ 
            system.debug('Test');
            Id CaseId= (Id)inputMap.get('CaseId');
            List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
            List<dcp_Claim_Item__c> claimItemList = new List<dcp_Claim_Item__c>();
            Map<String,Object> claimDetail = new Map<String,Object>();
            Map<String,Object> claimItem = new Map<String,Object>();
            Map<String,Id> claimItemMap = new Map<String,Id>();
            List<Object> compFile = new List<Object>();
            claimDetail= (Map<String,Object>)inputMap.get('ClaimDetails');
            
            if(claimDetail.get('ClaimItem')!= null){
                system.debug('Test2');
                system.debug('claimDetail'+ claimDetail);
                String jString = JSON.serialize(claimDetail.get('ClaimItem'));
                system.debug('Test44'+jString);
                if(jString.substring(0,1)=='['){
                    for(Object obj:(List<Object>)claimDetail.get('ClaimItem')){
                        
                        Map<String, Object> myMaps = (Map<String,Object>)obj;
                        dcp_Claim_Item__c item1 = new dcp_Claim_Item__c(); 
                        item1.dcp_Age__c=(string)myMaps.get('Age');
                        item1.dcp_Claim_Amount__c=(decimal)myMaps.get('Amount');
                        item1.dcp_Make__c=(string)myMaps.get('Make');
                        item1.dcp_Model__c=(string)myMaps.get('Model');
                        item1.Name=(string)myMaps.get('ClaimedItem');
                        item1.dcp_Case__c=caseId;
                        claimItemList.add(item1);
                    }
                }
                if(jString.substring(0,1)=='{'){
                    system.debug('Test3');
                    Map<String, Object> myMaps = (Map<String,Object>)claimDetail.get('ClaimItem');
                    dcp_Claim_Item__c item1 = new dcp_Claim_Item__c(); 
                    item1.dcp_Age__c=(string)myMaps.get('Age');
                    item1.dcp_Claim_Amount__c=(decimal)myMaps.get('Amount');
                    item1.dcp_Make__c=(string)myMaps.get('Make');
                    item1.dcp_Model__c=(string)myMaps.get('Model');
                    item1.Name=(string)myMaps.get('ClaimedItem');
                    item1.dcp_Case__c=caseId;
                    claimItemList.add(item1);
                }
                system.debug('claimItemList----'+claimItemList);
                if(claimItemList.size()>0){
                    insert claimItemList;
                }
                
                for(dcp_Claim_Item__c Item :[Select Id, Name from dcp_Claim_Item__c WHERE dcp_Case__c=:CaseId]) {   
                    claimItemMap.put(Item.Name,Item.Id);
                }
                
                if(jString.substring(0,1)=='['){
                    for(Object obj:(List<Object>)claimDetail.get('ClaimItem')){
                        
                        Map<String, Object> myMaps = (Map<String,Object>)obj;
                        if(myMaps.get('Attachments')!=null){
                          for(Object objone:(List<Object>)myMaps.get('Attachments')){
                             Map<String,Object> dataone = (Map<String,Object>)objone;
                             Map<String,Object> finaldata = new Map<String,Object>();

                       ContentDocumentLink link1 = new ContentDocumentLink();
                       link1.ShareType = 'V';
                       link1.LinkedEntityId = claimItemMap.get((string)myMaps.get('ClaimedItem'));
                       link1.ContentDocumentId = (Id)dataone.get('data');
                       String fileName = (String)dataone.get('filename');
                       String fileNameithExtension = fileName.split('\\.').get(1);
                       if(fileNameithExtension == 'EXE' ){
                       	error.put('UploadError', 'Error::: File format not supported. Please upload pdf/Doc/Docx');
                       }else{
                       	linkList.add(link1);
                           }
                   }}
                    }
                }
                if(jString.substring(0,1)=='{'){
   
                    Map<String, Object> myMaps = (Map<String,Object>)claimDetail.get('ClaimItem');
                     if(myMaps.get('Attachments')!=null){
                    for(Object objone:(List<Object>)myMaps.get('Attachments')){
                      Map<String,Object> dataone = (Map<String,Object>)objone;
                       Map<String,Object> finaldata = new Map<String,Object>();

                       ContentDocumentLink link1 = new ContentDocumentLink();
                       link1.ShareType = 'V';
                       link1.LinkedEntityId = claimItemMap.get((string)myMaps.get('ClaimedItem'));
                       link1.ContentDocumentId = (Id)dataone.get('data');
                       String fileName = (String)dataone.get('filename');
                       System.debug('test1 -> '+fileName);
                       String fileNameithExtension = fileName.split('\\.').get(1);
                        System.debug('test2 -> '+fileNameithExtension);
                       if(fileNameithExtension == 'EXE'){
                       	error.put('UploadError', 'Error::: File format not supported. Please upload pdf/Doc/Docx');
                       }else{
                       	linkList.add(link1);
                           }
                   }}
                }
                system.debug('linkList----'+linkList);
                if(linkList.size()>0){
                    insert linkList;
                }
                if(!error.isEmpty())
            {outMap.put('uploaderror',error);}
                outMap.put('fileData',compFile);
                
                
            }  
            
        }
        return result;
    }
}