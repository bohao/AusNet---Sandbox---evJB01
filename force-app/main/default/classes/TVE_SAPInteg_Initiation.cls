/*
@author  : pavan.dave@ausnetservices.com.au
@created : 10 Feb 2020
@Description : Class for executing SAP Integration - Initiation part
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
12 feb 2020           Lakshay Sharma                 Added next queueable task
-----------------------------------------------------------------------------------------
*/
public with sharing class TVE_SAPInteg_Initiation
{
	public static void startInitiation()
	{
		Boolean hasPermission = FeatureManagement.checkPermission('Execute_SAP_Integration');

		if (hasPermission)
		{
			WOS_Initiation WOS = new WOS_Initiation();
			WOS.startInitiation();
		}
		else
		{
			throw new TVE_ConfigurationException('The current user doesn’t have permission to execute SAP integration.');
		}
	}

	private without sharing class WOS_Initiation
	{
		private void startInitiation()
		{
			Map<String, String>              initAPIMap     = new Map<String, String>();
			List<Integration_Task__c>        newIntTaskList = new List<Integration_Task__c>();
			Map<Integration_Task__c, String> artIDlist      = new Map<Integration_Task__c, String>();
			Map<Id, Artefact__c>             artefactMap    = new Map<Id, Artefact__c>();
			List<Id>                         ArtefactIdList = new List<Id>();

			// Here we go......
			List<Integration_Task__c> lstIntgTask = new List<Integration_Task__c>([SELECT Id, Status__c,Type__c,ParentId__c
																				   FROM Integration_Task__c
																				   WHERE Status__c ='Ready']);

			for (Integration_Task__c item: lstIntgTask)
			{
				//item.Status__c = 'In Progress';

				if (item.Type__c=='GetCustomer')
					initAPIMap.put('CreateCustomer','CallAPI');
				if (item.Type__c=='CreateCustomer')
					initAPIMap.put('CreateCustomer','CallAPI');
				if (item.Type__c=='GetInvoice')
					initAPIMap.put('GetInvoice','CallAPI');
				if (item.Type__c=='UpdateCM')
					initAPIMap.put('UpdateCM','CallAPI');
				if (item.Type__c=='CreateMasterNoti')
					initAPIMap.put('CreateCustomer','CallAPI');
				if (item.Type__c=='CreateWork')
					initAPIMap.put('CreateCustomer','CallAPI');
			   	if (item.Type__c=='GetCMArtefact')
					initAPIMap.put('GetCMArtefact','CallAPI');
				if (item.Type__c=='GetCM')
					initAPIMap.put('GetCM','CallAPI');
				if (item.Type__c=='GetConstWO')
					initAPIMap.put('GetConstWO','CallAPI');
				if (item.Type__c=='GetConstNoti')
					initAPIMap.put('GetConstNoti','CallAPI');
				if (item.Type__c=='RequestInvoice')
					initAPIMap.put('RequestInvoice','CallAPI');
				if (item.Type__c!='CreateArtefact')
					newIntTaskList.add(item);
				if (item.Type__c=='CreateArtefact')
				{
					artIDlist.put(item,item.ParentId__c);
					ArtefactIdList.add(item.ParentId__c);
				}
			}

			if (artIDlist.size() > 0)
			{
				artefactMap=TVE_IntegUtility.getArtefact(ArtefactIdList);

				if (artefactMap.size() > 0)
				{
					List<Integration_Task__c> createArtefactList = new List<Integration_Task__c>();

					for (Integration_Task__c intTask:artIDlist.keySet()){
						if (artefactMap.containskey(artIDlist.get(intTask)))
							createArtefactList.add(intTask);
					}

					if (!createArtefactList.isEmpty()) {
						initAPIMap.put('CreateArtefact','CallAPI');
						newIntTaskList.addAll(createArtefactList);
					}
				}
			}

			if (!newIntTaskList.isEmpty())
			{
				for (Integration_Task__c item: newIntTaskList)
				{
					item.Status__c = 'In Progress';
				}
				update newIntTaskList;
			}

			if (initAPIMap.size()>0)
			{
				for (String key: initAPIMap.keySet())
				{
					if (key=='CreateCustomer')
					{
						TVE_SAPInteg_CreateCustomer createcustom = new TVE_SAPInteg_CreateCustomer();
						if (!Test.isRunningTest())
							Id jobID = System.enqueueJob(createcustom);
					}
					if (key=='GetInvoice')
					{
						TVE_SAP_Int_GetInvoice getInvoice = new TVE_SAP_Int_GetInvoice();
						if (!Test.isRunningTest())
							Id jobID = System.enqueueJob(getInvoice);
					}
					if (key=='UpdateCM')
					{
						TVE_SAPInteg_UpdateCMQue updateCM = new TVE_SAPInteg_UpdateCMQue();
						if (!Test.isRunningTest())
							Id jobID = System.enqueueJob(updateCM);
					}

					if (key=='GetCMArtefact')
					{
						TVE_SAP_Int_GetCMArtefact getCMArt = new TVE_SAP_Int_GetCMArtefact();
						if (!Test.isRunningTest())
							Id jobID = System.enqueueJob(getCMArt);
					}
					if (key=='GetCM')
					{
						TVE_SAPInteg_GetCMToSAP getCM = new TVE_SAPInteg_GetCMToSAP();
						if (!Test.isRunningTest())
							Id jobID = System.enqueueJob(getCM);
					}
					if (key=='GetConstWO')
					{
						TVE_SAPInteg_GetWorkOrderToSAP GetWO= new TVE_SAPInteg_GetWorkOrderToSAP();
						if (!Test.isRunningTest())
							Id jobID = System.enqueueJob(GetWO);
					}
					if (key=='GetConstNoti')
					{
						TVE_SAPInteg_GetNotificationToSAP GetPMNoti = new TVE_SAPInteg_GetNotificationToSAP();
						if (!Test.isRunningTest())
							Id jobID = System.enqueueJob(GetPMNoti);
					}
					if (key=='RequestInvoice')
					{
						TVE_SAPInteg_RequestInvoice reqInvoice = new TVE_SAPInteg_RequestInvoice();
						if (!Test.isRunningTest())
							Id jobID = System.enqueueJob(reqInvoice);
					}
					 if (key=='CreateArtefact')
					{
						TVE_SAPInt_CreateArtefact createArt = new TVE_SAPInt_CreateArtefact();
						if (!Test.isRunningTest())
							Id jobID = System.enqueueJob(createArt);
					}
				}
			}
		}
	}
}