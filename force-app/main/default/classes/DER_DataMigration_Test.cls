@IsTest
private class DER_DataMigration_Test
{
	public static testMethod void DataMigration_Test1()
	{
		generateData();
		Test.startTest();
			DER_DataMigration.runDataMig(DER_DataMigration.runMode.LINKER);
		Test.stopTest();
	}


	// ************************************************************************************
	// *** Test Data:
	private static void generateData()
	{
		// Add L2 Assets
		List<Asset> insertAssets = new List<Asset>();

		Asset a = new Asset();
		a.Name                           = 'Random_L2_1';
		a.Legacy_Data_Id__c              = 'Random_L2_1';
		a.Legacy_Data_Parent_Id__c       = '63050012230';
		a.RecordTypeId                   = UtilDatabase.getRecordTypeNames('Asset').get(DER_DataMigration.ASSET_L2);
		a.Status                         = 'Active';
		a.AEMO_Id__c                     = '200000001341840';
		a.AEMO_Status__c                 = 'Active';
		a.Legacy_Data__c                 = true;
		a.AC_Equip_Cap__c                = 31.28;
		a.AC_Equip_Type__c               = 'Unknown_equipment';
		a.Commissioning_Date__c          = Date.valueOf('2018-08-27');
		a.Device_Count__c                = 1;
		a.Inv_Power_Factor_Mode__c       = 'Not Enabled';
		a.Inv_Power_Rate_Limit_Mode__c   = 'Not Enabled';
		a.Inv_Power_Response_Mode__c     = 'Not Enabled';
		a.Inv_Reactive_Power_Mode__c     = 'Not Enabled';
		a.Inv_Volt_Var_Response_Mode__c  = 'Not Enabled';
		a.Inv_Volt_Watt_Response_Mode__c = 'Not Enabled';
		insertAssets.add(a);

		a = new Asset();
		a.Name                           = 'Random_L2_3';
		a.Legacy_Data_Id__c              = 'Random_L2_3';
		a.Legacy_Data_Parent_Id__c       = '63050014808';
		a.RecordTypeId                   = UtilDatabase.getRecordTypeNames('Asset').get(DER_DataMigration.ASSET_L2);
		a.Status                         = 'Active';
		a.AEMO_Id__c                     = '200000001341841';
		a.AEMO_Status__c                 = 'Active';
		a.Legacy_Data__c                 = true;
		a.AC_Equip_Cap__c                = 29.9;
		a.AC_Equip_Type__c               = 'Unknown_equipment';
		a.Commissioning_Date__c          = Date.valueOf('2017-05-02');
		a.Device_Count__c                = 1;
		a.Inv_Power_Factor_Mode__c       = 'Not Enabled';
		a.Inv_Power_Rate_Limit_Mode__c   = 'Not Enabled';
		a.Inv_Power_Response_Mode__c     = 'Not Enabled';
		a.Inv_Reactive_Power_Mode__c     = 'Not Enabled';
		a.Inv_Volt_Var_Response_Mode__c  = 'Not Enabled';
		a.Inv_Volt_Watt_Response_Mode__c = 'Not Enabled';
		insertAssets.add(a);

		// Add L3 Assets
		a = new Asset();
		a.Name                           = 'Random_L3_2';
		a.Legacy_Data_Id__c              = 'Random_L3_2';
		a.Legacy_Data_Parent_Id__c       = 'Random_L2_1';
		a.RecordTypeId                   = UtilDatabase.getRecordTypeNames('Asset').get(DER_DataMigration.ASSET_L3);
		a.Status                         = 'Active';
		a.AEMO_Id__c                     = '200000001350961';
		a.AEMO_Status__c                 = 'Active';
		a.Legacy_Data__c                 = true;
		a.Device_Count__c                = 1;
		a.Device_Type__c                 = 'Solar PV';
		a.Device_Sub_Type__c             = 'Unknown_subtype';
		a.Nominal_Rated_Cap__c           = 0;
		a.Nominal_Storage_Cap__c         = 0;
		insertAssets.add(a);

		a = new Asset();
		a.Name                           = 'Random_L3_4';
		a.Legacy_Data_Id__c              = 'Random_L3_4';
		a.Legacy_Data_Parent_Id__c       = 'Random_L2_3';
		a.RecordTypeId                   = UtilDatabase.getRecordTypeNames('Asset').get(DER_DataMigration.ASSET_L3);
		a.Status                         = 'Active';
		a.AEMO_Id__c                     = '200000001350962';
		a.AEMO_Status__c                 = 'Active';
		a.Legacy_Data__c                 = true;
		a.Device_Count__c                = 1;
		a.Device_Type__c                 = 'Solar PV';
		a.Device_Sub_Type__c             = 'Unknown_subtype';
		a.Nominal_Rated_Cap__c           = 0;
		a.Nominal_Storage_Cap__c         = 0;
		insertAssets.add(a);

		insert insertAssets;
	}
}