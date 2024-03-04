public with sharing class CE_ContactPointSync2
{
	// *********************************************************************
	// *** Member vars
	private static final Set<String> CON_RETAILER_FLDS = new Set<String>
	{
		'Phone',
		'MobilePhone',
		'OtherPhone',
		'Email'
	};

	private static final Set<String> CON_ENHANCED_FLDS = new Set<String>
	{
		'CE_Email_Address__c',
		'CE_Phone_Number__c'
	};

	private static final Map<String, String> CPE_FLD_MAP = new Map<String, String>
	{
		'EmailAddress' => 'CE_Email_Address__c'
	};

	private static final Map<String, String> CPP_FLD_MAP = new Map<String, String>
	{
		'TelephoneNumber' => 'CE_Phone_Number__c'
	};

	private static final Set<String> MOBILE_PREFIXES = new Set<String>{'04', '+614', '614'};

	private static final String DML_INSERT = 'Insert';
	private static final String DML_UPDATE = 'Update';

	public static Boolean isRunningContactUpdate = false;
	public static Boolean isRunningCPPCPEUpdate  = false;
	public static Boolean disableAccountPrimConTrig = false;

	public static Map<String, EngagementChannelType> channels;
	public static DataUsePurpose purpose;


	// *********************************************************************
	// *** No constructor


	// *********************************************************************
	// *** Static Methods

	// ** Trigger from Contact
	public static void syncCPPCPEFields(List<Contact> newContacts, Map<Id, Contact> oldContacts)
	{
		if (isRunningContactUpdate) return;

		// Qualify
		Id RTId = UtilDatabase.getRecordTypeNames('Contact').get(Outage_IncidentProcessor.CON_DCP_RT);
		List<Contact> qualifiedCons = new List<Contact>();

		for (Contact con: newContacts)
			if (con.RecordTypeId == RTId)
				qualifiedCons.add(con);

		syncRetailerFieldsCPPCPE(qualifiedCons, oldContacts);
		syncEnhancedFieldsCPPCPE(qualifiedCons, oldContacts);
	}

	public static void syncRetailerFieldsCPPCPE(List<Contact> newContacts, Map<Id, Contact> oldContacts)
	{
		// qualify
		List<Contact> qualifiedCons = new List<Contact>();
		Boolean isUpdate = false;
		if (Trigger.isUpdate != null)
		{
			// check which object is triggered.
			if (Trigger.new[0] instanceOf Contact)
				isUpdate = Trigger.isUpdate;
		}

		for (Contact newCon: newContacts)
		{
			if (!isUpdate)
			{
				// Is insert
				for (String fld: CON_RETAILER_FLDS)
				{
					if (newCon.get(fld) != null)
					{
						qualifiedCons.add(newCon);
						break;
					}
				}

				continue;
			}

			Contact oldCon = oldContacts.get(newCon.Id);

			// check fields, find records to be updated
			for (String fld: CON_RETAILER_FLDS)
			{
				if (newCon.get(fld) != oldCon.get(fld))
				{
					qualifiedCons.add(newCon);
					break;
				}
			}
		}

		if (qualifiedCons.isEmpty())
		{
			// nothing to do
			return;
		}

		// Get CPP and CPEs for contacts
		UtilDatabase db = new UtilDatabase();
		List<Contact> consWithCPPCPEs = getContacts(getConIds(qualifiedCons));

		for (Contact newCon: consWithCPPCPEs)
		{
			Contact oldCon;
			if (isUpdate) oldCon = oldContacts.get(newCon.Id);

			// check fields, find records to be updated
			for (String fld: CON_RETAILER_FLDS)
			{
				String oldValue, newValue;
				if (isUpdate && oldCon.get(fld) != null) oldValue = (String)oldCon.get(fld);
				if (newCon.get(fld) != null)             newValue = (String)newCon.get(fld);

				if (isUpdate && newValue == oldValue) continue;

				// * Scenarios
				// null to value
				// value to null
				// value1 to value2

				if (fld.containsIgnoreCase('Phone'))
				{
					// Check CPP
					Boolean foundRecord = false;

					for (ContactPointPhone CPP: newCon.Contact_Point_Phones__r)
					{
						if (CPP.Data_Type__c != Outage_IncidentProcessor.DATATYPE_RETAILER) continue;
						if (CPP.Source_Field__c != fld) continue;
						foundRecord = true;

						ContactPointPhone oldCPP = CPP.clone(true, true, true, true);

						CPP.TelephoneNumber = newValue;
						CPP.IsSMSCapable = isMobile(newValue);
						CPP.IsPrimary = true;
						CPP.Status__c = Outage_IncidentProcessor.CP_STS_ACTIVE;

						if (newValue == null)
						{
							CPP.TelephoneNumber = oldCPP.TelephoneNumber;
							CPP.IsSMSCapable = oldCPP.IsSMSCapable;
							CPP.IsPrimary = false;
							CPP.Status__c = Outage_IncidentProcessor.CP_STS_DELETED;
						}

						if (CPP.IsSMSCapable)
							CPP.PhoneType = Outage_IncidentProcessor.CPP_PHONE_TYPE_MOBILE;
						else
							CPP.PhoneType = Outage_IncidentProcessor.CPP_PHONE_TYPE_HOME;

						CPP.PrimaryKey__c = getPrimaryKeyValue(CPP);

						// If set to null, close out any consent records found
						if (newValue == null || !CPP.IsSMSCapable)
						{
							CPP.IsPrimary = false;
							closeCPCRecord(CPP, newCon, db);
						}

						if (isDiff(CPP, oldCPP)) db.addObjForUpsert(CPP);
						break;
					}

					if (!foundRecord && newValue != null)
					{
						// create new
						ContactPointPhone CPP = new ContactPointPhone();
						CPP.Contact__c = newCon.Id;
						CPP.Data_Type__c = Outage_IncidentProcessor.DATATYPE_RETAILER;
						CPP.Source_Field__c = fld;
						CPP.IsPrimary = true;
						CPP.Status__c = Outage_IncidentProcessor.CP_STS_ACTIVE;

						CPP.TelephoneNumber = newValue;
						CPP.IsSMSCapable = isMobile(newValue);

						if (CPP.IsSMSCapable)
							CPP.PhoneType = Outage_IncidentProcessor.CPP_PHONE_TYPE_MOBILE;
						else
							CPP.PhoneType = Outage_IncidentProcessor.CPP_PHONE_TYPE_HOME;

						CPP.PrimaryKey__c = getPrimaryKeyValue(CPP);
						db.addObjForUpsert(CPP);
					}
				}
				else if (fld.containsIgnoreCase('Email'))
				{
					// Check CPE
					Boolean foundRecord = false;

					for (ContactPointEmail CPE: newCon.Contact_Point_Emails__r)
					{
						if (CPE.Data_Type__c != Outage_IncidentProcessor.DATATYPE_RETAILER) continue;
						if (CPE.Source_Field__c != fld) continue;
						foundRecord = true;

						ContactPointEmail oldCPE = CPE.clone(true, true, true, true);

						CPE.EmailAddress = newValue;
						CPE.PrimaryKey__c = getPrimaryKeyValue(CPE);
						CPE.IsPrimary = true;
						CPE.Status__c = Outage_IncidentProcessor.CP_STS_ACTIVE;

						if (newValue == null)
						{
							CPE.EmailAddress = oldCPE.EmailAddress;
							CPE.IsPrimary = false;
							CPE.Status__c = Outage_IncidentProcessor.CP_STS_DELETED;
							closeCPCRecord(CPE, newCon, db);
						}

						if (isDiff(CPE, oldCPE)) db.addObjForUpsert(CPE);
						break;
					}

					if (!foundRecord && newValue != null)
					{
						// create new
						ContactPointEmail CPE = new ContactPointEmail();
						CPE.Contact__c = newCon.Id;
						CPE.Data_Type__c = Outage_IncidentProcessor.DATATYPE_RETAILER;
						CPE.Source_Field__c = fld;
						CPE.IsPrimary = true;
						CPE.Status__c = Outage_IncidentProcessor.CP_STS_ACTIVE;

						CPE.EmailAddress = newValue;
						CPE.PrimaryKey__c = getPrimaryKeyValue(CPE);
						db.addObjForUpsert(CPE);
					}
				}
			}
		}

		isRunningCPPCPEUpdate = true;
		db.upsertObjs();
	}

	public static void syncEnhancedFieldsCPPCPE(List<Contact> newContacts, Map<Id, Contact> oldContacts)
	{
		System.debug('** syncEnhancedFieldsCPPCPE');
		// qualify
		List<Contact> qualifiedCons = new List<Contact>();
		Boolean isUpdate = Trigger.isUpdate;
		// System.debug('isUpdate: ' + isUpdate);

		for (Contact newCon: newContacts)
		{
			if (!isUpdate)
			{
				// Is insert
				for (String fld: CON_ENHANCED_FLDS)
				{
					if (newCon.get(fld) != null)
					{
						qualifiedCons.add(newCon);
						break;
					}
				}

				continue;
			}

			Contact oldCon = oldContacts.get(newCon.Id);

			// check fields, find records to be updated
			for (String fld: CON_ENHANCED_FLDS)
			{
				if (newCon.get(fld) != oldCon.get(fld))
				{
					qualifiedCons.add(newCon);
					break;
				}
			}
		}

		if (qualifiedCons.isEmpty())
		{
			// nothing to do
			System.debug('Nothing to do.');
			return;
		}

		// Get CPP and CPEs for contacts
		UtilDatabase db = new UtilDatabase();
		List<Contact> consWithCPPCPEs = getContacts(getConIds(qualifiedCons));

		for (Contact newCon: consWithCPPCPEs)
		{
			Contact oldCon;
			if (isUpdate) oldCon = oldContacts.get(newCon.Id);

			// check fields, find records to be updated
			for (String fld: CON_ENHANCED_FLDS)
			{
				// System.debug('** Field: ' + fld);

				String oldValue, newValue;
				if (isUpdate && oldCon.get(fld) != null) oldValue = (String)oldCon.get(fld);
				if (newCon.get(fld) != null) newValue = (String)newCon.get(fld);

				if (isUpdate && newValue == oldValue)
				{
					// System.debug('Field not changed. Skipping field update...');
					continue;
				}

				// System.debug('Field changed, needs sync');
				// System.debug('oldValue: ' + oldValue);
				// System.debug('newValue: ' + newValue);

				// * Scenarios
				// null to value
					// Find existing, activate,
					// or create new

				// value to null
					// Find existing, deactivate?
					// or - set as Primary=false
					// or - do nothing?

				// value1 to value2
					// Find existing, update - or create new

				if (fld.containsIgnoreCase('Phone'))
				{
					// Check CPP
					Boolean foundRecord = false;
					// System.debug('CPP Size: ' + newCon.Contact_Point_Phones__r.size());

					newValue = getMobileFormat(newValue);
					oldValue = getMobileFormat(oldValue);

					for (ContactPointPhone CPP: newCon.Contact_Point_Phones__r)
					{
						if (CPP.Data_Type__c != Outage_IncidentProcessor.DATATYPE_ENHANCED) continue;
						if (CPP.TelephoneNumber != newValue && CPP.TelephoneNumber != oldValue) continue;

						ContactPointPhone oldCPP = CPP.clone(true, true, true, true);
						// System.debug('CPP:\n' + JSON.serializePretty(CPP));

						// from here: CPP record is either oldvalue or newvalue.
						Boolean isOldValue = (CPP.TelephoneNumber == oldValue);
						// System.debug('isOldValue: ' + isOldValue);

						if (isUpdate && isOldValue)
						{
							CPP.IsPrimary = false;
							closeCPCRecord(CPP, newCon, db);
							if (isDiff(oldCPP, CPP)) db.addObjForUpsert(CPP);
							continue;
						}

						// from here: CPP record is newvalue only.
						foundRecord = true;
						if (newValue == null)
						{
							// nothing else to do.
							// unlikely to find ourselves here... we'll see.
							break;
						}

						CPP.Status__c = Outage_IncidentProcessor.CP_STS_ACTIVE;
						CPP.TelephoneNumber = newValue;
						CPP.IsSMSCapable = isMobile(newValue);
						CPP.IsPrimary = true;

						if (CPP.IsSMSCapable)
							CPP.PhoneType = Outage_IncidentProcessor.CPP_PHONE_TYPE_MOBILE;
						else
							CPP.PhoneType = Outage_IncidentProcessor.CPP_PHONE_TYPE_HOME;

						CPP.PrimaryKey__c = getPrimaryKeyValue(CPP);
						if (isDiff(oldCPP, CPP)) db.addObjForUpsert(CPP);
						break;
					}

					if (!foundRecord && newValue != null)
					{
						// create new
						ContactPointPhone CPP = new ContactPointPhone();
						CPP.Contact__c = newCon.Id;
						CPP.Data_Type__c = Outage_IncidentProcessor.DATATYPE_ENHANCED;
						CPP.Status__c = Outage_IncidentProcessor.CP_STS_ACTIVE;
						CPP.IsPrimary = true;

						CPP.TelephoneNumber = newValue;
						CPP.IsSMSCapable = isMobile(newValue);

						if (CPP.IsSMSCapable)
							CPP.PhoneType = Outage_IncidentProcessor.CPP_PHONE_TYPE_MOBILE;
						else
							CPP.PhoneType = Outage_IncidentProcessor.CPP_PHONE_TYPE_HOME;

						CPP.PrimaryKey__c = getPrimaryKeyValue(CPP);
						db.addObjForUpsert(CPP);
					}
				}
				else if (fld.containsIgnoreCase('Email'))
				{
					// Check CPE
					Boolean foundRecord = false;

					for (ContactPointEmail CPE: newCon.Contact_Point_Emails__r)
					{
						if (CPE.Data_Type__c != Outage_IncidentProcessor.DATATYPE_ENHANCED) continue;
						if (CPE.EmailAddress != newValue && CPE.EmailAddress != oldValue) continue;

						ContactPointEmail oldCPE = CPE.clone(true, true, true, true);

						// from here: CPE record is either oldvalue or newvalue.
						Boolean isOldValue = (CPE.EmailAddress == oldValue);

						if (isUpdate && isOldValue)
						{
							CPE.IsPrimary = false;
							closeCPCRecord(CPE, newCon, db);
							if (isDiff(CPE, oldCPE)) db.addObjForUpsert(CPE);
							continue;
						}

						// from here: CPP record is newvalue only.
						foundRecord = true;
						if (newValue == null)
						{
							// nothing else to do.
							// unlikely to find ourselves here... we'll see.
							break;
						}

						CPE.Status__c = Outage_IncidentProcessor.CP_STS_ACTIVE;
						CPE.EmailAddress = newValue;
						CPE.PrimaryKey__c = getPrimaryKeyValue(CPE);
						CPE.IsPrimary = true;
						if (isDiff(CPE, oldCPE)) db.addObjForUpsert(CPE);
						break;
					}

					if (!foundRecord && newValue != null)
					{
						// create new
						ContactPointEmail CPE = new ContactPointEmail();
						CPE.Contact__c = newCon.Id;
						CPE.Data_Type__c = Outage_IncidentProcessor.DATATYPE_ENHANCED;
						CPE.Status__c = Outage_IncidentProcessor.CP_STS_ACTIVE;
						CPE.IsPrimary = true;

						CPE.EmailAddress = newValue;
						CPE.PrimaryKey__c = getPrimaryKeyValue(CPE);
						db.addObjForUpsert(CPE);
					}
				}
			}
		}

		isRunningCPPCPEUpdate = true;
		db.upsertObjs();
	}

	// ** Trigger from CPP/CPE
	public static void syncCPPCPEContactFields(List<SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		if (isRunningCPPCPEUpdate) return;

		Boolean isUpdate = Trigger.isUpdate;
		List<SObject> qualifiedSObjs = new List<SObject>();
		Set<Id> ConIds = new Set<Id>();
		String ObjType;
		Map<String, String> fieldMap;

		// if IsChanged, and Enhanced, and IsPrimary
		// then sync to Contact
		for (SObject newSObj: newSObjs)
		{
			// get type, get map
			if (ObjType == null)
			{
				ObjType = UtilDatabase.getObjectName(newSObj);

				if (ObjType == 'ContactPointEmail')
					fieldMap = CPE_FLD_MAP;
				else if (ObjType == 'ContactPointPhone')
					fieldMap = CPP_FLD_MAP;
	
				if (fieldMap == null)
				{
					// is bad
					throw new Outage_IncidentProcessor.DataIntegrityException();
				}
			}

			if (newSObj.get('Contact__c')           == null) continue;
			if ((String)newSObj.get('Status__c')    != Outage_IncidentProcessor.CP_STS_ACTIVE) continue;
			if ((String)newSObj.get('Data_Type__c') != Outage_IncidentProcessor.DATATYPE_ENHANCED) continue;
			if (!(Boolean)newSObj.get('IsPrimary')) continue;

			Id ConId = (Id)newSObj.get('Contact__c');

			if (!isUpdate)
			{
				// is insert

				// qualify
				qualifiedSObjs.add(newSObj);
				ConIds.add(ConId);
				continue;
			}

			// is update
			SObject oldSObj = oldSObjs.get(newSObj.Id);

			for (String fld: fieldMap.keySet())
			{
				String newValue, oldValue;
				if (newSObj.get(fld) != null) newValue = (String)newSObj.get(fld);
				if (oldSObj.get(fld) != null) oldValue = (String)oldSObj.get(fld);

				if (newValue != oldValue)
				{
					// qualify
					qualifiedSObjs.add(newSObj);
					ConIds.add(ConId);
					break;
				}
			}
		}

		if (qualifiedSObjs.isEmpty())
		{
			// nothing to do
			return;
		}

		// Get contacts
		Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, Name, CE_Email_Address__c, CE_Phone_Number__c FROM Contact WHERE Id IN :ConIds]);

		// Iterate qualified
		UtilDatabase db = new UtilDatabase();

		for (SObject newSObj: qualifiedSObjs)
		{
			Id ConId = (Id)newSObj.get('Contact__c');
			Contact con = mapContacts.get(ConId);

			for (String childFld: fieldMap.keySet())
			{
				String conFld = fieldMap.get(childFld);

				String srcValue, conValue;
				if (newSObj.get(childFld) != null) srcValue = (String)newSObj.get(childFld);
				if (con.get(conFld) != null)       conValue = (String)con.get(conFld);

				if (conFld.containsIgnoreCase('Phone'))
					srcValue = getMobileFormatPretty(srcValue);

				if (conValue != srcValue)
				{
					con.put(conFld, srcValue);
					db.addObjForUpsert(con);
				}
			}
		}

		// Run updates
		isRunningContactUpdate = true;
		db.upsertObjs();
	}

	// ** Force update of Retailer fields - for Batch processing
	public static void forceSyncRetailerFields() // CE_ContactPointSync2.forceSyncRetailerFields();
	{
		List<Contact> contacts = [SELECT Id, Name, RecordTypeId, 
								  Phone, MobilePhone, Email, OtherPhone, HomePhone, CE_Email_Address__c, CE_Phone_Number__c
								  FROM Contact 
								  WHERE RecordType.DeveloperName = :Outage_IncidentProcessor.CON_DCP_RT];

		forceSyncRetailerFields(contacts);
	}

	public static void forceSyncRetailerFields(List<Contact> contacts)
	{
		if (contacts == null || contacts.isEmpty()) return;

		syncRetailerFieldsCPPCPE(contacts, null);
	}

	public static void createRetailerDefaultConsents(List<Contact> contacts)
	{
		if (contacts == null || contacts.isEmpty()) return;

		/*
			CRM validates Primary Contact Number for a valid mobile number
			If this is a valid mobile number - then message is sent using this number

			If this is not a valid mobile number
			Then CRM validates Secondary Contact Number for a valid mobile number
			If this is a valid mobile number - then message is sent using this number

			If this is not a valid mobile number
			Then customer email is used to send message
		*/

		List<Contact> consWithCPPCPEs = getContacts(getConIds(contacts));
		UtilDatabase db = new UtilDatabase();

		for (Contact con: consWithCPPCPEs)
		{
			// count Retailer CPPs and CPEs
			Integer numRetailerCPPs = countRetailerCPPCPEs(con.Contact_Point_Phones__r);
			Integer numRetailerCPEs = countRetailerCPPCPEs(con.Contact_Point_Emails__r);
			Integer numNewCPCs      = 0;

			if (numRetailerCPPs + numRetailerCPEs == 0)
			{
				// if 0, nothing to do
				continue;
			}

			// count CPCs
			if (con.Contact_Point_Consents__r != null && !con.Contact_Point_Consents__r.isEmpty())
			{
				// If >0, leave it alone
				continue;
			}

			// for each retailer CPP / CPE
			if (numRetailerCPPs > 0 && numNewCPCs == 0)
			{
				for (ContactPointPhone CPP: con.Contact_Point_Phones__r)
				{
					if (CPP.Data_Type__c != Outage_IncidentProcessor.DATATYPE_RETAILER) continue;
					if (CPP.Status__c    != Outage_IncidentProcessor.CP_STS_ACTIVE) continue;
					if (CPP.PhoneType    != Outage_IncidentProcessor.CPP_PHONE_TYPE_MOBILE) continue;

					// create default CPC
					db.addObjForUpsert(createCPCRecord(CPP));
					numNewCPCs++;

					// break, since we only need one CPC
					break;
				}
			}

			if (numRetailerCPEs > 0 && numNewCPCs == 0)
			{
				for (ContactPointEmail CPE: con.Contact_Point_Emails__r)
				{
					if (CPE.Data_Type__c != Outage_IncidentProcessor.DATATYPE_RETAILER) continue;
					if (CPE.Status__c    != Outage_IncidentProcessor.CP_STS_ACTIVE) continue;

					// create default CPC
					db.addObjForUpsert(createCPCRecord(CPE));
					numNewCPCs++;

					// break, since we only need one CPC
					break;
				}
			}
		}

		db.upsertObjs();
	}

	public static void createRetailerDefaultConsents(Set<Id> conIds)
	{
		if (disableAccountPrimConTrig) return;
		List<Contact> cons = getContacts(conIds);

		forceSyncRetailerFields(cons);
		createRetailerDefaultConsents(cons);
	}


	// *********************************************************************
	// *** Helper methods
	private static Boolean isDiff(ContactPointEmail sobj1, ContactPointEmail sobj2)
	{
		if (sobj1 == null || sobj2 == null) return true;

		return (sobj1.Contact__c      != sobj2.Contact__c      ||
				sobj1.Data_Type__c    != sobj2.Data_Type__c    ||
				sobj1.Source_Field__c != sobj2.Source_Field__c ||
				sobj1.Status__c       != sobj2.Status__c       ||
				sobj1.IsPrimary       != sobj2.IsPrimary       ||
				sobj1.EmailAddress    != sobj2.EmailAddress    ||
				sobj1.PrimaryKey__c   != sobj2.PrimaryKey__c);
	}

	private static Boolean isDiff(ContactPointPhone sobj1, ContactPointPhone sobj2)
	{
		if (sobj1 == null || sobj2 == null) return true;

		return (sobj1.Contact__c      != sobj2.Contact__c      ||
				sobj1.Data_Type__c    != sobj2.Data_Type__c    ||
				sobj1.Source_Field__c != sobj2.Source_Field__c ||
				sobj1.Status__c       != sobj2.Status__c       ||
				sobj1.IsPrimary       != sobj2.IsPrimary       ||
				sobj1.TelephoneNumber != sobj2.TelephoneNumber ||
				sobj1.IsSMSCapable    != sobj2.IsSMSCapable    ||
				sobj1.PhoneType       != sobj2.PhoneType       ||
				sobj1.PrimaryKey__c   != sobj2.PrimaryKey__c);
	}

	private static void closeCPCRecord(SObject sobj, Contact con, UtilDatabase db)
	{
		if (sobj == null || con == null || db == null) return;

		Id CPId = sobj.Id;

		String  DataType   = (String)sobj.get('Data_Type__c');
		Boolean isRetailer = (DataType == Outage_IncidentProcessor.DATATYPE_RETAILER);
		String  CapSource  = isRetailer ? Outage_IncidentProcessor.CPC_RTL_UPD_CAPTURE_SOURCE:Outage_IncidentProcessor.CPC_ENH_UPD_CAPTURE_SOURCE;

		for (ContactPointConsent CPC: con.Contact_Point_Consents__r)
		{
			if (CPC.ContactPointId != CPId) continue;
			if (CPC.Status__c != Outage_IncidentProcessor.CPC_STS_ACTIVE) continue;

			CPC.CaptureDate   = CPC.EffectiveTo = DateTime.now();
			CPC.CaptureSource = CapSource;
			db.addObjForUpsert(CPC);
		}
	}

	private static ContactPointConsent createCPCRecord(SObject contactpoint)
	{
		if (contactpoint == null) return null;

		String channel = Outage_IncidentProcessor.CHANNEL_EMAIL;
		if (contactpoint instanceOf ContactPointPhone)
			channel = Outage_IncidentProcessor.CHANNEL_SMS;
		
		ContactPointConsent CPC = new ContactPointConsent();
		CPC.Name = 'CPC record';
		CPC.Contact__c = (Id)contactpoint.get('Contact__c');
		CPC.ContactPointId = contactpoint.Id;
		CPC.CaptureSource = Outage_IncidentProcessor.CPC_DEFAULT_CAPTURE_SOURCE;
		CPC.CaptureDate = System.now();
		CPC.EffectiveFrom = CPC.CaptureDate;
		CPC.EngagementChannelTypeId = getChannelId(channel);
		CPC.DataUsePurposeId = getPurposeId(Outage_IncidentProcessor.DATAUSE_OUTAGES);
		CPC.Authorised_to_Change__c = null;
		CPC.Privacy_Policy__c = null;

		return CPC;
	}

	private static Id getChannelId(String channelName)
	{
		if (channels == null)
			channels = new Map<String, EngagementChannelType>();

		if (!channels.containsKey(channelName))
		{
			for (EngagementChannelType ect: [SELECT Id, Name
											 FROM EngagementChannelType
											 WHERE Name=:channelName
											 LIMIT 1])
			{
				channels.put(channelName, ect);
			}

			if (!channels.containsKey(channelName))
			{
				throw new Outage_IncidentProcessor.DataIntegrityException();
			}
		}

		return channels.get(channelName).Id;
	}

	private static Id getPurposeId(String purposeName)
	{
		if (purpose == null)
		{
			for (DataUsePurpose dup: [SELECT Id, Name
									  FROM DataUsePurpose
									  WHERE Name=:purposeName
									  LIMIT 1])
			{
				purpose = dup;
			}

			if (purpose == null)
			{
				throw new Outage_IncidentProcessor.DataIntegrityException();
			}
		}

		return purpose.Id;
	}

	public static String getPrimaryKeyValue(SObject sobj)
	{
		if (sobj == null) return null;
		String key;

		String ObjType = UtilDatabase.getObjectName(sobj);

		if (ObjType == 'ContactPointPhone')
		{
			ContactPointPhone CPP = (ContactPointPhone)sobj;
			key = CPP.Contact__c + '|' + CPP.Data_Type__c + '|' + CPP.TelephoneNumber;
			if (CPP.Data_Type__c == Outage_IncidentProcessor.DATATYPE_RETAILER)
				key += '|' + CPP.Source_Field__c;
		}
		else if (ObjType == 'ContactPointEmail')
		{
			ContactPointEmail CPE = (ContactPointEmail)sobj;
			key = CPE.Contact__c + '|' + CPE.Data_Type__c + '|' + CPE.EmailAddress;
			if (CPE.Data_Type__c == Outage_IncidentProcessor.DATATYPE_RETAILER)
				key += '|' + CPE.Source_Field__c;
		}

		return key;
	}

	private static Boolean isMobile(String phoneValue)
	{
		Boolean output = false;

		if (phoneValue == null)
			return output;

		for (String prefix: MOBILE_PREFIXES)
		{
			if (phoneValue.startsWith(prefix))
			{
				output = true;
				break;
			}
		}

		return output;
	}

	public static String getMobileFormat(String phoneValue)
	{
		if (phoneValue == null) return null;
		if (!isMobile(phoneValue)) return phoneValue;

		phoneValue = phoneValue.trim();

		// check TelephoneNumber - standardise prefix
		for (String prefix: MOBILE_PREFIXES)
		{
			if (phoneValue.startsWith(prefix))
			{
				phoneValue = '614' + phoneValue.removeStart(prefix);
				break;
			}
		}

		// Strip spaces
		if (phoneValue.contains(' '))
			phoneValue = phoneValue.replace(' ', '');

		return phoneValue;
	}

	public static String getMobileFormatPretty(String phoneValue)
	{
		if (phoneValue == null) return null;
		if (!isMobile(phoneValue)) return phoneValue;
		phoneValue = getMobileFormat(phoneValue);

		// Segment into 4,3,3
		if (phoneValue.length() == 11 && phoneValue.startsWith('614'))
		{
			// 0411222333
			phoneValue = '04' + phoneValue.removeStart('614');
			phoneValue = phoneValue.substring(0, 4) + ' ' + 
						 phoneValue.substring(4, 7) + ' ' + 
						 phoneValue.substring(7, 10);
		}

		return phoneValue;
	}

	private static Integer countRetailerCPPCPEs(List<SObject> records)
	{
		Integer count = 0;
		if (records == null || records.isEmpty()) return count;

		for (SObject o: records)
		{
			if (o.get('Data_Type__c') == null) continue;
			if ((String)o.get('Data_Type__c') != Outage_IncidentProcessor.DATATYPE_RETAILER) continue;
			
			count++;
		}

		return count;
	}

	private static Set<Id> getConIds(List<Contact> contacts)
	{
		if (contacts == null) return null;

		Set<Id> conIds = new Set<Id>();
		for (Contact c: contacts)
			conIds.add(c.Id);

		return conIds;
	}

	private static List<Contact> getContacts(Set<Id> conIds)
	{
		return [SELECT Id, Name, Salutation, FirstName, LastName,
				Email, Phone, MobilePhone, OtherPhone, HomePhone,
				CE_Email_Address__c, CE_Phone_Number__c,

				(SELECT Id, Name, Contact__c, ContactPointId, DataUsePurpose.Name, EngagementChannelType.Name,
				Status__c, Authorised_to_Change__c, Privacy_Policy__c,
				CaptureSource, CaptureDate, EffectiveFrom, EffectiveTo,
				TYPEOF ContactPoint WHEN ContactPointPhone THEN Id,IsPrimary,TelephoneNumber,PhoneType,IsSmsCapable END,
				TYPEOF ContactPoint WHEN ContactPointEmail THEN Id,IsPrimary,EmailAddress END
				FROM Contact_Point_Consents__r),

				(SELECT Id, Name, Contact__c, Source_Field__c,
				IsPrimary, Data_Type__c, Status__c, PrimaryKey__c,
				TelephoneNumber, PhoneType, IsSMSCapable
				FROM Contact_Point_Phones__r),

				(SELECT Id, Name, Contact__c, Source_Field__c,
				IsPrimary, Data_Type__c, Status__c, PrimaryKey__c,
				EmailAddress
				FROM Contact_Point_Emails__r)

				FROM Contact
				WHERE Id IN :conIds
				AND RecordType.DeveloperName = :Outage_IncidentProcessor.CON_DCP_RT];
	}
}