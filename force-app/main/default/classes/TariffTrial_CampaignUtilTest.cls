@isTest
public class TariffTrial_CampaignUtilTest {

    static Integer NUM_OF_TEST_RECORDS = 3;

    @testSetup
    static void setup() {

        List<vlocity_cmt__Premises__c> premises = TestDataFactory.createPremises(NUM_OF_TEST_RECORDS);
        insert premises;

        List<vlocity_cmt__ServicePoint__c> sps = TestDataFactory.createServicePoints(NUM_OF_TEST_RECORDS, premises);
        insert sps;

        List<Contact> contacts = TestDataFactory.createContacts(NUM_OF_TEST_RECORDS);
        insert contacts;
        
        List<Account> accounts = TestDataFactory.createAccounts(NUM_OF_TEST_RECORDS, sps, contacts);
        insert accounts;
    }

    @isTest
    static void testInsertCampaigns() {
        Test.startTest();
        // Initialize test data using the data factory within startTest block
        List<Tariff_Trial__c> tariffTrials = TestDataFactory.createTariffTrials(NUM_OF_TEST_RECORDS); // Example: Creating 3 tariff trials
        insert tariffTrials;

        Test.stopTest(); // End of the setup phase

        // Verify that campaigns have been created successfully
        List<Campaign> campaigns = [SELECT Id, Name, Event_Id__c FROM Campaign];
        System.assertEquals(3, campaigns.size(), 'Incorrect number of campaigns created');

        // Verify that campaign members have been created successfully
        List<CampaignMember> campaignMembers = [SELECT Id, CampaignId, ContactId, Participant_Id__c FROM CampaignMember];
        System.assertEquals(3, campaignMembers.size(), 'Incorrect number of campaign members created');
    }

    @isTest
    static void testUpdateCampaigns() {
        // Insert the initial Tariff_Trial__c records
        List<Tariff_Trial__c> tariffTrials = TestDataFactory.createTariffTrials(3);
        insert tariffTrials;

        // Get the created Tariff_Trial__c records
        tariffTrials = [SELECT Id, Duration__c FROM Tariff_Trial__c];

        // Modify the Tariff_Trial__c records
        for (Tariff_Trial__c trial : tariffTrials) {
            trial.Duration__c = 4; // Modify any field you want to update
        }
        
        Test.startTest();
        // Update the records within startTest block
        update tariffTrials; // Update the records
        Test.stopTest(); // End of the test phase

        // Verify that the campaigns have been updated successfully
        List<Campaign> updatedCampaigns = [SELECT Duration__c FROM Campaign];
        System.assertEquals(3, updatedCampaigns.size(), 'Incorrect number of campaigns updated');
        // Verify that the campaign duration have been updated successfully
        for(Campaign c : updatedCampaigns) {
            System.assertEquals(4, c.Duration__c, 'Duration hasn\'t been updated successfully');
        }
    }
}
