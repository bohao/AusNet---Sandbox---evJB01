/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 23 Sep 2019
  @Description : Class for DER_Application__c Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
public with sharing class Trig_DER_Application implements UtilTrigHandle{
	// *********************************************************************
	// *** Disable logic

	public static Boolean TrigDisabled = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().DER_Application_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}

	// *********************************************************************
	// *** Trigger contexts

	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		// Avolid calling below methods if already called from future methods
		if (!UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals && !DER_Application_Util.isRunning_PopulateExternalMeter)
		{
			//Both method calls future method
			ValidateDERApp_TotalCalc(newSObjs, oldSObjs);
			Validate_ExternalMeterPop(newSObjs, oldSObjs);
		}
		upsertDeviceRecords(newSObjs,oldSObjs);
	}

	public void AfterInsert(Map<Id, SObject> newSObjs)
	{
		Validate_ExternalMeterPop(newSObjs, null);
		upsertDeviceRecords(newSObjs,null);
	}

	public void BeforeInsert(List<SObject> newSObjs) 
	{
		TotalSystemCapExpCalc(newSObjs);
	}

	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		TotalSystemCapExpCalc(newSObjs.values());
		//----Start - Fix for defect CMC-2233 and CMC-2310----//
		CheckExistingExport(newSObjs.values());
		//----End---------//
	}

	// if context is not implemented, condense into one-liners
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> newSObjs) {}
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}

	// *********************************************************************
	// *** Trigger methods

	// Calc Total System Export and Capacity values
	private void TotalSystemCapExpCalc(List<SObject> newSObjs)
	{
		switch on Trigger.operationType
		{
			when BEFORE_INSERT, BEFORE_UPDATE
			{
				for (sObject sObjItem: newSObjs)
				{
					DER_Application__c newDerApp = (DER_Application__c)sObjItem;

					newDerApp.Total_Sys_Exp__c = newDerApp.Ph_A_Total_Export__c + newDerApp.Ph_B_Total_Export__c + newDerApp.Ph_C_Total_Export__c + newDerApp.Ph_Unk_Total_Export__c;
					newDerApp.Total_Sys_Cap__c = newDerApp.Ph_A_Total_Capacity__c + newDerApp.Ph_B_Total_Capacity__c + newDerApp.Ph_C_Total_Capacity__c + newDerApp.Ph_Unk_Total_Capacity__c;
				}
			}
		}
	}

	// Check for total existing export when "Import Existing Asset" flag is checked
	private void CheckExistingExport(List<SObject> newSObjs)
	{
		switch on Trigger.operationType
		{
			when BEFORE_UPDATE
			{
				for (sObject sObjItem: newSObjs)
				{
					DER_Application__c newExpDerApp = (DER_Application__c)sObjItem;
					if ((newExpDerApp.Import_Existing_Assets__c) && (newExpDerApp.Total_Exist_Export__c != null && newExpDerApp.Total_Exist_Export__c == 0) && (newExpDerApp.Ph_Unk_Exist_Export__c != null && newExpDerApp.Ph_Unk_Exist_Export__c == 0) && (newExpDerApp.Existing_Total_Export_Rating__c != null  &&  newExpDerApp.Existing_Total_Export_Rating__c > 0 ))
						newExpDerApp.Ph_Unk_Exist_Export__c = newExpDerApp.Existing_Total_Export_Rating__c;
						                 
				}
			}
		}
	}

	// Calculate totals and update the DER Applicaiton
	private void  ValidateDERApp_TotalCalc(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		System.debug('*** Trig_DER_Application.ValidateDERApp_TotalCalc()');
		if (UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals) return;

		Set<Id> validDERAppIds = new Set<Id>();

		switch on Trigger.operationType
		{
			when AFTER_UPDATE
			{
				for (sObject sObjItem: newSObjs.values())
				{
					DER_Application__c newDERAppItem = (DER_Application__c)sObjItem;
					DER_Application__c oldDERAppItem = (DER_Application__c)oldSObjs.get(newDERAppItem.Id);

					if (newDERAppItem.Ph_A_New_Capacity__c != oldDERAppItem.Ph_A_New_Capacity__c ||
						newDERAppItem.Ph_B_New_Capacity__c != oldDERAppItem.Ph_B_New_Capacity__c ||
						newDERAppItem.Ph_C_New_Capacity__c != oldDERAppItem.Ph_C_New_Capacity__c)
					{
						validDERAppIds.add(newDERAppItem.Id);
					}
				}
			}
		}

		//-----------------------------------------------------------//
		//--------- Calculate DER Application Phase Total -----------//
		//-----------------------------------------------------------//

		if (!validDERAppIds.isEmpty())
			UtilFieldCalcs.CalcDERAppPhaseTotals(validDERAppIds);
	}

	// Populate External Meter Lookup and relavent details
	private void Validate_ExternalMeterPop(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		System.debug('*** Trig_DER_Application.Validate_ExternalMeterPop()');
		List<Id> validExtMeter_Pop = new List<Id>();
		List<Id> validExtMeter_Clear = new List<Id>();
		
		// This trigger executes a future method. If already future, do not run.
		if (System.isFuture())
		{
			System.debug('Already a future, exiting.');
			return;
		}

		switch on Trigger.operationType
		{
			when AFTER_INSERT
			{
				for (SObject sObjItem: newSObjs.values())
				{
					DER_Application__c newDERApp = (DER_Application__c)sObjItem;

					if (newDERApp.Meter_Number__c != null && newDERApp.NMI__c != null)
					{
						validExtMeter_Pop.add(newDERApp.Id);
					}
				}
			}

			when AFTER_UPDATE
			{
				for (SObject sObjItem: newSObjs.values())
				{
					DER_Application__c newDERApp = (DER_Application__c)sObjItem;
					DER_Application__c oldDERApp = (DER_Application__c)oldSObjs.get(newDERApp.Id);

					if (isPopulated('Meter_Number__c', newDERApp, oldDERApp) && newDERApp.NMI__c != null)
					{
						validExtMeter_Pop.add(newDERApp.Id);
					}
					else if (isCleared('Meter_Number__c', newDERApp, oldDERApp) && newDERApp.NMI__c != null)
					{
						validExtMeter_Clear.add(newDERApp.Id);
					}

					if (isPopulated('NMI__c', newDERApp, oldDERApp) && newDERApp.Meter_Number__c != null)
					{
						validExtMeter_Pop.add(newDERApp.Id);
					}
					else if (isCleared('NMI__c', newDERApp, oldDERApp) && oldDERApp.Meter_Number__c != null)
					{
						validExtMeter_Clear.add(newDERApp.Id);
					}

					if(newDERApp.Meter_Number__c == oldDERApp.Meter_Number__c
					&& newDERApp.Meter_Ref__c == null
					&& newDERApp.NMI__c != null
					)
					{
						validExtMeter_Pop.add(newDERApp.Id);
					}
				}
			}
		}

		DER_Application_Util.PopulateExternalMeter(validExtMeter_Pop, validExtMeter_Clear);
	}

	private void upsertDeviceRecords(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		Map<Id, Case> idCaseMap = new Map<Id, Case>();
		Map<Id, DER_Application__c> idDerAppMap = new Map<Id, DER_Application__c>();
		List<SObject> listOfderApps = new List<SObject>();
		List<SObject> updatedlistOfderApps = new List<SObject>();

		for (Case c: [SELECT Id, Status, RecordTypeId, DER_Application_Scenario__c, DER_Application__c FROM Case WHERE DER_Application__c IN :newSObjs.keySet()])
		{
			idCaseMap.put(c.DER_Application__c, c);
		}

		switch on Trigger.operationType
		{
			when AFTER_INSERT
			{
				for (SObject sObjItem: newSObjs.values())
				{
					DER_Application__c newDERApp = (DER_Application__c)sObjItem;

					if (newDERApp.Import_Existing_Assets__c)
					{
						listOfderApps.add(newDERApp);
						String caseStatus = newDERApp.Case_Status__c;
						String DERScenario = newDERApp.DER_Scenario__c;

						if (idCaseMap.containsKey(newDERApp.Id))
						{
							caseStatus = idCaseMap.get(newDERApp.Id).Status;
							DERScenario = idCaseMap.get(newDERApp.Id).DER_Application_Scenario__c;
						}

						if (newDERApp.NMI__c != null)
						{
							if ((caseStatus == 'New' && DERScenario == 'Manual') ||
								(caseStatus == 'Installation Pending' && DERScenario == 'Auto'))
							{
								idDerAppMap.put(newDERApp.Id,newDERApp);
							}
						}
					}
				}
			}

			when AFTER_UPDATE
			{
				for (SObject sObjItem: newSObjs.values())
				{
					DER_Application__c newDERApp = (DER_Application__c)sObjItem;
					DER_Application__c oldDERApp = (DER_Application__c)oldSObjs.get(newDERApp.Id);

					if (newDERApp.Import_Existing_Assets__c && 
						oldDERApp.Import_Existing_Assets__c != newDERApp.Import_Existing_Assets__c)
					{
						listOfderApps.add(newDERApp);
						String caseStatus = newDERApp.Case_Status__c;
						String DERScenario = newDERApp.DER_Scenario__c;

						if (idCaseMap.containsKey(newDERApp.Id))
						{
							caseStatus = idCaseMap.get(newDERApp.Id).Status;
							DERScenario = idCaseMap.get(newDERApp.Id).DER_Application_Scenario__c;
						}

						if (newDERApp.NMI__c != null)
						{
							if ((caseStatus == 'New' && DERScenario == 'DER_App_Manual') ||
								(caseStatus == 'Installation Pending' && DERScenario == 'DER_App_Auto'))
							{
								idDerAppMap.put(newDERApp.Id,newDERApp);
							}
						}
					}
				}
			}
		}

		if (idDerAppMap.size() > 0)
		{
			UpsertAssetRecords.copyExistingAssetToDevices(idDerAppMap);
		}

		if (!listOfderApps.isEmpty())
		{
			for (DER_Application__c derApp: (List<DER_Application__c>) listOfderApps)
			{
				DER_Application__c dapp = new DER_Application__c(Id = derApp.Id);
				dapp.Import_Existing_Assets__c = false;
				updatedlistOfderApps.add(dapp);
			}
		}

		if (!updatedlistOfderApps.isEmpty())
			update updatedlistOfderApps;
	}

	// --------------------------------------------------------------//
	//------- DER_Application__c Trigger utility methods --------------//
	// --------------------------------------------------------------//

	private static Boolean isCleared(String f, DER_Application__c newDERApp, DER_Application__c oldDERApp)
	{
		Boolean isFieldCleared = false;
		if(newDERApp.get(f) == null)
			isFieldCleared = newDERApp.get(f) != oldDERApp.get(f);
		else if(newDERApp.get(f) instanceof Date)
			isFieldCleared = newDERApp.get(f) == null && ((Date)newDERApp.get(f)) != ((Date)oldDERApp.get(f));
		else
			isFieldCleared = String.isBlank((String)newDERApp.get(f)) && ((String)newDERApp.get(f)) != ((String)oldDERApp.get(f));
		return isFieldCleared;
	}

	private static Boolean isPopulated(String f, DER_Application__c newDERApp, DER_Application__c oldDERApp)
	{
		Boolean isFieldPopulated = false;
		if(newDERApp.get(f) == null)
			isFieldPopulated = false;
		else if(newDERApp.get(f) instanceof Date)
			isFieldPopulated = newDERApp.get(f) != null && ((Date)newDERApp.get(f)) != ((Date)oldDERApp.get(f));
		else
			isFieldPopulated = String.isNotBlank((String)newDERApp.get(f)) && ((String)newDERApp.get(f)) != ((String)oldDERApp.get(f));
		return isFieldPopulated;
	}
}