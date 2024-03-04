/*
  @author  : Palash.Awasthi@ausnetservices.com.au
  @created : 26 Dec 2019
  @Description : Class for calculating L2 Device Line Information.
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
public with sharing class DER_L2_Device_Lines {
    @AuraEnabled(cacheable = true)
    public static Map < String, Double > L2_Device_Lines(String caseRecordId) {

        List < String > caseStatusList1 = new List < String > {
            'New',
            'More Info Required',
            'Invoice Pending',
            'Technical Assessment'
        };
        List < String > caseStatusList2 = new List < String > {
            'Offer Sent',
            'Installation Pending'
        };
        List < String > caseStatusList3 = new List < String > {
            'Designer Validation',
            'Installation Validation',
            'Publish',
            'Reconfig',
            'Complete',
            'Cancelled'
        };
        List < Device__c > requested = new List < Device__c > ();
        List < Device__c > approved = new List < Device__c > ();
        List < Device__c > installed = new List < Device__c > ();
        List < Device__c > existing = new List < Device__c > ();
        List < Device__c > decommission = new List < Device__c > ();
        Decimal Total = 0.0;
        Double Totalrequested = 0.0;
        Double Totalapproved = 0.0;
        Double Totalinstalled = 0.0;
        Double Totalexisting = 0.0;
        Double Totaldecommission = 0.0;
        Map < String, Double > tableData = new Map < String, Double > ();

        // Get AC equipment capacity of device for requested, approved, installed, existing and decommssion
        List < Case > caseRecord = [SELECT Id, DER_Application__c, Status FROM Case WHERE Id =: caseRecordId];
        List < Device__c > devList = [SELECT Id, AC_Equip_Cap__c, Requested__c, Approved__c, Installed__c, Existing_Device__c, Decommission__c FROM Device__c 
                                      WHERE DER_Application__c =: caseRecord[0].DER_Application__c AND((Requested__c = TRUE) OR(Approved__c = TRUE) OR(Installed__c = TRUE) OR(Existing_Device__c = TRUE) OR(Decommission__c = TRUE))];

        if (devList.size() > 0) {
            for (Device__c dev: devList) {
                if (dev.Requested__c == TRUE) {
                    requested.add(dev);
                }
                if (dev.Approved__c == TRUE) {
                    approved.add(dev);
                }
                if (dev.Installed__c == TRUE) {
                    installed.add(dev);
                }
                if (dev.Existing_Device__c == TRUE) {
                    existing.add(dev);
                }
                if (dev.Decommission__c == TRUE) {
                    decommission.add(dev);
                }
            }
        }

        // Total Capacity for Requested
        if (requested.size() > 0) {
            for (Device__c dev: requested) {
                Totalrequested = Totalrequested + dev.AC_Equip_Cap__c;
            }
            tableData.put('Requested', Totalrequested);
            System.debug('Table data ' + tableData);
        }

        // Total Capacity for Approved
        if (approved.size() > 0) {
            for (Device__c dev: approved) {
                Totalapproved = Totalapproved + dev.AC_Equip_Cap__c;
            }
            tableData.put('Approved', Totalapproved);
        }

        // Total Capacity for Installed
        if (installed.size() > 0) {
            for (Device__c dev: installed) {
                Totalinstalled = Totalinstalled + dev.AC_Equip_Cap__c;
            }
            tableData.put('Installed', Totalinstalled);
        }

        // Total Capacity for Existing
        if (existing.size() > 0) {
            for (Device__c dev: existing) {
                Totalexisting = Totalexisting + dev.AC_Equip_Cap__c;
            }
            tableData.put('Existing', Totalexisting);
        }

        // Total Capacity for Decommission
        if (decommission.size() > 0) {
            for (Device__c dev: decommission) {
                Totaldecommission = (Totaldecommission + dev.AC_Equip_Cap__c)*-1;
            }
            tableData.put('Decommission', Totaldecommission);
        }

        /*--------------- Calculate Total Capacity ---------------*/
        Decimal toround;
        if (caseStatusList1.contains(caseRecord[0].Status)) {
            Total = Totalrequested + Totalexisting + Totaldecommission;
            toround = Total.setScale(2);
        } else if (caseStatusList2.contains(caseRecord[0].Status)) {
            Total = Totalapproved + Totalexisting + Totaldecommission;
            toround = Total.setScale(2);

        } else if (caseStatusList3.contains(caseRecord[0].Status)) {
            Total = Totalinstalled + Totalexisting + Totaldecommission;
            toround = Total.setScale(2);
        }
        
        tableData.put('Total', toround);

        if (tableData.isEmpty()) {
            return null;
        } else {
            System.debug('return value is ' + tableData);
            return tableData;
        }

    }
}