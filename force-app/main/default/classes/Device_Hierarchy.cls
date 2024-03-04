public class Device_Hierarchy
{
	@AuraEnabled
	public static List<items> getDeviceHierarchy(Id caseId)
	{
		// Wrapper instance
		List<items> finalWrp = new List<items>();

		Case Caserecord = [SELECT DER_Application__c, DER_Application__r.Name FROM Case WHERE Id = :caseId];

		// Going upto 2 level only as per SOQL limit
		for (Device__c devL2 : [SELECT Id, Name, RecordType.Name, AC_Equip_Type__c, AC_Equip_Sub_Type__c, Device_Count__c,
		 						(SELECT Id, Name, RecordType.Name, Parent_Device__c, Device_Type__c, Device_Sub_Type__c, Device_Count__c
								 	FROM Devices__r
									 WHERE RecordType.DeveloperName='Device_L3')
								FROM Device__c
								WHERE DER_Application__c = :Caserecord.DER_Application__c
								AND RecordType.DeveloperName='Device_L2'])
		{
			// populating wrapper
			List<items> trP3 = new List<items>();
			for (Device__c devL3: devL2.Devices__r)
			{
				trP3.add(new items(devL3.RecordType.Name, devL3.Device_Type__c + ' - ' + devL3.Device_Sub_Type__c + ' (x'+devL3.Device_Count__c+')', true, null));
			}

			finalWrp.add(new items(devL2.RecordType.Name, devL2.AC_Equip_Type__c + ' - ' + devL2.AC_Equip_Sub_Type__c + ' (x'+devL2.Device_Count__c+')', true, trP3));
		}

		return finalWrp;
	}

	@AuraEnabled 
	public static Boolean searchDevice(String queryString, String searchType) {
		if(searchType == 'Inverter') {
			for(Inverters__x inv : [SELECT inverter_number__c, model_number__c, manufacturer__c, rated_apparent_va__c
									  FROM 	 Inverters__x]) { //External Objects don't support like) {
				if((inv.model_number__c != null && inv.model_number__c.contains(queryString)) ||
					(inv.manufacturer__c != null && inv.manufacturer__c.contains(queryString)) ||
					(inv.rated_apparent_va__c != null && inv.rated_apparent_va__c.contains(queryString))) {
					return true;
				}
			}
		}
		if(searchType == 'Module') {
			for(CECModules__x module: [SELECT ModuleNumber__c, ModelNumber__c, OutputAtSTC__c FROM CECModules__x]) {
				if((module.ModuleNumber__c != null && module.ModuleNumber__c.contains(queryString)) ||
					(module.ModelNumber__c != null && module.ModelNumber__c.contains(queryString)) ||
					(module.OutputAtSTC__c != null && module.OutputAtSTC__c.contains(queryString))) {
					return true;
				}
			}
		}

		return false;
	}

	public class items
	{
		@AuraEnabled public String label { get; set; }
		@AuraEnabled public String name { get; set; }
		@AuraEnabled public Boolean expanded { get; set; }
		@AuraEnabled public List<items> items { get; set; }

		public items(String name, String label, Boolean expanded, List<items> items)
		{
			this.label = label;
			this.name = name;
			this.expanded = expanded;
			this.items = items;
		}
	}
 }