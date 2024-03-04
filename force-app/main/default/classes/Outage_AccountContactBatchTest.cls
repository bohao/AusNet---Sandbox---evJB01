/*
@description: Apex Test Class For Outage_AccountContactBatch 
*/
@isTest
public with sharing class Outage_AccountContactBatchTest
{

    @testSetup
    static void setup() {
        Integer numCustomers = 10;
        // Generate customer data (NMI, Premise, Account, Contact, ACR, ContactPointEmail, ContactPointPhone, ContactPointConsent, EngagementChannelType, DataUsePurpose)
        Outage_DataFactory.getODF().generateCustomers(numCustomers);
        List<AccountContactRelation> acrList = Outage_DataFactory.getODF().ACRs;
    }

    @isTest
    static void runBatchTest() {

        List<AccountContactRelation> acrList = [SELECT Id, Roles, ContactId, AccountId, Account.Contact_Matched__c 
                                                FROM AccountContactRelation 
                                                WHERE Roles includes('Market Contact')];

        List<AccountContactRelation> acrsToUpdate = new List<AccountContactRelation>();
        List<Account>                accsToUpdate = new List<Account>();
        List<Contact>                consToUpdate = new List<Contact>();

        // Setup no contact found scenario
        Id accId1 = acrList.get(0).AccountId;
        acrList.get(0).Roles = '';
        acrsToUpdate.add(acrList.get(0));

        // Setup multiple contacts found with no primary contact scenario
        Id accId2 = acrList.get(1).AccountId;
        Id conId3 = acrList.get(2).ContactId;

        Account acc2 = [SELECT Id, vlocity_cmt__PrimaryContactId__c FROM Account WHERE Id = :accId2 LIMIT 1];
        acc2.vlocity_cmt__PrimaryContactId__c = null;
        accsToUpdate.add(acc2);

        Contact con2 = [SELECT Id, AccountId FROM Contact WHERE Id = :conId3 LIMIT 1];
        con2.AccountId = accId2;
        consToUpdate.add(con2);

        // Setup multiple contacts found with primary contact scenario
        Id accId4 = acrList.get(3).AccountId;
        Id conId5 = acrList.get(4).ContactId;

        Account acc4 = [SELECT Id, vlocity_cmt__PrimaryContactId__c FROM Account WHERE Id = :accId4 LIMIT 1];
        acc4.vlocity_cmt__PrimaryContactId__c = conId5;
        accsToUpdate.add(acc4);

        update accsToUpdate;

        Contact con4 = [SELECT Id, AccountId, MC_Contact__c FROM Contact WHERE Id = :conId5 LIMIT 1];
        con4.AccountId = accId4;
        con4.MC_Contact__c = false;
        consToUpdate.add(con4);

        update consToUpdate;

        // Id for 1 contact found with no primary contact scenario
        Id conId6 = acrList.get(5).ContactId;
        
        // update roles for the new ACRs 
        for (AccountContactRelation newACR : [SELECT Id, Roles FROM AccountContactRelation WHERE (ContactId = :con2.Id OR ContactId = :con4.Id) AND Id NOT IN :acrList]) {
            newACR.Roles = 'Market Contact';
            acrsToUpdate.add(newACR);
        }

        update acrsToUpdate;

        Test.startTest();
        Outage_AccountContactBatch.runBatch();
        Test.stopTest();

        // Validate no contact found scenario
        Account acc1 = [SELECT Id, vlocity_cmt__PrimaryContactId__c, Contact_Matched__c FROM Account WHERE Id = :accId1 LIMIT 1];
        // Assert.areEqual(Outage_AccountContactUtils.CON_MATCHED_NONE, acc1.Contact_Matched__c);
        // Assert.isNull(acc1.vlocity_cmt__PrimaryContactId__c, 'vlocity_cmt__PrimaryContactId__c should be null');

        // Validate multiple contacts found with no primary contact scenario
        acc2 = [SELECT Id, vlocity_cmt__PrimaryContactId__c, Contact_Matched__c FROM Account WHERE Id = :accId2 LIMIT 1];
        // Assert.areEqual(Outage_AccountContactUtils.CON_MATCHED_MULTIPLE, acc2.Contact_Matched__c);

        // Validate multiple contacts found with primary contact scenario
        con4 = [SELECT Id, MC_Contact__c, Account.Contact_Matched__c FROM Contact WHERE Id = :conId5 LIMIT 1];
        // Assert.areEqual(Outage_AccountContactUtils.CON_MATCHED_FOUND, con4.Account.Contact_Matched__c);
        // Assert.isTrue(con4.MC_Contact__c, 'MC_Contact__c should be set to true');

        // Validate 1 contact found with no primary contact scenario
        Contact con6 = [SELECT Id, MC_Contact__c, Account.Contact_Matched__c FROM Contact WHERE Id = :conId6 LIMIT 1];
        // Assert.areEqual(Outage_AccountContactUtils.CON_MATCHED_FOUND, con6.Account.Contact_Matched__c);
        // Assert.isTrue(con6.MC_Contact__c, 'MC_Contact__c should be set to true');
    }
}