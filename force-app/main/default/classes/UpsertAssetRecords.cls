/*
	@author  : Rohit.Middha@ausnetservices.com.au
	@created : 14 Oct 2019
	@Description : For upserting asset records when case status is complete
	-----------------------------------------------------------------------------------------
	Change log
	-----------------------------------------------------------------------------------------
	Date                  Name                           Description
	-----------------------------------------------------------------------------------------
	NA                    NA                              NA
	-----------------------------------------------------------------------------------------
*/
public with sharing class UpsertAssetRecords
{
	public static Set<String> AssetDeviceFields = new Set<String>
	{
		'Name',
		'AC_Equip_Cap__c',
		'AC_Equip_Exp__c',
		'AC_Equip_Sub_Type__c',
		'AC_Equip_Type__c',
		'AC_DC_Coupling__c',
		'AutoAugCapCopied__c',
		'AEMO_Status__c',
		'Battery_Depth_of_Discharge__c',
		'Commissioning_Date__c',
		'Decommissioning_Date__c',
		'Device_Count__c',
		'Device_Sub_Type__c',
		'Device_Type__c',
		'DRED_Enabled__c',
		'Fstop_over_freq__c',
		'Fstop_ch_under_freq__c',
		'Inv_Fixed_Power_Factor__c',
		'Inv_Fixed_Power_Factor_Quad__c',
		'Inv_Fixed_Reactive_Power__c',
		'Inv_Power_Factor_P1__c',
		'Inv_Power_Factor_P2__c',
		'Inv_Power_Factor_Mode__c',
		'Inv_Power_Factor_Quad_P1__c',
		'Inv_Power_Factor_Quad_P2__c',
		'Inv_Power_Ramp_Rate__c',
		'Inv_Power_Rate_Limit_Mode__c',
		'Inv_Power_Response_Mode__c',
		'Inv_Reactive_Power_Mode__c',
		'Inv_Ref_Point_P1__c',
		'Inv_Ref_Point_P2__c',
		'Inv_Var_Response_Q_at_V1__c',
		'Inv_Var_Response_Q_at_V2__c',
		'Inv_Var_Response_Q_at_V3__c',
		'Inv_Var_Response_Q_at_V4__c',
		'Inv_Var_Response_V1__c',
		'Inv_Var_Response_V2__c',
		'Inv_Var_Response_V3__c',
		'Inv_Var_Response_V4__c',
		'Inv_Vnom_max__c',
		'Inv_Volt_Var_Response_Mode__c',
		'Inv_Volt_Watt_Response_Mode__c',
		'Inv_Watt_Response_P_at_V1__c',
		'Inv_Watt_Response_P_at_V2__c',
		'Inv_Watt_Response_P_at_V3__c',
		'Inv_Watt_Response_P_at_V4__c',
		'Inv_Watt_Response_V1__c',
		'Inv_Watt_Response_V2__c',
		'Inv_Watt_Response_V3__c',
		'Inv_Watt_Response_V4__c',
		'Legacy_Data__c',
		'Manufacturer__c',
		'Max_Total_Harmonics__c',
		'Model__c',
		'Nominal_Rated_Cap__c',
		'Nominal_Storage_Cap__c',
		'Non_Inv_Base_for_Droop__c',
		'Non_Inv_Deadband__c',
		'Non_Inv_Droop__c',
		'Non_Inv_Gen_Freq_Deadband__c',
		'Non_Inv_Gen_Freq_Droop__c',
		'Non_Inv_Generator_Freq_Response_Mode__c',
		'Non_Inv_Gen_Ramp_Rate__c',
		'Non_Inv_Inter_Trip_Scheme__c',
		'Non_Inv_Neutral_Voltage_Displacement__c',
		'Non_Inv_Power_Ramp_Gradient__c',
		'Non_Inv_Rate_of_Change_of_Freq__c',
		'Non_Inv_Reactive_Fixed_Power_Factor__c',
		'Non_Inv_Reactive_Fixed_Power_Factor_Quad__c',
		'Non_Inv_Reactive_Power_Reg__c',
		'Non_Inv_Reactive_Power_Sink_Limit__c',
		'Non_Inv_Reactive_Power_Source_Limit__c',
		'Non_Inv_Volt_Set_Point__c',
		'Non_Inv_Volt_Set_Point_Unit__c',
		'Non_Inv_Voltage_Vector_Shift__c',
		'Device_Phase__c',
		'Serial_Numbers__c',
		'Legacy_Data__c',
		'Equip_Power_Factor__c',
		'Rated_Reactive_Max_Power_Output__c',
		'Impedance__c',
		'Sub_Transient_Impedance__c',
		'Leakage_Reactance__c',
		'CEC_ID__c',
		'AEMO_Id__c',
		'NMI_AEMO_Id__c'
	};

	public static Set<String> ConnPointL1Fields = new Set<String>
	{
		'Generation_Types__c',
		'Phases__c',
		'Phase_Amount_Available__c',
		'Central_Protection_Control__c',
		'Islandable_Installation__c',
		'Export_Limitation_kVA__c',
		'Under_Freq_Protection__c',
		'Under_Freq_Protection_Delay__c',
		'Over_Freq_Protection__c',
		'Undervolt_Protection_Delay__c',
		'Neutral_Voltage_Displacement__c',
		'Overvolt_Protection_1__c',
		'Overvolt_Protection_1_Delay__c',
		'Overvolt_Protection_2__c',
		'Undervolt_Protection__c',
		'Rate_of_Change_of_Freq__c',
		'Volt_Vector_Shift__c',
		'Inter_Trip_Scheme__c',
		'Power_Factor__c',
		'Volt_Rise_Max_PV_Output__c',
		'Protect_Relay_Manufacturer__c',
		'Protect_Relay_Make_Series__c',
		'Protect_Relay_Model__c',
		'Protect_Relay_Location__c',
		'Protect_Relay_Comm_Method__c',
		'Wireless_Manufacturer__c',
		'Wireless_Model__c',
		'Signal_Loss_Max_Detect__c',
		'Signal_Loss_Max_Operate__c',
		'Signal_Loss_Action_Open_PV_Replay__c',
		'SOP_33_06_Compliant__c',
		'Registered_Generator__c',
		'Ph_A_Total_Capacity__c',
		'Ph_B_Total_Capacity__c',
		'Ph_C_Total_Capacity__c',
		'Ph_Unk_Total_Capacity__c'
	};

	public static Set<String> DerAppFields = new Set<String>
	{
		'Central_Protection_Control__c',
		'Islandable_Installation__c',
		'Export_Limitation_kVA__c',
		'Under_Freq_Protection__c',
		'Under_Freq_Protection_Delay__c',
		'Over_Freq_Protection__c',
		'Undervolt_Protection__c',
		'Undervolt_Protection_Delay__c',
		'Neutral_Voltage_Displacement__c',
		'Overvolt_Protection_1__c',
		'Overvolt_Protection_1_Delay__c',
		'Overvolt_Protection_2__c',
		'Rate_of_Change_of_Freq__c',
		'Volt_Vector_Shift__c',
		'Inter_Trip_Scheme__c',
		'Power_Factor__c',
		'Volt_Rise_Max_PV_Output__c',
		'Protect_Relay_Manufacturer__c',
		'Protect_Relay_Make_Series__c',
		'Protect_Relay_Model__c',
		'Protect_Relay_Location__c',
		'Protect_Relay_Comm_Method__c',
		'Wireless_Manufacturer__c',
		'Wireless_Model__c',
		'Signal_Loss_Max_Detect__c',
		'Signal_Loss_Max_Operate__c',
		'Signal_Loss_Action_Open_PV_Replay__c',
		'SOP_33_06_Compliant__c',
		'Registered_Generator__c'
	};

	public static Map<String, String> CPtoDERApp = new Map<String, String>
	{
		'Phase_A_Total_System_Export__c' => 'Ph_A_Exist_Export__c',
		'Phase_B_Total_System_Export__c' => 'Ph_B_Exist_Export__c',
		'Phase_C_Total_System_Export__c' => 'Ph_C_Exist_Export__c',
		'Phase_Unk_Total_System_Export__c' => 'Ph_Unk_Exist_Export__c',

		'Ph_A_Total_Capacity__c' => 'Ph_A_Exist_Capacity__c',
		'Ph_B_Total_Capacity__c' => 'Ph_B_Exist_Capacity__c',
		'Ph_C_Total_Capacity__c' => 'Ph_C_Exist_Capacity__c',
		'Ph_Unk_Total_Capacity__c' => 'Ph_Unk_Exist_Capacity__c'
	};

	public static void upsertAssets(Set<Id> derAppIds)
	{
		Map<Id, DER_Application__c> derIdObjMap = new Map<Id, DER_Application__c>();
		Map<Id, Connection_Point__c> cPIdObjMap = new Map<Id, Connection_Point__c>();
		Set<Id> connPointIds = new Set<Id>();
		List<Connection_Point__c> cpList = new List<Connection_Point__c>();

		String queryApp = UtilDatabase.getAllFields('DER_Application__c');
		queryApp += ' FROM DER_Application__c';
		queryApp += ' WHERE Id IN :derAppIds';

		for (DER_Application__c derapp :(List<DER_Application__c>)Database.query(queryApp))
		{
			derIdObjMap.put(derapp.Id, derapp);
			connPointIds.add(derapp.NMI__c);
		}

		String queryCp = UtilDatabase.getAllFields('Connection_Point__c');
		queryCp += ' FROM Connection_Point__c';
		queryCp += ' WHERE Id IN :connPointIds';

		for (Connection_Point__c cp :(List<Connection_Point__c>)Database.query(queryCp))
		{
			cPIdObjMap.put(cp.Id, cp);
		}

		Map<Id, List<Device__c>> derIdL2DevicesMap = new Map<Id, List<Device__c>>();
		Map<Id, List<Device__c>> derIdL3DevicesMap = new Map<Id, List<Device__c>>();

		String queryDevice = UtilDatabase.getAllFields('Device__c');
		queryDevice += ', Parent_Device__r.DER_Application__c, Parent_Device__r.Asset__c';
		queryDevice += ' FROM Device__c';
		queryDevice += ' WHERE (DER_Application__c in :derAppIds';
		queryDevice += ' OR Parent_Device__r.DER_Application__c IN :derAppIds)';
		queryDevice += ' AND (Installed__c = true OR Decommission__c = true OR Existing_Device__c = true)';

		// Sort devices into map keyed by App Id
		// Sort into L2 and L3 maps
		for (Device__c dev: (List<Device__c>)Database.query(queryDevice))
		{
			String RTName = UtilDatabase.getRecordTypes().get(dev.RecordTypeId);

			if (RTName == 'Device_L2')
			{
				Id DeviceDERAppId = dev.DER_Application__c;

				if (!derIdL2DevicesMap.containsKey(DeviceDERAppId))
					derIdL2DevicesMap.put(DeviceDERAppId, new List<Device__c>());

				derIdL2DevicesMap.get(DeviceDERAppId).add(dev);
			}
			else if (RTName == 'Device_L3')
			{
				Id DeviceDERAppId = dev.Parent_Device__r.DER_Application__c;

				if (!derIdL3DevicesMap.containsKey(DeviceDERAppId))
					derIdL3DevicesMap.put(DeviceDERAppId, new List<Device__c>());

				derIdL3DevicesMap.get(DeviceDERAppId).add(dev);
			}
		}

		// Iterate Apps/L2s
		Map<Id, Asset> assetsL2 = new Map<Id, Asset>();

		for (Id appId: derAppIds)
		{
			if (!derIdL2DevicesMap.containsKey(appId))
				continue;

			Id ConnPointId = derIdObjMap.get(appId).NMI__c;
			String NMI = cPIdObjMap.get(ConnPointId).NMI__c;

			// Get L2s and clone, upsert
			for (Device__c dev: derIdL2DevicesMap.get(appId))
			{
				Asset assetRec = cloneDevice(dev, NMI);
				assetRec.Conn_Point__c = derIdObjMap.get(appId).NMI__c; // Set Parent
				assetsL2.put(dev.Id, assetRec);
			}
		}

		if (!assetsL2.isEmpty()) createUpdateAssets(assetsL2.values());

		// Iterate Apps/L3s
		Map<Id, Asset> assetsL3 = new Map<Id, Asset>();

		for (Id appId: derAppIds)
		{
			if (!derIdL3DevicesMap.containsKey(appId))
				continue;

			Id ConnPointId = derIdObjMap.get(appId).NMI__c;
			String NMI = cPIdObjMap.get(ConnPointId).NMI__c;

			// Get L3s and clone, upsert
			for (Device__c dev: derIdL3DevicesMap.get(appId))
			{
				Asset assetRec = cloneDevice(dev, NMI);

				// Set Parent
				Id devParentId = dev.Parent_Device__c;
				assetRec.ParentId = assetsL2.get(devParentId).Id; // Find L2 Asset.

				assetsL3.put(dev.Id, assetRec);
			}
		}

		if (!assetsL3.isEmpty()) createUpdateAssets(assetsL3.values());

		for (Id appId: derAppIds)
		{
			Id ConnPointId = derIdObjMap.get(appId).NMI__c;

			if (cPIdObjMap.containsKey(ConnPointId))
			{
				Connection_Point__c cp = cPIdObjMap.get(ConnPointId);

				// Map all the fields
				for (String field: ConnPointL1Fields)
					cp.put(field, derIdObjMap.get(appId).get(field));

				cp.Phase_A_Total_System_Export__c = derIdObjMap.get(appId).Ph_A_Total_Export__c;
				cp.Phase_B_Total_System_Export__c = derIdObjMap.get(appId).Ph_B_Total_Export__c;
				cp.Phase_C_Total_System_Export__c = derIdObjMap.get(appId).Ph_C_Total_Export__c;
				cp.Phase_Unk_Total_System_Export__c = derIdObjMap.get(appId).Ph_Unk_Total_Export__c;

				cpList.add(cp);
			}
		}

		if (!cpList.isEmpty()) update cpList;

		// Link devices to assets
		List<Device__c> updDevices = new List<Device__c>();
		updDevices.addAll(linkDevicesToAssets(assetsL2));
		updDevices.addAll(linkDevicesToAssets(assetsL3));
		if (!updDevices.isEmpty()) update updDevices;
	}

	private static Asset cloneDevice(Device__c dev, String NMI)
	{
		if (dev == null) return null;
		Asset assetRec = new Asset();

		// Update existing Asset
		if (dev.Asset__c != null)
			assetRec = new Asset(Id = dev.Asset__c);

		if (dev.Installed__c || dev.Decommission__c || dev.Existing_Device__c)
		{
			String RTName = UtilDatabase.getRecordTypes().get(dev.RecordTypeId);

			// Set Record type
			if (RTName == 'Device_L2')
				assetRec.RecordTypeId = UtilDatabase.getRecordTypeNames('Asset').get('Asset_DER_L2');
			else if (RTName == 'Device_L3')
				assetRec.RecordTypeId = UtilDatabase.getRecordTypeNames('Asset').get('Asset_DER_L3');

			// Set status
			if (dev.Installed__c && !dev.Decommission__c)
				assetRec.Status = 'Active';
			else if (dev.Decommission__c)
				assetRec.Status = 'Decommissioned';

			// Map all the fields
			for (String field: AssetDeviceFields)
				assetRec.put(field, dev.get(field));

			// External Id
			if (assetRec.AEMO_Id__c == null) 
				assetRec.AEMO_Id__c = dev.Id;

			// Key
			if (assetRec.NMI_AEMO_Id__c == null)
				assetRec.NMI_AEMO_Id__c = NMI + '-' + RTName.removeStart('Device_') + '-' + assetRec.AEMO_Id__c;
		}

		return assetRec;
	}

	private static List<Device__c> linkDevicesToAssets(Map<Id, Asset> assetMap)
	{
		List<Device__c> updDevices = new List<Device__c>();

		for (Id devId: assetMap.keySet())
		{
			Device__c d = new Device__c(Id = devId);

			if (d.Asset__c == assetMap.get(devId).Id)
				continue; // Already set, skip record

			d.Asset__c = assetMap.get(devId).Id;
			updDevices.add(d);
		}

		return updDevices;
	}

	private static void createUpdateAssets(List<SObject> SObjects)
	{
		if (SObjects == null) return;

		List<SObject> SObjsUpdate = new List<SObject>();
		List<Asset> AssetsUpsert = new List<Asset>();

		for (SObject o: SObjects)
		{
			if (o.Id != null)
				SObjsUpdate.add(o);
			else
				AssetsUpsert.add((Asset)o);
		}

		if (!SObjsUpdate.isEmpty()) update SObjsUpdate;
		if (!AssetsUpsert.isEmpty()) upsert AssetsUpsert NMI_AEMO_Id__c;
	}


	public static void copyExistingAssetToDevices(Map<Id, DER_Application__c> derAppIdMap)
	{
		Map<Id, Id> CPtoDERAppIds = new Map<Id, Id>();
		Set<Id> ConnPointIds = new Set<Id>();
		Map<Id, Case> idCaseMap = new Map<Id,Case>();
		Map<Id, Connection_Point__c> idNMIMap = new Map<Id, Connection_Point__c>();
		List<Device__c> devList = new List<Device__c>();
		List<SObject> derAppListToUpdate = new List<SObject>();
		List<SObject> finallistOfderApps = new List<SObject>();

		Map<Id, List<Asset>> derIdL2AssetsMap = new Map<Id, List<Asset>>();
		Map<Id, List<Asset>> derIdL3AssetsMap = new Map<Id, List<Asset>>();

		for (DER_Application__c derapp: derAppIdMap.values())
			CPtoDERAppIds.put(derapp.NMI__c, derapp.Id);

		ConnPointIds.addAll(CPtoDERAppIds.keySet());

		String queryNMI = UtilDatabase.getAllFields('Connection_Point__c');
		queryNMI += ' FROM Connection_Point__c';
		queryNMI += ' WHERE Id IN :ConnPointIds';

		for (Connection_Point__c cp: (List<Connection_Point__c>)Database.query(queryNMI))
			idNMIMap.put(cp.Id, cp);

		for (Case cse: [SELECT Id, Type, DER_Application__c FROM Case WHERE DER_Application__c IN :derAppIdMap.keySet()])
			idCaseMap.put(cse.DER_Application__c, cse);

		// ---

		for (DER_Application__c derapp: derAppIdMap.values())
		{
			Connection_Point__c NMI = idNMIMap.get(derapp.NMI__c);

			DER_Application__c updDERApp = new DER_Application__c(Id = derapp.Id);

			// Copy fields from Conn Pt to DER App (L1 fields)
			for (String field: DerAppFields)
			{
				if (NMI.get(field) != null)
					updDERApp.put(field, NMI.get(field));
			}

			// Copy more fields (these names do not match between objects)
			for (String CPfield: CPtoDERApp.keySet())
			{
				String DERAppfield = CPtoDERApp.get(CPfield);

				if (NMI.get(CPfield) != null)
					updDERApp.put(DERAppfield, NMI.get(CPfield));
			}

			derAppListToUpdate.add(updDERApp);
		}

		String queryAsset = UtilDatabase.getAllFields('Asset');
		queryAsset += ', Parent.Conn_Point__c, Parent.Conn_Point__r.NMI__c, Conn_Point__r.NMI__c';
		queryAsset += ' FROM Asset';
		queryAsset += ' WHERE (Conn_Point__c in :ConnPointIds';
		queryAsset += ' OR Parent.Conn_Point__c IN :ConnPointIds)';
		queryAsset += ' AND Status = \'Active\'';

		// Sort devices into map keyed by App Id
		// Sort into L2 and L3 maps
		for (Asset asset: (List<Asset>)Database.query(queryAsset))
		{
			String RTName = UtilDatabase.getRecordTypes().get(asset.RecordTypeId);

			if (RTName == 'Asset_DER_L2')
			{
				Id connId = asset.Conn_Point__c;
				Id DerAppId = CPtoDERAppIds.get(connId);

				if (!derIdL2AssetsMap.containsKey(DerAppId))
					derIdL2AssetsMap.put(DerAppId, new List<Asset>());

				derIdL2AssetsMap.get(DerAppId).add(asset);
			}
			else if (RTName == 'Asset_DER_L3')
			{
				Id connId = asset.Parent.Conn_Point__c;
				Id DerAppId = CPtoDERAppIds.get(connId);

				if (!derIdL3AssetsMap.containsKey(DerAppId))
					derIdL3AssetsMap.put(DerAppId, new List<Asset>());

				derIdL3AssetsMap.get(DerAppId).add(asset);
			}
		}

		// Iterate Apps/L2s
		Map<Id, Device__c> devicesL2 = new Map<Id, Device__c>();

		for (Id DERAppId: CPtoDERAppIds.values())
		{
			if (!derIdL2AssetsMap.containsKey(DERAppId))
				continue;

			// Get L2 Assets and clone, upsert
			for (Asset ast: derIdL2AssetsMap.get(DERAppId))
			{
				String NMI = ast.Conn_Point__r.NMI__c;

				//Added for CMC-2320 for Augument case type 
				Boolean autoAugAst = ast.AutoAugCapCopied__c;
				Boolean LegacyFlag = ast.Legacy_Data__c;
				//End - Added for CMC-2320 for Augument case type 

				Device__c devRec = cloneAsset(ast, NMI);
				devRec.Existing_Device__c = true;
				devRec.Decommission__c = false;

				String caseType = derAppIdMap.get(DERAppId).Case_Type__c;

				//Added for CMC-2320 for Augument case type 
				String caseScenario = derAppIdMap.get(DERAppId).DER_Scenario__c;
				Decimal ExisTotalInvCap = derAppIdMap.get(DERAppId).Existing_Total_Inverter_Capacity__c;
				//End - Added for CMC-2320 for Augument case type 

				if (idCaseMap.containsKey(DERAppId))
					caseType = idCaseMap.get(DERAppId).Type;

				if (caseType == 'Replacement' || caseType == 'Abolishment')
					devRec.Decommission__c = true;
		 		
	            //Condition added for CMC-2320 for Augument case type 		
				if (caseType == 'Augmentation' && caseScenario == 'Auto' && LegacyFlag == true && autoAugAst == false && (ExisTotalInvCap != null && ExisTotalInvCap > 0)){
					devRec.AutoAugCapCopied__c = true;
					devRec.AC_Equip_Cap__c = ExisTotalInvCap;
					finallistOfderApps.add(derAppIdMap.get(DERAppId));
				}
				//End - Condition added for CMC-2320 for Augument case type 	

				devRec.DER_Application__c = DERAppId;
				devRec.Asset__c = ast.Id;
				devRec.RecordTypeId = UtilDatabase.getRecordTypeNames('Device__c').get('Device_L2');

				devicesL2.put(ast.Id, devRec);
			}
		}

		if (!devicesL2.isEmpty()) createUpdateDevices(devicesL2.values());

		// Iterate Apps/L3s
		Map<Id, Device__c> devicesL3 = new Map<Id, Device__c>();

		for (Id DERAppId: CPtoDERAppIds.values())
		{
			if (!derIdL3AssetsMap.containsKey(DERAppId))
				continue;

			// Get L3s and clone, upsert
			for (Asset ast: derIdL3AssetsMap.get(DERAppId))
			{
				String NMI = ast.Parent.Conn_Point__r.NMI__c;

				Device__c devRec = cloneAsset(ast, NMI);
				devRec.Parent_Device__c = devicesL2.get(ast.Parent.Id).Id;
				devRec.Existing_Device__c = true;

				String caseType = derAppIdMap.get(DERAppId).Case_Type__c;

				if (idCaseMap.containsKey(DERAppId))
					caseType = idCaseMap.get(DERAppId).Type;

				if (caseType == 'Replacement' || caseType == 'Abolishment')
					devRec.Decommission__c = true;

				devRec.Asset__c = ast.Id;
				devRec.RecordTypeId = UtilDatabase.getRecordTypeNames('Device__c').get('Device_L3');
				devicesL3.put(ast.Id, devRec);
			}
		}

		//Code for CMC-2320 starts
		if(!finallistOfderApps.isEmpty()){
			Map<Id,DER_Application__c> AugmentDERAppMap = new Map<Id,DER_Application__c>();
			for (DER_Application__c derappcap:  (List<DER_Application__c>) finallistOfderApps){

				DER_Application__c updDERAppCapacity = new DER_Application__c(Id = derappcap.Id);
			    updDERAppCapacity.Ph_Unk_Exist_Capacity__c = derappcap.Existing_Total_Inverter_Capacity__c;
			    AugmentDERAppMap.put(updDERAppCapacity.Id,updDERAppCapacity);
			}
			for(SObject sObjItem: derAppListToUpdate){
				DER_Application__c derapp1 = (DER_Application__c)sObjItem;
			    DER_Application__c derapp2 = AugmentDERAppMap.get(derapp1.id);
			    derapp1.Ph_Unk_Exist_Capacity__c = derapp2.Ph_Unk_Exist_Capacity__c;
			}
		}
		//Code for CMC-2320 ends	

		if (!devicesL3.isEmpty()) createUpdateDevices(devicesL3.values());
		
		if (!derAppListToUpdate.isEmpty()) update derAppListToUpdate;		
	}

	private static Device__c cloneAsset(Asset ast, String NMI)
	{
		if (ast == null) return null;

		Device__c devRec = new Device__c();
		String recTypeName = Asset.sObjectType.getDescribe().getRecordTypeInfosById().get(ast.recordTypeID).getName();

		// Map all the fields
		for (String field: AssetDeviceFields)
		{
			if (field == 'Name')
				continue;

			devRec.put(field, ast.get(field));
		}

		// External Id
		if (devRec.AEMO_Id__c == null)
			devRec.AEMO_Id__c = ast.Id;

		// Key
		if (devRec.NMI_AEMO_Id__c == null)
			devRec.NMI_AEMO_Id__c = NMI + '-' + recTypeName.removeStart('Asset_DER_') + '-' + devRec.AEMO_Id__c;

		return devRec;
	}

	private static void createUpdateDevices(List<SObject> SObjects)
	{
		if (SObjects == null) return;

		List<SObject> SObjsUpdate = new List<SObject>();
		List<Device__c> DevicesUpsert = new List<Device__c>();

		for (SObject o: SObjects)
		{
			if (o.Id != null)
				SObjsUpdate.add(o);
			else
				DevicesUpsert.add((Device__c)o);
		}

		if (!SObjsUpdate.isEmpty()) update SObjsUpdate;
		if (!DevicesUpsert.isEmpty()) insert DevicesUpsert; // Do not upsert. These are not unique values in Device obj
	}
}