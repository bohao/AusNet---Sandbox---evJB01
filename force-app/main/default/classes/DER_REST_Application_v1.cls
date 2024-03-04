/*
@author  : pavan.dave@ausnetservices.com.au
@created : 30 Aug 2019
@Description : REST based webservice for accessing/updating the DER Applicaiton and related records
---------------------------------------------------------------------------------------------------------
Change log
---------------------------------------------------------------------------------------------------------
Date                  Name                           Description
---------------------------------------------------------------------------------------------------------
10/09/2019             Rohit Middha                   Updated doGet Method as per CMC 511
18/09/2019             Pavan Dave                     CMC-1089
17-OCT-19              Pavan Dave                     CMC-1379
19-OCT-19			   Pavan Dave					  CMC-1705 (Refactoring for L3 devices)
05-DEC-19              Palash Awasthi                 CMC-1876 (Refactoring for Representative Company)
06-JUL-20			   Sridhar Sathiamurthy           Included email as criteria for Installer Contact
---------------------------------------------------------------------------------------------------------
*/
@RestResource(urlMapping='/v1.0/der/application/*')
global with sharing class DER_REST_Application_v1
{
	public virtual class DERApplicationAPIException extends Exception{}
	public static String ACCOUNT_RECORDTYPE_BUSINESS        = 'Customer_Business';
	public static String ACCOUNT_RECORDTYPE_INDIVIDUAL      = 'Customer_Individual';
	public static String ACCOUNT_RECORDTYPE_SERVICEPROVIDER = 'Service_Provider';
	public static String CASE_RECORDTYPE_AUTO               = 'DER_App_Auto';
	public static String CASE_RECORDTYPE_MANUAL             = 'DER_App_Manual';
	public static String CASE_SCENARIO_AUTO                 = 'Auto';
	public static String CASE_SCENARIO_MANUAL               = 'Manual';
	public static String CASE_STATUS_INST_PENDING           = 'Installation Pending';
	public static String CASE_STATUS_NEW                    = 'New';
	public static String CASE_STATUS_INST_VALIDATION        = 'Installation Validation';
	public static String CASE_DEFAULT_QUEUE_AUTO            = 'DER Apps - Hold/Wait';
	public static String CASE_DEFAULT_QUEUE_MANUAL          = 'DER Apps - New Conns';
	public static Set<String> ACCOUNT_SERVICEPROVIDER_TYPES = new Set<String>{'Installer', 'Representative'};
	public static Set<String> CONTACT_REP_TITLES            = new Set<String>{'Application Representative', 'Customer Representative'};

	@HttpGet
	global static void doGet()
	{
		String resBody = '';
		String errBody = '';
		JSONGenerator gen = JSON.createGenerator(false);
		List<DER_Agreement__c> lstDERAgmt;

		UtilDebug de = new UtilDebug();
		de.bug('DER_REST_Application_v1 - doGet()', true);
		de.bug('Get Application\n');

		String appNumber, nmiNumber, email;

		appNumber = RestContext.request.params.get('appNumber');
		nmiNumber = RestContext.request.params.get('nmiNumber');
		email = RestContext.request.params.get('email');

		Boolean isParamMissing = false;

		de.bug('Request parameters');
		de.bug('appNumber: ' + appNumber, true);
		de.bug('nmiNumber: ' + nmiNumber, true);
		de.bug('email:     ' + email + '\n', true);

		// isBlank validates null, blank and white space values
		if (String.isBlank(appNumber)){
			errBody = 'appNumber, ';
			isParamMissing = true;
		}
		if (String.isBlank(nmiNumber)){
			errBody = errBody + 'nmiNumber, ';
			isParamMissing = true;
		}
		if (String.isBlank(email)){
			errBody = errBody + 'email, ';
			isParamMissing = true;
		}

		if (isParamMissing){
			errBody = 'Required Parameter(s) missing - ' + errBody.substringBeforeLast(',');
		}else{
			DER_Payload payload = new DER_Payload();
			List<Id> deviceIds = new List<Id>();

			String queryCase = '';
			queryCase += UtilDatabase.getAllFields('Case');
			queryCase += ' FROM Case';
			queryCase += ' WHERE Application_Number__c =\''+ appNumber + '\'';
			queryCase += ' AND (ContactEmail = \''+ email + '\' OR Auto_Applicant_Email__c = \''+ email + '\' OR Applicant_Email__c = \''+ email + '\')';
			queryCase += ' LIMIT 1';

			List<Case> lstCase = Database.query(queryCase);
			if (!lstCase.isEmpty())
			{
				payload.derCase = lstCase[0];

				// explicit nulls help the JSON payload.
				UtilDatabase.explicitNulls(payload.derCase);

				String queryApp = '';
				queryApp += UtilDatabase.getAllFields('DER_Application__c');
				queryApp += ' FROM DER_Application__c';
				queryApp += ' WHERE Id =\''+ payload.derCase.DER_Application__c + '\'';
				queryApp += ' AND NMI__r.NMI__c =\''+ nmiNumber + '\'';

				for (SObject o: Database.query(queryApp))
				{
					DER_Application__c der = (DER_Application__c)o;
					payload.derApp = (DER_Application__c)UtilDatabase.explicitNulls(der);
					break;
				}

				String queryDERAgmt = '';
				queryDERAgmt += UtilDatabase.getAllFields('DER_Agreement__c');
				queryDERAgmt += ' FROM DER_Agreement__c';
				queryDERAgmt += ' WHERE DER_Application__c =\''+ payload.derCase.DER_Application__c + '\'';
				lstDERAgmt = Database.query(queryDERAgmt);

				String queryDevice = '';
				queryDevice += UtilDatabase.getAllFields('Device__c');
				queryDevice += ' FROM Device__c';
				queryDevice += ' WHERE DER_Application__c =\''+ payload.derCase.DER_Application__c + '\'';
				queryDevice += ' OR Parent_Device__r.DER_Application__c =\''+ payload.derCase.DER_Application__c + '\'';
				queryDevice += ' ORDER BY Device_Hierarchy__c ASC';

				List<SObject> objList = Database.query(queryDevice);
				Map <Id, String> mapRTIdName = UtilDatabase.getRecordTypes();

				if (!objList.isEmpty())
				{
					payload.devices =  new List<Device__c>();
					for (SObject o: objList)
					{
						// Set EAI Fields
						Device__c device = (Device__c)o;
						device.EAI_Type__c = mapRTIdName.get(device.RecordTypeId);
						device.EAI_Ref__c = device.Id;
						device.EAI_Parent__c = null;
						if (device.Parent_Device__c != null)
							device.EAI_Parent__c = device.Parent_Device__c;

						// explicit nulls help the JSON payload.
						UtilDatabase.explicitNulls(device);

						payload.devices.add(device);
					}
				}
			}

			if (payload.derApp == null || payload.derCase == null)
			{
				errBody = 'No Record(s) Found';
			}
			else
			{
				if (payload.derApp.NMI__c != null){
					payload.nmi = (Connection_Point__c) UtilDatabase.getRecord(payload.derApp.NMI__c);
					UtilDatabase.explicitNulls(payload.nmi); // explicit nulls help the JSON payload.
				}

				if (payload.derCase.Customer__c  != null){
					payload.customer= (Account) UtilDatabase.getRecord(payload.derCase.Customer__c );
					UtilDatabase.explicitNulls(payload.customer); // explicit nulls help the JSON payload.
				}

				if (payload.derCase.AccountId != null){
					payload.installer= (Account) UtilDatabase.getRecord(payload.derCase.AccountId);
					UtilDatabase.explicitNulls(payload.installer); // explicit nulls help the JSON payload.
				}

				if (payload.derCase.ContactId != null){
					payload.installerContact= (Contact) UtilDatabase.getRecord(payload.derCase.ContactId);
					UtilDatabase.explicitNulls(payload.installerContact); // explicit nulls help the JSON payload.
				}

				if (payload.derCase.Representative__c != null)
				{
					payload.representative = (Contact) UtilDatabase.getRecord(payload.derCase.Representative__c);
					UtilDatabase.explicitNulls(payload.representative); // explicit nulls help the JSON payload.

					if (payload.representative != null && payload.representative.AccountId != null)
					{
						payload.representativeCompany = (Account)UtilDatabase.getRecord(payload.representative.AccountId);
						UtilDatabase.explicitNulls(payload.representativeCompany); // explicit nulls help the JSON payload.
					}
				}

				if (!lstDERAgmt.isEmpty()){
					payload.derAgreement = lstDERAgmt[0];
					UtilDatabase.explicitNulls(payload.derAgreement); // explicit nulls help the JSON payload.
				}

				resBody = JSON.serializePretty(payload, false);
			}
		}

		if (String.isNotBlank(errBody))
		{
			gen.writeStartObject();
			gen.writeStringField('error', errBody);
			gen.writeEndObject();
			resBody = gen.getAsString();
		}

		de.bug('Response');
		de.bug(resBody);
		de.bugSend();

		RestContext.response.addHeader('Content-Type', 'application/json;');
		RestContext.response.responseBody = Blob.valueOf(resBody);
	}

	@HttpPatch
	global static void doPatch()
	{
		String resBody = '';
		Integer resStatuCode = 403;
		UtilDebug de = new UtilDebug();
		de.bug('DER_REST_Application_v1 - doPatch()', true);
		de.bug('Update Application\n');

		String reqContentType = RestContext.request.headers.get('Content-Type');
		DER_Payload_Response payloadResp = new DER_Payload_Response();

		de.bug('Request payload');
		de.bug('---------------');
		de.bug('content type: ' + reqContentType);

		if (String.isNotBlank(reqContentType) && reqContentType.toLowerCase().contains('application/json'))
		{
			String reqBody = RestContext.request.requestBody.toString();
			de.bug(reqBody, true);

			if (String.isNotBlank(reqBody))
			{
				// A savepoint while no DML has been executed for doPost
				Savepoint sp = Database.setSavepoint();
				try
				{
					DER_Payload payload = (DER_Payload)JSON.deserialize(reqBody, DER_Payload.class);
					System.debug('payload----------------->'+payload);

					//------------------------------------------------------------------------------------//
					//------- Create/match logic for differnt objects based on the references ------------//
					//------------------------------------------------------------------------------------//
					Case queryDERCase;

					if (payload.derCase != null && payload.derCase.Id != null
					&& payload.derApp != null && payload.derApp.Id != null
					&& payload.nmi != null && payload.nmi.Id != null)
					{
						queryDERCase = (Case)UtilDatabase.getRecord(payload.derCase.Id);
						// Set App Scenario
						payload.derCase.DER_Application_Scenario__c = queryDERCase.DER_Application_Scenario__c;

						if (String.isNotBlank(payload.derCase.DER_Application_Scenario__c)
							&& (payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_AUTO
								|| payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_MANUAL))
						{
							if (payload.nmi != null)
							{
								// ------------------------------------------------- //
								// --------- Update DER Application --------------- //
								// ------------------------------------------------ //

								// Meter__c field is expected to be present at payload.derApp
								// If Meter__c field is present then Apex Trigger will lookup the meter record to Meter_Ref__c
								update payload.derApp;
								payloadResp.success.setDerAppUpdate(payload.derApp.Id, payload.derCase.Id);

								// ---------------------------------------- //
								// --------- Upsert Devices --------------- //
								// ---------------------------------------- //

								if (payload.devices != null)
								{
									UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = true; // Disable roll up trigger momentarily
									payloadResp = processDevices(payload, payloadResp);
								}

								Id caseRTId;
								if (payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_AUTO)
								{
									caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_AUTO).getRecordTypeId();

									// --------------------------------------------------------------------------------------------------- //
									// ---------Installer, installer contact, customer, rep will be created/match for UPDATE/AUTO--------- //
									// --------------------------------------------------------------------------------------------------- //
									if (payload.installer != null && payload.installerContact != null
										&& payload.installer.ABN__c != null
										&& payload.installerContact.Accreditation_Number__c != null
										&& payload.installerContact.Acceditation_Type__c != null)
									{

										if (payload.customer != null)
										{
											// ----------------------------------------------------- //
											// ---------Insert customer for UPDATE/AUTO------------- //
											// ----------------------------------------------------- //

											//Always create new customer as per business logic CMC-1379
											Id acctCustRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
											payload.customer.recordTypeId = acctCustRTId;
											payload.customer.Customer_Type__c = 'ELE - DER';
											insert payload.customer;
											payloadResp.success.setCustomerInsert(payload.customer.Id);

											// ------------------------------------------------ //
											// ---------------- Update Connection Point-------- //
											// ------------------------------------------------ //

											// here nmi will be updated after customer is created

											payload.nmi.Account__c = payload.customer.Id;
											insertUpdateNMI(payload.nmi, true); // isUpdate = true
											payloadResp.success.setNmiUpdate(payload.nmi.Id, payload.nmi.NMI__c);

											// ------------------------------------------------ //
											// ---------Find Installer for UPDATE/AUTO-------- //
											// ----------------------------------------------- //

											// "Installers are always service providers"
											Id acctBusinessRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_SERVICEPROVIDER).getRecordTypeId();
											payload.installer.recordTypeId = acctBusinessRTId;
											payload.installer.Customer_Type__c = 'ELE - DER';
											Id instId = findServProvider(payload.installer.ABN__c);
											if (instId != null){
												payload.installer.Id = instId;
												update payload.installer;
												payloadResp.success.setInstallerUpdate(payload.installer.Id, payload.installer.ABN__c);
											}else{
												insert payload.installer;
												payloadResp.success.setInstallerInsert(payload.installer.Id);
											}

											// -------------------------------------------------------- //
											// ---------Find Installer Contact for UPDATE/AUTO-------- //
											// ------------------------------------------------------- //

											payload.installerContact.AccountId = payload.installer.Id;
											
											Id instContId = findInstallerContact(payload.installerContact.Accreditation_Number__c,
																				payload.installerContact.Acceditation_Type__c,
																				payload.installerContact.Email);
											
											if (instContId != null){
												payload.installerContact.Id = instContId;
												update payload.installerContact;
												payloadResp.success.setInstContUpdate(payload.installerContact.Id,
																							payload.installerContact.Accreditation_Number__c+
																							'+'+
																							payload.installerContact.Acceditation_Type__c);
												linkAccWithContact(payload.installer.Id, payload.installerContact.Id);
											}else{
												insert payload.installerContact;
												payloadResp.success.setInstContInsert(payload.installerContact.Id);
											}

											// ------------------------------------------------ //
											// ---- Insert DER Agreement UPDATE/AUTO  --------- //
											// ------------------------------------------------ //
											List<DER_Agreement__c> lstAgmnt = new List<DER_Agreement__c>([SELECT Id, Account__c
																											FROM DER_Agreement__c
																											WHERE DER_Application__c =: payload.derApp.Id]);
											//Agreement's Account lookup will be populated with Customer Id
											for (DER_Agreement__c item: lstAgmnt){
												item.Account__c = payload.customer.Id;
											}

											if (!lstAgmnt.isEmpty())
											{
												update lstAgmnt;
											}

											payload.derCase.AccountId = payload.installer.Id;
											payload.derCase.ContactId = payload.installerContact.Id;
											payload.derCase.Customer__c = payload.customer.Id;

											// ------------------------------------- //
											// --------- Update Case /AUTO --------- //
											// ------------------------------------- //

											payload.derCase.RecordTypeId = caseRTId;
											payload.derCase.DER_Application__c = payload.derApp.Id;
											payload.derCase.Status = CASE_STATUS_INST_VALIDATION;

											// Run device roll up calc before updating Case
											runDeviceRollup(payload.derCase);

											update payload.derCase;
											payloadResp.success.setDerCaseUpdate(payload.derCase.Id, payload.derCase.Id);
											resStatuCode = 200;
										}
										else
										{
											payloadResp.setError('customer JSON node is required');
											Database.rollback(sp);
										}
									}
									else
									{
										payloadResp.setError('installer (with ABN__c) & installerContact (with Accreditation_Number__c, Acceditation_Type__c) JSON nodes are required.');
										Database.rollback(sp);
									}
								}
								else
								{
									caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_MANUAL).getRecordTypeId();
									// ----------------------------------------- //
									// --------- Update Connection Point-------- //
									// ----------------------------------------- //

									insertUpdateNMI(payload.nmi, true); // isUpdate = true
									payloadResp.success.setNmiUpdate(payload.nmi.Id, payload.nmi.Id);

									// ----------------------------------------------------------------------------------- //
									// ---------Installer, installer contact, customer, rep for UPDATE/MANUAL------------- //
									// ----------------------------------------------------------------------------------- //
									if (payload.installer != null && payload.installerContact != null
										&& payload.installer.ABN__c != null
										&& payload.installerContact.Accreditation_Number__c != null
										&& payload.installerContact.Acceditation_Type__c != null)
									{

										if (payload.customer != null)
										{
											// ------------------------------------------------------- //
											// ----------------- Update for UPDATE/MANUAL------------- //
											// -------------------------------------------------------- //

											update payload.customer;
											payloadResp.success.setCustomerUpdate(payload.customer.Id, payload.customer.Id);

											if (payload.representative != null)
											{
												// --------------------------------------------------------------------- //
												// ---------------- Update representative for UPDATE/MANUAL------------- //
												// --------------------------------------------------------------------- //

												// Link representative contact with mutliple accounts
												update payload.representative;
												payloadResp.success.setRepUpdate(payload.representative.Id, payload.representative.Id);
												//linkAccWithContact(payload.representative.AccountId, payload.representative.Id);
											}else{
												// no error
												// representative node is now set to optional
											}
											// ------------------------------------------------------------------------------//
											// ---------------- Update representative Company for UPDATE/MANUAL------------- //
											// ------------------------------------------------------------------------------//
											if(payload.representativeCompany != null){
												update payload.representativeCompany;
												payloadResp.success.setRepCompUpdate(payload.representativeCompany.Id, payload.representativeCompany.Id);
											}
											else{
												// no error
												// representative Company node now set to optional
											}

											// ---------------------------------------------------------------- //
											// -----------------Update Installer for UPDATE/MANUAL------------- //
											// ---------------------------------------------------------------- //

											// "Installers are always service providers"
											Id acctBusinessRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_SERVICEPROVIDER).getRecordTypeId();
											payload.installer.recordTypeId = acctBusinessRTId;
											update payload.installer;
											payloadResp.success.setInstallerUpdate(payload.installer.Id, payload.installer.Id);

											// ------------------------------------------------------------------------ //
											// ---------------- Update Installer Contact for UPDATE/MANUAL------------- //
											// ------------------------------------------------------------------------ //

											update payload.installerContact;
											payloadResp.success.setInstContUpdate(payload.installerContact.Id, payload.installerContact.Id);
											//linkAccWithContact(payload.installerContact.AccountId, payload.installerContact.Id);

											// ------------------------------------- //
											// --------- Update Case /MANUAL ------- //
											// ------------------------------------- //

											payload.derCase.RecordTypeId = caseRTId;
											payload.derCase.DER_Application__c = payload.derApp.Id;
											payload.derCase.Status = CASE_STATUS_INST_VALIDATION;


											// Run device roll up calc before updating Case
											runDeviceRollup(payload.derCase);

											update payload.derCase;
											payloadResp.success.setDerCaseUpdate(payload.derCase.Id, payload.derCase.Id);
											resStatuCode = 200;
										}else{
											payloadResp.setError('customer JSON node is required');
											Database.rollback(sp);
										}
									}else{
										payloadResp.setError('installer (with ABN__c) & installerContact (with Accreditation_Number__c, Acceditation_Type__c) JSON nodes are required.');
										Database.rollback(sp);
									}
								}
							}
							else
							{
								payloadResp.setError('required nmi JSON nodes is missing.');
								Database.rollback(sp);
							}
						}
						else
						{
							payloadResp.setError('DER_Application_Scenario__c attribute (on derCase JSON node) is missing or invalid.');
							Database.rollback(sp);
						}

					}
					else
					{
						payloadResp.setError('derApp, derCase and nmi JSON nodes are required with Id attributes.');
						Database.rollback(sp);
					}
				}
				catch(DERApplicationAPIException derExp)
				{
					resStatuCode = 417;
					payloadResp.setError('Exception Occurred. ' + derExp.getMessage());
					System.debug('DER_REST_Application_v1--> doPost--> Exception-->'+payloadResp.error);
					Database.rollback(sp);
				}
				catch(Exception e)
				{
					resStatuCode = 417;
					payloadResp.setError('Exception Occurred. Message: ' + e.getMessage()
										+ ' StackTrace: ' + e.getStackTraceString()
										+ ' Type: ' + e.getTypeName()
										+ ' Cause: ' + e.getCause());

					System.debug('DER_REST_Application_v1--> doPatch--> Exception-->'+payloadResp.error);
					Database.rollback(sp);
				}
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

		de.bug('Response');
		de.bug('--------');
		de.bug('statusCode: ' + resStatuCode);
		de.bug('body:\n' + JSON.serializePretty(payloadResp));
		de.bugSend();

		RestContext.response.addHeader('Content-Type', 'application/json;');
		RestContext.response.statusCode = resStatuCode;
		RestContext.response.responseBody = Blob.valueOf(JSON.serialize(payloadResp));
	}

	@HttpPost
	global static void doPost()
	{
		Integer resStatuCode = 403;
		UtilDebug de = new UtilDebug();
		de.bug('DER_REST_Application_v1 - doPost()', true);
		de.bug('Create Application\n');

		String reqContentType = RestContext.request.headers.get('Content-Type');
		DER_Payload_Response payloadResp = new DER_Payload_Response();

		de.bug('Request payload');
		de.bug('---------------');
		de.bug('content type: ' + reqContentType);

		if (String.isNotBlank(reqContentType) && reqContentType.toLowerCase().contains('application/json'))
		{
			String reqBody = RestContext.request.requestBody.toString();
			de.bug(reqBody + '\n');

			if (String.isNotBlank(reqBody))
			{
				// A savepoint when no DML has been executed
				Savepoint sp = Database.setSavepoint();
				try
				{
					System.debug('reqBody----------------->'+reqBody);
					DER_Payload payload = (DER_Payload)JSON.deserialize(reqBody, DER_Payload.class);
					System.debug('payload----------------->'+payload);

					//------------------------------------------------------------------------------------//
					//------------ Insert logic for differnt objects based on the references ------------//
					//------------------------------------------------------------------------------------//
					if (payload.derCase != null && payload.derApp != null)
					{
						if (String.isNotBlank(payload.derCase.DER_Application_Scenario__c)
							&& (payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_AUTO
								|| payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_MANUAL))
						{
							if (payload.nmi != null && payload.nmi.NMI__c != null)
							{
								// ------------------------------------------------ //
								// ---------Find or create Connection Point-------- //
								// ------------------------------------------------ //

								Id conPointId = findConPoint(payload.nmi.NMI__c);
								if (conPointId != null){
									payload.nmi.Id = conPointId;
									// Update connection point once customer is inserted
								}else{
									//if Creating - Customer lookup will be null
									insertUpdateNMI(payload.nmi, false); // isUpdate = true
									payloadResp.success.setNmiInsert(payload.nmi.Id);
								}

								// ------------------------------------------------ //
								// --------- Insert DER Application --------------- //
								// ------------------------------------------------ //

								// Meter__c field is expected to be present at payload.derApp
								// If Meter__c field is present then Apex Trigger will lookup the meter record to Meter_Ref__c
								payload.derApp.NMI__c = payload.nmi.Id;

								// Set derApp Case Status for import assets trigger.
								payload.derApp.DER_Scenario__c = payload.derCase.DER_Application_Scenario__c;
								payload.derApp.Case_Type__c    = payload.derCase.Type;

								if (payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_AUTO)
									payload.derApp.Case_Status__c = CASE_STATUS_INST_PENDING;
								else if (payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_MANUAL)
									payload.derApp.Case_Status__c = CASE_STATUS_NEW;


								insert payload.derApp;
								payloadResp.success.setDerAppInsert(payload.derApp.Id);

								// ---------------------------------------- //
								// --------- Upsert Devices --------------- //
								// ---------------------------------------- //

								if (payload.devices != null)
								{
									UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = true; // Disable roll up trigger momentarily
									payloadResp = processDevices(payload, payloadResp);
								}

								Id caseRTId;
								if (payload.derCase.DER_Application_Scenario__c == CASE_SCENARIO_AUTO)
								{
									caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_AUTO).getRecordTypeId();
									// --------------------------------------------------------------------------------------------- //
									// ---------No installer, installer contact, customer, rep will be created for AUTO------------- //
									// --------------------------------------------------------------------------------------------- //

									// -------------------------------------------- //
									// ---------Update nmi for CREATE/AUTO  ------- //
									// -------------------------------------------- //

									if (payloadResp.success.nmi == null)
									{
										insertUpdateNMI(payload.nmi, true); // isUpdate = true;
										payloadResp.success.setNmiUpdate(payload.nmi.Id, payload.nmi.NMI__c);
									}

									// ------------------------------------- //
									// ---- Insert Case for CREATE/AUTO----- //
									// ------------------------------------- //

									payload.derCase.RecordTypeId = caseRTId;
									payload.derCase.DER_Application__c = payload.derApp.Id;
									payload.derCase.Status = CASE_STATUS_INST_PENDING;
									payload.derCase.OwnerId = getDefaultCaseQueueOwner(payload.derCase);

									if (payload.derCase.Auto_Applicant_Email__c != null){
										payload.derCase.Applicant_Email__c = payload.derCase.Auto_Applicant_Email__c;
										payload.derCase.Applicant_Name__c = payload.derCase.Auto_Applicant_FirstName__c + ' ' + payload.derCase.Auto_Applicant_LastName__c;
									}

									// Run device roll up calc before updating Case
									runDeviceRollup(payload.derCase);
									insertCase(payload.derCase);

									// Get App number
									Case newCase = (Case) UtilDatabase.getRecord(payload.derCase.Id);
									payloadResp.success.setDerCaseInsert(newCase.Id, newCase.Application_Number__c);

									// What are the chances the address is ok?
									System.debug('Check Address: ' + newCase.Site_fx__c);
									System.debug('Case_Ready__c: ' + newCase.Case_Ready__c);
									if (newCase.Site_fx__c != null && newCase.Site_fx__c != '' && newCase.Site_fx__c != 'N/A' &&
										!newCase.Case_Ready__c)
									{
										System.debug('** Setting Case_Ready__c to True.');
										Case updCase = new Case(Id = newCase.Id, Case_Ready__c = true);
										update updCase;
									}

									// ------------------------------------------------ //
									// ---- Insert DER Agreement CREATE/AUTO  --------- //
									// ------------------------------------------------ //
									DER_Agreement__c derAgmnt = new DER_Agreement__c();
									//Agreement's Account lookup will be populated during UpdateApplication API call
									derAgmnt.DER_Application__c = payload.derApp.Id;
									derAgmnt.NMI__c = payload.nmi.Id;
									derAgmnt.Offer_Accepted_By__c = payload.derCase.Applicant_Type__c;
									derAgmnt.Offer_Accepted_Date__c = System.today();
									derAgmnt.Offer_Made_Date__c = System.today();
									derAgmnt.Offer_Type__c = payload.derCase.Agreement_Type__c;
									derAgmnt.Status__c = Trig_DER_Agreement.AGGR_STATUS_OFFERACCEPTED;
									insert derAgmnt;

									resStatuCode = 200;
								}
								else
								{
									// Manual

									caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CASE_RECORDTYPE_MANUAL).getRecordTypeId();
									// -------------------------------------------------------------------------------------------- //
									// ---------Installer, installer contact, customer, rep will be created for MANUAL------------- //
									// -------------------------------------------------------------------------------------------- //
									if (payload.installer != null && payload.installerContact != null
										&& payload.installer.ABN__c != null
										&& payload.installerContact.Accreditation_Number__c != null
										&& payload.installerContact.Acceditation_Type__c != null)
									{
										// ----------------------------------------------------------------------- //
										// ---------Find or create RepresentativeCompany for CREATE/MANUAL------- //
										// -----------------------------------------------------------------------//
										// "RepresentativeCompany are always service providers"
										if (payload.representativeCompany != null)
										{
											if (payload.representativeCompany.Id == null)
											{
												// Set record type.
												payload.representativeCompany.recordTypeId = UtilDatabase.getRecordTypeNames('Account').get(ACCOUNT_RECORDTYPE_SERVICEPROVIDER);

												// Attempt to match Rep Company Account on ABN
												Id repCompId = findServProvider(payload.representativeCompany.ABN__c);

												if (repCompId != null)
												{
													payload.representativeCompany.Id = repCompId;
													update payload.representativeCompany;
													payloadResp.success.setRepCompUpdate(payload.representativeCompany.Id, payload.representativeCompany.ABN__c);
												}
												else
												{
													payload.representativeCompany.Type = 'Representative';
													payload.representativeCompany.Customer_Type__c = 'ELE - DER';
													insert payload.representativeCompany;
													payloadResp.success.setRepCompInsert(payload.representativeCompany.Id);
												}
											}
											else
											{
												// Assume should not get here.
												update payload.representativeCompany;
											}

											if (payload.representative != null && payload.representative.email != null)
											{
												// -------------------------------------------------------------- //
												// ---------Find or create representative for CREATE/MANUAL------- //
												// -------------------------------------------------------------- //

												// Link representative contact with mutliple accounts
												Id repId = findRep(payload.representative.email);

												if (repId != null)
												{
													payload.representative.AccountId = payload.representativeCompany.Id;
													payload.representative.Id = repId;
													update payload.representative;

													payloadResp.success.setRepUpdate(payload.representative.Id, payload.representative.email);
													linkAccWithContact(payload.representativeCompany.Id, payload.representative.Id);
												}
												else
												{
													payload.representative.AccountId = payload.representativeCompany.Id;
													insert payload.representative;

													payloadResp.success.setRepInsert(payload.representative.Id);
													linkAccWithContact(payload.representativeCompany.Id, payload.representative.Id);
												}

												payload.derCase.Representative__c = payload.representative.Id;
											}
											else{
												// no error
												// representative node is now set to optional
											}
										}
										else
										{
											// no represntative Company
											// Hence no representative Contact
										}


										if (payload.customer != null)
										{
											// ------------------------------------------------ //
											// ---------Insert customer for CREATE/MANUAL------- //
											// ------------------------------------------------ //

											// Always create new customer as per business logic CMC-1379 except Update/MANUAL
											// "If customer has ABN, then set to Customer - business else Customer - Individual"
											Id acctCustRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
											payload.customer.recordTypeId = acctCustRTId;
											payload.customer.Customer_Type__c = 'ELE - DER';
											insert payload.customer;
											payloadResp.success.setCustomerInsert(payload.customer.Id);

											// -------------------------------------------- //
											// ---------Update nmi for CREATE/MANUAL------- //
											// -------------------------------------------- //

											if (payloadResp.success.nmi == null)
											{
												// Now update connection point with Account lookup as customer
												payload.nmi.Account__c = payload.customer.Id;
												insertUpdateNMI(payload.nmi, true); // isUpdate = true;
												payloadResp.success.setNmiUpdate(payload.nmi.Id, payload.nmi.NMI__c);
											}

											// --------------------------------------------------------- //
											// ---------Find or create Installer for CREATE/MANUAL------- //
											// --------------------------------------------------------- //

											// "Installers are always service providers"
											Id acctBusinessRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_SERVICEPROVIDER).getRecordTypeId();
											payload.installer.recordTypeId = acctBusinessRTId;
											payload.installer.Customer_Type__c = 'ELE - DER';
											Id instId = findServProvider(payload.installer.ABN__c);
											if (instId != null){
												payload.installer.Id = instId;
												update payload.installer;
												payloadResp.success.setInstallerUpdate(payload.installer.Id, payload.installer.ABN__c);
											}else{
												payload.installer.Type = 'Installer';
												insert payload.installer;
												payloadResp.success.setInstallerInsert(payload.installer.Id);
											}

											// ----------------------------------------------------------------- //
											// ---------Find or create Installer Contact for CREATE/MANUAL------ //
											// ----------------------------------------------------------------- //

											payload.installerContact.AccountId = payload.installer.Id;
											
											Id instContId = findInstallerContact(payload.installerContact.Accreditation_Number__c,
																				payload.installerContact.Acceditation_Type__c,
																				payload.installerContact.Email);
											
											
											if (instContId != null){
												payload.installerContact.Id = instContId;
												update payload.installerContact;
												payloadResp.success.setInstContUpdate(payload.installerContact.Id,
																								payload.installerContact.Accreditation_Number__c+
																								'+'+
																								payload.installerContact.Acceditation_Type__c);
												linkAccWithContact(payload.installer.Id, payload.installerContact.Id);
											}else{
												insert payload.installerContact;
												payloadResp.success.setInstContInsert(payload.installerContact.Id);
											}

											// ------------------------------------- //
											// ---- Insert Case CREATE/MANUAL------- //
											// ------------------------------------- //


											payload.derCase.AccountId = payload.installer.Id;
											payload.derCase.ContactId = payload.installerContact.Id;
											payload.derCase.Customer__c = payload.customer.Id;
											payload.derCase.OwnerId = getDefaultCaseQueueOwner(payload.derCase);
											payload.derCase.RecordTypeId = caseRTId;
											payload.derCase.DER_Application__c = payload.derApp.Id;
											payload.derCase.Status = CASE_STATUS_NEW;

											// Run device roll up calc before inserting Case
											runDeviceRollup(payload.derCase);

											insertCase(payload.derCase);

											// Get App number
											Case newCase = (Case) UtilDatabase.getRecord(payload.derCase.Id);
											payloadResp.success.setDerCaseInsert(newCase.Id, newCase.Application_Number__c);

											// What are the chances the address is ok?
											System.debug('Check Address: ' + newCase.Site_fx__c);
											System.debug('Case_Ready__c: ' + newCase.Case_Ready__c);
											if (newCase.Site_fx__c != null && newCase.Site_fx__c != '' && newCase.Site_fx__c != 'N/A' &&
												!newCase.Case_Ready__c)
											{
												System.debug('** Setting Case_Ready__c to True.');
												Case updCase = new Case(Id = newCase.Id, Case_Ready__c = true);
												update updCase;
											}

											resStatuCode = 200;
										}
										else
										{
											payloadResp.setError('customer JSON node is required');
											Database.rollback(sp);
										}

									}else{
										payloadResp.setError('installer (with ABN__c) & installerContact (with Accreditation_Number__c, Acceditation_Type__c) JSON nodes are required.');
										Database.rollback(sp);
									}
								}
							}else{
								payloadResp.setError('required attribute nmi__c is missing for nmi JSON nodes.');
								Database.rollback(sp);
							}
						}else{
							payloadResp.setError('DER_Application_Scenario__c attribute (on derCase JSON node) is missing or invalid.');
							Database.rollback(sp);
						}
					}else{
						payloadResp.setError('derApp and derCase JSON nodes are required.');
						Database.rollback(sp);
					}
				}
				catch(DERApplicationAPIException derExp)
				{
					resStatuCode = 417;
					payloadResp.setError('Exception Occurred. ' + derExp.getMessage());
					System.debug('DER_REST_Application_v1--> doPost--> Exception-->'+payloadResp.error);
					Database.rollback(sp);
				}
				catch(Exception e)
				{
					resStatuCode = 417;
					payloadResp.setError('Exception Occurred. Message: ' + e.getMessage()
										+ ' StackTrace: ' + e.getStackTraceString()
										+ ' Type: ' + e.getTypeName()
										+ ' Cause: ' + e.getCause());

					System.debug('DER_REST_Application_v1--> doPost--> Exception-->'+payloadResp.error);
					Database.rollback(sp);
				}
			}
			else
			{
				payloadResp.setError('Request Body Not Found');
				resStatuCode = 400;
			}
		}
		else
		{
			payloadResp.setError('Invalid Content-Type');
			resStatuCode = 400;
		}

		de.bug('Response');
		de.bug('--------');
		de.bug('statusCode: ' + resStatuCode);
		de.bug('body:\n' + JSON.serializePretty(payloadResp), true);
		de.bugSend();

		RestContext.response.addHeader('Content-Type', 'application/json;');
		RestContext.response.statusCode = resStatuCode;
		RestContext.response.responseBody = Blob.valueOf(JSON.serialize(payloadResp));
	}

	//------------------------------------------------------------------//
	//------------  Internal Utility Methods ----------------------------//
	//------------------------------------------------------------------//

	private static void runDeviceRollup(Case derCase)
	{
		UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals = false; // reenable roll up trigger
		UtilFieldCalcs.CalcDERAppPhaseTotals(new Set<Id>{derCase.DER_Application__c}, false);
	}

	private static DER_Payload_Response processDevices(DER_Payload payload, DER_Payload_Response payloadResp)
	{
		if(payload.devices != null)
		{
			String deviceErrors = '';

			// Iterate L2 and L3 devices
			Map<String, Device__c> L2_Devices = new Map<String, Device__c>();
			Map<String, Device__c> L3_Devices = new Map<String, Device__c>();
			Set<String> EAIRefs = new Set<String>();
			Set<String> DeviceRTs = new Set<String>{'Device_L2', 'Device_L3'};
			Map<String, Id> mapRTNameId = UtilDatabase.getRecordTypeNames('Device__c');

			Boolean hasErrors = false;

			for (Device__c device: payload.devices)
			{
				if (device.EAI_Ref__c == null)
				{
					// Error: need a reference
					deviceErrors += 'Error: Device(s) missing EAI_Ref__c\n';
					hasErrors = true;
					break;
				}

				if (EAIRefs.contains(device.EAI_Ref__c))
				{
					// Error: reference duplicated
					deviceErrors += 'Error: [' + device.EAI_Ref__c + '] Device EAI_Ref__c duplication\n';
					hasErrors = true;
					continue;
				}
				EAIRefs.add(device.EAI_Ref__c);

				if (device.EAI_Type__c == null)
				{
					// Error: need a type
					deviceErrors += 'Error: [' + device.EAI_Ref__c + '] Device missing EAI_Type__c\n';
					hasErrors = true;
					continue;
				}

				if (!DeviceRTs.contains(device.EAI_Type__c))
				{
					// Error: invalid type
					deviceErrors += 'Error: [' + device.EAI_Ref__c + '] EAI_Type__c invalid\n';
					hasErrors = true;
					continue;
				}

				if (device.EAI_Type__c == 'Device_L3' && device.EAI_Parent__c == null)
				{
					// Error: need a parent for L3s
					deviceErrors = 'Error: [' + device.EAI_Ref__c + '] L3 Device missing EAI_Parent__c\n';
					hasErrors = true;
					continue;
				}

				if (device.EAI_Type__c == 'Device_L2' && device.EAI_Parent__c != null)
				{
					// Error: parent not allowed for L2
					deviceErrors = 'Error: [' + device.EAI_Ref__c + '] L2 Device EAI_Parent__c must be null\n';
					hasErrors = true;
					continue;
				}

				// Set record type Id
				device.RecordTypeId = mapRTNameId.get(device.EAI_Type__c);

				// Store in correct map
				if (device.EAI_Type__c == 'Device_L2')
					L2_Devices.put(device.EAI_Ref__c, device);
				else if (device.EAI_Type__c == 'Device_L3')
					L3_Devices.put(device.EAI_Ref__c, device);
			}

			// Validate L3s
			if (!hasErrors)
			{
				for (Device__c device: L3_Devices.values())
				{
					// Check parent exists
					if (!L2_Devices.containsKey(device.EAI_Parent__c))
					{
						// Error: parent not found for L3
						deviceErrors += 'Error: [' + device.EAI_Ref__c + '] L3 Device EAI_Parent__c not found: ' + device.EAI_Parent__c;
						hasErrors = true;
						continue;
					}
				}
			}

			if (hasErrors)
			{
				// throw
				System.debug('Process Device Hierarchy Fatal Error: ' +  deviceErrors);
				throw new DERApplicationAPIException(deviceErrors);
			}
			else
			{
				// all good.

				// Process L2s
				for (Device__c device: L2_Devices.values())
				{
					// Set DER App
					device.DER_Application__c = payload.derApp.Id;

					// Clear flags
					device.EAI_Type__c   = null;
					device.EAI_Ref__c    = null;
					device.EAI_Parent__c = null;
				}
				Database.UpsertResult[] L2_results = Database.upsert(L2_Devices.values(), Device__c.Id, true);

				// Process L3s
				for (Device__c device: L3_Devices.values())
				{
					// Set parent
					device.Parent_Device__c = L2_Devices.get(device.EAI_Parent__c).Id;

					// Clear flags
					device.EAI_Type__c   = null;
					device.EAI_Ref__c    = null;
					device.EAI_Parent__c = null;
				}
				Database.UpsertResult[] L3_results = Database.upsert(L3_Devices.values(), Device__c.Id, true);

				List<Database.UpsertResult> all_results = new List<Database.UpsertResult>();
				all_results.addAll(L2_results);
				all_results.addAll(L3_results);

				for (Database.UpsertResult result: all_results)
				{
					if (result.isSuccess())
					{
						if (result.isCreated())
						{
							System.debug(result.Id +' was created');
							payloadResp.success.setDeviceInsert(result.Id);
						}
						else
						{
							System.debug(result.Id +' was updated');
							payloadResp.success.setDeviceUpdate(result.Id, result.Id);
						}
					}
				}
			}
		}
		return payloadResp;
	}

	private static Id findConPoint(String nmiNum)
	{
		List<Connection_Point__c> cp = new List<Connection_Point__c>([SELECT Id
																		FROM Connection_Point__c
																		WHERE NMI__c =: nmiNum]);
		Id cpId;
		if (!cp.isEmpty()){
			cpId = cp[0].Id;
		}
		return cpId;
	}

	private static Id findRep(String email)
	{
		Id repId;

		// Match only DER contacts
		// Note: Wizard is creating orphaned Reps. This query attempts to find these, also.

		for (Contact rep: [SELECT Id
						   FROM Contact
						   WHERE Email = :email
						   AND IsPersonAccount = false
						   AND ((Account.RecordType.DeveloperName = :ACCOUNT_RECORDTYPE_SERVICEPROVIDER
								AND Account.Type IN :ACCOUNT_SERVICEPROVIDER_TYPES)
								OR Title IN :CONTACT_REP_TITLES)
						   LIMIT 1])
		{
			repId = rep.Id;
			break;
		}

		return repId;
	}

	private static Id findServProvider(String abn)
	{
		Id instId;

		// Note by using ABN__c field, we automatically match only DER SPs

		for (Account acc: [SELECT Id
							FROM Account
							WHERE ABN__c = :abn
							AND RecordType.DeveloperName = :ACCOUNT_RECORDTYPE_SERVICEPROVIDER LIMIT 1])
		{
			instId = acc.Id;
			break;
		}

		return instId;
	}

	private static Id findInstallerContact(String accNum, String accType, String email)
	{
		// Match only DER contacts
		List<Contact> instCon = new List<Contact>([SELECT Id
												FROM Contact
												WHERE Accreditation_Number__c = :accNum
												AND Acceditation_Type__c = :accType
												AND Email = :email
												AND Account.RecordType.DeveloperName = :ACCOUNT_RECORDTYPE_SERVICEPROVIDER
												AND Account.Type IN :ACCOUNT_SERVICEPROVIDER_TYPES]);
		Id instContId;
		if (!instCon.isEmpty()){
			instContId = instCon[0].Id;
		}
		return instContId;
	}

	private static void linkAccWithContact(Id accId, Id contId)
	{
		if (contId == null || accId == null)
		{
			System.debug('linkAccWithContact---> either accountId or contactId is null. accId: '+accId+' contId: '+contId);
			return;
		}

		AccountContactRelation ACR;

		for (AccountContactRelation accConRel: [SELECT Id, IsDirect
												FROM AccountContactRelation
												WHERE AccountId = :accId
												AND ContactId = :contId])
		{
			ACR = accConRel;
		}

		if (ACR == null)
		{
			// No relationship is established, so create one!
			ACR = new AccountContactRelation(AccountId = accId, ContactId = contId);
			insert ACR;
		}
	}

	private static void insertCase(Case derCase)
	{
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule = false;
		derCase.setOptions(dmo);
		insert derCase;
	}

	private static void insertUpdateNMI(Connection_Point__c nmi, boolean isUpdate)
	{
		Trig_Connection_Point.TrigDisabled = true;

		if (isUpdate)
			update nmi;
		else
			insert nmi;

		DER_Connection_Point_Util.PopulateExternalNMIRef(new Set<Id>{nmi.Id}, null);
	}

	private static Id queueId;
	private static Id getDefaultCaseQueueOwner(Case derCase)
	{
		if (queueId == null && derCase != null && derCase.DER_Application_Scenario__c != null)
		{
			String queueName;

			if (derCase.DER_Application_Scenario__c == CASE_SCENARIO_AUTO)
				queueName = CASE_DEFAULT_QUEUE_AUTO;
			else if (derCase.DER_Application_Scenario__c == CASE_SCENARIO_MANUAL)
				queueName = CASE_DEFAULT_QUEUE_MANUAL;

			for (Group g: [SELECT Id FROM Group WHERE Name = :queueName AND Type = 'Queue' LIMIT 1])
				queueId = g.Id;
		}

		return queueId;
	}
}