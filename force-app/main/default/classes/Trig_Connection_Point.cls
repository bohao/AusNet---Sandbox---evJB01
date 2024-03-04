/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 16 Oct 2019
  @Description : Class for Connection_Point__c Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
public with sharing class Trig_Connection_Point implements UtilTrigHandle{
	// *********************************************************************
	// *** Disable logic

	public static Boolean TrigDisabled = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().Connection_Point_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}

	// *********************************************************************
	// *** Trigger contexts

	public void AfterInsert(Map<Id, SObject> newSObjs)
	{
		if(!DER_Connection_Point_Util.isRunning_PopulateExternalNMIRef)
		{
			Validate_ExtNMIRefPop(newSObjs, null);
		}
	}

	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		if(!DER_Connection_Point_Util.isRunning_PopulateExternalNMIRef)
		{
			Validate_ExtNMIRefPop(newSObjs, oldSObjs);
		}
	}

	// if context is not implemented, condense into one-liners
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> newSObjs) {}
	public void BeforeInsert(List<SObject> newSObjs) {}
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs){}

	// *********************************************************************
	// *** Trigger methods

	// Populate External NMI_Ref__c Lookup and relavent details
	private void Validate_ExtNMIRefPop(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		System.debug('*** Trig_Connection_Point.Validate_ExtNMIRefPop()');
		Set<Id> validExtNMIRef_Pop = new Set<Id>();
		Set<Id> validExtNMIRef_Clear = new Set<Id>();


		switch on Trigger.operationType
		{
			when AFTER_INSERT
			{
				for (SObject sObjItem: newSObjs.values())
				{
					Connection_Point__c newConPoint = (Connection_Point__c)sObjItem;

					if (newConPoint.NMI__c != null)
					{
						validExtNMIRef_Pop.add(newConPoint.Id);
					}
				}
			}

			when AFTER_UPDATE
			{
				for (SObject sObjItem: newSObjs.values())
				{
					Connection_Point__c newConPoint = (Connection_Point__c)sObjItem;
					Connection_Point__c oldConPoint = (Connection_Point__c)oldSObjs.get(newConPoint.Id);

					if (isPopulated('NMI__c', newConPoint, oldConPoint))
					{
						validExtNMIRef_Pop.add(newConPoint.Id);
					}
					else if (isCleared('NMI__c', newConPoint, oldConPoint))
					{
						validExtNMIRef_Clear.add(newConPoint.Id);
					}

					if (newConPoint.NMI__c == oldConPoint.NMI__c && 
						newConPoint.NMI_Ref__c == null
					)
					{
						validExtNMIRef_Pop.add(newConPoint.Id);
					}
				}
			}
		}

		DER_Connection_Point_Util.PopulateExternalNMIRef(validExtNMIRef_Pop, validExtNMIRef_Clear);
	}

	// --------------------------------------------------------------//
	//------- Connection_Point__c Trigger utility methods -----------//
	// --------------------------------------------------------------//

	private static Boolean isCleared(String f, Connection_Point__c newConPoint, Connection_Point__c oldDERApp)
	{
		Boolean isFieldCleared = false;
		if(newConPoint.get(f) == null)
			isFieldCleared = newConPoint.get(f) != oldDERApp.get(f);
		else if(newConPoint.get(f) instanceof Date)
			isFieldCleared = newConPoint.get(f) == null && ((Date)newConPoint.get(f)) != ((Date)oldDERApp.get(f));
		else
			isFieldCleared = String.isBlank((String)newConPoint.get(f)) && ((String)newConPoint.get(f)) != ((String)oldDERApp.get(f));
		return isFieldCleared;
	}

	private static Boolean isPopulated(String f, Connection_Point__c newConPoint, Connection_Point__c oldDERApp)
	{
		Boolean isFieldPopulated = false;
		if(newConPoint.get(f) == null)
			isFieldPopulated = false;
		else if(newConPoint.get(f) instanceof Date)
			isFieldPopulated = newConPoint.get(f) != null && ((Date)newConPoint.get(f)) != ((Date)oldDERApp.get(f));
		else
			isFieldPopulated = String.isNotBlank((String)newConPoint.get(f)) && ((String)newConPoint.get(f)) != ((String)oldDERApp.get(f));
		return isFieldPopulated;
	}
}