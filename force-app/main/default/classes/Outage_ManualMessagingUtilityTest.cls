@isTest
public class Outage_ManualMessagingUtilityTest {
	@TestSetup
    public static void createTestData() {
        // Create Test data
        
    }
    
    @IsTest
    public static void test01_getTemplateData(){
        Test.startTest();
        
        Map<String,Map<String,List<String>>> result=Outage_ManualMessagingUtility.getMMPickLists();
        
     
        Test.stopTest();
    }
    
    
    @IsTest
    public static void test02_getTranslatedDataContactSMS(){
        Test.startTest();
        Outage_ManualMessagingUtility mmmu = new Outage_ManualMessagingUtility();
        Contact contactRecord = new Contact(FirstName='CityGen',LastName='CityGen',Email='cgen@c.com',MobilePhone='0490213214',OtherPhone='422244222');
        INSERT contactRecord;
        DataUsePurpose dup = new DataUsePurpose(Name='Outage Notifications');
        INSERT dup;
        ContactPointPhone phone = new ContactPointPhone(Contact__c=contactRecord.Id,IsPrimary=true,IsSmsCapable=true, TelephoneNumber='1234567890');
        INSERT phone;
        ContactPointConsent consent = new ContactPointConsent(Name='Test Consent', Contact__c=contactRecord.Id,ContactPointId=phone.Id,DataUsePurposeId=dup.Id,EffectiveFrom=DateTime.now());
        INSERT consent;
        mmmu.rec.ContactId = contactRecord.Id;
        mmmu.rec.mode ='Send';
        mmmu.rec.ScheduledDateTime = '';
        mmmu.rec.overrideCustPref = 'No';
        mmmu.rec.channel = 'SMS';
        mmmu.rec.msgBody = 'Dear %%FirstName%% %%LastName%%';
        
        Map<String, Object> tm = Outage_ManualMessagingUtility.translateMessagesForMM(mmmu.rec);
        
        Test.stopTest();
    }
    
    @IsTest
    public static void test03_getTranslatedDataIncidentEmail(){
        Test.startTest();
        Outage_ManualMessagingUtility mmmu = new Outage_ManualMessagingUtility();
        Contact contactRecord = new Contact(FirstName='CityGen',LastName='CityGen',Email='cgen@c.com',MobilePhone='0490213214',OtherPhone='422244222');
        INSERT contactRecord;
        DataUsePurpose dup = new DataUsePurpose(Name='Outage Notifications');
        INSERT dup;
        ContactPointEmail email = new ContactPointEmail(Contact__c=contactRecord.Id,IsPrimary=true, EmailAddress='1234567890@1.com');
        INSERT email;
        ContactPointConsent consent = new ContactPointConsent(Name='Test Consent', Contact__c=contactRecord.Id,ContactPointId=email.Id,DataUsePurposeId=dup.Id,EffectiveFrom=DateTime.now());
        INSERT consent;
        Incident inc = new Incident(Subject='INC-001',uom_Incident_Id__c='INC-001',Status='Open',Priority='1');
        INSERT inc;
        vlocity_cmt__Premises__c prem = new vlocity_cmt__Premises__c(Name='Test',vlocity_cmt__PostalCode__c='23134',vlocity_cmt__City__c='NSW',vlocity_cmt__State__c='VIC',vlocity_cmt__StreetAddress__c='NSW Street');
        INSERT prem;
        vlocity_cmt__ServicePoint__c sp = new vlocity_cmt__ServicePoint__c(Name='Test Service point',vlocity_cmt__ServiceType__c='Electricity', vlocity_cmt__PremisesId__c=prem.Id);
        INSERT sp;
        Affected_Market_Identifier__c affMI = new Affected_Market_Identifier__c(Name='1234567890',uom_Incident__c=inc.Id,uom_Service_Point__c=sp.Id,uom_Unique_Market_Identifier__c='1234567890',uom_Status__c='In Progress');
        INSERT affMI;
        Affected_Customer__c af = new 	Affected_Customer__c(Name=contactRecord.Name, uom_Contact__c=contactRecord.Id, uom_Incident__c=inc.Id,uom_Affected_Market_Identifier__c=affMI.Id);
        INSERT af;
        mmmu.rec.ContactId = '';
        mmmu.rec.IncidentId = inc.Id;
        mmmu.rec.mode ='Schedule';
        mmmu.rec.ScheduledDateTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        mmmu.rec.overrideCustPref = 'Yes';
        mmmu.rec.channel = 'Email';
        mmmu.rec.msgBody = 'Dear %%FirstName%% %%LastName%%';
        mmmu.rec.subject = 'Dear';
        Map<String, Object> tm = Outage_ManualMessagingUtility.translateMessagesForMM(mmmu.rec);
        
        Test.stopTest();
        
    }
    
    
    
    @IsTest
    public static void test05_getTranslatedDataContactEmail(){
        Test.startTest();
        Outage_ManualMessagingUtility mmmu = new Outage_ManualMessagingUtility();
        Contact contactRecord = new Contact(FirstName='CityGen',LastName='CityGen',Email='cgen@c.com',MobilePhone='0490213214',OtherPhone='422244222');
        INSERT contactRecord;
        DataUsePurpose dup = new DataUsePurpose(Name='Outage Notifications');
        INSERT dup;
        ContactPointEmail email = new ContactPointEmail(Contact__c=contactRecord.Id,IsPrimary=true, EmailAddress='1234567890@1.com');
        INSERT email;
        ContactPointConsent consent = new ContactPointConsent(Name='Test Consent', Contact__c=contactRecord.Id,ContactPointId=email.Id,DataUsePurposeId=dup.Id,EffectiveFrom=DateTime.now());
        INSERT consent;
        mmmu.rec.ContactId = contactRecord.Id;
        mmmu.rec.mode ='Send';
        mmmu.rec.ScheduledDateTime = '';
        mmmu.rec.overrideCustPref = 'No';
        mmmu.rec.channel = 'Email';
        mmmu.rec.msgBody = 'Dear %%FirstName%% %%LastName%%';
        mmmu.rec.subject = 'Dear';
        Map<String, Object> tm = Outage_ManualMessagingUtility.translateMessagesForMM(mmmu.rec);
        
        Test.stopTest();
    }
    
    @IsTest
    public static void test06_getTranslatedDataIncidentSms(){
        Test.startTest();
        Outage_ManualMessagingUtility mmmu = new Outage_ManualMessagingUtility();
        Contact contactRecord = new Contact(FirstName='CityGen',LastName='CityGen',Email='cgen@c.com',MobilePhone='0490213214',OtherPhone='422244222');
        INSERT contactRecord;
        DataUsePurpose dup = new DataUsePurpose(Name='Outage Notifications');
        INSERT dup;
        ContactPointPhone phone = new ContactPointPhone(Contact__c=contactRecord.Id,IsPrimary=true,IsSmsCapable=true, TelephoneNumber='1234567890');
        INSERT phone;
        ContactPointConsent consent = new ContactPointConsent(Name='Test Consent', Contact__c=contactRecord.Id,ContactPointId=phone.Id,DataUsePurposeId=dup.Id,EffectiveFrom=DateTime.now());
        INSERT consent;
        Incident inc = new Incident(Subject='INC-001',uom_Incident_Id__c='INC-001',Status='Open',Priority='1');
        INSERT inc;
        vlocity_cmt__Premises__c prem = new vlocity_cmt__Premises__c(Name='Test',vlocity_cmt__PostalCode__c='23134',vlocity_cmt__City__c='NSW',vlocity_cmt__State__c='VIC',vlocity_cmt__StreetAddress__c='NSW Street');
        INSERT prem;
        vlocity_cmt__ServicePoint__c sp = new vlocity_cmt__ServicePoint__c(Name='Test Service point',vlocity_cmt__ServiceType__c='Electricity', vlocity_cmt__PremisesId__c=prem.Id);
        INSERT sp;
        Affected_Market_Identifier__c affMI = new Affected_Market_Identifier__c(Name='1234567890',uom_Incident__c=inc.Id,uom_Service_Point__c=sp.Id,uom_Unique_Market_Identifier__c='1234567890',uom_Status__c='In Progress');
        INSERT affMI;
        Affected_Customer__c af = new 	Affected_Customer__c(Name=contactRecord.Name, uom_Contact__c=contactRecord.Id, uom_Incident__c=inc.Id,uom_Affected_Market_Identifier__c=affMI.Id);
        INSERT af;
        mmmu.rec.ContactId = '';
        mmmu.rec.IncidentId = inc.Id;
        mmmu.rec.mode ='Schedule';
        mmmu.rec.ScheduledDateTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        mmmu.rec.overrideCustPref = 'Yes';
        mmmu.rec.channel = 'SMS';
        mmmu.rec.msgBody = 'Dear %%FirstName%% %%LastName%% %%IncidentNumber%% ';
        
        Map<String, Object> tm = Outage_ManualMessagingUtility.translateMessagesForMM(mmmu.rec);
        
        Test.stopTest();
    }
    
        @IsTest
    public static void test07_getTranslatedDataCampaignSms(){
        Test.startTest();
        Outage_ManualMessagingUtility mmmu = new Outage_ManualMessagingUtility();
        Contact contactRecord = new Contact(FirstName='CityGen',LastName='CityGen',Email='cgen@c.com',MobilePhone='0490213214',OtherPhone='422244222');
        INSERT contactRecord;
        DataUsePurpose dup = new DataUsePurpose(Name='Outage Notifications');
        INSERT dup;
        ContactPointPhone phone = new ContactPointPhone(Contact__c=contactRecord.Id,IsPrimary=true,IsSmsCapable=true, TelephoneNumber='1234567890');
        INSERT phone;
        ContactPointConsent consent = new ContactPointConsent(Name='Test Consent', Contact__c=contactRecord.Id,ContactPointId=phone.Id,DataUsePurposeId=dup.Id,EffectiveFrom=DateTime.now());
        INSERT consent;
        Campaign camp = new Campaign(Name='Testing Camp');
        INSERT camp;
        vlocity_cmt__Premises__c premiseData = new vlocity_cmt__Premises__c(vlocity_cmt__City__c='HIGHETT',vlocity_cmt__Country__c='AU', vlocity_cmt__PostalCode__c ='3190',vlocity_cmt__StreetAddress__c = '16 PRINCESS AVE HIGHETT' );
        INSERT premiseData;
        vlocity_cmt__ServicePoint__c servicePoint = new vlocity_cmt__ServicePoint__c(vlocity_cmt__MarketIdentifier__c='6305098567', vlocity_cmt__PremisesId__c = premiseData.Id);
        INSERT servicePoint;
        CampaignMember cm = new CampaignMember(CampaignId=camp.Id,ContactId=contactRecord.Id, Service_Point__c = servicePoint.Id);
        INSERT cm;
        mmmu.rec.ContactId = '';
        mmmu.rec.IncidentId = '';
        mmmu.rec.CampaignId= camp.Id;
        mmmu.rec.mode ='Send';
        mmmu.rec.ScheduledDateTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        mmmu.rec.overrideCustPref = 'Yes';
        mmmu.rec.channel = 'SMS';
        mmmu.rec.msgBody = 'Dear Customer';
        
        Map<String, Object> tm = Outage_ManualMessagingUtility.translateMessagesForMM(mmmu.rec);
        
        Test.stopTest();
    }
         @IsTest
    public static void test08_getTranslatedDataCampaignEmail()
    {
        CE_ContactPointSync2.isRunningContactUpdate = true;
        CE_ContactPointSync2.isRunningCPPCPEUpdate  = true;
        Test.startTest();
        Outage_ManualMessagingUtility mmmu = new Outage_ManualMessagingUtility();
        Contact contactRecord = new Contact(FirstName='CityGen',LastName='CityGen',Email='cgen@c.com',MobilePhone='0490213214',OtherPhone='422244222');
        INSERT contactRecord;
        DataUsePurpose dup = new DataUsePurpose(Name='Outage Notifications');
        INSERT dup;
        ContactPointEmail email = new ContactPointEmail(Contact__c=contactRecord.Id,IsPrimary=true, EmailAddress='1234567890@c.com');
        INSERT email;
        ContactPointConsent consent = new ContactPointConsent(Name='Test Consent', Contact__c=contactRecord.Id,ContactPointId=email.Id,DataUsePurposeId=dup.Id,EffectiveFrom=DateTime.now());
        INSERT consent;
        Campaign camp = new Campaign(Name='Testing Camp');
        INSERT camp;
        CampaignMember cm = new CampaignMember(CampaignId=camp.Id,ContactId=contactRecord.Id);
        INSERT cm;
        mmmu.rec.ContactId = '';
        mmmu.rec.IncidentId = '';
        mmmu.rec.CampaignId= camp.Id;
        mmmu.rec.mode ='Schedule';
        mmmu.rec.ScheduledDateTime = String.valueOf(Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        mmmu.rec.overrideCustPref = 'Yes';
        mmmu.rec.channel = 'SMS';
        mmmu.rec.msgBody = 'Dear %%FirstName%% %%LastName%% %%IncidentNumber%% %%uom_Customer_Street__c%% %%uom_Estimated_restoration_date__c%% %%Estimated_assessment_date__c%%';
        mmmu.rec.subject = 'Dear';
        Map<String, Object> tm = Outage_ManualMessagingUtility.translateMessagesForMM(mmmu.rec);
        
        Test.stopTest();
    }
    
         @IsTest
    public static void test09_getContactPreference(){
        Test.startTest();
        Contact contactRecord = new Contact(FirstName='CityGen',LastName='CityGen',Email='cgen@c.com',MobilePhone='0490213214',OtherPhone='422244222');
        INSERT contactRecord;
        String contactPref = Outage_ManualMessagingUtility.getContactPreference(String.valueOf(contactRecord.Id));
      Test.stopTest();
    }
    
             @IsTest
    public static void test10_refreshMCTemplates(){
        Test.startTest();
        Map<String,Map<String,List<String>>> mcTmpls  = Outage_ManualMessagingUtility.refreshMCTemplates();
      Test.stopTest();
    }
}