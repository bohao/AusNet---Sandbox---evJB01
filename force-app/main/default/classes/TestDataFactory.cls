public class TestDataFactory {

    public static List<Account> createAccounts(Integer numberOfAccounts, List<vlocity_cmt__ServicePoint__c> sps, List<Contact> contacts) {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++) {
            Account acc = new Account(
                Name = 'Test Account ' + i,
                Market_Identifier__c = sps[i].Id,
                vlocity_cmt__PrimaryContactId__c = contacts[i].Id
                // Add other required fields here
            );
            accounts.add(acc);
        }
        return accounts;
    }

    public static List<vlocity_cmt__Premises__c> createPremises(Integer numberOfPremises) {
        List<vlocity_cmt__Premises__c> premises = new List<vlocity_cmt__Premises__c>();
        for (Integer i = 0; i < numberOfPremises; i++) {
            vlocity_cmt__Premises__c premise = new vlocity_cmt__Premises__c(
                Name = '123' + i + ' Fake Street', 
                vlocity_cmt__StreetAddress__c = '123' + i + ' Fake Street',
                vlocity_cmt__City__c = 'Melbourne', 
                vlocity_cmt__State__c = 'VIC', 
                vlocity_cmt__PostalCode__c = '3000');
            premises.add(premise);
        }
        return premises;
    }

    public static List<Contact> createContacts(Integer numberOfContacts) {
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < numberOfContacts; i++) {
            Contact con = new Contact(
                FirstName = 'Test First Name ' + i,
                LastName = 'Test Last Name ' + i,
                Email = 'test' + i + '@test.com',
                MobilePhone = '46531425' + i
                // Add other required fields here
            );
            contacts.add(con);
        }
        return contacts;
    }

    public static List<vlocity_cmt__ServicePoint__c> createServicePoints(Integer numberOfServicePoints, List<vlocity_cmt__Premises__c> premises) {
        List<vlocity_cmt__ServicePoint__c> sps = new List<vlocity_cmt__ServicePoint__c>();
        for (Integer i = 0; i < numberOfServicePoints; i++) {
            vlocity_cmt__ServicePoint__c sp = new vlocity_cmt__ServicePoint__c(
                Name = '1234567890' + i, 
                vlocity_cmt__MarketIdentifier__c = '1234567890' + i, 
                vlocity_cmt__ServiceType__c = 'Electricity', 
                vlocity_cmt__Status__c = 'Connected', 
                vlocity_cmt__PremisesId__c = premises[i].Id);
            sps.add(sp);
        }
        return sps;
    }

    public static List<Tariff_Trial__c> createTariffTrials(Integer numberOfTrials) {
        List<Tariff_Trial__c> tariffTrials = new List<Tariff_Trial__c>();
        for (Integer i = 0; i < numberOfTrials; i++) {
            Tariff_Trial__c trial = new Tariff_Trial__c(
                Event_Id__c = 'Event' + i,
                NMI__c = '1234567890' + i,
                Campaign_Name__c = 'Campaign' + i,
                Start_DateTime__c = Date.today(),
                Duration__c = 5, 
                // Add other required fields here
                Participant_First_Name__c = 'IBM',
                Participant_Last_Name__c = 'Tester',
                Participant_Id__c = 'Event' + i + '_' + 'Event' + i,
                Mobile__c = '46531425' + i,
                Email__c = 'test' + i + '@test.com'
            );
            tariffTrials.add(trial);
        }
        return tariffTrials;
    }
}
