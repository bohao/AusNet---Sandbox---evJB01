public with sharing class TVE_Contact_Utility {
    public static void updateCustomerTypeByAccountIds(Set<Id> acctIds) {
        List<Contact> contacts = new List<Contact>();
        for(Contact cont : [SELECT Id, Customer_Type__c, Account.Customer_Type__c FROM Contact WHERE AccountId IN :acctIds]) {
            if(cont.Customer_Type__c != cont.Account.Customer_Type__c) {
                cont.Customer_Type__c = cont.Account.Customer_Type__c;
                contacts.add(cont);
            }
        }
        update contacts;
    }
    
    public static void updateCustomerTypeByContacts(Map<Id, Contact> contacts) {
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Customer_Type__c FROM Account WHERE Id IN :contacts.keySet() AND IsPersonAccount = false]);
        for(Contact cont : contacts.values()) {
            if(accounts.containsKey(cont.AccountId)) {
                String customerType = accounts.get(cont.AccountId).Customer_Type__c;
                if(cont.Customer_Type__c != customerType) {
                    cont.Customer_Type__c = customerType;
                }
            }
        }
    }
}