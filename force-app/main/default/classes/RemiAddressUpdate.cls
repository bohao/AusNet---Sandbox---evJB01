/*
@description       : Apex Class For Remi Address Update 
@author            : Aditya Sinha, IBM India
@group             : 
@last modified on  : 17-08-2022
@last modified by  : Aditya Sinha
Modifications Log 
Ver   CreatedDate         Author         Modification
1.0   17-08-2022         Aditya Sinha   Initial Version
*/
global without sharing class RemiAddressUpdate implements vlocity_cmt.VlocityOpenInterface2 { 
    global static boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) { 
    if(methodName.equals('updateAddress')){ 
    Id CaseID = (Id)inputMap.get('CaseID');
    List<Case> caseList = new List<Case>();
    Case caseObj= new Case();
    caseObj.Id = CaseID;
    caseObj.Remi_APRA_RSA_Fund_address__c= (String)inputMap.get('APRAProvidedStreetAddressSetValue');
    caseList.add(caseObj);
    if(caseList .size()>0){
       update caseList;
    }               
    }
    return true;
    }
}