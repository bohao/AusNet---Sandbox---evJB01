/*
@author  : palash.awasthi@ausnetservices.com.au
@created : 2 Jan 2020
@Description : Test Class for DER L2 Device Lines
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
@isTest
public with sharing class DER_L2_Device_Lines_Test {
    private static String customerEmail = 'customer@test12345.com';
    private static String installerEmail = 'installer@test12345.com';
    private static String repEmail = 'rep@test12345.com';
    
    @testSetup static void setup()
    {
        Id testDERAppId = DER_TestUtility.loadDERAppRecords(customerEmail, installerEmail, repEmail);
        List<Device__c> testDevList = new List<Device__c>(); 

        Device__c testDevice2 = DER_TestUtility.createDevice_L2(testDERAppId);
        testDevice2.AC_Equip_Type__c = 'Inverter';
        testDevice2.AC_Equip_Sub_Type__c = 'Solar';
        testDevice2.Device_Phase__c = 'A';
        testDevice2.AC_Equip_Cap__c = 50;
        testDevice2.AC_Equip_Exp__c = 30;
        testDevice2.Approved__c = TRUE;
        testDevList.add(testDevice2); 

        Device__c testDevice3 = DER_TestUtility.createDevice_L2(testDERAppId);
        testDevice3.AC_Equip_Type__c = 'Inverter';
        testDevice3.AC_Equip_Sub_Type__c = 'Solar';
        testDevice3.Device_Phase__c = 'A';
        testDevice3.AC_Equip_Cap__c = 60;
        testDevice3.AC_Equip_Exp__c = 30;
        testDevice3.Installed__c = TRUE;
        testDevList.add(testDevice3); 

        Device__c testDevice4 = DER_TestUtility.createDevice_L2(testDERAppId);
        testDevice4.AC_Equip_Type__c = 'Inverter';
        testDevice4.AC_Equip_Sub_Type__c = 'Solar';
        testDevice4.Device_Phase__c = 'A';
        testDevice4.AC_Equip_Cap__c = 70;
        testDevice4.AC_Equip_Exp__c = 30;
        testDevice4.Existing_Device__c = TRUE;
        testDevList.add(testDevice4); 

        Device__c testDevice5 = DER_TestUtility.createDevice_L2(testDERAppId);
        testDevice5.AC_Equip_Type__c = 'Inverter';
        testDevice5.AC_Equip_Sub_Type__c = 'Solar';
        testDevice5.Device_Phase__c = 'A';
        testDevice5.AC_Equip_Cap__c = 80;
        testDevice5.AC_Equip_Exp__c = 30;
        testDevice5.Decommission__c = TRUE;
        testDevList.add(testDevice5);

        insert testDevList;
    }


    @isTest static void testL2DeviceLinesTotal(){
        
        Case cas = [SELECT Id, DER_Application__c FROM Case];
        Map < String, Double > tableDataExpected = new Map < String, Double > ();
        Map < String, Double > tableDataActual = new Map < String, Double > ();
        tableDataExpected.put('Requested', 40);
        tableDataExpected.put('Approved', 50);
        tableDataExpected.put('Installed', 60);
        tableDataExpected.put('Existing', 70);
        tableDataExpected.put('Decommission', -80);
        tableDataExpected.put('Total', 30);
        Test.startTest();
        tableDataActual = DER_L2_Device_Lines.L2_Device_Lines(cas.Id);
        System.assertEquals(tableDataExpected, tableDataActual, 'The Actual and Expected values do not match');
        Test.stopTest();
    }
}