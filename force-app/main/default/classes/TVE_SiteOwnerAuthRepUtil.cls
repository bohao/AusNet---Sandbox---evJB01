/*
@author  : dave.pavan@in.ibm.com    
@created : 28 April 2020
@Description : Class for SiteOwner & AuthRep Utility
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/

public without sharing class TVE_SiteOwnerAuthRepUtil {
    
    public static final string ACC_CUST_INDIV_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Individual').getRecordTypeId();
    public static final string ACC_CUST_BUSIN_RECTYPEID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer_Business').getRecordTypeId();
    private static final string PERSON_SITEOWNER = 'PERSON_SITEOWNER';
    private static final string PERSON_AUTHREP = 'PERSON_AUTHREP';
    private static final string BUSSINESS_SITEOWNER = 'BUSSINESS_SITEOWNER';
    private static final string BUSSINESS_AUTHREP = 'BUSSINESS_AUTHREP';
    private static final string CUSTOMER_TYPE_CINCL = 'ELE - CINCL';
        
    public static project__c populateSiteOwnerAuthRep(Project__c proj)
    {
        Account siteOwnerAccount;
        Contact siteOwnerContact;
        Account authorisedRepAccount;
        Contact authorisedRepCon;
        
        String siteOwnerEmail = proj.OwnerEmail__c;
        String siteOwnerCompany =  proj.OwnerCompany__c;
        String authRepEmail = proj.AgentEmail__c;
        String authRepCompany = proj.AgentCompany__c;

        //---------------------------------------------------//
        //----------------- ABN Mapping  --------------------//
        //---------------------------------------------------//

        Set<string> abnSet = new Set<string>();
        Map<String, Account> accountsByABN = new Map<String, Account>();

        if(String.isNotBlank(proj.OwnerABN__c)){
            abnSet.add(proj.OwnerABN__c);
        }
        if(String.isNotBlank(proj.AgentABN__c)){
            abnSet.add(proj.AgentABN__c);
        }

        system.debug('abnSet: '+abnSet);
        if(!abnSet.isEmpty()){
            for(Account acc : [Select id, ABN_CINCL__c, ASPaccreditaionID__c, PersonContactId from Account Where ABN_CINCL__c in:abnSet order by createdDate DESC]){
                if(!accountsByABN.containsKey(acc.ABN_CINCL__c))
               	 	accountsByABN.put(acc.ABN_CINCL__c, acc);
            }
        }
        system.debug('accountsByABN: '+accountsByABN);

        //---------------------------------------------------//
        //-------------- Site Owner Calculation -------------//
        //---------------------------------------------------//
        
        if(String.isNotBlank(siteOwnerEmail))
        {                
            if(String.isBlank(siteOwnerCompany))
            {                  
                //---------------------------------------------------------//
                //-------------- Site Owner as Person Account -------------//
                //---------------------------------------------------------//
                siteOwnerAccount = createPersonAccount(
                    ACC_CUST_INDIV_RECTYPEID,
                    proj.OwnerFirstName__c,
                    proj.OwnerLastName__c,
                    siteOwnerEmail,
                    proj.OwnerMobile__c,
                    proj.OwnerStreet__c,
                    proj.OwnerSuburb__c,
                    proj.OwnerPostalCode__c,
                    proj.OwnerState__c,
                    proj.OwnerPreferredContactMethod__c
                );
                
                siteOwnerContact = new Contact();
                
                ProjectAccContInfo projInfo = Customer_PersonAccount(proj, siteOwnerEmail, siteOwnerAccount, siteOwnerContact);
                proj = projInfo.prj;
                siteOwnerAccount = projInfo.acct;
                siteOwnerContact = projInfo.cont;
            }
            else
            {
                //---------------------------------------------------------//
                //------------ Site Owner as Business Account -------------//
                //---------------------------------------------------------//
                siteOwnerAccount  = createBusinessAccount(
                    ACC_CUST_BUSIN_RECTYPEID,
                    proj.OwnerCompany__c,
                    proj.OwnerABN__c,
                    proj.OwnerStreet__c,
                    proj.OwnerSuburb__c,
                    proj.OwnerPostalCode__c,
                    proj.OwnerState__c
                );
                
                siteOwnerContact = createContact(
                    proj.OwnerABN__c,
                    proj.OwnerFirstName__c,
                    proj.OwnerLastName__c,
                    siteOwnerEmail,
                    proj.OwnerMobile__c,
                    proj.OwnerStreet__c,
                    proj.OwnerSuburb__c,
                    proj.OwnerPostalCode__c,
                    proj.OwnerState__c,
                    proj.OwnerPreferredContactMethod__c
                );
                
                ProjectAccContInfo projInfo = Customer_BusinessAccount(proj, accountsByABN, siteOwnerEmail, siteOwnerAccount, siteOwnerContact);
                proj = projInfo.prj;
                siteOwnerAccount = projInfo.acct;
                siteOwnerContact = projInfo.cont;
            }
        }

        //---------------------------------------------------//
        //-------------- Auth Rep Calculation ---------------//
        //---------------------------------------------------//

        //------------------------------------------------------//
        //-------------- If project created by ASP -------------//
        //------------------------------------------------------//
        
        //-------------------- ASP Check --------------------//
        
        if(isASP(proj))    
        {
            if(String.isNotBlank(authRepEmail))
            {
                if(String.isBlank(authRepCompany))
                {
                    //---------------------------------------------------------//
                    //-------------- Auth Rep as Person Account ---------------//
                    //---------------------------------------------------------//
                    
                    authorisedRepAccount = createPersonAccount(
                        ACC_CUST_INDIV_RECTYPEID,
                        proj.AgentFirstName__c,
                        proj.AgentLastName__c,
                        authRepEmail,
                        proj.AgentMobile__c,
                        proj.AgentStreet__c,
                        proj.AuthorizedRepSuburb__c,
                        proj.AgentPostalCode__c,
                        proj.AgentState__c,
                        proj.AuthorizedRepPreferredContactMethod__c
                    );

                    authorisedRepCon = new Contact();

                    ProjectAccContInfo projInfo = ASP_PersonAccount(proj, authRepEmail, authorisedRepAccount, authorisedRepCon);
                    proj = projInfo.prj;
                    authorisedRepAccount = projInfo.acct;
                    authorisedRepCon = projInfo.cont;
                    
                    system.debug('authorisedRepAccount: '+authorisedRepAccount);
                }
                else
                {
                    //---------------------------------------------------------//
                    //-------------- Auth Rep as Business Account -------------//
                    //---------------------------------------------------------//

                    authorisedRepAccount = createBusinessAccount(
                        ACC_CUST_BUSIN_RECTYPEID,
                        authRepCompany,
                        proj.AgentABN__c,
                        proj.AgentStreet__c,
                        proj.AuthorizedRepSuburb__c,
                        proj.AgentPostalCode__c,
                        proj.AgentState__c
                    );
                    
                    system.debug('authorisedRepAccount: '+authorisedRepAccount);                        
    
                    authorisedRepCon = createContact(
                        proj.AgentABN__c,
                        proj.AgentFirstName__c,
                        proj.AgentLastName__c,
                        authRepEmail,
                        proj.AgentMobile__c,
                        proj.AgentStreet__c,
                        proj.AuthorizedRepSuburb__c,
                        proj.AgentPostalCode__c,
                        proj.AgentState__c,
                        proj.AuthorizedRepPreferredContactMethod__c
                    );

                    ProjectAccContInfo projInfo = ASP_BusinessAccount(proj, accountsByABN, authRepEmail, authorisedRepAccount, authorisedRepCon);
                    proj = projInfo.prj;
                    authorisedRepAccount = projInfo.acct;
                    authorisedRepCon = projInfo.cont;                    
                }
            } 
        }
        
        //---------------------------------------------------------------------------//
        //--------------- If project NOT created by ASP (i.e. customer) -------------//
        //--------------------------------------------------------------------------//

        else                            
        {
            if(String.isNotBlank(authRepEmail))
            {
                if(String.isBlank(authRepCompany))
                {
                    //---------------------------------------------------------//
                    //-------------- Auth Rep as Person Account ---------------//
                    //---------------------------------------------------------//
                    
                    authorisedRepAccount = createPersonAccount(
                        ACC_CUST_INDIV_RECTYPEID,
                        proj.AgentFirstName__c,
                        proj.AgentLastName__c,
                        authRepEmail,
                        proj.AgentMobile__c,
                        proj.AgentStreet__c,
                        proj.AuthorizedRepSuburb__c,
                        proj.AgentPostalCode__c,
                        proj.AgentState__c,
                        proj.AuthorizedRepPreferredContactMethod__c
                    );

                    authorisedRepCon = new Contact();

                    ProjectAccContInfo projInfo = Customer_PersonAccount(proj, authRepEmail, authorisedRepAccount, authorisedRepCon);
                    proj = projInfo.prj;
                    authorisedRepAccount = projInfo.acct;
                    authorisedRepCon = projInfo.cont;
                    
                    system.debug('authorisedRepAccount: '+authorisedRepAccount);
                }
                else
                {
                    //---------------------------------------------------------//
                    //-------------- Auth Rep as Business Account -------------//
                    //---------------------------------------------------------//


                    authorisedRepAccount = createBusinessAccount(
                        ACC_CUST_BUSIN_RECTYPEID,
                        authRepCompany,
                        proj.AgentABN__c,
                        proj.AgentStreet__c,
                        proj.AuthorizedRepSuburb__c,
                        proj.AgentPostalCode__c,
                        proj.AgentState__c
                    );
                    
                    system.debug('authorisedRepAccount: '+authorisedRepAccount);                        
    
                    authorisedRepCon = createContact(
                        proj.AgentABN__c,
                        proj.AgentFirstName__c,
                        proj.AgentLastName__c,
                        authRepEmail,
                        proj.AgentMobile__c,
                        proj.AgentStreet__c,
                        proj.AuthorizedRepSuburb__c,
                        proj.AgentPostalCode__c,
                        proj.AgentState__c,
                        proj.AuthorizedRepPreferredContactMethod__c
                    );

                    ProjectAccContInfo projInfo = Customer_BusinessAccount(proj, accountsByABN, authRepEmail, authorisedRepAccount, authorisedRepCon);
                    proj = projInfo.prj;
                    authorisedRepAccount = projInfo.acct;
                    authorisedRepCon = projInfo.cont;                    
                }
            }
        }

        if(siteOwnerAccount != null && siteOwnerAccount.Id != null)
            proj.SiteOwner__c = siteOwnerAccount.Id;

        if(siteOwnerContact != null && siteOwnerContact.Id != null)
            proj.PropertyOwnerContact__c = siteOwnerContact.Id;

        if(authorisedRepAccount != null && authorisedRepAccount.Id != null)
            proj.AuthorisedRepresentative__c = authorisedRepAccount.Id;

        if(authorisedRepCon != null && authorisedRepCon.Id != null)
            proj.AuthorizedRepresentativeContact__c = authorisedRepCon.Id;

        return proj;
    } 

    public static ProjectAccContInfo ASP_PersonAccount(Project__c proj, String email, Account accountRec, Contact contactRec)
    {
        ProjectAccContInfo prjInfo = new ProjectAccContInfo();
        String msg;
        
        //---------------------------------------------------//
        //--------------------- Email Match -----------------//
        //---------------------------------------------------//
        
        List<Contact> existBusiCont = getContactsByEmail(email, 1);
        List<Account> existPersonAcc = getPersonAccountsByEmail(email, 1);
        
        if(!existBusiCont.isEmpty() || !existPersonAcc.isEmpty())
        {
            if(!existBusiCont.isEmpty())
            {
                msg = 'Existing customer of a company found with the same email - '+ email + '. Business Contact ID - ' + existBusiCont[0].Id; 
                proj = TVE_Project_Utility.TriageProject(proj, msg);
                
            }
            else if(!existPersonAcc.isEmpty())
            {                        
                //---------------------------------------------------//
                //--------------------- Fuzzy Match -----------------//
                //---------------------------------------------------//

                List<Datacloud.MatchRecord> matchRecords = getDuplicates(new List<Account>{accountRec});
                //system.debug('matchRecords----->'+matchRecords);

                if (matchRecords.size() > 0) 
                {
                    Account acc = (Account)matchRecords[0].getRecord();
                    system.debug('Duplicate Found. Existing Account Id:--->'+acc.Id);            
                    Account accRecord = [SELECT Id, ASPaccreditaionID__c, isPersonAccount, PersonContactId FROM Account WHERE Id =: acc.Id LIMIT 1];
                    if(accRecord.ASPaccreditaionID__c != null)
                    {                                    
                        //Triage - do nothing (retrieved ASP correctly)
                        
                        accountRec = new Account(Id = accRecord.Id);                                   
                        contactRec = new Contact(Id = accRecord.PersonContactId);                                    
                    }
                    else 
                    {
                        msg = 'No ASP contact found with email - '+ email +'. Please add per business process.';
                        proj = TVE_Project_Utility.TriageProject(proj, msg);
                        //siteOwner & authRep will not be inserted
                    }                                
                }
                else
                {                            
                    system.debug('duplicate NOT found');
                    msg = 'No ASP contact found with email - '+ email +'. Please add per business process.';
                    proj = TVE_Project_Utility.TriageProject(proj, msg);
                }
            }
        }
        else 
        {
            msg = 'No ASP contact found with email - '+ email +'. Please add per business process.';
            proj = TVE_Project_Utility.TriageProject(proj, msg);
        }         
        
        prjInfo.prj = proj;
        prjInfo.acct = accountRec;
        prjInfo.cont = contactRec;

        return prjInfo;
    }

    public static ProjectAccContInfo ASP_BusinessAccount(Project__c proj, Map<String, Account> accountsByABN, String email, Account accountRec, Contact contactRec)
    {        
        ProjectAccContInfo prjInfo = new ProjectAccContInfo(); 
        String msg;        
        
        //---------------------------------------------------//
        //--------------------- ABN Check -------------------//
        //---------------------------------------------------//                
        
        if(accountRec.ABN_CINCL__c != null && accountsByABN.containsKey(accountRec.ABN_CINCL__c))
        {
            Account accByABN = accountsByABN.get(accountRec.ABN_CINCL__c);
        
            //---------------------------------------------------//
            //--------------------- Email Check -----------------//
            //---------------------------------------------------//
                                
            List<Contact> existBusiCont = getContactsByEmail(email, -1);
            List<Account> existPersonAcc = getPersonAccountsByEmail(email, -1);
            
            if(!existBusiCont.isEmpty() || !existPersonAcc.isEmpty())
            {
                List<Id> accIds = new List<Id>();                                
                Set<Id> accIdsMatchedEmail = new Set<Id>();

                for(Contact item: existBusiCont)
                {
                    accIdsMatchedEmail.add(item.AccountId);
                    if(item.AccountId != accByABN.Id)
                        accIds.add(item.AccountId);
                }
                for(Account item: existPersonAcc)
                {
                    accIdsMatchedEmail.add(item.Id);
                    if(item.Id != accByABN.Id)
                        accIds.add(item.Id);
                }

                //------------------------------------------------------------//
                //--------------------- ABN vs Email Compare -----------------//
                //------------------------------------------------------------//

                Boolean isABNMatchAndEmailMatchSame = accIdsMatchedEmail.contains(accByABN.Id) && accIdsMatchedEmail.size() == 1;

                if(!isABNMatchAndEmailMatchSame)
                {
                    msg = 'Same contact has switched company. Account IDs - ' + String.join(accIds, ', ');
                    proj = TVE_Project_Utility.TriageProject(proj, msg);
                }
                else
                {
                    //---------------------------------------------------//
                    //--------------------- Fuzzy Match -----------------//
                    //---------------------------------------------------//

                    Contact cont = getDuplicateContact(accountRec, contactRec);
                    //system.debug('matchRecords----->'+matchRecords);

                    if (cont != null) 
                    {
                        Contact existConRec = [SELECT Id, AccountId FROM Contact WHERE Id =: cont.Id];
                        Account accRec = [SELECT ASPaccreditaionID__c FROM Account WHERE Id =: existConRec.AccountId LIMIT 1];

                        if(accRec.ASPaccreditaionID__c != null)
                        {
                            //do nothing (retrieved ASP correctly)
                            accountRec = new Account(Id = existConRec.AccountId);
                            contactRec = new Contact(Id = existConRec.Id);
                        }
                        else
                        {
                            msg = 'No ASP contact found with email - '+ email +'. Please add per business process';
                            proj = TVE_Project_Utility.TriageProject(proj, msg);
                            //AuthRep will not be inserted
                        }
                    }
                    else
                    {
                        //AuthRep will not be inserted
                        msg = 'Existing customer found with email - '+email+'. Contact Id - '+existBusiCont[0].Id+'.'; 
                        proj = TVE_Project_Utility.TriageProject(proj, msg);
                    }
                }
            }
            else
            {
                msg = 'No ASP contact found with email - '+ email +'. Please add per business process';
                proj = TVE_Project_Utility.TriageProject(proj, msg);
                //siteOwner & authRep will not be inserted                                                           
            }
        }
        else
        {
            //----------------------------------------------------//
            //--------------------- no ABN match -----------------//
            //----------------------------------------------------//


            //---------------------------------------------------//
            //--------------------- Email Check -----------------//
            //---------------------------------------------------//
                                
            List<Contact> existBusiCont = getContactsByEmail(email, -1);
            List<Account> existPersonAcc = getPersonAccountsByEmail(email, -1);
            
            if(!existBusiCont.isEmpty() || !existPersonAcc.isEmpty())
            {
                if(!existPersonAcc.isEmpty())
                {
                    msg = 'Existing individual customer found with the same email. Person Account Id - '+ existPersonAcc[0].Id;
                    proj = TVE_Project_Utility.TriageProject(proj, msg);
                }
                else if(!existBusiCont.isEmpty())
                {
                    System.debug('existBusiCont--->'+existBusiCont);
                    
                    //---------------------------------------------------//
                    //--------------------- Fuzzy Match -----------------//
                    //---------------------------------------------------//
                    
                    Contact cont = getDuplicateContact(accountRec, contactRec);
                    //system.debug('matchRecords----->'+matchRecords);

                    if (cont != null) 
                    {
                        Contact existConRec = [SELECT Id, AccountId FROM Contact WHERE Id =: cont.Id];
                        Account accRec = [SELECT ASPaccreditaionID__c FROM Account WHERE Id =: existConRec.AccountId LIMIT 1];

                        if(accRec.ASPaccreditaionID__c != null)
                        {
                            msg = 'Same contact has switched company. Contact ID - ' + existConRec.Id;
                            proj = TVE_Project_Utility.TriageProject(proj, msg);
                        }
                        else 
                        {
                            msg = 'No ASP contact found with email - '+ email +'. Please add per business process';
                            proj = TVE_Project_Utility.TriageProject(proj, msg);                                                                                            
                        }
                    }
                    else
                    {
                        // If the new account doesn't have duplicates, insert it.
                        msg = 'Existing customer found with email '+email+'. Contact ID - '+existBusiCont[0].Id;
                        proj = TVE_Project_Utility.TriageProject(proj, msg);
                    }                  
                }
            }
            else
            {
                msg = 'No ASP contact found with email - '+ email +'. Please add per business process';
                proj = TVE_Project_Utility.TriageProject(proj, msg);                                                                                            
            }
            
            system.debug('accountRec: '+accountRec);                        
        }                
        
        prjInfo.prj = proj;
        prjInfo.acct = accountRec;
        prjInfo.cont = contactRec;

        return prjInfo;
    }

    
    public static ProjectAccContInfo Customer_PersonAccount(Project__c proj, String email, Account accountRec, Contact contactRec)
    {
        ProjectAccContInfo prjInfo = new ProjectAccContInfo();
        String msg;
        
        //---------------------------------------------------//
        //--------------------- Email Match -----------------//
        //---------------------------------------------------//
        
        List<Contact> existBusiCont = getContactsByEmail(email, 1);
        List<Account> existPersonAcc = getPersonAccountsByEmail(email, 1);
        
        if(!existBusiCont.isEmpty() || !existPersonAcc.isEmpty())
        {
            if(!existPersonAcc.isEmpty())
            {                        
                //---------------------------------------------------//
                //--------------------- Fuzzy Match -----------------//
                //---------------------------------------------------//
                
                List<Datacloud.MatchRecord> matchRecords = getDuplicates(new List<Account>{accountRec});
                //system.debug('matchRecords----->'+matchRecords);

                if (matchRecords.size() > 0) 
                {
                    Account acc = (Account)matchRecords[0].getRecord();
                    system.debug('Duplicate Found. Existing Account Id:--->'+acc.Id);            
                    Account accRecord = [SELECT Id, ASPaccreditaionID__c, isPersonAccount, PersonContactId FROM Account WHERE Id =: acc.Id LIMIT 1];
                    if(accRecord.ASPaccreditaionID__c != null)
                    {                                    
                        msg = 'Existing customer found which is already an ASP with email ' + email + '. Person Account ID - ' + accRecord.Id;
                        proj = TVE_Project_Utility.TriageProject(proj, msg);
                        
                    }
                    else 
                    {
                        accountRec = new Account(Id = accRecord.Id);                                   
                        contactRec = new Contact(Id = accRecord.PersonContactId);                                    
                    }
                }
                else
                {                            
                    system.debug('duplicate NOT found');
                    msg = 'Existing customer found with email '+ email +'. Person Account ID - ' + existPersonAcc[0].Id;
                    proj = TVE_Project_Utility.TriageProject(proj, msg);
                }                        
            }
            else if(!existBusiCont.isEmpty())
            {
                msg = 'Existing customer of a company found with the same email - '+ email + '. Business Contact ID - ' + existBusiCont[0].Id + '. Please populate the contact email manually'; 
                proj = TVE_Project_Utility.TriageProject(proj, msg);

                accountRec.PersonEmail = null;
                insert accountRec;
                Account acc = [SELECT Id, PersonContactId FROM Account WHERE Id =: accountRec.Id LIMIT 1];
                contactRec = new Contact(Id = acc.PersonContactId);
            }
        }
        else 
        {
            insert accountRec;
            Account acc = [SELECT Id, PersonContactId FROM Account WHERE Id =: accountRec.Id LIMIT 1];
            contactRec = new Contact(Id = acc.PersonContactId);                              
        }         
        
        prjInfo.prj = proj;
        prjInfo.acct = accountRec;
        prjInfo.cont = contactRec;

        return prjInfo;

    }

    public static ProjectAccContInfo Customer_BusinessAccount(Project__c proj, Map<String, Account> accountsByABN, String email, Account accountRec, Contact contactRec)
    {
        ProjectAccContInfo prjInfo = new ProjectAccContInfo();
        String msg;

        //---------------------------------------------------//
        //--------------------- ABN Check -------------------//
        //---------------------------------------------------//                
        
        if(accountRec.ABN_CINCL__c != null && accountsByABN.containsKey(accountRec.ABN_CINCL__c))
        {
            Account accByABN = accountsByABN.get(accountRec.ABN_CINCL__c);
        
            //---------------------------------------------------//
            //--------------------- Email Check -----------------//
            //---------------------------------------------------//
            
            List<Contact> existBusiCont = getContactsByEmail(email, -1);
            List<Account> existPersonAcc = getPersonAccountsByEmail(email, -1);
            
            if(!existBusiCont.isEmpty() || !existPersonAcc.isEmpty())
            {
                List<Id> accIds = new List<Id>();
                Set<Id> accIdsMatchedEmail = new Set<Id>();

                for(Contact item: existBusiCont)
                {
                    accIdsMatchedEmail.add(item.AccountId);
                    if(item.AccountId != accByABN.Id)
                        accIds.add(item.AccountId);
                }
                for(Account item: existPersonAcc)
                {
                    accIdsMatchedEmail.add(item.Id);
                    if(item.Id != accByABN.Id)
                        accIds.add(item.Id);
                }

                //------------------------------------------------------------//
                //--------------------- ABN vs Email Compare -----------------//
                //------------------------------------------------------------//

                Boolean isABNMatchAndEmailMatchSame = accIdsMatchedEmail.contains(accByABN.Id) && accIdsMatchedEmail.size() == 1;

                if(!isABNMatchAndEmailMatchSame)
                {
                    msg = 'Same contact has switched company. Account IDs - ' + String.join(accIds, ', ');
                    proj = TVE_Project_Utility.TriageProject(proj, msg);
                }
                else 
                {
                    //---------------------------------------------------//
                    //--------------------- Fuzzy Match -----------------//
                    //---------------------------------------------------//

                    Contact cont = getDuplicateContact(accountRec, contactRec);
                    //system.debug('matchRecords----->'+matchRecords);

                    if (cont != null) 
                    {
                        Contact existConRec = [SELECT Id, AccountId FROM Contact WHERE Id =: cont.Id];
                        Account existAccRec = [SELECT ASPaccreditaionID__c FROM Account WHERE Id =: existConRec.AccountId LIMIT 1];

                        if(existAccRec.ASPaccreditaionID__c != null)
                        {
                            msg = 'Existing customer found which is already an ASP with email '+email+'. Contact Id - ' + existConRec.Id;
                            proj = TVE_Project_Utility.TriageProject(proj, msg);                                    
                        }
                        else 
                        {
                            accountRec = new Account(Id = existConRec.AccountId);
                            contactRec = new Contact(Id = existConRec.Id);
                        }
                    }
                    else
                    {
                        // If the new account doesn't have duplicates
                        msg = 'Existing customer found with email '+email+'. Contact Id - '+existBusiCont[0].Id; 
                        proj = TVE_Project_Utility.TriageProject(proj, msg);
                    }
                }
            }
            else
            {
                if(accByABN.ASPaccreditaionID__c != null)
                {
                    msg = 'Existing customer found which is already an ASP with email '+email+'. Account Id - ' + accByABN.Id;
                    proj = TVE_Project_Utility.TriageProject(proj, msg);                                    
                }
                else 
                {
                    accountRec = new Account(Id = accByABN.Id);
                    insert contactRec;
                }                
            }
        }
        else
        {
            //----------------------------------------------------//
            //--------------------- no ABN match -----------------//
            //----------------------------------------------------//


            //---------------------------------------------------//
            //--------------------- Email Check -----------------//
            //---------------------------------------------------//
            
            List<Contact> existBusiCont = getContactsByEmail(email, -1);
            List<Account> existPersonAcc = getPersonAccountsByEmail(email, -1);
            
            if(!existBusiCont.isEmpty() || !existPersonAcc.isEmpty())
            {
                if(!existBusiCont.isEmpty())
                {
                    
                    //---------------------------------------------------//
                    //--------------------- Fuzzy Match -----------------//
                    //---------------------------------------------------//

                    Contact cont = getDuplicateContact(accountRec, contactRec);
                    //system.debug('matchRecords----->'+matchRecords);

                    if (cont != null) 
                    {
                        Contact existConRec = [SELECT Id, AccountId FROM Contact WHERE Id =: cont.Id];
                        Account accRec = [SELECT ASPaccreditaionID__c FROM Account WHERE Id =: existConRec.AccountId LIMIT 1];

                        if(accRec.ASPaccreditaionID__c != null)
                        {
                            msg = 'Existing customer found which is already an ASP with email - '+email+'. Contact Id - '+existConRec.Id;
                            proj = TVE_Project_Utility.TriageProject(proj, msg);
                        }
                        else 
                        {
                            msg = 'Same contact has switched company. Contact ID - ' + existConRec.Id;
                            proj = TVE_Project_Utility.TriageProject(proj, msg);
                        }
                    }
                    else
                    {
                        // If the new account doesn't have duplicates
                        msg = 'Existing customer found with email '+email+'. Contact ID - '+existBusiCont[0].Id;
                        proj = TVE_Project_Utility.TriageProject(proj, msg);
                    }                  
                }
                else if(!existPersonAcc.isEmpty())
                {
                    msg = 'Existing individual customer found with the same email. Person Account Id - '+ existPersonAcc[0].Id + '. Please populate the contact email manually';
                    proj = TVE_Project_Utility.TriageProject(proj, msg);            

                    insert accountRec;
                    contactRec.Email = null;
                    insert contactRec;
                }
            }
            else
            {
                insert accountRec;
                insert contactRec;
            }
        }                
        
        prjInfo.prj = proj;
        prjInfo.acct = accountRec;
        prjInfo.cont = contactRec;

        return prjInfo;
    }

    public static boolean isASP(Project__c proj)
    {
        Boolean isASPFlag = false;

        if(proj.IsPropertyOwner__c =='No' && proj.RelationshipToOwner__c == 'Accredited Service Provider - AusNet Services')
        {
            isASPFlag = true;
        }

        return isASPFlag;
    }

    private static Account createPersonAccount(
        Id recTypeId,
        String firstName,
        String lastName,
        String email,
        String mobile,
        String street,
        String suburb,
        String postcode,
        String state,
        String contactMethod
    ){
        Account acc = new Account();
        acc.FirstName = firstName;
        acc.LastName  = lastName;
        acc.PersonEmail = email;
        acc.PersonMobilePhone = mobile;
        acc.PersonMailingStreet = street;
        acc.PersonMailingCity = suburb;
        acc.PersonMailingPostalCode = postcode;
        acc.PersonMailingState = state;
        acc.CommunicationPreference__pc = contactMethod;
        acc.Customer_Type__c = 'ELE - CINCL';
        acc.RecordTypeID = recTypeId;
        return acc;
    }
    
    private static Account createBusinessAccount(
        Id rectypeId,
        String company,
        String abn,
        String street,
        String suburb,
        String postcode,
        String state
    ){
        Account acc = new Account();
        acc.Name = company;
        acc.ABN_CINCL__c = abn;
        acc.Customer_Type__c = 'ELE - CINCL';
        acc.BillingStreet = street;
        acc.BillingCity = suburb;
        acc.BillingPostalCode = postcode;
        acc.BillingState = state;
        acc.RecordTypeID = rectypeId;
        return acc;
    }

    private static Contact createContact(
        String abn,
        String firstName,
        String lastName,
        String email,
        String mobile,
        String street,
        String suburb,
        String postcode,
        String state,
        String contactMethod
    ){
        Contact con = new Contact();
        con.Account = new Account(ABN_CINCL__c = abn);
        con.FirstName = firstName;
        con.LastName = lastName;
        con.Email = email;
        con.MobilePhone = mobile;
        con.MailingStreet = street;
        con.MailingCity = suburb;
        con.MailingPostalCode = postcode;
        con.MailingState = state;
        con.CommunicationPreference__c = contactMethod;
        return con;
    }

    private static List<Datacloud.MatchRecord> getDuplicates(List<SObject> records) {
        List<Datacloud.MatchRecord> duplicates = new List<Datacloud.MatchRecord>();

        try {
            for(Datacloud.FindDuplicatesResult findDup : Datacloud.FindDuplicates.findDuplicates(records)) {
                System.debug('findDup--->'+findDup);
                for(Datacloud.DuplicateResult dupResult : findDup.getDuplicateResults()) {
                    System.debug('dupResult--->'+dupResult);
                    for(Datacloud.MatchResult matchResult : dupResult.getMatchResults()) {
                        System.debug('matchResult--->'+matchResult);
                        duplicates.addAll(matchResult.getMatchRecords());
                    }
                }
            }
        } catch (System.HandledException e) {}
        return duplicates;
    }

    private static Contact getDuplicateContact(Account acct, Contact cont) {
        Savepoint sp = Database.setSavepoint();

        Account acc = acct.clone(false, true, false, false);
        acc.ABN_CINCL__c = null;
        insert acc;
        Contact con = cont.clone(false, true, false, false);
        con.Account = null;
        con.AccountId = acc.Id;
        con.Customer_Type__c = 'ELE - CINCL';

        List<Datacloud.MatchRecord> matchRecords = getDuplicates(new List<Contact>{con});

        Database.rollback(sp);

        if(matchRecords.isEmpty()) {
            return null;
        }
        return (Contact)matchRecords[0].getRecord();
    }

    private static List<Account> getPersonAccountsByEmail(String email, Integer row) {
        String query = 'SELECT Id FROM Account WHERE PersonEmail = :email'
                        + ' AND Customer_Type__c = :CUSTOMER_TYPE_CINCL';
        if(row > 0) {
            query += ' LIMIT :row';
        }
        return Database.query(query);
    }

    private static List<Contact> getContactsByEmail(String email, Integer row) {
        String query = 'SELECT Id, AccountId FROM Contact WHERE Email = :email'
                        + ' AND Account.IsPersonAccount = false'
                        + ' AND Account.Customer_Type__c = :CUSTOMER_TYPE_CINCL';
        if(row > 0) {
            query += ' LIMIT :row';
        }
        return Database.query(query);
    }

    public class ProjectAccContInfo
    {
        Project__c prj;
        Account acct;
        Contact cont;
        public ProjectAccContInfo()
        {
            this.prj = new Project__c();
            this.acct = new Account();
            this.cont = new Contact();
        }
    }
    
}