global without sharing class GetInverters implements vlocity_cmt.VlocityOpenInterface2 { 
    global static boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) { 
    if(methodName.equals('getInverterList')){ 
     Map<String, Object> inputIpMap = new Map<String, Object>();
     Map<String, Object> ipOptionsMap=new Map<String, Object>();
     Map<String, Object> ipOutputMap = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService('IP_FNP_SolarInstallDtls', inputIpMap, ipOptionsMap);  
     outMap.put('InverterList',ipOutputMap);          
    }
    return true;
    }
}