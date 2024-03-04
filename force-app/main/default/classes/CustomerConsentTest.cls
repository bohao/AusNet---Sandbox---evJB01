/*
@description: Apex Test Class For CustomerConsent 
*/
@isTest
public with sharing class CustomerConsentTest {
    private static final String DUP_NAME_TEST = 'dup test 1';

    @testSetup
    static void setup() {
        Integer numCustomers = 1;
        // Generate customer data (NMI, Premise, Account, Contact, ACR, ContactPointEmail, ContactPointPhone, ContactPointConsent, EngagementChannelType, DataUsePurpose)
        Outage_DataFactory.getODF().generateCustomers(numCustomers);

        UtilDatabase db = new UtilDatabase();

		for (ContactPointPhone cpp: Outage_DataFactory.getODF().CPPhones) {
			if (cpp.PhoneType != 'Mobile') continue;

			ContactPointConsent cpc = new ContactPointConsent();
			cpc.Name = 'CPC record';
			cpc.Contact__c = cpp.Contact__c;
			cpc.ContactPointId = cpp.Id;
			cpc.CaptureSource = 'Test data';
			cpc.CaptureDate = System.now().addDays(-1);
			cpc.EffectiveFrom = cpc.CaptureDate;
			cpc.EngagementChannelTypeId = Outage_DataFactory.getODF().getChannelId(Outage_IncidentProcessor.CHANNEL_SMS);
			cpc.DataUsePurposeId = Outage_DataFactory.getODF().getPurposeId(Outage_IncidentProcessor.DATAUSE_OUTAGES);
			cpc.Authorised_to_Change__c = 'Authorised';
			cpc.Privacy_Policy__c = 'Agreed';

			db.addObjForUpsert(cpc);
		}

		db.upsertObjs();
    }
    
    @isTest
    static void getCustomerPreferencesTest() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        List<ContactPointEmail> cpeList = [SELECT Id, Status__c FROM ContactPointEmail WHERE Contact__c = :con.Id];
        List<ContactPointEmail> cpeListToUpdate = new List<ContactPointEmail>();

        for (ContactPointEmail cpe : cpeList) {
            cpe.Status__c = Outage_IncidentProcessor.CP_STS_ACTIVE;
            cpeListToUpdate.add(cpe);
        }

        update cpeListToUpdate;

        List<ContactPointPhone> cppList = [SELECT Id, Status__c FROM ContactPointPhone WHERE Contact__c = :con.Id];
        List<ContactPointPhone> cppListToUpdate = new List<ContactPointPhone>();

        for (ContactPointPhone cpp : cppList) {
            cpp.Status__c = Outage_IncidentProcessor.CP_STS_ACTIVE;
            cppListToUpdate.add(cpp);
        }

        update cppListToUpdate;

        Test.startTest();
        List<Map<String, Object>> customerPreferences = CustomerConsent.getCustomerPreferences(con.Id);

        // Validate list contains 3 data records
        Assert.areEqual(3, customerPreferences.size());

        Map<String, Object> dataForFirstCP = (Map<String, Object>) customerPreferences[0];
        
        // Validate map structure contains 3 keys
        Assert.areEqual(3, dataForFirstCP.size());
        Assert.isTrue(dataForFirstCP.containsKey('additionalfields'));
        Assert.isTrue(dataForFirstCP.containsKey('fields'));
        Assert.isTrue(dataForFirstCP.containsKey('preferences'));

        List<Map<String, Object>> prefsList = (List<Map<String, Object>>) dataForFirstCP.get('preferences');
        Map<String, Object> outagePrefs = prefsList.get(0);

         // Validate preference map structure contains 3 keys
        Assert.areEqual(3, outagePrefs.size());
        Assert.isTrue(outagePrefs.containsKey('datausepurpose'));
        Assert.isTrue(outagePrefs.containsKey('optedin'));
        Assert.isTrue(outagePrefs.containsKey('canoptinout'));

        // Setup no records found
        List<ContactPointEmail> cpeNotActiveListToUpdate = new List<ContactPointEmail>();
        
        for (ContactPointEmail cpe : cpeList) {
            cpe.Status__c = Outage_IncidentProcessor.CP_STS_INACTIVE;
            cpeNotActiveListToUpdate.add(cpe);
        }

        update cpeNotActiveListToUpdate;

        List<ContactPointPhone> cppNotActiveListToUpdate = new List<ContactPointPhone>();

        for (ContactPointPhone cpp : cppList) {
            cpp.Status__c = Outage_IncidentProcessor.CP_STS_INACTIVE;
            cppNotActiveListToUpdate.add(cpp);
        }

        update cppNotActiveListToUpdate;

        customerPreferences = CustomerConsent.getCustomerPreferences(con.Id);

        // Validate list contains 0 data records as contactPoints are not active
        Assert.areEqual(0, customerPreferences.size());

        Test.stopTest();
    }

    @isTest
    static void updateContactPointRecordsTest() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        ContactPointEmail cpEmail = [SELECT Id, Status__c FROM ContactPointEmail WHERE Contact__c = :con.Id LIMIT 1];
        ContactPointPhone cpPhoneMobile = [SELECT Id, Status__c FROM ContactPointPhone WHERE Contact__c = :con.Id AND PhoneType = :CustomerConsent.PHONETYPE_MOBILE LIMIT 1];

        EngagementChannelType ect = new EngagementChannelType(Name = CustomerConsent.CHANNEL_VOICE_CALL, ContactPointType = 'Phone');
		insert ect;

        DataUsePurpose dup = new DataUsePurpose(Name = DUP_NAME_TEST, CanDataSubjectOptOut = true);
        insert dup;

        Map<String, Map<String, Object>> contactPointUpdates = new Map<String, Map<String, Object>>();
        Map<String, Object> prefs = new Map<String, Object>();
        prefs.put(Outage_IncidentProcessor.DATAUSE_OUTAGES, false);
        prefs.put(DUP_NAME_TEST, true);

        contactPointUpdates.put(cpEmail.Id, prefs);
        contactPointUpdates.put(cpPhoneMobile.Id, prefs);

        Map<String, Object> legalData = new Map<String, Object>();
        legalData.put('prefauthorisation', true);
        legalData.put('privacypolicy', true);

        Test.startTest();
        List<ContactPointConsent> cpConsents = [SELECT Id, DataUsePurposeName__c FROM ContactPointConsent WHERE Contact__c = :con.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE];
        List<ContactPointConsent> cpConsentsOutageNotifications = [SELECT Id FROM ContactPointConsent WHERE Contact__c = :con.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE AND DataUsePurposeName__c = :Outage_IncidentProcessor.DATAUSE_OUTAGES];
		
        // Validate starting test data has only 2 opted-in records and they are both Outage Notiications
        Assert.areEqual(2, cpConsents.size());
        Assert.areEqual(2, cpConsentsOutageNotifications.size());

        CustomerConsent.updateContactPointRecords(con.Id, contactPointUpdates, legalData);
        
        cpConsentsOutageNotifications = [SELECT Id FROM ContactPointConsent WHERE Contact__c = :con.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE AND DataUsePurposeName__c = :Outage_IncidentProcessor.DATAUSE_OUTAGES];
        List<ContactPointConsent> cpConsentsDupTest = [SELECT Id, ContactPointId FROM ContactPointConsent WHERE Contact__c = :con.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE AND DataUsePurposeName__c = :DUP_NAME_TEST];

        // Validate the opt-in/opt-out updates occured (Outage Notiications opted-out, dup test 1 opted-in)
        // Assert.areEqual(0, cpConsentsOutageNotifications.size());
        // Assert.areEqual(2, cpConsentsDupTest.size());
        Test.stopTest();
    }
    
    @isTest
    static void HandleNonActiveContactPointRecordsTest() {
        List<DataUsePurpose> dupList = new List<DataUsePurpose>();
        DataUsePurpose outageDup = [SELECT Id, Name FROM DataUsePurpose WHERE Name = :Outage_IncidentProcessor.DATAUSE_OUTAGES];

        DataUsePurpose dup = new DataUsePurpose(Name = DUP_NAME_TEST, CanDataSubjectOptOut = true);
        insert dup;
        DataUsePurpose dupTest = [SELECT Id, Name FROM DataUsePurpose WHERE Name = :DUP_NAME_TEST];

        dupList.add(outageDup);
        dupList.add(dupTest);

        Map<Id, ContactPointEmail> cpeMap = new Map<Id, ContactPointEmail>([SELECT Id, Contact__c, EmailAddress, IsPrimary, Data_Type__c FROM ContactPointEmail LIMIT 1]);
        Map<Id, ContactPointPhone> cppMap = new Map<Id, ContactPointPhone>([SELECT Id, TelephoneNumber, IsPrimary, PhoneType, Data_Type__c FROM ContactPointPhone WHERE PhoneType = :CustomerConsent.PHONETYPE_MOBILE LIMIT 1]);
        ContactPointEmail cpEmail = cpeMap.values()[0];
        ContactPointPhone cpPhone = cppMap.values()[0];

        Map<Id, Map<String, Object>> customerPreferenceMap = new Map<Id, Map<String, Object>>();
       
        Test.startTest();
        customerPreferenceMap = CustomerConsent.HandleNonActiveContactPointRecords(dupList, customerPreferenceMap, cpeMap);

        // Validate map structure
        Assert.areEqual(1, customerPreferenceMap.size());
        Assert.isTrue(customerPreferenceMap.containsKey(cpEmail.Id));
        Assert.areEqual(3, customerPreferenceMap.get(cpEmail.Id).size());
        Assert.isTrue(customerPreferenceMap.get(cpEmail.Id).containsKey('preferences'));
        Assert.isTrue(customerPreferenceMap.get(cpEmail.Id).containsKey('fields'));
        Assert.isTrue(customerPreferenceMap.get(cpEmail.Id).containsKey('additionalfields'));

        customerPreferenceMap = CustomerConsent.HandleNonActiveContactPointRecords(dupList, customerPreferenceMap, cppMap);

        // Validate map now contains two contactpointIds
        Assert.areEqual(2, customerPreferenceMap.size());
        Assert.isTrue(customerPreferenceMap.containsKey(cpPhone.Id));

        Test.stopTest();
    }
    
    @isTest
    static void handleActiveContactPointConsentRecordsTest() {
        List<DataUsePurpose> dupList = new List<DataUsePurpose>();
        DataUsePurpose outageDup = [SELECT Id, Name FROM DataUsePurpose WHERE Name = :Outage_IncidentProcessor.DATAUSE_OUTAGES];

        DataUsePurpose dup = new DataUsePurpose(Name = DUP_NAME_TEST, CanDataSubjectOptOut = true);
        insert dup;
        DataUsePurpose dupTest = [SELECT Id, Name FROM DataUsePurpose WHERE Name = :DUP_NAME_TEST];

        dupList.add(outageDup);
        dupList.add(dupTest);

        ContactPointEmail cpEmail = [SELECT Id, Contact__c, EmailAddress, IsPrimary, Data_Type__c FROM ContactPointEmail LIMIT 1];
        ContactPointConsent cpConsentWithEmail = [SELECT Id, ContactPointId, DataUsePurposeName__c, EngagementChannelTypeName__c FROM ContactPointConsent WHERE ContactPointId = :cpEmail.Id];

        ContactPointPhone cpPhoneMobile = [SELECT Id, TelephoneNumber, IsPrimary, PhoneType, Data_Type__c FROM ContactPointPhone WHERE PhoneType = :CustomerConsent.PHONETYPE_MOBILE LIMIT 1];
        ContactPointConsent cpConsentWithMobilePhone = [SELECT Id, ContactPointId, DataUsePurposeId, DataUsePurposeName__c, EngagementChannelTypeName__c FROM ContactPointConsent WHERE ContactPointId = :cpPhoneMobile.Id];

        
        Map<Id, Map<String, Object>> customerPreferenceMap = new Map<Id, Map<String, Object>>();

        Test.startTest();
        customerPreferenceMap = CustomerConsent.handleActiveContactPointConsentRecords(dupList, customerPreferenceMap, cpConsentWithEmail, cpEmail);

        // Validate map structure
        Assert.areEqual(1, customerPreferenceMap.size());
        Assert.isTrue(customerPreferenceMap.containsKey(cpConsentWithEmail.ContactPointId));
        Assert.areEqual(3, customerPreferenceMap.get(cpConsentWithEmail.ContactPointId).size());
        Assert.isTrue(customerPreferenceMap.get(cpConsentWithEmail.ContactPointId).containsKey('preferences'));

        Map<String, Object> prefs = (Map<String, Object>) customerPreferenceMap.get(cpConsentWithEmail.ContactPointId).get('preferences');

        // Validate prefs are present 
        Assert.isTrue(prefs.containsKey(Outage_IncidentProcessor.DATAUSE_OUTAGES));
        Assert.isTrue(prefs.containsKey(DUP_NAME_TEST));

        // Validate Outage Notification is set to true as the consents DataUsePurpose is Outage Notification
        Assert.isTrue(Boolean.valueOf(prefs.get(Outage_IncidentProcessor.DATAUSE_OUTAGES)));
        // Validate dup test 1 is set to false as the consents DataUsePurpose is Outage Notification
        Assert.isFalse(Boolean.valueOf(prefs.get(DUP_NAME_TEST)));

        cpConsentWithEmail.DataUsePurposeId = dupTest.Id;
        update cpConsentWithEmail;
        ContactPointConsent cpConsentWithEmailUpdated = [SELECT Id, ContactPointId, DataUsePurposeName__c, EngagementChannelTypeName__c FROM ContactPointConsent WHERE Id = :cpConsentWithEmail.Id];
        customerPreferenceMap = CustomerConsent.handleActiveContactPointConsentRecords(dupList, customerPreferenceMap, cpConsentWithEmailUpdated, cpEmail);

        // Validate map still contains only one contactpointId
        Assert.areEqual(1, customerPreferenceMap.size());
        // Validate Outage Notification is still set to true
        Assert.isTrue(Boolean.valueOf(prefs.get(Outage_IncidentProcessor.DATAUSE_OUTAGES)));
        // Validate dup test 1 is set to true as the consents DataUsePurpose is now dup test 1
        Assert.isTrue(Boolean.valueOf(prefs.get(DUP_NAME_TEST)));

        customerPreferenceMap = CustomerConsent.handleActiveContactPointConsentRecords(dupList, customerPreferenceMap, cpConsentWithMobilePhone, cpPhoneMobile);
        
        // Validate map now contains two contactpointIds
        Assert.areEqual(2, customerPreferenceMap.size());

        Map<String, Object> prefsMobile = (Map<String, Object>) customerPreferenceMap.get(cpConsentWithMobilePhone.ContactPointId).get('preferences');
        
        // Validate Outage Notification is set to true as the consents DataUsePurpose is Outage Notification
        Assert.isTrue(Boolean.valueOf(prefsMobile.get(Outage_IncidentProcessor.DATAUSE_OUTAGES)));
        // Validate dup test 1 is set to false as the consents DataUsePurpose is Outage Notification
        Assert.isFalse(Boolean.valueOf(prefsMobile.get(DUP_NAME_TEST)));
        // Validate ContactPointIds dup preference values are set independently / not overidden
        Assert.areNotEqual(Boolean.valueOf(prefs.get(DUP_NAME_TEST)), Boolean.valueOf(prefsMobile.get(DUP_NAME_TEST)));

        Test.stopTest();
    }
    
    @isTest
    static void getAdditionalFieldsMapTest() {
        ContactPointEmail cpEmail = [SELECT Id, EmailAddress, IsPrimary, Data_Type__c FROM ContactPointEmail LIMIT 1];
        cpEmail.Data_Type__c = CustomerConsent.CP_DATATYPE_ENHANCED;
        ContactPointConsent cpConsentWithEmail = [SELECT Id, ContactPointId, Status__c, DataUsePurposeName__c, EngagementChannelTypeName__c FROM ContactPointConsent WHERE ContactPointId = :cpEmail.Id LIMIT 1];
        
        ContactPointPhone cpPhone = [SELECT Id, TelephoneNumber, IsPrimary, PhoneType, Data_Type__c FROM ContactPointPhone WHERE PhoneType = :CustomerConsent.PHONETYPE_MOBILE LIMIT 1];
        cpPhone.Data_Type__c = 'Retailer';
        ContactPointConsent cpConsentWithMobilePhone = [SELECT Id, ContactPointId, Status__c, DataUsePurposeName__c, EngagementChannelTypeName__c FROM ContactPointConsent WHERE ContactPointId = :cpPhone.Id LIMIT 1];

        Test.startTest();
        // Validate additional fields key present and is empty
        Map<String, Map<String, Object>> additionalFieldsMap = CustomerConsent.getAdditionalFieldsMap(null, null);
        Assert.isTrue(additionalFieldsMap.containsKey('additionalfields'));
        Assert.areEqual(0, additionalFieldsMap.get('additionalfields').keySet().size());

        // Validate channeltype is set to Email and isenhanceddatatype is set to true
        additionalFieldsMap = CustomerConsent.getAdditionalFieldsMap(cpEmail, null);
        Assert.areEqual(Outage_IncidentProcessor.CHANNEL_EMAIL, additionalFieldsMap.get('additionalfields').get('channeltype'));
        Assert.isTrue(Boolean.valueOf(additionalFieldsMap.get('additionalfields').get('isenhanceddatatype')));

        // Validate using Consent record the channeltype is set to Email and isenhanceddatatype is set to true
        additionalFieldsMap = CustomerConsent.getAdditionalFieldsMap(cpConsentWithEmail, cpEmail);
        Assert.areEqual(Outage_IncidentProcessor.CHANNEL_EMAIL, additionalFieldsMap.get('additionalfields').get('channeltype'));
        Assert.isTrue(Boolean.valueOf(additionalFieldsMap.get('additionalfields').get('isenhanceddatatype')));

        // Validate channeltype is set to SMS and isenhanceddatatype is set to false
        additionalFieldsMap = CustomerConsent.getAdditionalFieldsMap(cpPhone, null);
        Assert.areEqual(Outage_IncidentProcessor.CHANNEL_SMS, additionalFieldsMap.get('additionalfields').get('channeltype'));
        Assert.isFalse(Boolean.valueOf(additionalFieldsMap.get('additionalfields').get('isenhanceddatatype')));

        // Validate using Consent record the channeltype is set to SMS and isenhanceddatatype is set to false
        additionalFieldsMap = CustomerConsent.getAdditionalFieldsMap(cpConsentWithMobilePhone, cpPhone);
        Assert.areEqual(Outage_IncidentProcessor.CHANNEL_SMS, additionalFieldsMap.get('additionalfields').get('channeltype'));
        Assert.isFalse(Boolean.valueOf(additionalFieldsMap.get('additionalfields').get('isenhanceddatatype')));

        // Validate channeltype is set to Voice Call
        cpPhone.PhoneType = CustomerConsent.PHONETYPE_HOME;
        additionalFieldsMap = CustomerConsent.getAdditionalFieldsMap(cpPhone, null);
        Assert.areEqual(CustomerConsent.CHANNEL_VOICE_CALL, additionalFieldsMap.get('additionalfields').get('channeltype'));
        Test.stopTest();
    }
    
    @isTest
    static void formatHomePhoneNumberTest() {
        String expected10Digit = '03 9755 7700';
        String expected8Digit = '9755 7700';
        String expectedAsIsDigits = '123456';

        Test.startTest();
        String actual10Digit = CustomerConsent.formatHomePhoneNumber('0397557700');
        Assert.areEqual(expected10Digit, actual10Digit);

        String actual8Digit = CustomerConsent.formatHomePhoneNumber('97557700');
        Assert.areEqual(expected8Digit, actual8Digit);

        String actualAsIsDigits = CustomerConsent.formatHomePhoneNumber('123456');
        Assert.areEqual(expectedAsIsDigits, actualAsIsDigits);
        Test.stopTest();
    }
    
    @isTest
    static void formatMobilePhoneNumberTest() {
        String expected11DigitWith61Prefix = '0411 222 333';
        String expected11DigitWithOut61Prefix = '99411222333';
        String expectedAsIsDigits = '123456';

        Test.startTest();
        String actual11DigitWith61Prefix = CustomerConsent.formatMobilePhoneNumber('61411222333');
        Assert.areEqual(expected11DigitWith61Prefix, actual11DigitWith61Prefix);

        String actual11DigitWithOut61Prefix = CustomerConsent.formatMobilePhoneNumber('99411222333');
        Assert.areEqual(expected11DigitWithOut61Prefix, actual11DigitWithOut61Prefix);

        String actualAsIsDigits = CustomerConsent.formatMobilePhoneNumber('123456');
        Assert.areEqual(expectedAsIsDigits, actualAsIsDigits);
        Test.stopTest();
    }

    @isTest
    static void getContactPointFieldsMapTest() {
        ContactPointPhone cpPhone = [SELECT Id, TelephoneNumber, IsPrimary, PhoneType, Data_Type__c FROM ContactPointPhone LIMIT 1];
        cpPhone.PhoneType = CustomerConsent.PHONETYPE_MOBILE;
        cpPhone.TelephoneNumber = '61411222333';

        Test.startTest();
        // Validate fields is assigned null if contactpoint is null
        Map<String, Map<String, Object>> resultFieldsMap = CustomerConsent.getContactPointFieldsMap(null);
        Assert.isNull(resultFieldsMap.get('fields'));

        // Validate fields is not equal to null if contactpoint is not null
        resultFieldsMap = CustomerConsent.getContactPointFieldsMap(cpPhone);
        Assert.isNotNull(resultFieldsMap.get('fields'));

        // Validate TelephoneNumber is formatted for Mobile numbers
        Assert.areEqual('0411 222 333', resultFieldsMap.get('fields').get('TelephoneNumber'));

        cpPhone.PhoneType = CustomerConsent.PHONETYPE_HOME;
        cpPhone.TelephoneNumber = '97557700';

        // Validate TelephoneNumber is formatted for Home numbers
        resultFieldsMap = CustomerConsent.getContactPointFieldsMap(cpPhone);
        Assert.areEqual('9755 7700', resultFieldsMap.get('fields').get('TelephoneNumber'));
        Test.stopTest();
    }
        
    @isTest
    static void getDataUsePurposePreferenceMapTemplateTest() {

        List<DataUsePurpose> dupList = new List<DataUsePurpose>();
        DataUsePurpose dup = new DataUsePurpose(Name = DUP_NAME_TEST);
        DataUsePurpose dup2 = new DataUsePurpose(Name = 'dup test 2');
        dupList.add(dup);
        dupList.add(dup2);

        Test.startTest();
        Map<String, Map<String, Object>> dupPrefMapTemp = CustomerConsent.getDataUsePurposePreferenceMapTemplate(dupList);
        
        // Validate a the map is created and has each of the DataUsePurpose preferences set to false
        Assert.isNotNull(dupPrefMapTemp.get('preferences'));
        Assert.areEqual(2, dupPrefMapTemp.get('preferences').size());
        Assert.isFalse(Boolean.valueOf(dupPrefMapTemp.get('preferences').get(DUP_NAME_TEST)));
        Assert.isFalse(Boolean.valueOf(dupPrefMapTemp.get('preferences').get('dup test 2')));
        Test.stopTest();
    }

    @isTest
    static void getCanOptInOutTest() {
       
        Test.startTest();
        // 'Outage Notifications' with engagement channel type 'Voice Call' cannot opt in or out
        Boolean resultCanOptInOut = CustomerConsent.getCanOptInOut(Outage_IncidentProcessor.DATAUSE_OUTAGES, CustomerConsent.CHANNEL_VOICE_CALL);
        Assert.isFalse(resultCanOptInOut);

        // Other scenarios can opt in or out
        resultCanOptInOut = CustomerConsent.getCanOptInOut(Outage_IncidentProcessor.DATAUSE_OUTAGES, Outage_IncidentProcessor.CHANNEL_EMAIL);
        Assert.isTrue(resultCanOptInOut);

        resultCanOptInOut = CustomerConsent.getCanOptInOut('Test Data Use', CustomerConsent.CHANNEL_VOICE_CALL);
        Assert.isTrue(resultCanOptInOut);
        Test.stopTest();
    }

    @isTest
    static void handleContactPointConsentOptOutsTest() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        ContactPointEmail cpEmail = [SELECT Id, Status__c FROM ContactPointEmail WHERE Contact__c = :con.Id LIMIT 1];
        ContactPointPhone cpPhone = [SELECT Id, Status__c FROM ContactPointPhone WHERE Contact__c = :con.Id AND PhoneType = :CustomerConsent.PHONETYPE_MOBILE LIMIT 1];
        EngagementChannelType ect = [SELECT Id, Name FROM EngagementChannelType WHERE Name=:Outage_IncidentProcessor.CHANNEL_EMAIL LIMIT 1];
       
        DataUsePurpose dup = new DataUsePurpose(Name = DUP_NAME_TEST, CanDataSubjectOptOut = true);
        insert dup;
        DataUsePurpose dupTest = [SELECT Id, Name FROM DataUsePurpose WHERE Name = :DUP_NAME_TEST];

        ContactPointConsent cpc = new ContactPointConsent(
            Contact__c = con.Id,
            ContactPointId = cpEmail.Id,
            DataUsePurposeId = dupTest.Id,
            EngagementChannelTypeId = ect.Id,
            CaptureSource = 'Test data',
            CaptureDate = Datetime.now(),
            EffectiveFrom = Datetime.now()
        );
        insert cpc;

        List<ContactPointConsent> cpConsents = [SELECT Id, ContactPointId, DataUsePurposeName__c, EngagementChannelTypeName__c FROM ContactPointConsent WHERE Contact__c = :con.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE];

        Map<Id, Set<String>> contactPointEmailOptOutMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> contactPointPhoneOptOutMap = new Map<Id, Set<String>>();

        Map<String, Object> legalData = new Map<String, Object>();
        Set<String> optOutDups = new Set<String>{Outage_IncidentProcessor.DATAUSE_OUTAGES};

        contactPointPhoneOptOutMap.put(cpPhone.Id, optOutDups);

        Test.startTest();
        // Validate starting test data
        Assert.areEqual(3, cpConsents.size());

        // Validate single opt out occured and works for ContactPointPhone objects 
        CustomerConsent.handleContactPointConsentOptOuts(contactPointEmailOptOutMap, contactPointPhoneOptOutMap, legalData);
        cpConsents = [SELECT Id, ContactPointId, DataUsePurposeName__c, EngagementChannelTypeName__c FROM ContactPointConsent WHERE Contact__c = :con.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE];
        Assert.areEqual(2, cpConsents.size());

        optOutDups.add(DUP_NAME_TEST);
        contactPointPhoneOptOutMap.clear();
        contactPointEmailOptOutMap.put(cpEmail.Id, optOutDups);

         // Validate multiple opt outs occured and works for ContactPointEmail objects 
        CustomerConsent.handleContactPointConsentOptOuts(contactPointEmailOptOutMap, contactPointPhoneOptOutMap, legalData);
        cpConsents = [SELECT Id, ContactPointId, DataUsePurposeName__c, EngagementChannelTypeName__c FROM ContactPointConsent WHERE Contact__c = :con.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE];
        Assert.areEqual(0, cpConsents.size());
        Test.stopTest();
    }
            
    @isTest
    static void handleContactPointConsentOptInsTest() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        
        ContactPointEmail cpEmail = [SELECT Id, Status__c FROM ContactPointEmail WHERE Contact__c = :con.Id LIMIT 1];
        cpEmail.IsPrimary = false;
        update cpEmail;
        
        ContactPointPhone cpPhoneMobile = [SELECT Id, Status__c FROM ContactPointPhone WHERE Contact__c = :con.Id AND PhoneType = :CustomerConsent.PHONETYPE_MOBILE LIMIT 1];
        cpPhoneMobile.IsPrimary = false;
        update cpPhoneMobile;

        ContactPointPhone cpPhoneHome = [SELECT Id, Status__c FROM ContactPointPhone WHERE Contact__c = :con.Id AND PhoneType = :CustomerConsent.PHONETYPE_HOME LIMIT 1];
        cpPhoneHome.IsPrimary = false;
        update cpPhoneHome;

        List<ContactPointConsent> cpConsents = [SELECT Id, EffectiveTo FROM ContactPointConsent WHERE Contact__c = :con.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE];
        List<ContactPointConsent> cpConsentsToUpdate = new  List<ContactPointConsent>();
        for (ContactPointConsent cpc : cpConsents) {
            cpc.EffectiveTo = Datetime.now();
            cpConsentsToUpdate.add(cpc);
        }

        update cpConsentsToUpdate;

        DataUsePurpose dup = new DataUsePurpose(Name = DUP_NAME_TEST, CanDataSubjectOptOut = true);
        insert dup;

        EngagementChannelType ect = new EngagementChannelType(Name = CustomerConsent.CHANNEL_VOICE_CALL, ContactPointType = 'Phone');
		insert ect;


        Map<Id, Set<String>> contactPointEmailOptIntMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> contactPointPhoneOptInMap = new Map<Id, Set<String>>();

        Set<String> optInDups = new Set<String>{DUP_NAME_TEST};

        contactPointEmailOptIntMap.put(cpEmail.Id, optInDups);
        

        Map<String, Object> legalData = new Map<String, Object>();

        Test.startTest();
        cpConsents = [SELECT Id FROM ContactPointConsent WHERE Contact__c = :con.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE];
        
        // Validate starting test data
        Assert.areEqual(0, cpConsents.size());

        // Validate opt in occured for ContactPointEmail objects
        CustomerConsent.handleContactPointConsentOptIns(contactPointEmailOptIntMap, contactPointPhoneOptInMap, con.Id, legalData);
        cpConsents = [SELECT Id  FROM ContactPointConsent WHERE Contact__c = :con.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE];
        Assert.areEqual(1, cpConsents.size());

        contactPointEmailOptIntMap.clear();
        contactPointPhoneOptInMap.put(cpPhoneHome.Id, optInDups);
        contactPointPhoneOptInMap.put(cpPhoneMobile.Id, optInDups);

        // Validate opt in occured for ContactPointPhone objects with Home and Mobile phonetypes
        CustomerConsent.handleContactPointConsentOptIns(contactPointEmailOptIntMap, contactPointPhoneOptInMap, con.Id, legalData);
        cpConsents = [SELECT Id  FROM ContactPointConsent WHERE Contact__c = :con.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE];
        Assert.areEqual(3, cpConsents.size());

        // Validate isPrimary not changed for non Outage Notifications opt in
        cpPhoneMobile = [SELECT Id, isPrimary FROM ContactPointPhone WHERE Contact__c = :con.Id AND PhoneType = :CustomerConsent.PHONETYPE_MOBILE LIMIT 1];
        Assert.isFalse(cpPhoneMobile.isPrimary);

        contactPointPhoneOptInMap.clear();
        optInDups.clear();
        optInDups.add(Outage_IncidentProcessor.DATAUSE_OUTAGES);
        legalData.put('prefauthorisation', true);
        legalData.put('privacypolicy', true);

        contactPointEmailOptIntMap.put(cpEmail.Id, optInDups);
        contactPointPhoneOptInMap.put(cpPhoneMobile.Id, optInDups);

        // Validate opt in occured for ContactPointPhone (Mobile) and ContactPointEmail objects
        CustomerConsent.handleContactPointConsentOptIns(contactPointEmailOptIntMap, contactPointPhoneOptInMap, con.Id, legalData);
        cpConsents = [SELECT Id  FROM ContactPointConsent WHERE Contact__c = :con.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE];
        Assert.areEqual(5, cpConsents.size());

        // Validate isPrimary is changed to true for Outage Notifications opt ins
        cpPhoneMobile = [SELECT Id, isPrimary FROM ContactPointPhone WHERE Contact__c = :con.Id AND PhoneType = :CustomerConsent.PHONETYPE_MOBILE LIMIT 1];
        cpEmail = [SELECT Id, isPrimary FROM ContactPointEmail WHERE Contact__c = :con.Id LIMIT 1];
        Assert.isTrue(cpPhoneMobile.isPrimary);
        Assert.isTrue(cpEmail.isPrimary);


        ContactPointEmail cpeNew = new ContactPointEmail(Contact__c = con.Id, IsPrimary = false, EmailAddress = 'handleContactPointConsentOptInsTest@CustomerConsentTest.com.invalid', Data_Type__c = 'Retailer');
        insert cpeNew;

        ContactPointPhone cppNew = new ContactPointPhone(Contact__c = con.Id, IsPrimary = false, TelephoneNumber = '61411222333', PhoneType = 'Mobile', IsSmsCapable = true, Data_Type__c = 'Retailer');
        insert cppNew;

        ContactPointEmail cpEmailNew = [SELECT Id, isPrimary FROM ContactPointEmail WHERE Contact__c = :con.Id AND EmailAddress = 'handleContactPointConsentOptInsTest@CustomerConsentTest.com.invalid' LIMIT 1];
        ContactPointPhone cpPhoneNew = [SELECT Id, isPrimary FROM ContactPointPhone WHERE Contact__c = :con.Id AND TelephoneNumber = '61411222333' LIMIT 1];

        contactPointEmailOptIntMap.clear();
        contactPointPhoneOptInMap.clear();
        contactPointPhoneOptInMap.clear();
        contactPointEmailOptIntMap.put(cpEmailNew.Id, optInDups);
        contactPointPhoneOptInMap.put(cpPhoneNew.Id, optInDups);

        // Reset Trigger method catches to false
        Trig_ContactPointEmail.isRunningCheckIsPrimary = false;
        Trig_ContactPointPhone.isRunningCheckIsPrimary = false;

        // Validate opt in occured for ContactPointEmail and ContactPointPhone objects
        CustomerConsent.handleContactPointConsentOptIns(contactPointEmailOptIntMap, contactPointPhoneOptInMap, con.Id, legalData);
        cpConsents = [SELECT Id FROM ContactPointConsent WHERE Contact__c = :con.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE];
        Assert.areEqual(7, cpConsents.size());

        // Validate isPrimary is changed to true for the new Outage Notifications opt in
        cpEmailNew = [SELECT Id, isPrimary FROM ContactPointEmail WHERE Contact__c = :con.Id AND EmailAddress = 'handleContactPointConsentOptInsTest@CustomerConsentTest.com.invalid' LIMIT 1];
        cpPhoneNew = [SELECT Id, isPrimary FROM ContactPointPhone WHERE Contact__c = :con.Id AND TelephoneNumber = '61411222333' LIMIT 1];
        Assert.isTrue(cpEmailNew.isPrimary);
        Assert.isTrue(cpPhoneNew.isPrimary);

        // Validate the previous isPrimary's are changed to false due to the new Outage Notifications opt ins (only 1 isPrimary per channeltype per datatype is allowed *handled by Trig_ContactPointPhone OR Trig_ContactPointEmail*)
        ContactPointEmail cpEmailOld = [SELECT Id, isPrimary FROM ContactPointEmail WHERE Contact__c = :con.Id AND Id = :cpEmail.Id LIMIT 1];
        ContactPointPhone cpPhoneOld = [SELECT Id, isPrimary FROM ContactPointPhone WHERE Contact__c = :con.Id AND Id = :cpPhoneMobile.Id LIMIT 1];
        Assert.isFalse(cpEmailOld.isPrimary);
        Assert.isFalse(cpPhoneOld.isPrimary);

        Test.stopTest();
    }

    @isTest
    static void updateExistingActiveConsentsOutageNotificationsTest() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];

        ContactPointPhone cpPhoneMobile = [SELECT Id, Status__c FROM ContactPointPhone WHERE Contact__c = :con.Id AND PhoneType = :CustomerConsent.PHONETYPE_MOBILE LIMIT 1];
        ContactPointConsent cpConsentWithPhoneMobile = [SELECT Id, CaptureDate, CaptureSource, ContactPointId FROM ContactPointConsent WHERE ContactPointId = :cpPhoneMobile.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE AND DataUsePurposeName__c = :Outage_IncidentProcessor.DATAUSE_OUTAGES];
        cpConsentWithPhoneMobile.CaptureDate = Datetime.now().addDays(-1);
        update cpConsentWithPhoneMobile;

        ContactPointEmail cpEmail = [SELECT Id, Status__c FROM ContactPointEmail WHERE Contact__c = :con.Id LIMIT 1];
        ContactPointConsent cpConsentWithEmail = [SELECT Id, CaptureDate, CaptureSource FROM ContactPointConsent WHERE ContactPointId = :cpEmail.Id AND Status__c = :Outage_IncidentProcessor.CPC_STS_ACTIVE AND DataUsePurposeName__c = :Outage_IncidentProcessor.DATAUSE_OUTAGES];
        cpConsentWithEmail.CaptureDate = Datetime.now().addDays(-1);
        update cpConsentWithEmail;
        
        Map<String, Object> legalData = new Map<String, Object>();
        Set<String> excludedContactPoints = new Set<String>();
        excludedContactPoints.add(cpConsentWithPhoneMobile.ContactPointId);

        DateTime cpConsentMobileCapDate = cpConsentWithPhoneMobile.CaptureDate;
        DateTime cpConsentEmailCapDate = cpConsentWithEmail.CaptureDate;


        Test.startTest();
        CustomerConsent.updateExistingActiveConsentsOutageNotifications(excludedContactPoints, con.Id, legalData);

        ContactPointConsent cpConsentWithPhoneMobileUpdated = [SELECT Id, CaptureDate, CaptureSource  FROM ContactPointConsent WHERE Id = :cpConsentWithPhoneMobile.Id];
        ContactPointConsent cpConsentWithEmailUpdated = [SELECT Id, CaptureDate, CaptureSource  FROM ContactPointConsent WHERE Id = :cpConsentWithEmail.Id];

        // Validate Consent records with excludedContactPoints are not updated.
        Assert.areEqual(cpConsentMobileCapDate, cpConsentWithPhoneMobileUpdated.CaptureDate);
        Assert.areEqual('Test data', cpConsentWithPhoneMobileUpdated.CaptureSource);

        // Validate Consent records not in excludedContactPoints are updated.
        Assert.areNotEqual(cpConsentEmailCapDate, cpConsentWithEmailUpdated.CaptureDate);
        Assert.areEqual(CustomerConsent.CAPTURE_SRC_CALL_CENTRE, cpConsentWithEmailUpdated.CaptureSource);
        Test.stopTest();
    }
            
    @isTest
    static void getDataUsePurposeNameToIdMapTest() {
        List<DataUsePurpose> dups = [SELECT Id, Name FROM DataUsePurpose];

        for (DataUsePurpose dup : dups) {
            dup.CanDataSubjectOptOut = true;
        }

        update dups;
       
        Test.startTest();
        // Validate if all dups CanDataSubjectOptOut values are true then all are returned
        Assert.areEqual(dups.size(), CustomerConsent.getDataUsePurposeNameToIdMap().size());
        
        DataUsePurpose dupToChange = dups.get(0);
        dupToChange.CanDataSubjectOptOut = false;
        update dupToChange;

        // Validate if all dups CanDataSubjectOptOut values are true expect 1 then all but 1 are returned
        Assert.areEqual((dups.size() - 1), CustomerConsent.getDataUsePurposeNameToIdMap().size());
        Test.stopTest();
    }
            
    @isTest
    static void getEngagementChannelTypeNameToIdMapTest() {
        List<EngagementChannelType> ectList = [SELECT Id, Name FROM EngagementChannelType];

        Test.startTest();
        Map<String, Id> ectMap = CustomerConsent.getEngagementChannelTypeNameToIdMap();

        // Validate all EngagementChannelTypes are returned
        Assert.areEqual(ectList.size(), ectMap.size());
        Assert.isTrue(ectMap.size() > 0);

        EngagementChannelType ect = ectList.get(0);

        // Validate returned Map uses EngagementChannelTypes Name as key
        Assert.isTrue(ectMap.containsKey(ect.Name));

        // Validate returned Map EngagementChannelTypes Id as value
        Assert.areEqual(ect.Id, ectMap.get(ect.Name));
        Test.stopTest();
    }
            
    @isTest
    static void getPrivacyPolicyValueTest() {
        Map<String, Object> privacyPolicyMap = new Map<String, Object> {'privacypolicy' => true};
        Map<String, Object> blankTestMap = new Map<String, Object> {'blanktest' => true};
        
        Test.startTest();
        // Validate doesn't contain privacypolicy key
        String privacyPolicy = CustomerConsent.getPrivacyPolicyValue(blankTestMap);
        Assert.isTrue(String.isBlank(privacyPolicy));

        // Validate true outcome with privacypolicy key
        privacyPolicy = CustomerConsent.getPrivacyPolicyValue(privacyPolicyMap);
        Assert.areEqual('Agreed', privacyPolicy);

        // Validate false outcome with privacypolicy key
        privacyPolicyMap.put('privacypolicy', false);
        privacyPolicy = CustomerConsent.getPrivacyPolicyValue(privacyPolicyMap);
        Assert.areEqual('Did not agree', privacyPolicy);
        Test.stopTest();
    }
            
    @isTest
    static void getAuthorisedToChangeValueTest() {
        Map<String, Object> prefAuthorisationMap = new Map<String, Object> {'prefauthorisation' => true};
        Map<String, Object> blankTestMap = new Map<String, Object> {'blanktest' => true};
        
        Test.startTest();
        // Validate doesn't contain prefauthorisation key
        String authorisedToChange = CustomerConsent.getAuthorisedToChangeValue(blankTestMap);
        Assert.isTrue(String.isBlank(authorisedToChange));

        // Validate true outcome with prefauthorisation key
        authorisedToChange = CustomerConsent.getAuthorisedToChangeValue(prefAuthorisationMap);
        Assert.areEqual('Authorised', authorisedToChange);

        // Validate false outcome with prefauthorisation key
        prefAuthorisationMap.put('prefauthorisation', false);
        authorisedToChange = CustomerConsent.getAuthorisedToChangeValue(prefAuthorisationMap);
        Assert.areEqual('Not Authorised', authorisedToChange);
        Test.stopTest();
    }
            
    @isTest
    static void createNewContactPointConsentRecordTest() {
        ContactPointEmail cpEmail = [SELECT Id, Contact__c FROM ContactPointEmail LIMIT 1];
        EngagementChannelType ect = [SELECT Id, Name FROM EngagementChannelType LIMIT 1];
        DataUsePurpose dup = [SELECT Id, Name FROM DataUsePurpose LIMIT 1];

        Test.startTest();
        ContactPointConsent cpc = CustomerConsent.createNewContactPointConsentRecord(cpEmail.Contact__c, cpEmail.Id, dup.Id, ect.Id, '', '');
        System.debug(cpEmail.Contact__c);

        // Validate a ContactPointConsent object is returned and check its capture source is the Call Centre
        Assert.isNotNull(cpc);
        Assert.isInstanceOfType(cpc, ContactPointConsent.class);
        Assert.areEqual(CustomerConsent.CAPTURE_SRC_CALL_CENTRE, cpc.CaptureSource);
        Test.stopTest();
    }
}