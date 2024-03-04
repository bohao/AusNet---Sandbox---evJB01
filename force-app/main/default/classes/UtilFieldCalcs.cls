/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 20 Sep 2019
  @Description : Calculate totals and update the DER Applicaiton
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  01/11/2019            Rohit Middha                   CMC-1499
  13/11/2019            Vaughan Crole                  CMC-1499
  -----------------------------------------------------------------------------------------
*/
public with sharing class UtilFieldCalcs
{
	public static Set<String> CalcTotalFields_AllowedRTs = new Set<String>{'Device_L2'};
	public static Boolean isRunning_CalcDERAppPhaseTotals = false;
	public static Integer ROUNDING_DEC_PLACES = 2;
	public static String  INTEGRATION_PROFILE = 'Integration Profile';

	public static Id PROD_ORG_ID = '00D5L0000008aLNUAY';
	@TestVisible private static Map<String, String> RegionEmailAddresses = new Map<String, String>
	{
		'Prod-East'       => 'Solareast@AusnetServices.com.au',
		'Prod-Central'    => 'Solarcentral@AusnetServices.com.au',
		'Prod-North'      => 'Solarnorth@AusnetServices.com.au',
		'NonProd-East'    => 'lisa.forden@ausnetservices.com.au',
		'NonProd-Central' => 'Saurabh.bhalla@ausnetservices.com.au',
		'NonProd-North'   => 'murray.ogrady@ausnetservices.com.au'
	};


	public static void CalcDERAppPhaseTotals(Set<Id> derAppIds)
	{
		CalcDERAppPhaseTotals(derAppIds, true);
	}

	public static void CalcDERAppPhaseTotals(Set<Id> derAppIds, Boolean updateCase)
	{
		if (isRunning_CalcDERAppPhaseTotals) return;
		isRunning_CalcDERAppPhaseTotals = true;

		System.debug('UtilFieldCalcs.CalcDERAppPhaseTotals');
		System.debug('num derAppIds: ' + derAppIds.size());
		System.debug('updateCase: ' + updateCase);

		if (derAppIds == null || derAppIds.isEmpty())
			return;

		Map<Id, SObject> argsDERApps = UtilDatabase.getMapOfRecords(derAppIds);

		String querystr = '';
			querystr += UtilDatabase.getAllFields('Device__c');
			querystr += ' FROM Device__c';
			querystr += ' WHERE DER_Application__c IN :derAppIds';
			querystr += ' AND RecordType.DeveloperName IN :CalcTotalFields_AllowedRTs';
			querystr += ' AND Decommission__c = false';

		Map<Id, DER_Application__c> DERAppsMap = new Map<Id, DER_Application__c>();
		Map<Id, Case> DERAppIdCaseStatus = new Map<Id, Case>();
		Set<Id> updCases = new Set<Id>();

		for (Case c: [SELECT Id, DER_Application__c, Status, Type FROM Case WHERE DER_Application__c IN :derAppIds])
			DERAppIdCaseStatus.put(c.DER_Application__c, c);

		for (Device__c device: Database.query(querystr))
		{
			Id DERAppId = device.DER_Application__c;
			DER_Application__c argDERApp = (DER_Application__c)argsDERApps.get(DERAppId);

			System.debug('DERAppId: ' + DERAppId);

			Id caseId;
			String caseStatus = argDERApp.Case_Status__c;
			String caseType = argDERApp.Case_Type__c;

			// TODO: Deprecate?
			if (DERAppIdCaseStatus.containsKey(DERAppId))
			{
				caseStatus = DERAppIdCaseStatus.get(DERAppId).Status;
				caseId = DERAppIdCaseStatus.get(DERAppId).Id;
				caseType = DERAppIdCaseStatus.get(DERAppId).Type;
				// System.debug('Error: Cannot find Case Status.');
				// continue;
			}

			//	If Case Type == New or Aug,
			//	and the Device Existing = true
			//	then skip this device. 
			//	We do not sum existing lines for these case types.
			Set<String> deltaCaseTypes = new Set<String>{'New', 'Augmentation'};
			if (deltaCaseTypes.contains(caseType) && device.Existing_Device__c)
			{
				// New and Aug should not sum Existing device lines
				continue;
			}

			if (((caseStatus == 'New' || caseStatus == 'More Info Required' || caseStatus == 'Invoice Pending' || caseStatus == 'Technical Assessment') && device.Requested__c == true) ||
				((caseStatus == 'Installation Pending' || caseStatus == 'Offer Sent') && device.Approved__c == true) ||
				((caseStatus == 'Installation Validation' || caseStatus == 'Designer Validation' || caseStatus == 'Publish' || caseStatus == 'Reconfig' || caseStatus == 'Complete' || caseStatus == 'Cancelled' ) && device.Installed__c == true))
			{
				if (!DERAppsMap.containsKey(DERAppId))
				{
					DER_Application__c newDERApp = new DER_Application__c(Id = DERAppId);
					newDERApp.Ph_A_New_Capacity__c = 0;
					newDERApp.Ph_B_New_Capacity__c = 0;
					newDERApp.Ph_C_New_Capacity__c = 0;
					newDERApp.Ph_Unk_New_Capacity__c = 0;
					DERAppsMap.put(DERAppId, newDERApp);
				}

				DER_Application__c derApp = DERAppsMap.get(DERAppId);
				if (caseId != null) updCases.add(caseId);

				if (device.AC_Equip_Cap__c == null) device.AC_Equip_Cap__c = 0;
				if (device.Device_Count__c == null) device.Device_Count__c = 1;

				Decimal TotalCapacity = device.AC_Equip_Cap__c * device.Device_Count__c;

				if (device.Device_Phase__c == 'A')
				{
					System.debug('Phase A');
					derApp.Ph_A_New_Capacity__c += TotalCapacity;
				}
				else if (device.Device_Phase__c == 'B')
				{
					System.debug('Phase B');
					derApp.Ph_B_New_Capacity__c += TotalCapacity;
				}
				else if (device.Device_Phase__c == 'C')
				{
					System.debug('Phase C');
					derApp.Ph_C_New_Capacity__c += TotalCapacity;
				}
				else if (device.Device_Phase__c == '3 Phase')
				{
					System.debug('Multi phase');
					Decimal numPhases = 3;

					// Capacity
					// Check if mod 3 == 0
					if (mod(TotalCapacity, numPhases) == 0)
					{
						// If 0, split evenly, be on our way.
						Decimal Cap = TotalCapacity / numPhases;

						derApp.Ph_A_New_Capacity__c += Cap;
						derApp.Ph_B_New_Capacity__c += Cap;
						derApp.Ph_C_New_Capacity__c += Cap;
					}
					else
					{
						// If != 0, use rounding/asymmetric logic.
						Decimal Cap = TotalCapacity / numPhases;

						// round it to 2 dp
						Cap = Cap.setscale(ROUNDING_DEC_PLACES);

						// A = num, B = num
						derApp.Ph_A_New_Capacity__c += Cap;
						derApp.Ph_B_New_Capacity__c += Cap;

						// C = difference of total - A+B.
						Decimal CapC = TotalCapacity - (Cap * 2);
						derApp.Ph_C_New_Capacity__c += CapC;
					}
				}
				else if (device.Device_Phase__c == null)
				{
					derApp.Ph_Unk_New_Capacity__c += TotalCapacity;
				}
			}
		}

		if (!DERAppsMap.isEmpty())
			update DERAppsMap.values();

		// update the cases too!
		if (updateCase && !updCases.isEmpty())
			update getCases(updCases);
	}

	private static List<Case> getCases(Set<Id> caseIds)
	{
		List<Case> cases = new List<Case>();
		for (Id caseId: caseIds)
			cases.add(new Case(Id = caseId));
		return cases;
	}

	private static Integer mod(Decimal d1, Decimal d2)
	{
		if (d1 == null || d2 == null)
			return -1;

		// Check if whole numbers
		Decimal d1f = d1.round(System.RoundingMode.FLOOR);
		Decimal d2f = d2.round(System.RoundingMode.FLOOR);
		if (d1f != d1 || d2f != d2) return -1;

		Long l1 = d1.longValue();
		Long l2 = d2.longValue();

		return Math.mod(l1, l2).intValue();
	}

	public static void CalsGenerationTypesAndPhasesTotals(Set<Id> derAppIds)
	{
		isRunning_CalcDERAppPhaseTotals = true;
		List<String> allowedRTId = new List<String>();
		List<DER_Application__c> derAppListToUpdate = new List<DER_Application__c>();
		Map<Id,DER_Application__c> idDerAppMap = new Map<Id,DER_Application__c>();
		Map<Id,List<Device__c>> derappDevicesMap = new  Map<Id,List<Device__c>>();
		for (Id item: UtilDatabase.getRecordTypes().keySet())
		{
			if (CalcTotalFields_AllowedRTs.contains(UtilDatabase.getRecordTypes().get(item))){
				allowedRTId.add(item);
			}
		}

		System.debug('derAppIds----------------------->'+derAppIds);
		System.debug('allowedRTId----------------------->'+allowedRTId);

		String querystr = '';
		querystr += UtilDatabase.getAllFields('Device__c');
		querystr += ' FROM Device__c ';
		querystr += 'WHERE DER_Application__c IN: derAppIds';
		querystr += ' AND RecordTypeId IN: allowedRTId';
		//querystr += ' AND Decommission__c = false';


		System.debug('querystr---------------------------->'+querystr);

		List<Device__c> lstDevice = Database.query(querystr);

		List<Device__c> existingLst;
		for (Device__c dev : lstDevice)
		{
			if (derappDevicesMap.containsKey(dev.DER_Application__c))
			{
				existingLst = derappDevicesMap.get(dev.DER_Application__c);
				existingLst.add(dev);
				derappDevicesMap.put(dev.DER_Application__c, existingLst);
			}else {
				derappDevicesMap.put(dev.DER_Application__c, new List<Device__c>{dev});
			}
		}
	   // if (!derappDevicesMap.isEmpty())
	   // {
			List<Id> lstDERAppId = new List<Id>();
			lstDERAppId.addAll(derappDevicesMap.keySet());

			querystr = '';
			querystr += UtilDatabase.getAllFields('DER_Application__c');
			querystr += ' FROM DER_Application__c ';
			querystr += 'WHERE Id IN: derAppIds';

			System.debug('querystr--------->'+querystr);

			List<DER_Application__c> lstDERApp = Database.query(querystr);
			for (DER_Application__c derApp :lstDERApp )
			{
				idDerAppMap.put(derApp.Id,derApp);
			}
		//}
		for (Id derApppId : derAppIds)
		{
			Set<String> generationTypes = new Set<String>();
			Set<String> devPhases = new Set<String>();
			if (derappDevicesMap.get(derApppId) != null)
			{
				for (Device__c dev :derappDevicesMap.get(derApppId) )
				{
					if (dev.Decommission__c == false)
					{
						/*if (dev.AC_Equip_Sub_Type__c != null)
						{
							generationTypes.add(dev.AC_Equip_Sub_Type__c);
						}*/
						if((idDerAppMap.get(derApppId).Case_Status__c == 'New' || idDerAppMap.get(derApppId).Case_Status__c == 'More Info Required'
							|| idDerAppMap.get(derApppId).Case_Status__c == 'Invoice Pending' || idDerAppMap.get(derApppId).Case_Status__c == 'Technical Assessment'
							|| idDerAppMap.get(derApppId).Case_Status__c == 'Offer Sent' ||  idDerAppMap.get(derApppId).Case_Status__c == 'Installation Pending')
							 && dev.Requested__c == true && dev.AC_Equip_Sub_Type__c != null )
						{
                            generationTypes.add(dev.AC_Equip_Sub_Type__c);
						}
						if((idDerAppMap.get(derApppId).Case_Status__c == 'Installation Validation' || idDerAppMap.get(derApppId).Case_Status__c == 'Designer Validation'
							|| idDerAppMap.get(derApppId).Case_Status__c == 'Publish' || idDerAppMap.get(derApppId).Case_Status__c == 'Reconfig'
							|| idDerAppMap.get(derApppId).Case_Status__c == 'Complete')
							 && dev.Installed__c == true && dev.AC_Equip_Sub_Type__c != null )
						{
                            generationTypes.add(dev.AC_Equip_Sub_Type__c);
						}
						if(dev.Existing_Device__c && dev.AC_Equip_Sub_Type__c != null)
						{
							generationTypes.add(dev.AC_Equip_Sub_Type__c);
						}
						if (dev.Device_Phase__c != null)
						{
							devPhases.add(dev.Device_Phase__c);
						}
					}
				}
				if ( idDerAppMap.get(derApppId) != null)
				{
					DER_Application__c derApp = idDerAppMap.get(derApppId);
					String genTypes = '';
					String phases = '';
					if (!generationTypes.isEmpty())
					{
						for (String s : generationTypes)
						{
							if (genTypes  == '')
							{
								genTypes = s;
							}
							else
							{
								genTypes = genTypes +';'+s;
							}
						}
						if (genTypes != '')
						{
							derApp.Generation_Types__c = genTypes;
						}
					}
					 else
						{
							derApp.Generation_Types__c = null;
						}
					if (!devPhases.isEmpty())
					{
						for (String s : devPhases)
						{
							if (phases  == '')
							{
								phases = s;
							}
							else
							{
								phases = phases +';'+s;
							}
						}
						if (phases != '')
						{
							derApp.Phases__c = phases;
						}

					}
					//Fix for CMC-2303
					/*
					 else
						{
							derApp.Phases__c = null;
						}*/
					derAppListToUpdate.add(derApp);
				}
			}
			else
			{
				DER_Application__c derApp =  idDerAppMap.get(derApppId);
				derApp.Phases__c = null;
				derApp.Generation_Types__c = null;
				derAppListToUpdate.add(derApp);
			}

		}
		if (!derAppListToUpdate.isEmpty())
		{
			update derAppListToUpdate;
		}
	}

	public static void SetRegionEmailAddress(List<SObject> newSObjs)
	{
		String org = 'NonProd';
		if (UserInfo.getOrganizationId() == PROD_ORG_ID)
			org = 'Prod';

		for (SObject o: newSObjs)
		{
			Case derCase = (Case)o;
			derCase.Region_Email_Address__c = null;

			if (derCase.Region__c != null)
			{
				String key = org + '-' + derCase.Region__c;

				if (RegionEmailAddresses.containsKey(key))
					derCase.Region_Email_Address__c = RegionEmailAddresses.get(key);
			}
		}
	}
}