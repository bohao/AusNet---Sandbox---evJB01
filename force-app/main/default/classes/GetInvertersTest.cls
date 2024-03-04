/*
@description       : Apex Test Class For GetInverters  
@author            : Aditya Sinha, IBM India
@group             : 
@last modified on  : 20-09-2022
@last modified by  : Aditya Sinha
Modifications Log 
Ver   CreatedDate         Author         Modification
1.0   20-09-2022         Aditya Sinha   Initial Version
*/
@isTest
private class GetInvertersTest {
    
    static testMethod void invokeMethod(){
        Map<String, Object> inputMap=new Map<String,Object>();
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Test.startTest();
        Boolean result=GetInverters.invokeMethod('getInverterList',inputMap, outputMap, options);
        Test.stopTest();
    }
   
}