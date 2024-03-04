/*
@description       : Apex Class For Remi Document Upload 
@author            : Aditya Sinha, IBM India
@group             : 
@last modified on  : 05-08-2022
@last modified by  : Aditya Sinha
Modifications Log 
Ver   CreatedDate         Author         Modification
1.0   05-08-2022         Aditya Sinha   Initial Version
*/
global without sharing class RemiFileUpload implements vlocity_cmt.VlocityOpenInterface2 { 
    global static boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) { 
    if(methodName.equals('createAttachment')){ 
    Id ContactID = (Id)inputMap.get('ContactID');
    Id CaseID = (Id)inputMap.get('CaseID');
    List<ContentDocumentLink> linkList = new List<ContentDocumentLink>();
    Map<String,Object> YourDetails= (Map<String,Object>)inputMap.get('YourDetails');
    if(YourDetails.get('PhotoID')!=null){
                       for(Object objone:(List<Object>)YourDetails.get('PhotoID')){
                       Map<String,Object> dataone = (Map<String,Object>)objone;
                       ContentDocumentLink link1 = new ContentDocumentLink();
                       link1.ShareType = 'V';
                       link1.LinkedEntityId = ContactID ;
                       link1.ContentDocumentId = (Id)dataone.get('data');
                       String fileName = (String)dataone.get('filename');
                       String fileNameithExtension = fileName.split('\\.').get(1);
                        linkList.add(link1);
                   }}
     Map<String,Object> SuperannuationDetails= (Map<String,Object>)inputMap.get('SuperannuationDetails');
    if(SuperannuationDetails.get('SMSFDocumentUpload')!=null){
                       for(Object objone:(List<Object>)SuperannuationDetails.get('SMSFDocumentUpload')){
                       Map<String,Object> dataone = (Map<String,Object>)objone;
                       ContentDocumentLink link1 = new ContentDocumentLink();
                       link1.ShareType = 'V';
                       link1.LinkedEntityId = CaseID ;
                       link1.ContentDocumentId = (Id)dataone.get('data');
                       String fileName = (String)dataone.get('filename');
                       String fileNameithExtension = fileName.split('\\.').get(1);
                       linkList.add(link1);
                   }}
                   if(linkList.size()>0){
                    insert linkList;
                }               
    }
    return true;
    }
}