/*
@description: Apex Test Class For Trig_AccountContactRelationship 
*/
@isTest
public with sharing class Trig_AccountContactRelationshipTest {
    
    @testSetup
    static void setup() {
        Integer numCustomers = 2;
        // Generate customer data (NMI, Premise, Account, Contact, ACR)
        Outage_DataFactory.getODF().generateCustomers(numCustomers);
    }

    @isTest
    static void AfterInsertHandleMarketingCloudContactTest() {

        Integer numCustomers = 3;
        Outage_DataFactory.getODF().generateCustomers(numCustomers);
        List<Contact> consODF = Outage_DataFactory.getODF().cons;
        List<Account> accsODF = Outage_DataFactory.getODF().accs;
        List<AccountContactRelation> acrsODF = Outage_DataFactory.getODF().ACRs;

        // Update ACRS and Account so that Contacts MC_Contact__c fields are set to false
        List<AccountContactRelation> acrsToUpdate = new List<AccountContactRelation>();
        for (AccountContactRelation acr : acrsODF) {
            acr.Roles = '';
            acrsToUpdate.add(acr);
        }
        update acrsToUpdate;

        List<Account> accsToUpdate = new List<Account>();
        for (Account acc : accsODF) {
            acc.vlocity_cmt__PrimaryContactId__c = null;
            accsToUpdate.add(acc);
        }
        update accsToUpdate;

        // Clone account multiple times and retrieve to use in tests
        List<Account> clonedAccountsToInsert = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            Account account = accsODF.get(0).clone(false, true, false, false);
            clonedAccountsToInsert.add(account);
        }
        
        insert clonedAccountsToInsert;
        List<Account> accounts = [SELECT Id FROM Account WHERE Id IN :clonedAccountsToInsert];

        // Get Contacts
        List<Contact> conList = [SELECT Id, AccountId, MC_Contact__c FROM Contact WHERE Id IN :consODF];
        Contact con1 = conList.get(0);
        Contact con2 = conList.get(1);
        Contact con3 = conList.get(2);

        Test.startTest();

        // Validate initial data setup is correct
        Assert.isFalse(con1.MC_Contact__c, 'MC_Contact__c should be set to false');
        Assert.isFalse(con2.MC_Contact__c, 'MC_Contact__c should be set to false');
        Assert.isFalse(con3.MC_Contact__c, 'MC_Contact__c should be set to false');

        /* Create new ACRs to be inserted -
        Note: you can't associate a private contact with an account. Therefore the contacts are assoiciated
        to initial ODF accounts (via the contacts AccountId field) before these inserts occur) */
        List<AccountContactRelation> acrsToInsert = new List<AccountContactRelation>();
        AccountContactRelation acr1 = new AccountContactRelation(
            AccountId = accounts.get(0).Id,
            ContactId = con1.Id,
            Roles = Outage_IncidentProcessor.ACR_ROLE_MKT_CON,
            IsActive = true
        );
        acrsToInsert.add(acr1);

        AccountContactRelation acr2 = new AccountContactRelation(
            AccountId = accounts.get(1).Id,
            ContactId = con2.Id,
            Roles = Outage_IncidentProcessor.ACR_ROLE_SEC_CON,
            IsActive = true
        );
        acrsToInsert.add(acr2);

        AccountContactRelation acr3 = new AccountContactRelation(
            AccountId = accounts.get(2).Id,
            ContactId = con3.Id,
            Roles = 'Other',
            IsActive = true
        );
        acrsToInsert.add(acr3);

        Trig_AccountContactRelationship.isRunningHandleMarketingCloudContact = false;
        insert acrsToInsert;

        // Validate ACR with Roles containing 'Market Contact' updates the contacts MC_Contact__c field to true.
        con1 = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :con1.Id];
        Assert.isTrue(con1.MC_Contact__c, 'MC_Contact__c should be set to true');

        // Validate ACR with Roles containing 'Secondary Contact' updates the contacts MC_Contact__c field to true.
        con2 = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :con2.Id];
        Assert.isTrue(con2.MC_Contact__c, 'MC_Contact__c should be set to true');

        // Validate ACR with Roles not containing 'Market Contact' OR 'Secondary Contact' leaves the contacts MC_Contact__c field as false.
        con3 = [SELECT Id, MC_Contact__c FROM Contact WHERE Id = :con3.Id];
        Assert.isFalse(con3.MC_Contact__c, 'MC_Contact__c should be set to false');

        Test.stopTest();
    }

    @isTest
    static void AfterUpdateHandleMarketingCloudContactTest() {

        Integer numCustomers = 3;
        Outage_DataFactory.getODF().generateCustomers(numCustomers);
        List<Contact> consODF = Outage_DataFactory.getODF().cons;
        List<Account> accsODF = Outage_DataFactory.getODF().accs;
        List<AccountContactRelation> acrsODF = Outage_DataFactory.getODF().ACRs;

        List<Account> accsToUpdate = new List<Account>();
        for (Account acc : accsODF) {
            acc.vlocity_cmt__PrimaryContactId__c = null;
            accsToUpdate.add(acc);
        }
        update accsToUpdate;

        List<AccountContactRelation> acrList = [SELECT Id, ContactId, Roles, Contact.MC_Contact__c  FROM AccountContactRelation WHERE Id IN :acrsODF ORDER BY Id];

        Test.startTest();

        // Validate initial data setup is correct
        Assert.isTrue(acrList.get(0).Contact.MC_Contact__c, 'MC_Contact__c should be set to true');
        Assert.isTrue(acrList.get(1).Contact.MC_Contact__c, 'MC_Contact__c should be set to true');
        Assert.isTrue(acrList.get(2).Contact.MC_Contact__c, 'MC_Contact__c should be set to true');

        // Update Roles for ACRs
        acrList.get(0).Roles = '';
        acrList.get(1).Roles = 'Other';
        acrList.get(2).Roles = Outage_IncidentProcessor.ACR_ROLE_SEC_CON;

        Trig_AccountContactRelationship.isRunningHandleMarketingCloudContact = false;
        update acrList;

        acrList = [SELECT Id, ContactId, Roles, Contact.MC_Contact__c  FROM AccountContactRelation WHERE Id IN :acrsODF ORDER BY Id];

        // Validate MC_Contact__c fields are updated correctly
        Assert.isFalse(acrList.get(0).Contact.MC_Contact__c, 'MC_Contact__c should be set to false'); // Valid role to blank
        Assert.isFalse(acrList.get(1).Contact.MC_Contact__c, 'MC_Contact__c should be set to false'); // Valid role to other (non valid role)
        Assert.isTrue(acrList.get(2).Contact.MC_Contact__c, 'MC_Contact__c should be set to true'); // Valid role to valid role

        // Update Roles for ACRs
        acrList.get(0).Roles = Outage_IncidentProcessor.ACR_ROLE_MKT_CON;
        acrList.get(1).Roles = Outage_IncidentProcessor.ACR_ROLE_SEC_CON;

        Trig_AccountContactRelationship.isRunningHandleMarketingCloudContact = false;
        update acrList;

        acrList = [SELECT Id, ContactId, Roles, Contact.MC_Contact__c  FROM AccountContactRelation WHERE Id IN :acrsODF ORDER BY Id];

        // Validate MC_Contact__c fields are updated correctly
        Assert.isTrue(acrList.get(0).Contact.MC_Contact__c, 'MC_Contact__c should be set to true'); // Blank to valid role
        Assert.isTrue(acrList.get(1).Contact.MC_Contact__c, 'MC_Contact__c should be set to true'); // Other (non valid role) to valid role

        // Update Roles for ACRs to prep for test
        acrList.get(0).Roles = 'Other';
        acrList.get(1).Roles = 'Other';
        acrList.get(2).Roles = '';

        Trig_AccountContactRelationship.isRunningHandleMarketingCloudContact = false;
        update acrList;

        // Update Roles for ACRs
        acrList.get(0).Roles = '';
        acrList.get(1).Roles = 'Decision Maker';
        acrList.get(2).Roles = 'Other';

        Trig_AccountContactRelationship.isRunningHandleMarketingCloudContact = false;
        update acrList;

        acrList = [SELECT Id, ContactId, Roles, Contact.MC_Contact__c  FROM AccountContactRelation WHERE Id IN :acrsODF ORDER BY Id];

        // Validate MC_Contact__c fields are updated correctly
        Assert.isFalse(acrList.get(0).Contact.MC_Contact__c, 'MC_Contact__c should be set to false'); // Other (non valid role) to blank
        Assert.isFalse(acrList.get(1).Contact.MC_Contact__c, 'MC_Contact__c should be set to false'); // Other (non valid role) to other (non valid role)
        Assert.isFalse(acrList.get(2).Contact.MC_Contact__c, 'MC_Contact__c should be set to false'); // Blank to Other (non valid role)

        Test.stopTest();
    }
}