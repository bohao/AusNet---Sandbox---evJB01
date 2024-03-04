/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 13 Jan 2020
  @Description : TVE Class for Utility methods Artefact Object 
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  11 March             Lakshay Sharma
  08 May               Prateek Gupta                  Updated method "UpdateOwner" for defect TV-3203
                                                      & TV-3066                             
  -----------------------------------------------------------------------------------------
*/

public without sharing class TVE_Artefact_Util {
    public static ID invoiceRecordType = Schema.SObjectType.Artefact__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
    public static ID contractRecordType = Schema.SObjectType.Artefact__c.getRecordTypeInfosByName().get('Contract').getRecordTypeId();
    public static ID offerRecordType=Schema.SObjectType.Artefact__c.getRecordTypeInfosByName().get('Offer').getRecordTypeId();
    public static String AssignmentStatus='Payment Pending';
    public static String AssignmentStatusnew='Triage';
    public static String QueueName='AST Program Coordinators';
        
    
    public static ID IntgnTaskRecType=Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByName().get('Artefact').getRecordTypeId();  
    // Called from before insert and before update event of Artefact trigger
    public static void PopulateAccount(Map<Id, Artefact__c> mapValidRecords)
    {        
        List<Id> projIds = new List<Id>();
        if(!mapValidRecords.isEmpty())
        {
            for(Artefact__c artfctItem : mapValidRecords.values())
            {
                if(artfctItem.Project__c != null)
                {
                    projIds.add(artfctItem.Project__c);
                }
            }

            Map<Id, Map<String, String>> mapBillToSoldTo = TVE_IntegUtility.getSoldToBillTO(projIds);
            Map<Id, Project__c> mapProj = new Map<Id, Project__c>([SELECT Id, ApplicantAccount__c FROM Project__c WHERE Id IN: projIds]);

            for(Artefact__c artfctItem : mapValidRecords.values()) {
                if(artfctItem.RecordTypeId == invoiceRecordType) {
                    if(
                        artfctItem.Account__c == null
                        &&
                        mapBillToSoldTo.containsKey(artfctItem.Project__c)
                        &&
                        mapBillToSoldTo.get(artfctItem.Project__c).containsKey('billtoAcctId')
                    ) {
                        artfctItem.Account__c = mapBillToSoldTo.get(artfctItem.Project__c).get('billtoAcctId');
                    }
                    if(
                        artfctItem.Payer__c == null
                        &&
                        mapBillToSoldTo.containsKey(artfctItem.Project__c)
                        &&
                        mapBillToSoldTo.get(artfctItem.Project__c).containsKey('billtoContId')
                    ) {
                        artfctItem.Payer__c = mapBillToSoldTo.get(artfctItem.Project__c).get('billtoContId');
                    }
                } else {
                    if(artfctItem.Account__c == null && mapProj.containsKey(artfctItem.Project__c)) {
                        artfctItem.Account__c = mapProj.get(artfctItem.Project__c).ApplicantAccount__c;
                    }
                }
            }
        }
    }

    // Called from before insert and before update event of Artefact trigger
    public static void PopulateRecordTypeId(Map<Id, Artefact__c> mapValidRecords)
    {
        List<TVE_File_Classification_Mapping__mdt> lstMapping = new List<TVE_File_Classification_Mapping__mdt>([SELECT Id, 
                                                                                                                        Classification__c,
                                                                                                                        Record_Type_DeveloperName__c
                                                                                                                FROM TVE_File_Classification_Mapping__mdt
                                                                                                                WHERE Classification__c <> null
                                                                                                                  AND Classification__c <> ''
                                                                                                                  AND Record_Type_DeveloperName__c <> null
                                                                                                                  AND Record_Type_DeveloperName__c <> ''
                                                                                                                ]);
        Map<String, Id> mapClassificationRTId = new Map<String, Id>();
        Map<String, Id> mapRTNameId = UtilDatabase.getRecordTypeNames('Artefact__c');

        if(lstMapping.isEmpty())
        {
            throw new TVE_ConfigurationException('No valid records found for custom metadata API named TVE_File_Classification_Mapping__mdt');
        }
        else 
        {
            for(TVE_File_Classification_Mapping__mdt item: lstMapping)
            {
                mapClassificationRTId.put(item.Classification__c, mapRTNameId.get(item.Record_Type_DeveloperName__c));
            }

            if(!mapValidRecords.isEmpty())
            {
                Artefact__c artfct;
                for(Id artfctId : mapValidRecords.keySet())
                {
                    artfct = mapValidRecords.get(artfctId);
                    artfct.RecordTypeId = mapClassificationRTId.get(artfct.Classification__c);
                }
            }
        }        
    }
    public static void DueDatePopup(List<Artefact__c> ValidRecords)
    {
        Map<id,id>articleProjectIdMap=new map<id,id>();
        Map<Id, List<Artefact__c>> prjIdArtIdMap = new Map<Id, List<Artefact__c>>();
        List<project__c> projectListToUpdate = new List<project__c>();
        for(Artefact__c item:ValidRecords){
            if(item.Project__c!=null){			
                articleProjectIdMap.put(item.id,item.project__c);
                
                List<Artefact__c> lstArt = new List<Artefact__c>();
                if(prjIdArtIdMap.containsKey(item.Project__c))
                {
                    lstArt = prjIdArtIdMap.get(item.Project__c);
                    lstArt.add(item);
                    prjIdArtIdMap.put(item.Project__c, lstArt);    
                }else 
                {
                    prjIdArtIdMap.put(item.Project__c, new List<Artefact__c>{item});    
                }
                
            }
            
        }


        List<Project__c> lstPrg = new List<Project__c>([SELECT Id, InvoiceDueDate__c, ContractDueDate__c, 
                                                                PreliminaryOfferDueDate__c, FirmOfferDueDate__c
                                                        FROM Project__c
                                                        WHERE Id IN: articleProjectIdMap.values()]);

        for(Project__c projItem: lstPrg){
            for(Artefact__c artItem: prjIdArtIdMap.get(projItem.Id)){
                if(artItem.Status__c=='Pending Payment' && artItem.RecordTypeId==invoiceRecordType ){
                    projItem.InvoiceDueDate__c=artItem.DueDate__c;
                }
                if(artItem.RecordTypeId==contractRecordType ){
                    projItem.ContractDueDate__c= artItem.DueDate__c;
                }
                if (artItem.RecordTypeId==offerRecordType && artItem.Classification__c=='Prelim Estimate'){
                    
                    projItem.PreliminaryOfferDueDate__c = artItem.DueDate__c;
                }
                if (artItem.RecordTypeId==offerRecordType && artItem.Classification__c=='Firm Offer Letter'){
                    
                    projItem.FirmOfferDueDate__c  = artItem.DueDate__c;
                }
            }
            projectListToUpdate.add(projItem);
        }

        
        if(!projectListToUpdate.isEmpty()){
            update projectListToUpdate;
        }
        
    }
    public static void EPaymentLinkPopup(List<Artefact__c> ValidRecords)
    {
        Map<Id, Project__c> projectsToUpdate = new Map<Id, Project__c>();

        for(Artefact__c arte : ValidRecords) {
            if(arte.Project__c != null) {
                if(!projectsToUpdate.containsKey(arte.Project__c)) {
                    projectsToUpdate.put(
                        arte.Project__c,
                        new Project__c(
                            Id = arte.Project__c,
                            ElectronicPaymentLink__c = arte.Electronic_Payment_Link__c
                        )
                    );
                }
            }
        }
        
        if(!projectsToUpdate.isEmpty()) {
            update projectsToUpdate.values();
        }
    }
    
    public static void DeleteRelatedFile(List<Id> ValidRecords)
    {
        system.debug('ValidRecords++'+ValidRecords);
        list<id> contentDocId = new list<id>();
        List<ContentDocumentLink> lstConDocLink = [SELECT ContentDocumentId, LinkedEntityId 
                                                       FROM ContentDocumentLink 
                                                       WHERE LinkedEntityId IN :ValidRecords];
        if(lstConDocLink !=null){
            Database.delete(lstConDocLink);
        }
    }
    
    //added by Neha for TV-1200
    public static void SendArteToSap_NonInvoice(List<Artefact__c> artList)
    {
        String IntTaskRTId = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByDeveloperName().get('Artefact').getRecordTypeId();
        Map<Id,String> recordMap= new Map<Id,String>();
         Map<String,String> creatIntTaskMap = new  Map<String,String>();
        
        for(Artefact__c art:artList) 
                recordMap.put(art.id,art.id);
             	 
                creatIntTaskMap.put('SObject__c','Artefact__c');
                creatIntTaskMap.put('Type__c','CreateArtefact');
                creatIntTaskMap.put('Status__c','Ready');
             	creatIntTaskMap.put('Operation__c','Create');
             	creatIntTaskMap.put('RecordTypeID',IntTaskRTId);
             
              TVE_IntegUtility.CreateInteTask(recordMap,creatIntTaskMap);
    }

    public static void UpdateOwner(List<Id> ParentId)
    {
        system.debug('ParentRecordIds++'+ParentId);
        // List<Artefact__c> ArtefactforRelatedParents = new List<Artefact__c>();
        List<Project__c> ProjectListForUpdate=new List<Project__c>();
        Map<Id,List<Artefact__c>> ProjectArtefactMap = new Map<Id,List<Artefact__c>>();      
        List<Group> queueOwner = new List<Group>([SELECT Id, Type FROM Group WHERE Type = 'Queue' AND Name =:QueueName]);
  
        List<Artefact__c> ArtefactforRelatedParents = [SELECT Id,InvoicePaidDate__c,Project__r.ProjectAssigmentStatus__c,Project__r.WorkCode__c,Project__r.ApplicantLicenseAllocation__c 
                                                       FROM Artefact__c 
                                                       WHERE Project__c IN :ParentId and RecordTypeId=:invoiceRecordType];
        
        List<Artefact__c> listArti=new List<Artefact__c>();
        for(Artefact__c art: ArtefactforRelatedParents){
            if(ProjectArtefactMap.containskey(art.Project__c)){
                listArti = ProjectArtefactMap.get(art.Project__c);
                listArti.add(art);
                ProjectArtefactMap.put(art.Project__c,listArti);
            }else{
                ProjectArtefactMap.put(art.Project__c,new List<Artefact__c>{art});
            }
            
        }
        Project__c proj;
     for(Id key:ProjectArtefactMap.keySet()){
         
        if(ProjectArtefactMap.get(Key).size()==1 
        && ProjectArtefactMap.get(key)[0].InvoicePaidDate__c != null
        && ProjectArtefactMap.get(key)[0].Project__r.ProjectAssigmentStatus__c ==AssignmentStatus){
            proj=new Project__c();
            proj.Id=key;
            proj.OwnerId= queueOwner[0].Id;
            proj.ProjectAssigmentStatus__c=AssignmentStatusnew;
            if(ProjectArtefactMap.get(key)[0].Project__r.ApplicantLicenseAllocation__c == 'Unregistered Community User' 
            && ProjectArtefactMap.get(key)[0].Project__r.WorkCode__c != '1013')
                proj.TriageDescription__c = 'Pending Registration';
            ProjectListForUpdate.add(proj);
        }
     }
     if(!ProjectListForUpdate.isEmpty())
     {
        update ProjectListForUpdate;

     }  
     
    }
    
    public static void RequestInvoiceInteg(List<Artefact__c> ValidRecords){
        System.debug('-----Inside RequestInvoiceInteg-----'+ValidRecords);

        List<Integration_Task__c> IntgnTskList = new List<Integration_Task__c>();
        for(Artefact__c atfct: ValidRecords){
            Integration_Task__c IntgnTsk = new Integration_Task__c();
            IntgnTsk.Operation__c = 'GET';
            IntgnTsk.SObject__c = 'Artefact__c';
            IntgnTsk.ParentId__c = atfct.Id;
            IntgnTsk.Type__c  = 'RequestInvoice';
            IntgnTsk.Status__c  = 'Ready';
            IntgnTsk.RecordTypeId = IntgnTaskRecType;
            IntgnTskList.add(IntgnTsk);
        }
        System.debug('-------After Integration task list insertion------'+IntgnTskList);
        if(!IntgnTskList.isEmpty()){
            System.System.debug('intngnList task list is not empty'+IntgnTskList);
            insert IntgnTskList;
        }
    }
}