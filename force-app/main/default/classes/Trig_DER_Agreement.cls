/*
	@author  : pavan.dave@ausnetservices.com.au
	@created : 03 Oct 2019
	@Description : Class for DER Agreement Triggers
	-----------------------------------------------------------------------------------------
	Change log
	-----------------------------------------------------------------------------------------
	Date                  Name                           Description
	-----------------------------------------------------------------------------------------
	15 oct 2019             btiwar47@in.ibm.com       Added method SetCaseStatusToInstallationPending
	15 oct 2019             btiwar47@in.ibm.com       Added method SetCaseStatusToCancelled 
	28 oct 2019             Palash awasthi            Added method SetRecordMSOVersion        
	-----------------------------------------------------------------------------------------
*/
public with sharing class Trig_DER_Agreement implements UtilTrigHandle
{
	// *********************************************************************
	// *** Disable logic

	public static Boolean TrigDisabled = false;
	public static String AGGR_STATUS_OFFERACCEPTED = 'Offer Accepted';
	public static String AGGR_STATUS_OFFERDECLINED = 'Offer Declined';
	public static String CASE_STATUS_INSTALLATION = 'Installation Pending';
	public static String CASE_STATUS_CANCELLED = 'Cancelled';
	public static String CASE_REASON_APPLICANT_DECLINED = 'Applicant Declined';

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().DER_Agreement_Trigger_Disabled__c)
			return true;
		else
		 	return TrigDisabled;
	}

	// *********************************************************************
	// *** Trigger contexts

	public void AfterInsert(Map<Id, SObject> newSObjs)
	{
		SetContractStatus(newSObjs, null);
		SetOfferAcceptDate(newSObjs, null);
		SetOfferExpDate(newSObjs, null);
		SetCaseStatusToInstallationPending(newSObjs, null);
		SetCaseStatusToCancelled(newSObjs, null);
        SetContractActiveDate(newSObjs, null);
        SetOfferVersion(newSObjs, null);
		SetOfferMadeDate(newSObjs, null);
	}

	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		SetContractStatus(newSObjs,oldSObjs);
		SetOfferAcceptDate(newSObjs, oldSObjs);
		SetOfferExpDate(newSObjs, oldSObjs);
		SetCaseStatusToInstallationPending(newSObjs, oldSObjs);
		SetCaseStatusToCancelled(newSObjs, oldSObjs);
        SetContractActiveDate(newSObjs, oldSObjs);
        SetOfferVersion(newSObjs, oldSObjs);
		SetOfferMadeDate(newSObjs, oldSObjs);
		SetCommisioningDate(newSObjs, oldSObjs);
	}

	// if context is not implemented, condense into one-liners
	public void BeforeInsert(List<SObject> newSObjs) {
		SetRecordMSOVersion(newSObjs,null);
	}
	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) {
		SetRecordMSOVersion(newSObjs.values(), oldSObjs.values());
	}
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> oldSObjs) {}

	// *********************************************************************
	// *** Trigger methods

	// ---------------------------------------------------//
	// ------ Set Contract Status on Case  ---------------//
	// ---------------------------------------------------//
	private static void SetContractStatus(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
	{
		System.debug('*** Trig_DER_Agreement.SetContractStatus()');
		Map<Id, String> validAppIdStatus_Pop = new Map<Id, String>();
		List<Id> validDERApp_Clear = new List<Id>();

		switch on Trigger.operationType
		{
			when AFTER_INSERT
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;

					if (String.isNotBlank(newDERAgmt.Status__c) && newDERAgmt.DER_Application__c != null)
					{
						validAppIdStatus_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Status__c);
					}
				}
			}

			when AFTER_UPDATE
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;
					DER_Agreement__c oldDERAgmt = (DER_Agreement__c)oldSObj.get(newDERAgmt.Id);

					// Criterias for populating the Contract Status field on Case
					if (isPopulated('Status__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null)
					{
						validAppIdStatus_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Status__c);
					}
					else if (isCleared('Status__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null)
					{
						validDERApp_Clear.add(newDERAgmt.DER_Application__c);
					}

					if (isPopulated('DER_Application__c', newDERAgmt, oldDERAgmt)
						&& newDERAgmt.Status__c != null
						&& newDERAgmt.DER_Application__c != null)
					{
						validAppIdStatus_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Status__c);
					}
					else if (isCleared('DER_Application__c', newDERAgmt, oldDERAgmt)
						&& oldDERAgmt.Status__c != null)
					{
						validDERApp_Clear.add(oldDERAgmt.DER_Application__c);
					}
				}
			}
		}

		Case caseRec;
		List<Case> lstCaseUpd;

		if (!validAppIdStatus_Pop.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Contract_Status__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validAppIdStatus_Pop.keySet()]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Contract_Status__c = (validAppIdStatus_Pop.get(item.Id));
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}

		if (!validDERApp_Clear.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Contract_Status__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validDERApp_Clear]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Contract_Status__c = '';
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}
	}

	// ---------------------------------------------------//
	// ------ Set Offer Accept Date on Case  -------------//
	// ---------------------------------------------------//
	private static void SetOfferAcceptDate(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
	{
		System.debug('*** Trig_DER_Agreement.SetOfferAcceptDate()');
		Map<Id, Date> validAppIdDate_Pop = new Map<Id, Date>();
		List<Id> validDERApp_Clear = new List<Id>();

		switch on Trigger.operationType
		{
			when AFTER_INSERT
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;

					if (newDERAgmt.Offer_Accepted_Date__c != null && newDERAgmt.DER_Application__c != null)
					{
						validAppIdDate_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Offer_Accepted_Date__c);
					}
				}
			}

			when AFTER_UPDATE
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;
					DER_Agreement__c oldDERAgmt = (DER_Agreement__c)oldSObj.get(newDERAgmt.Id);

					// Criterias for populating the Offer Accepted Date field on Case
					if (isPopulated('Offer_Accepted_Date__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null)
					{
						validAppIdDate_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Offer_Accepted_Date__c);
					}
					else if (isCleared('Offer_Accepted_Date__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null)
					{
						validDERApp_Clear.add(newDERAgmt.DER_Application__c);
					}

					if (isPopulated('DER_Application__c', newDERAgmt, oldDERAgmt) && newDERAgmt.Offer_Accepted_Date__c != null)
					{
						validAppIdDate_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Offer_Accepted_Date__c);
					}
					else if (isCleared('DER_Application__c', newDERAgmt, oldDERAgmt) && oldDERAgmt.Offer_Accepted_Date__c != null)
					{
						validDERApp_Clear.add(oldDERAgmt.DER_Application__c);
					}
				}
			}
		}

		Case caseRec;
		List<Case> lstCaseUpd;

		if (!validAppIdDate_Pop.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Offer_Accepted_Date__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validAppIdDate_Pop.keySet()]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Offer_Accepted_Date__c = (validAppIdDate_Pop.get(item.Id));
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}

		if (!validDERApp_Clear.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Offer_Accepted_Date__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validDERApp_Clear]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Offer_Accepted_Date__c = null;
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}
	}

	// ---------------------------------------------------//
	// ------ Set Offer Expiration Date on Case  -------------//
	// ---------------------------------------------------//
	private static void SetOfferExpDate(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
	{
		System.debug('*** Trig_DER_Agreement.SetOfferExpDate()');
		Map<Id, Date> validAppIdDate_Pop = new Map<Id, Date>();
		List<Id> validDERApp_Clear = new List<Id>();

		switch on Trigger.operationType
		{
			when AFTER_INSERT
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;

					if (newDERAgmt.Offer_Expiration_Date__c != null && newDERAgmt.DER_Application__c != null)
					{
						validAppIdDate_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Offer_Expiration_Date__c);
					}
				}
			}

			when AFTER_UPDATE
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;
					DER_Agreement__c oldDERAgmt = (DER_Agreement__c)oldSObj.get(newDERAgmt.Id);

					// Criterias for populating the Offer Expiration Date field on Case
					if (isPopulated('Offer_Expiration_Date__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null)
					{
						validAppIdDate_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Offer_Expiration_Date__c);
					}
					else if (isCleared('Offer_Expiration_Date__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null)
					{
						validDERApp_Clear.add(newDERAgmt.DER_Application__c);
					}

					if (isPopulated('DER_Application__c', newDERAgmt, oldDERAgmt) && newDERAgmt.Offer_Expiration_Date__c != null)
					{
						validAppIdDate_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Offer_Expiration_Date__c);
					}
					else if (isCleared('DER_Application__c', newDERAgmt, oldDERAgmt) && oldDERAgmt.Offer_Expiration_Date__c != null)
					{
						validDERApp_Clear.add(oldDERAgmt.DER_Application__c);
					}
				}
			}
		}

		Case caseRec;
		List<Case> lstCaseUpd;

		if (!validAppIdDate_Pop.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Offer_Expiration_Date__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validAppIdDate_Pop.keySet()]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Offer_Expiration_Date__c = (validAppIdDate_Pop.get(item.Id));
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}

		if (!validDERApp_Clear.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Offer_Expiration_Date__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validDERApp_Clear]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Offer_Expiration_Date__c = null;
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}
	}
	// ---------------------------------------------------//
    //When Agreement status changes to Offer accepted, update case status to Installation Pending //
    private static void SetCaseStatusToInstallationPending(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        System.debug('*** Trig_DER_Agreement.SetCaseStatusToInstallationPending()');
        Map<Id, String> validAppIdStatus_Pop = new Map<Id, String>();
        List<Id> validDERApp_Clear = new List<Id>();
        DER_Agreement__c newDERAgmt = new DER_Agreement__c();
        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for (SObject sObjItem: newSObj.values())
                {
                    newDERAgmt = (DER_Agreement__c)sObjItem;
                    
                    if (String.isNotBlank(newDERAgmt.Status__c) && newDERAgmt.DER_Application__c != null && newDERAgmt.Status__c==AGGR_STATUS_OFFERACCEPTED)
                    {
                        validAppIdStatus_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Status__c);
                    }
                }
            }
            
            when AFTER_UPDATE
            {
                for (SObject sObjItem: newSObj.values())
                {
                    newDERAgmt = (DER_Agreement__c)sObjItem;
                    DER_Agreement__c oldDERAgmt = (DER_Agreement__c)oldSObj.get(newDERAgmt.Id);
                    
                    // Criterias for populating the Contract Status field on Case
                    if (isPopulated('Status__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null && newDERAgmt.Status__c==AGGR_STATUS_OFFERACCEPTED)
                    {
                        validAppIdStatus_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Status__c);
                    }
                    else if (isCleared('Status__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null && newDERAgmt.Status__c==AGGR_STATUS_OFFERACCEPTED)
                    {
                        validDERApp_Clear.add(newDERAgmt.DER_Application__c);
                    }
                    
                    if (isPopulated('DER_Application__c', newDERAgmt, oldDERAgmt)
                        && newDERAgmt.Status__c ==AGGR_STATUS_OFFERACCEPTED
                        && newDERAgmt.DER_Application__c != null)
                    {
                        validAppIdStatus_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Status__c);
                    }
                    else if (isCleared('DER_Application__c', newDERAgmt, oldDERAgmt)
                             && oldDERAgmt.Status__c ==AGGR_STATUS_OFFERACCEPTED)
                    {
                        validDERApp_Clear.add(oldDERAgmt.DER_Application__c);
                    }
                }
            }
        }
        
        Case caseRec;
        List<Case> lstCaseUpd;
        
        if (!validAppIdStatus_Pop.isEmpty())
        {
            List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id,Post_Installation_Expiry_Date__c, Status FROM Cases__r)
                                                                               FROM DER_Application__c
                                                                               WHERE Id IN: validAppIdStatus_Pop.keySet()]);
            lstCaseUpd = new List<Case>();
            for (DER_Application__c item: lstDERApp)
            {
                if (!item.Cases__r.isEmpty())
                {
                    caseRec = item.Cases__r[0];
                    caseRec.Status = CASE_STATUS_INSTALLATION;
                    caseRec.Post_Installation_Expiry_Date__c = AddBusinessDays(newDERAgmt.Offer_Accepted_Date__c,65);
                    lstCaseUpd.add(caseRec);
                }
            }
            
            if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
        }
        
        if (!validDERApp_Clear.isEmpty())
        {
            List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Status FROM Cases__r)
                                                                               FROM DER_Application__c
                                                                               WHERE Id IN: validDERApp_Clear]);
            lstCaseUpd = new List<Case>();
            for (DER_Application__c item: lstDERApp)
            {
                if (!item.Cases__r.isEmpty())
                {
                    caseRec = item.Cases__r[0];
                    caseRec.Status = null;
                    caseRec.Post_Installation_Expiry_Date__c = null;
                    lstCaseUpd.add(caseRec);
                }
            }
            
            if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
        }
    }
    
    public static Boolean IsWeekendDay(Date dateParam)
   {
      boolean result     = false;
      //Recover the day of the week
      Date startOfWeek   = dateParam.toStartOfWeek();
      Integer dayOfWeek  = dateParam.day() - startOfWeek.day();
      system.debug('dayOfWeek = '+dayOfWeek);
      // if start of week is the month before the month we are now  
	  if (dayOfWeek < 0){
           Integer monthDays = date.daysInMonth(startOfWeek.year(), startOfWeek.month());
           dayOfWeek = monthDays + dayOfWeek;          
       }       
      //  Make sure to check the user locale
      if (UserInfo.getLocale() == 'en_US') {
           result = dayOfWeek == 0 || dayOfWeek == 6 ? true : false; // Sunday & Saturday (US)
      } else {
       
           result = dayOfWeek == 5 || dayOfWeek == 6 ? true : false; // Sunday & Saturday (EU)
      }
      return result;
   } 
   
   
   public static Date AddBusinessDays(Date StartDate, integer BusinessDaysToAdd )
   {
      //Add or decrease in BusinessDaysToAdd days 
      Date finalDate = StartDate;
      integer direction = BusinessDaysToAdd < 0 ? -1 : 1;
       while(BusinessDaysToAdd != 0)
       {
           finalDate = finalDate.AddDays(direction);
           if (!isWeekendDay(finalDate))
           {
               BusinessDaysToAdd -= direction;
               
           }
       }

       return finalDate;
   }
    
    // ---------------------------------------------------//
	//When Agreement status changes to Offer Declined, update case status to Cancelled and reason to applicant declined //
	private static void SetCaseStatusToCancelled(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
	{
		System.debug('*** Trig_DER_Agreement.SetCaseStatusToCancelled()');
		Map<Id, String> validAppIdStatus_Pop = new Map<Id, String>();
		List<Id> validDERApp_Clear = new List<Id>();

		switch on Trigger.operationType
		{
			when AFTER_INSERT
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;

					if (String.isNotBlank(newDERAgmt.Status__c) && newDERAgmt.DER_Application__c != null && newDERAgmt.Status__c==AGGR_STATUS_OFFERDECLINED)
					{
						validAppIdStatus_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Status__c);
					}
				}
			}

			when AFTER_UPDATE
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;
					DER_Agreement__c oldDERAgmt = (DER_Agreement__c)oldSObj.get(newDERAgmt.Id);

					// Criterias for populating the Contract Status field on Case
					if (isPopulated('Status__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null && newDERAgmt.Status__c==AGGR_STATUS_OFFERDECLINED)
					{
						validAppIdStatus_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Status__c);
					}
					else if (isCleared('Status__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null && newDERAgmt.Status__c==AGGR_STATUS_OFFERDECLINED)
					{
						validDERApp_Clear.add(newDERAgmt.DER_Application__c);
					}

					if (isPopulated('DER_Application__c', newDERAgmt, oldDERAgmt)
						&& newDERAgmt.Status__c ==AGGR_STATUS_OFFERDECLINED
						&& newDERAgmt.DER_Application__c != null)
					{
						validAppIdStatus_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Status__c);
					}
					else if (isCleared('DER_Application__c', newDERAgmt, oldDERAgmt)
						&& oldDERAgmt.Status__c ==AGGR_STATUS_OFFERDECLINED)
					{
						validDERApp_Clear.add(oldDERAgmt.DER_Application__c);
					}
				}
			}
		}

		Case caseRec;
		List<Case> lstCaseUpd;

		if (!validAppIdStatus_Pop.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Status, Cancelled_Reason__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validAppIdStatus_Pop.keySet()]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Status = CASE_STATUS_CANCELLED;
                    caseRec.Cancelled_Reason__c = CASE_REASON_APPLICANT_DECLINED;
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}

		if (!validDERApp_Clear.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Status, Cancelled_Reason__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validDERApp_Clear]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Status = null;
                    caseRec.Cancelled_Reason__c = '';
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}
	}

	// --------------------------------------------------------------//
    //------------- Set version on DER_Agreement Record -------------//
    // --------------------------------------------------------------//
    private static void SetRecordMSOVersion(List<SObject> newSObj, List<SObject> oldSObj){
        System.debug('*****Inside Before Insert*******');
        Date querydate;
        switch on Trigger.operationType
        {
            when BEFORE_INSERT
            {   System.debug('Inside before Insert');

			List<DER_Agreement_Version__c> derAgreementVersion = [SELECT Version_String__c, Offer_Type__c, Effective_Date__c, Expiration_Date__c
                                                                       FROM DER_Agreement_Version__c WHERE Offer_Type__c !=: null
                                                                       AND Effective_Date__c !=:null
                                                                       AND Version_String__c != null];
             for(SObject sObjItem: newSObj){
                 DER_Agreement__c newDERAgreement = (DER_Agreement__c)sObjItem;
                 if(newDERAgreement.Offer_Version__c == null && newDERAgreement.Offer_Type__c != null && 
                    (newDERAgreement.Offer_Accepted_Date__c != null || newDERAgreement.Offer_Made_Date__c != null)){
                        
                        if(newDERAgreement.Offer_Made_Date__c != null){
                            querydate = newDERAgreement.Offer_Made_Date__c;
                        }
                        else if(newDERAgreement.Offer_Accepted_Date__c != null){
                            querydate = newDERAgreement.Offer_Accepted_Date__c;
                        }
                    }
                 System.debug('Query Date is-----'+querydate);
                 for(DER_Agreement_Version__c derVersion : derAgreementVersion){

                      if(derVersion.Offer_Type__c ==  newDERAgreement.Offer_Type__c &&
                         derVersion.Effective_Date__c <= querydate &&
                         (derVersion.Expiration_Date__c >= querydate || derVersion.Expiration_Date__c == null)){
                         newDERAgreement.Offer_Version__c = derVersion.Version_String__c;
                         break;
                        } 
                    }
                 
                 
             }
            }
            
            when BEFORE_UPDATE
            {   System.debug('Inside before Update');
			 List<DER_Agreement_Version__c> derAgreementVersion = [SELECT Version_String__c, Offer_Type__c, Effective_Date__c, Expiration_Date__c
                                                                       FROM DER_Agreement_Version__c WHERE Offer_Type__c !=: null
                                                                       AND Effective_Date__c !=:null
                                                                       AND Version_String__c != null];
             Integer i = 0;
             for(SObject sObjItem: newSObj){
				 Integer flag = 0;
                 DER_Agreement__c newDERAgreement = (DER_Agreement__c)sObjItem;
                 DER_Agreement__c oldDERAgreement = (DER_Agreement__c)oldSObj[i++];
                 
                 if(isPopulated('Offer_Type__c', newDERAgreement, oldDERAgreement)||
                    isPopulated('Offer_Accepted_Date__c', newDERAgreement, oldDERAgreement)||
                    isPopulated('Offer_Made_Date__c', newDERAgreement, oldDERAgreement)){
                        
                        if(isCleared('Offer_Type__c', newDERAgreement, oldDERAgreement)){
                            newDERAgreement.Offer_Version__c = null;
                        }
                        else{
                            if(newDERAgreement.Offer_Made_Date__c != null){
                                querydate = newDERAgreement.Offer_Made_Date__c;
                            }
                            else if(newDERAgreement.Offer_Accepted_Date__c != null){
                                querydate = newDERAgreement.Offer_Accepted_Date__c;
                            }
                            System.debug('Query Date is-----'+querydate);
                            for(DER_Agreement_Version__c derVersion : derAgreementVersion){

                               if(derVersion.Offer_Type__c ==  newDERAgreement.Offer_Type__c &&
                                  derVersion.Effective_Date__c <= querydate &&
                                  (derVersion.Expiration_Date__c >= querydate || derVersion.Expiration_Date__c == null)){
                                   newDERAgreement.Offer_Version__c = derVersion.Version_String__c;
								   flag = 1;
                                   break;
                               } 
                            }
							if(flag == 0){
								newDERAgreement.Offer_Version__c = null;
							}
                        }
                        
                    }
                 
                 else if(isCleared('Offer_Type__c', newDERAgreement, oldDERAgreement)){
                     System.debug('Offer type is empty');
                     newDERAgreement.Offer_Version__c = null;
                 }
              }
            }
        }
    }

	// --------------------------------------------------------------//
	//------- DER_Agreement__c Trigger utility methods --------------//
	// --------------------------------------------------------------//

	private static Boolean isCleared(String f, DER_Agreement__c newDERAgmt, DER_Agreement__c oldDERAgmt)
	{
		Boolean isFieldCleared = false;
		if(newDERAgmt.get(f) == null)
			isFieldCleared = newDERAgmt.get(f) != oldDERAgmt.get(f);
		else if(newDERAgmt.get(f) instanceof Date)
			isFieldCleared = newDERAgmt.get(f) == null && ((Date)newDERAgmt.get(f)) != ((Date)oldDERAgmt.get(f));
		else
			isFieldCleared = String.isBlank((String)newDERAgmt.get(f)) && ((String)newDERAgmt.get(f)) != ((String)oldDERAgmt.get(f));
		return isFieldCleared;
	}

	private static Boolean isPopulated(String f, DER_Agreement__c newDERAgmt, DER_Agreement__c oldDERAgmt)
	{
		Boolean isFieldPopulated = false;
		if(newDERAgmt.get(f) == null)
			isFieldPopulated = false;
		else if(newDERAgmt.get(f) instanceof Date)
			isFieldPopulated = newDERAgmt.get(f) != null && ((Date)newDERAgmt.get(f)) != ((Date)oldDERAgmt.get(f));
		else
			isFieldPopulated = String.isNotBlank((String)newDERAgmt.get(f)) && ((String)newDERAgmt.get(f)) != ((String)oldDERAgmt.get(f));
		return isFieldPopulated;
	}
    
    // ---------------------------------------------------//
	// ------ Set Contract Active Date on Case  ---------------//
	// ---------------------------------------------------//
	private static void SetContractActiveDate(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
	{
		System.debug('*** Trig_DER_Agreement.SetContractActiveDate()');
		Map<Id, Date> validAppIdActiveDate_Pop = new Map<Id, Date>();
		List<Id> validDERApp_Clear = new List<Id>();

		switch on Trigger.operationType
		{
			when AFTER_INSERT
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;

					if (newDERAgmt.Contract_Active_Date__c != null && newDERAgmt.DER_Application__c != null)
					{
						validAppIdActiveDate_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Contract_Active_Date__c);
					}
				}
			}

			when AFTER_UPDATE
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;
					DER_Agreement__c oldDERAgmt = (DER_Agreement__c)oldSObj.get(newDERAgmt.Id);

					// Criterias for populating the Contract Status field on Case
					if (isPopulated('Contract_Active_Date__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null)
					{
						validAppIdActiveDate_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Contract_Active_Date__c);
					}
					else if (isCleared('Contract_Active_Date__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null)
					{
						validDERApp_Clear.add(newDERAgmt.DER_Application__c);
					}

					if (isPopulated('DER_Application__c', newDERAgmt, oldDERAgmt)
						&& newDERAgmt.Contract_Active_Date__c != null
						&& newDERAgmt.DER_Application__c != null)
					{
						validAppIdActiveDate_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Contract_Active_Date__c);
					}
					else if (isCleared('DER_Application__c', newDERAgmt, oldDERAgmt)
						&& oldDERAgmt.Contract_Active_Date__c != null)
					{
						validDERApp_Clear.add(oldDERAgmt.DER_Application__c);
					}
				}
			}
		}

		Case caseRec;
		List<Case> lstCaseUpd;

		if (!validAppIdActiveDate_Pop.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Contract_Active_Date__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validAppIdActiveDate_Pop.keySet()]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Contract_Active_Date__c = (validAppIdActiveDate_Pop.get(item.Id));
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}

		if (!validDERApp_Clear.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Contract_Active_Date__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validDERApp_Clear]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Contract_Active_Date__c = null;
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}
	}
    
    // ---------------------------------------------------//
	// ------ Set Offer Version on Case  -------------//
	// ---------------------------------------------------//
	private static void SetOfferVersion(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
	{
		System.debug('*** Trig_DER_Agreement.SetOfferVersion()');
		Map<Id, String> validAppIdVersion_Pop = new Map<Id, String>();
		List<Id> validDERApp_Clear = new List<Id>();

		switch on Trigger.operationType
		{
			when AFTER_INSERT
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;

					if (newDERAgmt.Offer_Version__c != null && newDERAgmt.DER_Application__c != null)
					{
						validAppIdVersion_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Offer_Version__c);
					}
				}
			}

			when AFTER_UPDATE
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;
					DER_Agreement__c oldDERAgmt = (DER_Agreement__c)oldSObj.get(newDERAgmt.Id);


					if (isPopulated('Offer_Version__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null)
					{
						validAppIdVersion_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Offer_Version__c);
					}
					else if (isCleared('Offer_Version__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null)
					{
						validDERApp_Clear.add(newDERAgmt.DER_Application__c);
					}

					if (isPopulated('DER_Application__c', newDERAgmt, oldDERAgmt) && newDERAgmt.Offer_Version__c != null)
					{
						validAppIdVersion_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Offer_Version__c);
					}
					else if (isCleared('DER_Application__c', newDERAgmt, oldDERAgmt) && oldDERAgmt.Offer_Version__c != null)
					{
						validDERApp_Clear.add(oldDERAgmt.DER_Application__c);
					}
				}
			}
		}

		Case caseRec;
		List<Case> lstCaseUpd;

		if (!validAppIdVersion_Pop.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Offer_Version__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validAppIdVersion_Pop.keySet()]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Offer_Version__c = (validAppIdVersion_Pop.get(item.Id));
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}

		if (!validDERApp_Clear.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Offer_Version__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validDERApp_Clear]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Offer_Version__c = '';
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}
	}

	// ---------------------------------------------------//
	// ------ Set Offer Made Date on Case  -------------//
	// ---------------------------------------------------//
	private static void SetOfferMadeDate(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
	{
		System.debug('*** Trig_DER_Agreement.SetOfferVersion()');
		Map<Id, Date> validAppOfferMadeDate = new Map<Id, Date>();
		List<Id> validDERApp_Clear = new List<Id>();

		switch on Trigger.operationType
		{
			when AFTER_INSERT
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;

					if (newDERAgmt.Offer_Made_Date__c != null && newDERAgmt.DER_Application__c != null)
					{
						validAppOfferMadeDate.put(newDERAgmt.DER_Application__c, newDERAgmt.Offer_Made_Date__c);
					}
				}
			}

			when AFTER_UPDATE
			{
				for (SObject sObjItem: newSObj.values())
				{
					DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;
					DER_Agreement__c oldDERAgmt = (DER_Agreement__c)oldSObj.get(newDERAgmt.Id);


					if (isPopulated('Offer_Made_Date__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null)
					{
						validAppOfferMadeDate.put(newDERAgmt.DER_Application__c, newDERAgmt.Offer_Made_Date__c);
					}
					else if (isCleared('Offer_Made_Date__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null)
					{
						validDERApp_Clear.add(newDERAgmt.DER_Application__c);
					}

					if (isPopulated('DER_Application__c', newDERAgmt, oldDERAgmt) && newDERAgmt.Offer_Made_Date__c != null)
					{
						validAppOfferMadeDate.put(newDERAgmt.DER_Application__c, newDERAgmt.Offer_Made_Date__c);
					}
					else if (isCleared('DER_Application__c', newDERAgmt, oldDERAgmt) && oldDERAgmt.Offer_Made_Date__c != null)
					{
						validDERApp_Clear.add(oldDERAgmt.DER_Application__c);
					}
				}
			}
		}

		Case caseRec;
		List<Case> lstCaseUpd;

		if (!validAppOfferMadeDate.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Offer_Made_Date__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validAppOfferMadeDate.keySet()]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Offer_Made_Date__c = (validAppOfferMadeDate.get(item.Id));
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}

		if (!validDERApp_Clear.isEmpty())
		{
			List<DER_Application__c> lstDERApp = new List<DER_Application__c>([SELECT Id, (SELECT Id, Offer_Made_Date__c FROM Cases__r)
																				FROM DER_Application__c
																				WHERE Id IN: validDERApp_Clear]);
			lstCaseUpd = new List<Case>();
			for (DER_Application__c item: lstDERApp)
			{
				if (!item.Cases__r.isEmpty())
				{
					caseRec = item.Cases__r[0];
					caseRec.Offer_Made_Date__c = null;
					lstCaseUpd.add(caseRec);
				}
			}

			if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
		}
	}

	private static void SetCommisioningDate(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
	{
		Map<Id, Date> validAppIdStatus_Pop = new Map<Id, Date>();
		List<Device__c> devListToUpdate = new List<Device__c>();
		for (SObject sObjItem: newSObj.values())
		{
			DER_Agreement__c newDERAgmt = (DER_Agreement__c)sObjItem;
			DER_Agreement__c oldDERAgmt = (DER_Agreement__c)oldSObj.get(newDERAgmt.Id);

			// Criterias for populating the Contract Status field on Case
			if (isPopulated('Status__c', newDERAgmt, oldDERAgmt) && newDERAgmt.DER_Application__c != null && newDERAgmt.Status__c== 'Contract Active' && newDERAgmt.Contract_Active_Date__c != null) 
			{
				validAppIdStatus_Pop.put(newDERAgmt.DER_Application__c, newDERAgmt.Contract_Active_Date__c);
			}
		}

		if (!validAppIdStatus_Pop.isEmpty())
		{
			List<Device__c> lstDevices = new List<Device__c>([SELECT Id, Commissioning_Date__c,DER_Application__c 
																				FROM Device__c
																				WHERE DER_Application__c IN: validAppIdStatus_Pop.keySet() and Installed__c = true]);
			for(Device__c dev : lstDevices)
			{
				dev.Commissioning_Date__c = validAppIdStatus_Pop.get(dev.DER_Application__c);
				devListToUpdate.add(dev);
			}
		}
		if(!devListToUpdate.isEmpty())
		{
           update devListToUpdate;
		}

	}


}