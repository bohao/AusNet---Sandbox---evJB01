@RestResource(urlMapping='/v1.0/tve/customers/*')
global class TVE_CustomerDetailsToEAIService {
    /**
     Contact id as a parameter to check associated account
     **/
    @HttpGet
    global static wrapAccountContactDetails doGet() {
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(DER_REST_Application_v1.ACCOUNT_RECORDTYPE_INDIVIDUAL).getRecordTypeId();
        wrapAccountContactDetails wrapObj = new wrapAccountContactDetails();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String contactId = RestContext.request.params.get('id');
        Contact result = [SELECT    Id, 
                                    firstName,
                                    lastName,
                                    Email,
                                    MailingStreet,
                                    MailingCountry,
                                    MailingCity,
                                    MailingState,
                                    MailingPostalCode,
                                    Name,
                                    Phone,
                                    MobilePhone,
                                    CommunicationPreference__c,
                                    AccountId,
                                    Account.Name,
                                    Account.ABN__c,
                                    Account.ABN_CINCL__c,
                                    Account.recordTypeId 
                          FROM      Contact 
                          WHERE     Id = :contactId];

        if(result.Account.recordTypeId == personRecordTypeId){
            Account accRecord = [SELECT firstName,
                                        lastName,
                                        ABN__c,
                                        ABN_CINCL__c,
                                        PersonEmail,
                                        Name,
                                        Phone,
                                        CommunicationPreference__pc,
                                        PersonMobilePhone,
                                        PersonMailingStreet,
                                        PersonMailingCity,
                                        PersonMailingState,
                                        PersonMailingCountry,
                                        PersonMailingPostalCode
                                FROM    Account 
                                WHERE   id =: result.AccountId];
            wrapObj.firstName = accRecord.firstName;
            wrapObj.lastName = accRecord.lastName;
            wrapObj.CompanyName = accRecord.Name;
            wrapObj.Abn = accRecord.ABN_CINCL__c;
            wrapObj.customerType = 'Individual';
            wrapObj.Phone = accRecord.Phone;
            wrapObj.MobileNo = accRecord.PersonMobilePhone;
            wrapObj.preferredContactMethod = accRecord.CommunicationPreference__pc;
            wrapObj.EmailAddress = accRecord.PersonEmail;
            wrapObj.StreetAddress = accRecord.PersonMailingStreet;
            wrapObj.Suburb = accRecord.PersonMailingCity;
            wrapObj.State = accRecord.PersonMailingState;
            wrapObj.Country = accRecord.PersonMailingCountry;
            wrapObj.PostCode = accRecord.PersonMailingPostalCode;
        } else {
            wrapObj.firstName = result.firstName;
            wrapObj.lastName = result.lastName;
            wrapObj.CompanyName = result.Account.Name;
            wrapObj.Abn = result.Account.ABN_CINCL__c;
            wrapObj.customerType = 'Business';
            wrapObj.Phone = result.Phone;
            wrapObj.MobileNo = result.MobilePhone;
            wrapObj.preferredContactMethod = result.CommunicationPreference__c;
            wrapObj.EmailAddress = result.Email;
            wrapObj.StreetAddress = result.MailingStreet;
            wrapObj.Suburb = result.MailingCity;
            wrapObj.State = result.MailingState;
            wrapObj.Country = result.MailingCountry;
            wrapObj.PostCode = result.MailingPostalCode;
        }
        return wrapObj;
    }
    
    global class wrapAccountContactDetails {
        public String firstName {get; set;}
        public String lastName {get; set;}
        public String CompanyName {get; set;}
        public String Abn {get; set;}
        public String Phone {get; set;}
        public String MobileNo {get; set;}
        public String customerType {get; set;}
        public String preferredContactMethod {get; set;}
        public String EmailAddress {get; set;}
        public String StreetAddress {get; set;}
        public String Suburb {get; set;}
        public String State {get; set;}
        public String Country {get; set;}
        public String PostCode {get; set;}
    }
}