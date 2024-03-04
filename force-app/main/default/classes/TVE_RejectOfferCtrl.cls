/*
 @author  : pavan.dave@ausnetservices.com.au
 @created : 28 Feb  2020
 @Description : Controller class for Reject Offer LWC
 -----------------------------------------------------------------------------------------
 Change log
 -----------------------------------------------------------------------------------------
 Date                  Name                           Description
 -----------------------------------------------------------------------------------------
5th May 2020		dave.pavan@in.ibm.com			TV-2864 - Undo apex changes since it's going be covered 
													from flow TVE11_Acceptance_Prelim_estimate
 -----------------------------------------------------------------------------------------
 */
public with sharing class TVE_RejectOfferCtrl
{
	@AuraEnabled(cacheable = true)
	public static List<PicklistWrpr> getRejReasons()
	{
		List<PicklistWrpr>               objWrapper  = new List<PicklistWrpr>();
		Schema.DescribeSObjectResult     objDescribe = TASK.getSObjectType().getDescribe();
		Map<String, Schema.SObjectField> fieldMap    = objDescribe.fields.getMap();
		List<Schema.PicklistEntry>       values      = fieldMap.get('RejectionReasons__c').getDescribe().getPickListValues();
		PicklistWrpr wrpr;

		for (Schema.PicklistEntry a: values)
		{
			wrpr = new PicklistWrpr();
			wrpr.pklst_label = a.getLabel();
			wrpr.pklst_value = a.getValue();
			objWrapper.add(wrpr);
		}
		return objWrapper;
	}

	@AuraEnabled
	public static void saveRejectedReason(String recordId, String selectedReason, String otherReason)
	{
		system.debug('recordId-->' + recordId);
		Task taskItem = [SELECT Id, WhatId, OfferStatus__c, Status, RejectionReasons__c, OtherRejectionReason__c
						 FROM Task
						 WHERE Id = :recordId];

		taskItem.OfferStatus__c = 'Rejected';
		taskItem.Status = 'Completed';
		System.debug('RejectionReasons__c--->' + selectedReason);
		taskItem.RejectionReasons__c = selectedReason;
		
		if (selectedReason == 'Other')
		{
			System.debug('OtherRejectionReason__c--->' + otherReason);

			if (otherReason != null && otherReason != '')
			{
				taskItem.OtherRejectionReason__c = otherReason;
			}
			else
				throw new TVE_RejectOfferCtrl_Exception('Error: Other reason not specified');
		}
		else
		{
			taskItem.OtherRejectionReason__c = null;
		}
		
		update taskItem;
	}

	public with sharing class PicklistWrpr
	{
		@auraEnabled public string pklst_label {get; set;}
		@auraEnabled public string pklst_value {get; set;}
	}

	public class TVE_RejectOfferCtrl_Exception extends Exception { }
}