public with sharing class CustomerConsent {
	public static final String CHANNEL_VOICE_CALL = 'Voice Call';
	public static final String PHONETYPE_MOBILE = 'Mobile';
	public static final String PHONETYPE_HOME = 'Home';
	public static final String CP_DATATYPE_ENHANCED = 'Enhanced';
	public static final String CAPTURE_SRC_CALL_CENTRE = 'Call Centre';
	
	/********** Constructor **********/
	public CustomerConsent() {

	}


	/********** Main methods **********/

	@AuraEnabled
	public static List<Map<String, Object>> getCustomerPreferences (Id contactId) {
		List<Map<String, Object>> customerPreferenceList = new List<Map<String, Object>>();
		Map<Id, Map<String, Object>> customerPreferenceMap = new Map<Id, Map<String, Object>>();

		try {
			List<ContactPointConsent> cpcList = getActiveContactPointConsentRecords(contactId);
			List<DataUsePurpose> dupList = getDataUsePurposeRecords();
			Map<Id, ContactPointEmail> cpeMap = getContactPointEmailRecords(contactId);
			Map<Id, ContactPointPhone> cppMap = getContactPointPhoneRecords(contactId);

			for (ContactPointConsent cpc : getActiveContactPointConsentRecords(contactId)) {
				SObject contactPoint;

				if (cpc.EngagementChannelTypeName__c == Outage_IncidentProcessor.CHANNEL_EMAIL) {
					contactPoint = cpeMap.get(cpc.ContactPointId);
				} else if (cpc.EngagementChannelTypeName__c == Outage_IncidentProcessor.CHANNEL_SMS || cpc.EngagementChannelTypeName__c == CHANNEL_VOICE_CALL) {
					contactPoint = cppMap.get(cpc.ContactPointId);
				}

				if (contactPoint != null) {
					customerPreferenceMap = handleActiveContactPointConsentRecords(dupList, customerPreferenceMap, cpc, contactPoint);
				}
			}

			customerPreferenceMap = HandleNonActiveContactPointRecords(dupList, customerPreferenceMap, cpeMap);
			customerPreferenceMap = HandleNonActiveContactPointRecords(dupList, customerPreferenceMap, cppMap);
			
			for (Id key : customerPreferenceMap.keySet()) {
				Map<String, Object> innerMap = customerPreferenceMap.get(key);

				Map<String, Object> prefs = (Map<String, Object>) innerMap.get('preferences');
				Map<String, Object> additionalFields = (Map<String, Object>) innerMap.get('additionalfields');
				String channelType = (String) additionalFields.get('channeltype');
				List<Map<String, Object>> prefsList = new List<Map<String, Object>>();

				// structure preference map and turn into a list
				for (String pref : prefs.keySet()) {
					Map<String, Object> combinedMap = new Map<String, Object>();
					Map<String, Object> innerPrefsMap = new Map<String, Object>();
					innerPrefsMap.put('datausepurpose', pref);
					innerPrefsMap.put('optedin', prefs.get(pref));
					innerPrefsMap.put('canoptinout', getCanOptInOut(pref, channelType));

					combinedMap.putAll(innerPrefsMap);

					prefsList.add(combinedMap);
				}
				innerMap.put('preferences', prefsList);

				customerPreferenceList.add(innerMap);
			}

		} catch (Exception e) {
			String errorMsg = 'Error occured during getCustomerPreferences.';
			throw new CustomerConsentException(errorMsg);
		}

		return customerPreferenceList;
	}

	@AuraEnabled
	public static Object updateContactPointRecords (Id contactId, Map<String, Map<String, Object>> contactPointUpdates, Map<String, Object> legalData) {
		Map<Id, Set<String>> contactPointEmailOptInMap = new Map<Id, Set<String>>();
		Map<Id, Set<String>> contactPointEmailOptOutMap = new Map<Id, Set<String>>();
		Map<Id, Set<String>> contactPointPhoneOptInMap = new Map<Id, Set<String>>();
		Map<Id, Set<String>> contactPointPhoneOptOutMap = new Map<Id, Set<String>>();

		try {
			if (FeatureManagement.checkPermission('Customer_Consent_Can_Update')) {
				for (Id contactPointId : contactPointUpdates.keySet()) {
					Schema.SObjectType objectType = contactPointId.getSObjectType();
					Map<String, Object> contactPointPrefs = contactPointUpdates.get(contactPointId);
					Set<String> optInPrefs = new Set<String>();
					Set<String> optOutPrefs = new Set<String>();
		
					for (String pref : contactPointPrefs.keySet()) {
						Boolean optIn = (Boolean) contactPointPrefs.get(pref);
						if (optIn) {
							optInPrefs.add(pref);
						} else {
							optOutPrefs.add(pref);
						}
					}
		
					if (objectType == ContactPointEmail.SObjectType) {
						updateOptInAndOptOutMaps(optInPrefs, optOutPrefs, contactPointEmailOptInMap, contactPointEmailOptOutMap, contactPointId);
					} else if (objectType == ContactPointPhone.SObjectType) {
						updateOptInAndOptOutMaps(optInPrefs, optOutPrefs, contactPointPhoneOptInMap, contactPointPhoneOptOutMap, contactPointId);
					}
				}
		
				if (!contactPointEmailOptOutMap.isEmpty() || !contactPointPhoneOptOutMap.isEmpty()) {
					handleContactPointConsentOptOuts(contactPointEmailOptOutMap, contactPointPhoneOptOutMap, legalData);
				}
		
				if (!contactPointEmailOptInMap.isEmpty() || !contactPointPhoneOptInMap.isEmpty()) {
					handleContactPointConsentOptIns(contactPointEmailOptInMap, contactPointPhoneOptInMap, contactId, legalData);
				}
				
				if (!legalData.isEmpty()) {
					updateExistingActiveConsentsOutageNotifications(contactPointUpdates.keySet(), contactId, legalData);
				}
			}

		} catch (Exception e) {
			String errorMsg = 'Error occured during updateContactPointRecords.';
			throw new CustomerConsentException(errorMsg);
		}
		
		return true;
	}


	/********** Helper methods **********/

	private static List<DataUsePurpose> getDataUsePurposeRecords () {
		List<DataUsePurpose> dupList = [SELECT Id, Name FROM DataUsePurpose WHERE CanDataSubjectOptOut = TRUE ORDER BY Name];
		return dupList;
	}

	private static List<ContactPointConsent> getActiveContactPointConsentRecords (Id contactId) {
		List<ContactPointConsent> cpcList = [SELECT Id, ContactPointId, Status__c, DataUsePurposeName__c, EngagementChannelTypeName__c 
											FROM ContactPointConsent 
											WHERE Contact__c = :contactId 
											AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE 
											ORDER BY EngagementChannelTypeName__c, Contact_Point__c ];
		return cpcList;
	}

	private static Map<Id, ContactPointEmail> getContactPointEmailRecords (Id contactId) {
		Map<Id, ContactPointEmail> cpeMap = new Map<Id, ContactPointEmail>([SELECT Id, EmailAddress, IsPrimary, Data_Type__c 
																			FROM ContactPointEmail 
																			WHERE Contact__c = :contactId 
																			AND Status__c = :Outage_IncidentProcessor.CP_STS_ACTIVE]);
		return cpeMap;
	}

	private static List<ContactPointEmail> getContactPointEmailRecordsByIdsOrIsPrimary (Id contactId, Set<Id> ids) {
		List<ContactPointEmail> cpeList = [SELECT Id, IsPrimary 
											FROM ContactPointEmail 
											WHERE Contact__c = :contactId 
											AND (isPrimary = TRUE OR Id IN :ids) 
											AND Status__c = :Outage_IncidentProcessor.CP_STS_ACTIVE];
		return cpeList;
	}

	private static Map<Id, ContactPointPhone> getContactPointPhoneRecords (Id contactId) {
		Map<Id, ContactPointPhone> cppMap = new Map<Id, ContactPointPhone>([SELECT Id, TelephoneNumber, IsPrimary, PhoneType, Data_Type__c 
																			FROM ContactPointPhone 
																			WHERE Contact__c = :contactId 
																			AND Status__c = :Outage_IncidentProcessor.CP_STS_ACTIVE]);
		return cppMap;
	}

	private static List<ContactPointPhone> getContactPointPhoneRecordsByIdsOrIsPrimary (Id contactId, Set<Id> ids) {
		List<ContactPointPhone> cppList = [SELECT Id, IsPrimary 
											FROM ContactPointPhone 
											WHERE Contact__c = :contactId 
											AND (isPrimary = TRUE OR Id IN :ids) 
											AND Status__c = :Outage_IncidentProcessor.CP_STS_ACTIVE];
		return cppList;
	}

	private static List<ContactPointPhone> getContactPointPhoneRecordsByIds (Id contactId, Set<Id> ids) {
		List<ContactPointPhone> cppList = [SELECT Id, PhoneType 
											FROM ContactPointPhone 
											WHERE Contact__c = :contactId 
											AND Id IN :ids 
											AND Status__c = :Outage_IncidentProcessor.CP_STS_ACTIVE];
		return cppList;
	}

	@testVisible
	private static Map<Id, Map<String, Object>> HandleNonActiveContactPointRecords(List<DataUsePurpose> dupList, Map<Id, Map<String, Object>> customerPreferenceMap, Map<Id, SObject> sObjectContactPointMap) {
		
		for (Id key : sObjectContactPointMap.keySet()) {

			if (!customerPreferenceMap.containsKey(key)) {

				Map<String, Object> combinedMap = new Map<String, Object>();
				Sobject contactPoint = sObjectContactPointMap.get(key);

				combinedMap.putAll(getDataUsePurposePreferenceMapTemplate(dupList));
				combinedMap.putAll(getContactPointFieldsMap(contactPoint));
				combinedMap.putAll(getAdditionalFieldsMap(contactPoint, null));

				customerPreferenceMap.put(key, combinedMap);
			}
		}

		return customerPreferenceMap;
	}

	@testVisible
	private static Map<Id, Map<String, Object>> handleActiveContactPointConsentRecords(List<DataUsePurpose> dupList, Map<Id, Map<String, Object>> customerPreferenceMap, ContactPointConsent cpc, SObject contactPoint) {

		if (customerPreferenceMap.containsKey(cpc.ContactPointId)) {
			Map<String, Object> prefs = (Map<String, Object>) customerPreferenceMap.get(cpc.ContactPointId).get('preferences');

			if (String.isNotBlank(cpc.DataUsePurposeName__c) && prefs.containsKey(cpc.DataUsePurposeName__c)) {
				prefs.put(cpc.DataUsePurposeName__c, true);
			}
		} else {
			Map<String, Object> combinedMap = new Map<String, Object>();
			Map<String, Map<String, Object>> dupPreferenceMap = getDataUsePurposePreferenceMapTemplate(dupList);

			if (dupPreferenceMap.get('preferences').containsKey(cpc.DataUsePurposeName__c)) {
				dupPreferenceMap.get('preferences').put(cpc.DataUsePurposeName__c, true);
			}

			combinedMap.putAll(dupPreferenceMap);
			combinedMap.putAll(getContactPointFieldsMap(contactPoint));
			combinedMap.putAll(getAdditionalFieldsMap(cpc, contactPoint));

			customerPreferenceMap.put(cpc.ContactPointId, combinedMap);

		}

		return customerPreferenceMap;
	}

	@testVisible
	private static Map<String, Map<String, Object>> getAdditionalFieldsMap(SObject contactPoint, SObject relatedContactPoint) {
		Map<String, Map<String, Object>> additionalFieldsMap = new Map<String, Map<String, Object>>();
		Map<String, Object> innerFieldsMap = new Map<String, Object>();
		Boolean isEnhancedDataType;

		if (contactPoint != null) {
	
			if (contactPoint instanceof ContactPointConsent) {
				innerFieldsMap.put('channeltype', contactPoint.get('EngagementChannelTypeName__c'));

				if (relatedContactPoint != null) {
					isEnhancedDataType = relatedContactPoint.get('Data_Type__c') == CP_DATATYPE_ENHANCED ? true : false;
				}

			} else {

				if (contactPoint instanceof ContactPointEmail) {
					innerFieldsMap.put('channeltype', Outage_IncidentProcessor.CHANNEL_EMAIL);
				} else if (contactPoint instanceof ContactPointPhone) {
					if (contactPoint.get('PhoneType') == PHONETYPE_MOBILE) {
						innerFieldsMap.put('channeltype', Outage_IncidentProcessor.CHANNEL_SMS);
					} else if (contactPoint.get('PhoneType') == PHONETYPE_HOME) {
						innerFieldsMap.put('channeltype', CHANNEL_VOICE_CALL);
					}
				}

				isEnhancedDataType = contactPoint.get('Data_Type__c') == CP_DATATYPE_ENHANCED ? true : false;
			}

			innerFieldsMap.put('isenhanceddatatype', isEnhancedDataType);
		}

		additionalFieldsMap.put('additionalfields', innerFieldsMap);

		return additionalFieldsMap;
	}

	@testVisible
	private static String formatHomePhoneNumber(String phoneNumber) {
		String updatedPhoneNumber = phoneNumber;

		if (String.isNotBlank(updatedPhoneNumber)) {

			if (phoneNumber.length() == 10) {
				// Format as "xx xxxx xxxx"
				updatedPhoneNumber = phoneNumber.substring(0, 2) + ' ' + phoneNumber.substring(2, 6) + ' ' + phoneNumber.substring(6);
			} else if (phoneNumber.length() == 8) {
				// Format as "xxxx xxxx"
				updatedPhoneNumber = phoneNumber.substring(0, 4) + ' ' + phoneNumber.substring(4);
			}
		}

		return updatedPhoneNumber;
	}

	@testVisible
	private static String formatMobilePhoneNumber(String phoneNumber) {
		String updatedPhoneNumber = phoneNumber;

		if (String.isNotBlank(updatedPhoneNumber)) {
			
			if (phoneNumber.length() == 11) {
				String prefix = phoneNumber.substring(0, 2);

				if (prefix == '61') {
					// Format as "xxxx xxx xxx"
					updatedPhoneNumber = '0' + phoneNumber.substring(2, 5) + ' ' + phoneNumber.substring(5, 8) + ' ' + phoneNumber.substring(8);
				}
			}
		}

		return updatedPhoneNumber;
	}

	@testVisible
	private static Map<String, Map<String, Object>> getContactPointFieldsMap(SObject contactPoint) {
		Map<String, Map<String, Object>> fieldsMap = new Map<String, Map<String, Object>>();

		if (contactPoint != null) {
			Map<String, Object> fieldsToValueMap = contactPoint.getPopulatedFieldsAsMap();
			Map<String, Object> modifiedFieldsToValueMap = new Map<String, Object>();

			for (String field : fieldsToValueMap.keySet()) {
				Object value = fieldsToValueMap.get(field);

				if (field == 'TelephoneNumber') {

					if (fieldsToValueMap.get('PhoneType') == PHONETYPE_MOBILE) {
						value = formatMobilePhoneNumber(String.valueOf(value));
					} else {
						value = formatHomePhoneNumber(String.valueOf(value));
					}
				}
				
				modifiedFieldsToValueMap.put(field, value);
			}

			fieldsMap.put('fields', modifiedFieldsToValueMap);
		} else {
			fieldsMap.put('fields', null);
		}

		return fieldsMap;
	}

	@testVisible
	private static Map<String, Map<String, Object>> getDataUsePurposePreferenceMapTemplate(List<DataUsePurpose> dupList) {
		Map<String, Map<String, Object>> dupPrefMapTemp = new Map<String, Map<String, Object>>();
		Map<String, Object> dupPrefInnerMapTemp = new Map<String, Object>();

		for (DataUsePurpose dup : dupList) {
			dupPrefInnerMapTemp.put(dup.Name, false);
		}

		dupPrefMapTemp.put('preferences', dupPrefInnerMapTemp);

		return dupPrefMapTemp;
	}

	@testVisible
	private static Boolean getCanOptInOut(String pref, String channelType) {
		Boolean canOptInOut = true;

		if (pref == Outage_IncidentProcessor.DATAUSE_OUTAGES && channelType == CHANNEL_VOICE_CALL) {
			canOptInOut = false;
		}
		
		return canOptInOut;
	}

	private static void updateOptInAndOptOutMaps(Set<String> optInPrefs, Set<String> optOutPrefs, Map<Id, Set<String>> contactPointOptInMap, Map<Id, Set<String>> contactPointOptOutMap, Id contactPointId) {
		if (!optInPrefs.isEmpty()) {
			contactPointOptInMap.put(contactPointId, optInPrefs);
		}
		if (!optOutPrefs.isEmpty()) {
			contactPointOptOutMap.put(contactPointId, optOutPrefs);
		}
	}

	@testVisible
	private static void handleContactPointConsentOptOuts(Map<Id, Set<String>> contactPointEmailOptOutMap, Map<Id, Set<String>> contactPointPhoneOptOutMap, Map<String, Object> legalData) {
		String privacyPolicy = getPrivacyPolicyValue(legalData);
		String authorisedToChange = getAuthorisedToChangeValue(legalData);
		List<ContactPointConsent> cpcRecordList = new List<ContactPointConsent>();

		for (ContactPointConsent cpc : [SELECT Id, EffectiveTo, ContactPointId, DataUsePurposeName__c, EngagementChannelTypeName__c, CaptureDate, CaptureSource, Privacy_Policy__c, Authorised_to_Change__c FROM ContactPointConsent WHERE (ContactPointId IN :contactPointEmailOptOutMap.keySet() OR ContactPointId IN :contactPointPhoneOptOutMap.keySet()) AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE]) {
			Set<String> optOutDups;

			if (cpc.EngagementChannelTypeName__c == Outage_IncidentProcessor.CHANNEL_EMAIL) {
				optOutDups = contactPointEmailOptOutMap.get(cpc.ContactPointId);
			} else if (cpc.EngagementChannelTypeName__c == Outage_IncidentProcessor.CHANNEL_SMS || cpc.EngagementChannelTypeName__c == CHANNEL_VOICE_CALL) {
				optOutDups = contactPointPhoneOptOutMap.get(cpc.ContactPointId);
			}

			if (optOutDups != null && optOutDups.contains(cpc.DataUsePurposeName__c)) {
				
				if (cpc.DataUsePurposeName__c == Outage_IncidentProcessor.DATAUSE_OUTAGES) {
					cpc.CaptureDate = Datetime.now();
					cpc.CaptureSource = CAPTURE_SRC_CALL_CENTRE;
					cpc.Privacy_Policy__c = privacyPolicy;
					cpc.Authorised_to_Change__c = authorisedToChange;
				}

				cpc.EffectiveTo = Datetime.now();
				cpcRecordList.add(cpc);
			}
		}

		if (!cpcRecordList.isEmpty()) {
			update cpcRecordList;
		}
	}

	@testVisible
	private static void handleContactPointConsentOptIns(Map<Id, Set<String>> contactPointEmailOptInMap, Map<Id, Set<String>> contactPointPhoneOptInMap, Id contactId, Map<String, Object> legalData) {
		WOSCustomerConsent wos = new WOSCustomerConsent();
		wos.handleContactPointConsentOptIns(contactPointEmailOptInMap, contactPointPhoneOptInMap, contactId, legalData);
	}

	@testVisible
	private static void updateExistingActiveConsentsOutageNotifications (Set<String> excludedContactPoints, Id contactId, Map<String, Object> legalData) {
		WOSCustomerConsent wos = new WOSCustomerConsent();
		wos.updateExistingActiveConsentsOutageNotifications(excludedContactPoints, contactId, legalData);
	}

	@testVisible
	private static Map<String, Id> getDataUsePurposeNameToIdMap () {
		Map<String, Id> dataUsePurposeNameToIdMap = new Map<String, Id>();

		for (DataUsePurpose dup : [SELECT Id, Name FROM DataUsePurpose WHERE CanDataSubjectOptOut = TRUE]) {
			dataUsePurposeNameToIdMap.put(dup.Name, dup.Id);
		}

		return dataUsePurposeNameToIdMap;
	}

	@testVisible
	private static Map<String, Id> getEngagementChannelTypeNameToIdMap () {
		Map<String, Id> engagementChannelTypeNameToIdMap = new Map<String, Id>();

		for (EngagementChannelType ect : [SELECT Id, Name FROM EngagementChannelType]) {
			engagementChannelTypeNameToIdMap.put(ect.Name, ect.Id);
		}

		return engagementChannelTypeNameToIdMap;
	}
	
	@testVisible
	private static String getPrivacyPolicyValue(Map<String, Object> legalData) {
		String privacyPolicy = '';

		if (legalData.containsKey('privacypolicy')) {
			Boolean privacyPolicyAgreedTo = (Boolean) legalData.get('privacypolicy');
			privacyPolicy = privacyPolicyAgreedTo ? 'Agreed' : 'Did not agree';
		}

		return privacyPolicy;
	}

	@testVisible
	private static String getAuthorisedToChangeValue(Map<String, Object> legalData) {
		String authorisedToChange = '';

		if (legalData.containsKey('prefauthorisation')) {
			Boolean prefAuthorisation = (Boolean) legalData.get('prefauthorisation');
			authorisedToChange = prefAuthorisation ? 'Authorised' : 'Not Authorised';
		}

		return authorisedToChange;
	}


	@testVisible
	private static ContactPointConsent createNewContactPointConsentRecord(Id contactId, Id cpId, Id dataUsePurposeId, Id engagementChannelTypeId, String privacyPolicy, String authorisedToChange) {

		ContactPointConsent cpc = new ContactPointConsent(
			Contact__c = contactId,
			ContactPointId = cpId,
			DataUsePurposeId = dataUsePurposeId,
			EngagementChannelTypeId = engagementChannelTypeId,
			CaptureSource = CAPTURE_SRC_CALL_CENTRE,
			CaptureDate = Datetime.now(),
			EffectiveFrom = Datetime.now(),
			Privacy_Policy__c = privacyPolicy,
			Authorised_to_Change__c = authorisedToChange
		);

		return cpc;
	}


	/********** Inner Classes **********/

	// Inner class for running DML statements without sharing
	private without sharing class WOSCustomerConsent {
		
        private WOSCustomerConsent() {

        }

		private void handleContactPointConsentOptIns(Map<Id, Set<String>> contactPointEmailOptInMap, Map<Id, Set<String>> contactPointPhoneOptInMap, Id contactId, Map<String, Object> legalData) {
			List<ContactPointConsent> cpcRecordList = new List<ContactPointConsent>();
			Map<String, Id> dataUsePurposeNameToIdMap = getDataUsePurposeNameToIdMap();
			Map<String, Id> engagementChannelTypeNameToIdMap = getEngagementChannelTypeNameToIdMap();
			Id ectIdEmail = engagementChannelTypeNameToIdMap.get(Outage_IncidentProcessor.CHANNEL_EMAIL);
			Id ectIdSMS = engagementChannelTypeNameToIdMap.get(Outage_IncidentProcessor.CHANNEL_SMS);
			Id ectIdVoiceCall = engagementChannelTypeNameToIdMap.get(CHANNEL_VOICE_CALL);
			String privacyPolicy = getPrivacyPolicyValue(legalData);
			String authorisedToChange = getAuthorisedToChangeValue(legalData);
			Set<Id> cpeIdsOutageNotifications = new Set<Id>();
			Set<Id> cppIdsOutageNotifications = new Set<Id>();
	
			if (!contactPointEmailOptInMap.isEmpty()) {
				for (Id cpeId : contactPointEmailOptInMap.keySet()) {
	
					for (String dupName : contactPointEmailOptInMap.get(cpeId)) {
						Id dupId = dataUsePurposeNameToIdMap.get(dupName);
	
						if (String.isNotBlank(dupId) && String.isNotBlank(ectIdEmail)) {
							ContactPointConsent cpc;
	
							if (dupName == Outage_IncidentProcessor.DATAUSE_OUTAGES) {
								cpc = createNewContactPointConsentRecord(contactId, cpeId, dupId, ectIdEmail, privacyPolicy, authorisedToChange);
								cpeIdsOutageNotifications.add(cpeId);
							} else {
								cpc = createNewContactPointConsentRecord(contactId, cpeId, dupId, ectIdEmail, '', '');
							}
							cpcRecordList.add(cpc);
						}
					}
				}
			}
	
			if (!contactPointPhoneOptInMap.isEmpty()) {
				for (ContactPointPhone cpp : getContactPointPhoneRecordsByIds(contactId, contactPointPhoneOptInMap.keySet())) {
					Id ectId;
		
					for (String dupName : contactPointPhoneOptInMap.get(cpp.Id)) {
						Id dupId = dataUsePurposeNameToIdMap.get(dupName);
		
						if (String.isNotBlank(dupId) && String.isNotBlank(ectIdSMS) && String.isNotBlank(ectIdVoiceCall)) {
							ContactPointConsent cpc;
		
							if (cpp.PhoneType == PHONETYPE_MOBILE) {
								ectId = ectIdSMS;
							} else if (cpp.PhoneType == PHONETYPE_HOME) {
								ectId = ectIdVoiceCall;
							}
		
							if (dupName == Outage_IncidentProcessor.DATAUSE_OUTAGES) {
								cppIdsOutageNotifications.add(cpp.Id);
								cpc = createNewContactPointConsentRecord(contactId, cpp.Id, dupId, ectId, privacyPolicy, authorisedToChange);
							}
							 else {
								cpc = createNewContactPointConsentRecord(contactId, cpp.Id, dupId, ectId, '', '');
							 }
		
							cpcRecordList.add(cpc);
						}
					} 
				}
			}
	
			if (!cpcRecordList.isEmpty()) {
			   insert cpcRecordList;
			}
	
			// Set isPrimary values for ContactPointEmail records for Outage Notifications scenarios
			if (!cpeIdsOutageNotifications.isEmpty()) {
	
				List<ContactPointEmail> cpeList =  getContactPointEmailRecordsByIdsOrIsPrimary(contactId, cpeIdsOutageNotifications);
				List<ContactPointEmail> cpeListToUpdate = new List<ContactPointEmail>();
	
				for (ContactPointEmail cpe : cpeList) {
	
					if (cpeIdsOutageNotifications.contains(cpe.Id)) {
						cpe.IsPrimary = true;
						cpeListToUpdate.add(cpe);
					}
				}
	
				update cpeListToUpdate;
			}
	
			// Set isPrimary values for ContactPointPhone records for Outage Notifications scenarios
			if (!cppIdsOutageNotifications.isEmpty()) {
	
				List<ContactPointPhone> cppList =  getContactPointPhoneRecordsByIdsOrIsPrimary(contactId, cppIdsOutageNotifications);
				List<ContactPointPhone> cppListToUpdate = new List<ContactPointPhone>();
	
				for (ContactPointPhone cpp : cppList) {
	
					if (cppIdsOutageNotifications.contains(cpp.Id)) {
						cpp.IsPrimary = true;
						cppListToUpdate.add(cpp);
					}
				}
	
				update cppListToUpdate;
			}
		}

		private void updateExistingActiveConsentsOutageNotifications (Set<String> excludedContactPoints, Id contactId, Map<String, Object> legalData) {
			String privacyPolicy = getPrivacyPolicyValue(legalData);
			String authorisedToChange = getAuthorisedToChangeValue(legalData);
			List<ContactPointConsent> cpcRecordList = new List<ContactPointConsent>();
	
			for (ContactPointConsent cpc : [SELECT Id, CaptureDate, CaptureSource, Privacy_Policy__c, Authorised_to_Change__c FROM ContactPointConsent WHERE Contact__c = :contactId AND ContactPointId NOT IN :excludedContactPoints AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE AND DataUsePurposeName__c = :Outage_IncidentProcessor.DATAUSE_OUTAGES]) {
				cpc.CaptureDate = Datetime.now();
				cpc.CaptureSource = CAPTURE_SRC_CALL_CENTRE;
				cpc.Privacy_Policy__c = privacyPolicy;
				cpc.Authorised_to_Change__c = authorisedToChange;
	
				cpcRecordList.add(cpc);
			}
	
			if (!cpcRecordList.isEmpty()) {
				update cpcRecordList;
			}
		}
	}

	// Inner class for exception handling
	public class CustomerConsentException extends Exception {

	}
}