/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 20 Sep 2019
  @Description : Class for Device Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -------------------------------------------------------------------------------------------------------
  24/10/19          Palash Awasthi                Added method getDerAppForDefaults() on  After insert
  01/11/2019        Rohit Middha                      CMC-1499
  -------------------------------------------------------------------------------------------------------
*/
public with sharing class Trig_Device implements UtilTrigHandle{
	// *********************************************************************
	// *** Disable logic

	public static Boolean TrigDisabled = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().Device_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}

	// *********************************************************************
	// *** Trigger contexts

	public void AfterInsert(Map<Id, SObject> newSObjs)
	{
		ValidateDevices_TotalCalc(newSObjs, null);
		//getDerAppForDefaults(newSObjs);
		ValidateDevices_GenerationTypesAndPhases(newSObjs, null);
		setKeyFields(newSObjs.values());
	}

	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		ValidateDevices_TotalCalc(newSObjs, oldSObjs);
		ValidateDevices_GenerationTypesAndPhases(newSObjs, oldSObjs);
		setL3DevicesStatusAsApproved(newSObjs, oldSObjs);
		setL3DevicesStatusAsDecomisssioned(newSObjs, oldSObjs);
	}

	public void AfterDelete(Map<Id, SObject> oldSObjs)
	{
		ValidateDevices_TotalCalc(null, oldSObjs);
		ValidateDevices_GenerationTypesAndPhases(null, oldSObjs);
	}

	public void AfterUndelete(Map<Id, SObject> newSObjs)
	{
		ValidateDevices_TotalCalc(newSObjs, null);
		ValidateDevices_GenerationTypesAndPhases(newSObjs, null);
	}

	public void BeforeInsert(List<SObject> newSObjs)
	{
		getDerDeviceForDefaults(newSObjs);
	}

	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		setKeyFields(newSObjs.values());
		getDerDeviceForDefaults(newSObjs,oldSObjs);
	}


	// if context is not implemented, condense into one-liners
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}

	// *********************************************************************
	// *** Trigger methods

	private static Boolean isRunningSetKeyFields = false;
	private static void setKeyFields(List<SObject> newSObjs)
	{
		if (isRunningSetKeyFields) return;
		isRunningSetKeyFields = true;

		// Get NMIs for our devices
		Map<Id, String> DeviceNMIs = new Map<Id, String>();

		for (SObject sObjItem: newSObjs)
			DeviceNMIs.put(sObjItem.Id, null);

		for (Device__c newDevice: [SELECT Id, Name, RecordTypeId, DER_Application__c, Parent_Device__c,
								DER_Application__r.NMI__r.NMI__c,
								Parent_Device__r.DER_Application__r.NMI__r.NMI__c
								FROM Device__c
								WHERE Id IN :DeviceNMIs.keySet()])
		{
			String RTName = UtilDatabase.getRecordTypes().get(newDevice.RecordTypeId);

			if (RTName == 'Device_L2' && newDevice.DER_Application__r.NMI__r.NMI__c != null)
			{
				DeviceNMIs.put(newDevice.Id, newDevice.DER_Application__r.NMI__r.NMI__c);
			}
			else if (RTName == 'Device_L3' && newDevice.Parent_Device__r.DER_Application__r.NMI__r.NMI__c != null)
			{
				DeviceNMIs.put(newDevice.Id, newDevice.Parent_Device__r.DER_Application__r.NMI__r.NMI__c);
			}
		}

		// Process records
		Map<Id, SObject> updSObjs = new Map<Id, SObject>();

		// This trigger runs in Before Update and After Insert.
		//		Before Update context can update the triggered SObj directly.
		//		After Insert context cannot, and must issue an update to a separate SObj instance.
		for (SObject sObjItem: newSObjs)
		{
			Device__c device = (Device__c)sObjItem;
			String RTName = UtilDatabase.getRecordTypes().get(device.RecordTypeId);

			Device__c updDevice;

			// This code provides a single point of updating the record (updDevice)
			if (Trigger.operationType == System.TriggerOperation.BEFORE_UPDATE)
				updDevice = device;
			else if (Trigger.operationType == System.TriggerOperation.AFTER_INSERT)
			{
				if (!updSObjs.containsKey(device.Id))
					updSObjs.put(device.Id, new Device__c(Id = device.Id));

				updDevice = (Device__c)updSObjs.get(device.Id);
			}

			if (updDevice == null)
				continue;


			// Now we set the fields as desired.
			//	Note we run comparison/read fields on device instance, but only set fields on updDevice instance.
			if (device.Id != null && device.SID__c == null)
			{
				// Set Sitecore Id to SF Id
				updDevice.SID__c = device.Id;
			}

			if (device.AEMO_Id__c != null && device.NMI_AEMO_Id__c == null)
			{
				// Get NMI
				if (!DeviceNMIs.containsKey(device.Id) || DeviceNMIs.get(device.Id) == null)
					continue;
				
				String NMI = DeviceNMIs.get(device.Id);

				// Set the NMI_AEMO_Id
				updDevice.NMI_AEMO_Id__c = NMI + '-' + RTName.removeStart('Device_') + '-' + device.AEMO_Id__c;
			}
		}

		if (!updSObjs.isEmpty()) update updSObjs.values();
	}


	// Calculate totals and update the DER Applicaiton
	private void  ValidateDevices_TotalCalc(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		System.debug('*** Trig_Device.ValidateDevices_TotalCalc()');
		if (UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals) return;

		Set<Id> validDERAppIds = new Set<Id>();
		Set<Id> allowedRTIds   = new Set<Id>();

		// Get the Record Type Ids.
		for (String RTName: UtilFieldCalcs.CalcTotalFields_AllowedRTs)
			allowedRTIds.add(UtilDatabase.getRecordTypeNames('Device__c').get(RTName));

		switch on Trigger.operationType
		{
			when AFTER_INSERT
			{
				for (SObject sObjItem: newSObjs.values())
				{
					Device__c newDeviceItem = (Device__c)sObjItem;

					if (!allowedRTIds.contains(newDeviceItem.RecordTypeId))
						continue;

					if (newDeviceItem.DER_Application__c != null && !newDeviceItem.Decommission__c)
						validDERAppIds.add(newDeviceItem.DER_Application__c);
				}
			}
			when AFTER_UPDATE
			{
				for (sObject sObjItem: newSObjs.values())
				{
					Device__c newDeviceItem = (Device__c)sObjItem;
					Device__c oldDeviceItem = (Device__c)oldSObjs.get(newDeviceItem.Id);

					if (!allowedRTIds.contains(newDeviceItem.RecordTypeId))
						continue;

					if (newDeviceItem.DER_Application__c != null &&
					   (newDeviceItem.DER_Application__c != oldDeviceItem.DER_Application__c ||
						newDeviceItem.RecordTypeId       != oldDeviceItem.RecordTypeId       ||
						newDeviceItem.Device_Phase__c    != oldDeviceItem.Device_Phase__c    ||
						newDeviceItem.AC_Equip_Cap__c    != oldDeviceItem.AC_Equip_Cap__c    ||
						newDeviceItem.Requested__c       != oldDeviceItem.Requested__c       ||
						newDeviceItem.Approved__c        != oldDeviceItem.Approved__c        ||
						newDeviceItem.Installed__c       != oldDeviceItem.Installed__c       ||
						newDeviceItem.Decommission__c    != oldDeviceItem.Decommission__c))
					{
						if (newDeviceItem.DER_Application__c != null)
							validDERAppIds.add(newDeviceItem.DER_Application__c);

						if (oldDeviceItem.DER_Application__c != null)
							validDERAppIds.add(oldDeviceItem.DER_Application__c);
					}
				}
			}
			when AFTER_DELETE
			{
				for (SObject sObjItem: oldSObjs.values())
				{
					Device__c newDeviceItem = (Device__c)sObjItem;

					if (!allowedRTIds.contains(newDeviceItem.RecordTypeId))
						continue;

					if (newDeviceItem.DER_Application__c != null && !newDeviceItem.Decommission__c)
						validDERAppIds.add(newDeviceItem.DER_Application__c);
				}
			}
			when AFTER_UNDELETE
			{
				for (SObject sObjItem: newSObjs.values())
				{
					Device__c newDeviceItem = (Device__c)sObjItem;

					if (!allowedRTIds.contains(newDeviceItem.RecordTypeId))
						continue;

					if (newDeviceItem.DER_Application__c != null && !newDeviceItem.Decommission__c)
						validDERAppIds.add(newDeviceItem.DER_Application__c);
				}
			}
		}

		//-----------------------------------------------------------//
		//--------- Calculate DER Application Phase Total -----------//
		//-----------------------------------------------------------//

		if (!validDERAppIds.isEmpty())
			UtilFieldCalcs.CalcDERAppPhaseTotals(validDERAppIds);
	}

	private static void getDerDeviceForDefaults(List<SObject> newSObjs)
	{
		System.debug('******************Before device insert trigger logic*********************');
		Map<Device__c,String> deviceOfferTypeMap = new Map<Device__c,String>();
		Set<Id> derAppIdset = new Set<Id>();
		Map<Id,String> derIdCaseAggrementMap = new Map<Id,String>();
		for (SObject sObjItem: newSObjs)
		{
			Device__c newDevice = (Device__c)sObjItem;
			if (newDevice.DER_Application__c != null)
			{
				derAppIdset.add(newDevice.DER_Application__c);
			}
		}
		System.debug('############# DerAppIdset is ########'+derAppIdset);
		for (Case c : [Select Id,Agreement_Type__c,DER_Application__c from Case where DER_Application__c in : derAppIdset])
		{
			derIdCaseAggrementMap.put(c.DER_Application__c,c.Agreement_Type__c);
		}

		for (SObject sObjItem: newSObjs)
		{
			Device__c newDevice = (Device__c)sObjItem;
			String RTName = UtilDatabase.getRecordTypes().get(newDevice.RecordTypeId);
			if (newDevice.AC_Equip_Type__c != null && RTName == 'Device_L2' && newDevice.DER_Application__c != null
			 && derIdCaseAggrementMap.get(newDevice.DER_Application__c) != null )
			{
				 deviceOfferTypeMap.put(newDevice,derIdCaseAggrementMap.get(newDevice.DER_Application__c));
			}
		}

		if (deviceOfferTypeMap != null && !deviceOfferTypeMap.isEmpty())
		{
			DER_Defaults.applyDefault(deviceOfferTypeMap);
		}
	}

	private void  ValidateDevices_GenerationTypesAndPhases(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		System.debug('*** Trig_Device.ValidateDevices_GenerationTypesAndPhases()');
		Set<Id> validDERAppIds = new Set<Id>();
		switch on Trigger.operationType {
			when AFTER_INSERT {
				for (SObject sObjItem: newSObjs.values())
				{
					Device__c newDeviceItem = (Device__c)sObjItem;
					if (newDeviceItem.DER_Application__c != null && newDeviceItem.Decommission__c == false)
					{
						validDERAppIds.add(newDeviceItem.DER_Application__c);
					}

				}
			}
			when AFTER_UPDATE {
				for (sObject sObjItem: newSObjs.values())
				{
					Device__c newDeviceItem = (Device__c)sObjItem;
					if (newDeviceItem.DER_Application__c != null
					   && (
						   newDeviceItem.AC_Equip_Sub_Type__c != ((Device__c)oldSObjs.get(newDeviceItem.Id)).AC_Equip_Sub_Type__c
						   || newDeviceItem.Device_Phase__c != ((Device__c)oldSObjs.get(newDeviceItem.Id)).Device_Phase__c
						   || newDeviceItem.RecordTypeId != ((Device__c)oldSObjs.get(newDeviceItem.Id)).RecordTypeId
						   || newDeviceItem.DER_Application__c != ((Device__c)oldSObjs.get(newDeviceItem.Id)).DER_Application__c
						   || newDeviceItem.Decommission__c != ((Device__c)oldSObjs.get(newDeviceItem.Id)).Decommission__c
					   )
					  )
					{
						if (newDeviceItem.DER_Application__c != null)
							validDERAppIds.add(newDeviceItem.DER_Application__c);
						if (((Device__c)oldSObjs.get(newDeviceItem.Id)).DER_Application__c != null)
							validDERAppIds.add(((Device__c)oldSObjs.get(newDeviceItem.Id)).DER_Application__c);
					}
				}
			}
			when AFTER_DELETE {
				for (SObject sObjItem: oldSObjs.values())
				{
					Device__c newDeviceItem = (Device__c)sObjItem;
					if (newDeviceItem.DER_Application__c != null && newDeviceItem.Decommission__c == false)
					{
						validDERAppIds.add(newDeviceItem.DER_Application__c);
					}
				}
			}
			when AFTER_UNDELETE {
				for (SObject sObjItem: newSObjs.values())
				{
					Device__c newDeviceItem = (Device__c)sObjItem;
					if (newDeviceItem.DER_Application__c != null && newDeviceItem.Decommission__c == false)
					{
						validDERAppIds.add(newDeviceItem.DER_Application__c);
					}
				}
			}
		}

		//-----------------------------------------------------------//
		//--------- Populate DER Application Phases and Generation Types -----------//
		//-----------------------------------------------------------//

		if (!validDERAppIds.isEmpty()){
		   UtilFieldCalcs.CalsGenerationTypesAndPhasesTotals(validDERAppIds);
		}
	}

	private static void getDerDeviceForDefaults(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		System.debug('******************Before device update trigger logic*********************');
		Map<Device__c,String> deviceOfferTypeMap = new Map<Device__c,String>();
		Set<Id> derAppIdset = new Set<Id>();
		Map<Id,String> derIdCaseAggrementMap = new Map<Id,String>();
		 for (SObject sObjItem: newSObjs.values())
		{
			Device__c newDevice = (Device__c)sObjItem;
			if (newDevice.DER_Application__c != null && newDevice.Existing_Device__c != true)
			{
				derAppIdset.add(newDevice.DER_Application__c);
			}

		}
		System.debug('############# DerAppIdset is ########'+derAppIdset);
		for (Case c : [Select Id,Agreement_Type__c,DER_Application__c from Case where DER_Application__c in : derAppIdset])
		{
			derIdCaseAggrementMap.put(c.DER_Application__c,c.Agreement_Type__c);
		}

		for (SObject sObjItem: newSObjs.values())
		{
			Device__c newDevice = (Device__c)sObjItem;
			String RTName = UtilDatabase.getRecordTypes().get(newDevice.RecordTypeId);
			if (newDevice.AC_Equip_Type__c != null && RTName == 'Device_L2' && newDevice.DER_Application__c != null
			 && derIdCaseAggrementMap.get(newDevice.DER_Application__c) != null &&
			   newDevice.AC_Equip_Type__c != ((Device__c)oldSObjs.get(newDevice.Id)).AC_Equip_Type__c &&
			   newDevice.Existing_Device__c != true)
			{
				 deviceOfferTypeMap.put(newDevice,derIdCaseAggrementMap.get(newDevice.DER_Application__c));
			}
		}

		if (deviceOfferTypeMap != null)
		{
			DER_Defaults.applyDefault(deviceOfferTypeMap);
		}

	}

	private static void setL3DevicesStatusAsApproved(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		Map<Id,Boolean> l2IdMap = new Map<Id,Boolean>();
		List<Device__c> l3IdSet = new List<Device__c>();
		switch on Trigger.operationType {
			when AFTER_UPDATE {
				for (sObject sObjItem: newSObjs.values())
				{
					Device__c newDeviceItem = (Device__c)sObjItem;
					Device__c oldDeviceItem = (Device__c)oldSObjs.get(newDeviceItem.Id);
					String RTName = UtilDatabase.getRecordTypes().get(newDeviceItem.RecordTypeId);

					if (newDeviceItem.Approved__c != oldDeviceItem.Approved__c &&  RTName == 'Device_L2' &&
						newDeviceItem.DER_Application__c != null)
					{
                      l2IdMap.put(newDeviceItem.Id,newDeviceItem.Approved__c);
					}
				}
                
			}

		}
		if(l2IdMap.size() > 0)
		{
          for(Device__c dev : [Select Id,Approved__c,Parent_Device__c from Device__c where 	Parent_Device__c in :l2IdMap.keySet()])
		  {
			  dev.Approved__c = l2IdMap.get(dev.Parent_Device__c);
              l3IdSet.add(dev);
		  }
		}
		if(!l3IdSet.isEmpty())
		{
          update l3IdSet;
		}
	}

	private static void setL3DevicesStatusAsDecomisssioned(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		Map<Id,Boolean> l2IdMap = new Map<Id,Boolean>();
		List<Device__c> l3IdSet = new List<Device__c>();
		switch on Trigger.operationType {
			when AFTER_UPDATE {
				for (sObject sObjItem: newSObjs.values())
				{
					Device__c newDeviceItem = (Device__c)sObjItem;
					Device__c oldDeviceItem = (Device__c)oldSObjs.get(newDeviceItem.Id);
					String RTName = UtilDatabase.getRecordTypes().get(newDeviceItem.RecordTypeId);

					if (newDeviceItem.Decommission__c != oldDeviceItem.Decommission__c &&  RTName == 'Device_L2')
					{
                      l2IdMap.put(newDeviceItem.Id,newDeviceItem.Decommission__c);
					}
				}
                
			}

		}
		if(l2IdMap.size() > 0)
		{
          for(Device__c dev : [Select Id,Decommission__c,Parent_Device__c from Device__c where 	Parent_Device__c in :l2IdMap.keySet()])
		  {
			  dev.Decommission__c = l2IdMap.get(dev.Parent_Device__c);
              l3IdSet.add(dev);
		  }
		}
		if(!l3IdSet.isEmpty())
		{
          update l3IdSet;
		}
	}


}