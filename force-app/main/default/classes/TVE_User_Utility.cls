/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 09 Feb 2020
@Description : Class for user Utility
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
public with sharing class TVE_User_Utility {
    public static void updateUnregisteredCommUser(List<User> newSObject){
        list<id> listOfUsers = new list<id>();
        List<User> usersWithSalesforceLicense = [
            Select Id,contactId,contact.UserCommunityLicense__c, Name, Profile.UserLicense.Name 
            From User 
            Where id IN :newSObject
        ];
        system.debug('usersWithSalesforceLicense'+usersWithSalesforceLicense);
        for(User userItem : usersWithSalesforceLicense){
            if(userItem.Contact.UserCommunityLicense__c != null){
                listOfUsers.add(userItem.ContactId);
            }
        }
        if(!listOfUsers.isEmpty()){
            updateUnregisteredCommunityLicence(listOfUsers);
        }
    }
    @future(callout=true)
    public static void updateUnregisteredCommunityLicence(list<id> listOfUsers){
        contact c;
        system.debug('listOfUsers'+listOfUsers);
        list<contact> listOfCon = new list<contact>();
        if(!listOfUsers.isEmpty()){
            for(id item :listOfUsers){
                c = new contact();
                c.id = item;
                c.UserCommunityLicense__c = 'Unregistered Community User';
                listOfCon.add(c);
            }
            Database.update(listOfCon);
        }
    }
    public static void updateUserCommLicense(List<User> newSObject){
        list<id> listOfUsers = new list<id>();
        list<id> listOfPartnerUsers = new list<id>();
        List<User> usersWithSalesforceLicense = [
            Select Id,contactId,contact.UserCommunityLicense__c, Name, Profile.UserLicense.Name 
            From User 
            Where id IN :newSObject
        ];
        contact c;
        for(User userItem : usersWithSalesforceLicense){
            if(userItem.Profile.UserLicense.Name == 'Customer Community Plus Login'){
                listOfUsers.add(userItem.Id);
            }else if(userItem.Profile.UserLicense.Name == 'Partner Community'){
                listOfPartnerUsers.add(userItem.Id);
            }
            
        }
        if(!listOfUsers.isEmpty() || !listOfPartnerUsers.isEmpty()){
            updateUserCommunityLicense(listOfUsers,listOfPartnerUsers);
        }
    }
    @future(callout=true)
    public static void updateUserCommunityLicense(list<Id> listOfUsers,list<Id> listOfPartnerUsers){
        contact c;
        list<contact> listOfCon = new list<contact>();
        
        if(!listOfUsers.isEmpty()){
            for(User item :[select id,City,Country,FirstName,Email,LastName,Phone,
                          MobilePhone,ContactId,CommunicationPreference__c,State,Street,PostalCode From User where Id IN :listOfUsers]){
                c = new contact();
                c.id = item.ContactId;
                c.MailingCity = item.city;
                c.CommunicationPreference__c = item.CommunicationPreference__c;
                c.MailingCountry = item.Country;
                c.Email = item.Email;
                c.FirstName = item.FirstName;
                c.LastName = item.LastName;
                c.MobilePhone = item.MobilePhone;
                c.Phone = item.Phone;
                c.MailingPostalCode = item.PostalCode;
                c.MailingState = item.State;
                c.MailingStreet = item.Street;
                c.UserCommunityLicense__c = 'Customer Community Plus Login';
                listOfCon.add(c);
            }
        }
        if(!listOfPartnerUsers.isEmpty()){
            for(User item :[select id,City,Country,FirstName,Email,LastName,Phone,
                          MobilePhone,ContactId,CommunicationPreference__c,State,Street,PostalCode From User where Id IN :listOfPartnerUsers]){
                c = new contact();
                c.id = item.ContactId;
                c.MailingCity = item.city;
                c.CommunicationPreference__c = item.CommunicationPreference__c;
                c.MailingCountry = item.Country;
                c.Email = item.Email; 
                c.FirstName = item.FirstName;
                c.LastName = item.LastName;
                c.MobilePhone = item.MobilePhone;
                c.Phone = item.Phone;
                c.MailingPostalCode = item.PostalCode;
                c.MailingState = item.State;
                c.MailingStreet = item.Street;
                c.UserCommunityLicense__c = 'Partner Community';
                listOfCon.add(c);
            }
        }
        Database.update(listOfCon);
    }
   
}