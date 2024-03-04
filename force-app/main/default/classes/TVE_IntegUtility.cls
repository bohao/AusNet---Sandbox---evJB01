public class TVE_IntegUtility {
    //method to get the integration task
    @TestVisible private static InvoiceHeaderSets__x mockedInvHead = new InvoiceHeaderSets__x();
    @TestVisible private static ConstructionMeasureSets__x mockedConstMeasure = new ConstructionMeasureSets__x();
    @TestVisible private static AttachmentSets__x mockedArt = new AttachmentSets__x();
    public static List<Integration_Task__c> getIntegrationTask(String operation,String SObjectname,String Type,String Status)
    {
        List<Integration_Task__c> ret = new List<Integration_Task__c>();
        List<Integration_Task__c> lstIntgTask = new List<Integration_Task__c>([SELECT Id, Status__c,ParentId__c
                                                                               FROM Integration_Task__c
                                                                               WHERE Operation__c =:operation
                                                                               AND SObject__c =:SObjectname
                                                                               AND Type__c =:Type
                                                                               AND Status__c =:Status]);
        if(Type=='CreateMasterNoti' && lstIntgTask.size()>33) {
            for(Integer i = 0; i < 33; i++) {
                ret.add(lstIntgTask.get(i));
            }
        } else if(Type=='CreateArtefact' && lstIntgTask.size()>1) {
            for(Integer i = 0; i < 1; i++) {
                ret.add(lstIntgTask.get(i));
            }
        } else if(Type=='GetCMArtefact' && lstIntgTask.size()>1) {
            for(Integer i = 0; i < 1; i++) {
                ret.add(lstIntgTask.get(i));
            }
        } else if(Type=='GetInvoice' && lstIntgTask.size()>5) {
            for(Integer i = 0; i < 5; i++) {
                ret.add(lstIntgTask.get(i));
            }
        } else if(Type=='GetCM' && lstIntgTask.size()>10) {
            for(Integer i = 0; i < 10; i++) {
                ret.add(lstIntgTask.get(i));
            }
        } else if(lstIntgTask.size()>100) {
            for(Integer i = 0; i < 100; i++) {
                ret.add(lstIntgTask.get(i));
            }
        } else {
            ret = lstIntgTask;
        }
        
        return ret;
    }
        
    //method to get Project__c
    public static List<Project__c> getProject(List<id> projIdList)
    {
        List<Project__c> lstProject=[select id,ProjectName__c,PropertyAccessInstructions__c,HazardDetails__c,
                                  FunctionalLocation__c,EstimatedCompletionDate__c,
                                  SiteOwner__c,SiteOwner__r.SAPCustomer__c ,ApplicationType__c,	PaymentReferenceNumber__c,IsPropertyOwner__c,
                                  AuthorisedRepresentative__c,AuthorisedRepresentative__r.SAPCustomer__c,OwnerID,CMNumber__c,
                                  ProjectAssignee__c,ContestabilityType__c,Subdivision__c,PlaningPermitNumber__c,
                                  SpearReferenceNumber__c,SubdivisionPlanNumber__c,OfferType__c,WorkCode__c,
                                  CUDesignTemplate__c,MaterialBillingCode1__c,
                                  MaterialBillingCode2__c,PaymentAmount__c,ProjectAssignee__r.SAP_ID__c,ProjectAssignee__r.Employee_ID__c,
                                  SiteOwner__r.BillingStreet,SiteOwner__r.FirstName,SiteOwner__r.LastName,
                                  SiteOwner__r.Name,SiteOwner__r.PersonMailingStreet,
                                  PropertyOwnerContact__r.Email,
                                  PropertyOwnerContact__r.MobilePhone,
                                  AuthorizedRepresentativeContact__r.Email,
                                  AuthorizedRepresentativeContact__r.Phone,
                                  AuthorizedRepresentativeContact__r.MobilePhone,
                                  AuthorisedRepresentative__r.BillingStreet,AuthorisedRepresentative__r.FirstName,
                                  AuthorisedRepresentative__r.LastName,AuthorisedRepresentative__r.Name,
                                  AuthorisedRepresentative__r.PersonMailingStreet,SiteOwner__r.isPersonAccount,
                                  AuthorisedRepresentative__r.isPersonAccount,CMType__c,ProposedTargetDate__c,
                                  PaymentAmountExGST__c,SAPStatus__c//Updated by JTan on 21/04/2020 for TV-2898
                                  from Project__c where ID IN:projIdList];
        return lstProject;
    }
    
    /*Method name:UpdateInteTask
* Input paramter:1) recordMap-- This map will contain key= Integration task id and 
* 													value= success or error message(it can be any string like'success'or 'error')
* 				 2)updateIntTaskMap-- This map will contain key=Api name of Integration task object fields
* 													value= field value which need to be updated
*/
    public static void UpdateInteTask(Map<Id,String> recordMap,map<String,String> updateIntTaskMap){
        Integration_Task__c intgTask;
        List<Integration_Task__c> intgTaskList = new List<Integration_Task__c>();
        for (Id key : recordMap.keySet()) {
            intgTask = new Integration_Task__c();
            intgTask.id=key;
            if(updateIntTaskMap.containsKey('Status__c'))
                intgTask.Status__c =updateIntTaskMap.get('Status__c');
            
            intgTaskList.add(intgTask);
        }
        if(intgTaskList.size()>0)
            update intgTaskList;
    }
    /*Method name:createIntegLog
* Input paramter:1) recordMap-- This map will contain key= Integration task id and 
* 													value= success or error message(it can be any string like'success'or 'error')
* 				 2)updateIntTaskMap-- This map will contain key=Api name of Integration task object fields
* 													value= field value which need to be created.
									 Also add one extra attribute to indetify whether it is get or post
*/
    public static void createIntegLog(Map<Id,String> recordMap, map<String,String> createIntglogmap){
        Integration_Log__c intgLog;
        List<Integration_Log__c> intgLogList = new List<Integration_Log__c>();
        
        if(!createIntglogmap.containsKey('Get'))
            createIntglogmap.put('Post','Post');
        
        for (Id key : recordMap.keySet()) {
            intgLog = new Integration_Log__c();
            if(createIntglogmap.containsKey('Get'))
            	intgLog.Transaction_ID__c=TVE_Utility.getUniqueId(key);
            intgLog.Integration_Task__c = key;
            if(createIntglogmap.containsKey('Status__c'))
            {
                intgLog.Status__c =createIntglogmap.get('Status__c');
                if(createIntglogmap.get('Status__c')=='Failed')
                    intgLog.Error_Message__c=recordMap.get(key);
            }
            
            intgLogList.add(intgLog);
        }
        if(intgLogList.size()>0)
            insert intgLogList;
        
    }
    
    /*Method name:CreateInteTask
* Input paramter:1) recordMap-- This map will contain key= Parent record id and 
* 													value= success or error message(it can be any string like'success'or 'error')
* 				 2)updateIntTaskMap-- This map will contain key=Api name of Integration task object fields
* 													value= field value which need to be created
*/
    
    public static void CreateInteTask(Map<Id,String> recordMap,Map<String,String> creatIntTaskMap){
        List<Integration_Task__c> intgTaskList = prepareIntTask(recordMap, creatIntTaskMap);
        if(!intgTaskList.isEmpty())
            insert intgTaskList;
    }

    public static List<Integration_Task__c> prepareIntTask(Map<Id,String> recordMap,Map<String,String> creatIntTaskMap){
        List<Integration_Task__c> intgTaskList = new List<Integration_Task__c>();
        for (Id key : recordMap.keySet()) {
            Integration_Task__c intgTask = new Integration_Task__c();
            if(creatIntTaskMap.containsKey('SObject__c'))
                intgTask.SObject__c = creatIntTaskMap.get('SObject__c');
            if(creatIntTaskMap.containsKey('Type__c'))
                intgTask.Type__c = creatIntTaskMap.get('Type__c');
            if(creatIntTaskMap.containsKey('Status__c'))
                intgTask.Status__c = creatIntTaskMap.get('Status__c');
            if(creatIntTaskMap.containsKey('Operation__c'))
                intgTask.Operation__c = creatIntTaskMap.get('Operation__c');
            if(creatIntTaskMap.containsKey('RecordTypeID'))
                intgTask.RecordTypeID = creatIntTaskMap.get('RecordTypeID');
            intgTask.ParentId__c = recordMap.get(key);
            intgTaskList.add(intgTask);
        }
        return intgTaskList;
    }
    
    public static List<Database.SaveResult> updateOpp(List<Id> oppIds, Map<Id,String> oppNotinumberMap){
        List<Opportunity> oppList= new List<Opportunity>();
        for(Id oppId : oppIds){
            oppList.add(
                new Opportunity(
                    Id = oppId,
                    Notification_Number__c=oppNotinumberMap.get(oppId)
                )
            );
        }
        List<Database.SaveResult> srList = Database.update(oppList, false);
        return srList;
    }
    
    public static String checkString(String val){
        String val1='';
        if(val!=null)
            return val;
        else
            return val1;
    }
    
    public static Map<id,Map<String,string>> getSoldToBillTO(List<id>  listProjId){
        Map<id,Map<String,string>> BillToSoldToMap = new Map<id,Map<String,string>>();
        
        System.debug('Bill to sold to '+listProjId);
        String siteOwner;
        
        if(listProjId.size()>0)
        {
            List<Project__c> lstProj=getProject(listProjId);
            
            for(Project__c proj:lstProj)
            {
                System.debug('Site ownwer 11111111'+proj.SiteOwner__r.SAPCustomer__c);
                
                if((proj.ApplicationType__c=='Residential' || 
                    proj.ApplicationType__c=='Commercial, Business and Industrial' || 
                    proj.ApplicationType__c=='New Estate') &&
                    proj.SiteOwner__c!=null)
                {   
                    BillToSoldToMap.put(proj.Id, commonBillToSoldToLogic(proj));
                }
                else if(proj.ApplicationType__c=='Public Lighting' ||
                         proj.ApplicationType__c=='Private Mains in Public Land' || 
                         proj.ApplicationType__c=='Relocation, alteration or removal of an asset')                                             
                {
                    // System.debug('Authorized 222222'+TVE_IntegUtility.checkString(proj.AuthorisedRepresentative__c));
                    Map<String,string> BSMap = new Map<String,String>();
                    if(proj.SiteOwner__c == null && proj.AuthorisedRepresentative__c != null)
                    {
                        BSMap.put('BillTo',TVE_IntegUtility.checkString(proj.AuthorisedRepresentative__r.SAPCustomer__c));
                        BSMap.putAll(getBillToinfo(proj,'AuthRep'));
                        BSMap.put('SoldTo',TVE_IntegUtility.checkString(proj.AuthorisedRepresentative__r.SAPCustomer__c));
                        BSMap.putAll(getSoldToinfo(proj,'AuthRep'));
                        BillToSoldToMap.put(proj.Id,BSMap);
                    }
                    else if(proj.SiteOwner__c != null && proj.AuthorisedRepresentative__c == null)
                    {
                        BSMap.put('BillTo',TVE_IntegUtility.checkString(proj.SiteOwner__r.SAPCustomer__c));
                        BSMap.putAll(getBillToinfo(proj,'SiteOwner'));
                        BSMap.put('SoldTo',TVE_IntegUtility.checkString(proj.SiteOwner__r.SAPCustomer__c));
                        BSMap.putAll(getSoldToinfo(proj,'SiteOwner'));            
                        BillToSoldToMap.put(proj.Id,BSMap);

                    }else if(proj.SiteOwner__c != null && proj.AuthorisedRepresentative__c != null)
                    {
                        BillToSoldToMap.put(proj.Id, commonBillToSoldToLogic(proj));
                    }
                    else if(proj.SiteOwner__c == null && proj.AuthorisedRepresentative__c == null)
                    {
                        //THIS IS UNEXPECTED SCENARIO AND CREATE WORK INTEGRATION IS EXPECTED TO FAIL HERE
                        System.debug('getSoldToBillTO---->THIS IS UNEXPECTED SCENARIO AND CREATE WORK INTEGRATION IS EXPECTED TO FAIL HERE');
                    }
                }
                
            }
        }
        return BillToSoldToMap;
    }

    //TV-2595
    public static Map<String,String> commonBillToSoldToLogic(Project__c proj)
    {
        Map<String,String> BSMap = new Map<String,String>();

        //----------------------------------------//
        //----------------PAYNOW------------------//
        //----------------------------------------//

        if(proj.PaymentReferenceNumber__c!=null)
        {
            if(proj.IsPropertyOwner__c=='Yes')
            {
                BSMap.put('BillTo',TVE_IntegUtility.checkString(proj.SiteOwner__r.SAPCustomer__c));
                BSMap.putAll(getBillToinfo(proj,'SiteOwner'));
                BSMap.put('SoldTo',TVE_IntegUtility.checkString(proj.SiteOwner__r.SAPCustomer__c));
                BSMap.putAll(getSoldToinfo(proj,'SiteOwner'));
            }
            else
            {
                BSMap.put('BillTo',TVE_IntegUtility.checkString(proj.AuthorisedRepresentative__r.SAPCustomer__c));
                BSMap.putAll(getBillToinfo(proj,'AuthRep'));
                BSMap.put('SoldTo',TVE_IntegUtility.checkString(proj.SiteOwner__r.SAPCustomer__c));
                BSMap.putAll(getSoldToinfo(proj,'SiteOwner'));
            }
        }
        //----------------------------------------//
        //-------------PAYLATER-------------------//
        //----------------------------------------//
        else
        {
            BSMap.put('BillTo',TVE_IntegUtility.checkString(proj.SiteOwner__r.SAPCustomer__c));
            BSMap.putAll(getBillToinfo(proj,'SiteOwner'));
            BSMap.put('SoldTo',TVE_IntegUtility.checkString(proj.SiteOwner__r.SAPCustomer__c));
            BSMap.putAll(getSoldToinfo(proj,'SiteOwner'));
        }
        return BSMap;
    }

    public static String getContesabilityOutbound(String contesabiltyshort){
        String contesabiltyfull;
        if(contesabiltyshort!=null){
            if(contesabiltyshort=='EDEC'){
                contesabiltyfull = 'EXTERNAL DESIGN EXTERNAL CONST';
            } else if(contesabiltyshort=='EDIC'){
                contesabiltyfull = 'EXTERNAL DESIGN INTERNAL CONST';
            } else if(contesabiltyshort=='IDEC'){
                contesabiltyfull = 'INTERNAL DESIGN EXTERNAL CONST';
            } else if(contesabiltyshort=='IDIC'){
                contesabiltyfull = 'INTERNAL DESIGN INTERNAL CONST';
            }
        } else {
            contesabiltyfull = '';
        }
        return contesabiltyfull;
    }

    public static String getContesabilityInbound(String contesabiltyfull){
        String contesabiltyshort;
        if(String.isNotBlank(contesabiltyfull)){
            if(contesabiltyfull=='EXTERNAL DESIGN EXTERNAL CONST'){
                contesabiltyshort = 'EDEC';
            } else if(contesabiltyfull=='EXTERNAL DESIGN INTERNAL CONST'){
                contesabiltyshort = 'EDIC';
            } else if(contesabiltyfull=='INTERNAL DESIGN EXTERNAL CONST'){
                contesabiltyshort = 'IDEC';
            } else if(contesabiltyfull=='INTERNAL DESIGN INTERNAL CONST'){
                contesabiltyshort = 'IDIC';
            }
        } else {
            contesabiltyshort = '';
        }
        return contesabiltyshort;
    }

    public static Map<String,String> getSoldToinfo(Project__c proj,String fieldname)
    {
        Map<id,Map<String,String>> siteSoldToMap = new Map<id,Map<String,String>>();
        Map<String,String> accvalues = new Map<String,String>();
        List<String> mailAdd;
        List<String> names;
        if(fieldname=='SiteOwner')
        {
            
            if(proj.SiteOwner__r.IsPersonAccount==true)
            {
                mailAdd= new List<String>();
                mailAdd=splitString(proj.SiteOwner__r.PersonMailingStreet);
                names = getSAPNames(new List<String>{checkString(proj.SiteOwner__r.FirstName), proj.SiteOwner__r.LastName});

                accvalues.put('soldtoCustNo',proj.SiteOwner__r.SAPCustomer__c);
                if(!names.isEmpty()) {
                    accvalues.put('soldtoStcName1',names[0]);
                    accvalues.put('soldtoStcName2',names[1]);
                }
                if(mailAdd.size()==2){
                    accvalues.put('soldtoAdd1',mailAdd[0]);
                    accvalues.put('soldtoAdd2',mailAdd[1]);
                }
                else{
                    accvalues.put('soldtoAdd1','');
                	accvalues.put('soldtoAdd2','');
                }
                //siteSoldToMap.put(accountID,BillingStreet,FirstName,LastName,Name,PersonMailingStreet 
            }
            else
            {
                mailAdd= new List<String>();
                mailAdd=splitString(proj.SiteOwner__r.BillingStreet);
                names = getSAPNames(new List<String>{proj.SiteOwner__r.Name});

                accvalues.put('soldtoCustNo',proj.SiteOwner__r.SAPCustomer__c);
                if(!names.isEmpty()) {
                    accvalues.put('soldtoStcName1',names[0]);
                    accvalues.put('soldtoStcName2',names[1]);
                }
                if(mailAdd.size()==2){
                	accvalues.put('soldtoAdd1',mailAdd[0]);
                	accvalues.put('soldtoAdd2',mailAdd[1]);
                }
                else{
                    accvalues.put('soldtoAdd1','');
                	accvalues.put('soldtoAdd2','');
                }
            }
        }
        else if(fieldname=='AuthRep')
        {
            
            if(proj.AuthorisedRepresentative__r.IsPersonAccount==true)
            {
                mailAdd= new List<String>();
                mailAdd=splitString(proj.AuthorisedRepresentative__r.PersonMailingStreet);
                names = getSAPNames(new List<String>{checkString(proj.AuthorisedRepresentative__r.FirstName), proj.AuthorisedRepresentative__r.LastName});

                accvalues.put('soldtoCustNo',proj.AuthorisedRepresentative__r.SAPCustomer__c);
                if(!names.isEmpty()) {
                    accvalues.put('soldtoStcName1',names[0]);
                    accvalues.put('soldtoStcName2',names[1]);
                }
                if(mailAdd.size()==2){
                	accvalues.put('soldtoAdd1',mailAdd[0]);
                	accvalues.put('soldtoAdd2',mailAdd[1]);
                }
                else{
                    accvalues.put('soldtoAdd1','');
                	accvalues.put('soldtoAdd2','');
                }
                //siteSoldToMap.put(accountID,BillingStreet,FirstName,LastName,Name,PersonMailingStreet 
            }
            else
            {
                mailAdd= new List<String>();
                mailAdd=splitString(proj.AuthorisedRepresentative__r.BillingStreet);
                names = getSAPNames(new List<String>{proj.AuthorisedRepresentative__r.Name});

                accvalues.put('soldtoCustNo',proj.AuthorisedRepresentative__r.SAPCustomer__c);
                if(!names.isEmpty()) {
                    accvalues.put('soldtoStcName1',names[0]);
                    accvalues.put('soldtoStcName2',names[1]);
                }
                if(mailAdd.size()==2){
                	accvalues.put('soldtoAdd1',mailAdd[0]);
                	accvalues.put('soldtoAdd2',mailAdd[1]);
                }
                else{
                    accvalues.put('soldtoAdd1','');
                	accvalues.put('soldtoAdd2','');
                }
            }
            //siteSoldTomap.put(accountID,accvalues);
        }
        
        return accvalues;
    }
    
    public static Map<String,String> getBillToinfo(Project__c proj,String fieldname)
    {
        Map<id,Map<String,String>> siteSoldToMap = new Map<id,Map<String,String>>();
        Map<String,String> accvalues = new Map<String,String>();
        List<String> mailAdd;
        List<String> names;
        if(fieldname=='SiteOwner')
        {
            accvalues.put('billtoAcctId',proj.SiteOwner__c);
            accvalues.put('billtoContId',proj.PropertyOwnerContact__c);
            accvalues.put('billtoCustNo',proj.SiteOwner__r.SAPCustomer__c);

            if(proj.SiteOwner__r.IsPersonAccount==true)
            {
                mailAdd= new List<String>();
                mailAdd=splitString(proj.SiteOwner__r.PersonMailingStreet);
                names = getSAPNames(new List<String>{checkString(proj.SiteOwner__r.FirstName), proj.SiteOwner__r.LastName});
                if(!names.isEmpty()) {
                    accvalues.put('billtoStcName1',names[0]);
                    accvalues.put('billtoStcName2',names[1]);
                }
                if(mailAdd.size()==2){
                    accvalues.put('billtoAdd1',mailAdd[0]);
                    accvalues.put('billtoAdd2',mailAdd[1]);
                }
                else{
                    accvalues.put('billtoAdd1','');
                	accvalues.put('billtoAdd2','');
                }
                //siteSoldToMap.put(accountID,BillingStreet,FirstName,LastName,Name,PersonMailingStreet 
            }
            else
            {
                mailAdd= new List<String>();
                mailAdd=splitString(proj.SiteOwner__r.BillingStreet);
                names = getSAPNames(new List<String>{proj.SiteOwner__r.Name});
                if(!names.isEmpty()) {
                    accvalues.put('billtoStcName1',names[0]);
                    accvalues.put('billtoStcName2',names[1]);
                }
                if(mailAdd.size()==2){
                    accvalues.put('billtoAdd1',mailAdd[0]);
                    accvalues.put('billtoAdd2',mailAdd[1]);
                }
                else{
                    accvalues.put('billtoAdd1','');
                    accvalues.put('billtoAdd2','');
                }
            }
        }
        else if(fieldname=='AuthRep')
        {
            accvalues.put('billtoAcctId',proj.AuthorisedRepresentative__c);
            accvalues.put('billtoContId',proj.AuthorizedRepresentativeContact__c);
            accvalues.put('billtoCustNo',proj.AuthorisedRepresentative__r.SAPCustomer__c);

            if(proj.AuthorisedRepresentative__r.IsPersonAccount==true)
            {
                mailAdd= new List<String>();
                mailAdd=splitString(proj.AuthorisedRepresentative__r.PersonMailingStreet);
                names = getSAPNames(new List<String>{checkString(proj.AuthorisedRepresentative__r.FirstName), proj.AuthorisedRepresentative__r.LastName});
                if(!names.isEmpty()) {
                    accvalues.put('billtoStcName1',names[0]);
                    accvalues.put('billtoStcName2',names[1]);
                }
                if(mailAdd.size()==2){
                    accvalues.put('billtoAdd1',mailAdd[0]);
                    accvalues.put('billtoAdd2',mailAdd[1]);
                }
                else{
                    accvalues.put('billtoAdd1','');
                    accvalues.put('billtoAdd2','');
                }
                //siteSoldToMap.put(accountID,BillingStreet,FirstName,LastName,Name,PersonMailingStreet 
            }
            else
            {
                mailAdd= new List<String>();
                mailAdd=splitString(proj.AuthorisedRepresentative__r.BillingStreet);
                names = getSAPNames(new List<String>{proj.AuthorisedRepresentative__r.Name});
                if(!names.isEmpty()) {
                    accvalues.put('billtoStcName1',names[0]);
                    accvalues.put('billtoStcName2',names[1]);
                }
                if(mailAdd.size()==2){
                    accvalues.put('billtoAdd1',mailAdd[0]);
                    accvalues.put('billtoAdd2',mailAdd[1]);
                }
                else{
                    accvalues.put('billtoAdd1','');
                	accvalues.put('billtoAdd2','');
                }
            }
            //siteSoldTomap.put(accountID,accvalues);
        }
        
        return accvalues;
    }
    
    public static List<String> splitString(String PersonMailingStreet )
    {       
        List<String> res = new List<String>();
        if(PersonMailingStreet!=null){
            Integer MaxSixe = PersonMailingStreet.length();
            if(PersonMailingStreet.length() > 35)
            {  
                res.add(PersonMailingStreet.substring(0, 35));
                if(MaxSixe > 70)
                {
                    res.add(PersonMailingStreet.substring(36, 70));                     
                }
                else
                {
                    res.add(PersonMailingStreet.substring(36, MaxSixe)); 
                }
            }
            else{
                res.add(PersonMailingStreet);
                res.add(' ');
            }
        }
        return res;
    }
    
    public static Map<String,string> getCMType(List<id>  prjIds){
        Map<String,string> WOprojMap = new Map<String,string>();
        List<WorkOrder> WOList = [select id,Project__c,Type__c,WorkOrderType__c from WorkOrder 
                                  where Project__c IN : prjIds and Type__c ='Design'];
        for(WorkOrder WO:WOList)
            WOprojMap.put(WO.Project__c , WO.WorkOrderType__c);
        return WOprojMap;
    }
    public static InvHeaderWrapper getInvoiceHeaderSet(String Invoicenumber)
    { 
        InvoiceHeaderSets__x invHead = new InvoiceHeaderSets__x();
        InvHeaderWrapper inVWrapper = new InvHeaderWrapper();
        try{
            if(!Test.isRunningTest()){
                invHead = [select CurrencyCode__c,DueDate__c,InvoiceNo__c,InvoicePdf__c,Link__c,CreationDate__c,
                                                MerchantPayRef__c,NetAmount__c,PaymentDate__c,TotalAmount__c,TotalGst__c
                                                from InvoiceHeaderSets__x
                                                where InvoiceNo__c =:Invoicenumber];
                System.debug('InvoiceHeaderSets__x in TVE_utility'+invHead);
            }
            else
                invHead=mockedInvHead;
            inVWrapper.invHSet=invHead;
            return inVWrapper;
        }
        catch(Exception e){
			inVWrapper.ErrorMessage=e.getMessage();
			return inVWrapper;          
        }
    }

    public static AttachmentSets__x getArtefact(String SAPNumber,String CMNumber,String DocTypevalues)
    {   
        AttachmentSets__x attachsets = new AttachmentSets__x();
        if(!Test.isRunningTest()) {
            attachsets = [select ArcDocId__c,ArObject__c,CreatedDate__c,Creator__c,FileContent__c,FileDesc__c,Filename__c,FileSize__c,
                          ImageResize__c,MimeType__c,ObjectId__c,OriginalUrl__c,SapObject__c,Url__c from AttachmentSets__x
                          where ArcDocId__c =: SAPNumber and ObjectId__c =: CMNumber and ArObject__c =: DocTypevalues and SapObject__c ='/CUM/CONSM'];
        } else {
            attachsets = mockedArt;
        }
        return attachsets;
    }
    
    public static List<Artefact__c> updateArtefact(Map<Id,InvoiceHeaderSets__x> invHeader)
    {
    	List<Artefact__c> updateArteList = new List<Artefact__c>(); 
        for(Id key: invHeader.keySet())
            {
                InvoiceHeaderSets__x inH =invHeader.get(key);
                Artefact__c art = new Artefact__c();
                
                art.InvoiceNumber__c=inH.InvoiceNo__c;
                art.Name=inH.InvoiceNo__c;
                art.DueDate__c = stringtodate(inH.DueDate__c);
                art.InvoiceDate__c = stringtodate(inH.CreationDate__c);
                art.Electronic_Payment_Link__c = inH.Link__c;
                art.ElectronicPaymentReferenceNumber__c = string.valueof(inH.MerchantPayRef__c);
                art.NetAmount__c = Decimal.valueOf(inH.NetAmount__c);
                art.InvoicePaidDate__c = stringtodate(inH.PaymentDate__c);
                art.TotalAmount__c = Decimal.valueOf(inH.TotalAmount__c);
                art.TotalGst__c = Decimal.valueOf(inH.TotalGst__c);
                art.id = key;
                updateArteList.add(art);
            }
        return updateArteList;
    }
    
    /*
    public static List<Artefact__c> updateArtefactforattachmentset(Map<Id,AttachmentSets__x> invHeader)
    {
    	List<Artefact__c> updateArteList = new List<Artefact__c>(); 
        for(Id key : invHeader.keySet())
            {
                AttachmentSets__x inH = invHeader.get(key);
                Artefact__c art = new Artefact__c();
                
                art.SAPNumber__c =inH.ArcDocId__c;
                art.Name = inH.Filename__c;
                art.Id = key;
                updateArteList.add(art);
            }
        return updateArteList;
    }
    */
    
    public static List<ContentVersion> createContentVersion(List<Id> arteIds, Map<Id,InvoiceHeaderSets__x> invHeader)
    {
        List<ContentVersion> cvs = new List<ContentVersion>();
        for(Id key : arteIds) {
            InvoiceHeaderSets__x inH = invHeader.get(key);
            ContentVersion cv = new ContentVersion();
            cv.PathOnClient = 'Invoice_'+inH.InvoiceNo__c+'.pdf';
            cv.VersionData =  EncodingUtil.base64Decode(inH.InvoicePdf__c);
            cv.IsMajorVersion = true;
            cvs.add(cv);
        }
        return cvs;
    }

    public static  Map<id,id> getContentDocument(List<ID> contentVListSuccess){
        Map<id,id> ContentVContentDoc =new  map<id,id>();
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument 
                                          where LatestPublishedVersionId=: contentVListSuccess];
        for(ContentDocument cd:documents)
        ContentVContentDoc.put(cd.id,cd.LatestPublishedVersionId);
        return  ContentVContentDoc;
    }

    /*
    public static Map<id,ContentDocumentLink> updateContentDocLink(Map<id,Id> artIdCVid,Map<Id,id> ContentVContentDoc){
        List<ContentDocumentLink> cdLinkList = new List<ContentDocumentLink>();
       
        Map<id,ContentDocumentLink> artCdLinkMap = new  Map<id,ContentDocumentLink>();
        cdLinkList=[select id,ContentDocumentId from ContentDocumentLink where ContentDocumentId IN: ContentVContentDoc.values()];
        for(ContentDocumentLink cdL:cdLinkList){
            ContentDocumentLink cdLink = new ContentDocumentLink();
            cdLink.ContentDocumentId=cdL.ContentDocumentId;
            cdLink.LinkedEntityId=  artIdCVid.get(ContentVContentDoc.get(cdL.ContentDocumentId));
            cdLink.ShareType='V';
            artCdLinkMap.put( artIdCVid.get(ContentVContentDoc.get(cdL.ContentDocumentId)),cdLink);
        }
        return artCdLinkMap;
        

    }*/

    /*
    public static Map<Id, ContentVersion> createContentVersionattachsets(Map<Id,AttachmentSets__x> attachsetsmap)
    {
        Map<Id, ContentVersion> mapArtToCV = new Map<Id, ContentVersion>();
        for(Id key : attachsetsmap.keySet())
            {
                AttachmentSets__x inH = attachsetsmap.get(key);
                ContentVersion cv = new ContentVersion();
                cv.Title = inH.Filename__c;
                cv.VersionData = EncodingUtil.base64Decode(inH.FileContent__c);
                cv.PathOnClient = inH.Filename__c;
                cv.IsMajorVersion = true;
                mapArtToCV.put(key, cv);
            }
        return mapArtToCV;
    }
    */

    /*
    public static List<User> updateUserattachsets(Map<Artefact__c,AttachmentSets__x> attachsetforUser)
    {
        List<User> userList = new List<User>();
        List<Artefact__c> updateArteList = new List<Artefact__c>();
        List<Id> lstUserIds=new List<id>();
        Map<Id,Id> mapofartIdCreatedId = new Map<Id,Id>();
        Map<Id,String> mapofartIdCreator = new Map<Id,String>();

        for(Artefact__c item: attachsetforUser.keySet()){
            mapofartIdCreatedId.put(item.Id,item.CreatedById);
            // AttachmentSets__x inH =invHeader.get(key);
            // lstUserIds.add(item.CreatedById);
            //map1
            //map2
            // mapofartIdCreator.put(item.Id,inh.Creator__c);
        
        }
        system.debug('user map 1'+mapofartIdCreatedId);
        //from user where Id in map1,values---->map3<id,user>
        Map<Id,User> mapofUserId= new Map<ID,User>([SELECT Id,SAP_ID__c FROM User WHERE Id IN :mapofartIdCreatedId.values()]);

        system.debug('user map 2'+mapofUserId);
        //for loop on map1
        for(Artefact__c key: attachsetforUser.keySet())
            {
                AttachmentSets__x inH =attachsetforUser.get(key);
                //map3.get(map1.get(key.id)).sapid__c=map2.get(key.id)
                mapofUserId.get(mapofartIdCreatedId.get(key.id)).SAP_ID__c=inH.Creator__c;  
                system.debug('Creator'+inH.Creator__c);
                
            }
            
        System.debug('UserList in utiliy'+userList);
        // return userList;
        return mapofUserId.values();
    }
    */
    
    public static List<ConstructionMeasureSets__x> GetCMs(List<String> lstCMNumbers)
    {
        List<ConstructionMeasureSets__x> lstCM = new List<ConstructionMeasureSets__x>();
        if(lstCMNumbers.size() > 0)
        {
            lstCM = [SELECT Id, Cmnum__c,Qmnum__c,Cmtxt__c,ZzTownPermit__c,ZzLodgeSpear__c,ZzSubdivision__c, ZzSubDivi__c, ZzAccc__c,
                    ZzCrab__c, UserStatus__c,ZzPrjOfficer__c,ZzContestability__c 
                    FROM ConstructionMeasureSets__x WHERE Cmnum__c in: lstCMNumbers];
        }        
        return lstCM;
    }

    public static Date stringtodate(String strdate)
    {
        if(String.isBlank(strdate))
            return null;
        List<String> dateList = new List<String>();
        String converteddate;
        for(Integer i=0;i<strdate.length();i++)
            dateList.add(strdate.substring(i,i+1));
        converteddate=dateList[0]+dateList[1]+dateList[2]+dateList[3]+'-'+dateList[4]+dateList[5]+'-'+dateList[6]+dateList[7];
        System.debug('converteddate in util'+converteddate);
        return Date.valueOf(converteddate);
    }
    
    public static Datetime dateConversionSAPtoSF(string strDate)
    {
        Datetime localDatetime;
        if(String.isNotEmpty(strDate) && String.isNotEmpty(strDate.substring(6, strDate.length() - 2)))
        {
            Long timestamp = Long.valueOf(strDate.substring(6, strDate.length() - 2));
            DateTime gmtDatetime = DateTime.newInstance(timestamp);
            System.TimeZone myTz = UserInfo.getTimeZone();
            Integer millisecondOffsetGmt = myTz.getOffset(gmtDateTime);
            localDatetime = DateTime.newInstance(timeStamp - millisecondOffsetGmt);
            system.debug(gmtDatetime);    // This displays (in the debug log) 2017-11-14 10:10:20, regardless of local time
            system.debug(localDatetime);  // For me, being UTC-6, this displays 2017-11-14 16:10:20 (again, in the debug log)
        }
        return localDatetime;
    }
    
    public static ConstMeasureWrapper getConstMeasureSet(String Cmnumber)
    {
        ConstMeasureWrapper cmWrapper = new ConstMeasureWrapper();
        try{
            if(!Test.isRunningTest()){
                cmWrapper.cmset = [select Cmnum__c,Cmtxt__c,ZzPrjOfficer__c,ZzTownPermit__c,
                                    ZzContestability__c,ZzLodgeSpear__c,ZzSubdivision__c,ZzSubDivi__c,
                                    ZzAccc__c,ZzCrab__c,UserStatus__c,Qmnum__c from ConstructionMeasureSets__x
                                    where Cmnum__c=:Cmnumber];
            } else {
                cmWrapper.cmset = mockedConstMeasure;
            }
            return cmWrapper;
        }
        catch(Exception e){
            cmWrapper.errorMessage = e.getMessage();
            return cmWrapper;
        }
    }

	public static Map<id,Artefact__c> getArtefact(List<id> ArtefactIdList)
	{
        Map<id,Artefact__c> artefactMap= new Map<id,Artefact__c>();
        List<Artefact__c> artList = [select id,project__c,SAPNumber__c,Project__r.CMNumber__c,Classification__c,
                                     Name,CreatedDate from Artefact__c where
                                    Project__r.CMNumber__c!='' and Project__r.sap_integration_status__c='Ready to Create' 
                                   and ID IN : ArtefactIdList];
        
        for(Artefact__c art:artList)
            	artefactMap.put(art.id,art);
        return artefactMap;
    }
    
    public static Map<Id,ContentVersion> getContentVersion(List<Id> ArtefactIdList)
	{
        Map<Id,ContentVersion> artCVMap= new Map<Id,ContentVersion>();
        Map<Id,Id> mapCDIdToArtId = new Map<Id,Id>();
        for(ContentDocumentLink cdl : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :ArtefactIdList]) {
            mapCDIdToArtId.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
        }
        for(ContentVersion cv : [SELECT Id,FileExtension,ContentSize,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: mapCDIdToArtId.keySet()])
            artCVMap.put(mapCDIdToArtId.get(cv.ContentDocumentId),cv);
        return artCVMap;
    }
    
    public static void updateArcID(Map<String,String> artDocIdMap){
        List<Artefact__c> artList = new List<Artefact__c>();
        for(String key:artDocIdMap.keyset()){
            Artefact__c art = new Artefact__c();
            art.id=key;
            art.SAPNumber__c=artDocIdMap.get(key);
            artList.add(art);
        }
        update artList;
    }
    
    public static List<WorkOrderSets__x> GetWOs(Set<String> lstOrderNumbers)
    {
        List<WorkOrderSets__x> lstWO = new List<WorkOrderSets__x>();
        if(lstOrderNumbers.size() > 0)
        {
            lstWO = [SELECT Id, StartDate__c, FinishDate__c, SystemStatus__c, OrderNumber__c  FROM WorkOrderSets__x 
                     WHERE OrderNumber__c IN : (lstOrderNumbers)];
        }        
        return lstWO;
    }
    
	public static List<PMNotificationSets__x> GetPMNoti(Set<String> lstNotificationNumbers)
    {
        List<PMNotificationSets__x> ret = new List<PMNotificationSets__x>();
        //Commented out the following query because IN keyword is not supported by SAP
        /*
        if(lstNotificationNumbers.size() > 0)
        {             
            lstWO = [SELECT Id, NotificationNumber__c, RequiredEndDate__c, SystemStatus__c FROM PMNotificationSets__x 
                     WHERE NotificationNumber__c IN : (lstNotificationNumbers)];
        }*/
        for(String notiNum : lstNotificationNumbers) {
            //Query in loop because governor limits don't apply to external objects
            List<PMNotificationSets__x> notis = [SELECT Id, NotificationNumber__c, RequiredEndDate__c, SystemStatus__c FROM PMNotificationSets__x WHERE NotificationNumber__c = :notiNum];
            if(!notis.isEmpty()) {
                ret.addAll(notis);
            }
        }
        return ret;
    }

    //Method to get Artefact__c records
    public static List<Artefact__c> getArtefactList(List<Id> artefactIdList)
    {
        List<Artefact__c> artefactRecords = new List<Artefact__c>();
        artefactRecords = [SELECT Id, InvoiceNumber__c, Project__c, MaterialCodeLine1__c, AmountLine1ExGST__c, MaterialCodeLine2__c, AmountLine2ExGST__c,
                           MaterialCodeLine3__c, AmountLine3ExGST__c, InvoiceTypeLine1__c, InvoiceTypeLine2__c, InvoiceTypeLine3__c, Bill_To__c FROM Artefact__c WHERE Id IN : artefactIdList];
        return artefactRecords;
    }

    public class ConstMeasureWrapper {
        public ConstructionMeasureSets__x cmset;
        public String errorMessage;
    }
    public class InvHeaderWrapper {
        public InvoiceHeaderSets__x invHSet;
        public String errorMessage;
    }
    public static Id getIntegrationUserId(){
        List<User> intUser =[Select user.id,user.profile.name from user,user.profile where user.profile.name = 'Integration Profile' limit 1];
        Id owner;
        if(intUser!=null && intUser.size()> 0){
            owner = intUser[0].Id;

        }
        return owner;
    }

    public static List<String> getSAPNames(List<String> SFNames) {
        List<String> SAPNames = new List<String>();
        if (!SFNames.isEmpty()) {
            if (SFNames.size() == 1) {
                SAPNames.add(SFNames[0]);
                SAPNames.add('');
            } else if (SFNames.size() == 2) {
                if (SFNames[0].length() + SFNames[1].length() < 35) {
                    SAPNames.add(String.join(SFNames, ' '));
                    SAPNames.add('');
                } else {
                    SAPNames.add(SFNames[0]);
                    SAPNames.add(SFNames[1]);
                }
            }
        }
        return SAPNames;
    }
}