/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 23 Dec 2019
@Description : Class for project Utility
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
public without sharing class TVE_Project_Utility {
    private static final String SMS_CALLOUT = 'NewConnectionSMS';
    public static String Artefact_Invoice_RT = 'Invoice';
    public static final string CLASSIFICATION_INVOICE = 'Invoice';
    public static String AST_PROG_CORD = 'AST_Program_Coordinators';
    public static Id AST_PROG_CORD_QUEUE_ID;
    
    private static List<TVE_Project_Progress__mdt> mdtObj;

    // Updated by JTan on 06/04/2020 for TV-2792
    @future(callout=true)
    public static void processStatusNotification(List<Id> projIds){
        API_Callout_Headers__mdt apiCallHea = [SELECT key__c, sourceSystem__c, targetSystem__c, objectName__c, endpoint__c FROM API_Callout_Headers__mdt WHERE objectName__c =: SMS_CALLOUT];
        EmailTemplate et = [SELECT Body FROM EmailTemplate WHERE DeveloperName = 'SMS_Status_Update'];
        
        Map<Id, String> mapProjToMobile = new Map<Id, String>();
        for(Project__c projObj : [SELECT Id, ApplicantAccount__c, ApplicantContact__c, ApplicantAccount__r.IsPersonAccount,
            ApplicantAccount__r.PersonMobilePhone, ApplicantContact__r.MobilePhone FROM Project__c WHERE Id IN :projIds]
        ) {
            if(projObj.ApplicantAccount__c != null) {
                if(projObj.ApplicantAccount__r.IsPersonAccount) {
                    if(projObj.ApplicantAccount__r.PersonMobilePhone != null) {
                        mapProjToMobile.put(projObj.Id, projObj.ApplicantAccount__r.PersonMobilePhone);
                    }
                } else {
                    if(projObj.ApplicantContact__c != null && projObj.ApplicantContact__r.MobilePhone != null) {
                        mapProjToMobile.put(projObj.Id, projObj.ApplicantContact__r.MobilePhone);
                    }
                }
            }
        }
        for(Id projId : projIds) {
            if(mapProjToMobile.containsKey(projId)) {
                processStatusChangeNotification(apiCallHea, et, projId, mapProjToMobile.get(projId));
            }
        }
    }

    // Updated by JTan on 06/04/2020 for TV-2792
    public static void processStatusChangeNotification(API_Callout_Headers__mdt apiCallHea, EmailTemplate et, Id projId, String to){
        JSONGenerator gen = JSON.createGenerator(true);
        String msgId = TVE_Utility.getUniqueId(projId);
        List<Messaging.RenderEmailTemplateBodyResult> resList = Messaging.renderEmailTemplate(null, projId, new list<string>{et.Body});
        gen.writeStartObject();
        gen.writeFieldName('request');
        gen.writeStartObject();
        gen.writeStringField('key', apiCallHea.key__c);
        gen.writeStringField('msgId', msgId);
        gen.writeStringField('sourceSystem', apiCallHea.sourceSystem__c);
        gen.writeStringField('targetSystem', apiCallHea.targetSystem__c);
        gen.writeStringField('objectName', apiCallHea.objectName__c);
        gen.writeFieldName('payload');
        gen.writeStartObject();
        gen.writeStringField('to', to);
        gen.writeStringField('messageBody', resList[0].getMergedBody());
        gen.writeEndObject();
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        system.debug('jsonData++'+jsonData);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setClientCertificateName('eains');
        request.setBody(jsonData);
        system.debug('requestBody++'+request.getBody());
        request.setEndpoint(apiCallHea.endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        system.debug('reBody++'+request.getBody());
        if(!Test.isRunningTest())
        {
            HttpResponse response = http.send(request);
            system.debug('responseBody++'+response.getBody());    
        }   
    }

    public static void RemoveProjectUrl(Map<Id,Project__c> projects) 
    {
        Project__c proj;
        for(Id prjItemId: projects.keySet())
        {   
            proj = projects.get(prjItemId);
            proj.TVE_Project_URL__c = null;
            proj.CommunityChatterLink__c = null;
            proj.SitecoreAcceptanceLink__c = null;
            proj.UploadDocumentsLink__c = null;
        }
        // no update dml required since called from before update
    }
    
    public static void PopulateProjUrls_AfterEvent(Map<Id,Project__c> projects)
    {
        eSignSettings__c eSign = eSignSettings__c.getInstance();
        System.debug('eSign' + eSign);
        if(eSign != null)
        {
            if(eSign.AES_Key__c != null)
            {   
                if(projects!=null)
                {                    
                    Project__c newProj;
                        
                    List<Project__c> prjUpdateList = new List<Project__c>();
                    
                    Map<Id, Project__c> mapProj = new Map<Id, Project__c>( [SELECT Id, TVE_Project_URL__c, WorkCode__c,
                                                                            ApplicantContact__c, ApplicantContact__r.UserCommunityLicense__c,
                                                                            IsPropertyOwner__c, RelationshipToOwner__c,
                                                                            CommunityChatterLink__c, UploadDocumentsLink__c, SitecoreAcceptanceLink__c,
                                                                            TriageDescription__c
                                                                            FROM Project__c 
                                                                            WHERE Id IN :projects.keySet()]
                                                                        );

                    for(Id prjId: mapProj.keySet())
                    {
                        newProj = mapProj.get(prjId);
                        System.debug('Trigger.operationType--->'+Trigger.operationType);
                        System.debug('newProj.ApplicantContact__r.UserCommunityLicense__c-->'+newProj.ApplicantContact__r.UserCommunityLicense__c);
                        newProj = ProjectLinkMapping(newProj, eSign, null);
                        prjUpdateList.add(newProj);                                             
                    }

                    if(!prjUpdateList.isEmpty())
                    {
                        update prjUpdateList;
                    }                                       
                }
            }
            else 
            {
                System.debug('PopulateProjUrls----> eSign.AES_Key__c is NOT set');
                //throw new TVE_ConfigurationException('AES key is not set for custom setting eSignSettings__c');
            }            
        }else{
            System.debug('eSignSettings__c data not found');
            throw new TVE_ConfigurationException('No valid records found for custom setting eSignSettings__c');
        }
    }

    public static void PopulateProjUrls_BeforeEvent(Map<Id,Project__c> projects)
    {
        Map<Id,Project__c> mapProjWithURL = new Map<Id, Project__c>();
        eSignSettings__c eSign = eSignSettings__c.getInstance();
        System.debug('eSign' + eSign);
        if(eSign != null)
        {
            if(eSign.AES_Key__c != null)
            {   
                if(projects!=null)
                {                    
                    Project__c newProj;
                    //Project__c projWithURL = new Project__c();
                        
                    List<Project__c> prjUpdateList = new List<Project__c>();
                    
                    Map<Id, Project__c> mapProj = new Map<Id, Project__c>( [SELECT Id, TVE_Project_URL__c, WorkCode__c,
                                                                    ApplicantContact__c, ApplicantContact__r.UserCommunityLicense__c,
                                                                    IsPropertyOwner__c, RelationshipToOwner__c,
                                                                    CommunityChatterLink__c, UploadDocumentsLink__c, SitecoreAcceptanceLink__c
                                                                    FROM Project__c 
                                                                    WHERE Id IN :projects.keySet()]
                                                                );


                    map<Id, Id> mapProj_AppContId = new map<Id, String>();

                    for(Id prjId: projects.keySet())
                    {
                        mapProj_AppContId.put(prjId, projects.get(prjId).ApplicantContact__c);
                    }
                    system.debug('mapProj_AppContId---->'+mapProj_AppContId);

                    Map<Id, Contact> mapCon = new Map<Id, Contact>([SELECT Id, UserCommunityLicense__c FROM Contact WHERE id =:mapProj_AppContId.values()]);
                    system.debug('mapCon---->'+mapCon);
                    
                    
                    map<Id, String> mapProj_AppConLicense = new map<Id, String>();
                    
                    for(Id prjId:  mapProj_AppContId.keySet())
                    {
                        mapProj_AppConLicense.put(prjId, (mapCon.get(mapProj_AppContId.get(prjId))).UserCommunityLicense__c );
                    }
                    system.debug('mapProj_AppConLicense---->'+mapProj_AppConLicense);                                                                                                                        
                    
                    for(Id prjId: mapProj.keySet())
                    {
                        System.debug('mapProj_AppConLicense.get(prjId)--->'+mapProj_AppConLicense.get(prjId));
                        if(mapProj_AppConLicense.get(prjId) != null)
                        { 
                            newProj = projects.get(prjId);
                            ProjectLinkMapping(newProj, eSign, mapProj_AppConLicense);                                                            
                        }                        
                    }                                      
                }
            }
            else 
            {
                System.debug('PopulateProjUrls----> eSign.AES_Key__c is NOT set');
                //throw new TVE_ConfigurationException('AES key is not set for custom setting eSignSettings__c');
            }            
        }else{
            System.debug('eSignSettings__c data not found');
            throw new TVE_ConfigurationException('No valid records found for custom setting eSignSettings__c');
        }               
    }
    
    public static Project__c ProjectLinkMapping(Project__c newProj, eSignSettings__c eSign, Map<Id, String> mapProj_AppConLicense)
    {
        // --------------------------------------------------------------------------------------------------- //
        // -- If "mapProj_AppConLicense" is provided i.e. this method is called from before update trigger --- //
        // --------------------------------------------------------------------------------------------------- //

        String encoded_proj_Id;
        String energy_conn_cc_document_tab_Id = '';
        String energy_conn_cc_message_tab_Id = '';
        String energy_conn_pc_document_tab_Id = '';
        String energy_conn_pc_message_tab_Id = '';
        
        List<TVE_Community_Tabset__mdt> lstTabSets = new List<TVE_Community_Tabset__mdt>([SELECT DeveloperName, Tabset_Id__c 
                                                                                                FROM TVE_Community_Tabset__mdt]);

        for(TVE_Community_Tabset__mdt item: lstTabSets) 
        {
            if(item.DeveloperName == 'Energy_Connect_Customer_Documents')
            {
                energy_conn_cc_document_tab_Id = item.Tabset_Id__c;
            }
            else if(item.DeveloperName == 'Energy_Connect_Customer_Messages')
            {
                energy_conn_cc_message_tab_Id = item.Tabset_Id__c;
            }
            else if(item.DeveloperName == 'Energy_Connect_Partner_Documents')
            {
                energy_conn_pc_document_tab_Id = item.Tabset_Id__c;
            }
            else if(item.DeveloperName == 'Energy_Connect_Partner_Messages')
            {
                energy_conn_pc_message_tab_Id = item.Tabset_Id__c;
            }

        }
                                                                                                        
        System.debug('ProjectLinkMapping-----> mapProj_AppConLicense'+mapProj_AppConLicense);
        System.debug('ProjectLinkMapping-----> newProj.ApplicantContact__r.UserCommunityLicense__c--->'+newProj.ApplicantContact__r.UserCommunityLicense__c);
        System.debug('ProjectLinkMapping-----> newProj.IsPropertyOwner__c--->'+newProj.IsPropertyOwner__c);
        System.debug('ProjectLinkMapping-----> newProj.RelationshipToOwner__c--->'+newProj.RelationshipToOwner__c);

        encoded_proj_Id = getEncryptedId(newProj.Id, esign.AES_Key__c);

        if((mapProj_AppConLicense == null && newProj.ApplicantContact__r.UserCommunityLicense__c == 'Unregistered Community User')
            ||
            (mapProj_AppConLicense != null && mapProj_AppConLicense.get(newProj.Id) == 'Unregistered Community User') ||
           (newProj.WorkCode__c != null && newProj.WorkCode__c == '1013'))
        {
            newProj.TVE_Project_URL__c = eSign.TVE_Project_URL_Unregistered__c + encoded_proj_Id;
            newProj.CommunityChatterLink__c = '';
            newProj.SitecoreAcceptanceLink__c = eSign.TVE_Sitecore_Acceptance_URL__c + encoded_proj_Id;
            newProj.UploadDocumentsLink__c = eSign.TVE_Doc_Upload_URL_Unregistered__c + encoded_proj_Id;
        }
        else if(newProj.IsPropertyOwner__c == 'No' && newProj.RelationshipToOwner__c == 'Accredited Service Provider - AusNet Services') 
        {          
            newProj.TVE_Project_URL__c = eSign.TVE_Project_URL_Partner_Community__c + newProj.Id;
            newProj.CommunityChatterLink__c = eSign.TVE_Project_URL_Partner_Community__c + newProj.Id + '/?' + energy_conn_pc_message_tab_Id;
            newProj.UploadDocumentsLink__c = eSign.TVE_Project_URL_Partner_Community__c + newProj.Id + '/?' + energy_conn_pc_document_tab_Id;
        }
        else if((newProj.IsPropertyOwner__c == 'Yes' || (newProj.IsPropertyOwner__c == 'No' && newProj.RelationshipToOwner__c != 'Accredited Service Provider - AusNet Services')))
        {
            newProj.TVE_Project_URL__c = eSign.TVE_Project_URL_Customer_Community__c + newProj.Id;
            newProj.CommunityChatterLink__c = eSign.TVE_Project_URL_Customer_Community__c + newProj.Id + '/?' + energy_conn_cc_message_tab_Id;
            newProj.UploadDocumentsLink__c = eSign.TVE_Project_URL_Customer_Community__c + newProj.Id + '/?' + energy_conn_cc_document_tab_Id;

            if(newProj.TriageDescription__c == 'Pending Registration') {
                newProj.TriageDescription__c = null;
            }
        }
        System.debug('newProj.TVE_Project_URL__c--->'+newProj.TVE_Project_URL__c);
        System.debug('newProj.CommunityChatterLink__c--->'+newProj.CommunityChatterLink__c);
        System.debug('newProj.SitecoreAcceptanceLink__c--->'+newProj.SitecoreAcceptanceLink__c);
        System.debug('newProj.UploadDocumentsLink__c--->'+newProj.UploadDocumentsLink__c);
            
        return newProj;
    }

    public static String getEncryptedId(String projId, String AESKey) {
        system.debug('projId-->'+projId);
        system.debug('eSign.AES_Key__c-->'+AESKey);
        Blob key = EncodingUtil.base64Decode(AESKey);
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, Blob.valueOf(projId));
        String encodedStr = EncodingUtil.base64Encode(encrypted);
        //Added by JTan on 07/04/2020 for TV-2456
        encodedStr = encodedStr.replace('+','-').replace('/', '_');
        return encodedStr;
    }

    public static Boolean isValidProgressStatusBarChange(string newStatus,string oldStatus,string conType){
        Boolean isValid = false;
        list<TVE_Project_Progress__mdt> validStatusList = queryMetadataForProgressStatus(conType);
        if(validStatusList != null && !validStatusList.isEmpty()){        
            set<string> setOfvalidStatus = new set<string>();
            for(TVE_Project_Progress__mdt metadataObj :validStatusList){
                setOfvalidStatus.add(metadataObj.Status__c);
            }
            system.debug('setOfvalidStatus'+setOfvalidStatus);
            if(!setOfvalidStatus.isEmpty()){
                if(setOfvalidStatus.contains(newStatus) && setOfvalidStatus.contains(oldStatus)){
                    isValid = true;
                }
            }
        }else{
            throw new TVE_ConfigurationException('No valid records found for custom metadata API '+
                                                 'named TVE_Project_Progress__mdt for Type__c is: '+conType);
        }    
        return isValid;
    }

    public static List<TVE_Project_Progress__mdt> queryMetadataForProgressStatus(string conType){
        if(mdtObj == null){
            mdtObj = [SELECT id, Type__c, Status__c 
                      FROM TVE_Project_Progress__mdt 
                      WHERE Type__c= :conType];            
        }
        return mdtObj;
    }

    public static void insertProjectWorkCodeAndMore(List<Project__c> newSObject)
    {
        List<TVE_Work_Code_Matrix__mdt> listMdt = new  List<TVE_Work_Code_Matrix__mdt>([SELECT Job_Type__c, Work_Code__c, Contestability__c,
                                                                                                CU_Design__c, 
                                                                                                COMT_MATERIALCODE1__c, COMT_MATERIALCODE2__c,
                                                                                                DSGN_MATERIALCODE1__c, DSGN_MATERIALCODE2__c,
                                                                                                PREQ_MATERIALCODE1__c, PREQ_MATERIALCODE2__c
                                                                                            FROM TVE_Work_Code_Matrix__mdt]);              
        
        if(listMdt != null && !listMdt.isEmpty())
        {     

            Map<string,TVE_Work_Code_Matrix__mdt> mapJobTypeVsRec= new Map<string,TVE_Work_Code_Matrix__mdt>();
            for (TVE_Work_Code_Matrix__mdt item : listMdt) 
            {
                mapJobTypeVsRec.put(item.Job_Type__c, item);
            }
            TVE_Work_Code_Matrix__mdt wcmItem;
            if(mapJobTypeVsRec != null && !mapJobTypeVsRec.isEmpty())
            {
                for (Project__c itemProj : newSObject) {
                    itemProj.OfferType__c = getOfferTypeFromPaymentType(itemProj.PaymentType__c, itemProj.JobType__c);
                    
                    if(mapJobTypeVsRec.get(itemProj.JobType__c) != null)
                    {
                        wcmItem = mapJobTypeVsRec.get(itemProj.JobType__c);
                        system.debug('Matched Work Code matrix item-->'+wcmItem);            

                        itemProj.WorkCode__c = wcmItem.Work_Code__c;
                        itemProj.ContestabilityType__c = wcmItem.Contestability__c;
                        itemProj.CUDesignTemplate__c = wcmItem.CU_Design__c;
    
                        if(itemProj.OfferType__c == 'COMT')
                        {
                            itemProj.MaterialBillingCode1__c = wcmItem.COMT_MATERIALCODE1__c;
                            itemProj.MaterialBillingCode2__c = wcmItem.COMT_MATERIALCODE2__c;
                        }
                        else if(itemProj.OfferType__c == 'PREQ')
                        {
                            itemProj.MaterialBillingCode1__c = wcmItem.PREQ_MATERIALCODE1__c;
                            itemProj.MaterialBillingCode2__c = wcmItem.PREQ_MATERIALCODE2__c;
                        }
                        else if(itemProj.OfferType__c == 'DSNG')
                        {
                            itemProj.MaterialBillingCode1__c = wcmItem.DSGN_MATERIALCODE1__c;
                            itemProj.MaterialBillingCode2__c = wcmItem.DSGN_MATERIALCODE2__c;
                        }           
                    }
                    else 
                    {
                        system.debug('No Work Code matrix record found for job code-->'+itemProj.JobType__c);                
                    }         
                }
            }

            
        }
        else{
            throw new TVE_ConfigurationException('No valid records found for custom metadata API '+
                                                 'named TVE_Work_Code_Matrix_mdt');
        }        
    }

    public static String getOfferTypeFromPaymentType(String paymentType, String jobType)    
    {
        List<String> jobTypeList =  new List<String>{'R-NPTP-A-001-00', 
                                                     'R-NPTP-A-002-00', 
                                                     'R-NPTP-A-003-00', 
                                                     'R-NPTP-A-004-00', 
                                                     'R-NPTP-A-005-00',  
                                                     'R-NPTP-A-006-00'};

        // Added by JTan on 06/04/2020 for TV-2766
        if(String.isBlank(paymentType)) {
            return 'PREQ';
        }
        String returnValue;
        switch on paymentType {
            when 'Prelim' {
                returnValue = 'PREQ';
            }
            when 'Firm'
            {
                if(jobTypeList.contains(jobType))
                {
                    returnValue = 'COMT';
                }
                else{
                    returnValue = 'DSNG';
                }
            }
        }
        return returnValue;
    }    

    public static void SiteOwnerAuthRepCreation(List<Project__c> createdRecList){ 
        if(createdRecList.size() == 1)
        {
            TVE_SiteOwnerAuthRepUtil.populateSiteOwnerAuthRep(createdRecList[0]);
        }
        else 
        {
            System.debug('TVE_Project_Utility->SiteOwnerAuthRepCreation--> MORE THAN 1 PROJECT RECORDS. THIS LOGIC WORK WITH BATCH SIZE 1 OR SINGLE PROJECT AT A TIME');
        }
    }
    
    //added by Neha to create Integration task Record
    public static void CreateIntegTask(List<Project__c> createIntRecList)
    {
        List<Integration_Task__c> IntTaskList = new List<Integration_Task__c>();
        Integration_Task__c IntTask;
        for(Project__c proj:createIntRecList)
        {
            IntTask = new Integration_Task__c();
            IntTask.Operation__c ='Create';
            IntTask.SObject__c = 'Project__c';
            IntTask.ParentId__c = Proj.Id;
            IntTask.Type__c ='CreateCustomer';
            IntTask.Status__c = 'Ready';
            IntTaskList.add(IntTask);
        }
        if(IntTaskList.size()>0)
            insert IntTaskList;
    }

    

    public static void UpdateProj_AccContLookups(List<Project__c> createAccRecList)
    {   
        system.debug('method2++++createAccRecList++'+createAccRecList);
        list<Project__c> listOfProject = new List<Project__c>();
        for(Project__c proj:[select id,SiteOwner__c,PropertyOwnerContact__c,
                             AuthorisedRepresentative__c,AuthorizedRepresentativeContact__c,
                             IsPropertyOwner__c,RelationshipToOwner__c,
                             //ApplicantContact__c,ASPContact__c,
                             ApplicantAccount__c,ASP__c
                             from Project__c where id IN :createAccRecList])
        {
            system.debug('proj++____'+proj);
            if(proj.IsPropertyOwner__c=='Yes'){
                proj.ApplicantAccount__c=proj.SiteOwner__c;
                proj.ApplicantContact__c=proj.PropertyOwnerContact__c;
                listOfProject.add(proj);
            }
            else if(proj.IsPropertyOwner__c=='No'){
                proj.ApplicantAccount__c=proj.AuthorisedRepresentative__c;
                proj.ApplicantContact__c=proj.AuthorizedRepresentativeContact__c;
                listOfProject.add(proj);
            }
        }
        if(!listOfProject.isEmpty()){
            update listOfProject;
        }
    }
    
    public static void PrePopulateProject(List<Project__c> newSObject)
    {
        List<User> userAssigned = new List<User>([SELECT Id FROM User WHERE TVE_Default_Assignee__c = true LIMIT 1]);

        //Added by JTan on 2020/03/20 for TV-2477
        List<String> lstASPExtIds = new List<String>();
        for(Project__c proj : newSObject) {
            if(String.isNotBlank(proj.ASPId__c)) {
                lstASPExtIds.add(proj.ASPId__c);
            }
        }
        Map<String, Id> mapASPExtIdToId = getValidASPs(lstASPExtIds);

        for(Project__c proj : newSObject)
        {
            if(String.isNotBlank(proj.ApplicationType__c))
                proj.RecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get(proj.ApplicationType__c).getRecordTypeId();

            if(!userAssigned.isEmpty()){
                proj.ProjectAssignee__c = userAssigned[0].Id;
            }

            //Added by JTan on 2020/03/20 for TV-2477
            if(mapASPExtIdToId.containsKey(proj.ASPId__c)){
                proj.ASP__c = mapASPExtIdToId.get(proj.ASPId__c);
            }

            if(proj.CMNumber__c == NULL){
                proj.CMType__c = '0003';
                proj.SAP_Integration_Status__c = 'Ready to Create';
                if(!userAssigned.isEmpty()){
                    proj.OwnerId = userAssigned[0].Id;
                }
            }
            else{
                String msg = [SELECT Message__c FROM TVEMessages__mdt WHERE DeveloperName = 'No_Reference_Number'][0].Message__c;
                proj = TriageProject(proj, msg);
            }
        }
    }

    public static Project__c TriageProject(Project__c proj, String message) 
    {
        proj.SAP_Integration_Status__c = 'Pending Triage';
        proj.PendingReview__c = true;
        proj.ProjectAssigmentStatus__c = 'Data Validation Required';
        if(proj.TriageDescription__c != null)
            proj.TriageDescription__c = proj.TriageDescription__c + '\n' + message;
        else
            proj.TriageDescription__c =  message;
        
        if(AST_PROG_CORD_QUEUE_ID == null)
            AST_PROG_CORD_QUEUE_ID = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName =:AST_PROG_CORD LIMIT 1][0].Id;    

        proj.OwnerId = AST_PROG_CORD_QUEUE_ID;
        return proj;
    }

    //Added by JTan on 2020/03/20 for TV-2477
    public static Map<String, Id> getValidASPs(List<String> lstASPExtIds) {
        Map<String, Id> ret = new Map<String, Id>();
        for(Account acct : [SELECT Id, ASPAccreditaionId__c FROM Account WHERE ASPAccreditaionId__c IN :lstASPExtIds]) {
            ret.put(acct.ASPAccreditaionId__c, acct.Id);
        }
        return ret;
    }
    
    public static void ArtefactCreation(List<Project__c> createIntRecListItem)
    {
        Id Artefact_Invoice_RT_Id = Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get(Artefact_Invoice_RT).getRecordTypeId();
        List<Artefact__c> artList = new List<Artefact__c>();
        Artefact__c art;
        for(Project__c proj:createIntRecListItem)
        {            
            if(proj.ApplicationPaymentMethod_fx__c  == 'PAYNOW'){
                art = new Artefact__c(); 
                art.Project__c = proj.Id;
                art.ElectronicPaymentReferenceNumber__c = proj.PaymentReferenceNumber__c;
                //art.InvoicePaidDate__c = date.today();
                art.RecordTypeId = Artefact_Invoice_RT_Id;
                art.Classification__c = CLASSIFICATION_INVOICE;
                art.TotalAmount__c = proj.PaymentAmount__c;
                art.NetAmount__c = proj.PaymentAmountExGST__c;
                art.Status__c = 'Pending Reconciliation';
                art.IsPayNow__c = true;
            }
            else if(proj.ApplicationPaymentMethod_fx__c  == 'PAYLATER'){
                art = new Artefact__c(); 
                art.Status__c = 'Pending Payment';
                art.Classification__c = CLASSIFICATION_INVOICE;
                art.Project__c = proj.Id;
                art.RecordTypeId = Artefact_Invoice_RT_Id;
            }
            artList.add(art);
        }
        if(artList.size()>0)
            insert artList;
    }
    
    public static void WorkOrderCreation(List<Project__c> createIntRecList)
    {
        system.debug('method++WorkOrderCreation+++'+createIntRecList);
        List<WorkOrder> workordlist = new List<WorkOrder>();
        map<id,list<WorkOrder>> mapOfProjectWorkOrder = new map<id,List<WorkOrder>>();
        WorkOrder designWorkOrder;
        WorkOrder constructionWorkOrder;
        
        for(Project__c proj:createIntRecList)
        {
            //Design Work order
            designWorkOrder = new WorkOrder();
            designWorkOrder.Type__c ='Design';
            designWorkOrder.WorkOrderType__c ='Z009';
            designWorkOrder.Project__c =proj.Id;
            workordlist.add(designWorkOrder);
            //Construction work order
            constructionWorkOrder = new WorkOrder();
            constructionWorkOrder.Type__c ='Construction';
            constructionWorkOrder.Project__c =proj.Id;
            workordlist.add(constructionWorkOrder);
        }
        if(workordlist.size()>0)
            insert workordlist;
    }
    
    @future
    public static void OpportunityCreation(List<Id> createIntRecList)
    {
        system.debug('method++OpportunityCreation+++'+createIntRecList);
        List<Project__c> createIntRecListItem = [select id from Project__c where id IN :createIntRecList];
        list<WorkOrder> wrk = [select id from WorkOrder where Project__c IN :createIntRecList];
        List<Opportunity> opplist = new List<Opportunity>();
        Opportunity opp1;
        Opportunity opp2;
        for(Project__c proj:createIntRecListItem)
        {
            for(workOrder wo : [select id,Type__c from WorkOrder where Project__c =: proj.Id]){
                if(wo.Type__c =='Design'){
                    opp1 = new Opportunity();
                    opp1.Type = 'Design';
                    opp1.Notification_Type__c = 'ZC';
                    opp1.System_Status__c = 'NOPR';
                    opp1.WorkOrder__c = wo.Id;
                    opp1.Project__c = proj.Id;
                    opp1.CloseDate = date.today();
                    opp1.Name = 'Design'+ proj.Id;
                    opp1.StageName = 'Qualification';
                    opplist.add(opp1);
                }else if(wo.Type__c =='Construction'){
                    opp2 = new Opportunity();
                    opp2.Type ='Construction';
                    opp2.Project__c = proj.Id;
                    opp2.WorkOrder__c = wo.Id;
                    opp2.CloseDate = date.today();
                    opp2.Name = 'Construction'+ proj.Id;
                    opp2.StageName = 'Qualification';
                    opplist.add(opp2);
                }
            }
        }
        if(opplist.size()>0)
            insert opplist;
    }
}