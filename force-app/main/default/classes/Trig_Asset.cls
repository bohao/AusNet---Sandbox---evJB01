/*
  @author  : Rohit.Middha@ausnetservices.com.au
  @created : 05 Dec 2020
  @Description : Class for Asset Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
*/
public with sharing class Trig_Asset implements UtilTrigHandle
{
	// *********************************************************************
	// *** Disable logic
	public static Boolean TrigDisabled = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().Asset_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}


	// *********************************************************************
	// *** Trigger contexts
	public void AfterInsert(Map<Id, SObject> newSObjs)
	{
		setAssetName(newSObjs, null);
		setKeyFields(newSObjs.values());
	}

	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		setAssetName(newSObjs, oldSObjs);
	}

	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		setKeyFields(newSObjs.values());
	}

	// if context is not implemented, condense into one-liners
	public void BeforeInsert(List<SObject> newSObjs) {}
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> oldSObjs) {}


	// *********************************************************************
	// *** Methods
	private void  setAssetName(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		List<SObject> listOfAssets = new List<SObject>();
		switch on Trigger.operationType
		{
			when AFTER_INSERT, AFTER_UPDATE
			{
				for (Asset trigAsset: (List<Asset>)Trigger.new)
				{
					if (trigAsset.Name != trigAsset.Asset_Id__c)
					{
						Asset updAsset = new Asset(Id = trigAsset.Id);
						updAsset.Name = trigAsset.Asset_Id__c;
						listOfAssets.add(updAsset);
					}
				}
			}
		}

		if (!listOfAssets.isEmpty()) update listOfAssets;
	}

	private static Boolean isRunningSetKeyFields = false;
	private static void setKeyFields(List<SObject> newSObjs)
	{
		if (isRunningSetKeyFields) return;
		isRunningSetKeyFields = true;

		// Get NMIs for our assets
		Map<Id, String> AssetNMIs = new Map<Id, String>();

		for (SObject sObjItem: newSObjs)
			AssetNMIs.put(sObjItem.Id, null);

		for (Asset newAsset: [SELECT Id, Name, RecordTypeId, Conn_Point__c, ParentId,
								Conn_Point__r.NMI__c,
								Parent.Conn_Point__r.NMI__c
								FROM Asset
								WHERE Id IN :AssetNMIs.keySet()])
		{
			String RTName = UtilDatabase.getRecordTypes().get(newAsset.RecordTypeId);

			if (RTName == 'Asset_DER_L2' && newAsset.Conn_Point__r.NMI__c != null)
			{
				AssetNMIs.put(newAsset.Id, newAsset.Conn_Point__r.NMI__c);
			}
			else if (RTName == 'Asset_DER_L3' && newAsset.Parent.Conn_Point__r.NMI__c != null)
			{
				AssetNMIs.put(newAsset.Id, newAsset.Parent.Conn_Point__r.NMI__c);
			}
		}

		// Process records
		Map<Id, SObject> updSObjs = new Map<Id, SObject>();

		// This trigger runs in Before Update and After Insert.
		//		Before Update context can update the triggered SObj directly.
		//		After Insert context cannot, and must issue an update to a separate SObj instance.
		for (SObject sObjItem: newSObjs)
		{
			Asset newAsset = (Asset)sObjItem;
			String RTName = UtilDatabase.getRecordTypes().get(newAsset.RecordTypeId);

			Asset updAsset;

			// This code provides a single point of updating the record (updAsset)
			if (Trigger.operationType == System.TriggerOperation.BEFORE_UPDATE)
				updAsset = newAsset;
			else if (Trigger.operationType == System.TriggerOperation.AFTER_INSERT)
			{
				if (!updSObjs.containsKey(newAsset.Id))
					updSObjs.put(newAsset.Id, new Asset(Id = newAsset.Id));

					updAsset = (Asset)updSObjs.get(newAsset.Id);
			}

			if (updAsset == null)
				continue;

			// Now we set the fields as desired.
			//	Note we run comparison/read fields on newAsset instance, but only set fields on updAsset instance.
			if (newAsset.AEMO_Id__c != null && newAsset.NMI_AEMO_Id__c == null)
			{
				// Get NMI
				if (!AssetNMIs.containsKey(newAsset.Id) || AssetNMIs.get(newAsset.Id) == null)
					continue;
				
				String NMI = AssetNMIs.get(newAsset.Id);

				// Set the NMI_AEMO_Id
				updAsset.NMI_AEMO_Id__c = NMI + '-' + RTName.removeStart('Asset_DER_') + '-' + newAsset.AEMO_Id__c;
			}
		}

		if (!updSObjs.isEmpty()) update updSObjs.values();
	}
}