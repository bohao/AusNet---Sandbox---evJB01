/*
@author  : rohit.middha@ausnetservices.com.au
@created : 20 Sep 2019
@Description : REST based webservice for AEMO Exception Management
-----------------------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------------------
20-01-2020            Palash Awasthi                 Added code for Storing AEMO ID into Salesforce

-----------------------------------------------------------------------------------------------------
*/
@RestResource(urlMapping='/v1.0/der/results/*')
global with sharing class AEMO_Results_v1 {
	public static String DERIssue_RECORDTYPE_Exception = 'Exception';
	public static String DERIssue_RECORDTYPE_Error = 'Error';

	@HttpPost
	global static void doPost()
	{
		UtilDebug de = new UtilDebug();
		de.bug('AEMO_Results_v1 - doPost()\n', true);

		String resBody = '';
		String resBodyUpdated = '';
		Integer resStatuCode = 403;
		String reqContentType = RestContext.request.headers.get('Content-Type');

		de.bug('Request payload');
		de.bug('---------------');
		de.bug('content type: ' + reqContentType);

		if (String.isNotBlank(reqContentType) && reqContentType.toLowerCase().contains('application/json'))
		{
			String reqBody = RestContext.request.requestBody.toString();
			de.bug(reqBody, true);

			if (String.isNotBlank(reqBody))
			{
				AemoResultsPayload payload = (AemoResultsPayload)JSON.deserialize(reqBody, AemoResultsPayload.class);

				Set<String> appNumberSet = new Set<String>();
				List<Id> deviceIds = new List<Id>();
				Map<String,Case> appNumberCaseMap = new Map<String,Case>();

				if (payload.results.size() > 0 && payload.results != null)
				{
					for (AemoResultsPayload.cls_results res: payload.results)
					{
						appNumberSet.add(res.name);
					}
				}

				if (appNumberSet != null)
				{
					for (String appNumber : appNumberSet)
					{
						for (Case c : [Select Id,Application_Number__c from Case where Application_Number__c = :appNumber ])
						{
							appNumberCaseMap.put(c.Application_Number__c, c);
						}
					}
				}
				for (AemoResultsPayload.cls_results res: payload.results)
				{
					//Code for Storing AEMO Id on L2 and L3 devices in Salesforce

					if (res.acConnections != NULL && res.acConnections.size() > 0){

						List<Device__c> deviceList = new List<Device__c>();
						for (AemoResultsPayload.cls_acConnections devL2 : res.acConnections){

							if (devL2.nspConnectionId != NULL){
								Device__c L2device = new Device__c();
								L2Device.Id = (Id)devL2.nspConnectionId;
								L2Device.AEMO_Id__c = devL2.connectionId;
								L2Device.AEMO_Status__c = devL2.status;
								deviceList.add(L2Device);
							}

							if (devL2.devices != NULL && devL2.devices.size() > 0){

								for (AemoResultsPayload.cls_devices devL3 : devL2.devices){

									if (devL3.nspDeviceId != NULL){
										Device__c L3device = new Device__c();
										L3device.Id = (Id)devL3.nspDeviceId;
										L3device.AEMO_Id__c = devL3.deviceId;
										L3device.AEMO_Status__c = devL3.status;
										deviceList.add(L3device);
									}
								}
							}
						}
						if (deviceList.size()>0){
							update deviceList;
						}
					}

					DER_Issue__c  derIssue;
					Case caseRecord = appNumberCaseMap.get(res.Name);
					if (res.exceptions != null && res.exceptions.size() > 0   )
					{

						List<DER_Issue__c> listExceptions = new List<Der_Issue__C>();

						for ( AemoResultsPayload.cls_exceptions ex : res.exceptions)
						{
							derIssue = new DER_Issue__c();
							derIssue.Case__c = caseRecord.Id ;
							derIssue.Title__c = ex.name;
							derIssue.AEMO_Exception_ID__c = ex.exceptionId;
							derIssue.Code__c =  ex.Code;
							derIssue.Details__c = ex.details;
							derIssue.AEMO_Status__c = ex.status;
							derIssue.Source__c = string.join((ex.affectedAttributes),',');
							derIssue.RecordTypeId = Schema.SObjectType.DER_Issue__c.getRecordTypeInfosByDeveloperName().get(DERIssue_RECORDTYPE_Exception).getRecordTypeId();
							derIssue.AEMO_Connection_ID__c = ex.connectionId;
							derIssue.AEMO_Device_ID__c = ex.deviceId;
							listExceptions.add(derIssue);

						}
						if (listExceptions != null)
						{
							insert listExceptions;
							caseRecord.Submission_Status__c = 'Submitted with Exceptions';
							update caseRecord;

						}
					}
					else if (res.errors != null && res.errors.size() > 0   )
					{
						List<DER_Issue__c> listErrors = new List<Der_Issue__C>();

						for ( AemoResultsPayload.cls_errors ex: res.errors)
						{
							derIssue = new DER_Issue__c();
							derIssue.Case__c = caseRecord.Id ;
							derIssue.Code__c =  ex.Code;
							derIssue.Source__c = ex.source;
							derIssue.Details__c = ex.detail;
							derIssue.Title__c = ex.title;
							derIssue.RecordTypeId = Schema.SObjectType.DER_Issue__c.getRecordTypeInfosByDeveloperName().get(DERIssue_RECORDTYPE_Error).getRecordTypeId();

							listErrors.add(derIssue);
						}
						if (listErrors != null)
						{
							insert listErrors;
							caseRecord.Submission_Status__c = 'Submission Failed';
							update caseRecord;


						}

					}
					else
					{
						caseRecord.Submission_Status__c = 'Submitted Successfully';
						update caseRecord;
					}
				}
				resBody = resbody + 'Request succesfully processed';
				resStatuCode = 200;

			}


			else
			{
				resBody = 'Request Body Not Found';
				resStatuCode = 400;
			}
		}
		else
		{
			resBody = 'Invalid Content-Type';
			resStatuCode = 400;
		}

		RestContext.response.addHeader('Content-Type', 'text/plain');
		RestContext.response.statusCode = resStatuCode;
		RestContext.response.responseBody = Blob.valueOf(resBody);

		de.bug('Response');
		de.bug('--------');
		de.bug('statusCode: ' + resStatuCode);
		de.bug('body:\n' + resBody);
		de.bugSend();
	}
}