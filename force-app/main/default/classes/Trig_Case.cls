/*
@author  : vaughan.crole@ausnetservices.com.au
@created : 17 Sep 2019
@Description : Class for Case Triggers
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           		Description
-----------------------------------------------------------------------------------------
24-SEP-19           pavan.dave@ausnetservices.com.au   		Added method SetApplicantDetails, SetRespPartyDetails
16-MAR-22	        syed.muhammadali@ausnetservices.com.au  Record type seggregation changes for Org Merge. BeforeInsert, AfterInsert, BeforeUpdate, After Update changed.
-----------------------------------------------------------------------------------------
*/
public without sharing class Trig_Case implements UtilTrigHandle
{
    public static String RESP_PARTY_INSTALLER = 'Installer';
    public static String RESP_PARTY_CUSTOMER = 'Customer';
    public static String RESP_PARTY_REP = 'Representative';
    public static String APPLICANT_INSTALLER = 'Installer';
    public static String APPLICANT_CUSTOMER = 'Customer';
    public static String APPLICANT_REP = 'Representative';
    public static String CASE_AUTO_RTYPE = 'DER Application - Auto';
    public static String CASE_MANUAL_RTYPE = 'DER Application - Manual';
    public static String CASE_STATUS_COMPLETE = 'Complete';

    @TestVisible private static List<NmiDataSets__x> mockedExtNMI = new List<NmiDataSets__x>();
    @TestVisible private static List<MeterDataSets__x> mockedExtMtr = new List<MeterDataSets__x>();

    @TestVisible private static Map<String,String> SyncCaseFields = new Map<String,String>
    {
        'Status'                      => 'Case_Status__c',
        'Id'                          => 'Case_Id__c',
        'CaseNumber'                  => 'Case_Number__c',
        'Type'                        => 'Case_Type__c',
        'DER_Application_Scenario__c' => 'DER_Scenario__c',
        'Application_Number__c'       => 'Case_Application_Number__c',
        'Origin'                      => 'Case_Origin__c'
    };



    // *********************************************************************
    // *** Disable logic
    public static Boolean TrigDisabled = false;

    public Boolean IsDisabled()
    {
        if (TrigSettings__c.getInstance().Case_Trigger_Disabled__c)
            return true;
        else
            return TrigDisabled;
    }

    // *********************************************************************
    // *** Trigger contexts
    @testvisible private static Set<String> recordTypesDER = new Set<String>{'DER_App_Auto', 'DER_App_Manual'};
    @testvisible private static Set<String> recordTypesMVP = new Set<String>{'REMI', 'REMI_Bank_Details','REMI_Question','Storm_Relief','dcp_Claim','dcp_Complaint','dcp_EWOV','dcp_General_Enquiry','dcp_Insurance_Letter'};
    public void BeforeInsert(List<SObject> newSObjs){ System.debug('*** Trig_Case. BeforeInsert');
        List<Case> cases = new List<Case>(); List<Case> casesDER = new List<Case>(); List<Case> casesMVP = new List<Case>(); 
		cases=(List<Case>)newSObjs;
        for (Case c: cases){
            // If no record type, skip record.
            if (c.RecordTypeId == null) {
                System.debug('**NULL record type encountered.');
            }
            // If record type not listed in recordTypesDER or recordTypesMVP, skip record.
            String RTName = UtilDatabase.getRecordTypes().get(c.RecordTypeId);
            if (recordTypesDER.contains(RTName)){
                casesDER.add(c);
            }
            if (recordTypesMVP.contains(RTName)){
                casesMVP.add(c);
            }
        }    
        
        if(casesDER.size()>0){ System.debug('*** Trig_Case. DER - BeforeInsert');
        	UtilFieldCalcs.SetRegionEmailAddress(casesDER);
        	ValidateDERApp_TotalCalc(casesDER);
        }
        
		if(casesMVP.size()>0){ System.debug('*** Trig_Case. DCP - BeforeInsert');
            DCPCaseEWOVHandler caseEwovHandler=new DCPCaseEWOVHandler();
            caseEwovHandler.beforeInsert(casesMVP);            
        }                                             
    }

    public void AfterInsert(Map<Id, SObject> newSObjs)
    {
        List<Case> cases = new List<Case>(); List<Case> casesDER = new List<Case>(); List<Case> casesMVP = new List<Case>(); Map<Id, Case> casesFromIdDER=new Map<Id, Case>();
		cases=(List<Case>)newSObjs.values();
        for (Case c: cases){
            // If no record type, skip record.
            if (c.RecordTypeId == null) {
                System.debug('**NULL record type encountered.');
            }
            // If record type not listed in recordTypesDER or recordTypesMVP, skip record.
            String RTName = UtilDatabase.getRecordTypes().get(c.RecordTypeId);
            if (recordTypesDER.contains(RTName)){
                casesDER.add(c);
                casesFromIdDER.put(c.id, c);
            }
            if (recordTypesMVP.contains(RTName)){
                casesMVP.add(c);
            }
        }    
        
        if(casesDER.size()>0){ System.debug('*** Trig_Case. DER - AfterInsert');        	
            setCaseSubject(casesDER);
        }
        
        if(casesFromIdDER.size()>0){
			getValidCasesForAemo(casesFromIdDER,null);
        	SetRespPartyDetails(casesFromIdDER, null);
        	SetApplicantDetails(casesFromIdDER, null);
        	setCaseFieldsOnDerApp(casesFromIdDER,null);
        	getDerAppIdsForDefaults(casesFromIdDER,null);
        	SetCustomerEmail(casesFromIdDER, null);            
        }
        
		if(casesMVP.size()>0){ System.debug('*** Trig_Case. DCP - AfterInsert');
            DCPCaseEWOVHandler caseEwovHandler=new DCPCaseEWOVHandler();
            caseEwovHandler.afterInsert(casesMVP);            
        }
        
        //old code
        System.debug('*** Trig_Case. After Insert');
        //moved - setCaseSubject((List<Case>)newSObjs.values());
        /*moved
        getValidCasesForAemo(newSObjs,null);
        SetRespPartyDetails(newSObjs, null);
        SetApplicantDetails(newSObjs, null);
        setCaseFieldsOnDerApp(newSObjs,null);
        getDerAppIdsForDefaults(newSObjs,null);
        SetCustomerEmail(newSObjs, null);
		*/
    }

    public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs){
        List<Case> casesNew = new List<Case>(); List<Case> casesDERNew = new List<Case>(); List<Case> casesMVPNew = new List<Case>(); Map<Id, Case> casesFromIdDERNew=new Map<Id, Case>();
        List<Case> casesOld = new List<Case>(); List<Case> casesDEROld = new List<Case>(); List<Case> casesMVPOld = new List<Case>(); Map<Id, Case> casesFromIdDEROld=new Map<Id, Case>();
		casesNew=(List<Case>)newSObjs.values();
                for (Case c: casesNew){
            // If no record type, skip record.
            if (c.RecordTypeId == null) {
                System.debug('**NULL record type encountered.');
            }
            // If record type not listed in recordTypesDER or recordTypesMVP, skip record.
            String RTName = UtilDatabase.getRecordTypes().get(c.RecordTypeId);
            if (recordTypesDER.contains(RTName)){
                casesDERNew.add(c);
                casesFromIdDERNew.put(c.id, c);
            }
            if (recordTypesMVP.contains(RTName)){
                casesMVPNew.add(c);
            }
        }
        casesOld=(List<Case>)oldSObjs.values();
        for (Case c: casesOld){
            // If no record type, skip record.
            if (c.RecordTypeId == null) {
                System.debug('**NULL record type encountered.');
            }
            // If record type not listed in recordTypesDER or recordTypesMVP, skip record.
            String RTName = UtilDatabase.getRecordTypes().get(c.RecordTypeId);
            if (recordTypesDER.contains(RTName)){
                casesDEROld.add(c);
                casesFromIdDEROld.put(c.id, c);
            }
            if (recordTypesMVP.contains(RTName)){
                casesMVPOld.add(c);
            }
        }
        if(casesDERNew.size()>0){      	
           
        }
        if(casesFromIdDERNew.size()>0 && casesFromIdDEROld.size()>0){
            getValidCasesForAemo(casesFromIdDERNew, casesFromIdDEROld);
            setOfferStatusFalse(casesFromIdDERNew, casesFromIdDEROld);
            getDerAppIdsForDefaults(casesFromIdDERNew,casesFromIdDEROld);
            if (!UtilCaseMatching.isRunning_casesMatched){
                setCaseConnectionStatus(casesFromIdDERNew,casesFromIdDEROld);
            }
            setCaseFieldsOnDerApp(casesFromIdDERNew, casesFromIdDEROld);
            ValidateDevices_GenerationTypesAndPhases(casesFromIdDERNew, casesFromIdDEROld);
            upsertAssetRecords(casesFromIdDERNew,casesFromIdDEROld);  
        }
        
        //Old Code
        /*
        getValidCasesForAemo(newSObjs, oldSObjs);
        setOfferStatusFalse(newSObjs, oldSObjs);
        getDerAppIdsForDefaults(newSObjs,oldSObjs);
        if (!UtilCaseMatching.isRunning_casesMatched){
            setCaseConnectionStatus(newSObjs,oldSObjs);
        }
        setCaseFieldsOnDerApp(newSObjs, oldSObjs);
        ValidateDevices_GenerationTypesAndPhases(newSObjs, oldSObjs);
        upsertAssetRecords(newSObjs,oldSObjs);        
		*/
    }

    public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs){
        List<Case> casesNew = new List<Case>(); List<Case> casesDERNew = new List<Case>(); List<Case> casesMVPNew = new List<Case>(); Map<Id, Case> casesFromIdDERNew=new Map<Id, Case>();
        List<Case> casesOld = new List<Case>(); List<Case> casesDEROld = new List<Case>(); List<Case> casesMVPOld = new List<Case>(); Map<Id, Case> casesFromIdDEROld=new Map<Id, Case>();
		casesNew=(List<Case>)newSObjs.values();
        for (Case c: casesNew){
            // If no record type, skip record.
            if (c.RecordTypeId == null) {
                System.debug('**NULL record type encountered.');
            }
            // If record type not listed in recordTypesDER or recordTypesMVP, skip record.
            String RTName = UtilDatabase.getRecordTypes().get(c.RecordTypeId);
            if (recordTypesDER.contains(RTName)){
                casesDERNew.add(c);
                casesFromIdDERNew.put(c.id, c);
            }
            if (recordTypesMVP.contains(RTName)){
                casesMVPNew.add(c);
            }
        }
        casesOld=(List<Case>)oldSObjs.values();
        for (Case c: casesOld){
            // If no record type, skip record.
            if (c.RecordTypeId == null) {
                System.debug('**NULL record type encountered.');
            }
            // If record type not listed in recordTypesDER or recordTypesMVP, skip record.
            String RTName = UtilDatabase.getRecordTypes().get(c.RecordTypeId);
            if (recordTypesDER.contains(RTName)){
                casesDEROld.add(c);
                casesFromIdDEROld.put(c.id, c);
            }
            if (recordTypesMVP.contains(RTName)){
                casesMVPOld.add(c);
            }
        }
        if(casesDERNew.size()>0){      	
            UtilFieldCalcs.SetRegionEmailAddress(casesDERNew);
            setCaseSubject(casesDERNew);
        }
        if(casesFromIdDERNew.size()>0 && casesFromIdDEROld.size()>0){
            getValidCasesForAemo(casesFromIdDERNew,casesFromIdDEROld);
            SetRespPartyDetails(casesFromIdDERNew, casesFromIdDEROld);
        	SetApplicantDetails(casesFromIdDERNew, casesFromIdDEROld);
        	SetCustomerEmail(casesFromIdDERNew, casesFromIdDEROld);
        	SetAemoPublishDate(casesFromIdDERNew, casesFromIdDEROld);
        	SetCaseStatus(casesFromIdDERNew, casesFromIdDEROld);    
        	SetAttachmentId(casesFromIdDERNew, casesFromIdDEROld);
        }
        //Old Code
        /*
        UtilFieldCalcs.SetRegionEmailAddress(newSObjs.values());
        getValidCasesForAemo(newSObjs,oldSObjs);
        setCaseSubject((List<Case>)newSObjs.values());
        SetRespPartyDetails(newSObjs, oldSObjs);
        SetApplicantDetails(newSObjs, oldSObjs);
        SetCustomerEmail(newSObjs, oldSObjs);
        SetAemoPublishDate(newSObjs, oldSObjs);
        SetCaseStatus(newSObjs, oldSObjs);    
        SetAttachmentId(newSObjs, oldSObjs);
		*/
    }

    // if context is not implemented, condense into one-liners
    public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
    public void AfterDelete(Map<Id, SObject> oldSObjs) {}
    public void AfterUndelete(Map<Id, SObject> oldSObjs) {}

    // *********************************************************************
    // *** Trigger methods

    // Calculate totals and update the DER Applicaiton
    private void ValidateDERApp_TotalCalc(List<SObject> newSObjs)
    {
        if (UtilFieldCalcs.isRunning_CalcDERAppPhaseTotals) return;
        System.debug('*** Trig_Case.ValidateDERApp_TotalCalc()');

        Set<Id> validDERAppIds = new Set<Id>();

        switch on Trigger.operationType
        {
            when BEFORE_INSERT
            {
                for (sObject sObjItem: newSObjs)
                {
                    Case newCase = (Case)sObjItem;

                    if (newCase.DER_Application__c != null)
                        validDERAppIds.add(newCase.DER_Application__c);
                }
            }
        }

        //-----------------------------------------------------------//
        //--------- Calculate DER Application Phase Total -----------//
        //-----------------------------------------------------------//

        if (!validDERAppIds.isEmpty())
            UtilFieldCalcs.CalcDERAppPhaseTotals(validDERAppIds, false);
    }




    // Set Case Subject with Application_Number__c value
    @testvisible private static Set<String> CaseSubject_AllowedRTs = new Set<String>{'DER_App_Auto', 'DER_App_Manual'};

    @testvisible private void setCaseSubject(List<Case> newCases)
    {
        System.debug('*** Trig_Case.setCaseSubject()');
        List<SObject> updSObjs = new List<SObject>();

        for (Case newCase: newCases)
        {
            // If no record type, skip record.
            if (newCase.RecordTypeId == null) continue;

            // If record type not listed in AllowedRTs, skip record.
            String RTName = UtilDatabase.getRecordTypes().get(newCase.RecordTypeId);
            if (!CaseSubject_AllowedRTs.contains(RTName)) continue;

            // Only update field if App Num is null
            if (newCase.Application_Number__c != null) continue;

            String AppNumber;

            // Generate random number
            while (AppNumber == null)
            {
                AppNumber = 'CA' + genRandomString(10) + RTName.removeStart('DER_App_').left(1);

                // Check if in database
                for (Case c: [SELECT Id, Application_Number__c FROM Case
                              WHERE Application_Number__c = :AppNumber
                              AND Id != :newCase.Id])
                {
                    // If not Unique, regenerate
                    AppNumber = null;
                }
            }

            // Capture new value
            switch on Trigger.operationType
            {
                when BEFORE_UPDATE
                {
                    newCase.Application_Number__c = AppNumber;
                    newCase.Subject = AppNumber;
                }
                when AFTER_INSERT
                {
                    Case updCase = new Case(Id = newCase.Id);
                    updCase.Application_Number__c = AppNumber;
                    updCase.Subject = AppNumber;
                    updSObjs.add(updCase);
                }
            }
        }

        if (!updSObjs.isEmpty()) update updSObjs;
    }

    private void getValidCasesForAemo(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
    {
        System.debug('Trig_Case - getValidCasesForAemo()');
        System.debug('Trigger: ' + Trigger.operationType);
        System.debug('*** [AemoPublish] runningPublish = ' + UtilAemoPublish.runningPublish);

        Set<Id> validCaseIds = new Set<Id>();
        Set<Id> deleteIssuesCaseIdList = new Set<Id>();

        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for (SObject sObjItem: newSObjs.values())
                {
                    Case newCase = (Case)sObjItem;

                    if (newCase.Submission_Status__c == 'Ready to Submit')
                        validCaseIds.add(newCase.Id);
                }
            }
            when AFTER_UPDATE
            {
                for (sObject sObjItem: newSObjs.values())
                {
                    Case newCase = (Case)sObjItem;
                    Case oldCase = (Case)oldSObjs.get(newCase.Id);

                    if ((newCase.Submission_Status__c == 'Ready To Submit') &&
                        (newCase.Submission_Status__c != oldCase.Submission_Status__c))
                    {
                        validCaseIds.add(newCase.Id);
                    }

                    if ((newCase.Submission_Status__c == 'Sent to EAI') &&
                        (newCase.Submission_Status__c != oldCase.Submission_Status__c))
                    {
                        deleteIssuesCaseIdList.add(newCase.Id);
                    }
                }

            }
            when BEFORE_UPDATE
            {
                for (sObject sObjItem: newSObjs.values())
                {
                    Case newCase = (Case)sObjItem;
                    Case oldCase = (Case)oldSObjs.get(newCase.Id);

                    if (newCase.Submission_Status__c == 'Ready To Submit' &&
                        newCase.Submission_Status__c != oldCase.Submission_Status__c)
                    {
                        // Upon Ready To Submit, reset the Response text field.
                        newCase.Submission_Response__c = null;
                    }
                }
            }
        }

        //-----------------------------------------------------------//
        //--------- Call Future Method For Publishing TO AEMO -------//
        //-----------------------------------------------------------//

        if (!validCaseIds.isEmpty() && !UtilAemoPublish.runningPublish)
        {
            System.debug('*** [AemoPublish] Calling publish....');
            UtilAemoPublish.runningPublish = true;

            // Get AEMO submission batch size
            DER_Submission_Settings__c der_submission_setting = DER_Submission_Settings__c.getInstance();
            Decimal batchSize = 100; // Default is 100
            if (der_submission_setting.Batch_Size__c != null)
                batchSize = der_submission_setting.Batch_Size__c;

            // Send validCaseIds to AEMO in batches of batchSize
            Set<Id> aemoBatchIds = new Set<Id>();

            Iterator<Id> iCaseIds = validCaseIds.iterator();
            while (iCaseIds.hasNext())
            {
                aemoBatchIds.add(iCaseIds.next());

                if (aemoBatchIds.size() == batchSize || !iCaseIds.hasNext())
                {
                    // Run publish, reset batch
                    UtilAemoPublish.publishToAemo(aemoBatchIds);
                    aemoBatchIds.clear();
                }
            }
        }
        else
        {
            System.debug('*** [AemoPublish] Skipping publish.');
        }

        if (!deleteIssuesCaseIdList.isEmpty())
        {
            List<DER_Issue__c> derIssues = new List<DER_Issue__c>();

            for (DER_Issue__c derIssue: [SELECT Id FROM DER_Issue__c WHERE Case__c IN :deleteIssuesCaseIdList])
                derIssues.add(derIssue);

            if (!derIssues.isEmpty()) delete derIssues;
        }
    }

    // ---------------------------------------------------//
    // ------ Set responsible party fields on Case -------//
    // ---------------------------------------------------//
    private static void SetRespPartyDetails(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        System.debug('*** Trig_Case.SetNotificationDetails()');
        Boolean doDML;
        List<Case> validCasesToClear = new List<Case>();

        Map<Id, Id> caseWithInstaller = new Map<Id, Id>();
        Map<Id, Id> caseWithRep = new Map<Id, Id>();
        Map<Id, Id> caseWithCustomer = new Map<Id, Id>();

        // Criterias for populating the notification fields
        Boolean isValidPop_RespParty;
        Boolean isValidPop_Installer;
        Boolean isValidPop_Customer;
        Boolean isValidPop_Rep;
        // Criterias for clearing the notification fields
        Boolean isValidClear_RespParty;
        Boolean isValidClear_Installer;
        Boolean isValidClear_Customer;
        Boolean isValidClear_Rep;

        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for (SObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;

                    isValidPop_RespParty = isValidNotificatoinMapping(newCase, 'Responsible_Party__c');

                    if (isValidPop_RespParty)
                    {
                        if (newCase.Responsible_Party__c == RESP_PARTY_CUSTOMER)
                            caseWithCustomer.put(newCase.Id, newCase.Customer__c);
                        else if (newCase.Responsible_Party__c == RESP_PARTY_INSTALLER)
                            caseWithInstaller.put(newCase.Id, newCase.ContactId);
                        else if (newCase.Responsible_Party__c == RESP_PARTY_REP)
                            caseWithRep.put(newCase.Id, newCase.Representative__c);

                    }
                }
                doDML = true;
            }

            when BEFORE_UPDATE
            {
                for (SObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;
                    Case oldCase = (Case)oldSObj.get(newCase.Id);

                    // Criterias for populating the notification fields
                    isValidPop_RespParty = isPopulated('Responsible_Party__c', newCase, oldCase)
                        && isValidNotificatoinMapping(newCase, 'Responsible_Party__c');

                    isValidPop_Installer = isPopulated('ContactId', newCase, oldCase)
                        && newCase.Responsible_Party__c == RESP_PARTY_INSTALLER;

                    isValidPop_Customer = isPopulated('Customer__c', newCase, oldCase)
                        && newCase.Responsible_Party__c == RESP_PARTY_CUSTOMER;

                    isValidPop_Rep = isPopulated('Representative__c', newCase, oldCase)
                        && newCase.Responsible_Party__c == RESP_PARTY_REP;

                    // Criterias for clearing the notification fields
                    isValidClear_RespParty = isCleared('Responsible_Party__c', newCase, oldCase);

                    isValidClear_Installer = isCleared('ContactId', newCase, oldCase)
                        && newCase.Responsible_Party__c == RESP_PARTY_INSTALLER;

                    isValidClear_Customer = isCleared('Customer__c', newCase, oldCase)
                        && newCase.Responsible_Party__c == RESP_PARTY_CUSTOMER;

                    isValidClear_Rep = isCleared('Representative__c', newCase, oldCase)
                        && newCase.Responsible_Party__c == RESP_PARTY_REP;

                    if (isValidPop_RespParty || isValidPop_Installer || isValidPop_Customer || isValidPop_Rep)
                    {
                        if (newCase.Responsible_Party__c == RESP_PARTY_CUSTOMER)
                            caseWithCustomer.put(newCase.Id, newCase.Customer__c);
                        else if (newCase.Responsible_Party__c == RESP_PARTY_INSTALLER)
                            caseWithInstaller.put(newCase.Id, newCase.ContactId);
                        else if (newCase.Responsible_Party__c == RESP_PARTY_REP)
                            caseWithRep.put(newCase.Id, newCase.Representative__c);
                    }
                    // Criterias for clearing the notification fields
                    else if (isValidClear_RespParty || isValidClear_Installer || isValidClear_Customer || isValidClear_Rep)
                    {
                        validCasesToClear.add(((Case)newSObj.get(newCase.Id)));
                    }
                }
                doDML = false;
            }
        }

        //Populate nofication fields
        if (!caseWithInstaller.isEmpty() || !caseWithRep.isEmpty() || !caseWithCustomer.isEmpty())
            DER_Notification_Util.PopuplateNotificationFields(newSObj, 'Responsible_Party__c',
                                                              caseWithInstaller, caseWithRep, caseWithCustomer, doDML);

        //Clear notification fields
        if (!validCasesToClear.isEmpty())
            DER_Notification_Util.ClearNotificationFields('Responsible_Party__c', validCasesToClear);

    }

    // ---------------------------------------------------//
    //----- Set applicant notificaiton fields on Case ----//
    // ---------------------------------------------------//
    private static void SetApplicantDetails(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        System.debug('*** Trig_Case.SetApplicantDetails()');
        Boolean doDML;
        List<Case> validCasesToClear = new List<Case>();

        Map<Id, Id> caseWithInstaller = new Map<Id, Id>();
        Map<Id, Id> caseWithRep = new Map<Id, Id>();
        Map<Id, Id> caseWithCustomer = new Map<Id, Id>();

        // Criterias for populating the notification fields
        Boolean isValidPop_AppType;
        Boolean isValidPop_Installer;
        Boolean isValidPop_Customer;
        Boolean isValidPop_Rep;
        // Criterias for clearing the notification fields
        Boolean isValidClear_AppType;
        Boolean isValidClear_Installer;
        Boolean isValidClear_Customer;
        Boolean isValidClear_Rep;

        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for (SObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;

                    isValidPop_AppType = isValidNotificatoinMapping(newCase, 'Applicant_Type__c');

                    if (isValidPop_AppType)
                    {
                        if (newCase.Applicant_Type__c == RESP_PARTY_CUSTOMER)
                            caseWithCustomer.put(newCase.Id, newCase.Customer__c);
                        else if (newCase.Applicant_Type__c == RESP_PARTY_INSTALLER)
                            caseWithInstaller.put(newCase.Id, newCase.ContactId);
                        else if (newCase.Applicant_Type__c == RESP_PARTY_REP)
                            caseWithRep.put(newCase.Id, newCase.Representative__c);

                    }
                }
                doDML = true;
            }

            when BEFORE_UPDATE
            {
                for (SObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;
                    Case oldCase = (Case)oldSObj.get(newCase.Id);

                    // Criterias for populating the notification fields
                    isValidPop_AppType = isPopulated('Applicant_Type__c', newCase, oldCase)
                        && isValidNotificatoinMapping(newCase, 'Applicant_Type__c');

                    isValidPop_Installer = isPopulated('ContactId', newCase, oldCase)
                        && newCase.Applicant_Type__c == APPLICANT_INSTALLER;

                    isValidPop_Customer = isPopulated('Customer__c', newCase, oldCase)
                        && newCase.Applicant_Type__c == APPLICANT_CUSTOMER;

                    isValidPop_Rep = isPopulated('Representative__c', newCase, oldCase)
                        && newCase.Applicant_Type__c == APPLICANT_REP;

                    // Criterias for clearing the notification fields
                    isValidClear_AppType = isCleared('Applicant_Type__c', newCase, oldCase);

                    isValidClear_Installer = isCleared('ContactId', newCase, oldCase)
                        && newCase.Applicant_Type__c == APPLICANT_INSTALLER;

                    isValidClear_Customer = isCleared('Customer__c', newCase, oldCase)
                        && newCase.Applicant_Type__c == APPLICANT_CUSTOMER;

                    isValidClear_Rep = isCleared('Representative__c', newCase, oldCase)
                        && newCase.Applicant_Type__c == APPLICANT_REP;

                    // Criterias for populating the notification fields
                    if (isValidPop_AppType || isValidPop_Installer || isValidPop_Customer || isValidPop_Rep)
                    {
                        if (newCase.Applicant_Type__c == APPLICANT_CUSTOMER)
                            caseWithCustomer.put(newCase.Id, newCase.Customer__c);
                        else if (newCase.Applicant_Type__c == APPLICANT_INSTALLER)
                            caseWithInstaller.put(newCase.Id, newCase.ContactId);
                        else if (newCase.Applicant_Type__c == APPLICANT_REP)
                            caseWithRep.put(newCase.Id, newCase.Representative__c);
                    }
                    // Criterias for clearing the notification fields
                    else if (isValidClear_AppType || isValidClear_Installer || isValidClear_Customer || isValidClear_Rep)
                    {
                        validCasesToClear.add(((Case)newSObj.get(newCase.Id)));
                    }
                }
                doDML = false;
            }
        }

        //Populate nofication fields
        if (!caseWithInstaller.isEmpty() || !caseWithRep.isEmpty() || !caseWithCustomer.isEmpty())
            DER_Notification_Util.PopuplateNotificationFields(newSObj, 'Applicant_Type__c',
                                                              caseWithInstaller, caseWithRep, caseWithCustomer, doDML);

        //Clear notification fields
        if (!validCasesToClear.isEmpty())
            DER_Notification_Util.ClearNotificationFields('Applicant_Type__c', validCasesToClear);
    }

    // ---------------------------------------------------//
    //------------ Set customer email on Case ------------//
    // ---------------------------------------------------//
    private static void SetCustomerEmail(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        System.debug('*** Trig_Case.SetCustomerEmail()');
        Map<Id, Case> validCasesToClear = new Map<Id, Case>();
        Map<Id, Case> validCasesToPop = new Map<Id, Case>();
        Boolean doDML = false;

        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for (SObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;

                    if (newCase.Customer__c != null)
                    {
                        validCasesToPop.put(newCase.Id, newCase);
                    }
                }
                doDML = true;
            }

            when BEFORE_UPDATE
            {
                for (SObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;
                    Case oldCase = (Case)oldSObj.get(newCase.Id);

                    if (isPopulated('Customer__c', newCase, oldCase))
                    {
                        validCasesToPop.put(newCase.Id, newCase);
                    }
                    else if (isCleared('Customer__c', newCase, oldCase))
                    {
                        validCasesToClear.put(newCase.Id, newCase);
                    }
                }
            }
        }

        //Populate customer email fields
        if (!validCasesToPop.isEmpty())
            DER_Notification_Util.CustomerEmail_Pop(validCasesToPop, doDML);

        //Clear customer email fields
        if (!validCasesToClear.isEmpty())
            DER_Notification_Util.CustomerEmail_Clear(validCasesToClear);
    }

    //-----------------------------------------------------------------------//
    //---- Update case status and create agreement record -------------------//
    //-----------------------------------------------------------------------//

    private void  setOfferStatusFalse(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
    {
        eSignSettings__c eSignObj = eSignSettings__c.getInstance();
        Map<Id,string> mapOfCaseApp = new  Map<Id,string>();
        Map<Id, Case> validCaseMap = new Map<Id, Case>();
        set<id> setOfCaseIds = new set<id>();

        switch on Trigger.operationType {
            when AFTER_UPDATE {
                for (sObject sObjItem: newSObjs.values())
                {
                    Case newCase = (Case)sObjItem;
                    Case oldCase = (Case)oldSObjs.get(newCase.Id);

                    if (newCase.Send_DER_Offer__c
                    && newCase.Send_DER_Offer__c != oldCase.Send_DER_Offer__c
                    && newCase.DER_Application__c != null)
                    {
                        mapOfCaseApp.put(newCase.Id, newCase.DER_Application__c);
                        validCaseMap.put(newCase.Id, newCase);
                        setOfCaseIds.add(newCase.Id);
                    }
                }
            }
        }       

        if (!mapOfCaseApp.isEmpty())
        {

            //---------Check For agreement record associated with DER_Application -----------//
            set<Id> applicationDoNotHaveValidAgg=new set<Id>();
            Map<Id, DER_Application__c> mapDerApp = new Map<Id, DER_Application__c>([select id, NMI__c,
                                                                                            (select id
                                                                                                from DER_Agreements__r
                                                                                                where status__c ='Offer Expired')
                                                                                    from DER_Application__c
                                                                                    where id IN :mapOfCaseApp.Values()]);

            for (DER_Application__c app:mapDerApp.values()){
                if (app.DER_Agreements__r.size()==0 || app.DER_Agreements__r.size()>0){
                    applicationDoNotHaveValidAgg.add(app.Id);
                }
            }           

            if (!applicationDoNotHaveValidAgg.isEmpty())
            {
                //----Get application object fields to populate during agreemnet creation--------------------//
                Map<Id, DER_Agreement__c> mapCaseIdDERAgmt = new Map<Id, DER_Agreement__c>();
                List<Case> updateCase = New list<Case>();
                DER_Agreement__c agg;
                Case caseItem;
                Case caseFEItem;             
                for (Id item: validCaseMap.keySet())
                {
                    caseItem = validCaseMap.get(item);                    
                    if (applicationDoNotHaveValidAgg.contains(caseItem.DER_Application__c))
                    {
                        agg=new DER_Agreement__c();
                        agg.NMI__c = mapDerApp.get(caseItem.DER_Application__c).NMI__c;
                        agg.Account__c = caseItem.AccountId;
                        agg.DER_Application__c = caseItem.DER_Application__c;
                        agg.Status__c = 'Offer Made';
                        agg.Offer_Made_Date__c = System.TODAY();
                        agg.Offer_Type__c = caseItem.Agreement_Type__c;
                        mapCaseIdDERAgmt.put(item, agg);
                    }
                }
                if (!mapCaseIdDERAgmt.isEmpty())
                    insert mapCaseIdDERAgmt.values();

                Blob key = EncodingUtil.base64Decode(eSignObj.AES_Key__c);
                Blob encrypted;
                String base64EncryptedString;

                for (Id item: validCaseMap.keySet()){
                    /*---FEBAU-242 Update Generate Offer URL for FE-----------*/
                    caseItem = new Case(); 
					caseFEItem = validCaseMap.get(item);                    
                    caseItem.Id = item;
                    caseItem.FE_Is_Flexible_Export_Assessment_Opt_in__c = caseFEItem.FE_Is_Flexible_Export_Assessment_Opt_in__c;                    
                    //----Encoding key to make it valid blob to string--------------------//
                    encrypted = Crypto.encryptWithManagedIV('AES128', key , Blob.valueOf(mapCaseIdDERAgmt.get(item).Id));
                    base64EncryptedString = EncodingUtil.base64Encode(encrypted);
                    base64EncryptedString = base64EncryptedString.replace('+','-').replace('/', '_');                                     
                    if(caseItem.FE_Is_Flexible_Export_Assessment_Opt_in__c){
                        
                       eSignObj.FE_Offer_URL__c += base64EncryptedString;
                       caseItem.DER_Offer_URL__c = eSignObj.FE_Offer_URL__c;
                       
                    }else{
                        eSignObj.DER_Offer_URL__c += base64EncryptedString;
                        caseItem.DER_Offer_URL__c = eSignObj.DER_Offer_URL__c;
                        
                    }
                    caseItem.Send_DER_Offer__c = false;
                    //caseItem.Status = 'Offer Sent';
                    updateCase.add(caseItem);
                }

                if (updateCase.size() > 0)
                    update updateCase;
            }
            else
            {
                System.debug('applicationDoNotHaveValidAgg is empty');
            }
        }
        else
        {
            System.debug('mapOfCaseApp is empty');
        }
    }

    private static void getDerAppIdsForDefaults(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        System.debug('Inside Fxn ');
        Map<Id,String> derAppIdOfferTypeMap = new Map<Id,String>();
        switch on Trigger.operationType {
            when AFTER_INSERT {

                for (SObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;

            String RTName = UtilDatabase.getRecordTypes().get(newCase.RecordTypeId);

                    if (newCase.Agreement_Type__c != null && CaseSubject_AllowedRTs.contains(RTName) && newCase.DER_Application__c != null )
                    {
                        derAppIdOfferTypeMap.put(newCase.DER_Application__c,newCase.Agreement_Type__c);
                    }

                }
            }
            when AFTER_UPDATE {
                 System.debug('Inside Fxn Update Case ');
                for (sObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;
                    Case oldCase = (Case)oldSObj.get(newCase.Id);
                    String RTName = UtilDatabase.getRecordTypes().get(newCase.RecordTypeId);
                    if ((isPopulated('Agreement_Type__c', newCase, oldCase)
                     || isPopulated('RecordTypeId', newCase, oldCase) )
                       && CaseSubject_AllowedRTs.contains(RTName) && newCase.Agreement_Type__c != null && newCase.DER_Application__c != null )
                    {

                       derAppIdOfferTypeMap.put(newCase.DER_Application__c,newCase.Agreement_Type__c);

                    }

                }

            }

        }
        if (derAppIdOfferTypeMap != null && !derAppIdOfferTypeMap.isEmpty())
        {
             System.debug('Inside Fxn ' +derAppIdOfferTypeMap);
              DER_Defaults.applyDefaults(derAppIdOfferTypeMap);
        }
    }

    //-----------------------------------------------------------------------//
    //----Update case status and create agreement record--------------------//
    //-----------------------------------------------------------------------//

    private void  setCaseConnectionStatus(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        List<Id> validCaseIds = new List<Id>();
        List<Id> caseIdNotCompletedList = new List<Id>();
        List<DER_Application__c> appsList = new List<DER_Application__c>();
        map<id,string> mapOfCaseApp = new map<id,string>();
        map<string,string> mapNMIMeter = new map<string,string>();
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();
        switch on Trigger.operationType {
            when AFTER_UPDATE {
                for (sObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;
                    Case oldCase = (Case)oldSObj.get(newCase.Id);
                    if ((newCase.Status == CASE_STATUS_COMPLETE)
                       && isPopulated('Status', newCase, oldCase)
                       && (rt_map.get(newCase.recordTypeID).getName().equalsIgnoreCase(CASE_AUTO_RTYPE)
                       || rt_map.get(newCase.recordTypeID).getName().equalsIgnoreCase(CASE_MANUAL_RTYPE)))
                    {
                        mapOfCaseApp.put(newCase.Id,newCase.DER_Application__c);
                    }
                }
            }
        }

        if (!mapOfCaseApp.isEmpty())
        {
            appsList = [SELECT Id,Meter_Number__c,NMI__c
                        FROM DER_Application__c
                        WHERE Id IN :mapOfCaseApp.Values()
                            AND (
                                (NMI__c <> Null)
                                OR
                                Meter_Number__c <> Null
                                ) ];
            for (DER_Application__c app : appsList){
                if (app.NMI__c != null
                && app.Meter_Number__c != null)
                {
                    mapNMIMeter.put(app.NMI__c, app.Meter_Number__c);
                }

            }
            if (!mapNMIMeter.isEmpty()){
                UtilCaseMatching.updateCaseMatchingNmiMeter(mapNMIMeter);
            }
        }
    }


    //-----------------------------------------------------------------------//
    //----Upsert Asset Record when Case Status is complete--------------------//
    //-----------------------------------------------------------------------//
    private void upsertAssetRecords(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        Set<Id> derAppIdList = new Set<Id>();
        Map<ID,Schema.RecordTypeInfo> rt_Map = Case.sObjectType.getDescribe().getRecordTypeInfosById();

        for (sObject sObjItem: newSObj.values())
        {
            Case newCase = (Case)sObjItem;
            Case oldCase = (Case)oldSObj.get(newCase.Id);

            if ((rt_map.get(newCase.recordTypeID).getName().equalsIgnoreCase(CASE_AUTO_RTYPE) ||
                 rt_map.get(newCase.recordTypeID).getName().equalsIgnoreCase(CASE_MANUAL_RTYPE)))
            {
                if (isPopulated('Status', newCase, oldCase) &&
                    newCase.DER_Application__c != null &&
                    newCase.Status == 'Complete')
                {
                    derAppIdList.add(newCase.DER_Application__c);
                }
            }
        }

        if (!derAppIdList.isEmpty())
        {
            UpsertAssetRecords.upsertAssets(derAppIdList);
        }
    }


    // ---------------------------------------------------//
    //------------ Set Aemo Publish Date on Case ------------//
    // ---------------------------------------------------//
    private static void SetAemoPublishDate(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {

        switch on Trigger.operationType
        {

            when BEFORE_UPDATE
            {
                for (SObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;
                    Case oldCase = (Case)oldSObj.get(newCase.Id);

                    if ((newCase.Submission_Status__c == 'Submitted Successfully' ||
                         newCase.Submission_Status__c == 'Submitted with Exceptions') &&
                         newCase.Status == 'Publish' &&
                         oldCase.AEMO_Publish_Date__c == null &&
                         isPopulated('Submission_Status__c', newCase, oldCase))
                    {
                        newCase.AEMO_Publish_Date__c = Date.today();
                    }

                }
            }
        }
    }

    private static Boolean isRunningSetCaseFieldsOnDerApp = false;
    private static void setCaseFieldsOnDerApp(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        //if (isRunningSetCaseFieldsOnDerApp) return;
        isRunningSetCaseFieldsOnDerApp = true;

        System.debug('*** Trig_Case.setCaseFieldsOnDerApp');

        List<DER_Application__c> derListToUpdate = new List<DER_Application__c>();

        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for (SObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;
                    String RTName = UtilDatabase.getRecordTypes().get(newCase.RecordTypeId);

                    if (CaseSubject_AllowedRTs.contains(RTName) && newCase.DER_Application__c != null)
                    {
                        derListToUpdate.add(syncCaseFields(newCase));
                    }
                }
            }

            when AFTER_UPDATE
            {
                Map<Id, SObject> derApps = new Map<Id, SObject>();

                for (sObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;
                    if (newCase.DER_Application__c != null)
                        derApps.put(newCase.DER_Application__c, null);
                }

                if (!derApps.isEmpty())
                    derApps = UtilDatabase.getMapOfRecords(derApps.keySet());

                for (sObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;
                    Case oldCase = (Case)oldSObj.get(newCase.Id);
                    String RTName = UtilDatabase.getRecordTypes().get(newCase.RecordTypeId);
                    DER_Application__c derApp;

                    if (newCase.DER_Application__c == null) continue;

                    if (derApps.containsKey(newCase.DER_Application__c))
                        derApp = (DER_Application__c)derApps.get(newCase.DER_Application__c);

                    System.debug('Case Id: ' + newCase.Id);
                    System.debug('Case Status: ' + newCase.Status);

                    if (CaseSubject_AllowedRTs.contains(RTName))
                    {
                        Boolean updateApp = false;

                        // Check if a sync field has changed....
                        for (String caseField: SyncCaseFields.keySet())
                        {
                            //System.debug('caseField : - '+newCase.get(caseField));
                            String derAppField = SyncCaseFields.get(caseField);

                            if (isPopulated(caseField, newCase, oldCase) || isPopulated('DER_Application__c', newCase, oldCase) ||
                                CaseDERAppCheck(caseField, derAppField, newCase, derApp))
                            {
                                System.debug('Field changed/diff to DER App: ' + caseField);
                                updateApp = true;
                                break;
                            }
                            else if (isCleared(caseField, newCase, oldCase))
                            {
                                System.debug('Field cleared: ' + caseField);
                                updateApp = true;
                                break;
                            }
                        }

                        if (updateApp)
                        {
                            System.debug('Update required to DER App');
                            derListToUpdate.add(syncCaseFields(newCase));
                        }
                    }
                }
            }
        }

        if (!derListToUpdate.isEmpty())
        {
            //system.debug('derListToUpdate :- '+derListToUpdate);
            System.debug('Running update DER App');
            update derListToUpdate;
        }
    }

    private static DER_Application__c syncCaseFields(Case derCase)
    {
        DER_Application__c derApp = new DER_Application__c(Id = derCase.DER_Application__c);

        for (String caseField: SyncCaseFields.keySet())
        {
            String derAppFieldName = SyncCaseFields.get(caseField);
            //System.debug('caseField : - '+derCase.get(caseField));

            if (derCase.get(caseField) != null)
                derApp.put(derAppFieldName, derCase.get(caseField));
            else
                derApp.put(derAppFieldName, null);
        }

        return derApp;
    }

    private static void SetCaseStatus(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {

                for (SObject sObjItem: newSObj.values())
                {
                    Case newCase = (Case)sObjItem;

                    if (newCase.Update_Status__c && newCase.Status == 'Technical Assessment' )
                    {
                        newCase.Status = 'Offer Sent';
                        newCase.Update_Status__c = false;
                    }

                }

    }

    private static void ValidateDevices_GenerationTypesAndPhases(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        Set<Id> derAppIds = new Set<Id>();

        for (sObject sObjItem: newSObj.values())
        {
            Case newCase = (Case)sObjItem;
            Case oldCase = (Case)oldSObj.get(newCase.Id);

            if (isPopulated('Status', newCase, oldCase) && newCase.DER_Application__c != null )
            {
                derAppIds.add(newCase.DER_Application__c);
            }
        }

        if(!derAppIds.isEmpty())
        {
            UtilFieldCalcs.CalsGenerationTypesAndPhasesTotals(derAppIds);
        }
    }


    // ---------------------------------------------------//
    //------- Case Trigger utility methods ---------------//
    // ---------------------------------------------------//

    private static Boolean CaseDERAppCheck(String caseField, String derAppField, Case newCase, DER_Application__c derApp)
    {
        if (derApp == null || newCase == null || caseField == null || derAppField == null)
            return false;

        if (newCase.get(caseField) != derApp.get(derAppField))
            return true;

        return false;
    }

    private static Boolean isCleared(String f, Case newCase, Case oldCase)
    {
        return String.isBlank((String)newCase.get(f)) && ((String)newCase.get(f)) != ((String)oldCase.get(f));
    }

    private static Boolean isPopulated(String f, Case newCase, Case oldCase)
    {
        return String.isNotBlank((String)newCase.get(f)) && ((String)newCase.get(f)) != ((String)oldCase.get(f));
    }

    private static Boolean isValidNotificatoinMapping(Case newCase, String f)
    {
        if (f == 'Applicant_Type__c')
        {
            return newCase.get(f) == APPLICANT_INSTALLER && newCase.ContactId != null
                || newCase.get(f) == APPLICANT_CUSTOMER && newCase.Customer__c != null
                || newCase.get(f) == APPLICANT_REP && newCase.Representative__c != null;
        }
        else if (f == 'Responsible_Party__c')
        {
            return newCase.get(f) == RESP_PARTY_INSTALLER && newCase.ContactId != null
                || newCase.get(f) == RESP_PARTY_CUSTOMER && newCase.Customer__c != null
                || newCase.get(f) == RESP_PARTY_REP && newCase.Representative__c != null;

        }

        return false;
    }

    public static String genRandomString(Integer len)
    {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        String randStr = '';

        while (randStr.length() < len)
        {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
    
    // this method created for nintext docgen purpose. using this method we are storing attachmentId in text field.
    private static void SetAttachmentId(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {       
        for (SObject sObjItem: newSObj.values())
        {
            Case newCase = (Case)sObjItem;          
            Case oldCase = (Case)oldSObj.get(newCase.Id);            
             
            List<ContentDocumentLink> lstNewAttachmentId = new List<ContentDocumentLink>();            
            if((newCase.Status != oldCase.Status && newCase.Status == 'Complete') || newCase.Status == 'Technical Assessment' || newCase.Status == 'Offer Sent' )
            {
                lstNewAttachmentId = [SELECT ContentDocument.id FROM ContentDocumentLink WHERE LinkedEntityId =: newCase.Id 
                                      AND (ContentDocument.Title LIKE 'SLD%' OR ContentDocument.Title LIKE 'sld%' OR ContentDocument.Title LIKE 'SLD_%'OR ContentDocument.Title LIKE 'sld_%') 
                                      ORDER BY SystemModstamp DESC LIMIT 1];               
                
                if (!lstNewAttachmentId.isEmpty())
                {
                    newCase.AttachmentIds__c = lstNewAttachmentId[0].ContentDocument.id;               
                } 
            }   
        }
    }
    
}