global class FnP_SolarFormUtility implements vlocity_cmt.VlocityOpenInterface {
    public virtual class DERApplicationAPIException extends Exception{}
    public static String ACCOUNT_RECORDTYPE_BUSINESS        = 'Customer_Business';
    public static String ACCOUNT_RECORDTYPE_INDIVIDUAL      = 'Customer_Individual';
    public static String ACCOUNT_RECORDTYPE_SERVICEPROVIDER = 'Service_Provider';
    public static String CASE_RECORDTYPE_AUTO               = 'DER_App_Auto';
    public static String CASE_RECORDTYPE_MANUAL             = 'DER_App_Manual';
    public static String CASE_SCENARIO_AUTO                 = 'Auto';
    public static String CASE_SCENARIO_MANUAL               = 'Manual';
    public static String CASE_STATUS_INST_PENDING           = 'Installation Pending';
    
    public static String CASE_STATUS_INST_VALIDATION        = 'Installation Validation';
    public static String CASE_DEFAULT_QUEUE_AUTO            = 'DER Apps - Hold/Wait';
    public static String CASE_DEFAULT_QUEUE_MANUAL          = 'DER Apps - New Conns';
    public static Set<String> ACCOUNT_SERVICEPROVIDER_TYPES = new Set<String>{'Installer', 'Representative'};
    public static Set<String> CONTACT_REP_TITLES            = new Set<String>{'Application Representative', 'Customer Representative'};
    public static String CASE_STATUS_NEW                    = 'New'; 
   
    global Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        Boolean result = true;
        try
        {
            if (methodName.equals('getInverters')){
                getInverters(inputMap,outMap,options);
            }
            
            else if(methodName.equals('createDERApplication')){
                result = createDERApplication(inputMap,outMap,options);
                System.debug('Success log in invoke method');
                // DCE-2747
                if(result){
                    // Duplicate log, may not be needed. check once.
                    String caseId = null;
                    if(outMap.containsKey('storeCaseId')){
                        Map<String,Object>storeCaseId=((Map<String, Object>)outMap.get('storeCaseId'));
                        caseId = (String)storeCaseId.get('caseId');
                    }
                    FnP_ExtUserObjAccessUtility.integrationLogSuccess(caseId,JSON.serialize(outMap),'SolarFormRecordType',methodName,JSON.serialize(inputMap),'Create');
                }
            }
            else if(methodName.equals('validateNMIandMeterNum')){
                validateNMIandMeterNum(inputMap,outMap,options);
            }
            else if(methodName.equals('getDERApplicationDetails')){  
                getDERApplicationDetails(inputMap,outMap,options);
            }
            else if(methodName.equals('updateDERApplication')){  
                result = updateDERApplication(inputMap,outMap,options);
                System.debug('Success log in invoke method');
            	// DCE-2747
                if(result )
                    FnP_ExtUserObjAccessUtility.integrationLogSuccess(null,JSON.serialize(outMap),'SolarFormRecordType',methodName,JSON.serialize(inputMap),'Create');
    
				}
            else if(methodName.equals('toPopulateInverter')){
                toPopulateInverter(inputMap,outMap,options);
            }
            else if(methodName.equals('toMergeInverterLists')){
                toMergeInverterLists(inputMap,outMap,options);
            }
            
        }
        catch(Exception excep)
        {
            System.debug('FnP_SolarFormUtility:invokeMethod -> exception: '+excep);
            System.debug('linenumber -> exception: '+excep.getLinenumber());
			FnP_ExtUserObjAccessUtility.integrationlog(excep.getMessage()+' '+excep.getStackTraceString()+' '+excep.getLineNumber(),'SolarFormRecordType',methodName,JSON.serialize(inputMap),null);
            outMap.put('DMLError',excep.getMessage()+' '+excep.getStackTraceString()+' '+excep.getLineNumber()); 
           // throw excep;
        }
        // DCE-2747
		if(result){
            outMap.put('DMLError', null);
            }
        else{
            outMap.put('DMLError','UnknownError Occurred');
        }
        return result;
    }

    global void toPopulateInverter(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        try {
            Map<String,Object> DERApplication = new Map<String,Object>();
            Map<String,Object> DERApplication2 = new Map<String,Object>();
            Map<String,Object> devicesone = new Map<String,Object>();
            List<Object> devices = new List<Object>();
            List<Map<String,Object>> solardevices = new List<Map<String,Object>>();
            List<Map<String,Object>> batterydevices = new List<Map<String,Object>>();
            List<Map<String,Object>> nulldevices = new List<Map<String,Object>>();
            List<Map<String,Object>> nulldevicesList;
            List<Map<String,Object>> nulldevicesListBattery;
            Double count;
            Double cap;
            Double multiply;
            System.debug('inputmap:::'+inputmap);
            DERApplication=(Map<String,Object>)inputMap.get('DERApplication');
            DERApplication2=(Map<String,Object>)DERApplication.get('DERApplication');
            devices=(List<Object>)DERApplication2.get('devices');
        
            string stringifyDevices = JSON.serialize(devices);
            List<Object> deviceList =(List<Object>)JSON.deserializeUntyped(stringifyDevices);
        
            System.debug('deviceList'+deviceList);
// DCE-2746
            //            System.debug('check'+deviceList.size());
        if(deviceList != null)
        {
            for(Object device : deviceList) {
                Map<String,Object> datacheck = (Map<String,Object>)device;
                System.debug('mapdatacheck'+datacheck.get('AC_Equip_Sub_Type__c'));
                //devicesone.put('SID__c',datacheck.get('SID__c'));
                devicesone.put('EAI_Type__c',datacheck.get('EAI_Type__c'));
                devicesone.put('EAI_Ref__c',datacheck.get('EAI_Ref__c'));
                devicesone.put('Approved__c',datacheck.get('Approved__c'));
                devicesone.put('Requested__c',datacheck.get('Requested__c'));
                devicesone.put('DRED_Enabled__c',datacheck.get('DRED_Enabled__c'));
                devicesone.put('CEC_ID__c',datacheck.get('CEC_ID__c'));
                devicesone.put('AC_Equip_Sub_Type__c',datacheck.get('AC_Equip_Sub_Type__c'));
                devicesone.put('AC_Equip_Type__c',datacheck.get('AC_Equip_Type__c'));
                devicesone.put('AC_Equip_Cap__c',datacheck.get('AC_Equip_Cap__c'));
                devicesone.put('Model__c',datacheck.get('Model__c'));
                devicesone.put('Manufacturer__c',datacheck.get('Manufacturer__c'));
                devicesone.put('InverterId',datacheck.get('InverterId'));
                devicesone.put('Device_Count__c',datacheck.get('Device_Count__c'));
                devicesone.put('Device_Phase__c',datacheck.get('Device_Phase__c'));
                devicesone.put('AC_DC_Coupling__c',datacheck.get('AC_DC_Coupling__c'));
                devicesone.put('Device_Type__c',datacheck.get('Device_Type__c'));
                devicesone.put('Id',datacheck.get('Id'));
                
                if(devicesone.get('Device_Count__c') != null && devicesone.get('AC_Equip_Cap__c') != null) {
                    count=(Double)devicesone.get('Device_Count__c');
                    system.debug('count'+count);
                    cap=(Double)devicesone.get('AC_Equip_Cap__c');
                    system.debug('cap'+cap);
                    multiply=count*cap;
                }

                devicesone.put('Total_Capacity',multiply);

                if(datacheck.get('AC_Equip_Sub_Type__c') == 'Solar') {
                    solardevices.add(devicesone); 
                }
                else if(datacheck.get('AC_Equip_Sub_Type__c') == 'Battery'){
                    batterydevices.add(devicesone);
                }
                else if(datacheck.get('AC_Equip_Sub_Type__c') == Null){// These are solar panels or battery inverters..
                    devicesone.put('EAI_Parent__c',datacheck.get('EAI_Parent__c'));
                    devicesone.put('Device_Sub_Type__c',datacheck.get('Device_Sub_Type__c'));
                    devicesone.put('Device_Type__c',datacheck.get('Device_Type__c'));
                    devicesone.put('Nominal_Rated_Cap__c',datacheck.get('Nominal_Rated_Cap__c'));
                    devicesone.put('Nominal_Storage_Cap__c',datacheck.get('Nominal_Storage_Cap__c'));
                    nulldevices.add(devicesone);
                    system.debug('nulldevices'+nulldevices);
                }

                devicesone = new Map<String, Object>();
            }         
        
            for(Map<String,Object> obj :solardevices) {
                system.debug('objsolar'+obj);
                nulldevicesList=new List<Map<String,Object>>();
                for(Map<String,Object> objone :nulldevices){
                    if(objone.get('EAI_Parent__c') == obj.get('EAI_Ref__c')){
                        nulldevicesList.add(objone);
                        system.debug('nulldevicesList' +nulldevicesList);
                    }
                }
                // Add the node only if solar panels are present.
                if(nulldevicesList!=null && !nulldevicesList.isEmpty())  
                { obj.put('Block_SolarPanel',nulldevicesList);
                	outMap.put('SPDeviceSize', nulldevicesList.size());
                }      
                else{
                    outMap.put('SPDeviceSize', 0);
                }
            }

            for(Map<String,Object> objtwo :batterydevices) {
            
                nulldevicesListBattery = new List<Map<String,Object>>();
                for(Map<String,Object> objthree :nulldevices) {
                    if(objthree.get('EAI_Parent__c') == objtwo.get('EAI_Ref__c')){
                        nulldevicesListBattery.add(objthree);
                    }
                }
            
                if(nulldevicesListBattery!=null && !nulldevicesListBattery.isEmpty()){
                	objtwo.put('Block_InverterBatteryDetails',nulldevicesListBattery); 
                    outMap.put('IBDeviceSize', nulldevicesListBattery.size());
                }   
                else{
                    outMap.put('IBDeviceSize', 0);
                }
            }
        }
            if(solardevices!=null && !solardevices.isEmpty()) {
                outMap.put('SolarDevicesDetails',solardevices);
                outMap.put('SolarDeviceSize', solardevices.size());
            }
            else{
                outMap.put('SolarDeviceSize', 0);
            }
            if(batterydevices!=null && !batterydevices.isEmpty()) {
                outMap.put('BatteryDevicesDetails',batterydevices);
                outMap.put('BatteryDeviceSize', batterydevices.size());
            }
            else{
                outMap.put('BatteryDeviceSize', 0);
            }
            
            Map<String,Object> inputMapDebug = inputMap.clone();
            inputMapDebug.remove('FullInverters');
            // DCE-2747 : No need of success lo for this.
           // integrationLogSuccess(null,'toPopulateInverter',JSON.serialize(inputMapDebug),'Update');
        }
        catch (Exception e){
            String exceptionResult = e.getMessage()+'\n'+e.getStackTraceString()+'\n'+e.getLineNumber();
            System.debug(LoggingLevel.ERROR, 'Exception in toPopulateInverter:\n'+exceptionResult);
            Map<String,Object> inputMapDebug = inputMap.clone();
            inputMapDebug.remove('FullInverters');
            //integrationlog(exceptionResult,'toPopulateInverter',JSON.serialize(inputMapDebug),'Update');
            FnP_ExtUserObjAccessUtility.integrationlog(exceptionResult,'SolarFormRecordType','toPopulateInverter',JSON.serialize(inputMapDebug),'Update');
        }
    } 
    
   
    global void toMergeInverterLists(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        try {  
            Map<String,Object> DERApplication = new Map<String,Object>();
            Map<String,Object> DERApplication2 = new Map<String,Object>();
            Map<String,Object> devicesone = new Map<String,Object>();
            List<Object> devices = new List<Object>();
            List<Map<String,Object>> devicesList = new List<Map<String,Object>>();
            List<Map<String,Object>> solardevices = new List<Map<String,Object>>();
            List<Map<String,Object>> batterydevices = new List<Map<String,Object>>();
            List<Map<String,Object>> nulldevices = new List<Map<String,Object>>();
            List<Map<String,Object>> nulldevicesList;
            List<Map<String,Object>> nulldevicesListBattery;
            Double count;
            Double cap;
            Double multiply;
            system.debug('inputmap:::'+inputmap);
            DERApplication=(Map<String,Object>)inputMap.get('DERApplication');
            DERApplication2=(Map<String,Object>)DERApplication.get('DERApplication');
            devices=(List<Object>)DERApplication2.get('devices');

            string stringifyDevices = JSON.serialize(devices);
            List<Object> deviceList =(List<Object>)JSON.deserializeUntyped(stringifyDevices);
            system.debug('check'+deviceList.size());
    
   
            for(Object device : deviceList) {
    
                Map<String,Object> datacheck = (Map<String,Object>)device;
           
           
                system.debug('mapdatacheck'+datacheck.get('AC_Equip_Sub_Type__c'));
                devicesone.put('SID__c',datacheck.get('SID__c'));
                devicesone.put('EAI_Type__c',datacheck.get('EAI_Type__c'));
                devicesone.put('EAI_Ref__c',datacheck.get('EAI_Ref__c'));
                devicesone.put('Approved__c',datacheck.get('Approved__c'));
                devicesone.put('Requested__c',datacheck.get('Requested__c'));
                devicesone.put('DRED_Enabled__c',datacheck.get('DRED_Enabled__c'));
                devicesone.put('CEC_ID__c',datacheck.get('CEC_ID__c'));
                devicesone.put('AC_Equip_Sub_Type__c',datacheck.get('AC_Equip_Sub_Type__c'));
                devicesone.put('AC_Equip_Cap__c',datacheck.get('AC_Equip_Cap__c'));
                devicesone.put('Model__c',datacheck.get('Model__c'));
                devicesone.put('Manufacturer__c',datacheck.get('Manufacturer__c'));
                //devicesone.put('InverterId',datacheck.get('InverterId'));
                devicesone.put('Device_Count__c',datacheck.get('Device_Count__c'));
                devicesone.put('Device_Phase__c',datacheck.get('Device_Phase__c'));
                devicesone.put('Id',datacheck.get('Id'));

                if (devicesone.get('Device_Count__c') != null && devicesone.get('AC_Equip_Cap__c') != null) {
                    count=(Double)devicesone.get('Device_Count__c');
                    system.debug('count'+count);
                    cap=(Double)devicesone.get('AC_Equip_Cap__c');
                    system.debug('cap'+cap);
                    multiply=count*cap;
                }
                //devicesone.put('totalCapacity',multiply);

                if(datacheck.get('AC_Equip_Sub_Type__c') == 'Solar') {
                    solardevices.add(devicesone);
                }
                else if(datacheck.get('AC_Equip_Sub_Type__c') == 'Battery'){
                    batterydevices.add(devicesone);
                }
                else if(datacheck.get('AC_Equip_Sub_Type__c') == Null){
                    devicesone.put('EAI_Parent__c',datacheck.get('EAI_Parent__c'));
                    devicesone.put('Device_Sub_Type__c',datacheck.get('Device_Sub_Type__c'));
                    devicesone.put('Device_Type__c',datacheck.get('Device_Type__c'));
                    devicesone.put('Nominal_Rated_Cap__c',datacheck.get('Nominal_Rated_Cap__c'));
                    nulldevices.add(devicesone);
                    system.debug('nulldevices'+nulldevices);
                }

                devicesone = new Map<String, Object>();
            }         
       
            for(Map<String,Object> obj :solardevices) {
                System.debug('objsolar'+obj);
                nulldevicesList=new List<Map<String,Object>>();
                
                for(Map<String,Object> objone :nulldevices) {
                    if(objone.get('EAI_Parent__c') == obj.get('EAI_Ref__c')) {
                        nulldevicesList.add(objone);
                        system.debug('nulldevicesList' +nulldevicesList);
                    }
                }

                // obj.put('Devices__r',nulldevicesList);
                // obj.put('Devices__r',new Map<String,Object>{'totalSize'=>nulldevicesList.size()});
                // obj.put('Devices__r',new Map<String,Object>{'done'=>true});
                // obj.put('Devices__r',new Map<String,Object>{'records'=>nulldevicesList});
                devicesList.addAll(nulldevicesList);
            }

            for (Map<String,Object> obj :batterydevices) {
          
                nulldevicesListBattery=new List<Map<String,Object>>();
                
                for (Map<String,Object> objthree :nulldevices){
                    if(objthree.get('EAI_Parent__c') == obj.get('EAI_Ref__c')){
                        nulldevicesListBattery.add(objthree);
                    }
                }
           
                // obj.put('Devices__r',nulldevicesListBattery);
                // obj.put('Devices__r',new Map<String,Object>{'totalSize'=>nulldevicesListBattery.size()});
                // obj.put('Devices__r',new Map<String,Object>{'done'=>true});
                // obj.put('Devices__r',new Map<String,Object>{'records'=>nulldevicesListBattery});
                devicesList.addAll(nulldevicesListBattery);
            }

            devicesList.addAll(solardevices);
            devicesList.addAll(batterydevices);

            outMap.put('Devices',devicesList);

            Map<String,Object> inputMapDebug = inputMap.clone();
            inputMapDebug.remove('FullInverters');
            // DCE-2747 : No need of success log for this.
            //FnP_ExtUserObjAccessUtility.integrationlogSuccess(null,String.valueOf(devicesList),'SolarFormRecordType','toMergeInverterLists',JSON.serialize(inputMapDebug),'Update');
        } 
        catch(Exception e) {

            String exceptionResult = e.getMessage()+'\n'+e.getStackTraceString()+'\n'+e.getLineNumber();
            System.debug(LoggingLevel.ERROR, 'Exception toMergeInverterLists:\n'+exceptionResult);
            Map<String,Object> inputMapDebug = inputMap.clone();
            inputMapDebug.remove('FullInverters');
          //  integrationlog(exceptionResult,'toMergeInverterLists',JSON.serialize(inputMapDebug),'Update');
            FnP_ExtUserObjAccessUtility.integrationlog(exceptionResult,'SolarFormRecordType','toMergeInverterLists',JSON.serialize(inputMapDebug),'Update');
        }
    }  
    
    global void getInverters(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        try {
       //Radhika     List<CEC_Inverters__mdt> inverterLst = new List<CEC_Inverters__mdt>();
       List<CECInverter__c> inverterLst = new List<CECInverter__c>();
            List<Map<String,Object>> solarInverters = new List<Map<String,Object>>();
            List<Map<String,Object>> batteryInverters = new List<Map<String,Object>>();
            Map<String,String> inverter = new Map<String, String>();
       //Radhika     String query = 'SELECT SID__c, AC_DC_Coupling__c, AC_Equip_Type__c ,CEC_ID__c,Approved__c,EAI_Ref__c,EAI_Type__c, DRED_Enabled__c, Requested__c, Inverter_Type__c,InverterMfr__c, InverterModel__c,	InverterCapacity__c from CEC_Inverters__mdt';
       		String query = 'SELECT SID__c, AC_DC_Coupling__c, AC_Equip_Type__c ,CEC_ID__c,Approved__c,EAI_Ref__c,EAI_Type__c, Inverter_Type__c,InverterMfr__c, InverterModel__c,	InverterCapacity__c from CECInverter__c';
            inverterLst = Database.query(query);
      //Radhika      for(CEC_Inverters__mdt inv : inverterLst ){
            for(CECInverter__c inv : inverterLst ){    
                inverter.put('InverterId',String.valueOf(inv.Id));
                inverter.put('Manufacturer__c',inv.InverterMfr__c);
                inverter.put('Model__c',inv.InverterModel__c); 
                inverter.put('AC_Equip_Cap__c',String.valueOf(inv.InverterCapacity__c));
                inverter.put('AC_Equip_Sub_Type__c', inv.Inverter_Type__c);
                inverter.put('AC_Equip_Type__c', inv.AC_Equip_Type__c);
                inverter.put('CEC_ID__c',inv.CEC_ID__c);
         //Radhika       inverter.put('DRED_Enabled__c', inv.DRED_Enabled__c);
         //Radhika       inverter.put('Requested__c',String.valueOf(inv.Requested__c));
         		inverter.put('DRED_Enabled__c', 'Yes');
                inverter.put('Requested__c',String.valueOf(true));
                inverter.put('Approved__c',String.valueOf(inv.Approved__c));
                inverter.put('EAI_Ref__c',inv.EAI_Ref__c);
                inverter.put('EAI_Type__c',inv.EAI_Type__c);
                inverter.put('SID__c',inv.SID__c);
                if(inv.Inverter_Type__c=='Solar') 
                    solarInverters.add(inverter);
                else {
                    inverter.put('AC_DC_Coupling__c',inv.AC_DC_Coupling__c);
                    batteryInverters.add(inverter);
                }
                inverter = new Map<String, String>();
            }
            outMap.put('SolarInverters',solarInverters);
            outMap.put('BatteryInverters',batteryInverters);

            Map<String,Object> inputMapDebug = inputMap.clone();
            inputMapDebug.remove('FullInverters');
           // DCE-2747 : No need of success log for this. 
           //  integrationLogSuccess(null,'getInverters',JSON.serialize(inputMapDebug),'Update');
            
        }
        catch(Exception e) {

            String exceptionResult = e.getMessage()+'\n'+e.getStackTraceString()+'\n'+e.getLineNumber();
            System.debug(LoggingLevel.ERROR, 'Exception toMergeInverterLists:\n'+exceptionResult);
            Map<String,Object> inputMapDebug = inputMap.clone();
            inputMapDebug.remove('FullInverters');
            FnP_ExtUserObjAccessUtility.integrationlog(exceptionResult,'SolarFormRecordType','getInverters',JSON.serialize(inputMapDebug),'Update');
           
       }
    }
    
    
    global  boolean createDERApplication(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        boolean result = true;
        try {
            UtilDebug de = new UtilDebug();
            Integer resStatuCode = 403;
            DER_Payload payload = new DER_Payload();
            DER_Payload_Response payloadResp = new DER_Payload_Response();
            Map<String,Object> inputDetails = null;
            system.debug('inputMap##'+inputMap);
            if(inputMap.containsKey('DERRequestPayload')){
                inputDetails=(Map<String,Object>)inputMap.get('DERRequestPayload');
                
                System.debug('DERRequestPayload ::: '+JSON.serializePretty(inputDetails));
            } 
            
            // A savepoint when no DML has been executed
            Savepoint sp = Database.setSavepoint();
            
            try {
                payload = (DER_Payload)JSON.deserialize(JSON.serializePretty(inputDetails), DER_Payload.class);
                //------------------------------------------------------------------------------------//
                //------------ Insert logic for differnt objects based on the references ------------//
                //------------------------------------------------------------------------------------//
                if (payload.derCase != null && payload.derApp != null)
                {
                    if (String.isNotBlank(payload.derCase.DER_Application_Scenario__c)
                        && (payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_AUTO
                            || payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_MANUAL))
                    {
                        system.debug('in IF test');
                        if (payload.nmi != null && payload.nmi.NMI__c != null)
                        {
                            // ------------------------------------------------ //
                            // ---------Find or create Connection Point-------- //
                            // ------------------------------------------------ //
                            
                            Id conPointId = findConPoint(payload.nmi.NMI__c);
                            if (conPointId != null){
                                payload.nmi.Id = conPointId;
                                // Update connection point once customer is inserted
                            }else{
                                //if Creating - Customer lookup will be null
                                insertUpdateNMI(payload.nmi, false); // isUpdate = true
                                payloadResp.success.setNmiInsert(payload.nmi.Id);
                            }
                            
                            // ------------------------------------------------ //
                            // --------- Insert DER Application --------------- //
                            // ------------------------------------------------ //
                            
                            // Meter__c field is expected to be present at payload.derApp
                            // If Meter__c field is present then Apex Trigger will lookup the meter record to Meter_Ref__c
                            payload.derApp.NMI__c = payload.nmi.Id;
                            
                            // Set derApp Case Status for import assets trigger.
                            payload.derApp.DER_Scenario__c = payload.derCase.DER_Application_Scenario__c;
                            payload.derApp.Case_Type__c    = payload.derCase.Type;
                            
                            if (payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_AUTO)
                                payload.derApp.Case_Status__c = CASE_STATUS_INST_PENDING;
                            else if (payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_MANUAL)
                                payload.derApp.Case_Status__c = CASE_STATUS_NEW;
                            
                            
                            insert payload.derApp;
                            payloadResp.success.setDerAppInsert(payload.derApp.Id);
                            
                            // ---------------------------------------- //
                            // --------- Upsert Devices --------------- //
                            // ---------------------------------------- //
                            
                            if (payload.devices != null)
                            {
                                UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = true; // Disable roll up trigger momentarily
                                payloadResp = processDevices(payload, payloadResp);
                                System.debug('payloadResp::'+payloadResp); 
                            }
                            
                            Id caseRTId;
                            if (payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_AUTO)
                            {
                                caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_AUTO).getRecordTypeId();
                                // --------------------------------------------------------------------------------------------- //
                                // ---------No installer, installer contact, customer, rep will be created for AUTO------------- //
                                // --------------------------------------------------------------------------------------------- //
                                
                                // -------------------------------------------- //
                                // ---------Update nmi for CREATE/AUTO  ------- //
                                // -------------------------------------------- //
                                
                                if (payloadResp.success.nmi == null)
                                {
                                    insertUpdateNMI(payload.nmi, true); // isUpdate = true;
                                    payloadResp.success.setNmiUpdate(payload.nmi.Id, payload.nmi.NMI__c);
                                }
                                
                                // ------------------------------------- //
                                // ---- Insert Case for CREATE/AUTO----- //
                                // ------------------------------------- //
                                
                                payload.derCase.RecordTypeId = caseRTId;
                                payload.derCase.DER_Application__c = payload.derApp.Id;
                                payload.derCase.Status = CASE_STATUS_INST_PENDING;
                                payload.derCase.OwnerId = getDefaultCaseQueueOwner(payload.derCase);
                                
                                if (payload.derCase.Auto_Applicant_Email__c != null){
                                    payload.derCase.Applicant_Email__c = payload.derCase.Auto_Applicant_Email__c;
                                    payload.derCase.Applicant_Name__c = payload.derCase.Auto_Applicant_FirstName__c + ' ' + payload.derCase.Auto_Applicant_LastName__c;
                                }
                                
                                // Run device roll up calc before updating Case
                                runDeviceRollup(payload.derCase);
                                insertCase(payload.derCase);
                                
                                // Get App number
                                Case newCase = (Case) UtilDatabase.getRecord(payload.derCase.Id);
                                payloadResp.success.setDerCaseInsert(newCase.Id, newCase.Application_Number__c);
                                
                                // What are the chances the address is ok?
                                System.debug('Check Address: ' + newCase.Site_fx__c);
                                System.debug('Case_Ready__c: ' + newCase.Case_Ready__c);
                                if (newCase.Site_fx__c != null && newCase.Site_fx__c != '' && newCase.Site_fx__c != 'N/A' &&
                                    !newCase.Case_Ready__c)
                                {
                                    System.debug('** Setting Case_Ready__c to True.');
                                    Case updCase = new Case(Id = newCase.Id, Case_Ready__c = true);
                                    update updCase;
                                }
                                
                                // ------------------------------------------------ //
                                // ---- Insert DER Agreement CREATE/AUTO  --------- //
                                // ------------------------------------------------ //
                                DER_Agreement__c derAgmnt = new DER_Agreement__c();
                                //Agreement's Account lookup will be populated during UpdateApplication API call
                                derAgmnt.DER_Application__c = payload.derApp.Id;
                                derAgmnt.NMI__c = payload.nmi.Id;
                                derAgmnt.Offer_Accepted_By__c = payload.derCase.Applicant_Type__c;
                                derAgmnt.Offer_Accepted_Date__c = System.today();
                                derAgmnt.Offer_Made_Date__c = System.today();
                                derAgmnt.Offer_Type__c = payload.derCase.Agreement_Type__c;
                                derAgmnt.Status__c = Trig_DER_Agreement.AGGR_STATUS_OFFERACCEPTED;
                                insert derAgmnt;
                                
                                resStatuCode = 200;
                                // DCE-2747 : Log the case id created. rest alll recs created are linked to this.
                                FnP_ExtUserObjAccessUtility.integrationLogSuccess(newCase.Id,JSON.serialize(payloadResp),'SolarFormRecordType','createDERApplication',JSON.serialize(payload),'Create');
                            }
                            else
                            {
                                // Manual
                                System.debug('Payload:::'+payload);
                                caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_MANUAL).getRecordTypeId();
                                // -------------------------------------------------------------------------------------------- //
                                // ---------Installer, installer contact, customer, rep will be created for MANUAL------------- //
                                // -------------------------------------------------------------------------------------------- //
                                system.debug('payload.installer'+payload.installer);
                                system.debug('payload.installerContact'+payload.installerContact);
                                system.debug('payload.installer.ABN__c'+payload.installer.ABN__c);
                                system.debug('payload.installerContact.Accreditation_Number__c'+payload.installerContact.Accreditation_Number__c);
                                system.debug('payload.installerContact.Acceditation_Type__c'+payload.installerContact.Acceditation_Type__c);
                                if (payload.installer != null && payload.installerContact != null
                                    && payload.installer.ABN__c != null
                                    && payload.installerContact.Accreditation_Number__c != null
                                    && payload.installerContact.Acceditation_Type__c != null)
                                {
                                    // ----------------------------------------------------------------------- //
                                    // ---------Find or create RepresentativeCompany for CREATE/MANUAL------- //
                                    // -----------------------------------------------------------------------//
                                    // "RepresentativeCompany are always service providers"
                                    if (payload.representativeCompany != null && String.isNotBlank(payload.representativeCompany.Name))
                                    {
                                        if (payload.representativeCompany.Id == null)
                                        {
                                            // Set record type.
                                            payload.representativeCompany.recordTypeId = UtilDatabase.getRecordTypeNames('Account').get(ACCOUNT_RECORDTYPE_SERVICEPROVIDER);
                                            
                                            // Attempt to match Rep Company Account on ABN
                                            Id repCompId = findServProvider(payload.representativeCompany.ABN__c);
                                            system.debug('repCompId'+repCompId);
                                            if (repCompId != null)
                                            {
                                                payload.representativeCompany.Id = repCompId;
                                                update payload.representativeCompany;
                                                payloadResp.success.setRepCompUpdate(payload.representativeCompany.Id, payload.representativeCompany.ABN__c);
                                            }
                                            else
                                            {
                                                payload.representativeCompany.Type = 'Representative';
                                                payload.representativeCompany.Customer_Type__c = 'ELE - DER';
                                                payload.representativeCompany.Name='TestingAccountName';
                                                insert payload.representativeCompany;
                                                payloadResp.success.setRepCompInsert(payload.representativeCompany.Id);
                                            }
                                        }
                                        else
                                        {
                                            // Assume should not get here.
                                            update payload.representativeCompany;
                                        }
                                        
                                        if (payload.representative != null && payload.representative.email != null)
                                        {
                                            // -------------------------------------------------------------- //
                                            // ---------Find or create representative for CREATE/MANUAL------- //
                                            // -------------------------------------------------------------- //
                                            
                                            // Link representative contact with mutliple accounts
                                            Id repId = findRep(payload.representative.email);
                                            
                                            if (repId != null)
                                            {
                                                payload.representative.AccountId = payload.representativeCompany.Id;
                                                payload.representative.Id = repId;
                                                update payload.representative;
                                                
                                                payloadResp.success.setRepUpdate(payload.representative.Id, payload.representative.email);
                                                linkAccWithContact(payload.representativeCompany.Id, payload.representative.Id);
                                            }
                                            else
                                            {
                                                payload.representative.AccountId = payload.representativeCompany.Id;
                                                insert payload.representative;
                                                
                                                payloadResp.success.setRepInsert(payload.representative.Id);
                                                linkAccWithContact(payload.representativeCompany.Id, payload.representative.Id);
                                            }
                                            
                                            payload.derCase.Representative__c = payload.representative.Id;
                                        }
                                        else{
                                            // no error
                                            // representative node is now set to optional
                                        }
                                    }
                                    else
                                    {
                                        // no represntative Company
                                        // Hence no representative Contact
                                    }
                                    
                                    
                                    if (payload.customer != null)
                                    {
                                        // ------------------------------------------------ //
                                        // ---------Insert customer for CREATE/MANUAL------- //
                                        // ------------------------------------------------ //
                                        
                                        // Always create new customer as per business logic CMC-1379 except Update/MANUAL
                                        // "If customer has ABN, then set to Customer - business else Customer - Individual" TO DO?
                                        system.debug('Payload customer:::'+payload.customer);
                                        Id acctCustRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
                                        payload.customer.recordTypeId = acctCustRTId;
                                        payload.customer.Customer_Type__c = 'ELE - DER';
                                        if(test.isRunningTest()){
                                            payload.customer.FirstName='Acc';
                                            payload.customer.LastName='Test';
                                        }
                                        insert payload.customer;
                                        payloadResp.success.setCustomerInsert(payload.customer.Id);
                                        
                                        // -------------------------------------------- //
                                        // ---------Update nmi for CREATE/MANUAL------- //
                                        // -------------------------------------------- //
                                        
                                        if (payloadResp.success.nmi == null)
                                        {
                                            // Now update connection point with Account lookup as customer
                                            payload.nmi.Account__c = payload.customer.Id;
                                            insertUpdateNMI(payload.nmi, true); // isUpdate = true;
                                            payloadResp.success.setNmiUpdate(payload.nmi.Id, payload.nmi.NMI__c);
                                        }
                                        
                                        // --------------------------------------------------------- //
                                        // ---------Find or create Installer for CREATE/MANUAL------- //
                                        // --------------------------------------------------------- //
                                        
                                        // "Installers are always service providers"
                                        Id acctBusinessRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_SERVICEPROVIDER).getRecordTypeId();
                                        payload.installer.recordTypeId = acctBusinessRTId;
                                        payload.installer.Customer_Type__c = 'ELE - DER';
                                        Id instId = findServProvider(payload.installer.ABN__c);
                                        system.debug('instId'+instId);
                                        if (instId != null){
                                            payload.installer.Id = instId;
                                            update payload.installer;
                                            payloadResp.success.setInstallerUpdate(payload.installer.Id, payload.installer.ABN__c);
                                        }else{
                                            payload.installer.Type = 'Installer';
                                            payload.installer.Name='TestingAccountName';
                                            insert payload.installer;
                                            payloadResp.success.setInstallerInsert(payload.installer.Id);
                                        }
                                        
                                        // ----------------------------------------------------------------- //
                                        // ---------Find or create Installer Contact for CREATE/MANUAL------ //
                                        // ----------------------------------------------------------------- //
                                        
                                        payload.installerContact.AccountId = payload.installer.Id;
                                        
                                        Id instContId = findInstallerContact(payload.installerContact.Accreditation_Number__c,
                                                                            payload.installerContact.Acceditation_Type__c,
                                                                            payload.installerContact.Email);
                                        
                                        
                                        if (instContId != null){
                                            payload.installerContact.Id = instContId;
                                            update payload.installerContact;
                                            payloadResp.success.setInstContUpdate(payload.installerContact.Id,
                                                                                payload.installerContact.Accreditation_Number__c+
                                                                                '+'+
                                                                                payload.installerContact.Acceditation_Type__c);
                                            linkAccWithContact(payload.installer.Id, payload.installerContact.Id);
                                        }else{
                                            insert payload.installerContact;
                                            payloadResp.success.setInstContInsert(payload.installerContact.Id);
                                        }
                                        
                                        // ------------------------------------- //
                                        // ---- Insert Case CREATE/MANUAL------- //
                                        // ------------------------------------- //
                                        
                                        
                                        payload.derCase.AccountId = payload.installer.Id;
                                        payload.derCase.ContactId = payload.installerContact.Id;
                                        payload.derCase.Customer__c = payload.customer.Id;
                                        payload.derCase.OwnerId = getDefaultCaseQueueOwner(payload.derCase);
                                        payload.derCase.RecordTypeId = caseRTId;
                                        payload.derCase.DER_Application__c = payload.derApp.Id;
                                        payload.derCase.Status = CASE_STATUS_NEW;
                                        system.debug('payload.derCase.AccountId'+ payload.derCase.AccountId);
                                        // Run device roll up calc before inserting Case
                                        runDeviceRollup(payload.derCase);
                                        
                                        insertCase(payload.derCase);
                                        
                                        // Get App number
                                        Case newCase = (Case) UtilDatabase.getRecord(payload.derCase.Id);
                                        payloadResp.success.setDerCaseInsert(newCase.Id, newCase.Application_Number__c);
                                        
                                        // What are the chances the address is ok?
                                        System.debug('Check Address: ' + newCase.Site_fx__c);
                                        System.debug('Case_Ready__c: ' + newCase.Case_Ready__c);

                                        if (newCase.Site_fx__c != null && 
                                            newCase.Site_fx__c != '' && 
                                            newCase.Site_fx__c != 'N/A' &&
                                            !newCase.Case_Ready__c)
                                        {
                                            System.debug('** Setting Case_Ready__c to True.');
                                            Case updCase = new Case(Id = newCase.Id, Case_Ready__c = true);
                                            update updCase;
                                        }
                                        
                                        resStatuCode = 200;
										// DCE-2747 : Log the case id created. rest alll recs created are linked to this.
                                		FnP_ExtUserObjAccessUtility.integrationLogSuccess(newCase.Id,JSON.serialize(payloadResp),'SolarFormRecordType','createDERApplication',JSON.serialize(payload),'Create');
                                        
                                        
                                    }
                                    else {
                                        payloadResp.setError('customer JSON node is required');
                                        Database.rollback(sp);
                                        result = false;
                                    }
                                }
                                else{
                                    payloadResp.setError('installer (with ABN__c) & installerContact (with Accreditation_Number__c, Acceditation_Type__c) JSON nodes are required.');
                                    Database.rollback(sp);
                                    result = false;
                                }
                            }
                        }
                        else {
                            payloadResp.setError('required attribute nmi__c is missing for nmi JSON nodes.');
                            Database.rollback(sp);
                            result = false;
                        }
                    }
                    else{
                        payloadResp.setError('DER_Application_Scenario__c attribute (on derCase JSON node) is missing or invalid.');
                        Database.rollback(sp);
                        result = false;
                    }
                }
                else{
                    payloadResp.setError('derApp and derCase JSON nodes are required.');
                    Database.rollback(sp);
                    result = false;
                }
            }
            catch(DERApplicationAPIException derExp)
            {
                resStatuCode = 417;
                payloadResp.setError('DERApplicationAPIException Exception Occurred. ' + derExp.getMessage());
                System.debug('FnP_SolarFormUtility--> DERApplicationAPIException--> Exception-->'+payloadResp.error);
                Database.rollback(sp);
				result = false;
                FnP_ExtUserObjAccessUtility.integrationlog(payloadResp.error,'SolarFormRecordType','createDERApplication',JSON.serialize(payload),'Create');
            }
            catch(Exception e)
            {
                resStatuCode = 417;
                payloadResp.setError('Exception Occurred. Message: ' + e.getMessage()
                                    + ' StackTrace: ' + e.getStackTraceString()
                                    + ' Type: ' + e.getTypeName()
                                    + ' Cause: ' + e.getCause());
                
                System.debug('FnP_SolarFormUtility--> doPost--> Exception-->'+payloadResp.error);
                Database.rollback(sp);
                result = false;
                FnP_ExtUserObjAccessUtility.integrationlog(payloadResp.error,'SolarFormRecordType','createDERApplication',JSON.serialize(payload),'Create');
            }
            
            de.bug('Response');
            de.bug('--------');
            de.bug('statusCode: ' + resStatuCode);
            de.bug('body:\n' + JSON.serializePretty(payloadResp), true);
            de.bugSend();
            
            // Set payloadResp to outmap...
            outMap.put('DERresponse',payloadResp);
        }
        catch(Exception e) {

            Map<String,Object> inputMapDebug = inputMap.clone();
            inputMapDebug.remove('FullInverters');

            string methodname='createDERApplication';
            string mapdetails=JSON.serialize(inputMapDebug);
            string operation='Create';
            result = false;
            FnP_ExtUserObjAccessUtility.integrationlog(e.getMessage()+' '+e.getStackTraceString()+' '+e.getLineNumber(),'SolarFormRecordType',methodname,mapdetails,operation);  
        }
        return result;
    }
    
    global boolean updateDERApplication(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        // DCE-2747 : moved this variable outside of try block to make it accessible in catch block as well. 
        Savepoint sp = Database.setSavepoint();
        boolean result = true;
        try {
            UtilDebug de = new UtilDebug();
            Integer resStatuCode = 403;
            DER_Payload payload = new DER_Payload();
            DER_Payload_Response payloadResp = new DER_Payload_Response();
            Map<String,Object> inputDetails = null;
            
            System.debug('inputMap ::: \n'+JSON.serializePretty(inputMap));

            if(inputMap.containsKey('DERRequestPayload')){
                
                inputDetails = (Map<String,Object>)inputMap.get('DERRequestPayload');
                
                System.debug('DERRequestPayload ::: \n'+JSON.serializePretty(inputDetails));
            }
            
            

            try {
                String inputDetailsSerialized = JSON.serialize(inputDetails);
                payload = (DER_Payload)JSON.deserialize(inputDetailsSerialized, DER_Payload.class);
                System.debug('payload----------------->\n'+payload);
                    System.debug('payload.derCase.Id ::::: ' + payload.derCase.Id);
                //------------------------------------------------------------------------------------//
                //------- Create/match logic for differnt objects based on the references ------------//
                //------------------------------------------------------------------------------------//
                if (payload.derCase != null && payload.derCase.Id != null
                    && payload.derApp != null && payload.derApp.Id != null
                    && payload.nmi != null && payload.nmi.Id != null)
                {
                    Case queryDERCase = (Case)UtilDatabase.getRecord(payload.derCase.Id);
                    // Set App Scenario
                    payload.derCase.DER_Application_Scenario__c = queryDERCase.DER_Application_Scenario__c;
                    System.debug('payload.derCase.DER_Application_Scenario__c ::::: ' + payload.derCase.DER_Application_Scenario__c);
                    if (String.isNotBlank(payload.derCase.DER_Application_Scenario__c)
                        && (payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_AUTO
                            || payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_MANUAL))
                    {
                        if (payload.nmi != null)
                        {
                            // ------------------------------------------------- //
                            // --------- Update DER Application --------------- //
                            // ------------------------------------------------ //
                            
                            // Get unique values of phases from payload.devices.. DCE-2668.start 
                            Set<String> devset = new Set<String>();
                            for (Device__c device: payload.devices) {
                                // if device.Device_Phase__c is 3-phase, then add a,b,c phase to this. 
                                switch on device.Device_Phase__c {
                                    when 'A','B','C' {
                                        devset.add(device.Device_Phase__c); 
                                    }
                                    when '3 Phase' {
                                        devset.add('A');
                                        devset.add('B');
                                        devset.add('C');
                                    }
                                }
                            }
                            // DCE-2746 : When there are no devices added, no need to set this field.
                            if(devset.size()!=0)
                            	payload.derApp.Phase_Amount_Available__c = String.valueOf(devset.size());
                            // Get unique values of phases from payload.devices.. DCE-2668. end
                            
                            // Meter__c field is expected to be present at payload.derApp
                            // If Meter__c field is present then Apex Trigger will lookup the meter record to Meter_Ref__c
                            payload.derApp.Post_Installation_Date__c = System.now();
                            update payload.derApp;
                            System.debug('payload.derApp Auto is updated '+ payload.derApp);
                            payloadResp.success.setDerAppUpdate(payload.derApp.Id, payload.derCase.Id);
                            
                            // ---------------------------------------- //
                            // --------- Upsert Devices --------------- //
                            // ---------------------------------------- //
                            
                            if (payload.devices != null)
                            {
                               UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = true; // Disable roll up trigger momentarily
                                payloadResp = processDevices(payload, payloadResp);
                                // DCE-2747 : If payloadResp is null, that means, processDevices logged error. 
                                if(payloadResp.error!=null){
                                    System.debug('Process Device HAS Error: '+ payloadResp.error );
                    				throw new DERApplicationAPIException(payloadResp.error);
                                }
                            }
                            
                            Id caseRTId;
                            if (payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_AUTO)
                            {
                                caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_AUTO).getRecordTypeId();
                                System.debug('Installer Details for Auto... payload.installer.ABN__c :: '+payload.installer.ABN__c + ' installerContact.Accreditation_Number__c:: '+payload.installerContact.Accreditation_Number__c + ' payload.installerContact.Acceditation_Type__c:: '+payload.installerContact.Acceditation_Type__c);
                                // --------------------------------------------------------------------------------------------------- //
                                // ---------Installer, installer contact, customer, rep will be created/match for UPDATE/AUTO--------- //
                                // --------------------------------------------------------------------------------------------------- //
                                if (payload.installer != null && payload.installerContact != null
                                    && payload.installer.ABN__c != null
                                    && payload.installerContact.Accreditation_Number__c != null
                                    && payload.installerContact.Acceditation_Type__c != null)
                                {
                                    
                                    if (payload.customer != null)
                                    {
                                        // ----------------------------------------------------- //
                                        // ---------Insert customer for UPDATE/AUTO------------- //
                                        // ----------------------------------------------------- //
                                        
                                        //Always create new customer as per business logic CMC-1379
                                        Id acctCustRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
                                        payload.customer.recordTypeId = acctCustRTId;
                                        payload.customer.Customer_Type__c = 'ELE - DER';
                                        insert payload.customer;
                                        payloadResp.success.setCustomerInsert(payload.customer.Id);
                                        
                                        // ------------------------------------------------ //
                                        // ---------------- Update Connection Point-------- //
                                        // ------------------------------------------------ //
                                        
                                        // here nmi will be updated after customer is created
                                        
                                        payload.nmi.Account__c = payload.customer.Id;
                                        insertUpdateNMI(payload.nmi, true); // isUpdate = true
                                        payloadResp.success.setNmiUpdate(payload.nmi.Id, payload.nmi.NMI__c);
                                        
                                        // ------------------------------------------------ //
                                        // ---------Find Installer for UPDATE/AUTO-------- //
                                        // ----------------------------------------------- //
                                        
                                        // "Installers are always service providers"
                                        Id acctBusinessRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_SERVICEPROVIDER).getRecordTypeId();
                                        payload.installer.recordTypeId = acctBusinessRTId;
                                        payload.installer.Customer_Type__c = 'ELE - DER';
                                        Id instId = findServProvider(payload.installer.ABN__c);
                                        if (instId != null){
                                            payload.installer.Id = instId;
                                            System.debug('payload.installer Auto is updated '+ payload.installer);
                                            update payload.installer;
                                            payloadResp.success.setInstallerUpdate(payload.installer.Id, payload.installer.ABN__c);
                                        }else{
                                            System.debug('payload.installer Auto is inserted '+ payload.installer);
                                            insert payload.installer;
                                            payloadResp.success.setInstallerInsert(payload.installer.Id);
                                        }
                                        
                                        // -------------------------------------------------------- //
                                        // ---------Find Installer Contact for UPDATE/AUTO-------- //
                                        // ------------------------------------------------------- //
                                        
                                        payload.installerContact.AccountId = payload.installer.Id;
                                        
                                        Id instContId = findInstallerContact(payload.installerContact.Accreditation_Number__c,
                                                                                payload.installerContact.Acceditation_Type__c,
                                                                                payload.installerContact.Email);
                                        
                                        if (instContId != null){
                                            payload.installerContact.Id = instContId;
                                            System.debug('payload.installerContact Auto is updated '+ payload.installerContact);
                                            update payload.installerContact;
                                            payloadResp.success.setInstContUpdate(payload.installerContact.Id,
                                                                                    payload.installerContact.Accreditation_Number__c+
                                                                                    '+'+
                                                                                    payload.installerContact.Acceditation_Type__c);
                                            linkAccWithContact(payload.installer.Id, payload.installerContact.Id);
                                        }else{
                                            System.debug('payload.installerContact Auto is inserted '+ payload.installerContact);
                                            insert payload.installerContact;
                                            payloadResp.success.setInstContInsert(payload.installerContact.Id);
                                        }
                                        
                                        // ------------------------------------------------ //
                                        // ---- Insert DER Agreement UPDATE/AUTO  --------- //
                                        // ------------------------------------------------ //
                                        List<DER_Agreement__c> lstAgmnt = new List<DER_Agreement__c>([SELECT Id, Account__c
                                                                                                        FROM DER_Agreement__c
                                                                                                        WHERE DER_Application__c =: payload.derApp.Id]);
                                        //Agreement's Account lookup will be populated with Customer Id
                                        for (DER_Agreement__c item: lstAgmnt){
                                            item.Account__c = payload.customer.Id;
                                        }
                                        
                                        if (!lstAgmnt.isEmpty())
                                        {
                                            update lstAgmnt;
                                        }
                                        
                                        payload.derCase.AccountId = payload.installer.Id;
                                        payload.derCase.ContactId = payload.installerContact.Id;
                                        payload.derCase.Customer__c = payload.customer.Id;
                                        
                                        // ------------------------------------- //
                                        // --------- Update Case /AUTO --------- //
                                        // ------------------------------------- //
                                        
                                        payload.derCase.RecordTypeId = caseRTId;
                                        payload.derCase.DER_Application__c = payload.derApp.Id;
                                        payload.derCase.Status = CASE_STATUS_INST_VALIDATION;
                                        
                                        // Run device roll up calc before updating Case
                                        runDeviceRollup(payload.derCase);
                                        System.debug('payload.derCase Auto is updated '+ payload.derCase);
                                        update payload.derCase;
                                        payloadResp.success.setDerCaseUpdate(payload.derCase.Id, payload.derCase.Id);
                                        resStatuCode = 200;
                                         // DCE-2747 : Log the case id created. rest alll recs created are linked to this.
                                		System.debug('Success log for Case update..');
                                        FnP_ExtUserObjAccessUtility.integrationLogSuccess(payload.derCase.Id,JSON.serialize(payloadResp),'SolarFormRecordType','updateDERApplication',JSON.serialize(payload),'Update');
                                    }
                                    else
                                    {
                                        payloadResp.setError('customer JSON node is required');
                                        Database.rollback(sp);
                                    }
                                }
                                else
                                {
                                    payloadResp.setError('installer (with ABN__c) & installerContact (with Accreditation_Number__c, Acceditation_Type__c) JSON nodes are required.');
                                    Database.rollback(sp);
                                }
                            }
                            else
                            {
                                caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_MANUAL).getRecordTypeId();
                                // ----------------------------------------- //
                                // --------- Update Connection Point-------- //
                                // ----------------------------------------- //
                                
                                insertUpdateNMI(payload.nmi, true); // isUpdate = true
                                payloadResp.success.setNmiUpdate(payload.nmi.Id, payload.nmi.Id);
                                
                                
                                // ----------------------------------------------------------------------------------- //
                                // ---------Installer, installer contact, customer, rep for UPDATE/MANUAL------------- //
                                // ----------------------------------------------------------------------------------- //
                                if (payload.installer != null && payload.installerContact != null
                                    && payload.installer.ABN__c != null
                                    && payload.installerContact.Accreditation_Number__c != null
                                    && payload.installerContact.Acceditation_Type__c != null)
                                {
                                    
                                    if (payload.customer != null)
                                    {
                                        // ------------------------------------------------------- //
                                        // ----------------- Update for UPDATE/MANUAL------------- //
                                        // -------------------------------------------------------- //
                                        System.debug('payload.customer is updated '+ payload.customer);
                                        update payload.customer;
                                        payloadResp.success.setCustomerUpdate(payload.customer.Id, payload.customer.Id);
                                        
                                        if (payload.representative != null)
                                        {
                                            // --------------------------------------------------------------------- //
                                            // ---------------- Update representative for UPDATE/MANUAL------------- //
                                            // --------------------------------------------------------------------- //
                                            
                                            // Link representative contact with mutliple accounts
                                            update payload.representative;
                                            payloadResp.success.setRepUpdate(payload.representative.Id, payload.representative.Id);
                                            //linkAccWithContact(payload.representative.AccountId, payload.representative.Id);
                                        }else{
                                            // no error
                                            // representative node is now set to optional
                                        }
                                        // ------------------------------------------------------------------------------//
                                        // ---------------- Update representative Company for UPDATE/MANUAL------------- //
                                        // ------------------------------------------------------------------------------//
                                        if(payload.representativeCompany != null){
                                            update payload.representativeCompany;
                                            payloadResp.success.setRepCompUpdate(payload.representativeCompany.Id, payload.representativeCompany.Id);
                                        }
                                        else{
                                            // no error
                                            // representative Company node now set to optional
                                        }
                                        
                                        // ---------------------------------------------------------------- //
                                        // -----------------Update Installer for UPDATE/MANUAL------------- //
                                        // ---------------------------------------------------------------- //
                                        
                                        // "Installers are always service providers"
                                        Id acctBusinessRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_SERVICEPROVIDER).getRecordTypeId();
                                        payload.installer.recordTypeId = acctBusinessRTId;
                                        System.debug('payload.installer.Id ' + payload.installer.Id);
                                        System.debug('payload.installer.Id ' + payload.installer);
                                        update payload.installer;
                                        payloadResp.success.setInstallerUpdate(payload.installer.Id, payload.installer.Id);
                                        
                                        // ------------------------------------------------------------------------ //
                                        // ---------------- Update Installer Contact for UPDATE/MANUAL------------- //
                                        // ------------------------------------------------------------------------ //
                                        System.debug('payload.installerContact is updated '+ payload.installerContact);
                                        update payload.installerContact;
                                        payloadResp.success.setInstContUpdate(payload.installerContact.Id, payload.installerContact.Id);
                                        //linkAccWithContact(payload.installerContact.AccountId, payload.installerContact.Id);
                                        
                                        // ------------------------------------- //
                                        // --------- Update Case /MANUAL ------- //
                                        // ------------------------------------- //
                                        
                                        payload.derCase.RecordTypeId = caseRTId;
                                        payload.derCase.DER_Application__c = payload.derApp.Id;
                                        payload.derCase.Status = CASE_STATUS_INST_VALIDATION;
                                        
                                        
                                        // Run device roll up calc before updating Case
                                        runDeviceRollup(payload.derCase);
                                        System.debug('derCase is updated '+ payload.derCase);
                                        update payload.derCase;
                                        payloadResp.success.setDerCaseUpdate(payload.derCase.Id, payload.derCase.Id);
                                        resStatuCode = 200;
                                         // DCE-2747 : Log the case id created. rest alll recs created are linked to this.
                                		System.debug('Success log for Case update..');
                                        FnP_ExtUserObjAccessUtility.integrationLogSuccess(payload.derCase.Id,JSON.serialize(payloadResp),'SolarFormRecordType','updateDERApplication',JSON.serialize(payload),'Update');
                                        
                                    }else{
                                        payloadResp.setError('customer JSON node is required');
                                        FnP_ExtUserObjAccessUtility.integrationlog(payloadResp.error,'SolarFormRecordType','updateDERApplication',JSON.serialize(payload),'Create');
                                        Database.rollback(sp);
                                    }
                                }else{
                                    payloadResp.setError('installer (with ABN__c) & installerContact (with Accreditation_Number__c, Acceditation_Type__c) JSON nodes are required.');
                                    FnP_ExtUserObjAccessUtility.integrationlog(payloadResp.error,'SolarFormRecordType','updateDERApplication',JSON.serialize(payload),'Create');
                                     Database.rollback(sp);
                                }
                            }
                        }
                        else
                        {
                            payloadResp.setError('required nmi JSON nodes is missing.');
                            FnP_ExtUserObjAccessUtility.integrationlog(payloadResp.error,'SolarFormRecordType','updateDERApplication',JSON.serialize(payload),'Create');
                            Database.rollback(sp);
                        }
                    }
                    else
                    {
                        payloadResp.setError('DER_Application_Scenario__c attribute (on derCase JSON node) is missing or invalid.');
                        FnP_ExtUserObjAccessUtility.integrationlog(payloadResp.error,'SolarFormRecordType','updateDERApplication',JSON.serialize(payload),'Create');
                        Database.rollback(sp);
                    }
                    
                }
                else
                {
                    payloadResp.setError('derApp, derCase and nmi JSON nodes are required with Id attributes.');
                    FnP_ExtUserObjAccessUtility.integrationlog(payloadResp.error,'SolarFormRecordType','updateDERApplication',JSON.serialize(payload),'Create');
                    Database.rollback(sp);
                }

            }
            catch(DERApplicationAPIException derExp)
            {
                resStatuCode = 417;
                payloadResp.setError('DERApplicationAPIException Occurred. ' + derExp.getMessage());
                System.debug('FnP_SolarFormUtility--> updateDERApplication--> DERApplicationAPIException-->\n'+derExp.getMessage());
                System.debug('FnP_SolarFormUtility--> updateDERApplication--> StackTraceString-->\n'+derExp.getStackTraceString());
                Database.rollback(sp);
				System.debug('After Rollback updateDERApplication');
                FnP_ExtUserObjAccessUtility.integrationlog(payloadResp.error,'SolarFormRecordType','updateDERApplication',JSON.serialize(payload),'Update');
            	result = false;
            }
            catch(Exception e)
            {
                resStatuCode = 417;
                System.debug('FnP_SolarFormUtility--> updateDERApplication--> Exception Message-->'+e.getMessage()+ ' StackTrace: ' + e.getStackTraceString()
                    + ' Type: ' + e.getTypeName()
                    + ' Cause: ' + e.getCause());
                payloadResp.setError(
                    'Exception Occurred. Message: ' + e.getMessage()
                    + ' StackTrace: ' + e.getStackTraceString()
                    + ' Type: ' + e.getTypeName()
                    + ' Cause: ' + e.getCause()
                );
                
                System.debug('FnP_SolarFormUtility--> updateDERApplication--> Exception-->\n'+payloadResp.error);
                // DCE-2747 : IP rollsback on error. no need to handle here. 
                Database.rollback(sp);
                FnP_ExtUserObjAccessUtility.integrationlog(payloadResp.error,'SolarFormRecordType','updateDERApplication',JSON.serialize(payload),'Update');
            	result = false;
            }
            
            de.bug('Response');
            de.bug('--------');
            de.bug('statusCode: ' + resStatuCode);
            de.bug('body:\n' + JSON.serializePretty(payloadResp));
            de.bugSend();
            
        } 
        catch(Exception e) {
            String exceptionResult = e.getMessage()+'\n'+e.getStackTraceString()+'\n'+e.getLineNumber();
            System.debug(LoggingLevel.ERROR, 'Exception in updateDERApplication:\n'+exceptionResult);
          // 
          //  return result; Map<String,Object> inputMapDebug = inputMap.clone();
          //  inputMapDebug.remove('FullInverters');
            // DCE-2747 : IP rollsback on error. no need to handle here. 
                Database.rollback(sp);
            FnP_ExtUserObjAccessUtility.integrationlog(exceptionResult,'SolarFormRecordType','updateDERApplication',JSON.serialize(inputMap),'Update');
        	result = false;
        }
        return result;
    }
    
    global void validateNMIandMeterNum(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options){
        try {
            HTTP http = new HTTP();
            
            String reqBody = '';
            String nmi = (String)inputMap.get('nmi');
            nmi = nmi.trim();
            String meterNum = (String)inputMap.get('meter_number');
            meterNum = meterNum.trim();
            // Fetch any input data from omniscript/IP that is needed for getting inverters list!!!  
            System.debug('NMI:: '+nmi+'  :: Meter num ::: '+meterNum);

            DateTime dt = Datetime.now();
            String fmt = dt.format('yyyyMMddhhmm');
            reqBody = '{ "key":"sol","msgid":"SFV-'+fmt+'","nmi":"'+nmi+'","meter_number":"'+meterNum+'"}';
            //reqBody = '{ "key":"sol","msgid":"SOL-2022231231","nmi":"'+nmi+'","meter_number":"'+meterNum+'"}';
            
            validateNMIMeterNumEndpoint__c customSett = validateNMIMeterNumEndpoint__c.getValues('validateNMIMeterNumEndpoint');
            System.debug('CustomSett'+customSett.Endpoint__c);
            HttpRequest httpReq = new HttpRequest();
             httpReq.setEndpoint(customSett.Endpoint__c);
         
            httpReq.setMethod('GET');
            httpReq.setHeader('Accept', '*/*');
            httpReq.setHeader('Content-Type', 'application/json');
            
            httpReq.setClientCertificateName('eains');
            httpReq.setBody(reqBody);
            
            System.debug('reqBody-->'+reqBody);
            string methodname = 'validateNMIandMeterNum';
            string mapdetails = JSON.serialize(inputMap); 
            string operation = 'Update';
            HttpResponse response = http.send(httpReq);
            if (response.getStatusCode() != 200) {

                String responseResult = response.getStatusCode() + ' and status ' + response.getStatus() + ' and body ' + response.getBody();
                System.debug('AMDER NMI Validation Response endpoint'+ httpReq.getEndpoint());
                System.debug('AMDER NMI Validation Response status code returned was not expected: '+responseResult);
                outMap.put('httpTokenResponseError',JSON.deserializeUntyped(response.getBody()));
                FnP_ExtUserObjAccessUtility.integrationlog(responseResult,'SolarFormRecordType',methodname,mapdetails,operation);
                return;
            } else {

                System.debug('AMDER NMI Validation No Error Line 1' + response.getBody());
                System.debug('AMDER NMI Validation No Error Line 2' + response.getHeaderKeys());
                outMap.put('httpTokenResponse',JSON.deserializeUntyped(response.getBody()));
                outMap.put('httpTokenRequestSent',JSON.deserializeUntyped(httpReq.getBody()));
                // if JSON.deserializeUntyped(response.getBody()) contains 'The NMI requested is valid' then it is success. else failure.
                // integrationLogSuccess(null,methodname,mapdetails,operation);
                 // DCE-2747 : No need to Log the validation success. it anyway goes to next page.
                 
                if(!response.getBody().contains('The NMI requested is valid')){
                    FnP_ExtUserObjAccessUtility.integrationlog(response.getBody(),'SolarFormRecordType',methodname,mapdetails,operation);
                }
                 
            }
        } catch(Exception ex) {

            String exceptionResult = ex.getMessage()+'\n'+ex.getStackTraceString()+'\n'+ex.getLineNumber();
            // DCE-2796. In case of exception for AMDER validation, Next button doesnt appear, no error message is displayed.
            outMap.put('httpTokenResponseError',JSON.deserializeUntyped(exceptionResult));
            System.debug(LoggingLevel.ERROR, 'Exception validateNMIandMeterNum:\n'+exceptionResult);
            Map<String,Object> inputMapDebug = inputMap.clone();
            inputMapDebug.remove('FullInverters');
            FnP_ExtUserObjAccessUtility.integrationlog(exceptionResult,'SolarFormRecordType','validateNMIandMeterNum',JSON.serialize(inputMapDebug),'Update');
        }
    }
    
    global void getDERApplicationDetails(Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {

        String methodname='getDERApplicationDetails';
        String mapdetails;
        String operation='Get';

        try {
            String resBody = '';
            String resBodyErr = '';
            String errBody = '';
            JSONGenerator gen = JSON.createGenerator(false);
            List<DER_Agreement__c> lstDERAgmt;
            
            UtilDebug de = new UtilDebug();
            de.bug('DER_REST_Application_v1 - doGet()', true);
            de.bug('Get Application\n');
            
            String appNumber, nmiNumber, email;
            if(inputMap.containsKey('Validation')){
                Map<String,Object>inputDetails=((Map<String, Object>)inputMap.get('Validation'));
                appNumber = (String)inputDetails.get('Text_ReferenceNumber');
                
                // Fixed as part JIRA Ticket DCE-2731
                nmiNumber = (String)inputDetails.get('Number_NMI'); 
                email = (String)inputDetails.get('Email');
                system.debug('inputdetails'+inputDetails);
            }
            
            Boolean isParamMissing = false;
            
            de.bug('Request parameters');
            de.bug('appNumber: ' + appNumber, true);
            de.bug('nmiNumber: ' + nmiNumber, true);
            de.bug('email:     ' + email + '\n', true);
            
            // isBlank validates null, blank and white space values
            if (String.isBlank(appNumber)){
                errBody = 'appNumber, ';
                isParamMissing = true;
            }
            if (String.isBlank(nmiNumber)){
                errBody = errBody + 'nmiNumber, ';
                isParamMissing = true;
            }
            if (String.isBlank(email)){
                errBody = errBody + 'email, ';
                isParamMissing = true;
            }
            
            if (isParamMissing){
                errBody = 'Required Parameter(s) missing - ' + errBody.substringBeforeLast(',');
            }
            else {
                DER_Payload payload = new DER_Payload();
                List<Id> deviceIds = new List<Id>();
                
                String queryCase = '';
                queryCase += UtilDatabase.getAllFields('Case');
                queryCase += ' FROM Case';
                queryCase += ' WHERE Application_Number__c =\''+ appNumber + '\'';
                queryCase += ' AND NMI_fx__c =\''+ nmiNumber + '\'';
                queryCase += ' AND (ContactEmail = \''+ email + '\' OR Auto_Applicant_Email__c = \''+ email + '\' OR Applicant_Email__c = \''+ email + '\')';
                queryCase += ' LIMIT 1';
                List<Case> lstCase = Database.query(queryCase);
                system.debug('lstCase'+lstCase);
                if (!lstCase.isEmpty())
                {
                    payload.derCase = lstCase[0];
                    system.debug('payload.derCase'+payload.derCase.DER_Application__c);
                    // explicit nulls help the JSON payload.
                    UtilDatabase.explicitNulls(payload.derCase);
                    
                    String queryApp = '';
                    queryApp += UtilDatabase.getAllFields('DER_Application__c');
                    queryApp += ' FROM DER_Application__c';
                    queryApp += ' WHERE Id =\''+ payload.derCase.DER_Application__c + '\'';
//        			queryApp += ' AND NMI__r.NMI__c =\''+ nmiNumber + '\'';
                    
                    for (SObject o: Database.query(queryApp))
                    {
                        DER_Application__c der = (DER_Application__c)o;
                        payload.derApp = (DER_Application__c)UtilDatabase.explicitNulls(der);
                        system.debug('payload.derApp inside for'+payload.derApp);
                        break;
                    }
                    system.debug('payload.derApp'+payload.derApp);
                    String queryDERAgmt = '';
                    queryDERAgmt += UtilDatabase.getAllFields('DER_Agreement__c');
                    queryDERAgmt += ' FROM DER_Agreement__c';
                    queryDERAgmt += ' WHERE DER_Application__c =\''+ payload.derCase.DER_Application__c + '\'';
                    lstDERAgmt = Database.query(queryDERAgmt);
                    
                    String queryDevice = '';
                    queryDevice += UtilDatabase.getAllFields('Device__c');
                    queryDevice += ' FROM Device__c';
                    queryDevice += ' WHERE DER_Application__c =\''+ payload.derCase.DER_Application__c + '\'';
                    queryDevice += ' OR Parent_Device__r.DER_Application__c =\''+ payload.derCase.DER_Application__c + '\'';
                    queryDevice += ' ORDER BY Device_Hierarchy__c ASC';
                    
                    List<SObject> objList = Database.query(queryDevice);
                    Map <Id, String> mapRTIdName = UtilDatabase.getRecordTypes();
                    
                    if (!objList.isEmpty())
                    {
                        payload.devices =  new List<Device__c>();
                        for (SObject o: objList)
                        {
                            // Set EAI Fields
                            Device__c device = (Device__c)o;
                            device.EAI_Type__c = mapRTIdName.get(device.RecordTypeId);
                            device.EAI_Ref__c = device.Id;
                            device.EAI_Parent__c = null;
                            if (device.Parent_Device__c != null)
                                device.EAI_Parent__c = device.Parent_Device__c;
                            
                            // explicit nulls help the JSON payload.
                            UtilDatabase.explicitNulls(device);
                            
                            payload.devices.add(device);
                        }
                    }
                }
                
                if (payload.derApp == null || payload.derCase == null)
                {
                    System.debug('payload.derApp == null || payload.derCase == null'+ payload.derApp+' :: '+ payload.derCase );
                    errBody = 'No Record(s) Found';
                }
                else
                {
                    if (payload.derApp.NMI__c != null){
                        payload.nmi = (Connection_Point__c) UtilDatabase.getRecord(payload.derApp.NMI__c);
                        UtilDatabase.explicitNulls(payload.nmi); // explicit nulls help the JSON payload.
                    }
                    
                    if (payload.derCase.Customer__c  != null){
                        payload.customer= (Account) UtilDatabase.getRecord(payload.derCase.Customer__c );
                        UtilDatabase.explicitNulls(payload.customer); // explicit nulls help the JSON payload.
                    }
                    
                    if (payload.derCase.AccountId != null){
                        payload.installer= (Account) UtilDatabase.getRecord(payload.derCase.AccountId);
                        UtilDatabase.explicitNulls(payload.installer); // explicit nulls help the JSON payload.
                    }
                    
                    if (payload.derCase.ContactId != null){
                        payload.installerContact= (Contact) UtilDatabase.getRecord(payload.derCase.ContactId);
                        UtilDatabase.explicitNulls(payload.installerContact); // explicit nulls help the JSON payload.
                    }
                    
                    if (payload.derCase.Representative__c != null)
                    {
                        payload.representative = (Contact) UtilDatabase.getRecord(payload.derCase.Representative__c);
                        UtilDatabase.explicitNulls(payload.representative); // explicit nulls help the JSON payload.
                        
                        if (payload.representative != null && payload.representative.AccountId != null)
                        {
                            payload.representativeCompany = (Account)UtilDatabase.getRecord(payload.representative.AccountId);
                            UtilDatabase.explicitNulls(payload.representativeCompany); // explicit nulls help the JSON payload.
                        }
                    }
                    
                    if (!lstDERAgmt.isEmpty()){
                        payload.derAgreement = lstDERAgmt[0];
                        UtilDatabase.explicitNulls(payload.derAgreement); // explicit nulls help the JSON payload.
                    }
                    
                    resBody = JSON.serializePretty(payload, false);
                }
            }

            if (String.isNotBlank(errBody))
            {
                
                gen.writeStartObject();
                gen.writeStringField('error', errBody);
                gen.writeEndObject();
                resBody = gen.getAsString();
                outMap.put('DERApplicationError',JSON.deserializeUntyped(resBody)); // Setting seperate error node, since there is error. DCE-2658
                outMap.put('DERApplication',null); // Setting blank payload, since there is error. DCE-2658
                FnP_ExtUserObjAccessUtility.integrationlog(resBody,'SolarFormRecordType',methodname,JSON.serialize(inputMap),operation);
            }
            else {
                de.bug('Response');
                
                de.bug(resBody);
                de.bugSend();
                outMap.put('DERApplication',JSON.deserializeUntyped(resBody));
              outMap.put('DERApplicationError',null); // Setting seperate error node, since there is error. DCE-2658
               // integrationLogSuccess(resBody,methodname,resBody,operation);
               // DCE-2747 No need to log success, since it navigates to next page on success. 
            }
        }
        catch(Exception e) {
            Map<String,Object> inputMapDebug = inputMap.clone();
            inputMapDebug.remove('FullInverters');
            FnP_ExtUserObjAccessUtility.integrationlog(e.getMessage()+' '+e.getStackTraceString()+' '+e.getLineNumber(),'SolarFormRecordType',methodname,JSON.serialize(inputMapDebug),operation);
        }
    }

    @TestVisible   
    private static Id findConPoint(String nmiNum) {
        
        List<Connection_Point__c> cp = new List<Connection_Point__c>([SELECT Id FROM Connection_Point__c WHERE NMI__c =:nmiNum]);
        
        return !cp.isEmpty() ? cp[0].Id : null;
    }
    
    @TestVisible  private static Id findRep(String email) {
        Id repId;
        
        // Match only DER contacts
        // Note: Wizard is creating orphaned Reps. This query attempts to find these, also.
        
        for (Contact rep: [
            SELECT Id
            FROM Contact
            WHERE Email = :email
            AND IsPersonAccount = false
            AND (
                (
                    Account.RecordType.DeveloperName = :ACCOUNT_RECORDTYPE_SERVICEPROVIDER
                    AND Account.Type IN :ACCOUNT_SERVICEPROVIDER_TYPES
                )
                OR Title IN :CONTACT_REP_TITLES
            )
            LIMIT 1
        ]) {
            system.debug('rep:::'+rep);
            repId = rep.Id;
            break;
        }
        
        return repId;
    }
    
    @TestVisible private static Id findServProvider(String abn) {
        // Note by using ABN__c field, we automatically match only DER SPs
        List<Account> serviceProviders = [
            SELECT Id
            FROM Account
            WHERE ABN__c = :abn
            AND RecordType.DeveloperName = :ACCOUNT_RECORDTYPE_SERVICEPROVIDER LIMIT 1
        ];

        return !serviceProviders.isEmpty() ? serviceProviders[0].Id : null; 
    }
    
    @TestVisible private static Id findInstallerContact(String accNum, String accType, String email){
        // Match only DER contacts
        List<Contact> instCon = new List<Contact>([
            SELECT Id
            FROM Contact
            WHERE Accreditation_Number__c = :accNum
            AND Acceditation_Type__c = :accType
            AND Email = :email
            AND Account.RecordType.DeveloperName = :ACCOUNT_RECORDTYPE_SERVICEPROVIDER
            AND Account.Type IN :ACCOUNT_SERVICEPROVIDER_TYPES
        ]);

        return !instCon.isEmpty() ? instCon[0].Id : null; 
    }

    @TestVisible
    private static void linkAccWithContact(Id accId, Id contId){
        AccountContactRelation ACR;
        try {
            if (contId == null || accId == null)
            {
                System.debug('linkAccWithContact---> either accountId or contactId is null. accId: '+accId+' contId: '+contId);
                return;
            }

            for (AccountContactRelation accConRel: [
                SELECT Id, IsDirect
                FROM AccountContactRelation
                WHERE AccountId = :accId
                AND ContactId = :contId
            ]) {
                ACR = accConRel;
            }
            
            if (ACR == null)
            {
                // No relationship is established, so create one!
                ACR = new AccountContactRelation(AccountId = accId, ContactId = contId);
                insert ACR;
            }
           // integrationLogSuccess(null,'linkAccWithContact',JSON.serialize(ACR),'Create');
           // DCE-2747 Main funciton will add the success log. no need to log here.
        }
        catch(Exception ex){
            FnP_ExtUserObjAccessUtility.integrationlog(ex.getMessage()+'\n'+ex.getStackTraceString()+'\n'+ex.getLineNumber(),'SolarFormRecordType','linkAccWithContact',JSON.serialize(ACR), 'Create');
        }
    }

    @TestVisible
    private static void insertCase(Case derCase){
        try{
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = false;
            derCase.setOptions(dmo);
            insert derCase;
           // integrationLogSuccess(null,'insertCase',JSON.serialize(derCase),'Create');
           // DCE-2747 No need to log here. Log in the main function.
        }
        catch(Exception ex){
            String exceptionResult = ex.getMessage()+'\n'+ex.getStackTraceString()+'\n'+ex.getLineNumber();
            System.debug(LoggingLevel.ERROR, 'Exception insertCase:\n'+exceptionResult);
            FnP_ExtUserObjAccessUtility.integrationlog(exceptionResult,'SolarFormRecordType','insertCase',JSON.serialize(derCase), 'Create');
        }
    }
    
    @TestVisible
    private static void insertUpdateNMI(Connection_Point__c nmi, boolean isUpdate){
        Trig_Connection_Point.TrigDisabled = true;
        
        if (isUpdate)
            update nmi;
        else
            insert nmi;
        
        DER_Connection_Point_Util.PopulateExternalNMIRef(new Set<Id>{nmi.Id}, null);
    }
    
    private static Id queueId;
    @TestVisible  private static Id getDefaultCaseQueueOwner(Case derCase){
        if (queueId == null && derCase != null && derCase.DER_Application_Scenario__c != null)
        {
            String queueName;
            
            if (derCase.DER_Application_Scenario__c == CASE_SCENARIO_AUTO)
                queueName = CASE_DEFAULT_QUEUE_AUTO;
            else if (derCase.DER_Application_Scenario__c == CASE_SCENARIO_MANUAL)
                queueName = CASE_DEFAULT_QUEUE_MANUAL;
            
            for (Group g: [SELECT Id FROM Group WHERE Name = :queueName AND Type = 'Queue' LIMIT 1])
                queueId = g.Id;
        }
        
        return queueId;
    }

    @TestVisible 
    private static void runDeviceRollup(Case derCase) {
        UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = false; // reenable roll up trigger
        UtilFieldCalcs.CalcDERAppPhaseTotals(new Set<Id>{derCase.DER_Application__c}, false);
    }

    @TestVisible
    private static DER_Payload_Response processDevices(DER_Payload payload, DER_Payload_Response payloadResp) {
        try {
            if(payload.devices != null)
            {
                String deviceErrors = '';
                
                // Iterate L2 and L3 devices
                Map<String, Device__c> L2_Devices = new Map<String, Device__c>();
                Map<String, Device__c> L3_Devices = new Map<String, Device__c>();
                Map<id, Device__c> L2_DevicesForDelete = new Map<id, Device__c>();
				list<Device__c> LE2DeviceDelete = new list<Device__c>();
               list<Device__c> LE3DeviceDelete = new list<Device__c>();

                Map<id, Device__c> L3_DevicesForDelete = new Map<id, Device__c>();

                Set<String> EAIRefs = new Set<String>();
                Set<String> DeviceRTs = new Set<String>{'Device_L2', 'Device_L3'};
                    Map<String, Id> mapRTNameId = UtilDatabase.getRecordTypeNames('Device__c');
                
                Boolean hasErrors = false;
				
                List<Device__c> allDevices = payload.devices;
                
                System.debug('allDevices:::'+allDevices);
                
                for (Device__c device: allDevices)
                {
                    System.debug('Device:::'+device);
                    
                    if (device.EAI_Ref__c == null)
                    {
                        // Error: need a reference
                        deviceErrors += 'Error: Device(s) missing EAI_Ref__c\n';
                        hasErrors = true;
                        break;
                    }
                    
                    if (EAIRefs.contains(device.EAI_Ref__c))
                    {
                        // Error: reference duplicated
                        deviceErrors += 'Error: [' + device.EAI_Ref__c + '] Device EAI_Ref__c duplication\n';
                        hasErrors = true;
                        continue;
                    }

                    EAIRefs.add(device.EAI_Ref__c);
                    
                    if (device.EAI_Type__c == null)
                    {
                        // Error: need a type
                        deviceErrors += 'Error: [' + device.EAI_Ref__c + '] Device missing EAI_Type__c\n';
                        hasErrors = true;
                        continue;
                    }
                    
                    if (!DeviceRTs.contains(device.EAI_Type__c))
                    {
                        // Error: invalid type
                        deviceErrors += 'Error:For manufacturer ['+device.Manufacturer__c+'] '+ device.EAI_Ref__c + '] EAI_Type__c invalid\n';
                        hasErrors = true;
                        continue;
                    }
                    
                    if (device.EAI_Type__c == 'Device_L3' && device.EAI_Parent__c == null)
                    {
                        // Error: need a parent for L3s
                        deviceErrors = 'Error: [' + device.EAI_Ref__c + '] L3 Device missing EAI_Parent__c\n';
                        hasErrors = true;
                        continue;
                    }
                    
                    if (device.EAI_Type__c == 'Device_L2' && device.EAI_Parent__c != null && device.EAI_Parent__c != '')
                    {
                        // Error: parent not allowed for L2
                        deviceErrors = 'Error: [' + device.EAI_Ref__c + '] L2 Device EAI_Parent__c must be null\n';
                        hasErrors = true;
                        continue;
                    }

                    if (device.EAI_Type__c == 'Device_L2' && (device.AC_Equip_Sub_Type__c == null || device.AC_Equip_Sub_Type__c == ''))
                    {
                        // Error: sub type mandatory for L2
                        deviceErrors = 'Error: [' + device.EAI_Ref__c + '] L2 Device AC_Equip_Sub_Type__c for ['+ device.Manufacturer__c +'] must be entered\n';
                        hasErrors = true;
                        continue;
                    }

                    if (device.EAI_Type__c == 'Device_L2' && device.AC_Equip_Sub_Type__c == 'Battery' && device.AC_DC_Coupling__c == null)
                    {
                        // Error: sub type mandatory for L2
                        deviceErrors = 'Error: [' + device.EAI_Ref__c + '] L2 Device AC_DC_Coupling__c for ['+ device.Manufacturer__c +'] must be entered\n';
                        hasErrors = true;
                        continue;
                    }
                    
                    // Set record type Id
                    device.RecordTypeId = mapRTNameId.get(device.EAI_Type__c);
                    
                    // Store in correct map
                    system.debug('device.EAI_Type__c ###'+device.EAI_Type__c);
                    if (device.EAI_Type__c == 'Device_L2'){
                        System.debug('Line 1 Device L2 ::: device'+ device);
                        L2_Devices.put(device.EAI_Ref__c, device);
                        //L2_DevicesForDelete.put(device.EAI_Ref__c, device);
                        //system.debug('L2_DevicesForDelete-->'+L2_DevicesForDelete);
                    }
                    else if (device.EAI_Type__c == 'Device_L3'){
                        
                        L3_Devices.put(device.EAI_Ref__c, device);

                        if (device.EAI_Parent__c != null) {
                            System.debug('Device L3 ::: device'+ device);
                            // L3_DevicesForDelete.put(device.EAI_Parent__c, device);
                            // system.debug('L3_DevicesForDelete-->'+L3_DevicesForDelete);
                        }
                    }
                }
                
                system.debug('payload.derApp.Id-->'+payload.derApp.Id);
                String queryDevice = '';
                queryDevice += UtilDatabase.getAllFields('Device__c');
                queryDevice += ' FROM Device__c';
                queryDevice += ' WHERE DER_Application__c =\''+ payload.derApp.Id + '\'';
                queryDevice += ' OR Parent_Device__r.DER_Application__c =\''+ payload.derApp.Id + '\'';
                queryDevice += ' ORDER BY Device_Hierarchy__c ASC';

                List<Device__c> objList = Database.query(queryDevice);            
                system.debug('newobjlist-->'+objList);
                
                if (!objList.isEmpty())
                {
                    for (Device__c o: objList)
                    {
                        if(!L3_Devices.keyset().contains(o.id) && o.Parent_Device__c != null)
                        {
                            system.debug('not contains L3-->');
                            LE3DeviceDelete.add(o);  
                            //L3_Devices.remove(o.id);
                        }

                        //L3_Devices.remove(LE3DeviceDelete);
                        // L3_Devices.keySet().removeAll(LE3DeviceDelete);
                        if(!L2_Devices.keyset().contains(o.id) && o.Parent_Device__c == null)
                        {
                            system.debug('not contains L2-->');
                            LE2DeviceDelete.add(o);
                            //L2_Devices.remove(o.id);
                        }
                    }
                    
                    system.debug('LE2DeviceDelete-->'+LE2DeviceDelete);
                    system.debug('LE3DeviceDelete-->'+LE3DeviceDelete);
                    
                    if (!LE3DeviceDelete.isEmpty()){
                        delete LE3DeviceDelete;
                    }
                    if (!LE2DeviceDelete.isEmpty()){
                        delete LE2DeviceDelete;
                    }
                }
                
                // Validate L3s
                if (!hasErrors)
                {
                    for (Device__c device: L3_Devices.values())
                    {
                        // Check parent exists
                        if (!L2_Devices.containsKey(device.EAI_Parent__c))
                        {
                            // Error: parent not found for L3
                            deviceErrors += 'Error: [' + device.EAI_Ref__c + '] L3 Device EAI_Parent__c not found: ' + device.EAI_Parent__c;
                            hasErrors = true;
                            continue;
                        }
                    }
                }
                
                if (hasErrors)
                {
                    // throw
                    System.debug('Process Device Hierarchy Fatal Error: ' +  deviceErrors);
                    throw new DERApplicationAPIException(deviceErrors);
                }
                else
                {
                    // all good.
                    
                    // Process L2s
                    for (Device__c device: L2_Devices.values())
                    {
                        
                        // Set DER App
                        device.DER_Application__c = payload.derApp.Id;
                        
                        // Clear flags
                        device.EAI_Type__c   = null;
                        device.EAI_Ref__c    = null;
                        device.EAI_Parent__c = null;
                        
                    }
                    System.debug('L2 Values:::'+L2_Devices.values());
                    System.debug('Device__c.Id:::'+Device__c.Id);
                    Database.UpsertResult[] L2_results = Database.upsert(L2_Devices.values(), Device__c.Id,true);
                    for (Database.UpsertResult test : L2_results){
                        if(test.isSuccess()){
                            system.debug('Success:::' + Device__c.Id + 'Created/Updated');
                            
                        }else{
                            System.debug('Error:::' + Device__c.Id + ' has error');
                        }}
                    
                    system.debug('L3 Devices'+L3_Devices);
                    // Process L3s
                    for (Device__c device: L3_Devices.values())
                    {
                        // Set parent
                        device.Parent_Device__c = L2_Devices.get(device.EAI_Parent__c).Id;
                        device.DER_Application__c = payload.derApp.Id;
                        // Clear flags
                        device.EAI_Type__c   = null;
                        device.EAI_Ref__c    = null;
                        device.EAI_Parent__c = null;
                    }
                    System.debug('Device__c.Id ::' + Device__c.Id);
                    Database.UpsertResult[] L3_results = Database.upsert(L3_Devices.values(), Device__c.Id, true);
                    
                    List<Database.UpsertResult> all_results = new List<Database.UpsertResult>();
                    all_results.addAll(L2_results);
                    all_results.addAll(L3_results);
                    
                    for (Database.UpsertResult result: all_results)
                    {
                        if (result.isSuccess())
                        {
                            if (result.isCreated())
                            {
                                System.debug(result.Id +' was created');
                                System.debug(result +' of uspert ');
                                payloadResp.success.setDeviceInsert(result.Id);
                            }
                            else
                            {
                                System.debug(result.Id +' was updated');
                                payloadResp.success.setDeviceUpdate(result.Id, result.Id);
                            }
                        }
                    }
                }
            }

            // integrationLogSuccess(JSON.serialize(payloadResp),'processDevices',JSON.serialize(payload),'Create');
            // DCE-2747 : No need to log here, log at the main function.
          //  return payloadResp; 
        }
        catch(Exception ex) {
            System.debug('Exception processDevices() getMessage: '+ex.getMessage());
            System.debug('Exception processDevices() getStackTraceString: '+ex.getStackTraceString());
            System.debug('Exception processDevices() getLineNumber: '+ex.getLineNumber());
            System.debug('Exception processDevices() payload.devices: '+JSON.serializePretty(payload.devices));
            FnP_ExtUserObjAccessUtility.integrationlog(ex.getMessage()+' '+ex.getStackTraceString()+' '+ex.getLineNumber(),'SolarFormRecordType','processDevices',JSON.serialize(payload), 'Create');
        	// DCE-2747 : No need to throw exception. 
            //    throw ex;
                
            payloadResp.error = ex.getMessage()+' '+ex.getStackTraceString()+' '+ex.getLineNumber(); 
        //    throw new DERApplicationAPIException(ex.getMessage()+' '+ex.getStackTraceString()+' '+ex.getLineNumber());
        }
        
        return payloadResp; 
    }
     // DCE-2747 : Use FnP_ExtUserObjAccessUtility.integrationlog funciton. remove this. 
/*    public static void integrationlog(string res,string methodname,string mapdetails,string operation){
        Id recordtypeId=Schema.SObjectType.Integration_Log__c.getRecordTypeInfosByName().get('SolarFormRecordType').getRecordTypeId();
        //Integration Task & log insertion starts here//
        list<Integration_Task__c> integrationTasks = new list<Integration_Task__c>();
        Integration_Task__c intgTask = new Integration_Task__c();
        intgTask.Operation__c=operation;
        intgTask.Status__c='Failed';
        intgTask.SObject__c='Project__c';
        intgTask.type__c=methodname;
        integrationTasks.add(intgTask);
        insert integrationTasks;
            
        Integer maxLength = 32750;
        //  intgTask.recordtypeId=recordtypeId;
        list<Integration_Log__c> loglist= new list<Integration_Log__c>();
        for(Integration_Task__c Task:integrationTasks) {
            Integration_Log__c log= new Integration_Log__c();
            log.Integration_Task__c=Task.id;
            log.Type__c=Task.Type__c;
            log.Application_Type__c ='Solar Form';
            log.RecordTypeId=recordtypeId;
            log.Status__c=Task.Status__c;
            log.ReqBody__c=mapdetails.length() > maxLength ? mapdetails.substring(0, maxLength) : mapdetails;
            log.Error_Message__c=res;
            loglist.add(log);
        }

        insert loglist;  
    } 
*/
    // DCE-2747 : Use FnP_ExtUserObjAccessUtility.integrationLogSuccess funciton. remove this. 
/*    public static String integrationLogSuccess(string res,string methodName,string mapDetails,string operation) {

        Id recordtypeId = Schema.SObjectType.Integration_Log__c.getRecordTypeInfosByName().get('SolarFormRecordType').getRecordTypeId();
        //Integration Task & log insertion starts here//
        Integration_Task__c intgTask = new Integration_Task__c();
        intgTask.Operation__c = operation;
        intgTask.Status__c = 'Successful';
        intgTask.SObject__c = 'Project__c';
        intgTask.type__c = methodName;
        insert intgTask;
        
        Integer maxLength = 32000;
        Integration_Log__c log = new Integration_Log__c();
        log.Integration_Task__c = intgTask.id;
        log.Type__c = intgTask.Type__c;
        log.Application_Type__c ='Solar Form';
        log.RecordTypeId = recordtypeId;
        log.Status__c = intgTask.Status__c;
        log.ReqBody__c = mapDetails.length() > maxLength ? mapDetails.substring(0, maxLength) : mapDetails;
        if(res!=null & res!=''){
            log.Error_Message__c = res.length() > maxLength ? res.substring(0, maxLength) : res;
        }
        //log.Error_Message__c = res.length() > maxLength ? res.substring(0, maxLength) : res;
        //log.Error_Message__c = res;
        insert log;
        return log.Id;
    } 
*/
}