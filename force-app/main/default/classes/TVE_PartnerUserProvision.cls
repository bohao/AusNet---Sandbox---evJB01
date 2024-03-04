/*
@author  : prateek.gupta@ausnetservices.com.au
@created : 04 May 2020
@Description : Apex sript for Partner User Provisioning
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
6-May-20      dave.pavan@in.ibm.com                Added method enableAccountAsPartner & refinedcreatePartnerUser
-----------------------------------------------------------------------------------------
*/

/*
--------------------------------------------------------------------------------------------------------------
---------------------------------------- USAGE INFORMATION ---------------------------------------------------
--------------------------------------------------------------------------------------------------------------

-- TRANSACTION 1 --

String soql;
DateTime DTTM = DateTime.now().addHours(-1);
String sDTTM = DTTM.formatGMT('yyyy-MM-dd') + 'T' + dttm.formatGMT('HH:mm:ss.SSS') + 'Z';
String soql_acc = 'SELECT Id FROM ACCOUNT WHERE CreatedById >= \'0052O0000011eB2QAI\' AND CreatedDate = ' + sDTTM;

TVE_PartnerUserProvision userProvision = new TVE_PartnerUserProvision(soql_acc, true, true);
userProvision.enableAccountAsPartner();

-- TRANSACTION 2 --

String soql;
DateTime DTTM = DateTime.now().addHours(-1);
String sDTTM = DTTM.formatGMT('yyyy-MM-dd') + 'T' + dttm.formatGMT('HH:mm:ss.SSS') + 'Z';
String soql_acc = 'SELECT Id FROM ACCOUNT WHERE CreatedById >= \'0052O0000011eB2QAI\' AND CreatedDate = ' + sDTTM;

TVE_PartnerUserProvision userProvision = new TVE_PartnerUserProvision(soql_acc, true, true);
userProvision.createPartnerUser();

--------------------------------------------------------------------------------------------------------------
*/


public with sharing class TVE_PartnerUserProvision
{
    // Options
    String ACC_QUERY;
    Boolean RUN_DML = false; // Update records?
    Boolean IS_PROD  = false;

    public TVE_PartnerUserProvision()
    {
        throw new TVE_ConfigurationException('Pass Account SOQL string (with just Id field) which are supposed to be enabled as partners. '+
                                             'Checkout USAGE INFORMATION section in this class');
    }

    public TVE_PartnerUserProvision(String account_soql, Boolean run_dml, Boolean is_prod)
    {
        this.ACC_QUERY = account_soql;
        this.RUN_DML = run_dml;
        this.IS_PROD = is_prod;
    }

    public void enableAccountAsPartner()
    {
        System.debug('RUN_DML is ' + (RUN_DML ? 'ON.' : 'off.') + '\n');

        System.debug('ACC_QUERY is ----> ' + ACC_QUERY);

        List<Account> accs = Database.query(ACC_QUERY);


        System.debug('Count of Account records which will be enabled as partner ----> ' + accs.size());

        for(Account item: accs)
        {
            item.IsPartner = true;
        }

        if (RUN_DML)
        {
            // Turn on triggers
            Trig_Account.TrigDisabled = false;
            update accs;
        }

    }

    public void createPartnerUser()
    {
        System.debug('RUN_DML is ' + (RUN_DML ? 'ON.' : 'off.') + '\n');

        System.debug('ACC_QUERY is ----> ' + ACC_QUERY);

        List<Account> accs = Database.query(ACC_QUERY);

        System.debug('*** Create Partner contacts for TVE-11');

        List<User> insUsers = new List<User>();
        Map<Id, Id> conidroleidMap = new Map<Id, Id>();
        Map<Id, Id> conidAcidMap = new Map<Id, Id>();
        Map<String, Integer> duplicateEmail = new Map<String, Integer>();

        // Get all the contacts of partner accounts
        List<Contact> lstCon = new List<Contact>([SELECT Id, FirstName, LastName, Email, Phone, MobilePhone, AccountId,
                                                    MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry
                                                    FROM Contact
                                                    WHERE Account.IsPartner = true AND AccountId IN: accs
                                                    AND Id NOT IN (SELECT ContactId FROM User WHERE UserType='PowerPartner')]);

        if (lstCon == null || lstCon.isEmpty())
        {
            System.debug('\n\nNo contacts found.');
            System.debug('*** End.');
            return;
        }

        // Get role name for all contacts
        for (Contact con: lstCon)
        {
            conidAcidMap.put(con.id, con.accountid);

            Integer count;
            if(!duplicateEmail.containsKey(con.Email))
            {
                duplicateEmail.put(con.Email, 1);
            }
            else
            {
                count = duplicateEmail.get(con.Email);
                count = count + 1;
                duplicateEmail.put(con.Email, count);
            }
        }
        System.debug('duplicateEmail--->' + duplicateEmail);

        // Create a list of role id and role names for all unique contact roles
        Map<Id, Id> usrRoles = new Map<Id, Id>();
        for (UserRole ur: [SELECT Id, PortalAccountId
                        FROM UserRole
                        WHERE PortalAccountId IN :conidAcidMap.values()
                        AND Name LIKE '%Partner User'])
        {
            usrRoles.put(ur.PortalAccountId, ur.Id);
        }

        // Creating a map of contact id and role id
        for (Id conid: conidAcidMap.keySet())
        {
            Id AccId = conidAcidMap.get(conid);

            if (usrRoles.containsKey(AccId))
                conidroleidMap.put(conid, usrRoles.get(AccId));
        }

        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name='TVE-11 Partner User' AND UserType='PowerPartner' LIMIT 1];

        System.debug('Number of Contacts found: ' + lstCon.size());
        //System.debug('* conidroleidmap****'+conidroleidMap);

        Set<String> mandatoryFields = new Set<String>{'FirstName', 'LastName', 'Email', 'Phone', 'MobilePhone',
                                                    'MailingStreet', 'MailingCity', 'MailingState', 'MailingPostalCode'};

        Integer i = 0;
        String username;

        for (Contact con: lstCon)
        {
            i++;
            Boolean isError = false;

            // Check fields
            for (String f: mandatoryFields)
            {
                if (con.get(f) == null || (String)con.get(f) == '')
                {
                    System.debug('('+i+') Error: Contact field is null or empty [' + con.Id + ']: ' + f);
                    isError = true;
                }
            }

            if (duplicateEmail.containsKey(con.Email) && duplicateEmail.get(con.Email) > 1)
            {
                System.debug('Error: Email is not unique------>' + con.Email);
                System.debug('Error: Number of duplicate contact with this email ----->' + duplicateEmail.get(con.Email));
                isError = true;
            }

            if (isError) return;

            if(IS_PROD)
            {
                username = con.Email;
            }
            else
            {
                username = con.Email + '.'+ String.valueof(DateTime.now().getTime());
            }

            User newUser = new User();
            newUser.ContactId            = con.Id;
            newUser.FirstName            = con.FirstName;
            newUser.LastName             = con.LastName;
            newUser.Username             = username; // Has to be unique
            newUser.Alias                = con.FirstName.left(1) + con.LastName.left(4);
            newUser.CommunityNickname    = con.FirstName.toLowerCase() + '.' + con.LastName.toLowerCase();
            newUser.Email                = con.Email;
            newUser.FederationIdentifier = con.Email;
            newUser.Street               = con.MailingStreet;
            newUser.City                 = con.MailingCity;
            newUser.State                = con.MailingState;
            newUser.PostalCode           = con.MailingPostalCode;
            newUser.Country              = con.MailingCountry;
            newUser.ProfileId            = partnerProfile.Id;
            newUser.EmailEncodingKey     = 'UTF-8';
            newUser.Phone                = con.Phone;
            newUser.MobilePhone          = con.MobilePhone;
            newUser.LocaleSidKey         = 'en_AU';
            newUser.LanguageLocaleKey    = 'en_US';
            newUser.TimeZoneSidKey       = 'Australia/Sydney';
            newUser.UserRoleId           = conidroleidMap.get(con.Id);

            System.debug('insUsers****** ' + newUser.Username);
            //System.debug('insUsers****** ' + newUser.UserRole.name);

            insUsers.add(newUser);
        }

        System.debug('Number of Users to create: ' + insUsers.size());

        if (RUN_DML)
        {
            // Turn on triggers
            Trig_User.TrigDisabled = false;

            // Update records
            System.debug('Inserting Partner User records...');
            insert insUsers;
        }

        System.debug('*** End.');
    }
}