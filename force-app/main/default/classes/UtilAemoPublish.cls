/*
@author  : Rohit.Middha@ausnetservices.com.au
@created : 26 Sep 2019
@Description : Create Payload request to publish data to AEMO.
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
05-DEC-2019           PALASH AWASTHI                  Changes for refactoring Payload to 
                                                      include Representative Company node
-----------------------------------------------------------------------------------------
*/
public with sharing class UtilAemoPublish {

	public class AEMO_Publish_Payload { public List<DER_Payload> ders = new List<DER_Payload>();}

	public static Boolean runningPublish = false;

	@future (callout = true)
	public static void publishToAemo(Set<Id> validCaseIds)
	{
		runningPublish = true;

		UtilDebug de = new UtilDebug();
		de.bug('UtilAemoPublish - publishToAemo()\n', true);

		Integer resStatuCode;
		AEMO_Publish_Payload payloadList = new AEMO_Publish_Payload();
		Map<Id,Id> caseDerMap = new Map<Id,Id>();
		Map<Id,List<Device__c>> derDevicesMap = new Map<Id,List<Device__c>>();
		Map<Id,Case> caseIdMap = new Map<Id,Case>();
		Set<Id> connectionIdList = new Set<Id>();
	  //  List<Id> meterIdList = new List<Id>();
	  //  List<Id> siteIdList = new List<Id>();
		Set<Id> customerIdList = new Set<Id>();
		Set<Id> installerIdList = new Set<Id>();
		Set<Id> contactIdList = new Set<Id>();
		String ENDPOINTURL = '';
		Map<Id,List<Device__c>> childDevicesMap = new Map<Id,List<Device__c>>();
		Map<Id,SObject> connectionIdMap = new Map<Id,SObject>();
	  //  Map<Id,SObject> meterIdMap = new Map<Id,SObject>();
		Map<Id,SObject> customerIdMap = new Map<Id,SObject>();
		Map<Id,SObject> installerIdMap = new Map<Id,SObject>();
		Map<Id,SObject> contactIdMap = new Map<Id,SObject>();
	  //  Map<Id,SObject> siteIdMap = new Map<Id,SObject>();
		Map<Id,DER_Application__c> iDDerMap = new Map<Id,DER_Application__c>();
		String reqBody = '';
		String queryCase = '';

		queryCase += UtilDatabase.getAllFields('Case');
		queryCase += ' FROM Case ';
		queryCase += 'WHERE Id in :validCaseIds';

		DER_Submission_Settings__c der_submission_setting = DER_Submission_Settings__c.getInstance();
		if (der_submission_setting.Endpoint__c != null && der_submission_setting.Domain__c !=null)
		{
			ENDPOINTURL = der_submission_setting.Domain__c+''+der_submission_setting.Endpoint__c;
		}

		for (Case c : Database.query(queryCase))
		{
			caseDerMap.put(c.DER_Application__c,c.Id);
			caseIdMap.put(c.Id, c);
			customerIdList.add(c.Customer__c);
			installerIdList.add(c.AccountId);
			contactIdList.add(c.ContactId);
		}
		if (!customerIdList.isEmpty())
		{
			customerIdMap =   UtilDatabase.getMapOfRecords(customerIdList);
		}
		if (!installerIdList.isEmpty())
		{
			installerIdMap =  UtilDatabase.getMapOfRecords(installerIdList);
		}
		if (!contactIdList.isEmpty())
		{
			contactIdMap =  UtilDatabase.getMapOfRecords(contactIdList);
		}
		if (caseDerMap != null)
		{
			Set<Id> idList = caseDerMap.keyset();

			String queryApp = '';
			queryApp += UtilDatabase.getAllFields('DER_Application__c');
			queryApp += ' FROM DER_Application__c ';
			queryApp += 'WHERE Id in :idList';


			List<DER_Application__c> der_apps = Database.query(queryApp);

			for (DER_Application__c der : der_apps )
			{
				iDDerMap.put(der.Id,der);
				connectionIdList.add(der.NMI__c);
			}
			 List<Id> derIdVals = new List<Id>();
			for (Id derId : iDDerMap.keyset())
			{
				derIdVals.add(derId);
			}

			String queryDevice = '';
			queryDevice += UtilDatabase.getAllFields('Device__c');
			queryDevice += ', Parent_Device__r.DER_Application__c';
			queryDevice += ' FROM Device__c';
			queryDevice += ' WHERE (DER_Application__c IN :derIdVals';
			queryDevice += ' OR Parent_Device__r.DER_Application__c IN :derIdVals)';
			queryDevice += ' AND (Installed__c = true OR Existing_Device__c = true OR Decommission__c = true)';
			queryDevice += ' ORDER BY Device_Hierarchy__c ASC';

			for (Device__c device: (List<Device__c>)Database.query(queryDevice))
			{
				Id DeviceDERAppId;
				device.EAI_Type__c   = UtilDatabase.getRecordTypes().get(device.RecordTypeId);
				device.EAI_Ref__c    = device.Id;
				device.EAI_Parent__c = null;

				if (device.EAI_Type__c == 'Device_L2')
				{
					DeviceDERAppId = device.DER_Application__c;
				}
				else if (device.EAI_Type__c == 'Device_L3')
				{
					DeviceDERAppId = device.Parent_Device__r.DER_Application__c;
					device.EAI_Parent__c = device.Parent_Device__c;
				}
				else
				{
					System.debug('Error: Bad Device Type: ' + device.EAI_Type__c);
					continue;
				}

				if (!childDevicesMap.containsKey(DeviceDERAppId))
					childDevicesMap.put(DeviceDERAppId, new List<Device__c>());

				childDevicesMap.get(DeviceDERAppId).add(device);
			}

			if (!customerIdList.isEmpty())
			{
				connectionIdMap = UtilDatabase.getMapOfRecords(connectionIdList);
			}
		}

		String queryDERAgmt = '';
		queryDERAgmt += UtilDatabase.getAllFields('DER_Agreement__c');
		queryDERAgmt += ' FROM DER_Agreement__c ';
		queryDERAgmt += 'WHERE DER_Application__c IN: derIdVals ';
		List<DER_Agreement__c> lstDERAgmt = Database.query(queryDERAgmt);
		Map<Id, DER_Agreement__c> mapDERApp_DERAgmt = new Map<Id, DER_Agreement__c>();
		for (DER_Agreement__c item: lstDERAgmt)
		{
			mapDERApp_DERAgmt.put(item.DER_Application__c, item);
		}

		for (DER_Application__c der : iDDerMap.values())
		{
			DER_Payload payload = new DER_Payload();
			payload.derApp = der;
			payload.derCase = (Case) UtilDatabase.getRecord(caseDerMap.get(der.Id));
			payload.devices =  new List<Device__c>();

			if (childDevicesMap.get(der.Id) != null)
			{
			   payload.devices = childDevicesMap.get(der.Id);
			}

			if (payload.derApp.NMI__c != null){
				payload.nmi = (Connection_Point__c) connectionIdMap.get(payload.derApp.NMI__c);
			}

			if (payload.derCase.Customer__c  != null){
				payload.customer= (Account) customerIdMap.get(payload.derCase.Customer__c );
			}

			if (payload.derCase.AccountId != null){
				payload.installer= (Account) installerIdMap.get(payload.derCase.AccountId);
			}

			if (payload.derCase.ContactId != null){
				payload.installerContact= (Contact) contactIdMap.get(payload.derCase.ContactId);
			}

			if (payload.derCase.Representative__c != null){
				payload.representative= (Contact) UtilDatabase.getRecord(payload.derCase.Representative__c);

				if (payload.representative != null && payload.representative.AccountId != null)
					{
						payload.representativeCompany = (Account)UtilDatabase.getRecord(payload.representative.AccountId);
						UtilDatabase.explicitNulls(payload.representativeCompany); // explicit nulls help the JSON payload.
					}
			}

			if (mapDERApp_DERAgmt.containsKey(payload.derApp.Id)){
				payload.derAgreement = mapDERApp_DERAgmt.get(payload.derApp.Id);
			}

			if (payload != null)
			{
				payloadList.ders.add(payload);
			}

		}
		if (payloadList != null)
		{
			reqBody = JSON.serialize(payloadList);
			resStatuCode = 200;
		}
		system.Debug('reqBody:- '+reqBody);
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(ENDPOINTURL);
		req.setHeader('Accept', 'application/json');
		req.setHeader('Content-type', 'application/json');
		req.setMethod('POST');
		req.setBody(reqBody);
		HttpResponse res = new HttpResponse();
		res.setStatusCode(-1);
		res.setStatus('none');

		de.bug('Request payload');
		de.bug('---------------');
		de.bug('content type: ' + req.getHeader('Content-type'));
		de.bug(reqBody + '\n');

		if ( !Test.isRunningTest() && ENDPOINTURL != '')
		{
			String certName = 'eains';
			if (der_submission_setting.Certificate_Name__c != null)
				certName = der_submission_setting.Certificate_Name__c;

			req.setClientCertificateName(certName);
			try
			{
				res = http.send(req);
			}
			catch(Exception e)
			{
				res = new HttpResponse();
				res.setStatusCode(0);
				res.setStatus('Exception in request ' + e);
			}
		}

		de.bug('Response');
		de.bug('--------');
		de.bug('statusCode: ' + res.getStatusCode());
		de.bug('body:\n' + res.getBody());
		de.bugSend();

		String subStatus;
		if (res != null && res.getBody() != null && res.getStatusCode() == 200)
			subStatus = 'Sent to EAI';
		else
			subStatus = 'Submission Failed';

		String subResp = submissionResponse(req, res);

		List<Case> caseListToUpdate = new List<Case>();
		for (Id caseId: caseDerMap.values())
		{
			Case c = caseIdMap.get(caseId);
			c.Submission_Status__c = subStatus;
			c.Submission_Response__c = subResp;
			caseListToUpdate.add(c);
		}

		if (!caseListToUpdate.isEmpty()) update caseListToUpdate;
	}

	private static String submissionResponse(HttpRequest req, HttpResponse res)
	{
		String output = '';

		if (req != null)
			output += req.toString() + '\n';
		else
			output += 'System.HttpRequest[null]\n';

		if (res != null)
			output += res.toString() + '\n';
		else
			output += 'System.HttpResponse[null]\n';

		return output;
	}

}