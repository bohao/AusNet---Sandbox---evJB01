/*
@author  : harshad.kumbhar@ausnetservices.com.au
@created : 12 Feb 2020
@Description : Class for executing SAP Integration - Get Customer & Update Customer part
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
18-Feb-2020       pavan.dave@ausnetservices.com.au    Added review comments from Jack (TV-1211)
-----------------------------------------------------------------------------------------
*/
public without sharing class TVE_SAPInteg_GetCustomer implements Queueable{
    
    @TestVisible private static List<CustomerSets__x> mockedExtCust = new List<CustomerSets__x>();
    @TestVisible private static List<Account> mockedAccount = new List<Account>();
    @TestVisible private static Boolean ExceptionFlag = false;
    
    public void execute(QueueableContext qc)
    {       
        List<Integration_Task__c> lstIntgTask = TVE_IntegUtility.getIntegrationTask('Get','Project__c','GetCustomer','In Progress');
        Map<Id, Id> parentToTask = new Map<Id, Id>();
        
        for(Integration_Task__c item: lstIntgTask)
        {
            parentToTask.put(item.ParentId__c, item.Id);
        }
        
        if(!parentToTask.isEmpty()){
            // ------------------------------------- //
            // ---------- GetCustomer -------------- //
            // ------------------------------------- //
            List<CustomerSets__x> lstCust = getCustomers(parentToTask.keySet(),lstIntgTask);
            
            
            // ------------------------------------- //
            // ---------- UpdateCustomer ------------//
            // ------------------------------------- //
            Map<String, CustomerSets__x> mapExtIdCustSet = new Map<String, CustomerSets__x>();
            for(CustomerSets__x item : lstCust) {
                mapExtIdCustSet.put(item.Previouseaccno__c, item);
            }
            updateCustomer(mapExtIdCustSet,parentToTask);
        }
        
        lstIntgTask = TVE_IntegUtility.getIntegrationTask('Get','Project__c','GetCustomer','In Progress');
        if(!lstIntgTask.isEmpty()){
            TVE_SAPInteg_GetCustomer getCustomer = new TVE_SAPInteg_GetCustomer();
                        ID jobID = System.enqueueJob(getCustomer);  
        }
        else{
            if(!Test.isRunningTest())
            {
                TVE_SAPInteg_CreateMasterNoti createMasterNoti = new TVE_SAPInteg_CreateMasterNoti();
                    // // enqueue the job for processing
                ID jobID = System.enqueueJob(createMasterNoti);   
                System.debug('TVE_SAPInteg_CreateMasterNoti - Job Id : ' + jobID);
            }       
        }      
    } 
    
    public List<CustomerSets__x> getCustomers(Set<Id> projIds,List<Integration_Task__c> inttaskList) 
    {
        Set<Id> setAccIds = new Set<Id>();
        Set<String> setAccUniqId = new Set<String>();
        List<CustomerSets__x> custList = new List<CustomerSets__x>();
        
        Map<Id,String> failureMap = new Map<Id,String>();
        Map<String,String> createIntglogmapF = new Map<String,String>();
        Map<String,String> updateIntTaskMapFail = new Map<String,String>();
        
        //Get account based on project id
        List<Project__c> projectList = [SELECT Id, SiteOwner__c, AuthorisedRepresentative__c FROM Project__c 
                                        WHERE ID IN :projIds];  
        
        for (Project__c proj : projectList) {
            if(!String.isBlank(proj.SiteOwner__c))
            {   
                setAccIds.add(proj.SiteOwner__c);            	
            }
            if(!String.isBlank(proj.AuthorisedRepresentative__c))
            {                
                setAccIds.add(proj.AuthorisedRepresentative__c);            	
            }
        }
        
        List<Account> lstAcc = [SELECT Id, SFDCUniqueId__c
                                FROM Account WHERE Id IN : setAccIds AND SAPCustomer__c = null];
        
        for(Account acc : lstAcc)
        {
            setAccUniqId.add(acc.SFDCUniqueId__c);                       
        }
        System.debug('getCustomers---->setAccUniqId------>'+setAccUniqId);
        
        //Mock result if responce is empty from callout
        
        try{
            if(Test.isRunningTest())
            {
                custList = (mockedExtCust.size() > 0) ? mockedExtCust : null;      
                if(ExceptionFlag)
                {
                    CalloutException e = new CalloutException();
                    e.setMessage('This is a constructed exception for testing and code coverage');
                    throw e;
                }
            }
            else 
            {    
                custList = new List<CustomerSets__x> ([SELECT CustNumber__c, Previouseaccno__c 
                                                       FROM CustomerSets__x WHERE  Previouseaccno__c IN : setAccUniqId]);
            }
            System.debug('getCustomers---->custList------>'+custList.size());
        }
        catch(Exception e)
        {
            for(Integration_Task__c task:inttaskList)
            {
                failureMap.put(task.Id, e.getMessage());
                updateIntTaskMapFail.put('Status__c', 'Failed');
                createIntglogmapF.put('Status__c','Failed');
                
                TVE_IntegUtility.UpdateInteTask(failureMap,updateIntTaskMapFail);
                TVE_IntegUtility.createIntegLog(failureMap,createIntglogmapF);
            }
        }
        
        
        return custList;
    }
    
    public void updateCustomer(Map<String, CustomerSets__x> mapExtIdCustSet,Map<Id, Id> parentToTask) {
        Map<Id,String> successMap = new Map<Id,String>();
        Map<Id,String> failureMap = new Map<Id,String>();
        Map<String,String> createIntTaskMap = new Map<String,String>();
        Map<String,String> updateIntTaskMap = new Map<String,String>();
        Map<String,String> createIntglogmapS = new Map<String,String>();
        Map<String,String> createIntglogmapF = new Map<String,String>();
        Map<String,String> updateIntTaskMapFail = new Map<String,String>();
        
        if(!mapExtIdCustSet.isEmpty()){
            List<Account> accList = [SELECT Id, SAPCustomer__c, SFDCUniqueId__c  
                                     FROM Account 
                                     WHERE SFDCUniqueId__c IN : mapExtIdCustSet.keySet()];
            
            System.debug('updateCustomer----->accList------>'+accList.size());
            Map<String, Account> mapSFUniqIdAcc = new Map<String, Account>();
            for(Account item : accList)
            {
                mapSFUniqIdAcc.put(item.SFDCUniqueId__c, item);
            }
            for(CustomerSets__x cust : mapExtIdCustSet.values())
            {             
                if(!string.isBlank(cust.Previouseaccno__c) && mapSFUniqIdAcc.containsKey(cust.Previouseaccno__c)) {
                    mapSFUniqIdAcc.get(cust.Previouseaccno__c).SAPCustomer__c = format(cust.CustNumber__c);
                }
            }
            if(!mapSFUniqIdAcc.isEmpty())
            {
                List<Database.SaveResult> lstSR;
                try{
                		lstSR = Database.update(mapSFUniqIdAcc.values(), false);
                }
                catch(Exception e){
                    for(ID pID:parentToTask.keySet())
                    	failureMap.put(parentToTask.get(pID),e.getMessage());
                }
                
                Set<String> setPrevAccNo_Success = new Set<String>();
                Map<String, List<String>> mapErrors = new Map<String, List<String>>();
                
                for (Database.SaveResult res : lstSR) {
                    if (res.isSuccess()) {
                        setPrevAccNo_Success.add(res.getId());
                    } else {
                        // Operation failed, so get all errors
                        List<String> errorMsg = new List<String>();
                        for(Database.Error err : res.getErrors()) {
                            errorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                        mapErrors.put(res.getId(), errorMsg);
                    }
                }
                System.debug('Mocked Account :' + mockedAccount);
                //For unit testing
                if(Test.isRunningTest()){
                    setPrevAccNo_Success.clear();
                    for(Account acc : mockedAccount){
                        System.debug('Mocked Account Id:' + acc.Id);
                        setPrevAccNo_Success.add(acc.Id);
                    }
                }
                
                List<Project__c> lstProj = [SELECT Id, SiteOwner__c, SiteOwner__r.SFDCUniqueId__c, AuthorisedRepresentative__c, AuthorisedRepresentative__r.SFDCUniqueId__c FROM Project__c WHERE Id IN: parentToTask.keySet()];
                if(lstProj.size()>0){
                    for(Project__c proj : lstProj) {
                        System.debug('Value 1 :' + !mapSFUniqIdAcc.keySet().contains(proj.SiteOwner__r.SFDCUniqueId__c));
                        System.debug('Value 2 :' + setPrevAccNo_Success.contains(proj.SiteOwner__c));
                        System.debug('Value 3 :' + !mapSFUniqIdAcc.keySet().contains(proj.AuthorisedRepresentative__r.SFDCUniqueId__c));
                        System.debug('Value 4 :' + setPrevAccNo_Success.contains(proj.AuthorisedRepresentative__c));
                        
                        if(
                            (mapSFUniqIdAcc.keySet().contains(proj.SiteOwner__r.SFDCUniqueId__c) && !setPrevAccNo_Success.contains(proj.SiteOwner__c))
                            ||
                            (mapSFUniqIdAcc.keySet().contains(proj.AuthorisedRepresentative__r.SFDCUniqueId__c) && !setPrevAccNo_Success.contains(proj.AuthorisedRepresentative__c))
                        ) {
                            List<String> errors = mapSFUniqIdAcc.keySet().contains(proj.SiteOwner__r.SFDCUniqueId__c) ? mapErrors.get(proj.SiteOwner__r.SFDCUniqueId__c) : new List<String>();
                            
                            if(mapSFUniqIdAcc.keySet().contains(proj.AuthorisedRepresentative__r.SFDCUniqueId__c)) {
                                if(mapErrors.get(proj.AuthorisedRepresentative__r.SFDCUniqueId__c) != null)
                                {
                                    errors.addAll(mapErrors.get(proj.AuthorisedRepresentative__r.SFDCUniqueId__c));
                                }
                            }
                            if(errors != null)
                            {
                                failureMap.put(parentToTask.get(proj.Id),String.join(errors, '\r\n'));
                            }
                        }
                    }
            	}
            }
        }
        
        for(Id parentId : parentToTask.keySet()) {
            if(!failureMap.containsKey(parentToTask.get(parentId)))
                successMap.put(parentToTask.get(parentId), parentId);
        }
            
        if(successMap.size()>0) {
            createIntTaskMap.put('SObject__c','Project__c');
            createIntTaskMap.put('Type__c','CreateMasterNoti');
            createIntTaskMap.put('Operation__c', 'Create');
            createIntTaskMap.put('Status__c','In Progress');
            updateIntTaskMap.put('Status__c','Successful');
            createIntglogmapS.put('Status__c','Successful');
                
            TVE_IntegUtility.UpdateInteTask(successMap,updateIntTaskMap);
            TVE_IntegUtility.createIntegLog(successMap,createIntglogmapS);
            TVE_IntegUtility.CreateInteTask(successMap,createIntTaskMap);
        }
        if(failureMap.size()>0) {
            updateIntTaskMapFail.put('Status__c','Failed');
            createIntglogmapF.put('Status__c','Failed');
                
            TVE_IntegUtility.UpdateInteTask(failureMap,updateIntTaskMapFail);
            TVE_IntegUtility.createIntegLog(failureMap,createIntglogmapF);
        }
    }
    
    // format the when value is empty it will return null value
    public String format(String str) {
        return str == NULL ? ' ' : str;
    }    
}