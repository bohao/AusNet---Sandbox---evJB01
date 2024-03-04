global class TVE_RegHandler implements Auth.RegistrationHandler{
    
    static final string community_profile = 'TVE-11 Customer User';
    
    class RegHandlerException extends Exception {}
    
    void prepareUserData(Auth.UserData data, User u)
    {   
        String name, firstName, lastName, username, alias, email, federationId,AzureID;
        Integer maxSize = 40;
        
        System.debug('here is your user data: ' + data);
        //TODO: Customize the user attributes. Also check that the username doesn't 
        //already exist and possibly ensure there are enough org licenses to 
        //create a user. Must be 80 characters or less
        // Print the attributes list retrieved by the Authentication Provider
        system.debug('id: ' + data.identifier);
        system.debug('Email: ' + data.email);
        system.debug('First Name: ' + data.firstName);
        system.debug('Last Name: ' + data.lastName);
        for(string key : data.attributeMap.keySet())
        {
            system.debug('key: ' + key + ' value: ' + data.attributeMap.get(key));
        }
        // Initialize the attributes essential for creating a new user with dummy values 
        // in case they will not be provided by the Auth Provider 
        /*UserLicense users = [select Id, Name, UsedLicenses, TotalLicenses from UserLicense where Name='Customer Community Plus Login' limit 1];
		if(users.UsedLicenses == users.TotalLicenses){
			throw new RegHandlerException('User Licensee not available'); 
		}
		else{*/
        
        AzureID = data.identifier;
        Contact con=[select id, FirstName, LastName, AD_User_ID__c,email, MobilePhone , Phone, 
                     CommunicationPreference__c, MailingStreet, MailingCity, 
                     MailingPostalCode, MailingState, Account.Name,
                     Account.ABN_CINCL__c from Contact where AD_User_ID__c=:AzureID];
        
        email= con.Email;
        firstName = con.firstName;
        lastName = con.lastName;
        
        String rand=TVE_SF_Azure_Utility.generatePassword(4);
        username = email;     
        alias = firstName;
        //Alias must be 8 characters or less
        if(alias.length()>8)            
            alias = alias.substring(0, 8);   
        u.username = email;
        u.email = email;
        u.lastName = lastName;
        u.firstName = firstName;
        u.alias = alias;
        u.languagelocalekey = UserInfo.getLocale();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'UTF-8';
        u.timeZoneSidKey = 'Australia/Sydney';
        if(con.Account.ABN_CINCL__c != null){
            u.CompanyName = con.Account.Name;
        }
        if(email.length() > maxSize ){
            u.CommunityNickname = email.substring(0, maxSize);
        } else{
            u.CommunityNickname = email;
        }
        u.MobilePhone = con.MobilePhone;
        u.Phone = con.Phone;
        u.CommunicationPreference__c = con.CommunicationPreference__c;
        u.Street = con.MailingStreet;
        u.City = con.MailingCity;
        u.PostalCode = con.MailingPostalCode;
        u.State = con.MailingState;
        u.contactId = con.Id;
    }
    // Creates a community user
    global User createUser(Id portalId, Auth.UserData data){
        User u = new User();
        prepareUserData(data, u);
        
        if(data.attributeMap.containsKey('sfdc_networkid')) {
            Profile p = [SELECT Id FROM profile WHERE name=:community_profile];     
            u.profileId = p.Id;
        }
        return u;
    }
    // Updates the user's first and last name
    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        User u = new User(id=userId);
        prepareUserData(data, u);
        update(u);
    } 
    
}