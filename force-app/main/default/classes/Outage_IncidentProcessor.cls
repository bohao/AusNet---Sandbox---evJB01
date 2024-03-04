public with sharing class Outage_IncidentProcessor
{
	// *********************************************************************
	// *** Member vars
		public static final String DATAUSE_OUTAGES           = 'Outage Notifications';
		public static final String CHANNEL_SMS               = 'SMS';
		public static final String CHANNEL_EMAIL             = 'Email';
		public static final String CHANNEL_SMS_EMAIL         = 'SMS + Email';

		public static final String ACC_SERVICE_RT            = 'Service';
		public static final String CON_DCP_RT                = 'dcp_Contact';

		public static final String SYNC_MC_SYNC              = 'Sync to MC';
		public static final String SYNC_MC_SYNC_MULTI        = 'Sync to MC (Multi Incident)';
		public static final String SYNC_MC_ETA_UPD           = 'ETA Updated';
		public static final String SYNC_MC_ETR_UPD           = 'ETR Updated';
		public static final String SYNC_MC_COMPLETE          = 'Complete';

		public static final String INT_STS_IN_PROG           = 'In Progress';
		public static final String INT_STS_COMPLETE          = 'Complete';

		public static final String INCIDENT_STS_1_REPORTED   = 'Outage Reported';
		public static final String INCIDENT_STS_2_ASSESS     = 'Awaiting Assessment';
		public static final String INCIDENT_STS_3_RESPONDING = 'Responding';
		public static final String INCIDENT_STS_4_MAKE_SAFE  = 'Awaiting Construction';
		public static final String INCIDENT_STS_5_CON_SCHED  = 'Construction Scheduled';
		public static final String INCIDENT_STS_6_CON_RESP   = 'Construction Responding';
		public static final String INCIDENT_STS_7_RESTORED   = 'Restored';
		// public static final String INCIDENT_STS_8_COMPLETED  = 'Completed'; // gonski
		public static final String INCIDENT_STS_9_CANCELLED  = 'Cancelled';
		public static final String INCIDENT_STS_10_MERGED    = 'Merged';

		public static final Set<String> INCIDENT_STS_CLSD = new Set<String>
		{
			INCIDENT_STS_7_RESTORED,
			INCIDENT_STS_9_CANCELLED,
			INCIDENT_STS_10_MERGED
		};

		// public static final String AFF_NMI_PLANNED           = 'Planned';
		public static final String AFF_NMI_IN_PROG           = 'In Progress';
		public static final String AFF_NMI_RESOLVED          = 'Restored';
		public static final String AFF_NMI_MERGED            = 'Merged';
		public static final String AFF_NMI_CANCELLED         = 'Cancelled';

		public static final Set<String> AFF_NMI_STS_CLSD = new Set<String>
		{
			AFF_NMI_RESOLVED,
			AFF_NMI_MERGED,
			AFF_NMI_CANCELLED
		};

		public static final String AFF_NMI_CODE_PRED          = 'PRED'; // predicted
		public static final String AFF_NMI_CODE_COMP          = 'COMP'; // complete
		public static final String AFF_NMI_CODE_DEAD          = 'DEAD'; // dead
		public static final String AFF_NMI_CODE_DELG          = 'DELG'; // delog
		// public static final String AFF_NMI_CODE_PLAN          = 'PLAN'; // planned
		public static final String AFF_NMI_CODE_REST          = 'REST'; // restored

		public static final String DATATYPE_RETAILER          = 'Retailer';
		public static final String DATATYPE_ENHANCED          = 'Enhanced';

		// Con Point Phone/Email
		public static final String CP_STS_ACTIVE              = 'Active';
		public static final String CP_STS_DELETED             = 'Deleted';
		// public static final String CP_STS_INACTIVE            = 'Inactive';
		public static final String CP_STS_INACTIVE            = CP_STS_DELETED;
		public static final String CPP_PHONE_TYPE_HOME        = 'Home';
		public static final String CPP_PHONE_TYPE_MOBILE      = 'Mobile';

		// Con Point Consent
		public static final String CPC_STS_ACTIVE             = 'Active';
		public static final String CPC_STS_INACTIVE           = 'Inactive';
		public static final String CPC_DEFAULT_CAPTURE_SOURCE = 'Default Consent Record';
		public static final String CPC_RTL_UPD_CAPTURE_SOURCE = 'Retailer Data Update';
		public static final String CPC_ENH_UPD_CAPTURE_SOURCE = 'Customer Data Update';

		public static final Map<String, String> AFF_NMI_CODE_STATUS = new Map<String, String>
		{
			AFF_NMI_CODE_PRED => AFF_NMI_IN_PROG,
			AFF_NMI_CODE_COMP => AFF_NMI_RESOLVED,
			AFF_NMI_CODE_DEAD => AFF_NMI_IN_PROG,
			AFF_NMI_CODE_DELG => AFF_NMI_RESOLVED,
			// AFF_NMI_CODE_PLAN => AFF_NMI_PLANNED,
			AFF_NMI_CODE_REST => AFF_NMI_RESOLVED
		};

		public static final Map<String, String> AFF_NMI_STATUS_CODE = new Map<String, String>
		{
			// AFF_NMI_PLANNED   => AFF_NMI_CODE_PLAN,
			AFF_NMI_IN_PROG   => AFF_NMI_CODE_DEAD,
			AFF_NMI_RESOLVED  => AFF_NMI_CODE_REST,
			AFF_NMI_MERGED    => AFF_NMI_CODE_COMP,
			AFF_NMI_CANCELLED => AFF_NMI_CODE_COMP
		};

		public static final String AFF_NMI_MATCH           = 'NMI Matched';
		public static final String AFF_NMI_NO_NMI          = 'NMI Not Matched';
		public static final String AFF_NMI_CUST_MATCH      = 'Customer Matched';
		public static final String AFF_NMI_NO_CUST         = 'Customer Not Matched: None Found';
		public static final String AFF_NMI_MULTI_CUST      = 'Customer Not Matched: Multiple Found';
		public static final String AFF_NMI_DUPE_CUST       = 'Customer Matched: Already On Incident';
		public static final String AFF_NMI_NMI_MERGED      = 'Customer Merged From ';

		public static final String AFF_NMI_SINGLE_INC      = 'Single Incident';
		public static final String AFF_NMI_MULTI_INC_1     = 'Multi-Incident (First)';
		public static final String AFF_NMI_MULTI_INC_2     = 'Multi-Incident (Subsequent)';

		public static final Set<String> AFF_NMI_MULTI_INCS = new Set<String>
		{
			AFF_NMI_MULTI_INC_1,
			AFF_NMI_MULTI_INC_2
		};

		public static final String AFF_CUST_INC_SYNC_SYNCD = 'Synchronised';
		public static final String AFF_CUST_INC_SYNC_OOS   = 'Out of Sync';

		public static final String AFF_CUST_TYPE_PRIM      = 'Primary Contact';
		public static final String AFF_CUST_TYPE_SEC       = 'Secondary Contact';

		public static final String INC_NOTIFS_AUTO         = 'Automated';
		public static final String INC_NOTIFS_DISABLED     = 'Disabled';

		public static final String SERV_POINT_ORIG         = 'Original';
		public static final String SERV_POINT_DUPE         = 'Duplicate';
		public static final String SERV_POINT_STS_ACTIVE   = 'Connected';
		public static final String SERV_POINT_STS_INACTIVE = 'Inactive';

		public static final String ACR_ROLE_MKT_CON        = 'Market Contact';
		public static final String ACR_ROLE_SEC_CON        = 'Secondary Contact';

		public static final String LSC_TASK_QUEUE_NAME     = 'LSC_Wellbeing_Check';
		public static final String LSC_TASK_RT_NAME        = 'LSC_Wellbeing_Check';

		public static final String FAKE_MOBILE_NUM         = '0491570156';

		// not final vars:
		public static Boolean isRunningCreateAffCust  = false;
		public static Boolean isRunningUpdateMultiInc = false;

		// Run settings
		public static Boolean enableFutures          = false;
		public static Boolean enableFutureMultiInc   = true;
		public static Boolean vcDebug                = false;
	// ***


	// *********************************************************************
	// *** Private vars
	private static Integer QUERY_LIMIT = 5000; // I've removed final so test coverage can alter this value
	private static Integer FIRST_QUERY_LIMIT = 100;

	// *********************************************************************
	// *** No constructor


	// *********************************************************************
	// *** Static Methods

	// *******************
	// * From Affected NMI

	// AffNMICreateAffCust profile:
	// Runs in after context
	// 4 SOQLs
	// 3 DMLs
	public static String AffNMICreateAffCust(List<Affected_Market_Identifier__c> AffNMIs)
	{
		UtilDebug de = newUOMDebug();
		de.bug('*** Outage_IncidentProcessor.AffNMICreateAffCust', true);

		// Set isRunningCreateAffCust to false?
		if (isRunningCreateAffCust)
		{
			// override
			de.bug('* Override: Setting isRunningCreateAffCust to false.');
			de.bug('Must be using Bulk API?');
			isRunningCreateAffCust = false;
		}

		Map<String, Affected_Market_Identifier__c> mapAffNMIsByNMI = new Map<String, Affected_Market_Identifier__c>();
		Set<Id> IncidentIds = new Set<Id>();
		Set<String> IncidentNMIs = new Set<String>();
		de.bug('Num AffNMIs: ' + AffNMIs.size());

		// get NMI numbers, Incident Ids
		for (Affected_Market_Identifier__c AffNMI: AffNMIs)
		{
			if (mapAffNMIsByNMI.containsKey(AffNMI.Name))
			{
				// Unlikely to occur - may cause issues due to mapAffNMIsByNMI map values being overridden
				de.bug('Duplicate mapAffNMIsByNMI key found - NMI exists in two occurrences', true);
			}

			// Note:
				// uom_Unique_Market_Identifier__c is the Incident-NMI key
				// Name is the NMI number
			mapAffNMIsByNMI.put(AffNMI.Name, AffNMI.clone(true, false, true, true));
			mapAffNMIsByNMI.get(AffNMI.Name).NMI_Match_Outcome__c = AFF_NMI_NO_NMI; // set default value
			IncidentIds.add(AffNMI.uom_Incident__c);
			IncidentNMIs.add(AffNMI.uom_Incident__c + ' - ' + AffNMI.Name);
		}
		de.bug('Num mapAffNMIsByNMI: ' + mapAffNMIsByNMI.size());
		de.bug('Num IncidentIds: ' + IncidentIds.size());

		de.bug('Incidents: \n' + JSON.serializePretty(IncidentIds));
		de.bug('NMIs: \n' + JSON.serializePretty(IncidentNMIs));

		List<Affected_Customer__c>          insAffCusts = new List<Affected_Customer__c>();
		List<Affected_Market_Identifier__c> updAffNMIs  = new List<Affected_Market_Identifier__c>();

		// Get incident data
		Map<Id, Incident> mapIncidents = new Map<Id, Incident>();
		Map<Id, Set<Id>>  incidentContactIds = new Map<Id, Set<Id>>();

		for (Incident i: [SELECT Id, IncidentNumber, uom_Incident_Id__c, Status,
						  uom_Estimated_assessment_date__c, uom_Estimated_restoration_date__c
						  FROM Incident
						  WHERE Id IN :IncidentIds])
		{
			mapIncidents.put(i.Id, i);

			if (!incidentContactIds.containsKey(i.Id))
				incidentContactIds.put(i.Id, new Set<Id>());
		}
		de.bug('Num mapIncidents: ' + mapIncidents.size());

		// get the affected customers for reparenting in merged scenarios
		// The logic here is:
		//    When an Affected NMI is added to an Incident (eg: Inc-2)
		//    See if there's a pre-existing Affected Customer record on another Incident (eg: Inc-1)
		//        where Status=Merged and Merged_Incident_Id=Inc-2 and NMI Num matches new Affected NMI Num.
		//    If yes, reparent the Aff Customer to this new Incident (instead of creating new Affected Customer)
		List<Affected_Customer__c> affectedCustomersToUpdate = new List<Affected_Customer__c>();
		Set<String> removeAffNMIFromMapSet = new Set<String>();
		for (Affected_Customer__c affCus: [SELECT Id, Name, uom_Incident__c, uom_Incident_Status__c, uom_Aff_NMI_Status__c, NMI__c, uom_Affected_Market_Identifier__c,
										   uom_Estimated_assessment_date__c, uom_Estimated_restoration_date__c, uom_Incident__r.Merged_Incident_Id__c, uom_Incident__r.uom_Incident_Id__c,

										   uom_Affected_Market_Identifier__r.uom_Service_Point__c,
										   uom_Affected_Market_Identifier__r.uom_Service_Account__c,
										   uom_Affected_Market_Identifier__r.NMI_Match_Outcome__c,
										   uom_Affected_Market_Identifier__r.NMI_Match_Note__c

										   FROM Affected_Customer__c
										   WHERE NMI__c IN :mapAffNMIsByNMI.keySet()
										   AND uom_Incident__r.Status = :INCIDENT_STS_10_MERGED
										   AND uom_Affected_Market_Identifier__r.uom_Status__c = :AFF_NMI_MERGED])
		{

			if (!mapAffNMIsByNMI.containsKey(affCus.NMI__c))
			{
				de.bug('Affected Market Identifier ['+affCus.NMI__c+']: Key not found in map. Skipping...', true);
				continue;
			}

			Affected_Market_Identifier__c AffNMI = mapAffNMIsByNMI.get(affCus.NMI__c);
			Incident incident = mapIncidents.get(AffNMI.uom_Incident__c);

			if (affCus.uom_Incident__r.Merged_Incident_Id__c != incident.uom_Incident_Id__c)
			{
				de.bug('Merged_Incident_Id__c ['+affCus.uom_Incident__r.Merged_Incident_Id__c+']: Does not match the uom_Incident_Id__c ['+incident.uom_Incident_Id__c+']. Skipping...', true);
				continue;
			}

			de.bug('Found customer to merge: ' + affCus.Id + ' ['+affCus.NMI__c+']');

			// Reparent the Affected Customer
			affCus.uom_Incident__c = AffNMI.uom_Incident__c;
			affCus.uom_Affected_Market_Identifier__c = AffNMI.Id;

			// Update the Affected Customer's statuses to the new Incident / Affected Market Identifier statuses
			affCus.uom_Aff_NMI_Status__c = AffNMI.uom_Status__c;
			affCus.uom_Incident_Status__c = incident.Status;

			// Update the Affected Customer's ETA and ETR dates to the new Incident ETA and ETR dates
			affCus.uom_Estimated_assessment_date__c = incident.uom_Estimated_assessment_date__c;
			affCus.uom_Estimated_restoration_date__c = incident.uom_Estimated_restoration_date__c;

			// Flag it so we don't create customer
			AffNMI.NMI_Match_Note__c = AFF_NMI_NMI_MERGED + affCus.uom_Incident__r.uom_Incident_Id__c;

			affectedCustomersToUpdate.add(affCus);
			removeAffNMIFromMapSet.add(AffNMI.Name);
		}

		if (!affectedCustomersToUpdate.isEmpty())
		{
			update affectedCustomersToUpdate;
			de.bug(affectedCustomersToUpdate.size() + ' Affected Customer records reparented.', true);

			// Remove the new Affected Market Identifiers from the map to prevent the creation of new Affected Customers after reparenting has occured
			// for (String mapKey : removeAffNMIFromMapSet) {
			// 	mapAffNMIsByNMI.remove(mapKey);
			// }
		}

		// ** Find/match NMIs
		de.bug('Find/match NMIs');

		Integer numServPoint = 0;
		for (vlocity_cmt__ServicePoint__c ServPoint: [SELECT Id, Name, vlocity_cmt__MarketIdentifier__c
													  FROM vlocity_cmt__ServicePoint__c
													  WHERE vlocity_cmt__MarketIdentifier__c IN :mapAffNMIsByNMI.keySet()
													  AND dcp_NMIStatus_To_Date__c = null
													  AND Data_Duplication__c = :SERV_POINT_ORIG])
		{
			// get the market identifier for this ServPoint record
			String NMI_num = ServPoint.vlocity_cmt__MarketIdentifier__c;
			Affected_Market_Identifier__c AffNMI = mapAffNMIsByNMI.get(NMI_num);
			AffNMI.uom_Service_Point__c   = ServPoint.Id;
			AffNMI.NMI_Match_Outcome__c   = AFF_NMI_MATCH;

			numServPoint++;
		}
		de.bug('Num ServPoints: ' + numServPoint);

		// Find/match customers
		List<Account> queriedAccounts = new List<Account>();
		Set<Id>       contactIds      = new Set<Id>();

		for (Account acc : [SELECT Id, Name, RecordType.Name,

							vlocity_cmt__PrimaryContactId__c, vlocity_cmt__PrimaryContactId__r.Name,
							vlocity_cmt__PrimaryContactId__r.Email, vlocity_cmt__PrimaryContactId__r.MobilePhone, vlocity_cmt__PrimaryContactId__r.Phone,
							vlocity_cmt__PrimaryContactId__r.CE_Email_Address__c, vlocity_cmt__PrimaryContactId__r.CE_Phone_Number__c,

							Market_Identifier__r.vlocity_cmt__MarketIdentifier__c,
							vlocity_cmt__PremisesId__c, vlocity_cmt__PremisesId__r.Name,
							vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c,
							vlocity_cmt__PremisesId__r.vlocity_cmt__City__c,
							Contact_Matched__c, ShippingStreet, ShippingCity,

							(SELECT Id, ContactId, Contact.Name,
							Contact.CE_Email_Address__c, Contact.CE_Phone_Number__c,
							toLabel(Roles)
							FROM AccountContactRelations WHERE Roles = :ACR_ROLE_SEC_CON)

							FROM Account
							WHERE Recordtype.Name = :ACC_SERVICE_RT
							AND Market_Identifier__r.vlocity_cmt__MarketIdentifier__c IN :mapAffNMIsByNMI.keySet()
							AND Market_Identifier__r.vlocity_cmt__ServiceType__c = 'Electricity'
							AND Market_Identifier__r.dcp_NMIStatus_To_Date__c = null
							AND Market_Identifier__r.Data_Duplication__c = :SERV_POINT_ORIG
							AND Contact_Matched__c = :Outage_AccountContactUtils.CON_MATCHED_FOUND])
		{
			queriedAccounts.add(acc);
			contactIds.add(acc.vlocity_cmt__PrimaryContactId__c);

			if (!acc.AccountContactRelations.isEmpty())
			{
				de.bug('Secondary Contacts found for Account: ' + acc.Id);
				for (AccountContactRelation acr: acc.AccountContactRelations)
				{
					contactIds.add(acr.ContactId);
				}
			}
		}
		de.bug('Num Accs: ' + queriedAccounts.size());

		// Get pre-existing contacts, limited for bulk compatibility
		Integer numAffCusts = 0;
		for (Affected_Customer__c affCust: [SELECT Id, Name, uom_Contact__c, uom_Incident__c
											FROM Affected_Customer__c
											WHERE uom_Incident__c IN :IncidentIds
											AND uom_Contact__c IN :contactIds])
		{
			Id incId = affCust.uom_Incident__c;

			if (!incidentContactIds.containsKey(incId))
				incidentContactIds.put(incId, new Set<Id>());

			incidentContactIds.get(incId).add(affCust.uom_Contact__c);
			numAffCusts++;
		}
		de.bug('Num AffCusts: ' + numAffCusts + '\n');

		// Find/match customers
		for (Account acc : queriedAccounts)
		{
			de.bug('Account: ' + acc.Id);

			// get the market identifier for this AccountContactRelation record
			String NMI_num = acc.Market_Identifier__r.vlocity_cmt__MarketIdentifier__c;
			Affected_Market_Identifier__c AffNMI = mapAffNMIsByNMI.get(NMI_num);
			Incident inc = mapIncidents.get(AffNMI.uom_Incident__c);

			de.bug('NMI: ' + NMI_num);
			de.bug('Incident : ' + inc.uom_Incident_Id__c);

			Boolean wasMerged = false;
			if (AffNMI.NMI_Match_Note__c != null && AffNMI.NMI_Match_Note__c.startsWith(AFF_NMI_NMI_MERGED))
			{
				wasMerged = true;
				de.bug('** ' + AffNMI.NMI_Match_Note__c);
			}

			if (AffNMI.uom_Service_Account__c != null && AffNMI.uom_Service_Account__c != acc.Id)
			{
				// If we've already matched this AffNMI with a different Service account
				// (means multiple customers found.)
				AffNMI.NMI_Match_Outcome__c = AFF_NMI_MULTI_CUST;
				de.bug('NMI_Match_Outcome__c: ' + AffNMI.NMI_Match_Outcome__c);
				continue;
			}

			// set the service account
			AffNMI.uom_Service_Account__c = acc.Id;
			AffNMI.NMI_Match_Outcome__c   = AFF_NMI_CUST_MATCH;
			if (AffNMI.NMI_Match_Note__c == null) AffNMI.NMI_Match_Note__c = '';

			// Street and Suburb
			String CustomerStreet = stripStreetDetails(acc.vlocity_cmt__PremisesId__r.vlocity_cmt__StreetAddress__c);
			String CustomerSuburb = acc.vlocity_cmt__PremisesId__r.vlocity_cmt__City__c?.trim();

			if (CustomerSuburb != null)
				CustomerStreet = CustomerStreet?.removeEndIgnoreCase(CustomerSuburb)?.trim();

			// Check if this Affected NMI was part of a Merge Operation
			// If yes - we don't want to create a customer on it.
			if (wasMerged)
			{
				// TODO
				// Affected NMI was part of a Merge Operation
				// skip creation of the affected customer
				de.bug('* Affected NMI was part of a Merge Operation', true);
				de.bug('Skipping Aff Customer record creation...', true);

				// record outcome
				// AffNMI.NMI_Match_Outcome__c = AFF_NMI_DUPE_CUST;
				// AffNMI.NMI_Match_Note__c += AFF_NMI_NMI_MERGED + affCus.uom_Incident__c.uom_Incident_Id__c + '\n';
				de.bug('NMI_Match_Outcome__c: ' + AffNMI.NMI_Match_Outcome__c);
				de.bug(AffNMI.NMI_Match_Note__c);
			}

			// Check if this Contact is already an affected customer on this incident?
			else if (incidentContactIds.containsKey(inc.Id) &&
					 incidentContactIds.get(inc.Id).contains(acc.vlocity_cmt__PrimaryContactId__c))
			{
				// contact already on this Incident - probably because of a separate NMI? Or maybe secondary contact
				// skip creation of the affected customer?
				de.bug('* Customer Contact already on this Incident record: ' + acc.vlocity_cmt__PrimaryContactId__c, true);
				de.bug('Skipping Aff Customer record creation...', true);

				// record outcome
				AffNMI.NMI_Match_Outcome__c = AFF_NMI_DUPE_CUST;
				AffNMI.NMI_Match_Note__c += 'Primary Contact already on this Incident ['+acc.vlocity_cmt__PrimaryContactId__c+']\n';
				de.bug('NMI_Match_Outcome__c: ' + AffNMI.NMI_Match_Outcome__c);
				de.bug(AffNMI.NMI_Match_Note__c);
			}
			else
			{
				// note: customer prefs is/was on Affected_Customer__c trigger
					// We set it below for the insert op, update will run on trigger as normal

				// create a new Affected_Customer__c record using data from the AccountContactRelation record and
				// the corresponding Affected_Market_Identifier__c record in the map
				de.bug('Creating new Primary Aff Customer...');
				de.bug('Primary Contact: ' + acc.vlocity_cmt__PrimaryContactId__c);

				insAffCusts.add(
					new Affected_Customer__c(
						// Customer fields
						Name = acc.vlocity_cmt__PrimaryContactId__r.Name.abbreviate(75),
						uom_Contact__c = acc.vlocity_cmt__PrimaryContactId__c,
						uom_Customer_Street__c = CustomerStreet,
						uom_Customer_Suburb__c = CustomerSuburb,
						Customer_Type__c = AFF_CUST_TYPE_PRIM,

						// Aff NMI fields
						uom_Affected_Market_Identifier__c = AffNMI.Id,
						uom_Incident__c                   = AffNMI.uom_Incident__c,
						uom_Aff_NMI_Status__c             = AffNMI.uom_Status__c,

						// Incident fields
						uom_Estimated_assessment_date__c  = inc.uom_Estimated_assessment_date__c,
						uom_Estimated_restoration_date__c = inc.uom_Estimated_restoration_date__c,
						uom_Incident_Status__c            = inc.Status
				));

				incidentContactIds.get(inc.Id).add(acc.vlocity_cmt__PrimaryContactId__c);
			}


			// Check for secondary contacts
			de.bug('Check for secondary contacts');
			if (!wasMerged && !acc.AccountContactRelations.isEmpty())
			{
				for (AccountContactRelation acr: acc.AccountContactRelations)
				{
					if (incidentContactIds.containsKey(inc.Id) &&
						incidentContactIds.get(inc.Id).contains(acr.ContactId))
					{
						// contact already on this Incident - probably because of a separate NMI?
						// skip creation of the affected customer?
						de.bug('* Customer Contact already on this Incident record: ' + acr.ContactId, true);
						de.bug('Skipping Aff Customer record creation...', true);

						// AffNMI.NMI_Match_Outcome__c = AFF_NMI_DUPE_CUST; // only for primary
						AffNMI.NMI_Match_Note__c += 'Secondary Contact already on this Incident ['+acr.ContactId+']\n';
					}
					else
					{
						de.bug('Creating new Secondary Aff Customer...');
						de.bug('Secondary Contact: ' + acr.ContactId);
						insAffCusts.add(
							new Affected_Customer__c(
								// Customer fields
								Name = acr.Contact.Name.abbreviate(75),
								uom_Contact__c = acr.ContactId,
								uom_Customer_Street__c = CustomerStreet,
								uom_Customer_Suburb__c = CustomerSuburb,
								Customer_Type__c = AFF_CUST_TYPE_SEC,

								// Aff NMI fields
								uom_Affected_Market_Identifier__c = AffNMI.Id,
								uom_Incident__c                   = AffNMI.uom_Incident__c,
								uom_Aff_NMI_Status__c             = AffNMI.uom_Status__c,

								// Incident fields
								uom_Estimated_assessment_date__c  = inc.uom_Estimated_assessment_date__c,
								uom_Estimated_restoration_date__c = inc.uom_Estimated_restoration_date__c,
								uom_Incident_Status__c            = inc.Status
						));

						incidentContactIds.get(inc.Id).add(acr.ContactId);
					}
				}
			}

			if (AffNMI.NMI_Match_Note__c == '') AffNMI.NMI_Match_Note__c = null;
			de.bug('');
		}

		// Get customer preferences, email and phone nums
		de.bug('setCustomerPreferences');
		de.bug('isRunningCreateAffCust: ' + isRunningCreateAffCust);

		Trig_AffectedCustomer.setCustomerPreferences(insAffCusts, de);

		// For the secondary contacts, find and remove dupe email and phone nums
		de.bug('Secondary contacts dedupe');
		Map<Id, Set<String>> nmiEndpoints = new Map<Id, Set<String>>();

		// Grab Primary Customer endpoints
		for (Affected_Customer__c affCust: insAffCusts)
		{
			Id AffNMIId = affCust.uom_Affected_Market_Identifier__c;

			if (!nmiEndpoints.containsKey(AffNMIId))
				nmiEndpoints.put(AffNMIId, new Set<String>());

			if (affCust.Notification_Pref__c == null) continue;
			if (affCust.Customer_Type__c != AFF_CUST_TYPE_PRIM) continue;

			// de.bug('Primary Affected Customer:' + affCust.Id);

			// Primary customer: add endpoints to map
			if (affCust.Notification_Pref__c.contains(CHANNEL_SMS))
				nmiEndpoints.get(AffNMIId).add(affCust.Phone__c);

			if (affCust.Notification_Pref__c.contains(CHANNEL_EMAIL))
				nmiEndpoints.get(AffNMIId).add(affCust.Email__c);
		}

		for (Affected_Customer__c affCust: insAffCusts)
		{
			Id AffNMIId = affCust.uom_Affected_Market_Identifier__c;

			if (affCust.Notification_Pref__c == null) continue;
			if (affCust.Customer_Type__c != AFF_CUST_TYPE_SEC) continue;

			de.bug('Secondary Affected Customer:' + affCust.Id);

			// Secondary customer: check map for dupe endpoints
			Set<String> endpoints = nmiEndpoints.get(AffNMIId);
			affCust.Notif_Duplication_Note__c = '';

			if (affCust.Notification_Pref__c.contains(CHANNEL_SMS))
			{
				if (endpoints.contains(affCust.Phone__c))
				{
					// remove it and note the reason
					de.bug('Removing duplicate endpoint: Phone');
					affCust.Phone__c = null;
					affCust.Notif_Duplication_Note__c += 'Phone number omitted; already in use on this Incident/NMI.\n';
				}
				else
				{
					endpoints.add(affCust.Phone__c);
				}
			}

			if (affCust.Notification_Pref__c.contains(CHANNEL_EMAIL))
			{
				if (endpoints.contains(affCust.Email__c))
				{
					// remove it and note the reason
					de.bug('Removing duplicate endpoint: Email');
					affCust.Email__c = null;
					affCust.Notif_Duplication_Note__c += 'Email address omitted; already in use on this Incident/NMI.\n';
				}
				else
				{
					endpoints.add(affCust.Email__c);
				}
			}

			if (affCust.Notif_Duplication_Note__c == '') affCust.Notif_Duplication_Note__c = null;

			// update Notification_Pref__c
			affCust.Notification_Pref__c = null;
			if (affCust.Phone__c != null && affCust.Email__c != null)
				affCust.Notification_Pref__c = CHANNEL_SMS_EMAIL;
			else if (affCust.Phone__c != null)
				affCust.Notification_Pref__c = CHANNEL_SMS;
			else if (affCust.Email__c != null)
				affCust.Notification_Pref__c = CHANNEL_EMAIL;
		}

		// If NMI is left as NMI Matched status, change to No Customers found.
		for (Affected_Market_Identifier__c AffNMI: mapAffNMIsByNMI.values())
		{
			if (AffNMI.NMI_Match_Outcome__c == AFF_NMI_MATCH)
				AffNMI.NMI_Match_Outcome__c = AFF_NMI_NO_CUST;
		}

		de.bug('!! Setting isRunningCreateAffCust to true.');
		isRunningCreateAffCust = true;
		if (!mapAffNMIsByNMI.isEmpty()) update mapAffNMIsByNMI.values();
		if (!insAffCusts.isEmpty()) insert insAffCusts;

		de.bug('* END: Outage_IncidentProcessor.AffNMICreateAffCust. OK');
		de.bugSend();
		return 'OK';
	}

	// * From Affected NMI
	// AffNMIUpdAffCust profile:
	// Runs in after context
	// 1 SOQLs
	// 1 DMLs
	public static String AffNMIUpdAffCust(Map<Id, Affected_Market_Identifier__c> oldAffNMIs, Map<Id, Affected_Market_Identifier__c> newAffNMIs)
	{
		System.debug('*** Outage_IncidentProcessor.AffNMIUpdAffCust');

		if (isRunningCreateAffCust)
		{
			System.debug('Do nothing: This thread is from createAffectedCustomer.');
			return 'OK: Nothing to do.';
		}

		// Logic
			// For the affected NMI
			// update the linked affected Customer
			//
			// I guess all we need here is the Status field?
			// Since most (all?) updates come from the parent field


		// ** Qualify
		Set<Id> AffNMIIds = new Set<Id>();

		for (Affected_Market_Identifier__c newNMI: newAffNMIs.values())
		{
			Affected_Market_Identifier__c oldNMI = oldAffNMIs.get(newNMI.Id);

			// has status changed?
			if (oldNMI.uom_Status__c != newNMI.uom_Status__c)
				AffNMIIds.add(newNMI.Id);
		}

		if (AffNMIIds.isEmpty())
		{
			System.debug('Do nothing: Status values have not changed.');
			return 'OK: Nothing to do.';
		}

		// ** Execute

		// Get Affected Customers
		List<Affected_Customer__c> updateAffCust = new List<Affected_Customer__c>();

		for (Affected_Customer__c cust: [SELECT Id, Name, uom_Aff_NMI_Status__c, uom_Affected_Market_Identifier__c, uom_Incident__c,
										 MC_Sync__c, MC_Sync_History__c, Incident_Notifications__c, Multi_Incident__c
										 FROM Affected_Customer__c
										 WHERE uom_Affected_Market_Identifier__c IN :newAffNMIs.keySet()])
		{
			Affected_Market_Identifier__c newNMI = newAffNMIs.get(cust.uom_Affected_Market_Identifier__c);
			CustomerUpdate CustUpdate = new CustomerUpdate(cust);

			if (cust.uom_Aff_NMI_Status__c != newNMI.uom_Status__c)
			{
				CustUpdate.updateNMIStatus(newNMI.uom_Status__c);
			}

			if (CustUpdate.reqsRecordUpdate())
			{
				CustUpdate.runUpdateNMIStatus();
				updateAffCust.add(CustUpdate.affCustomer);
			}
		}

		if (updateAffCust.isEmpty())
		{
			System.debug('Do nothing: Status values already correct (or no Affected Customers found.)');
			return 'OK: Nothing to do.';
		}

		update updateAffCust;
		return 'OK: ' + updateAffCust.size() + ' records updated.';
	}


	// * From Affected NMI
	// insertCheckNMIMultiIncident profile:
	// Runs in before insert context
	// 1 SOQLs
	// 1 DMLs
	public static void insertCheckNMIMultiIncident(List<Affected_Market_Identifier__c> affNMIs)
	{
		if (affNMIs == null || affNMIs.isEmpty())
			return;

		System.debug('* Outage_IncidentProcessor.insertCheckNMIMultiIncident');

		// get the NMIs and then query for other Affected NMIs where incident is open and NMI matches

		// if matches found
			// set the first one to primary
			// set the subsequent ones to secondary

		// Get the NMIs for querying...
		Map<String, List<Affected_Market_Identifier__c>> NMIs = new Map<String, List<Affected_Market_Identifier__c>>();
		for (Affected_Market_Identifier__c affNMI: affNMIs)
		{
			if (affNMI.Name == null) continue;
			if (affNMI.uom_Status__c != AFF_NMI_IN_PROG) continue;

			if (affNMI.Name.length() == 10)
			{
				// fix it
				affNMI.Name = Outage_NMITools.getNMI11(affNMI.Name);
			}

			if (!NMIs.containsKey(affNMI.Name))
				NMIs.put(affNMI.Name, new List<Affected_Market_Identifier__c>());
		}

		// Run the query, get any matching NMIs
		for (Affected_Market_Identifier__c affNMI: [SELECT Id, Name, Multi_Incident__c
													FROM Affected_Market_Identifier__c
													WHERE uom_Service_Point__r.vlocity_cmt__MarketIdentifier__c IN :NMIs.keySet()
													AND uom_Status__c = :AFF_NMI_IN_PROG
													ORDER BY Name ASC, CreatedDate ASC])
		{
			if (!NMIs.containsKey(affNMI.Name))
				NMIs.put(affNMI.Name, new List<Affected_Market_Identifier__c>());

			NMIs.get(affNMI.Name).add(affNMI);
		}

		// Add the triggered records to the matched NMIs map.
		for (Affected_Market_Identifier__c affNMI: affNMIs)
		{
			if (affNMI.Name == null) continue;
			if (affNMI.uom_Status__c != AFF_NMI_IN_PROG) continue;

			if (!NMIs.containsKey(affNMI.Name))
				NMIs.put(affNMI.Name, new List<Affected_Market_Identifier__c>());

			NMIs.get(affNMI.Name).add(affNMI);
		}

		// This map/list should now be sorted into
			// existing Aff NMIs, from oldest to newest,
			// then the triggered records (new NMIs)

		// Process the lists.....
		List<Affected_Market_Identifier__c> updAffNMIs = new List<Affected_Market_Identifier__c>();

		for (String nmi: NMIs.keySet())
		{
			if (NMIs.get(nmi).isEmpty())
			{
				// strange error
				System.debug('NMIs.get(nmi).isEmpty()');
				System.debug('nmi: ' + nmi);
				continue;
			}

			updAffNMIs.addAll(setMultiIncidents(NMIs.get(nmi)));
		}

		isRunningUpdateMultiInc = true;
		if (!updAffNMIs.isEmpty()) update updAffNMIs;
	}

	// * From Affected NMI
	// updateCheckNMIMultiIncident profile:
	// Runs in before update context
	// 0 SOQLs
	// 0 DMLs
	// 1 future
	public static void updateCheckNMIMultiIncident(List<Affected_Market_Identifier__c> newAffNMIs, Map<Id, Affected_Market_Identifier__c> oldAffNMIs)
	{
		if (newAffNMIs == null || newAffNMIs.isEmpty())	return;
		if (isRunningUpdateMultiInc) return;

		System.debug('* Outage_IncidentProcessor.updateCheckNMIMultiIncident');

		// If a NMI is restored and is multi-mode, then recheck the list.
		Set<String> AffNMINumbers = new Set<String>();

		for (Affected_Market_Identifier__c newAffNMI: newAffNMIs)
		{
			Affected_Market_Identifier__c oldAffNMI = oldAffNMIs.get(newAffNMI.Id);

			if (newAffNMI.Name.length() == 10)
			{
				// fix it
				newAffNMI.Name = Outage_NMITools.getNMI11(newAffNMI.Name);
			}

			if (newAffNMI.uom_Status__c != oldAffNMI.uom_Status__c &&  // If status is changed, and
				AFF_NMI_STS_CLSD.contains(newAffNMI.uom_Status__c))    // and new status is a closed status.
			{
				// Is it in multi mode?
				if (AFF_NMI_MULTI_INCS.contains(newAffNMI.Multi_Incident__c))
				{
					// qualified - let's recheck the list.
					AffNMINumbers.add(newAffNMI.Name);
				}

				// // clear the flag, since it's closed (don't want to count it any more.)
				// newAffNMI.Multi_Incident__c = null;
			}
			else if (newAffNMI.uom_Status__c != oldAffNMI.uom_Status__c && // If status is changed, and
					AFF_NMI_STS_CLSD.contains(oldAffNMI.uom_Status__c)  && // prior status is closed, and(aka from closed to open)
					!AFF_NMI_STS_CLSD.contains(newAffNMI.uom_Status__c))   // new status is open (aka from closed to open)
			{
				AffNMINumbers.add(newAffNMI.Name);
			}
			else if (newAffNMI.Multi_Incident__c == 'Recheck')
			{
				// qualified - let's recheck the list.
				AffNMINumbers.add(newAffNMI.Name);

				// if (AFF_NMI_STS_CLSD.contains(newAffNMI.uom_Status__c))
				// 	newAffNMI.Multi_Incident__c = null;
			}
		}

		if (AffNMINumbers.isEmpty()) return;
		// System.debug(JSON.serializePretty(AffNMINumbers));

		// run future here
		// debugLimits();
		if (enableFutureMultiInc)
		{
			System.debug('* running update in future...');
			fUpdateNMIMultiIncident(AffNMINumbers);
		}
		else
		{
			System.debug('* running update in same thread...');
			updateNMIMultiIncident(AffNMINumbers);
		}
	}

	// * From Affected NMI
	// fUpdateNMIMultiIncident profile:
	// Runs in future context
	// 1 SOQLs
	// 1 DMLs
	@future
	public static void fUpdateNMIMultiIncident(Set<String> AffNMINumbers)
	{
		updateNMIMultiIncident(AffNMINumbers);
	}

	public static void updateNMIMultiIncident(Set<String> AffNMINumbers)
	{
		System.debug('* Outage_IncidentProcessor.fUpdateNMIMultiIncident');
		if (AffNMINumbers == null || AffNMINumbers.isEmpty()) return;

		Map<String, List<Affected_Market_Identifier__c>> NMIs = new Map<String, List<Affected_Market_Identifier__c>>();

		// Run the query, get any matching NMIs
		// List<Affected_Market_Identifier__c> updAffNMIs = new List<Affected_Market_Identifier__c>();
		UtilDatabase db = new UtilDatabase();

		for (Affected_Market_Identifier__c affNMI: [SELECT Id, Name, Multi_Incident__c, uom_Status__c
													FROM Affected_Market_Identifier__c
													WHERE uom_Service_Point__r.vlocity_cmt__MarketIdentifier__c IN :AffNMINumbers
													//AND uom_Status__c = :AFF_NMI_IN_PROG
													ORDER BY Name ASC, CreatedDate ASC])
		{
			if (affNMI.Name.length() == 10)
				affNMI.Name = Outage_NMITools.getNMI11(affNMI.Name);

			if (affNMI.uom_Status__c != AFF_NMI_IN_PROG)
			{
				if (affNMI.Multi_Incident__c != null)
				{
					affNMI.Multi_Incident__c = null;
					db.addObjForUpsert(affNMI);
				}
				continue;
			}

			if (!NMIs.containsKey(affNMI.Name))
				NMIs.put(affNMI.Name, new List<Affected_Market_Identifier__c>());

			NMIs.get(affNMI.Name).add(affNMI);
		}

		// This map/list should now be sorted into
			// existing In Progress Aff NMIs, from oldest to newest

		// Process the lists.....

		for (String nmi: NMIs.keySet())
		{
			if (NMIs.get(nmi).isEmpty())
			{
				// strange error
				System.debug('NMIs.get(nmi).isEmpty()');
				System.debug('nmi: ' + nmi);
				continue;
			}

			for (Affected_Market_Identifier__c affNMI: setMultiIncidents(NMIs.get(nmi)))
				db.addObjForUpsert(affNMI);
		}

		isRunningUpdateMultiInc = true;
		db.upsertObjs();
	}


	// ***************
	// * From Incident

	// incidentUpdAffCustomers profile:
	// Runs in after context
	// 0 SOQLs
	// 0 DMLs
	public static String incidentUpdAffCustomers(Map<Id, Incident> oldIncidents, Map<Id, Incident> newIncidents)
	{
		System.debug('*** Outage_IncidentProcessor.incidentUpdAffCustomers');

		// Check if ETA, ETR or Status has changed on an Incident
		// then update the linked Affected Customer records as appropriate

		// If the Integration Status == In Progress, leave them alone.
			// If Complete, update
			// If null, update ???

		Map<Id, IncidentUpdate> incUpdates = new Map<Id, IncidentUpdate>();
		Integer nmiCount = 0;

		// Get nmi count per incident
		for (Incident newInc: newIncidents.values())
		{
			if (newInc.Integration_Status__c == INT_STS_IN_PROG)
			{
				System.debug('Incident ['+newInc.Id+']: Integration In Progress. Skipping...');
				continue;
			}

			IncidentUpdate incUpd = new IncidentUpdate(newInc);
			incUpdates.put(incUpd.incidentId, incUpd);
		}

		if (incUpdates.isEmpty())
		{
			System.debug('Do nothing: No updates required.');
			return 'OK: Nothing to do.';
		}

		for (AggregateResult ar: [SELECT COUNT(Id) counter, uom_Incident__c
								 FROM Affected_Market_Identifier__c
								 WHERE uom_Incident__c IN :incUpdates.keySet()
								 GROUP BY uom_Incident__c])
		{
			Integer counter = (Integer)ar.get('counter');
			Id      incId   = (Id)ar.get('uom_Incident__c');

			if (!incUpdates.containsKey(incId)) continue;

			incUpdates.get(incId).numNMIs = counter;
		}

		for (Incident newInc: newIncidents.values())
		{
			if (newInc.Integration_Status__c == INT_STS_IN_PROG)
				continue;

			Incident oldInc = oldIncidents.get(newInc.Id);
			IncidentUpdate incUpd = incUpdates.get(newInc.Id);
			Integer numNMIs = incUpd.numNMIs;

			Boolean integrationStatusComplete = (newInc.Integration_Status__c == INT_STS_COMPLETE);

			// has status/ETA/ETR changed?
			if (oldInc.Status != newInc.Status)
				incUpd.incStatusUpdated = true;

			if (oldInc.uom_Estimated_assessment_date__c != newInc.uom_Estimated_assessment_date__c)
				incUpd.etaUpdated = true;

			if (oldInc.uom_Estimated_restoration_date__c != newInc.uom_Estimated_restoration_date__c)
				incUpd.etrUpdated = true;

			// Remove from map if update not requied
			if (!incUpd.isUpdated() && !integrationStatusComplete)
			{
				incUpdates.remove(newInc.Id);
				continue;
			}

			if (numNMIs != null)
				nmiCount += numNMIs;
		}

		if (incUpdates.isEmpty())
		{
			System.debug('Do nothing: Field values we are watching have not changed.');
			return 'OK: Nothing to do.';
		}

		// Queue if greater than x
		if (nmiCount >= FIRST_QUERY_LIMIT)
		{
			System.debug('*** Spawning queueable to finish the job...');

			Outage_AsyncProcessor Async = new Outage_AsyncProcessor(incUpdates);
			Id jobId = System.enqueueJob(Async);

			System.debug('Queueable jobId: ' + jobId);
			return 'Queueable jobId: ' + jobId;
		}

		return processIncidentUpdAffCusts(incUpdates);
	}

	// * From Incident
	// processIncidentUpdAffCusts profile:
	// Runs in before context
	// 1 SOQLs
	// 2 DMLs
	// 2 Futures
	public static String processIncidentUpdAffCusts(Map<Id, IncidentUpdate> incUpdates)
	{
		System.debug('*** Outage_IncidentProcessor.processIncidentUpdAffCusts');

		// Get Affected Customers (which are in progress)
		List<Affected_Customer__c> updateAffCust   = new List<Affected_Customer__c>();
		Map<Id, String>            updateAffNMIIds = new Map<Id, String>();

		Integer queryRecordCount = 0;

		Set<String> INC_STS_1_2 = new Set<String>{ INCIDENT_STS_1_REPORTED, INCIDENT_STS_2_ASSESS };

		Map<String, String> IncidentSts7_9_10_NMISts = new Map<String, String>
		{
			INCIDENT_STS_7_RESTORED  => AFF_NMI_RESOLVED,
			INCIDENT_STS_9_CANCELLED => AFF_NMI_CANCELLED,
			INCIDENT_STS_10_MERGED   => AFF_NMI_MERGED
		};

		for (Affected_Customer__c cust: [SELECT Id, Name, uom_Incident_Status__c, uom_Affected_Market_Identifier__c, uom_Incident__c,
										 uom_Aff_NMI_Status__c, uom_Estimated_assessment_date__c, uom_Estimated_restoration_date__c,
										 MC_Sync__c, MC_Sync_History__c, Incident_Sync__c, Incident_Notifications__c,
										 Multi_Incident__c
										 FROM Affected_Customer__c
										 WHERE uom_Incident__c IN :incUpdates.keySet()
										 AND uom_Aff_NMI_Status__c = :AFF_NMI_IN_PROG
										 AND Incident_Sync__c = :AFF_CUST_INC_SYNC_OOS
										 LIMIT :QUERY_LIMIT])
		{
			IncidentUpdate incUpdate = incUpdates.get(cust.uom_Incident__c);
			queryRecordCount++;
			System.debug(cust.Incident_Sync__c);

			CustomerUpdate CustUpdate = new CustomerUpdate(cust);

			// Does Incident Status need updating?
			if (cust.uom_Incident_Status__c != incUpdate.incStatus)
			{
				CustUpdate.updateIncidentStatus(incUpdate.incStatus);
			}

			// Does ETA need updating?
			if (cust.uom_Estimated_assessment_date__c != incUpdate.etaDate)
			{
				CustUpdate.updateETA(incUpdate.etaDate);
			}

			// Does ETR need updating?
			if (cust.uom_Estimated_restoration_date__c != incUpdate.etrDate)
			{
				CustUpdate.updateETR(incUpdate.etrDate);
			}

			if (CustUpdate.reqsRecordUpdate())
			{
				if (CustUpdate.incStatusUpdated)
				{
					// The first two Incident Statuses are to be treated effective as one.
					// We will only Sync to MC on the first occurence of EITHER Inc Status 1 or 2
					// And we will not sync when we see the second occurence of EITHER Inc Status 1 or 2
					// Eg: 1. Inc Sts = Reported (1) -> Sync to MC
					//     2. Inc Sts = Assess (2) -> Do not sync (as we sync'ed on step 1)
					String result;

					if (INC_STS_1_2.contains(CustUpdate.incStatus))
					{
						// Check the Status history for this customer,
						// for each prior Status in history, check is it status 1 or 2?
						// if no prior status is 1 or 2, then sync.

						Boolean found1_2 = false;
						Set<String> priorHistory = CustUpdate.getSetMCSyncHistory();

						if (priorHistory != null && !priorHistory.isEmpty())
						{
							for (String priorStatus: priorHistory)
							{
								if (INC_STS_1_2.contains(priorStatus))
								{
									found1_2 = true;
									break;
								}
							}
						}

						// Run update/sync
						if (!found1_2)
						{
							result = CustUpdate.runUpdateIncidentStatus();
						}
					}

					else if (IncidentSts7_9_10_NMISts.containsKey(CustUpdate.incStatus))
					{
						// When Incident set to Power Restored, Cancelled or Merged
						// Set any/all AffCusts to this status.

						// Queue an update for Aff NMI record:
						String NMIStatus = IncidentSts7_9_10_NMISts.get(CustUpdate.incStatus);
						CustUpdate.affCustomer.uom_Aff_NMI_Status__c = NMIStatus;
						updateAffNMIIds.put(CustUpdate.affCustomer.uom_Affected_Market_Identifier__c, NMIStatus);

						// note: no MC Sync event on Merged. This runs inside the CustomerUpdate object
						result = CustUpdate.runUpdateIncidentStatus();
					}

					else
					{
						// Catch all
						// Else (is an incident status update that is not status 1,2 - or 7,9,10)
						result = CustUpdate.runUpdateIncidentStatus();
					}

					System.debug(result);
				}

				/*
					// Disabled. We are not doing ETA/ETR updates currently.
					// If this is to be reenabled, it will require refactoring to use CustUpdate properly.
					else if (upd.etaUpdated && isNotifEnabled(cust) && allowMultiIncidentNotif(cust))
					{
						cust.MC_Sync__c = SYNC_MC_ETA_UPD;
						upd.addMCSyncHistoryItem(SYNC_MC_ETA_UPD);
					}
					else if (upd.etrUpdated && isNotifEnabled(cust) && allowMultiIncidentNotif(cust))
					{
						cust.MC_Sync__c = SYNC_MC_ETR_UPD;
						upd.addMCSyncHistoryItem(SYNC_MC_ETR_UPD);
					}
				*/

				// Add updated AffCust to list.
				updateAffCust.add(CustUpdate.affCustomer);
			}
		}

		if (!updateAffCust.isEmpty())
			update updateAffCust;

		if (!updateAffNMIIds.isEmpty())
		{
			futureUpdateAffNMIStatus(updateAffNMIIds);
			updateAffNMIIds.clear();
		}

		// update any rogue AffectedNMI records
		if (queryRecordCount < QUERY_LIMIT)
		{
			Integer rowsLeftLimit = QUERY_LIMIT - queryRecordCount;

			for (Affected_Market_Identifier__c affNMI: [SELECT Id, Name,
											 uom_Incident__c, uom_Incident__r.Status,
											 uom_Status__c, Incident_Sync__c
											 FROM Affected_Market_Identifier__c
											 WHERE uom_Incident__c IN :incUpdates.keySet()
											 AND uom_Status__c = :AFF_NMI_IN_PROG
											 AND Incident_Sync__c = :AFF_CUST_INC_SYNC_OOS
											 AND uom_Incident__r.Status IN :IncidentSts7_9_10_NMISts.keySet()
											 LIMIT :rowsLeftLimit])
			{
				IncidentUpdate incUpdate = incUpdates.get(affNMI.uom_Incident__c);
				queryRecordCount++;

				if (IncidentSts7_9_10_NMISts.containsKey(affNMI.uom_Incident__r.Status))
				{
					// When Incident set to Power Restored, Cancelled or Merged
					// Set any/all AffCusts to this status.

					// Queue an update for Aff NMI record:
					String NMIStatus = IncidentSts7_9_10_NMISts.get(affNMI.uom_Incident__r.Status);
					updateAffNMIIds.put(affNMI.Id, NMIStatus);
				}
			}
		}

		if (!updateAffNMIIds.isEmpty())
		{
			futureUpdateAffNMIStatus(updateAffNMIIds);
			updateAffNMIIds.clear();
		}

		// Limit check, and spawn new queueable
		// If our query size was the same as the query limit,
		// then it's likely there are more records to process
		// So we'll spawn a new thread and rerun there.
		if (queryRecordCount == QUERY_LIMIT)
		{
			System.debug('*** Spawning new queueable to finish the job...');

			Outage_AsyncProcessor Async = new Outage_AsyncProcessor(incUpdates);
			Id jobId = System.enqueueJob(Async);

			System.debug('Queueable jobId: ' + jobId);
		}
		else
		{
			// finished. Clean up Integration Status
			Set<Id> incIdsIntCompleted = new Set<Id>();

			for (IncidentUpdate incUpd: incUpdates.values())
				if (incUpd.integrationStatus == INT_STS_COMPLETE)
					incIdsIntCompleted.add(incUpd.incidentId);

			futureUpdateIncidentIntStatus(incIdsIntCompleted, null);
		}

		return 'OK: ' + updateAffCust.size() + ' records updated.';
	}


	// *********************************************************************
	// *** Secondary methods
	public static void futureUpdateAffNMIStatus(Map<Id, String> affNMIIdStatus)
	{
		if (Test.isRunningTest() || !enableFutures)
			updateAffNMIStatus(affNMIIdStatus);
		else
			fUpdateAffNMIStatus(affNMIIdStatus);
	}

	@future public static void fUpdateAffNMIStatus(Map<Id, String> affNMIIdStatus)
	{
		updateAffNMIStatus(affNMIIdStatus);
	}

	// updateAffNMIStatus profile:
	// Runs in future context
	// 0 SOQLs
	// 1 DMLs
	public static void updateAffNMIStatus(Map<Id, String> affNMIIdStatus)
	{
		System.debug('*** Outage_IncidentProcessor.updateAffNMIStatus');
		if (affNMIIdStatus == null || affNMIIdStatus.isEmpty())
			return;

		List<Affected_Market_Identifier__c> updAffNMIs = new List<Affected_Market_Identifier__c>();

		for (Id affNMIId: affNMIIdStatus.keySet())
		{
			String status = affNMIIdStatus.get(affNMIId);
			Affected_Market_Identifier__c updAffNMI = new Affected_Market_Identifier__c(Id = affNMIId);
			updAffNMI.uom_Status__c = status;
			updAffNMIs.add(updAffNMI);
		}

		update updAffNMIs;
	}

	public static void futureUpdateIncidentIntStatus(Set<Id> IncidentIds, String incIntStatus)
	{
		if (Test.isRunningTest() || !enableFutures)
			UpdateIncidentIntStatus(IncidentIds, incIntStatus);
		else
			fUpdateIncidentIntStatus(IncidentIds, incIntStatus);
	}

	@future public static void fUpdateIncidentIntStatus(Set<Id> IncidentIds, String incIntStatus)
	{
		UpdateIncidentIntStatus(IncidentIds, incIntStatus);
	}

	// UpdateIncidentIntStatus profile:
	// Runs in future context
	// 1 SOQLs
	// 1 DMLs
	public static void UpdateIncidentIntStatus(Set<Id> IncidentIds, String incIntStatus)
	{
		System.debug('*** Outage_IncidentProcessor.UpdateIncidentIntStatus');
		if (IncidentIds == null || IncidentIds.isEmpty())
			return;

		// Note: null incIntStatus is allowed, and is the natural state for the Integration_Status__c field

		List<Incident> updIncs = [SELECT Id, Subject, Integration_Status__c
								  FROM Incident
								  WHERE Id IN :IncidentIds
								  AND Integration_Status__c != :incIntStatus];

		for (Incident updInc: updIncs)
		{
			updInc.Integration_Status__c = incIntStatus;
		}

		update updIncs;
	}

	// setMultiIncidents profile:
	// Runs in current context
	// 0 SOQLs
	// 0 DMLs
	public static List<Affected_Market_Identifier__c> setMultiIncidents(List<Affected_Market_Identifier__c> affNMIs)
	{
		if (affNMIs == null || affNMIs.isEmpty()) return null;

		List<Affected_Market_Identifier__c> updateList = new List<Affected_Market_Identifier__c>();
		String NMINum = affNMIs.get(0).Name;

		if (affNMIs.size() == 1)
		{
			// nothing to do: It is solo!
			System.debug('NMI ' + NMINum + ': Setting Single Incident mode.');

			Affected_Market_Identifier__c affNMI = affNMIs.get(0);
			affNMI.Multi_Incident__c = AFF_NMI_SINGLE_INC;

			if (affNMI.Id != null)
				updateList.add(affNMI);

			return updateList;
		}

		// Else, multi mode!
		// Set as appropriate
		System.debug('NMI ' + NMINum + ': Setting Multi Incident mode.');
		Integer count = 0;

		for (Affected_Market_Identifier__c AffNMI: affNMIs)
		{
			// Set first as Multi-Incident (First)
			// Set rest as Multi-Incident (Subsequent)
			String priorValue = affNMI.Multi_Incident__c;

			if (count++ == 0)
				affNMI.Multi_Incident__c = AFF_NMI_MULTI_INC_1;
			else
				affNMI.Multi_Incident__c = AFF_NMI_MULTI_INC_2;

			if (affNMI.Id != null) // && affNMI.Multi_Incident__c != priorValue)
				updateList.add(affNMI);
		}

		return updateList;
	}

	@future
	public static void applySuburbs(Set<Id> IncIds)
	{
		if (IncIds == null || IncIds.isEmpty()) return;

		System.debug('*** apply suburbs to incidents');
		Map<Id, String> suburblist = new Map<Id, String>();

		// Get all open Incidents
		for (Incident inc: [SELECT Id, uom_Operating_Zone__c FROM Incident
							WHERE Id IN :IncIds])
		{
			String suburbs = '';

			if (inc.uom_Operating_Zone__c != null)
				suburbs = inc.uom_Operating_Zone__c +': ';

			suburblist.put(inc.Id, suburbs);
		}

		if (suburblist.isEmpty()) return;

		// Get suburb list from linked customers
		for (AggregateResult ar: [SELECT uom_Incident__c, uom_Customer_Suburb__c
									FROM Affected_Customer__c
									WHERE uom_Incident__c IN :suburblist.keySet()
									AND uom_Customer_Suburb__c != null
									GROUP BY uom_Incident__c, uom_Customer_Suburb__c
									ORDER BY uom_Customer_Suburb__c ASC])
									//AND uom_Aff_NMI_Status__c NOT IN ('Restored', 'Cancelled', 'Merged')
		{
			System.debug(JSON.serializePretty(ar));
			Id incidentId = (Id)ar.get('uom_Incident__c');
			String suburb = (String)ar.get('uom_Customer_Suburb__c');

			if (!suburblist.containsKey(incidentId))
				suburblist.put(incidentId, '');

			String suburbs = suburblist.get(incidentId);
			if (!suburbs.endsWith(': ')) suburbs += ', ';
			suburbs += suburb;

			suburblist.put(incidentId, suburbs);
		}

		if (suburblist.isEmpty()) return;

		// update incidents
		UtilDatabase db = new UtilDatabase();

		for (Id incId: suburblist.keySet())
		{
			String suburbs = suburblist.get(incId);
			suburbs = suburbs.removeEnd(': ');

			Incident inc = new Incident(Id = incId,
										has_affected_suburbs__c = true,
										Affected_Suburbs__c = suburbs);
			db.addObjForUpsert(inc);
		}

		db.upsertObjs();
	}


	// *********************************************************************
	// *** Helper methods
	@testvisible private static Boolean globalNotifEnabled;
	public static Boolean isGlobalNotifEnabled()
	{
		if (globalNotifEnabled == null)
		{
			// System.debug('Setting globalNotifEnabled...');
			globalNotifEnabled = !Incident_Setup__c.getInstance().Incident_Notifs_Disabled__c;
		}
		return globalNotifEnabled;
	}

	public static String stripStreetDetails(String street)
	{
		if (street == null) return street;

		List<String> parts = street.split('\\d');
		String output = parts.get(parts.size()-1);
		return output.trim();
	}

	public static void setQueryLimit(Integer intLimit)
	{
		if (intLimit == null || intLimit <= 0)
			return;

		QUERY_LIMIT = intLimit;
	}

	public static Integer getDMLRowsLeft()
	{
		return Limits.getLimitDMLRows() - Limits.getDMLRows();
	}

	public static Integer getQueryRowsLeft()
	{
		return Limits.getLimitQueryRows() - Limits.getQueryRows();
	}

	public static Integer getDMLStatementsLeft()
	{
		return Limits.getLimitDMLStatements() - Limits.getDMLStatements();
	}

	public static Integer getFutureCallsLeft()
	{
		return Limits.getLimitFutureCalls() - Limits.getFutureCalls();
	}

	public static void debugLimits()
	{
		System.debug('DML Rows Left:       ' + getDMLRowsLeft());
		System.debug('Query Rows Left:     ' + getQueryRowsLeft());
		System.debug('DML Statements Left: ' + getDMLStatementsLeft());
		System.debug('Future Calls Left:   ' + getFutureCallsLeft());
	}

	public static Boolean getDebugMode()
	{
		if (Test.isRunningTest()) return true;

		Boolean debugMode = false;
		debugMode = DER_System__c.getInstance().UOM_API_Debug_Enabled__c;

		return debugMode;
	}

	public static UtilDebug newUOMDebug()
	{
		UtilDebug de = new UtilDebug(getDebugMode());
		return de;
	}

	// *********************************************************************
	// *** Classes
	public class IncidentUpdate
	{
		public Id incidentId;

		public Boolean incStatusUpdated = false;
		public Boolean etaUpdated = false;
		public Boolean etrUpdated = false;

		public String   incStatus;
		public DateTime etaDate;
		public DateTime etrDate;
		public String   integrationStatus;

		public Integer  queryLimit;
		public Integer  numNMIs;

		public IncidentUpdate(Incident inc)
		{
			incidentId        = inc.Id;
			incStatus         = inc.Status;
			etaDate           = inc.uom_Estimated_assessment_date__c;
			etrDate           = inc.uom_Estimated_restoration_date__c;
			integrationStatus = inc.Integration_Status__c;

			queryLimit = QUERY_LIMIT;
		}

		public Boolean isUpdated()
		{
			return (incStatusUpdated || etaUpdated || etrUpdated);
		}
	}

	public class CustomerUpdate
	{
		public Affected_Customer__c affCustomer;

		public Boolean incStatusUpdated = false;
		public Boolean nmiStatusUpdated = false;
		public Boolean etaUpdated = false;
		public Boolean etrUpdated = false;

		public String incStatus;
		public DateTime etaDate;
		public DateTime etrDate;

		public String nmiStatus;
		public String multiIncMode;

		public List<String> mcSyncHistory;

		public CustomerUpdate(Affected_Customer__c affCust)
		{
			affCustomer = affCust;
			multiIncMode = affCustomer.Multi_Incident__c;
			applyMCSyncHistory(affCust.MC_Sync_History__c);
		}

		public Boolean reqsRecordUpdate()
		{
			return (incStatusUpdated || nmiStatusUpdated || etaUpdated || etrUpdated);
		}

		public void updateIncidentStatus(String incidentStatus)
		{
			if (incidentStatus == null) return;

			affCustomer.uom_Incident_Status__c = incidentStatus;
			incStatus = incidentStatus;
			incStatusUpdated = true;
		}

		public void updateETA(DateTime incidentETADate)
		{
			if (incidentETADate == null) return;

			affCustomer.uom_Estimated_assessment_date__c = incidentETADate;
			etaDate = incidentETADate;
			etaUpdated = true;
		}

		public void updateETR(DateTime incidentETRDate)
		{
			if (incidentETRDate == null) return;

			affCustomer.uom_Estimated_restoration_date__c = incidentETRDate;
			etrDate = incidentETRDate;
			etrUpdated = true;
		}

		public void updateNMIStatus(String argNMIStatus)
		{
			if (argNMIStatus == null) return;

			if (affCustomer.uom_Aff_NMI_Status__c != argNMIStatus)
				nmiStatusUpdated = true;

			affCustomer.uom_Aff_NMI_Status__c = argNMIStatus;
			nmiStatus = argNMIStatus;
		}

		public String runUpdateIncidentStatus()
		{
			// Is incident status updated/need to be updated?
			// 		* Check certain status update criteria (maybe)
			// 		* Check notif settings
			// 		* Check Multi settings
			// 		* If multi (first)
			// 			* Check if first update or not
			// 			* Use correct Sync MC flag
			String SyncFlag = SYNC_MC_SYNC;
			String SyncStatus = incStatus;

			if (!isNotifEnabled())
			{
				return 'Do Not Sync: Global or Incident Notifications disabled.';
			}

			if (!allowMultiIncidentNotif())
			{
				return 'Do Not Sync: Multi Incident mode is ' + multiIncMode;
			}

			if (incStatus == INCIDENT_STS_10_MERGED)
			{
				return 'Do Not Sync: Incident Status is ' + incStatus;
			}

			if (multiIncMode == AFF_NMI_MULTI_INC_1)
			{
				// TODO: Check if final status?
				if (INCIDENT_STS_CLSD.contains(incStatus))
				{
					// This incident is closed. Do not send message on close.
					return 'Do Not Sync: Multi Incident mode is ' + multiIncMode + ' and Incident Status is ' + incStatus;
				}

				// Check if we've run this update already
				if (mcSyncHistory != null && !mcSyncHistory.isEmpty())
				{
					if (getSetMCSyncHistory().contains(AFF_NMI_MULTI_INC_1))
					{
						return 'Do Not Sync: Multi Incident sync has already been sent';
					}
				}

				SyncFlag = SYNC_MC_SYNC_MULTI;
				SyncStatus = AFF_NMI_MULTI_INC_1;
			}

			// Run the sync
			affCustomer.MC_Sync__c = SyncFlag;
			addMCSyncHistoryItem(SyncStatus);

			return 'Syncing: MC Sync is set to ' + affCustomer.MC_Sync__c;
		}

		public String runUpdateNMIStatus()
		{
			// Is NMI status updated/need to be updated?
					// Only Sync when Restored
					// Also, prevent sync when Multi mode (Subsequent)
					// TODO: Do not sync on Restored/multi mode.
			// 		* Check notif settings
			// 		* Check Multi settings
			// 		* If multi (first)
			// 			* Check if first update or not
			// 			* Use correct Sync MC flag

			String SyncFlag = SYNC_MC_SYNC;
			String SyncStatus = nmiStatus;

			if (!nmiStatusUpdated)
			{
				return 'Do Not Sync: NMI Status has not changed: (' + nmiStatus + ')';
			}

			if (nmiStatus != AFF_NMI_RESOLVED)
			{
				return 'Do Not Sync: NMI Status has changed (' + nmiStatus + '), but is not tracked ('+AFF_NMI_RESOLVED+').';
			}

			if (!isNotifEnabled())
			{
				return 'Do Not Sync: Global or Incident Notifications disabled.';
			}

			if (!allowMultiIncidentNotif())
			{
				return 'Do Not Sync: Multi Incident mode is ' + multiIncMode;
			}

			if (AFF_NMI_MULTI_INCS.contains(multiIncMode) && AFF_NMI_STS_CLSD.contains(nmiStatus))
			{
				return 'Do Not Sync: Multi-Incident mode is '+multiIncMode+' and NMI Status is '+AFF_NMI_RESOLVED;
			}

			// assume nmiStatus has changed, is resolved.

			// Run the sync
			affCustomer.MC_Sync__c = SyncFlag;
			addMCSyncHistoryItem(SyncStatus);

			return 'Syncing: MC Sync is set to ' + affCustomer.MC_Sync__c;
		}


		// ** helper methods
		private void applyMCSyncHistory(String jsonMCSyncHistory)
		{
			if (jsonMCSyncHistory == null) return;
			mcSyncHistory = new List<String>();

			try
			{
				mcSyncHistory = (List<String>)JSON.deserialize(jsonMCSyncHistory, List<String>.class);
			}
			catch (Exception e) {}
		}

		public void addMCSyncHistoryItem(String status)
		{
			if (status == null) return;

			if (mcSyncHistory == null)
			mcSyncHistory = new List<String>();

			mcSyncHistory.add(status);
			affCustomer.MC_Sync_History__c = setMCSyncHistory();
		}

		private String setMCSyncHistory()
		{
			if (mcSyncHistory == null || mcSyncHistory.isEmpty())
				return null;

			String output;

			try
			{
				output = JSON.serializePretty(mcSyncHistory);
			}
			catch (Exception e) {}

			return output;
		}

		public Set<String> getSetMCSyncHistory()
		{
			return toSet(mcSyncHistory);
		}

		public Boolean isNotifEnabled()
		{
			if (affCustomer == null || affCustomer.Incident_Notifications__c == null)
				return false;

			return (affCustomer.Incident_Notifications__c == INC_NOTIFS_AUTO && isGlobalNotifEnabled());
		}

		public Boolean allowMultiIncidentNotif()
		{
			if (affCustomer != null &&                                // if record is not null
				affCustomer.Multi_Incident__c != null &&              // and multi field is not null
				affCustomer.Multi_Incident__c == AFF_NMI_MULTI_INC_2) // and multi field = Multi-Incident (Subsequent)
			{
				// Disallow notification
				return false;
			}

			// Allow notification to occur
			return true;
		}

		private Set<String> toSet(List<String> mylist)
		{
			if (mylist == null)
				return null;
			return new Set<String>(mylist);
		}
	}


	// *********************************************************************
	// *** Exception
	public class DataIntegrityException extends Exception {}

}