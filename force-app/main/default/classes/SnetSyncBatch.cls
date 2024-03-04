global class SnetSyncBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Schedulable {
	private boolean isProcessCheck = false;
    public  String  whereCondition = '';
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // Query records from Object1 and Object2
        Boolean syncToAusnet = false;
        System.debug('whereCondition'+whereCondition);
        String queryRecord = '';
        queryRecord += UtilDatabase.getAllFields('DER_Application__c');
        queryRecord += ',('+UtilDatabase.getAllFields('Case');
        queryRecord += ' FROM Cases__r ),';
        queryRecord += '('+UtilDatabase.getAllFields('Device__c');
        queryRecord += ' FROM Devices__r )';
        queryRecord += ' FROM DER_Application__c WHERE '+whereCondition+' Synced_To_SNET__c='+syncToAusnet+' ORDER BY CreatedDate ASC LIMIT 5000';
        return Database.getQueryLocator(queryRecord);
    }
    global void execute(Database.BatchableContext bc, List<DER_Application__c> scope) {
        List<DER_Application__c> recordsToUpdate = new List<DER_Application__c>();
        List<DER_Application__c> derRecords = (List<DER_Application__c>)scope;
        Map<Id, String> idAppNoMap = new Map<Id, String>();
        List<object> dataToSend = new List<object>();
        isProcessCheck = true;
        for (DER_Application__c s : derRecords) {
            idAppNoMap.put(s.Id,s.Case_Application_Number__c);
            Map<String, Object> applicationData = new Map<String, Object>();
            applicationData.put('key','der');
            DateTime todaysDate = System.today();
            String todaysDateStr = todaysDate.format('yyyyMMdd');
            todaysDateStr = 'SOL-'+todaysDateStr+String.valueof(Integer.valueof((Math.random() * 1000000)));
            //System.debug('msgid'+todaysDateStr);
            applicationData.put('msgid',todaysDateStr);
            Map<String, Object> applicationInfo = new Map<String, Object>();
            for (Case c : s.Cases__r) {
				applicationInfo.put('application_id',c.Application_Number__c);
				applicationInfo.put('due_date', c.Post_Installation_Expiry_Date__c);
				applicationInfo.put('type', c.Type);
                applicationInfo.put('date_insert', c.CreatedDate.format('yyyy-MM-dd HH:mm:ss'));
				applicationInfo.put('scenario', c.DER_Application_Scenario__c);
                System.debug('scenario'+c.DER_Application_Scenario__c);
				applicationInfo.put('applicant_type', c.Applicant_Type__c);
				applicationInfo.put('responsible_party_type', c.Responsible_Party__c);

                  //FEBAU-217
				applicationInfo.put('fe_reg_status', c.FE_Reg_Status__c);
				
				Map<String, Object> meterInfo = new Map<String, Object>();
				meterInfo.put('nmi', c.NMI_fx__c);
                //System.debug('nmi::'+c.NMI_fx__c);
				meterInfo.put('meter_number', c.Meter_fx__c);
				applicationInfo.put('meterInfo', meterInfo);
				
				Map<String, Object> contactInfo = new Map<String, Object>();
				contactInfo.put('email', c.Installer_Email__c);
				contactInfo.put('phone', c.Installer_Phone__c);
				Map<String, Object> nameInfo = new Map<String, Object>();
				nameInfo.put('title', null);
				nameInfo.put('first_name', c.Installer_First_Name__c);
				nameInfo.put('middle_name',null);
				nameInfo.put('last_name', c.Installer_Last_Name__c);
				contactInfo.put('nameInfo', nameInfo);
				applicationInfo.put('contactInfo', contactInfo);
				
				Map<String, Object> installerInfo = new Map<String, Object>();
				installerInfo.put('accreditation_number', c.Installer_Accreditation_No__c);
				installerInfo.put('name', c.Installer_First_Name__c+' '+c.Installer_Last_Name__c);
				installerInfo.put('company', c.Installer_Company__c);
				installerInfo.put('abn', c.Installer_ABN__c);
				Map<String, Object> installerNameInfo = new Map<String, Object>();
				installerNameInfo.put('title', null);
				installerNameInfo.put('first_name', c.Installer_First_Name__c);
				installerNameInfo.put('middle_name', c.Installer_Middle_Name__c);
				installerNameInfo.put('last_name', c.Installer_Last_Name__c);
				installerInfo.put('nameInfo', installerNameInfo);
				Map<String, Object> installerContactInfo = new Map<String, Object>();
				installerContactInfo.put('email',c.Installer_Email__c);
				installerContactInfo.put('phone', c.Installer_Phone__c);
				Map<String, Object> installerNameInfo1 = new Map<String, Object>();
				installerNameInfo1.put('title', null);
				installerNameInfo1.put('first_name', c.Installer_First_Name__c);
				installerNameInfo1.put('middle_name', c.Installer_Middle_Name__c);
				installerNameInfo1.put('last_name', c.Installer_Last_Name__c);
				installerContactInfo.put('nameInfo', installerNameInfo1);
				installerInfo.put('contactInfo', installerContactInfo);
				Map<String, Object> installerAddressInfo = new Map<String, Object>();
				installerAddressInfo.put('address_line_1', c.Installer_AddressLine1__c);
				installerAddressInfo.put('address_line_2', c.Installer_AddressLine2__c);
				installerAddressInfo.put('postcode', c.Installer_Postcode__c);
				installerAddressInfo.put('suburb', c.Installer_Suburb__c);
				installerAddressInfo.put('state', c.Installer_State__c);
				installerInfo.put('addressInfo', installerAddressInfo);
				applicationInfo.put('installerInfo', installerInfo);


				

				Map<String, Object> customerInfo = new Map<String, Object>();
				customerInfo.put('name', c.Customer_First_Name__c+' '+c.Customer_Last_Name__c);
				customerInfo.put('company', c.Customer_Company__c);
                customerInfo.put('accreditation_number', c.Customer_Accreditation_No__c);
				customerInfo.put('abn', c.Customer_ABN__c);
				Map<String, Object> customerNameInfo = new Map<String, Object>();
				customerNameInfo.put('title', null);
				customerNameInfo.put('first_name', c.Customer_First_Name__c);
				customerNameInfo.put('middle_name', null);
				customerNameInfo.put('last_name', c.Customer_Last_Name__c);
				customerInfo.put('nameInfo', customerNameInfo);
				Map<String, Object> customerContactInfo = new Map<String, Object>();
				customerContactInfo.put('email', c.Customer_Email_Fx__c);
				customerContactInfo.put('phone', c.Customer_Phone__c);
				Map<String, Object> customerNameInfo1 = new Map<String, Object>();
				customerNameInfo1.put('title', null);
				customerNameInfo1.put('first_name', c.Customer_First_Name__c);
				customerNameInfo1.put('middle_name', null);
				customerNameInfo1.put('last_name', c.Customer_Last_Name__c);
				customerContactInfo.put('nameInfo', customerNameInfo1);
				customerInfo.put('contactInfo', customerContactInfo);
				Map<String, Object> supplyAddressInfo = new Map<String, Object>();
				supplyAddressInfo.put('address_line_1', c.Customer_Supply_AddressLine1__c);
				supplyAddressInfo.put('address_line_2', c.Customer_Supply_AddressLine2__c);
				supplyAddressInfo.put('postcode', c.Customer_Supply_Postcode__c);
				supplyAddressInfo.put('suburb', c.Customer_Supply_Suburb__c);
				supplyAddressInfo.put('state', c.Customer_Supply_State__c);
				customerInfo.put('supplyAddressInfo', supplyAddressInfo);
				Map<String, Object> mailingAddressInfo = new Map<String, Object>();
				mailingAddressInfo.put('address_line_1', c.Customer_Mailing_AddressLine1__c);
				mailingAddressInfo.put('address_line_2', c.Customer_Mailing_AddressLine2__c);
				mailingAddressInfo.put('postcode', c.Customer_Mailing_Postcode__c);
				mailingAddressInfo.put('suburb', c.Customer_Mailing_Suburb__c);
				mailingAddressInfo.put('state', c.Customer_Mailing_State__c);
				customerInfo.put('mailingAddressInfo', mailingAddressInfo);
				customerInfo.put('same_as_mailing', true);
				applicationInfo.put('customerInfo', customerInfo);
                
                if(c.Applicant_Type__c == 'Installer'){
                    applicationInfo.put('applicantInfo', installerInfo);
                }
                if(c.Applicant_Type__c == 'Customer'){
                    Map<String, Object> ApplicantCustomerInfo = new Map<String, Object>(customerInfo);
                    Map<String, Object> ApplicantCustomerAddressInfo = (Map<String, Object>)customerInfo.get('mailingAddressInfo');
                    ApplicantCustomerInfo.remove('mailingAddressInfo');
                    ApplicantCustomerInfo.remove('supplyAddressInfo');
                    ApplicantCustomerInfo.remove('same_as_mailing');
                    ApplicantCustomerInfo.put('addressInfo', ApplicantCustomerAddressInfo);
                    applicationInfo.put('applicantInfo', ApplicantCustomerInfo);
                }
                if(c.Applicant_Type__c == 'Representative' || c.Applicant_Type__c == null){                   
                    Map<String, Object> applicantInfo = new Map<String, Object>();
                    applicantInfo.put('accreditation_number', c.Representative_Accreditation_No__c);
                    applicantInfo.put('name', c.Representative_First_Name__c+' '+c.Representative_Last_Name__c);
                    applicantInfo.put('company', c.Representative_Company__c);
                    applicantInfo.put('abn', c.Representative_ABN__c);
                    Map<String, Object> applicantNameInfo = new Map<String, Object>();
                    applicantNameInfo.put('title', null);
                    applicantNameInfo.put('first_name', c.Representative_First_Name__c);
                    applicantNameInfo.put('middle_name', null);
                    applicantNameInfo.put('last_name', c.Representative_Last_Name__c);
                    applicantInfo.put('nameInfo', applicantNameInfo);
                    Map<String, Object> applicantContactInfo = new Map<String, Object>();
                    contactInfo.put('email', c.Representative_Email__c);
                    contactInfo.put('phone', c.Representative_Phone__c);
                    Map<String, Object> applicantNameInfo1 = new Map<String, Object>();
                    applicantNameInfo1.put('title', null);
                    applicantNameInfo1.put('first_name', c.Representative_First_Name__c);
                    applicantNameInfo1.put('middle_name', null);
                    applicantNameInfo1.put('last_name', c.Representative_Last_Name__c);
                    applicantContactInfo.put('nameInfo', applicantNameInfo1);
                    applicantInfo.put('contactInfo', applicantContactInfo);
                    Map<String, Object> applicantAddressInfo = new Map<String, Object>();
                    applicantAddressInfo.put('address_line_1', c.Representative_AddressLine1__c);
                    applicantAddressInfo.put('address_line_2', c.Representative_AddressLine2__c);
                    applicantAddressInfo.put('postcode', c.Representative_Postcode__c);
                    applicantAddressInfo.put('suburb', c.Representative_Suburb__c);
                    applicantAddressInfo.put('state', c.Representative_State__c);
                    applicantInfo.put('addressInfo', applicantAddressInfo);
                    applicationInfo.put('applicantInfo', applicantInfo);
                }
                
                if(c.Responsible_Party__c == 'Installer'){
                    applicationInfo.put('responsiblePartyInfo', installerInfo);
                }
                if(c.Responsible_Party__c == 'Customer'){
                    Map<String, Object> RepresentativeCustomerInfo = new Map<String, Object>(customerInfo);
                    Map<String, Object> RepresentativeCustomerAddressInfo = (Map<String, Object>)customerInfo.get('mailingAddressInfo');
                    RepresentativeCustomerInfo.remove('mailingAddressInfo');
                    RepresentativeCustomerInfo.remove('supplyAddressInfo');
                    RepresentativeCustomerInfo.remove('same_as_mailing');
                    RepresentativeCustomerInfo.put('addressInfo', RepresentativeCustomerAddressInfo);
                    applicationInfo.put('responsiblePartyInfo', RepresentativeCustomerInfo);
                }
                if(c.Responsible_Party__c == 'Representative' || c.Responsible_Party__c == null  ){
                    Map<String, Object> responsiblePartyInfo = new Map<String, Object>();
                    responsiblePartyInfo.put('accreditation_number', c.Representative_Accreditation_No__c);
                    responsiblePartyInfo.put('name', c.Representative_First_Name__c+' '+c.Representative_Last_Name__c);
                    responsiblePartyInfo.put('company', c.Representative_Company__c);
                    responsiblePartyInfo.put('abn', c.Representative_ABN__c);
                    Map<String, Object> responsiblePartyNameInfo = new Map<String, Object>();
                    responsiblePartyNameInfo.put('title', null);
                    responsiblePartyNameInfo.put('first_name', c.Representative_First_Name__c);
                    responsiblePartyNameInfo.put('middle_name', null);
                    responsiblePartyNameInfo.put('last_name', c.Representative_Last_Name__c);
                    responsiblePartyInfo.put('nameInfo', responsiblePartyNameInfo);
                    Map<String, Object> responsiblePartyContactInfo = new Map<String, Object>();
                    responsiblePartyContactInfo.put('email', c.Representative_Email__c);
                    responsiblePartyContactInfo.put('phone', c.Representative_Phone__c);
                    Map<String, Object> responsiblePartyNameInfo1 = new Map<String, Object>();
                    responsiblePartyNameInfo1.put('title', null);
                    responsiblePartyNameInfo1.put('first_name', c.Representative_First_Name__c);
                    responsiblePartyNameInfo1.put('middle_name', null);
                    responsiblePartyNameInfo1.put('last_name', c.Representative_Last_Name__c);
                    responsiblePartyContactInfo.put('nameInfo', responsiblePartyNameInfo1);
                    responsiblePartyInfo.put('contactInfo', responsiblePartyContactInfo);
                    Map<String, Object> addressInfo = new Map<String, Object>();
                    addressInfo.put('address_line_1', c.Representative_AddressLine1__c);
                    addressInfo.put('address_line_2', c.Representative_AddressLine2__c);
                    addressInfo.put('postcode', c.Representative_Postcode__c);
                    addressInfo.put('suburb', c.Representative_Suburb__c);
                    addressInfo.put('state', c.Representative_State__c);
                    responsiblePartyInfo.put('addressInfo', addressInfo);
                    applicationInfo.put('responsiblePartyInfo', responsiblePartyInfo);
                }
            }
			
			
			Map<String, Object> systemInfo = new Map<String, Object>();
			systemInfo.put('has_solar', (s.Has_Solar__c) ? 'true' : 'false');
			systemInfo.put('has_battery', (s.Has_Battery__c) ? 'true' : 'false');
			systemInfo.put('installation_type', s.Case_Type__c);
			systemInfo.put('existing_generation', s.Import_Existing_Assets__c);
			systemInfo.put('system_config_changed', null);
			systemInfo.put('site_phases', String.valueOf(s.Phase_Amount_Installed__c));
			systemInfo.put('generation_site', s.Generation_Types__c);
			
			Map<String, Object> summaryInfo = new Map<String, Object>();
			Map<String, Object> totalInfo = new Map<String, Object>();
			totalInfo.put('approved_total_capacity', String.valueOf(s.Approved_Total_Capacity__c));
			totalInfo.put('approved_export_rating', String.valueOf(s.Approved_Export_Rating__c));
			totalInfo.put('existing_total_export_rating', String.valueOf(s.Existing_Total_Export_Rating__c));
			totalInfo.put('existing_total_inverter_capacity', String.valueOf(s.Existing_Total_Inverter_Capacity__c));
			summaryInfo.put('totalInfo', totalInfo);
			
			Map<String, Object> totalRatingInfo = new Map<String, Object>();
			totalRatingInfo.put('capacity_phase_a', String.valueOf(s.Ph_A_Total_Capacity__c));
			totalRatingInfo.put('export_phase_a', String.valueOf(s.Ph_A_Total_Export__c));
			totalRatingInfo.put('capacity_phase_b', String.valueOf(s.Ph_B_Total_Capacity__c));
			totalRatingInfo.put('export_phase_b', String.valueOf(s.Ph_B_Total_Export__c));
			totalRatingInfo.put('capacity_phase_c', String.valueOf(s.Ph_C_Total_Capacity__c));
			totalRatingInfo.put('export_phase_c', String.valueOf(s.Ph_C_Total_Export__c));
			summaryInfo.put('totalRatingInfo', totalRatingInfo);
			
			Map<String, Object> existingRatingInfo = new Map<String, Object>();
			existingRatingInfo.put('capacity_phase_a', String.valueOf(s.Ph_A_Exist_Capacity__c));
			existingRatingInfo.put('export_phase_a', String.valueOf(s.Ph_A_Exist_Export__c));
			existingRatingInfo.put('capacity_phase_b', String.valueOf(s.Ph_B_Exist_Capacity__c));
			existingRatingInfo.put('export_phase_b', String.valueOf(s.Ph_B_Exist_Export__c));
			existingRatingInfo.put('capacity_phase_c', String.valueOf(s.Ph_C_Exist_Capacity__c));
			existingRatingInfo.put('export_phase_c', String.valueOf(s.Ph_C_Exist_Export__c));
			summaryInfo.put('existingRatingInfo', existingRatingInfo);
            systemInfo.put('summaryInfo', summaryInfo);
            
            Map<String, Object> technicalScheduleInfo = new Map<String, Object>();
			technicalScheduleInfo.put('dred_enabled', s.Islandable_Installation__c);
			technicalScheduleInfo.put('islandable_system', s.Islandable_Installation__c);
			technicalScheduleInfo.put('power_factor', String.valueOf(s.Power_Factor__c));
			technicalScheduleInfo.put('voltage_rise', String.valueOf(s.Volt_Rise_Max_PV_Output__c));
			technicalScheduleInfo.put('protection_relay_manufacturer', s.Protect_Relay_Manufacturer__c);
			technicalScheduleInfo.put('make_series', s.Protect_Relay_Make_Series__c);
            technicalScheduleInfo.put('model', s.Protect_Relay_Model__c);
			technicalScheduleInfo.put('location', s.Protect_Relay_Location__c);
			technicalScheduleInfo.put('wired_wireless', s.Wireless_Model__c);
			technicalScheduleInfo.put('wireless_system_manufacturer', s.Wireless_Manufacturer__c);
			technicalScheduleInfo.put('wireless_system_model', s.Wireless_Model__c);
			technicalScheduleInfo.put('fail_safe_detection_max_time', String.valueOf(s.Signal_Loss_Max_Detect__c));
            technicalScheduleInfo.put('fail_safe_operation_max_time', String.valueOf(s.Signal_Loss_Action_Open_PV_Replay__c));
			technicalScheduleInfo.put('anti_islanding', null);
			technicalScheduleInfo.put('other_generator_connected', null);
			technicalScheduleInfo.put('generator_type', null);
			technicalScheduleInfo.put('operation_mode', null);
			technicalScheduleInfo.put('change_over_ats', null);
            technicalScheduleInfo.put('pv_system_operation',null);
			technicalScheduleInfo.put('sop_33_06_compliant', s.SOP_33_06_Compliant__c);
			technicalScheduleInfo.put('rejection_reason', null);
			technicalScheduleInfo.put('agree_terms_conditions', null);
			technicalScheduleInfo.put('amder_request_id', null);           
			systemInfo.put('technicalScheduleInfo', technicalScheduleInfo);
           
			
			Boolean isPost = false;
			List<Device__c> childDevice = new List<Device__c>();
			List<Device__c> parentDevice = new List<Device__c>();
			for (Device__c deviceRecord : s.Devices__r) {
				if(deviceRecord.Parent_Device__c == null){
					parentDevice.add(deviceRecord);
				}
				if(deviceRecord.Parent_Device__c != null){
					childDevice.add(deviceRecord);
				}
			}
            //system.debug('parentDevice'+parentDevice);
            //system.debug('childDevice'+childDevice);
			List<Map<String, Object>> totalDevices = new List<Map<String, Object>>();
			for (Device__c pd : parentDevice) {
				Map<String, Object> devices = new Map<String, Object>();
				devices.put('id', pd.CEC_ID__c);
				devices.put('sid', pd.SID__c);
				devices.put('manufacturer', pd.Manufacturer__c);
				devices.put('model', pd.Model__c);
				devices.put('type', pd.AC_Equip_Type__c);
				devices.put('sub_type', pd.AC_Equip_Sub_Type__c);
				devices.put('other_type', pd.Name);
                devices.put('total_capacity_rating', String.valueOf(pd.AC_Equip_Cap__c));
                devices.put('total_export_rating', String.valueOf(pd.AC_Equip_Exp__c));
				devices.put('phase', pd.Device_Phase__c);
				devices.put('quantity', String.valueOf(pd.Device_Count__c));
				devices.put('coupling', pd.AC_DC_Coupling__c);
                if(pd.AC_Equip_Sub_Type__c == 'Solar'){
                    devices.put('for_solar', 'true');
                }
                else{
                    devices.put('for_solar', 'false');
                }
                if(pd.AC_Equip_Sub_Type__c == 'Battery'){
                    devices.put('for_battery', 'true');
                }
                else{
                    devices.put('for_battery', 'false');
                }				
				devices.put('dred_enabled', pd.DRED_Enabled__c);
                List<object> childDeviceList = new List<object>();
				if (!childDevice.isEmpty()) {					
					for (Device__c cd : childDevice) {                      
                        if(pd.Id == cd.Parent_Device__c){
                            isPost = true;
                            Map<String, Object> childDevices = new Map<String, Object>();
                            childDevices.put('id', cd.Name);
                            childDevices.put('device_date_inserted', cd.CreatedDate.format('yyyy-MM-dd HH:mm:ss'));
                            childDevices.put('sid', cd.SID__c);
                            childDevices.put('manufacturer', cd.Manufacturer__c);
                            childDevices.put('model', cd.Model__c);
                            childDevices.put('type', cd.Device_Type__c);
                            childDevices.put('sub_type', cd.Device_Sub_Type__c);
                            childDevices.put('rated_capacity', String.valueOf(cd.Nominal_Rated_Cap__c));
                            childDevices.put('storage_capacity', String.valueOf(cd.Nominal_Storage_Cap__c));
                            childDevices.put('quantity', String.valueOf(cd.Device_Count__c));
                            childDevices.put('phase', cd.Device_Phase__c);
                            childDevices.put('coupling', cd.AC_DC_Coupling__c);
                            childDeviceList.add(childDevices);
                        }						
					}					
                } 
                devices.put('devices', childDeviceList);
		     totalDevices.add(devices);
			}
            if(isPost == true){
                applicationData.put('operation','UPDATE');
            }else{
                applicationData.put('operation','CREATE');
            }
			systemInfo.put('inverter', totalDevices);
            applicationInfo.put('systemInfo', systemInfo);
            applicationData.put('applicationInfo', applicationInfo);
            dataToSend.add(applicationData);
            //recordsToUpdate.add(s);
            //system.debug('applicationInfo'+dataToSend);
        }
        Map<String, Object> firstReqNode = new Map<String, Object>();
        firstReqNode.put('request', dataToSend);
        Map<String, Object> secondReqNode = new Map<String, Object>();
        secondReqNode.put('request', firstReqNode);
        // Make callout outside for loop
        if (!derRecords.isEmpty()) {
            SNET__c customSett = SNET__c.getValues('SNET');
            HttpRequest request = new HttpRequest();
        	request.setHeader('Content-Type', 'application/json');
            request.setEndpoint(customSett.Endpoint__c);
            //request.setEndpoint('https://stg-gw.apin.ausnetservices.com.au/DERApplications/Update');
            request.setMethod('POST');
        	request.setTimeout(120000);
        	//request.setEndpoint('https://snets.free.beeceptor.com');
            //request.setMethod('GET');
            request.setBody(JSON.serialize(secondReqNode));
            HttpResponse response = new Http().send(request);
            system.debug('response'+response.getBody());
            system.debug('response2'+response.getStatusCode());
            // Update custom flag on records
            if(response.getStatusCode() == 200){
                //Map<String, Object> snetResponseMap = (Map<String, Object>)JSON.deserializeUntyped (response.getBody());
                List<object> snetResponse = (List<object>)JSON.deserializeUntyped(response.getBody());
                system.debug('snetResponse'+snetResponse.size());
                Map<String, Object> responseMap = new Map<String, Object>();
                Map<String, Object> resultMap = new Map<String, Object>();
                Map<String, Object> resultKeyMap = new Map<String, Object>();
                for(Object res :snetResponse ){
                    responseMap = (Map<String, Object>)res;
					resultMap =(Map<String, Object>)responseMap.get('response');
                    System.debug('resultMap'+resultMap);
                    System.debug('resp code child'+resultMap.get('code'));
                    if(resultMap.get('code') == '200' || resultMap.get('code') == 200){
                        System.debug('resp code combo'+resultMap.get('salesforceId')+':'+resultMap.get('code')+':'+resultMap.get('message'));
                    	resultKeyMap.put((String)resultMap.get('salesforceId') ,resultMap.get('code'));                        
                    }else{
                        System.debug('failure Resp'+resultMap);
                        System.debug('failure Resp code'+resultMap.get('code'));
                        System.debug('failure Resp salesforceId'+resultMap.get('salesforceId'));
                        System.debug('failure Resp Msg'+resultMap.get('message'));
                    }
                }
                System.debug('resultKeyMap'+resultKeyMap.size());
                for (Id s : idAppNoMap.keySet()) {
                            
                            if(resultKeyMap.containsKey(idAppNoMap.get(s))){
                               DER_Application__c dApp = new DER_Application__c(); 
                               dApp.Id =s;
                               dApp.Synced_To_SNET__c = true;              			 
                               recordsToUpdate.add(dApp);
                            }
            	}
                
            	// Update records in batch
            	UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = true;
                system.debug('recordsToUpdate.size'+recordsToUpdate.size());
            	update recordsToUpdate;
            }else{
                system.debug(' fail response'+response.getBody());
                system.debug(' fail code'+response.getStatusCode());
            }
           
        }
    }
    global void finish(Database.BatchableContext bc) {
        // Do any cleanup or post-processing here
		 if(isProcessCheck == true){
            SnetSyncBatch mb = new SnetSyncBatch();
			Database.executeBatch(mb, 50);
        }
    }
    
     global void execute(SchedulableContext sc)
     {
      	SnetSyncBatch b = new SnetSyncBatch(); 
        database.executeBatch(b,50);
     }
}