@isTest
public class FnP_SolarFormUtilityTest {
	
    
    @IsTest
    public static void test_Inverters(){
        Test.startTest();
        Map<String,Object> fieldMapping=new Map<String,Object>();
        fieldMapping.put('FirstName','FirstName');
        fieldMapping.put('LastName','LastName');
        fieldMapping.put('Email','Email');
        fieldMapping.put('MobilePhone','MobilePhone');
        fieldMapping.put('OtherPhone','OtherPhone');
        
        List<Object> sObjectFieldLst = new List<Object>();
        sObjectFieldLst.add(fieldMapping);
        
        Map<String,Object> inputMap=new Map<String,Object>();
        inputMap.put('FirstName','CityGen');
        inputMap.put('LastName','CityGen');
        inputMap.put('Email','cgen@c.com');
        inputMap.put('MobilePhone','0490213214');
        inputMap.put('OtherPhone','422244222');
        inputMap.put('sObjectFieldLst',sObjectFieldLst);
        inputMap.put('sobjectApiName','Contact');
        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        FnP_SolarFormUtility fnpObject=new FnP_SolarFormUtility();
        Boolean result=fnpObject.invokeMethod('getInverters',inputMap, outputMap, options);
        system.debug('result'+result);
        
        System.assertEquals(true, result);
        Test.stopTest();
    }
    @IsTest
    public static void test_createDERApplicationAuto(){
        Test.startTest();           
        Map<String, Object> n;
        Map<String, Object> o;
        Map<String, Object> p;
        Map<String, Object> q;
        Map<String, Object> r;
        Map<String, Object> t;
         Map<String, Object> s;
        
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DERAPPUpdateSOlarForm' LIMIT 1];
        string sr1='{"Status\":true,\"Type\":\"RemoteAction\",\"ElapsedTime\":1237,\"ElapsedTimeCPU\":477,\"DERRequestPayload\":{\"derCase\":{\"ContactPhone\":\"9123498764\",\"ContactEmail\":\"test@gmail.com\",\"attributes\":{\"type\":\"Case\"},\"Applicant_Email__c\":\"\",\"DER_Application_Scenario__c\":\"Auto\",\"Priority\":\"Low\",\"Origin\":\"Web\",\"Status\":\"InstallationPending\",\"Type\":\"Augmentation\",\"Applicant_Type__c\":\"\",\"Agreement_Type__c\":\"BasicMicroEGMSO\",\"Auto_Applicant_Email__c\":\"\",\"Auto_Applicant_LastName__c\":\"doe\",\"Auto_Applicant_FirstName__c\":\"\"},\"devices\":[{\"attributes\":{\"type\":\"Device__c\"},\"Total_Export\":\"0.69\",\"AC_Equip_Cap__c\":2,\"Total_Capacity\":4,\"Phase\":\"B\",\"Manufacturer__c\":\"ALPHAESSCOLTF\",\"Model__c\":\"HNS4000TL(AS4777-22020)\",\"AC_Equip_Sub_Type__c\":\"Battery\",\"AC_DC_Coupling__c\":\"AC\",\"AC_Equip_Type__c\":\"Solar\",\"CEC_ID__c\":\"INV00007993\",\"DRED_Enabled__c\":\"Yes\",\"Requested__c\":\"true\",\"Approved__c\":\"true\",\"EAI_Parent__c\":null,\"EAI_Type__c\":\"Device_L2\",\"SID__c\":null,\"TotallingExport\":1.38},{\"attributes\":{\"type\":\"Device__c\"},\"Total_Export\":\"0.69\",\"AC_Equip_Cap__c\":2,\"Total_Capacity\":4,\"Phase\":\"B\",\"Manufacturer__c\":\"ALPHAESSCOLTF\",\"Model__c\":\"HNS4000TL(AS4777-22020)\",\"AC_Equip_Type__c\":\"Solar\",\"CEC_ID__c\":\"INV00007993\",\"DRED_Enabled__c\":\"Yes\",\"Requested__c\":\"true\",\"Approved__c\":\"true\",\"EAI_Parent__c\":\"INV00007993\",\"EAI_Ref__c\":\"INV00007994\",\"AC_Equip_Sub_Type__c\":\"Battery\",\"AC_DC_Coupling__c\":\"AC\",\"AC_Equip_Type__c\":\"Solar\",\"Device_Type__c\":\"Battery\",\"SID__c\":null,\"TotallingExport\":1.38}],\"nmi\":{\"attributes\":{\"type\":\"Connection_Point__c\"},\"Name\":\"12345\",\"nmi__c\":\"12345\"},\"derApp\":{\"attributes\":{\"type\":\"DER_Application__c\"},\"Approved_Export_Rating__c\":\"\",\"Existing_Total_Export_Rating__c\":\"\",\"Existing_Total_Inverter_Capacity__c\":\"\",\"Phase_Amount_Available__c\":\"\",\"Approved_Total_Capacity__c\":\"\",\"Import_Existing_Assets__c\":\"\",\"SOP_33_06_Compliant__c\":\"\",\"Ph_C_New_Export__c\":\"2.13\",\"Ph_A_New_Export__c\":0,\"Ph_B_New_Export__c\":\"2.02\",\"Has_Battery__c\":true,\"Has_Solar__c\":true,\"Meter_Number__c\":\"xy123\"}}}';
        string sr2='{"Status\":true,\"Type\":\"RemoteAction\",\"ElapsedTime\":1237,\"ElapsedTimeCPU\":477,\"DERRequestPayload\":{\"derCase\":{\"ContactPhone\":\"9123498764\",\"ContactEmail\":\"test@gmail.com\",\"attributes\":{\"type\":\"Case\"},\"Applicant_Email__c\":\"\",\"DER_Application_Scenario__c\":\"Auto\",\"Priority\":\"Low\",\"Origin\":\"Web\",\"Status\":\"InstallationPending\",\"Type\":\"Augmentation\",\"Applicant_Type__c\":\"\",\"Agreement_Type__c\":\"BasicMicroEGMSO\",\"Auto_Applicant_Email__c\":\"\",\"Auto_Applicant_LastName__c\":\"doe\",\"Auto_Applicant_FirstName__c\":\"\"},\"devices\":[{\"attributes\":{\"type\":\"Device__c\"},\"Total_Export\":\"0.69\",\"AC_Equip_Cap__c\":2,\"Total_Capacity\":4,\"Phase\":\"B\",\"Manufacturer__c\":\"ALPHAESSCOLTF\",\"Model__c\":\"HNS4000TL(AS4777-22020)\",\"AC_Equip_Type__c\":\"Solar\",\"CEC_ID__c\":\"INV00007993\",\"DRED_Enabled__c\":\"Yes\",\"Requested__c\":\"true\",\"Approved__c\":\"true\",\"EAI_Parent__c\":\"INV00007993\",\"EAI_Ref__c\":\"INV00007994\",\"AC_Equip_Sub_Type__c\":\"Battery\",\"AC_DC_Coupling__c\":\"AC\",\"AC_Equip_Type__c\":\"Solar\",\"Device_Type__c\":\"Battery\",\"SID__c\":null,\"TotallingExport\":1.38}],\"nmi\":{\"attributes\":{\"type\":\"Connection_Point__c\"},\"Name\":\"12345\",\"nmi__c\":\"12345\"},\"derApp\":{\"attributes\":{\"type\":\"DER_Application__c\"},\"Approved_Export_Rating__c\":\"\",\"Existing_Total_Export_Rating__c\":\"\",\"Existing_Total_Inverter_Capacity__c\":\"\",\"Phase_Amount_Available__c\":\"\",\"Approved_Total_Capacity__c\":\"\",\"Import_Existing_Assets__c\":\"\",\"SOP_33_06_Compliant__c\":\"\",\"Ph_C_New_Export__c\":\"2.13\",\"Ph_A_New_Export__c\":0,\"Ph_B_New_Export__c\":\"2.02\",\"Has_Battery__c\":true,\"Has_Solar__c\":true,\"Meter_Number__c\":\"xy123\"}}}';
        string sr3='{"Status\":true,\"Type\":\"Remote Action\",\"ElapsedTime\":1237,\"ElapsedTimeCPU\":477,\"DERRequestPayload\":{\"derCase\":{\"ContactPhone\":\"9123498764\",\"ContactEmail\":\"test@gmail.com\",\"attributes\":{\"type\":\"Case\"},\"Applicant_Email__c\":\"\",\"DER_Application_Scenario__c\":\"Auto\",\"Priority\":\"Low\",\"Origin\":\"Web\",\"Status\":\"Installation Pending\",\"Type\":\"Augmentation\",\"Applicant_Type__c\":\"\",\"Agreement_Type__c\":\"Basic Micro EG MSO\",\"Auto_Applicant_Email__c\":\"\",\"Auto_Applicant_LastName__c\":\"doe\",\"Auto_Applicant_FirstName__c\":\"\"},\"devices\":[{\"attributes\":{\"type\":\"Device__c\"},\"Total_Export\":\"0.69\",\"AC_Equip_Cap__c\":2,\"Total_Capacity\":4,\"Phase\":\"B\",\"Manufacturer__c\":\"ALPHA ESS CO LTF\",\"Model__c\":\"HNS4000TL (AS4777-2 2020)\",\"AC_Equip_Type__c\":\"Solar\",\"CEC_ID__c\":\"INV00007993\",\"DRED_Enabled__c\":\"Yes\",\"Requested__c\":\"true\",\"Approved__c\":\"true\",\"EAI_Parent__c\":null,\"EAI_Ref__c\":\"INV00007994\",\"EAI_Type__c\":\"Device_L3\",\"AC_Equip_Sub_Type__c\":\"Battery\",\"AC_DC_Coupling__c\":\"AC\",\"Device_Type__c\":\"Battery\",\"SID__c\":null,\"TotallingExport\":1.38}],\"nmi\":{\"attributes\":{\"type\":\"Connection_Point__c\"},\"Name\":\"12345\",\"nmi__c\":\"12345\"},\"derApp\":{\"attributes\":{\"type\":\"DER_Application__c\"},\"Approved_Export_Rating__c\":\"\",\"Existing_Total_Export_Rating__c\":\"\",\"Existing_Total_Inverter_Capacity__c\":\"\",\"Phase_Amount_Available__c\":\"\",\"Approved_Total_Capacity__c\":\"\",\"Import_Existing_Assets__c\":\"\",\"SOP_33_06_Compliant__c\":\"\",\"Ph_C_New_Export__c\":\"2.13\",\"Ph_A_New_Export__c\":0,\"Ph_B_New_Export__c\":\"2.02\",\"Has_Battery__c\":true,\"Has_Solar__c\":true,\"Meter_Number__c\":\"xy123\"}}}';
        string sr4='{"Status\":true,\"Type\":\"Remote Action\",\"ElapsedTime\":1237,\"ElapsedTimeCPU\":477,\"DERRequestPayload\":{\"derCase\":{\"ContactPhone\":\"9123498764\",\"ContactEmail\":\"test@gmail.com\",\"attributes\":{\"type\":\"Case\"},\"Applicant_Email__c\":\"\",\"DER_Application_Scenario__c\":\"Auto\",\"Priority\":\"Low\",\"Origin\":\"Web\",\"Status\":\"Installation Pending\",\"Type\":\"Augmentation\",\"Applicant_Type__c\":\"\",\"Agreement_Type__c\":\"Basic Micro EG MSO\",\"Auto_Applicant_Email__c\":\"\",\"Auto_Applicant_LastName__c\":\"doe\",\"Auto_Applicant_FirstName__c\":\"\"},\"devices\":[{\"attributes\":{\"type\":\"Device__c\"},\"Total_Export\":\"0.69\",\"AC_Equip_Cap__c\":2,\"Total_Capacity\":4,\"Phase\":\"B\",\"Manufacturer__c\":\"ALPHA ESS CO LTF\",\"Model__c\":\"HNS4000TL (AS4777-2 2020)\",\"AC_Equip_Type__c\":\"Solar\",\"CEC_ID__c\":\"INV00007993\",\"DRED_Enabled__c\":\"Yes\",\"Requested__c\":\"true\",\"Approved__c\":\"true\",\"EAI_Parent__c\":\"INV00007993\",\"EAI_Ref__c\":\"INV00007994\",\"EAI_Type__c\":\"Device_L2\",\"AC_Equip_Sub_Type__c\":\"Battery\",\"AC_DC_Coupling__c\":\"AC\",\"Device_Type__c\":\"Battery\",\"SID__c\":null,\"TotallingExport\":1.38}],\"nmi\":{\"attributes\":{\"type\":\"Connection_Point__c\"},\"Name\":\"12345\",\"nmi__c\":\"12345\"},\"derApp\":{\"attributes\":{\"type\":\"DER_Application__c\"},\"Approved_Export_Rating__c\":\"\",\"Existing_Total_Export_Rating__c\":\"\",\"Existing_Total_Inverter_Capacity__c\":\"\",\"Phase_Amount_Available__c\":\"\",\"Approved_Total_Capacity__c\":\"\",\"Import_Existing_Assets__c\":\"\",\"SOP_33_06_Compliant__c\":\"\",\"Ph_C_New_Export__c\":\"2.13\",\"Ph_A_New_Export__c\":0,\"Ph_B_New_Export__c\":\"2.02\",\"Has_Battery__c\":true,\"Has_Solar__c\":true,\"Meter_Number__c\":\"xy123\"}}}';
        string sr5='{"Status\":true,\"Type\":\"Remote Action\",\"ElapsedTime\":1237,\"ElapsedTimeCPU\":477,\"DERRequestPayload\":{\"derCase\":{\"ContactPhone\":\"9123498764\",\"ContactEmail\":\"test@gmail.com\",\"attributes\":{\"type\":\"Case\"},\"Applicant_Email__c\":\"\",\"DER_Application_Scenario__c\":\"Auto\",\"Priority\":\"Low\",\"Origin\":\"Web\",\"Status\":\"Installation Pending\",\"Type\":\"Augmentation\",\"Applicant_Type__c\":\"\",\"Agreement_Type__c\":\"Basic Micro EG MSO\",\"Auto_Applicant_Email__c\":\"\",\"Auto_Applicant_LastName__c\":\"doe\",\"Auto_Applicant_FirstName__c\":\"\"},\"devices\":[{\"attributes\":{\"type\":\"Device__c\"},\"Total_Export\":\"0.69\",\"AC_Equip_Cap__c\":2,\"Total_Capacity\":4,\"Phase\":\"B\",\"Manufacturer__c\":\"ALPHA ESS CO LTF\",\"Model__c\":\"HNS4000TL (AS4777-2 2020)\",\"AC_Equip_Sub_Type__c\":\"Battery\",\"AC_DC_Coupling__c\":\"AC\",\"AC_Equip_Type__c\":\"Solar\",\"CEC_ID__c\":\"INV00007993\",\"DRED_Enabled__c\":\"Yes\",\"Requested__c\":\"true\",\"Approved__c\":\"true\",\"EAI_Parent__c\":null,\"EAI_Ref__c\":\"INV00007993\",\"EAI_Type__c\":\"Device_L2\",\"SID__c\":null,\"TotallingExport\":1.38},{\"attributes\":{\"type\":\"Device__c\"},\"Total_Export\":\"0.69\",\"AC_Equip_Cap__c\":2,\"Total_Capacity\":4,\"Phase\":\"B\",\"Manufacturer__c\":\"ALPHA ESS CO LTF\",\"Model__c\":\"HNS4000TL (AS4777-2 2020)\",\"AC_Equip_Type__c\":\"Solar\",\"CEC_ID__c\":\"INV00007993\",\"DRED_Enabled__c\":\"Yes\",\"Requested__c\":\"true\",\"Approved__c\":\"true\",\"EAI_Parent__c\":\"INV00007993\",\"EAI_Ref__c\":\"INV00007993\",\"EAI_Type__c\":\"Device_L3\",\"AC_Equip_Sub_Type__c\":\"Battery\",\"AC_DC_Coupling__c\":\"AC\",\"Device_Type__c\":\"Battery\",\"SID__c\":null,\"TotallingExport\":1.38}],\"nmi\":{\"attributes\":{\"type\":\"Connection_Point__c\"},\"Name\":\"12345\",\"nmi__c\":\"12345\"},\"derApp\":{\"attributes\":{\"type\":\"DER_Application__c\"},\"Approved_Export_Rating__c\":\"\",\"Existing_Total_Export_Rating__c\":\"\",\"Existing_Total_Inverter_Capacity__c\":\"\",\"Phase_Amount_Available__c\":\"\",\"Approved_Total_Capacity__c\":\"\",\"Import_Existing_Assets__c\":\"\",\"SOP_33_06_Compliant__c\":\"\",\"Ph_C_New_Export__c\":\"2.13\",\"Ph_A_New_Export__c\":0,\"Ph_B_New_Export__c\":\"2.02\",\"Has_Battery__c\":true,\"Has_Solar__c\":true,\"Meter_Number__c\":\"xy123\"}}}';
        string sr6='{"Status\":true,\"Type\":\"Remote Action\",\"ElapsedTime\":1237,\"ElapsedTimeCPU\":477,\"DERRequestPayload\":{\"derCase\":{\"ContactPhone\":\"9123498764\",\"ContactEmail\":\"test@gmail.com\",\"attributes\":{\"type\":\"Case\"},\"Applicant_Email__c\":\"\",\"DER_Application_Scenario__c\":\"Auto\",\"Priority\":\"Low\",\"Origin\":\"Web\",\"Status\":\"Installation Pending\",\"Type\":\"Augmentation\",\"Applicant_Type__c\":\"\",\"Agreement_Type__c\":\"Basic Micro EG MSO\",\"Auto_Applicant_Email__c\":\"\",\"Auto_Applicant_LastName__c\":\"doe\",\"Auto_Applicant_FirstName__c\":\"\"},\"devices\":[{\"attributes\":{\"type\":\"Device__c\"},\"Total_Export\":\"0.69\",\"AC_Equip_Cap__c\":2,\"Total_Capacity\":4,\"Phase\":\"B\",\"Manufacturer__c\":\"ALPHA ESS CO LTF\",\"Model__c\":\"HNS4000TL (AS4777-2 2020)\",\"AC_Equip_Sub_Type__c\":\"Battery\",\"AC_DC_Coupling__c\":\"AC\",\"AC_Equip_Type__c\":\"Solar\",\"CEC_ID__c\":\"INV00007993\",\"DRED_Enabled__c\":\"Yes\",\"Requested__c\":\"true\",\"Approved__c\":\"true\",\"EAI_Parent__c\":null,\"EAI_Ref__c\":\"INV00007993\",\"EAI_Type__c\":\"Device\",\"SID__c\":null,\"TotallingExport\":1.38}],\"nmi\":{\"attributes\":{\"type\":\"Connection_Point__c\"},\"Name\":\"12345\",\"nmi__c\":\"12345\"},\"derApp\":{\"attributes\":{\"type\":\"DER_Application__c\"},\"Approved_Export_Rating__c\":\"\",\"Existing_Total_Export_Rating__c\":\"\",\"Existing_Total_Inverter_Capacity__c\":\"\",\"Phase_Amount_Available__c\":\"\",\"Approved_Total_Capacity__c\":\"\",\"Import_Existing_Assets__c\":\"\",\"SOP_33_06_Compliant__c\":\"\",\"Ph_C_New_Export__c\":\"2.13\",\"Ph_A_New_Export__c\":0,\"Ph_B_New_Export__c\":\"2.02\",\"Has_Battery__c\":true,\"Has_Solar__c\":true,\"Meter_Number__c\":\"xy123\"}}}';
        string sr7='{"Status\":true,\"Type\":\"Remote Action\",\"ElapsedTime\":1237,\"ElapsedTimeCPU\":477,\"DERRequestPayload\":{\"derCase\":{\"ContactPhone\":\"9123498764\",\"ContactEmail\":\"test@gmail.com\",\"attributes\":{\"type\":\"Case\"},\"Applicant_Email__c\":\"\",\"DER_Application_Scenario__c\":\"Auto\",\"Priority\":\"Low\",\"Origin\":\"Web\",\"Status\":\"Installation Pending\",\"Type\":\"Augmentation\",\"Applicant_Type__c\":\"\",\"Agreement_Type__c\":\"Basic Micro EG MSO\",\"Auto_Applicant_Email__c\":\"\",\"Auto_Applicant_LastName__c\":\"doe\",\"Auto_Applicant_FirstName__c\":\"\"},\"devices\":[{\"attributes\":{\"type\":\"Device__c\"},\"Total_Export\":\"0.69\",\"AC_Equip_Cap__c\":2,\"Total_Capacity\":4,\"Phase\":\"B\",\"Manufacturer__c\":\"ALPHA ESS CO LTF\",\"Model__c\":\"HNS4000TL (AS4777-2 2020)\",\"AC_Equip_Sub_Type__c\":\"Battery\",\"AC_DC_Coupling__c\":\"AC\",\"AC_Equip_Type__c\":\"Solar\",\"CEC_ID__c\":\"INV00007993\",\"DRED_Enabled__c\":\"Yes\",\"Requested__c\":\"true\",\"Approved__c\":\"true\",\"EAI_Parent__c\":null,\"EAI_Ref__c\":\"INV00007993\",\"EAI_Type__c\":\"Device_L2\",\"SID__c\":null,\"TotallingExport\":1.38},{\"attributes\":{\"type\":\"Device__c\"},\"Total_Export\":\"0.69\",\"AC_Equip_Cap__c\":2,\"Total_Capacity\":4,\"Phase\":\"B\",\"Manufacturer__c\":\"ALPHA ESS CO LTF\",\"Model__c\":\"HNS4000TL (AS4777-2 2020)\",\"AC_Equip_Type__c\":\"Solar\",\"CEC_ID__c\":\"INV00007993\",\"DRED_Enabled__c\":\"Yes\",\"Requested__c\":\"true\",\"Approved__c\":\"true\",\"EAI_Parent__c\":\"INV00007993\",\"EAI_Ref__c\":\"INV00007993\",\"EAI_Type__c\":\"Device_L3\",\"AC_Equip_Sub_Type__c\":\"Battery\",\"AC_DC_Coupling__c\":\"AC\",\"Device_Type__c\":\"Battery\",\"SID__c\":null,\"TotallingExport\":1.38}],\"nmi\":{\"attributes\":{\"type\":\"Connection_Point__c\"},\"Name\":\"12345\",\"nmi__c\":\"12345\"},\"derApp\":{\"attributes\":{\"type\":\"DER_Application__c\"},\"Approved_Export_Rating__c\":\"\",\"Existing_Total_Export_Rating__c\":\"\",\"Existing_Total_Inverter_Capacity__c\":\"\",\"Phase_Amount_Available__c\":\"\",\"Approved_Total_Capacity__c\":\"\",\"Import_Existing_Assets__c\":\"\",\"SOP_33_06_Compliant__c\":\"\",\"Ph_C_New_Export__c\":\"2.13\",\"Ph_A_New_Export__c\":0,\"Ph_B_New_Export__c\":\"2.02\",\"Has_Battery__c\":true,\"Has_Solar__c\":true,\"Meter_Number__c\":\"xy123\"}}}';
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(sr.body.toString());
        n=(Map<String, Object>) JSON.deserializeUntyped(sr1);
        o=(Map<String, Object>) JSON.deserializeUntyped(sr2);
        p=(Map<String, Object>) JSON.deserializeUntyped(sr3);
        q=(Map<String, Object>) JSON.deserializeUntyped(sr4);
        r=(Map<String, Object>) JSON.deserializeUntyped(sr5);
        t=(Map<String, Object>) JSON.deserializeUntyped(sr6);
         s=(Map<String, Object>) JSON.deserializeUntyped(sr7);

        system.debug('map value####'+m.containsKey('DERRequestPayload'));
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        FnP_SolarFormUtility fnpObject=new FnP_SolarFormUtility();
        
        Boolean result=fnpObject.invokeMethod('createDERApplication',m, outputMap, options);
        Boolean result1=fnpObject.invokeMethod('createDERApplication',n, outputMap, options);
        Boolean result2=fnpObject.invokeMethod('createDERApplication',o, outputMap, options);
        //Boolean result3=fnpObject.invokeMethod('createDERApplication',p, outputMap, options);
//        Boolean result4=fnpObject.invokeMethod('createDERApplication',q, outputMap, options);
//         Boolean result5=fnpObject.invokeMethod('createDERApplication',r, outputMap, options);
//         Boolean result6=fnpObject.invokeMethod('createDERApplication',t, outputMap, options);
//         Boolean result7=fnpObject.invokeMethod('createDERApplication',s, outputMap, options);
        Test.stopTest();
    }
    @IsTest
    public static void test_createDERApplicationManual(){
        Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
         Map<String, Object> n;
        Map<String, Object> m1;
        string srr='{"Status\":true,\"Type\":\"RemoteAction\",\"ElapsedTime\":1237,\"ElapsedTimeCPU\":477,\"DERRequestPayload\":{\"nmi\":{\"attributes\":{\"type\":\"Connection_Point__c\"},\"Name\":\"12345\"}}}';
        string sr1='{"Status\":true,\"Type\":\"RemoteAction\",\"ElapsedTime\":1237,\"ElapsedTimeCPU\":477,\"DERRequestPayload\":{\"AuthorisedContact\":{\"Email\":\"\",\"LastName\":\"Doe\",\"attributes\":{\"type\":\"Contact\"},\"FirstName\":\"\"},\"CustomerContact\":{\"Email\":\"test@ausnet.com\",\"LastName\":\"Doe\",\"attributes\":{\"type\":\"Contact\"},\"FirstName\":\"John\"},\"Type_ExistingSystem__c\":\"\",\"Volt_Rise_Max_PV_Output__c\":\"\",\"Power_Factor__c\":\"\",\"Primary_Contact__C\":\"\",\"AuthorisedRepresentative\":{\"attributes\":{\"type\":\"Account\"},\"Authorised_BillingStreetAddress__c\":\"\",\"Authorised_Billingarea2__c\":\"\",\"Authorised_BillingSuburb__c\":\"\",\"Authorised_BillingState__c\":\"\",\"Authorised_BillingPostalCode__c\":\"\",\"Authorised_ABN__c\":\"\",\"Authorised_CompanyName__c\":\"\",\"Authorised_ContactNumber__c\":\"\",\"Authorised_Email__c\":\"\",\"Authorised_LastName__c\":\"\",\"Authorised_FirstName__c\":\"\"},\"Application_Number__c\":\"\",\"Responsible_Party__c\":\"\",\"Wireless_Model__c\":\"\",\"Wireless_Manufacturer__c\":\"\",\"Signal_Loss_Max_Operate__c\":\"\",\"Signal_Loss_Max_Detect__c\":\"\",\"Signal_Loss_Action_Open_PV_Replay__c\":\"\",\"Protect_Relay_Model__c\":\"\",\"Protect_Relay_Manufacturer__c\":\"\",\"Protect_Relay_Make_Series__c\":\"\",\"Protect_Relay_Location__c\":\"\",\"Protect_Relay_Comm_Method__c\":\"\",\"Islandable_Installation__c\":\"\",\"Acceditation_Type__c\":\"\",\"installerContact\":{\"attributes\":{\"type\":\"Contact\"},\"Email\":\"john.doe@ausnetservices.com.au\",\"FirstName\":\"\",\"LastName\":\"doe\"},\"derCase\":{\"ContactPhone\":\"9123498764\",\"ContactEmail\":\"test@gmail.com\",\"attributes\":{\"type\":\"Case\"},\"Applicant_Email__c\":\"\",\"DER_Application_Scenario__c\":\"Auto\",\"Priority\":\"Low\",\"Origin\":\"Web\",\"Status\":\"InstallationPending\",\"Type\":\"Augmentation\",\"Applicant_Type__c\":\"\",\"Agreement_Type__c\":\"BasicMicroEGMSO\",\"Auto_Applicant_Email__c\":\"\",\"Auto_Applicant_LastName__c\":\"\",\"Auto_Applicant_FirstName__c\":\"\"},\"installer\":{\"Installer_Comapny_Subburb__c\":\"\",\"attributes\":{\"type\":\"Account\"},\"Installer_CompanyName__c\":\"\",\"Installer_LastName__c\":\"\",\"Installer_FirstName__c\":\"\",\"Installer_Email__c\":\"\",\"Installer_ContactPhone__c\":\"\",\"CompanyPostalCode\":\"\",\"CompanyState\":\"\",\"CompanyCity\":\"\",\"CompanyStreet\":\"\",\"Name\":\"\"},\"devices\":[{\"attributes\":{\"type\":\"Device__c\"},\"Total_Export\":\"0.69\",\"AC_Equip_Cap__c\":2,\"Total_Capacity\":4,\"Phase\":\"B\",\"Manufacturer__c\":\"ALPHAESSCOLTF\",\"Model__c\":\"HNS4000TL(AS4777-22020)\",\"AC_Equip_Sub_Type__c\":\"Battery\",\"AC_DC_Coupling__c\":\"AC\",\"AC_Equip_Type__c\":\"Solar\",\"CEC_ID__c\":\"INV00007993\",\"DRED_Enabled__c\":\"Yes\",\"Requested__c\":\"true\",\"Approved__c\":\"true\",\"EAI_Parent__c\":null,\"EAI_Ref__c\":\"INV00007993\",\"EAI_Type__c\":\"Device_L2\",\"SID__c\":null,\"TotallingExport\":1.38},{\"attributes\":{\"type\":\"Device__c\"},\"Total_Export\":\"0.69\",\"AC_Equip_Cap__c\":2,\"Total_Capacity\":4,\"Phase\":\"B\",\"Manufacturer__c\":\"ALPHAESSCOLTF\",\"Model__c\":\"HNS4000TL(AS4777-22020)\",\"AC_Equip_Type__c\":\"Solar\",\"CEC_ID__c\":\"INV00007993\",\"DRED_Enabled__c\":\"Yes\",\"Requested__c\":\"true\",\"Approved__c\":\"true\",\"EAI_Parent__c\":\"INV00007993\",\"EAI_Ref__c\":\"INV00007994\",\"EAI_Type__c\":\"Device_L3\",\"AC_Equip_Sub_Type__c\":\"Battery\",\"AC_DC_Coupling__c\":\"AC\",\"AC_Equip_Type__c\":\"Solar\",\"Device_Type__c\":\"Battery\",\"SID__c\":null,\"TotallingExport\":1.38}],\"SDevices\":[{\"TotallingExport\":1.08,\"SID__c\":\"SID__c\",\"EAI_Type__c\":\"Device_L2\",\"EAI_Ref__c\":\"INV00008913\",\"EAI_Parent__c\":\"INV00008913\",\"Approved__c\":\"true\",\"Requested__c\":\"true\",\"DRED_Enabled__c\":\"Yes\",\"CEC_ID__c\":\"INV00008913\",\"AC_Equip_Type__c\":\"Battery\",\"Model__c\":\"HNS4000TL(AS4777-22020)\",\"Manufacturer__c\":\"CSISOLARCOLTD\",\"Phase\":\"C\",\"Total_Capacity\":3,\"AC_Equip_Cap__c\":1,\"Total_Export\":\"0.36\"},{\"TotallingExport\":0.64,\"SID__c\":\"SID__c\",\"EAI_Type__c\":\"Device_L2\",\"EAI_Ref__c\":\"INV00007914\",\"EAI_Parent__c\":\"INV00007914\",\"Approved__c\":\"true\",\"Requested__c\":\"true\",\"DRED_Enabled__c\":\"Yes\",\"CEC_ID__c\":\"INV00007914\",\"AC_Equip_Type__c\":\"Battery\",\"Model__c\":\"HNS3000TL(AS4777-22020)\",\"Manufacturer__c\":\"AISWEINEWENERGYTECHNOLOGY(JIANGSU)COLTD\",\"Phase\":\"B\",\"Total_Capacity\":7,\"AC_Equip_Cap__c\":7,\"Total_Export\":\"0.64\"}],\"BDevices\":[{\"TotallingExport\":1.38,\"SID__c\":null,\"EAI_Type__c\":\"Device_L2\",\"EAI_Ref__c\":\"INV00007993\",\"EAI_Parent__c\":\"INV00007993\",\"Approved__c\":\"true\",\"Requested__c\":\"true\",\"DRED_Enabled__c\":\"Yes\",\"CEC_ID__c\":\"INV00007993\",\"AC_Equip_Type__c\":\"Solar\",\"Model__c\":\"HNS4000TL(AS4777-22020)\",\"Manufacturer__c\":\"ALPHAESSCOLTF\",\"Phase\":\"B\",\"Total_Capacity\":4,\"AC_Equip_Cap__c\":2,\"Total_Export\":\"0.69\"},{\"TotallingExport\":1.05,\"SID__c\":\"SID__c\",\"EAI_Type__c\":\"Device_L2\",\"EAI_Ref__c\":\"INV00007913\",\"EAI_Parent__c\":\"INV00007913\",\"Approved__c\":\"true\",\"Requested__c\":\"true\",\"DRED_Enabled__c\":\"Yes\",\"CEC_ID__c\":\"INV00007913\",\"AC_Equip_Type__c\":\"Battery\",\"Model__c\":\"HYD4000-ES\",\"Manufacturer__c\":\"ShenzhenSOFARSOLARCoLtd\",\"Phase\":\"C\",\"Total_Capacity\":8,\"AC_Equip_Cap__c\":8,\"Total_Export\":\"1.05\"}],\"nmi\":{\"attributes\":{\"type\":\"Connection_Point__c\"},\"Name\":\"12345\"},\"derApp\":{\"attributes\":{\"type\":\"DER_Application__c\"},\"Approved_Export_Rating__c\":\"\",\"Existing_Total_Export_Rating__c\":\"\",\"Existing_Total_Inverter_Capacity__c\":\"\",\"Phase_Amount_Available__c\":\"\",\"Approved_Total_Capacity__c\":\"\",\"Import_Existing_Assets__c\":\"\",\"SOP_33_06_Compliant__c\":\"\",\"Ph_C_New_Export__c\":\"2.13\",\"Ph_A_New_Export__c\":0,\"Ph_B_New_Export__c\":\"2.02\",\"Has_Battery__c\":true,\"Has_Solar__c\":true,\"Meter_Number__c\":\"xy12\"}}}"';
        
        m1 = (Map<String, Object>) JSON.deserializeUntyped(srr);        
        n = (Map<String, Object>) JSON.deserializeUntyped(sr1);
        
        StaticResource srNull = [SELECT Id, Body FROM StaticResource WHERE Name = 'CreateDERNMINULL' LIMIT 1];
        Map<String, Object> mNull = (Map<String, Object>) JSON.deserializeUntyped(srNull.body.toString());
       
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DERAPPCreateSOlarFormManual' LIMIT 1];
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(sr.body.toString());
        system.debug('map value####'+m.containsKey('DERRequestPayload'));
        Map<String,Object> inputMap=new Map<String,Object>();
        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        FnP_SolarFormUtility fnpObject=new FnP_SolarFormUtility();
        
        Boolean result=fnpObject.invokeMethod('createDERApplication',m, outputMap, options);
        Boolean resullt=fnpObject.invokeMethod('createDERApplication',mNull, outputMap, options);
        Boolean resultt=fnpObject.invokeMethod('createDERApplication',m1, outputMap, options);
        Boolean result1=fnpObject.invokeMethod('createDERApplication',n, outputMap, options);
        
        Test.stopTest();
    }
    
    @IsTest
    public static void test_updateDERApplicationAuto(){
        Test.startTest();        
        Case c = new Case();
        c.origin = 'Web';
        c.DER_Application_Scenario__c = 'Auto';
        insert c;
        
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DERAPPCreateSOlarForm' LIMIT 1];
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(sr.body.toString());
        system.debug('map value####'+m.containsKey('DERRequestPayload'));
        Connection_Point__c nmi = new Connection_Point__c();
        insert nmi;
        
        DER_Application__c der = new DER_Application__c();
        der.NMI__c = nmi.Id;
        insert der;
        if(m.containsKey('DERRequestPayload')){
            Map<String, Object> DERRequestPayload = (Map<String, Object>)m.get('DERRequestPayload');
            if(DERRequestPayload.containskey('derCase')){
                Map<String, Object> derCase = (Map<String, Object>)DERRequestPayload.get('derCase');
                derCase.put('Id', c.Id);
            }
            if(DERRequestPayload.containskey('derApp')){
                Map<String, Object> derApp = (Map<String, Object>)DERRequestPayload.get('derApp');
                derApp.put('Id', der.Id);
            }
            if(DERRequestPayload.containskey('nmi')){
                Map<String, Object> nmiMap = (Map<String, Object>)DERRequestPayload.get('nmi');
                nmiMap.put('Id', nmi.Id);
            }
            if(DERRequestPayload.containskey('installer')){
                Map<String, Object> installer = (Map<String, Object>)DERRequestPayload.get('installer');
                installer.put('ABN__c', '1234567890');
                installer.put('Name', 'TestFirst TestLast');
                installer.put('Installer_FirstName__c', 'TestFirst');
                installer.put('Installer_LastName__c', 'TestLast');
            }
            if(DERRequestPayload.containskey('installerContact')){
                Map<String, Object> installer = (Map<String, Object>)DERRequestPayload.get('installerContact');
                installer.put('Accreditation_Number__c', '1y34567890twe');
                installer.put('Acceditation_Type__c', 'CEC');
            }
            
        }        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        FnP_SolarFormUtility fnpObject=new FnP_SolarFormUtility();        
        Boolean result1=fnpObject.invokeMethod('updateDERApplication',m, outputMap, options);
        Test.stopTest();
    }
    @IsTest
    public static void test_updateDERApplicationManual(){
        Test.startTest();
        
        Account acc = new Account();
        acc.Name='Test1';
        insert acc;
        
        Account representativeCompany = new Account();
        representativeCompany.Name = 'Test Company';
        insert representativeCompany;
        
        Account InstallerCom = new Account();
        InstallerCom.Name = 'Test Company';
        insert InstallerCom;
        
        Contact con = new Contact();
        con.FirstName = 'Jane';
        con.LastName = 'Doe';
        con.AccountId = acc.Id;
        insert con;
        
        Contact InstallerContact = new Contact();
        InstallerContact.FirstName = 'Jane';
        InstallerContact.LastName = 'Doe';
        InstallerContact.AccountId = InstallerCom.Id;
        insert InstallerContact;
        
        Case c = new Case();
        c.origin = 'Web';
        c.DER_Application_Scenario__c = 'Manual';
        insert c;
         StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DERAPPCreateSOlarFormManual' LIMIT 1];
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(sr.body.toString());
        System.debug('serializePretty-->>'+JSON.serializePretty(m));
        system.debug('map value####'+m.containsKey('DERRequestPayload'));
        
        Connection_Point__c nmi = new Connection_Point__c();
        insert nmi;
        
        DER_Application__c der = new DER_Application__c();
        der.NMI__c = nmi.Id;
        insert der;
        if(m.containsKey('DERRequestPayload')){
            Map<String, Object> DERRequestPayload = (Map<String, Object>)m.get('DERRequestPayload');
            if(DERRequestPayload.containskey('derCase')){
                Map<String, Object> derCase = (Map<String, Object>)DERRequestPayload.get('derCase');
                derCase.put('Id', c.Id);
            }
            if(DERRequestPayload.containskey('derApp')){
                Map<String, Object> derApp = (Map<String, Object>)DERRequestPayload.get('derApp');
                derApp.put('Id', der.Id);
            }
            if(DERRequestPayload.containskey('nmi')){
                Map<String, Object> nmiMap = (Map<String, Object>)DERRequestPayload.get('nmi');
                nmiMap.put('Id', nmi.Id);
            }
            if(DERRequestPayload.containskey('installer')){
                Map<String, Object> installer = (Map<String, Object>)DERRequestPayload.get('installer');
                installer.put('ABN__c', '1234567890');
                installer.put('Name', 'TestFirst TestLast');
                installer.put('Installer_FirstName__c', 'TestFirst');
                installer.put('Installer_LastName__c', 'TestLast');
                
            }
            if(DERRequestPayload.containskey('installerContact')){
                Map<String, Object> installer = (Map<String, Object>)DERRequestPayload.get('installerContact');
                installer.put('Accreditation_Number__c', '1y34567890twe');
                installer.put('Acceditation_Type__c', 'CEC');
            }
            if(DERRequestPayload.containskey('Customer')){
                Map<String, Object> Customer = (Map<String, Object>)DERRequestPayload.get('Customer');
                Customer.put('ABN__c', '1234567890');
                Customer.put('Id', acc.Id);
            }
            if(DERRequestPayload.containskey('representative')){
                Map<String, Object> representative = (Map<String, Object>)DERRequestPayload.get('representative');
                representative.put('Id', con.Id);
            }
            if(DERRequestPayload.containskey('representativeCompany')){
                Map<String, Object> representative = (Map<String, Object>)DERRequestPayload.get('representativeCompany');
                representative.put('Id', representativeCompany.Id);
            }
            if(DERRequestPayload.containskey('installer')){
                Map<String, Object> installer = (Map<String, Object>)DERRequestPayload.get('installer');
                installer.put('Id', InstallerCom.Id);
            }
            if(DERRequestPayload.containskey('installerContact')){
                Map<String, Object> installerCont = (Map<String, Object>)DERRequestPayload.get('installerContact');
                installerCont.put('Id', InstallerContact.Id);
            }
        }
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        FnP_SolarFormUtility fnpObject=new FnP_SolarFormUtility();
        
        Boolean result1=fnpObject.invokeMethod('updateDERApplication',m, outputMap, options);
        
        Test.stopTest();
    }
    @IsTest
    public static void test_getDERApplicationDetails(){
        Test.startTest();
        
        Account Acc= new Account();
        Acc.Name = 'TestAccount' ;
        Acc.Customer_Type__c='ELE - CINCL';
        insert Acc;
        
        
        
        Contact con = new contact();
        con.lastname='test1';
        con.Email='test@ausnet.com';
        con.AccountId=Acc.Id;
        insert con;
        
        
        Connection_Point__c cp = new Connection_Point__c();
        cp.NMI_Ref__c='1234';
        cp.NMI__c='1234';
        insert cp;
        
        DER_Application__c derApp = new DER_Application__c();
        derApp.Ph_C_New_Export__c= 2.13;
        derApp.Ph_A_New_Export__c=0;
        derApp.Ph_B_New_Export__c=2.02;
        derApp.Has_Battery__c =true;
        derApp.Has_Solar__c=true;
        derApp.Meter_Number__c='xy123';
        derApp.NMI__c=cp.Id;
        insert derApp;
        
        DER_Agreement__c DerAgree = new DER_Agreement__c();
        DerAgree.DER_Application__c=derApp.Id;
        DerAgree.NMI__c=cp.Id;
        DerAgree.Account__c=Acc.Id;
        insert DerAgree;
        
        
        Case c1= new case();
        c1.Application_Number__c='1234';  c1.Auto_Applicant_Email__c='test@ausnet.com';
        c1.DER_Application__c=derApp.Id;
        c1.AccountId=Acc.Id;
        c1.ContactId=con.Id;
        c1.Representative__c=con.Id;
        insert c1;
        
        Device__c dev1 = new Device__c();
        dev1.AC_Equip_Sub_Type__c='	Battery';
        dev1.AC_Equip_Type__c='Inverter';
        dev1.AC_DC_Coupling__c='AC';
        dev1.DER_Application__c=derApp.Id;
        insert dev1;
        
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DERSolarValidationJson' LIMIT 1];
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(sr.body.toString());
        Map<String,Object> inputMap=new Map<String,Object>();
        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        FnP_SolarFormUtility fnpObject=new FnP_SolarFormUtility();
        List<Case> c= [select ContactEmail,type,Application_Number__c,status from case limit 1];
        
        Boolean result1=fnpObject.invokeMethod('getDERApplicationDetails',m, outputMap, options);
        
        Test.stoptest();
    }
   
     @IsTest(SeeAllData=true)
    public static void test_getDERApplicationDetailselseblock(){
        Test.startTest();
		Map<String, Object> m;
        Map<String, Object> n;
        Map<String, Object> o;

        string sr='{"Status\":true,\"Type\":\"Remote Action\",\"ElapsedTime\":1237,\"ElapsedTimeCPU\":477,\"Validation\":{\"Text_ReferenceNumber\":\"1234\",\"Number_NMI\":1234}}';
	    string sr1='{"Status\":true,\"Type\":\"Remote Action\",\"ElapsedTime\":1237,\"ElapsedTimeCPU\":477,\"Validation\":{\"Text_ReferenceNumber\":\"1234\",\"Email\":\"test@ausnet.com\"}}';
        string sr2='{"Status\":true,\"Type\":\"Remote Action\",\"ElapsedTime\":1237,\"ElapsedTimeCPU\":477,\"Validation\":{\"Number_NMI\":1234,\"Email\":\"test@ausnet.com\"}}'; 
        n= (Map<String, Object>) JSON.deserializeUntyped(sr1);
         m = (Map<String, Object>) JSON.deserializeUntyped(sr);
        o=(Map<String, Object>) JSON.deserializeUntyped(sr2);
        Map<String,Object> inputMap=new Map<String,Object>();
        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        FnP_SolarFormUtility fnpObject=new FnP_SolarFormUtility();
        List<Case> c= [select ContactEmail,type,Application_Number__c,status from case limit 1];
        
        Boolean result1=fnpObject.invokeMethod('getDERApplicationDetails',m, outputMap, options);
         Boolean result2=fnpObject.invokeMethod('getDERApplicationDetails',n, outputMap, options);
		 Boolean result3=fnpObject.invokeMethod('getDERApplicationDetails',o, outputMap, options);

        Test.stoptest();
    }
    
    
    @IsTest
    public static void test_toPopulateInverter(){
        Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
        // Let's first create an auto application
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();            
        
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json;');
        
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DtoPopulateInverter' LIMIT 1];
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(sr.body.toString());
        Map<String,Object> inputMap=new Map<String,Object>();
        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        FnP_SolarFormUtility fnpObject=new FnP_SolarFormUtility();
        
        
        Boolean result1=fnpObject.invokeMethod('toPopulateInverter',m, outputMap, options);
        
        Test.stoptest();
    }
    
    
    @IsTest
    public static void test_toMergeInverterLists(){
        Test.startTest();
        User testUser = UtilDatabase_Test.getTestUser();
        // Let's first create an auto application
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();            
        
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json;');
        
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DERtoMergeInverterListsJson' LIMIT 1];
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(sr.body.toString());
        Map<String,Object> inputMap=new Map<String,Object>();
        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        FnP_SolarFormUtility fnpObject=new FnP_SolarFormUtility();
        
        
        Boolean result1=fnpObject.invokeMethod('toMergeInverterLists',m, outputMap, options);
        
        Test.stoptest();
    }
    
@isTest(SeeAllData=true)
    public static void test_validateNMIandMeterNum(){
        Test.startTest();
         
        Test.setMock(HttpCalloutMock.class, new RestMock());
        User testUser = UtilDatabase_Test.getTestUser();
        // Let's first create an auto application
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();            
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json;');
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'DERSolarValidationJson' LIMIT 1];
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(sr.body.toString());
        Map<String,Object> inputMap=new Map<String,Object>();
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        FnP_SolarFormUtility fnpObject=new FnP_SolarFormUtility();
        Boolean result1=fnpObject.invokeMethod('validateNMIandMeterNum',m, outputMap, options);
       
        //Boolean result1=fnpObject.invokeMethod('validateNMIandMeterNum',m, null, null);
        
        Test.stopTest();
    }
    
    
 @IsTest
public static void test_Methods(){

string nmiNum='12345';
string email='test@asunet.com';
string ABN='abn';
String accNum='';
String accType=''; 
boolean isUpdate= true;
Test.startTest();

FnP_SolarFormUtility.findConPoint(nmiNum);
FnP_SolarFormUtility.findRep(email);
FnP_SolarFormUtility.findServProvider(ABN);
FnP_SolarFormUtility.findInstallerContact(accNum,accType,email);
case cs = new case();
FnP_SolarFormUtility.runDeviceRollup(cs);
FnP_SolarFormUtility.getDefaultCaseQueueOwner(cs);
Connection_Point__c cp = new Connection_Point__c();
cp.NMI__c = '123456';
insert cp;
FnP_SolarFormUtility.insertCase(cs);
account acc= new account();
acc.name='test';
insert acc;
contact con= new contact();
con.lastname='testcon';
con.AccountId= acc.Id;
insert con;
FnP_SolarFormUtility.linkAccWithContact(acc.Id,con.Id);
FnP_SolarFormUtility.insertUpdateNMI(cp,isUpdate);
Test.stopTest();
}

   
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {  //'+meterNum+'
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json;charset=UTF-8');
            res.setHeader('Accept', 'application/json');
            res.setBody('{"Response" : {"getbody":" "}}');
            res.setStatus('OK');
            res.setStatusCode(200);
            return res;
        }
    }
    
    
   
}