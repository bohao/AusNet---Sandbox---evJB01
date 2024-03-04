/*
@author  : harshad.kumbhar@ausnetservices.com.au
@created : 24 Feb 2020
@Description : REST based webservice for change event to create tasks/batch jobs
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/

@RestResource(urlMapping='/v1.0/changeevent/*')
global with sharing class TVE_SAPInteg_ChangeEventAPI {
    
    public static String Proj_RT = 'Project';
    public static Id Proj_RTId   = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByDeveloperName().get(Proj_RT).getRecordTypeId();    
    public static String Art_RT  = 'Artefact';
    public static Id Art_RTId    = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByDeveloperName().get(Art_RT).getRecordTypeId();
    public static String Opp_RT  = 'Opportunity';
    public static Id Opp_RTId    = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByDeveloperName().get(Opp_RT).getRecordTypeId();
    public static String WO_RT   = 'WorkOrder';
    public static Id WO_RTId     = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByDeveloperName().get(WO_RT).getRecordTypeId();

    public static String Artefact_Invoice_RT = 'Invoice';
    public static Id Artefact_Invoice_RT_Id = Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get(Artefact_Invoice_RT).getRecordTypeId();

    public static final String SOURCE_SAP = 'SAP';
    
    @HttpPost
    global static void doPost() {
        String reqContentType = RestContext.request.headers.get('Content-Type');
        PayloadResponse payloadResponse = new PayloadResponse();
        if(String.isNotBlank(reqContentType) && reqContentType.toLowerCase().contains('application/json'))
        {
            String reqBody = RestContext.request.requestBody.toString();
            if(String.isNotBlank(reqBody))
            {
                try
                {
                    TVE_SAPInteg_ChangeEvent_Payload payload = (TVE_SAPInteg_ChangeEvent_Payload)JSON.deserialize(reqBody, TVE_SAPInteg_ChangeEvent_Payload.class);
                    payloadResponse = validatePayload(payload);
                }
                catch(Exception e)
                {
                    payloadResponse.statusCode = '403';
                    payloadResponse.status = 'Fail';
                    payloadResponse.message = e.getMessage();
                }
            }
        }
        RestContext.response.addHeader('Content-Type', 'application/json;');		
        RestContext.response.statusCode = Integer.valueOf(payloadResponse.statusCode);		
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(payloadResponse));
    }
    
    public class PayloadResponse
    {
        public string statusCode {get; set;}
        public string status {get; set;}
        public string message {get; set;}
    }
    
    public static PayloadResponse validatePayload(TVE_SAPInteg_ChangeEvent_Payload payload)
    {
        PayloadResponse body = new PayloadResponse();
        switch on payload.request.objectName {
            when 'Event.CM_Update' {
                if (String.isNotBlank(payload.request.payload.objectId))
                {
                    Map<Id,Project__c> mapProj = new Map<Id,Project__c>([SELECT Id, CMNumber__c FROM Project__c 
                                                                         WHERE CMNumber__c =: payload.request.payload.objectId]);
                    
                    if (mapProj.isEmpty())
                    {
                        body.statusCode = '403';
                        body.status = 'Fail';
                        body.message = 'No Project record with CM number '+payload.request.payload.objectId+' found';
                    }
                    else if (mapProj.size() == 1)
                    {
                        List<Integration_Task__c> taskList = [SELECT Id, Status__c, Type__c FROM Integration_Task__c 
                                                              WHERE ParentId__c =: mapProj.keySet() 
                                                              AND (Status__c = 'Ready' OR Status__c = 'In Progress')];
                        
                        Map<String, Integer> mapTask = new Map<String, Integer>();
                        for(Integration_Task__c task : taskList) {
                            switch on task.Type__c {
                                when 'UpdateCM' {
                                    Integer taskCount = mapTask.containsKey(task.Type__c) ? mapTask.get(task.Type__c) : 0;
                                    mapTask.put(task.Type__c, taskCount++);
                                }
                                when 'GetCM' {
                                    Integer taskCount = mapTask.containsKey(task.Type__c) ? mapTask.get(task.Type__c) : 0;
                                    mapTask.put(task.Type__c, taskCount++);
                                }
                                when else {
                                    Integer taskCount = mapTask.containsKey('Other') ? mapTask.get('Other') : 0;
                                    mapTask.put('Other', taskCount++);
                                }
                            }
                        }
                        
                        if (mapTask.containsKey('UpdateCM')) {
                            body.statusCode = '403';
                            body.status = 'Fail';
                            body.message = 'Update from Salesforce to SAP is pending. Please try later';
                        }
                        else if (mapTask.containsKey('GetCM')) {
                            body.statusCode = '200';
                            body.status = 'Success';
                            body.message = '';
                        }
                        else if (mapTask.containsKey('Other')) {
                            body.statusCode = '403';
                            body.status = 'Fail';
                            body.message = 'Creation from Salesforce to SAP is pending. Please try later';
                        }
                        else {
                            Map<Id,String> creatIntTaskMapKey = new Map<Id,String>();
                            Map<String,String> creatIntTaskMap = new Map<String,String>();
                            creatIntTaskMapKey.put(mapProj.values()[0].Id, mapProj.values()[0].Id);
                            creatIntTaskMap.put('Operation__c','Get');
                            creatIntTaskMap.put('SObject__c','Project__c');
                            creatIntTaskMap.put('Type__c','GetCM');
                            creatIntTaskMap.put('Status__c','Ready');
                            creatIntTaskMap.put('RecordTypeID', Proj_RTId);
                            TVE_IntegUtility.CreateInteTask(creatIntTaskMapKey,creatIntTaskMap);
                                
                            body.statusCode = '200';
                            body.status = 'Success';
                            body.message = '';
                        }
                    }
                    else {
                        body.statusCode = '403';
                        body.status = 'Fail';
                        body.message = 'More than one Project record found';
                    }
                }
                else {
                    body.statusCode = '403';
                    body.status = 'Fail';
                    body.message = 'Bad Request: objectId not found';
                }
            }
            when 'Event.Work_Create' {
                if (String.isNotBlank(payload.request.payload.objectId))
                {
                    List<SObject> sobjectsToUpdate = new List<SObject>();
                    List<SObject> sobjectsToInsert = new List<SObject>();
                    List<String> errorMessages = new List<String>();
                    // Project update              
                    Map<Id,Project__c> mapProj = new Map<Id,Project__c>([SELECT Id, CMNumber__c, SalesOrder__c FROM Project__c 
                                                                         WHERE Id =: payload.request.payload.objectId]);
                    if (mapProj.isEmpty())
                    {
                        body.statusCode = '403';
                        body.status = 'Fail';
                        errorMessages.add('No Project record with ID ' + payload.request.payload.objectId + ' found');
                    }
                    else if (mapProj.size() == 1)
                    {
                        updateProject(sobjectsToUpdate, mapProj.values()[0], payload.request.payload.cmId, payload.request.payload.salesOrderId);
                    }
                    else {
                        body.statusCode = '403';
                        body.status = 'Fail';
                        errorMessages.add('More than one Project record found');
                    }
                    
                    // Opp update
                    if (String.isNotBlank(payload.request.payload.constNotiId)) {
                        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>([SELECT Id, Notification_Number__c FROM Opportunity 
                                                                              WHERE Type = 'Construction' 
                                                                              AND Project__c =: payload.request.payload.objectId]);
                        if (mapOpp.isEmpty())
                        {
                            body.statusCode = '403';
                            body.status = 'Fail';
                            errorMessages.add('No Construction Opportunity record found for Project with ID ' + payload.request.payload.objectId);
                        }
                        else if (mapOpp.size() == 1)
                        {
                            updateOpportunity(sobjectsToUpdate, mapOpp.values()[0], payload.request.payload.constNotiId);
                        }
                        else {
                            body.statusCode = '403';
                            body.status = 'Fail';
                            errorMessages.add('More than one Construction Opportunity record found');
                        }
                    }
                    
                    // Work Order update
                    if (String.isNotBlank(payload.request.payload.constWOId)) {
                        Map<Id,WorkOrder> mapWO = new Map<Id,WorkOrder>([SELECT Id, OrderNumber__c FROM WorkOrder 
                                                                         WHERE Type__c = 'Construction' AND 
                                                                         Project__c = :payload.request.payload.objectId]);
                        if (mapWO.isEmpty())
                        {
                            body.statusCode = '403';
                            body.status = 'Fail';
                            errorMessages.add('No Construction WorkOrder record found for Project with ID ' + payload.request.payload.objectId);
                        }
                        else if (mapWO.size() == 1)
                        {
                            updateWorkOrder(sobjectsToUpdate, mapWO.values()[0], payload.request.payload.constWOId);
                        }
                        else {
                            body.statusCode = '403';
                            body.status = 'Fail';
                            errorMessages.add('More than one Construction WorkOrder record found');
                        }
                    }
                    
                    // Artefact update
                    if (String.isNotBlank(payload.request.payload.invoiceId)) {
                        Map<Id,Artefact__c> mapArtfact = new Map<Id,Artefact__c>([SELECT Id, InvoiceNumber__c FROM Artefact__c 
                                                                                  WHERE Project__c =: payload.request.payload.objectId 
                                                                                  AND RecordType.DeveloperName = 'Invoice']);
                        if (mapArtfact.isEmpty())
                        {
                            body.statusCode = '403';
                            body.status = 'Fail';
                            errorMessages.add('No Invoice record found for Project with ID ' + payload.request.payload.objectId);
                        }
                        else if (mapArtfact.size() == 1)
                        {
                            updateInvoice(sobjectsToUpdate, mapArtfact.values()[0], payload.request.payload.invoiceId);
                            // Create Integration Task
                            if (!hasExistingTask(mapArtfact.values()[0].Id, 'GetInvoice')) {
                                createIntTask(
                                    sobjectsToInsert,
                                    mapArtfact.values()[0],
                                    'Get',
                                    'Artefact__c',
                                    'GetInvoice',
                                    'Ready',
                                    Art_RTId
                                );
                            }
                        }
                        else {
                            body.statusCode = '403';
                            body.status = 'Fail';
                            errorMessages.add('More than one Invoice record found');
                        }
                    }
                    
                    if (body.status != 'Fail') {
                        Savepoint sp = Database.setSavepoint();
                        try {
                            if (!sobjectsToUpdate.isEmpty()) {
                                update sobjectsToUpdate;
                            }
                            if (!sobjectsToInsert.isEmpty()) {
                                insert sobjectsToInsert;
                            }
                            
                            body.statusCode = '200';
                            body.status = 'Success';
                            body.message = '';
                        } catch (Exception e) {
                            Database.rollback(sp);
                            
                            body.statusCode = '403';
                            body.status = 'Fail';
                            body.message = e.getMessage();
                        }
                    } else {
                        body.message = String.join(errorMessages, '; ');
                    }
                }
                else {
                    body.statusCode = '403';
                    body.status = 'Fail';
                    body.message = 'Bad Request: objectId not found';
                }
            }
            when 'Event.PMNotification_Update' {
                if (String.isNotBlank(payload.request.payload.sfrefno))
                {
                    if (String.isNotBlank(payload.request.payload.objectId)) {
                        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>([SELECT Id, Notification_Number__c FROM Opportunity 
                                                                              WHERE Project__c =: payload.request.payload.sfrefno
                                                                              AND Type = 'Construction']);
                        if (mapOpp.isEmpty())
                        {
                            body.statusCode = '403';
                            body.status = 'Fail';
                            body.message = 'No Opportunity record found';
                        }
                        else if (mapOpp.size() == 1)
                        {
                            
                            List<SObject> sobjectsToUpdate = new List<SObject>();
                            List<SObject> sobjectsToInsert = new List<SObject>();
                            // Update Opportunity
                            updateOpportunity(sobjectsToUpdate, mapOpp.values()[0], payload.request.payload.objectId);
                            // Create Integration Task
                            if (!hasExistingTask(mapOpp.values()[0].Id, 'GetConstNoti')) {
                                createIntTask(
                                    sobjectsToInsert,
                                    mapOpp.values()[0],
                                    'Get',
                                    'Opportunity',
                                    'GetConstNoti',
                                    'Ready',
                                    Opp_RTId
                                );
                            }
                            
                            Savepoint sp = Database.setSavepoint();
                            try {
                                if (!sobjectsToUpdate.isEmpty()) {
                                    update sobjectsToUpdate;
                                }
                                if (!sobjectsToInsert.isEmpty()) {
                                    insert sobjectsToInsert;
                                }
                                
                                body.statusCode = '200';
                                body.status = 'Success';
                                body.message = '';
                            } catch (Exception e) {
                                Database.rollback(sp);
                                
                                body.statusCode = '403';
                                body.status = 'Fail';
                                body.message = e.getMessage();
                            }
                        }
                        else {
                            body.statusCode = '403';
                            body.status = 'Fail';
                            body.message = 'More than one Opportunity record found';
                        }
                    }
                    else {
                        body.statusCode = '403';
                        body.status = 'Fail';
                        body.message = 'Bad Request: objectId not found';
                    }
                }
                else {
                    body.statusCode = '403';
                    body.status = 'Fail';
                    body.message = 'Bad Request: sfrefno not found';
                }
            }
            when 'Event.WorkOrder_Update' {
                if (String.isNotBlank(payload.request.payload.sfrefno)) 
                {   
                    if (String.isNotBlank(payload.request.payload.objectId)) {
                        Map<Id,WorkOrder> mapWO = new Map<Id,WorkOrder>([SELECT Id, OrderNumber__c FROM WorkOrder 
                                                                         WHERE Project__c =: payload.request.payload.sfrefno
                                                                         AND Type__c = 'Construction']);
                        if (mapWO.isEmpty())
                        {
                            body.statusCode = '403';
                            body.status = 'Fail';
                            body.message = 'No WorkOrder record found';
                        }
                        else if (mapWO.size() == 1)
                        {
                            
                            List<SObject> sobjectsToUpdate = new List<SObject>();
                            List<SObject> sobjectsToInsert = new List<SObject>();
                            // Update WorkOrder
                            updateWorkOrder(sobjectsToUpdate, mapWO.values()[0], payload.request.payload.objectId);
                            // Create Integration Task
                            if (!hasExistingTask(mapWO.values()[0].Id, 'GetConstWO')) {
                                createIntTask(
                                    sobjectsToInsert,
                                    mapWO.values()[0],
                                    'Get',
                                    'WorkOrder',
                                    'GetConstWO',
                                    'Ready',
                                    WO_RTId
                                );
                            }
                            
                            Savepoint sp = Database.setSavepoint();
                            try {
                                if (!sobjectsToUpdate.isEmpty()) {
                                    update sobjectsToUpdate;
                                }
                                if (!sobjectsToInsert.isEmpty()) {
                                    insert sobjectsToInsert;
                                }
                                
                                body.statusCode = '200';
                                body.status = 'Success';
                                body.message = '';
                            } catch (Exception e) {
                                Database.rollback(sp);
                                
                                body.statusCode = '403';
                                body.status = 'Fail';
                                body.message = e.getMessage();
                            }
                        }
                        else {
                            body.statusCode = '403';
                            body.status = 'Fail';
                            body.message = 'More than one WorkOrder record found';
                        }
                    }
                    else {
                        body.statusCode = '403';
                        body.status = 'Fail';
                        body.message = 'Bad Request: objectId not found';
                    }
                }
                else
                {
                    body.statusCode = '403';
                    body.status = 'Fail';
                    body.message = 'Bad Request: sfrefno not found';
                }
            }
            when 'Event.Invoice_Update' {
                if (String.isNotBlank(payload.request.payload.sfrefno))
                {
                    if (String.isNotBlank(payload.request.payload.objectId)) {
                        List<SObject> sobjectsToUpdate = new List<SObject>();
                        List<SObject> sobjectsToInsert = new List<SObject>();
                        if (isRecordId('Artefact__c', (Id)payload.request.payload.sfrefno)) {
                            Map<Id,Artefact__c> mapArte = new Map<Id,Artefact__c>([SELECT Id, InvoiceNumber__c FROM Artefact__c 
                                                                                   WHERE Id =: payload.request.payload.sfrefno 
                                                                                   AND RecordType.DeveloperName = 'Invoice']);
                            if (mapArte.isEmpty())
                            {
                                body.statusCode = '403';
                                body.status = 'Fail';
                                body.message = 'No Invoice record found';
                            }
                            else if (mapArte.size() == 1)
                            {
                                updateInvoice(sobjectsToUpdate, mapArte.values()[0], payload.request.payload.objectId);
                                // Create Integration Task
                                if (!hasExistingTask(mapArte.values()[0].Id, 'GetInvoice')) {
                                    createIntTask(
                                        sobjectsToInsert,
                                        mapArte.values()[0],
                                        'Get',
                                        'Artefact__c',
                                        'GetInvoice',
                                        'Ready',
                                        Art_RTId
                                    );
                                }
                                
                                Savepoint sp = Database.setSavepoint();
                                try {
                                    if (!sobjectsToUpdate.isEmpty()) {
                                        update sobjectsToUpdate;
                                    }
                                    if (!sobjectsToInsert.isEmpty()) {
                                        insert sobjectsToInsert;
                                    }
                                    
                                    body.statusCode = '200';
                                    body.status = 'Success';
                                    body.message = '';
                                } catch (Exception e) {
                                    Database.rollback(sp);
                                    
                                    body.statusCode = '403';
                                    body.status = 'Fail';
                                    body.message = e.getMessage();
                                }
                            }
                            else {
                                body.statusCode = '403';
                                body.status = 'Fail';
                                body.message = 'More than one Invoice record found';
                            }
                        }
                        else if (isRecordId('Project__c', (Id)payload.request.payload.sfrefno)) {
                            Map<Id,Artefact__c> mapArte = new Map<Id,Artefact__c>([SELECT Id, InvoiceNumber__c FROM Artefact__c 
                                                                                   WHERE Project__c =: payload.request.payload.sfrefno 
                                                                                   AND RecordType.DeveloperName = 'Invoice'
                                                                                   AND (InvoiceNumber__c =: payload.request.payload.objectId OR Source__c !=: TVE_RequestInvoiceUtility.SOURCE_SF_CLOUD)]);
                            List<Artefact__c> invoicesWithMatchedNumber = new List<Artefact__c>();
                            List<Artefact__c> invoicesWithoutNumber = new List<Artefact__c>();
                            for (Artefact__c inv : mapArte.values()) {
                                if (inv.InvoiceNumber__c == payload.request.payload.objectId) {
                                    invoicesWithMatchedNumber.add(inv);
                                }
                                if (String.isBlank(inv.InvoiceNumber__c)) {
                                    invoicesWithoutNumber.add(inv);
                                }
                            }
                            
                            if (invoicesWithMatchedNumber.isEmpty()) {
                                List<Project__c> projects = [SELECT Id, SalesOrder__c, ApplicantAccount__c, ApplicantContact__c FROM Project__c WHERE Id =: payload.request.payload.sfrefno LIMIT 1];
                                if (projects.isEmpty()) {
                                    body.statusCode = '403';
                                    body.status = 'Fail';
                                    body.message = 'No Project record found with ID ' + payload.request.payload.sfrefno;
                                }
                                else {
                                    // SAP-initiated Invoice is created
                                    if (invoicesWithoutNumber.isEmpty()) {
                                        updateProject(sobjectsToUpdate, projects[0], null, payload.request.payload.salesOrderId);
    
                                        createInvoice(sobjectsToInsert, projects[0], payload.request.payload.objectId);
                                        // Create Integration Task
                                        createIntTask(
                                            sobjectsToInsert,
                                            projects[0],// To be replaced
                                            'Get',
                                            'Artefact__c',
                                            'GetInvoice',
                                            'Ready',
                                            Art_RTId
                                        );
                                    }
                                    // Initial Invoice is created for non-auto scenarios
                                    else if (invoicesWithoutNumber.size() == 1) {
                                        updateProject(sobjectsToUpdate, projects[0], null, payload.request.payload.salesOrderId);
        
                                        updateInvoice(sobjectsToUpdate, invoicesWithoutNumber[0], payload.request.payload.objectId);
                                        // Create Integration Task
                                        if (!hasExistingTask(invoicesWithoutNumber[0].Id, 'GetInvoice')) {
                                            createIntTask(
                                                sobjectsToInsert,
                                                invoicesWithoutNumber[0],
                                                'Get',
                                                'Artefact__c',
                                                'GetInvoice',
                                                'Ready',
                                                Art_RTId
                                            );
                                        }
                                    }
                                    // Should not happen ideally
                                    else {
                                        body.statusCode = '403';
                                        body.status = 'Fail';
                                        body.message = 'More than one Invoice record found without Invoice number';
                                    }
                                }
                            }
                            // Integrated Invoice is updated in SAP
                            else if (invoicesWithMatchedNumber.size() == 1) {
                                // Create Integration Task
                                if (!hasExistingTask(invoicesWithMatchedNumber[0].Id, 'GetInvoice')) {
                                    createIntTask(
                                        sobjectsToInsert,
                                        invoicesWithMatchedNumber[0],
                                        'Get',
                                        'Artefact__c',
                                        'GetInvoice',
                                        'Ready',
                                        Art_RTId
                                    );
                                }
                            }
                            else {
                                body.statusCode = '403';
                                body.status = 'Fail';
                                body.message = 'More than one Invoice record found with number ' + payload.request.payload.objectId;
                            }

                            if (body.status != 'Fail') {
                                Savepoint sp = Database.setSavepoint();
                                try {
                                    if (!sobjectsToUpdate.isEmpty()) {
                                        update sobjectsToUpdate;
                                    }
                                    if (sobjectsToInsert.size() == 1) {
                                        insert sobjectsToInsert;
                                    } else if (sobjectsToInsert.size() == 2) {
                                        //Update Integration_Task__c.ParentId__c with inserted Artefact__c
                                        Artefact__c inv;
                                        Integration_Task__c task;
                                        if (sobjectsToInsert[0].getSObjectType() == Artefact__c.SObjectType) {
                                            inv = (Artefact__c)sobjectsToInsert[0];
                                            task = (Integration_Task__c)sobjectsToInsert[1];
                                        } else {
                                            inv = (Artefact__c)sobjectsToInsert[1];
                                            task = (Integration_Task__c)sobjectsToInsert[0];
                                        }
                                        insert inv;
                                        task.ParentId__c = inv.Id;
                                        insert task;
                                    }
                                    
                                    body.statusCode = '200';
                                    body.status = 'Success';
                                    body.message = '';
                                } catch (Exception e) {
                                    Database.rollback(sp);
                                    
                                    body.statusCode = '403';
                                    body.status = 'Fail';
                                    body.message = e.getMessage();
                                }
                            }
                        }
                        else {
                            body.statusCode = '403';
                            body.status = 'Fail';
                            body.message = 'Bad Request: invalid sfrefno';
                        }
                    }
                    else {
                        body.statusCode = '403';
                        body.status = 'Fail';
                        body.message = 'Bad Request: objectId not found';
                    }
                }
                else {
                    body.statusCode = '403';
                    body.status = 'Fail';
                    body.message = 'Bad Request: sfrefno not found';
                }
            }
            when 'Event.CMArtefact_Create' {
                if (String.isNotBlank(payload.request.payload.objectId)) {
                    Map<String,Project__c> mapProj = new Map<String,Project__c>();
                    for(Project__c proj : [SELECT CMNumber__c FROM Project__c WHERE CMNumber__c =: payload.request.payload.cmNum]) {
                        mapProj.put(proj.CMNumber__c,proj);
                    }
                    Map<String,TVE_File_Classification_Mapping__mdt> mapDocumentType = new Map<String,TVE_File_Classification_Mapping__mdt>();
                    for(TVE_File_Classification_Mapping__mdt mdt : [SELECT Id,DocumentType__c,Classification__c FROM TVE_File_Classification_Mapping__mdt
                                                                    WHERE DocumentType__c =: payload.request.payload.docId])
                    {
                        mapDocumentType.put(mdt.DocumentType__c,mdt);
                    }
                    
                    Artefact__c saparte = new Artefact__c();
                    saparte.Source__c = SOURCE_SAP;
                    saparte.Classification__c = mapDocumentType.get(payload.request.payload.docId).Classification__c;
                    saparte.Name = payload.request.payload.fileName;
                    saparte.SAPNumber__c = payload.request.payload.objectId;
                    saparte.Project__c = mapProj.get(payload.request.payload.cmNum).Id;
                    insert saparte;
                    
                    Map<Id,String> creatIntTaskMapKey = new Map<Id,String>();
                    Map<String,String> creatIntTaskMap = new Map<String,String>();
                    creatIntTaskMapKey.put(saparte.Id, saparte.Id);
                    creatIntTaskMap.put('Operation__c', 'Get');
                    creatIntTaskMap.put('SObject__c', 'Artefact__c');
                    creatIntTaskMap.put('Type__c', 'GetCMArtefact');
                    creatIntTaskMap.put('Status__c', 'Ready');
                    creatIntTaskMap.put('RecordTypeID', Art_RTId);
                    TVE_IntegUtility.CreateInteTask(creatIntTaskMapKey, creatIntTaskMap);
                    
                    body.statusCode = '200';
                    body.status = 'Success';
                    body.message = '';
                }
                else {
                    body.statusCode = '403';
                    body.status = 'Fail';
                    body.message = 'No Artefact record found';
                }
            }
            when else {
                body.statusCode = '404';
                body.status = 'Fail';
                body.message = 'Bad Request';
            }
        }
        return body;
    }
    
    private static void updateProject(List<SObject> sobjectsToUpdate, Project__c proj, String cmNum, String soNum) {
        if (proj != null) {
            if (
                (String.isNotBlank(cmNum) && String.isBlank(proj.CMNumber__c))
                ||
                (String.isNotBlank(soNum) && String.isBlank(proj.SalesOrder__c))
            ) {
                if (String.isNotBlank(cmNum) && String.isBlank(proj.CMNumber__c)) {
                    proj.CMNumber__c = cmNum;
                }
                if (String.isNotBlank(soNum) && String.isBlank(proj.SalesOrder__c)) {
                    proj.SalesOrder__c = soNum;
                }
                sobjectsToUpdate.add(proj);
            }
        }
    }
    
    private static void updateOpportunity(List<SObject> sobjectsToUpdate, Opportunity opp, String notiNum) {
        if (opp != null) {
            if (String.isBlank(opp.Notification_Number__c)) {
                opp.Notification_Number__c = notiNum;
                sobjectsToUpdate.add(opp);
            }
        }
    }
    
    private static void updateWorkOrder(List<SObject> sobjectsToUpdate, WorkOrder wo, String woNum) {
        if (wo != null) {
            if (String.isBlank(wo.OrderNumber__c)) {
                wo.OrderNumber__c = woNum;
                sobjectsToUpdate.add(wo);
            }
        }
    }
    
    private static void updateInvoice(List<SObject> sobjectsToUpdate, Artefact__c inv, String invNum) {
        if (inv != null) {
            if (String.isBlank(inv.InvoiceNumber__c)) {
                inv.InvoiceNumber__c = invNum;
                sobjectsToUpdate.add(inv);
            }
        }
    }
    
    private static void createInvoice(List<SObject> sobjectsToInsert, Project__c proj, String invNum) {
        Artefact__c inv = new Artefact__c(
            Project__c = proj.Id,
            Classification__c = TVE_RequestInvoiceUtility.CLASSIFICATION_INVOICE,
            RecordTypeId = Artefact_Invoice_RT_Id,
            Payer__c = proj.ApplicantContact__c,
            Account__c = proj.ApplicantAccount__c,
            Source__c = SOURCE_SAP,
            Status__c = 'Pending Payment',
            InvoiceNumber__c = invNum
        );
        sobjectsToInsert.add(inv);
    }
    
    private static void createIntTask(
        List<SObject> sobjectsToInsert,
        SObject parent,
        String operation,
        String objectName,
        String type,
        String status,
        String recordTypeId
    ) {
        if (parent != null) {
            Map<Id,String> creatIntTaskMapKey = new Map<Id,String>();
            Map<String,String> creatIntTaskMap = new Map<String,String>();
            creatIntTaskMapKey.put(parent.Id,parent.Id);
            creatIntTaskMap.put('Operation__c',operation);
            creatIntTaskMap.put('SObject__c',objectName);
            creatIntTaskMap.put('Type__c',type);
            creatIntTaskMap.put('Status__c',status);
            creatIntTaskMap.put('RecordTypeID',recordTypeId);
            sobjectsToInsert.addAll(TVE_IntegUtility.prepareIntTask(creatIntTaskMapKey,creatIntTaskMap));
        }
    }
    
    private static Boolean isRecordId(String objectName, Id recordId) {
        return Schema.getGlobalDescribe().get(objectName) == recordId.getSobjectType();
    }

    private static Boolean hasExistingTask(String parentId, String type) {
        List<Integration_Task__c> taskList = [SELECT Id FROM Integration_Task__c
                                              WHERE ParentId__c =: parentId AND Type__c =: type
                                              AND (Status__c = 'Ready' OR Status__c = 'In Progress')];
        return !taskList.isEmpty();
    }
}