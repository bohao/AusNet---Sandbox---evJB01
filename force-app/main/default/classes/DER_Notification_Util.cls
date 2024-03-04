/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 26 Sep 2019
  @Description : Class for Notification Utility
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/

public with sharing class DER_Notification_Util {
    
	// Called from before update & after insert event on Case
    public static void PopuplateNotificationFields(Map<Id, sObject> newSObj, String field, 
													Map<Id, Id> caseWithInstaller,
													Map<Id, Id> caseWithRep,
													Map<Id, Id> caseWithCustomer,
                                                    Boolean doDML)
	{
		System.debug('PopuplateNotificationFields for '+field+' caseWithCustomer-------------------->'+caseWithCustomer);
		System.debug('PopuplateNotificationFields for '+field+' caseWithInstaller-------------------->'+caseWithInstaller);
		System.debug('PopuplateNotificationFields for '+field+' caseWithRep-------------------->'+caseWithRep);

		Map<Id, Account> mapCustomerAcc = new Map<Id, Account>([SELECT Id, IsPersonAccount, FirstName, LastName, PersonEmail, 
																		(SELECT Id, FirstName, LastName, Email
																			FROM Contacts LIMIT 1)
																	FROM Account 
																	WHERE Id IN: caseWithCustomer.values()]);

		Map<Id, Contact> mapCont = new Map<Id, Contact>([SELECT Id, FirstName, LastName, Email
																FROM Contact
																WHERE Id IN: caseWithInstaller.values()
																	OR Id IN: caseWithRep.values()]);
		
        Map<Id, Case> mapUpdCase = new Map<Id, Case>();

		Contact conRec;
		Account accRec;
        Case caseRec;
        Case updCase;
        String name;
        String email;

		for(Id idItem: caseWithInstaller.keySet())
		{
			conRec = mapCont.get(caseWithInstaller.get(idItem));				
            caseRec = (Case)newSObj.get(idItem);
            name = getName(conRec);
            email = conRec.Email;

			if(field == 'Applicant_Type__c')
			{
				if(doDML)
                {
                    if(mapUpdCase.containsKey(caseRec.Id)){
                        updCase = mapUpdCase.get(caseRec.Id);
                        updCase.Applicant_Name__c = name;
                        updCase.Applicant_Email__c = email;
                    }else{
                        updCase = new Case(Id = caseRec.Id, 
                                    Applicant_Name__c = name,
                                    Applicant_Email__c = email);
                    }                    
                    mapUpdCase.put(caseRec.Id, updCase);
                }
                else 
                {
                    caseRec.Applicant_Name__c = name;		
				    caseRec.Applicant_Email__c = email; 
                }                
			}
			else if(field == 'Responsible_Party__c')
			{
				if(doDML)
                {
                    if(mapUpdCase.containsKey(caseRec.Id)){
                        updCase = mapUpdCase.get(caseRec.Id);
                        updCase.Resp_Party_Name__c = name;
                        updCase.Resp_Party_Email__c = email;
                    }else{
                        updCase = new Case(Id = caseRec.Id, 
                                    Resp_Party_Name__c = name,
                                    Resp_Party_Email__c = email);
                    }                    
                    mapUpdCase.put(caseRec.Id, updCase);
                }
                else 
                {
                    caseRec.Resp_Party_Name__c = name;		
				    caseRec.Resp_Party_Email__c = email; 
                }   
			}            
		}

		for(Id idItem: caseWithRep.keySet())
		{
			conRec = mapCont.get(caseWithRep.get(idItem));
            caseRec = (Case)newSObj.get(idItem);
            name = getName(conRec);
            email = conRec.Email;

			if(field == 'Applicant_Type__c')
			{
				if(doDML)
                {
                    if(mapUpdCase.containsKey(caseRec.Id)){
                        updCase = mapUpdCase.get(caseRec.Id);
                        updCase.Applicant_Name__c = name;
                        updCase.Applicant_Email__c = email;
                    }else{
                        updCase = new Case(Id = caseRec.Id, 
                                    Applicant_Name__c = name,
                                    Applicant_Email__c = email);
                    }                    
                    mapUpdCase.put(caseRec.Id, updCase);
                }
                else 
                {
                    caseRec.Applicant_Name__c = name;		
				    caseRec.Applicant_Email__c = email; 
                }    
			}
			else if(field == 'Responsible_Party__c')
			{
				if(doDML)
                {
                    if(mapUpdCase.containsKey(caseRec.Id)){
                        updCase = mapUpdCase.get(caseRec.Id);
                        updCase.Resp_Party_Name__c = name;
                        updCase.Resp_Party_Email__c = email;
                    }else{
                        updCase = new Case(Id = caseRec.Id, 
                                    Resp_Party_Name__c = name,
                                    Resp_Party_Email__c = email);
                    }                    
                    mapUpdCase.put(caseRec.Id, updCase);
                }
                else 
                {
                    caseRec.Resp_Party_Name__c = name;		
				    caseRec.Resp_Party_Email__c = email; 
                }   
			}           
		}

		for(Id idItem: caseWithCustomer.keySet())
		{
			accRec = mapCustomerAcc.get(caseWithCustomer.get(idItem));
            caseRec = (Case)newSObj.get(idItem);
			for(Contact cItem: accRec.Contacts)
			{
                name = getName(cItem);
                email = cItem.Email;

				if(field == 'Applicant_Type__c')
				{
					if(doDML)
                    {
                        if(mapUpdCase.containsKey(caseRec.Id)){
                            updCase = mapUpdCase.get(caseRec.Id);
                            updCase.Applicant_Name__c = name;
                            updCase.Applicant_Email__c = email;
                        }else{
                            updCase = new Case(Id = caseRec.Id, 
                                        Applicant_Name__c = name,
                                        Applicant_Email__c = email);
                        }                    
                        mapUpdCase.put(caseRec.Id, updCase);
                    }
                    else 
                    {
                        caseRec.Applicant_Name__c = name;		
                        caseRec.Applicant_Email__c = email; 
                    }    
				}
				else if(field == 'Responsible_Party__c')
				{
					if(doDML)
                    {
                        if(mapUpdCase.containsKey(caseRec.Id)){
                            updCase = mapUpdCase.get(caseRec.Id);
                            updCase.Resp_Party_Name__c = name;
                            updCase.Resp_Party_Email__c = email;
                        }else{
                            updCase = new Case(Id = caseRec.Id, 
                                        Resp_Party_Name__c = name,
                                        Resp_Party_Email__c = email);
                        }                    
                        mapUpdCase.put(caseRec.Id, updCase);
                    }
                    else 
                    {
                        caseRec.Resp_Party_Name__c = name;		
                        caseRec.Resp_Party_Email__c = email; 
                    }   
				}
				break;
			}
		}

        //doDML is true when it is called from After Insert trigger event
        if(doDML && !mapUpdCase.isEmpty())
        {
            update mapUpdCase.values();
        }
	} 

	// Called from before update event on Case
    public static void ClearNotificationFields(String field, List<Case> validCasesToClear)
    {
        System.debug('ClearNotificationFields for '+field+' validCasesToClear-------------------->'+validCasesToClear);

		for(Case caseToClear: validCasesToClear){
            if(field == 'Responsible_Party__c') 
            {
                caseToClear.Resp_Party_Name__c = '';
                caseToClear.Resp_Party_Email__c = '';
            }
            else if(field == 'Applicant_Type__c') 
            {
                caseToClear.Applicant_Name__c = '';
                caseToClear.Applicant_Email__c = '';   
            }
			
		}
    }

    // Called from before update & after insert event on Case
    public static void CustomerEmail_Pop(Map<Id, Case> mapCase, Boolean doDML)
    {
        System.debug('DER_Notification_Util.CustomerEmail_Pop() ------ mapCase.size() ----> '+mapCase.size()+' doDML----> '+doDML);
        Map<Id, Case> mapCaseUpd = new Map<Id, Case>();
        Map<Id, Id> mapCustomerCase = new Map<Id, Id>();
        List<Id> lstAcc = new List<Id>();
        Case caseItem;
        for(Id item: mapCase.keySet())
        {
            caseItem = mapCase.get(item);
            if(caseItem.Customer__c != null)
            {
                lstAcc.add(caseItem.Customer__c);
                mapCustomerCase.put(caseItem.Customer__c, item);               
            }
        }

        Map<Id, Account> mapAcc = new Map<Id, Account>([SELECT Id, PersonEmail, ISPersonAccount
                                                        FROM Account
                                                        WHERE Id IN: lstAcc]);
        List<Id> lstBusiAcc = new List<Id>();
        Account accItem;
        Case caseRec;
        for(Id item: mapAcc.keySet())
        {
            accItem = mapAcc.get(item);
            if(accItem.IsPersonAccount)
            {
                if(doDML)
                {
                    caseRec = new Case();
                    caseRec.Id = mapCustomerCase.get(item);
                    caseRec.Customer_Email__c = accItem.PersonEmail;
                    mapCaseUpd.put(caseRec.Id, caseRec);
                }                    
                else
                {
                    mapCase.get(mapCustomerCase.get(item)).Customer_Email__c = accItem.PersonEmail;
                }                    
            }
            else 
            {
                lstBusiAcc.add(item);    
            }
        }

        Map<Id, Contact> mapContact = new Map<Id, Contact>([SELECT Id, Email, AccountId
                                                            FROM Contact
                                                            WHERE AccountId IN: lstBusiAcc 
                                                                AND Email <> Null]);
        Map<Id, Id> mapCustomerCont = new Map<Id, Id>();
        Contact cont;        
        for(Id item: mapContact.keySet())
        {
            cont = mapContact.get(item);
            if(!mapCustomerCont.containsKey(cont.AccountId))
                mapCustomerCont.put(cont.AccountId, item);
        }
        
        for(Id item: mapContact.keySet())
        {
            cont = mapContact.get(item);
            if(mapCustomerCase.containsKey(cont.AccountId))
            {
                if(doDML)
                {
                    caseRec = new Case();
                    caseRec.Id = mapCustomerCase.get(cont.AccountId);
                    caseRec.Customer_Email__c = cont.Email;
                    mapCaseUpd.put(caseRec.Id, caseRec);
                }                    
                else
                {
                    mapCase.get(mapCustomerCase.get(cont.AccountId)).Customer_Email__c = cont.Email;
                }    
                
            }
        }

        //doDML => true (when called from after insert)
        //doDML => false (when called from before update)
        if(doDML && !mapCaseUpd.isEmpty())
            update mapCaseUpd.values();

    }
    
    // Called from before update event on Case
    public static void CustomerEmail_Clear(Map<Id, Case> mapCase)
    {
        System.debug('DER_Notification_Util.CustomerEmail_Clear() ------ mapCase.size() ----> '+mapCase.size());
        Case caseItem;
        for(Id item: mapCase.keySet())
        {
            caseItem = mapCase.get(item);
            caseItem.Customer_Email__c = null;
        }
    }

	// Called from after update event on Contact
	public static void UpdateNotifFields(Map<Id, String> validContPop_Name, Map<Id, String> validContPop_Email,
										List<Id> validContClear_Email, Map<Id, Id> validAccContIds)
	{
		System.debug('validContPop_Name------->'+validContPop_Name);
        System.debug('validContPop_Email------->'+validContPop_Email);
        System.debug('validContClear_Email------->'+validContClear_Email);
		
		List<Id> validContIds = new List<Id>();
        validContIds.addAll(validContPop_Name.keySet());
		validContIds.addAll(validContPop_Email.keySet());
		validContIds.addAll(validContClear_Email);
		
        Map<Id, Case> casesToBeUpdated = new Map<Id, Case>([SELECT Id, Resp_Party_Name__c, Resp_Party_Email__c,
                                                                    Applicant_Name__c, Applicant_Email__c,
                                                                    Applicant_Type__c, Responsible_Party__c,
                                                                    ContactId, Representative__c, Customer__c
                                                                FROM Case
                                                                WHERE (ContactId IN: validContIds 
                                                                        AND (Applicant_Type__c =: Trig_Case.APPLICANT_INSTALLER
                                                                             OR Responsible_Party__c =: Trig_Case.APPLICANT_INSTALLER)
                                                                        )
                                                                        OR
                                                                        (Representative__c IN: validContIds
                                                                        AND (Applicant_Type__c =: Trig_Case.APPLICANT_REP
                                                                             OR Responsible_Party__c =: Trig_Case.APPLICANT_REP)
                                                                        )
                                                                        OR
                                                                        (Customer__c IN: validAccContIds.keySet()     
                                                                            AND(Applicant_Type__c =: Trig_Case.APPLICANT_CUSTOMER
                                                                             OR Responsible_Party__c =: Trig_Case.APPLICANT_CUSTOMER)
                                                                        )]);

        System.debug('casesToBeUpdated------->'+casesToBeUpdated);

        Case caseRec; 
        Id contId;
        for(Id cIdItem: casesToBeUpdated.keySet())
        {
            caseRec = casesToBeUpdated.get(cIdItem);

            if(caseRec.Applicant_Type__c == Trig_Case.APPLICANT_INSTALLER && validContIds.contains(caseRec.ContactId))
            {
                contId = caseRec.ContactId;
                caseRec = updateCase(caseRec, 'Applicant_Type__c', validContPop_Name, validContPop_Email, validContClear_Email, contId);
            }
            else if(caseRec.Applicant_Type__c == Trig_Case.APPLICANT_REP && validContIds.contains(caseRec.Representative__c))
            {
                contId = caseRec.Representative__c;
                caseRec = updateCase(caseRec, 'Applicant_Type__c', validContPop_Name, validContPop_Email, validContClear_Email, contId);
            }
            else if(caseRec.Applicant_Type__c == Trig_Case.APPLICANT_CUSTOMER && validAccContIds.containsKey(caseRec.Customer__c))
            {
                contId = validAccContIds.get(caseRec.Customer__c);
                caseRec = updateCase(caseRec, 'Applicant_Type__c', validContPop_Name, validContPop_Email, validContClear_Email, contId);
            }

            if(caseRec.Responsible_Party__c == Trig_Case.RESP_PARTY_INSTALLER && validContIds.contains(caseRec.ContactId))
            {
                contId = caseRec.ContactId;
                caseRec = updateCase(caseRec, 'Responsible_Party__c', validContPop_Name, validContPop_Email, validContClear_Email, contId);
            }
            else if(caseRec.Responsible_Party__c == Trig_Case.RESP_PARTY_REP && validContIds.contains(caseRec.Representative__c))
            {
                contId = caseRec.Representative__c;
                caseRec = updateCase(caseRec, 'Responsible_Party__c', validContPop_Name, validContPop_Email, validContClear_Email, contId);
            }
            else if(caseRec.Responsible_Party__c == Trig_Case.RESP_PARTY_CUSTOMER && validAccContIds.containsKey(caseRec.Customer__c))
            {
                contId = validAccContIds.get(caseRec.Customer__c);
                caseRec = updateCase(caseRec, 'Responsible_Party__c', validContPop_Name, validContPop_Email, validContClear_Email, contId);
            }
        }  

        update casesToBeUpdated.values();
	}

	// Called from after update event on Person Account
	public static void UpdateNotifFields_PersonAcc(Map<Id, String> validContPop_Name, Map<Id, String> validContPop_Email,
										List<Id> validContClear_Email)
	{
		System.debug('Person Account ----> validContPop_Name------->'+validContPop_Name);
        System.debug('Person Account ----> validContPop_Email------->'+validContPop_Email);
        System.debug('Person Account ----> validContClear_Email------->'+validContClear_Email);
		
		List<Id> validAccIds = new List<Id>();
        validAccIds.addAll(validContPop_Name.keySet());
		validAccIds.addAll(validContPop_Email.keySet());
		validAccIds.addAll(validContClear_Email);
		
        Map<Id, Case> casesToBeUpdated = new Map<Id, Case>([SELECT Id, Resp_Party_Name__c, Resp_Party_Email__c,
                                                                    Applicant_Name__c, Applicant_Email__c,
                                                                    Applicant_Type__c, Responsible_Party__c,
                                                                    ContactId, Representative__c, Customer__c
                                                                FROM Case
                                                                WHERE (Customer__c IN: validAccIds     
                                                                            AND(Applicant_Type__c =: Trig_Case.APPLICANT_CUSTOMER
                                                                             OR Responsible_Party__c =: Trig_Case.APPLICANT_CUSTOMER)
                                                                        )]);

        System.debug('casesToBeUpdated------->'+casesToBeUpdated);

        Case caseRec; 
        Id personAccId;
        for(Id cIdItem: casesToBeUpdated.keySet())
        {
            caseRec = casesToBeUpdated.get(cIdItem);

            if(caseRec.Applicant_Type__c == Trig_Case.APPLICANT_CUSTOMER && validAccIds.contains(caseRec.Customer__c))
            {
                personAccId = caseRec.Customer__c;
                
				if(validContPop_Name.containsKey(personAccId))
				{
					caseRec.Applicant_Name__c = validContPop_Name.get(personAccId);						
				}

				if(validContPop_Email.containsKey(personAccId))
				{
					caseRec.Applicant_Email__c =  validContPop_Email.get(personAccId);						
				}

				if(validContClear_Email.contains(personAccId))
				{
					caseRec.Applicant_Email__c = '';					
				}
            }

			if(caseRec.Responsible_Party__c == Trig_Case.RESP_PARTY_CUSTOMER && validAccIds.contains(caseRec.Customer__c))
            {
                personAccId = caseRec.Customer__c;
                
				if(validContPop_Name.containsKey(personAccId))
				{
					caseRec.Resp_Party_Name__c = validContPop_Name.get(personAccId);						
				}

				if(validContPop_Email.containsKey(personAccId))
				{
					caseRec.Resp_Party_Email__c =  validContPop_Email.get(personAccId);						
				}

				if(validContClear_Email.contains(personAccId))
				{
					caseRec.Resp_Party_Email__c = '';					
				}
            }
        }  

        update casesToBeUpdated.values();
	}
    
    // Called from after update event on Person Account
	public static void UpdateCustomerEmail_BusinessAcc(Map<Id, String> validContEmail_Pop,
										                List<Id> validContEmail_Clear)
	{
		System.debug('UpdateCustomerEmail_BusinessAcc ----> validContEmail_Clear------->'+validContEmail_Clear);
        System.debug('UpdateCustomerEmail_BusinessAcc ----> validContEmail_Pop------->'+validContEmail_Pop);

        Map<Id, Case> casesToBeUpdated = new Map<Id, Case>([SELECT Id, Customer_Email__c, Customer__c
                                                                FROM Case
                                                                WHERE (Customer__c IN: validContEmail_Pop.keySet()
                                                                    OR Customer__c IN : validContEmail_Clear)
                                                            ]);

        System.debug('UpdateCustomerEmail_BusinessAcc casesToBeUpdated------->'+casesToBeUpdated);
        
        Case caseRec; 
        Map<Id, Id> mapCustIdCaseId = new Map<Id, Id>();
        for(Id cIdItem: casesToBeUpdated.keySet())
        {
            caseRec = casesToBeUpdated.get(cIdItem);
            mapCustIdCaseId.put(caseRec.Customer__c, cIdItem);               
        }  

        for(Id item: validContEmail_Pop.keySet())
        {
            if(mapCustIdCaseId.containsKey(item)){
                casesToBeUpdated.get(mapCustIdCaseId.get(item)).Customer_Email__c = validContEmail_Pop.get(item);
            }
        }

        for(Id item: validContEmail_Clear)
        {
            if(mapCustIdCaseId.containsKey(item)){
                casesToBeUpdated.get(mapCustIdCaseId.get(item)).Customer_Email__c = null;
            }
        }

        if(!casesToBeUpdated.values().isEmpty())
            update casesToBeUpdated.values();
    }

    // Called from after update event on Person Account
	public static void UpdateCustomerEmail_PersonAcc(Map<Id, String> validPersonEmail_Pop,
										                List<Id> validPersonEmail_Clear)
	{
		System.debug('UpdateCustomerEmail_PersonAcc ----> validPersonEmail_Clear------->'+validPersonEmail_Clear);
        System.debug('UpdateCustomerEmail_PersonAcc ----> validPersonEmail_Pop------->'+validPersonEmail_Pop);

        Map<Id, Case> casesToBeUpdated = new Map<Id, Case>();

        for (Case c: [SELECT Id, Customer_Email__c, Customer__c
                        FROM Case
                        WHERE (Customer__c IN: validPersonEmail_Pop.keySet()
                        OR Customer__c IN : validPersonEmail_Clear)])
        {
            casesToBeUpdated.put(c.Id, c);
        }

        if (casesToBeUpdated.isEmpty()) return;
        System.debug('UpdateCustomerEmail_PersonAcc casesToBeUpdated------->'+casesToBeUpdated);
        
        Case caseRec; 
        Map<Id, Id> mapCustIdCaseId = new Map<Id, Id>();
        for(Id cIdItem: casesToBeUpdated.keySet())
        {
            caseRec = casesToBeUpdated.get(cIdItem);
            mapCustIdCaseId.put(caseRec.Customer__c, cIdItem);               
        }  

        for(Id item: validPersonEmail_Pop.keySet())
        {
            casesToBeUpdated.get(mapCustIdCaseId.get(item)).Customer_Email__c = validPersonEmail_Pop.get(item);
        }

        for(Id item: validPersonEmail_Clear)
        {
            casesToBeUpdated.get(mapCustIdCaseId.get(item)).Customer_Email__c = null;
        }

        if(!casesToBeUpdated.values().isEmpty())
            update casesToBeUpdated.values();
    }
    
    // ---------------------------------------------------//
    //--------------- Utility methods --------------------//
    // ---------------------------------------------------//
    
	public static String getName(Contact conRec)
	{
		String name;
		if(String.isNotBlank(conRec.FirstName))
			name = conRec.FirstName + ' ';
		else
			name = '';					
		name += conRec.LastName;
		return name;
	}

    private static Case updateCase(Case caseRec, String field, Map<Id, String> mapNamePop,
                                     Map<Id, String> mapEmailPop, List<Id> lstEmailClear, Id contId)
    {
        if(mapNamePop.containsKey(contId))
        {
            if(field == 'Applicant_Type__c')
                caseRec.Applicant_Name__c = mapNamePop.get(contId);
            else if(field == 'Responsible_Party__c')
                caseRec.Resp_Party_Name__c = mapNamePop.get(contId);
        }

        if(mapEmailPop.containsKey(contId))
        {
            if(field == 'Applicant_Type__c')
                caseRec.Applicant_Email__c =  mapEmailPop.get(contId);
            else if(field == 'Responsible_Party__c')
                caseRec.Resp_Party_Email__c = mapEmailPop.get(contId);
        }

        if(lstEmailClear.contains(contId))
        {
            if(field == 'Applicant_Type__c')
                caseRec.Applicant_Email__c = '';
            else if(field == 'Responsible_Party__c')
                caseRec.Resp_Party_Email__c = '';
        }

        return caseRec;
    }
}