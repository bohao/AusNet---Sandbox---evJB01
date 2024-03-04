/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 04 Sep 2019
  @Description : Utility Test class
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
@isTest
public class DER_TestUtility {
    public static String L2_Device_RT = 'Device_L2';
    public static String L3_Device_RT = 'Device_L3';

    public static Account createPersonAccount(String acctName, String emailAddr) {
        Id acctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(DER_REST_Application_v1.ACCOUNT_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        return new Account(
            LastName = acctName,
            RecordTypeId = acctRTId,
            PersonEmail = emailAddr,
            ABN__c = getUniqueABN());
    }

    public static Account createBusinessAccount(String acctName) {
        Id acctRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(DER_REST_Application_v1.ACCOUNT_RECORDTYPE_SERVICEPROVIDER).getRecordTypeId();
        return new Account(
            Name = acctName,
            RecordTypeId = acctRTId,
            Customer_Type__c = 'ELE - DER',
            ABN__c = getUniqueABN());
    }
    public static String getUniqueABN(){
        String returnValue;
        returnValue = String.valueOf(Math.round((Math.random() * (900000) + 1000000000)));
		return returnValue;
	}

    public static Contact createBusinessAccountContact(Id businessAccId, String firstName, String lastName, String email){
        return new Contact(
            FirstName = firstName,
            LastName = lastName,
            Email = email,
            AccountId = businessAccId
        );
    }    

    public static Case createCaseForInstaller(String recordTypeDeveloperName, String status, String origin, 
                                              String priority, Id installerId, Id installerContactId) {
        Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
        return new Case(
            Status = status,
            RecordTypeId = caseRTId,
            Origin = origin,
            Priority = priority,
            AccountId = installerId,
            ContactId = installerContactId,
            Invoice_Number__c = '12345');
    }

    
    public static Case createCaseForCustomer(Id derAppId, String recordTypeDeveloperName, String status, String origin, 
                                             String priority, Id customerId) {
        Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
        return new Case(
            DER_Application__c = derAppId, 
            Status = status,
            RecordTypeId = caseRTId,
            Origin = origin,
            Priority = priority,
            Customer__c = customerId,
            Invoice_Number__c = '12345'
        );
    }
    
    public static Case createCaseForDerGetMethod(Id derAppId, String recordTypeDeveloperName, String status, String origin, 
                                              String priority, Id installerId, Id installerContactId,Id customerId) {
        Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
        return new Case(
            DER_Application__c = derAppId, 
            Status = status,
            RecordTypeId = caseRTId,
            Origin = origin,
            Priority = priority,
            AccountId = installerId,
            ContactId = installerContactId,
            Customer__c = customerId,
            Invoice_Number__c = '12345');
    }

    public static Case createCaseWith_Installer_Customer_Rep(Id derAppId, 
                                                            String recordTypeDeveloperName, 
                                                            String status, String origin, String priority, 
                                                            Id installerId, Id installerContactId,
                                                            Id customerId, Id repId, 
                                                            String applicantType, String respParty) {

        Id caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
        return new Case(
            DER_Application__c = derAppId, 
            Status = status,
            RecordTypeId = caseRTId,
            Origin = origin,
            Priority = priority,
            AccountId = installerId,
            ContactId = installerContactId,
            Customer__c = customerId,
            Representative__c = repId,
            Applicant_Type__c = applicantType,
            Responsible_Party__c = respParty,
            Invoice_Number__c = '12345');
    }

    public static Connection_Point__c createConnectionPoint(Id accountId) {
        return new Connection_Point__c(
            Account__c = accountId,
            NMI__c = '12345'
        );
    }

    public static DER_Application__c createDERApplication (Id connectionPointId){
        return new DER_Application__c(
            NMI__c = connectionPointId
        );
    }
    public static Device__C createDevice (Id derApplicationId){
        return new Device__c(
            DER_Application__c = derApplicationId,
            AC_Equip_Type__c = 'Inverter',
            AC_Equip_Sub_Type__c = 'Solar'
          
        );
    }

    public static Device__C createDevice_L2 (Id derApplicationId){
        Id L2_Device_RTId = Schema.SObjectType.Device__c.getRecordTypeInfosByDeveloperName().get(L2_Device_RT).getRecordTypeId();
        return new Device__c(
            DER_Application__c = derApplicationId,
            RecordTypeId = L2_Device_RTId,
            AC_Equip_Type__c = 'Inverter',
            AC_Equip_Sub_Type__c = 'Solar'
        
        );        
    }
    
    public static Device__C createDevice_L3 (Id deviceL2Id){
        Id L3_Device_RTId = Schema.SObjectType.Device__c.getRecordTypeInfosByDeveloperName().get(L3_Device_RT).getRecordTypeId();
        return new Device__c(
            Parent_Device__c = deviceL2Id,
            RecordTypeId = L3_Device_RTId,
            AC_Equip_Type__c = 'Inverter',
            AC_Equip_Sub_Type__c = 'Solar'
        );        
    }

    public static DER_Agreement__c createAgreement(Id derAppId, Id installerAccId, String agmtStatus, 
                                                    Date offerAccptDate, Date offerMadeDate, String offerType){
        return new DER_Agreement__c(
            DER_Application__c = derAppId,
            Account__c = installerAccId,
            Status__c = agmtStatus,
            Offer_Accepted_Date__c = offerAccptDate,
            Offer_Made_Date__c = offerMadeDate,
            Offer_Type__c = offerType,
            Contract_Active_Date__c = offerAccptDate,
            Offer_Version__c ='0.0'
        );
    }

    public static NmiDataSets__x createEXTNMI(String nmiNumber){
        return new NmiDataSets__x(            
            ExternalId = nmiNumber,
            Nmi__c = nmiNumber
        );
    }

    public static MeterDataSets__x createEXTMtr(String nmiNumber, String serialNum, String typeCode){
        return new MeterDataSets__x(            
            ExternalId = nmiNumber,
            SerialNumber__c = serialNum,
            InstallTypeCode__c = typeCode
        );
    }

    public static User createTestUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        System.assert(p != null, 'Profile not found.');

        return new User(
            ProfileId = p.Id,
            LastName = 'Doe',
            Email = 'testuser@fnptest.com',
            Username = 'testuser@fnptest.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
    }
    
    // ------------------------------------------------------------- //
    // -------------- Data setup for DER Application --------------- //
    // ------------------------------------------------------------ //
        
    public static Id loadDERAppRecords(String customerEmail, String installerEmail, String repEmail){

        //Create Individual Account
        Account testCustomer = DER_TestUtility.createPersonAccount('Person Account', customerEmail);
        insert testCustomer;        
        
        //Create Connection Point
        Connection_Point__c testConnectionPoint = DER_TestUtility.createConnectionPoint(testCustomer.Id);
        Insert testConnectionPoint;
        
        DER_Application__c testDERApp = DER_TestUtility.createDERApplication(testConnectionPoint.Id);
        Insert testDERApp;
        
        //Create Business Account
        Account testInstaller = DER_TestUtility.createBusinessAccount('Business Account');
        insert testInstaller;
        
        //Create Business Account's Contact
        Contact testInstallerContact = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Installer', installerEmail);
        insert testInstallerContact;
        
        //Create Business Account
        Account testRepAcc = DER_TestUtility.createBusinessAccount('Representative Business Account');
        insert testRepAcc;
        
        //Create Business Account's Contact
        Contact testRep = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Representative', repEmail);
        insert testRep;

        //Create case with customer, installer & representative
        Case testCase = DER_TestUtility.createCaseWith_Installer_Customer_Rep(testDERApp.Id,
                                                                         DER_REST_Application_v1.CASE_RECORDTYPE_AUTO, 
                                                                         'New', 'Email', 'Medium', 
                                                                         testInstaller.Id, testInstallerContact.Id, 
                                                                         testCustomer.Id, testRep.Id,
                                                                         Trig_Case.APPLICANT_REP, Trig_Case.RESP_PARTY_REP);
        insert testCase;

        //Create Device1
        Device__c testDevice = DER_TestUtility.createDevice_L2(testDERApp.Id);
        testDevice.AC_Equip_Type__c = 'Inverter';
        testDevice.AC_Equip_Sub_Type__c = 'Solar';
        testDevice.Requested__c = true;
        testDevice.Device_Phase__c = 'A';
        testDevice.AC_Equip_Cap__c = 40;
        testDevice.AC_Equip_Exp__c = 30;
        Insert testDevice;  
        
        return testDERApp.Id;
    }
}