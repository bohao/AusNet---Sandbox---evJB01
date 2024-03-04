/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 23 Sep 2019
  @Description : Test class for DER Application Trigger and respective trigger logics
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/

@isTest
private class Trig_DER_Application_Test {
    
    private static String NMI_NUMBER = '123456789'; 
    private static String SERIAL_NUM = '1234'; 
    private static String TYPE_CODE = 'TEST'; 
    private static String customerEmail = 'customer@test12345.com';
    private static String installerEmail = 'installer@test12345.com';
    private static String repEmail = 'rep@test12345.com';
    private static String custEmailNotifLogic = 'customer@test12345.com';
    public  static String Asset_RT   = 'Asset_DER_L2';
    public  static String Asset_RT_L3   = 'Asset_DER_L3';
    private static Id  Asset_RTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Asset_RT).getRecordTypeId();
    private static Id  Asset_RTId_L3 = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(Asset_RT_L3).getRecordTypeId();
    
    public static testMethod void device_update_success(){
        User testUser = UtilDatabase_Test.getTestUser();
        DER_Application__c app = [SELECT Id, Ph_A_New_Capacity__c
                            FROM DER_Application__c LIMIT 1];
        
        Test.startTest();
        System.runAs(testUser){
            app.Ph_A_New_Capacity__c = 0;

            update app;            
        }
        Test.stopTest();

        DER_Application__c appAfterUpdate = (DER_Application__c) UtilDatabase.getRecord(app.Id);
        System.assertEquals(0, appAfterUpdate.Ph_A_New_Capacity__c);
        System.assertEquals(0, appAfterUpdate.Ph_B_New_Capacity__c);
        System.assertEquals(0, appAfterUpdate.Ph_C_New_Capacity__c);

    }

    public static testMethod void meter_ref_update(){
        User testUser = UtilDatabase_Test.getTestUser();
        Case derCase = [SELECT Id, DER_Application__c 
                            FROM Case
                            WHERE ContactEmail =: installerEmail
                            AND DER_Application__c != null];

        DER_Application__c derApp = [SELECT Id, Meter_Number__c , Meter_Ref__c, NMI__c
                                        FROM DER_Application__c 
                                        WHERE Id =: derCase.DER_Application__c
                                        AND NMI__c != null
                                        LIMIT 1];        
        Test.startTest();
        System.runAs(testUser){
            Connection_Point__c conPoint = [SELECT Id, NMI__c FROM Connection_Point__c WHERE Id =: derApp.NMI__c];
            conPoint.NMI__c = NMI_NUMBER;
            update conPoint;

            //Create NmiDataSets__x
            MeterDataSets__x testExtMtr = DER_TestUtility.createEXTMtr(NMI_NUMBER, SERIAL_NUM, TYPE_CODE);
            DER_Application_Util.mockedExtMtr.add(testExtMtr);
            
            derApp.Meter_Number__c = SERIAL_NUM;
            update derApp;            
        }
        Test.stopTest();

        DER_Application__c appAfterUpdate =  [SELECT Id, Meter_Number__c, Meter_Ref__c, Meter_Install_Type_Code__c
                                                    FROM DER_Application__c 
                                                    WHERE Id =: derApp.Id
                                                    LIMIT 1];
        System.assertNotEquals(null, appAfterUpdate.Meter_Install_Type_Code__c);
    }

    public static testMethod void meter_ref_clear(){
        User testUser = UtilDatabase_Test.getTestUser();
        Case derCase = [SELECT Id, DER_Application__c 
                            FROM Case
                            WHERE ContactEmail =: installerEmail
                            AND DER_Application__c != null];

        DER_Application__c derApp = [SELECT Id, Meter_Number__c , Meter_Ref__c, NMI__c
                                        FROM DER_Application__c 
                                        WHERE Id =: derCase.DER_Application__c
                                        AND NMI__c != null
                                        LIMIT 1];        

        Connection_Point__c conPoint = [SELECT Id, NMI__c FROM Connection_Point__c WHERE Id =: derApp.NMI__c];
        conPoint.NMI__c = NMI_NUMBER;
        update conPoint;

        //Create NmiDataSets__x
        MeterDataSets__x testExtMtr = DER_TestUtility.createEXTMtr(NMI_NUMBER, SERIAL_NUM, TYPE_CODE);
        DER_Application_Util.mockedExtMtr.add(testExtMtr);
        
        derApp.Meter_Number__c = SERIAL_NUM;
        update derApp;


        Test.startTest();
        System.runAs(testUser){
            
            derApp.Meter_Number__c = null;
            update derApp;            
        }
        Test.stopTest();

        DER_Application__c appAfterUpdate =  [SELECT Id, Meter_Number__c, Meter_Ref__c, Meter_Install_Type_Code__c
                                                    FROM DER_Application__c 
                                                    WHERE Id =: derApp.Id
                                                    LIMIT 1];
        System.assertEquals(null, appAfterUpdate.Meter_Install_Type_Code__c);
    }

     public static testMethod void upsertDeviceRecordsTest(){
          //Create Individual Account
        Account testCustomer = DER_TestUtility.createPersonAccount('Person Account', 'test@test12345.com');
        insert testCustomer;


        DER_Application__c derApp = new DER_Application__c();
        insert derApp;
         
       Connection_Point__c cp = new Connection_Point__c();
         cp.NMI__c = '123456';
         insert cp;
         
         derApp.NMI__c = cp.Id;
         update derApp;

        //Create Business Account
        Account testInstaller = DER_TestUtility.createBusinessAccount('Business Account');
        insert testInstaller;

        //Create Business Account's Contact
        Contact testInstallerContact = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Installer', custEmailNotifLogic);
        insert testInstallerContact;

        //Create Business Account
        Account testRepAcc = DER_TestUtility.createBusinessAccount('Representative Business Account');
        insert testRepAcc;

        //Create Business Account's Contact
        Contact testRep = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Representative', 'representative@test12345.com');
        insert testRep;

        //Create case with customer, installer & representative
        Case testCaseNotifLogic = DER_TestUtility.createCaseWith_Installer_Customer_Rep(derApp.Id,
                                                                                        DER_REST_Application_v1.CASE_RECORDTYPE_MANUAL,
                                                                                        'New', 'Email', 'Medium',
                                                                                        testInstaller.Id, testInstallerContact.Id,
                                                                                        testCustomer.Id, testRep.Id,
                                                                                        Trig_Case.APPLICANT_REP, Trig_Case.RESP_PARTY_REP);
        insert testCaseNotifLogic;

        Asset ast = new Asset();
        ast.Conn_Point__c = cp.Id;
        ast.Name = 'test1';
        ast.AC_Equip_Type__c = 'Inverter';
        ast.AC_Equip_Sub_Type__c = 'Solar';
        ast.RecordTypeId = Asset_RTId;
        ast.Status = 'Active';
        insert ast;

        Asset ast1 = new Asset();
        ast1.Name = 'test2';
        ast1.ParentId = ast.Id;
        ast1.Device_Type__c = 'Solar PV';
        ast1.Device_Sub_Type__c = 'Monocrystalline';
        ast1.RecordTypeId = Asset_RTId_L3;
        ast1.Status = 'Active';
        insert ast1;
         
        derApp.Import_Existing_Assets__c = true;
        derApp.Existing_Total_Export_Rating__c = 3.2;
        update derApp;
         
     }

    @TestSetup
    public static void setup() {
        
        //Create User
        User testUser = DER_TestUtility.createTestUser();
        insert testUser;

        Id testDERAppId = DER_TestUtility.loadDERAppRecords(customerEmail, installerEmail, repEmail);
    }      
}