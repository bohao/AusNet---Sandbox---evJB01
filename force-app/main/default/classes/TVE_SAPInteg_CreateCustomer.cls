/*
  @author  : harshad.kumbhar@ausnetservices.com.au
  @created : 12 Feb 2020
  @Description : Class for executing SAP Integration - Create Customer part
  -----------------------------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------------------------
  20-Jul-2021          Sridhar Sathiamurthy            Changed Apex collection from list to map for 1stProjId
  -----------------------------------------------------------------------------------------------------------
*/
public without sharing class TVE_SAPInteg_CreateCustomer implements Queueable{
    
    @TestVisible private static List<CustomerSets__x> mockedExtCust = new List<CustomerSets__x>();    
    @TestVisible private static List<CustomerSets__x> mockedExtCustGet = new List<CustomerSets__x>();
    
    private static final String CREATECUST_CALLOUT = 'CreateCustomer';
    public static Map<String,String> StatesMap = new Map<String,String>
            {'Australian Capital Territory' => 'ACT', 'New South Wales' => 'NSW', 'Northern Territory' => 'NT', 'Queensland' => 'QLD', 'South Australia' => 'SA', 'Tasmania' => 'TAS', 'Victoria' => 'VIC', ' Western Australia' => 'WA'};
    public static Map<String,Id> mapAccUniqueIdProjId = new Map<String,Id>();
    
    public void execute(QueueableContext qc)
    {        
        List<Integration_Task__c> lstIntgTask = TVE_IntegUtility.getIntegrationTask( 'Create','Project__c','CreateCustomer','In Progress');
		System.debug('Integration Task : ' + lstIntgTask);
        Map<Id, Id> lstProjIds = new Map<Id, Id>();
        Map<Id, Id> parentToTask = new Map<Id, Id>();

        Map<Id,String> successMap = new Map<Id,String>();
        Map<Id,String> failureMap = new Map<Id,String>();
		Map<String,String> createIntTaskMap = new Map<String,String>();
        Map<String,String> updateIntTaskMap = new Map<String,String>();
		Map<String,String> createIntglogmapS = new Map<String,String>();
		Map<String,String> createIntglogmapF = new Map<String,String>();
        Map<String,String> updateIntTaskMapFail = new Map<String,String>();
        if(!lstIntgTask.isEmpty()){
            for(Integration_Task__c item: lstIntgTask)
            {
                lstProjIds.put(item.ParentId__c,item.ParentId__c);
              
                parentToTask.put(item.ParentId__c, item.Id);
            }
        }
		 if(!lstProjIds.isEmpty())
        {
            Map<Id, CustomerSets__x> mapPrjIdCustSet = new Map<Id, CustomerSets__x>();
            List<Database.SaveResult> lstSR= new List<Database.SaveResult>();
            GetCustomerWrapper customersList;
            try{
            	customersList = getCustomerSet(lstProjIds.values());
        		System.debug('Customer List : ' + customersList.customer);
            }
            catch(Exception e){
                for(Id projID:lstProjIds.keySet())
                	failureMap.put(parentToTask.get(projID),e.getMessage());
            }
           
            if(customersList != null && !customersList.customer.isEmpty())
            {
                if(Test.isRunningTest())
                {
                    lstSR.add((Database.SaveResult)JSON.deserialize('{"success":true,"id":"a0E2N000000EDvC"}', Database.SaveResult.class));
                }
                else 
                {
				 //Insert external object CustomerSets__x i.e. CreateCustomer call to SAP
                    try{
                 		lstSR = Database.insertImmediate(customersList.customer); 
                    }
            		catch(Exception e){
                		for(Id projID:lstProjIds.keySet())
                			failureMap.put(parentToTask.get(projID),e.getMessage());
            		}
                }
             
                Set<String> setPrevAccNo_Success = new Set<String>();
                Map<String, List<String>> mapErrors = new Map<String, List<String>>();
                for (Integer i = 0; i < lstSR.size(); i++) {
                    Database.SaveResult res = lstSR.get(i);
                    if (res.isSuccess())
                    {
                        setPrevAccNo_Success.add(customersList.customer.get(i).Previouseaccno__c);
                    }      
                    else {
                        // Operation failed, so get all errors
                        List<String> errorMsg = new List<String>();
                        for(Database.Error err : res.getErrors()) {
                            errorMsg.add(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        }
                        mapErrors.put(customersList.customer.get(i).Previouseaccno__c, errorMsg);
                    }
                }
                
                //For unit testing
                if(!mockedExtCustGet.isEmpty()) {
                    setPrevAccNo_Success.clear();
                    for (CustomerSets__x cust : mockedExtCustGet) {
                        setPrevAccNo_Success.add(cust.Previouseaccno__c);
                    }
                }
                
                List<Project__c> lstProj = [SELECT Id, SiteOwner__c, SiteOwner__r.SFDCUniqueId__c, AuthorisedRepresentative__c, AuthorisedRepresentative__r.SFDCUniqueId__c,AuthorizedRepresentativeContact__r.Email,
                                           AuthorizedRepresentativeContact__r.Phone,AuthorizedRepresentativeContact__r.MobilePhone,PropertyOwnerContact__r.Email,PropertyOwnerContact__r.Phone,
                                           PropertyOwnerContact__r.MobilePhone FROM Project__c WHERE Id IN: lstProjIds.keySet()];
                if(lstProj.size()>0){
                	for(Project__c proj : lstProj) {
                        if(
                            (customersList.account.contains(proj.SiteOwner__c) && !setPrevAccNo_Success.contains(proj.SiteOwner__r.SFDCUniqueId__c))
                            ||
                            (customersList.account.contains(proj.AuthorisedRepresentative__c) && !setPrevAccNo_Success.contains(proj.AuthorisedRepresentative__r.SFDCUniqueId__c))
                        ) {
                            List<String> errors = customersList.account.contains(proj.SiteOwner__c) && mapErrors.containsKey(proj.SiteOwner__r.SFDCUniqueId__c) ? mapErrors.get(proj.SiteOwner__r.SFDCUniqueId__c) : new List<String>();
                            if(customersList.account.contains(proj.AuthorisedRepresentative__c)) {
                                if(mapErrors.get(proj.AuthorisedRepresentative__r.SFDCUniqueId__c) != null)
                                {
                                    errors.addAll(mapErrors.get(proj.AuthorisedRepresentative__r.SFDCUniqueId__c));
                      
                                }
                            }
                            if(errors!=null)
                            {
                                failureMap.put(parentToTask.get(proj.Id),String.join(errors, '\r\n'));
                            }
                        }
                    }
            	}
            }
            
            for(Integration_Task__c item: lstIntgTask) {
                if(!failureMap.containsKey(item.Id))
                    successMap.put(item.Id, item.ParentId__c);
            }

            if(successMap.size()>0) {
                createIntTaskMap.put('SObject__c','Project__c');
                createIntTaskMap.put('Type__c','GetCustomer');
                createIntTaskMap.put('Operation__c', 'Get');
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
        
        lstIntgTask = TVE_IntegUtility.getIntegrationTask( 'Create','Project__c','CreateCustomer','In Progress');
        if(!lstIntgTask.isEmpty()){
            TVE_SAPInteg_CreateCustomer createCustomer = new TVE_SAPInteg_CreateCustomer();
            ID jobID = System.enqueueJob(createCustomer);  
        }
        else{
        // enqueue the job for processing
            if(!Test.isRunningTest()) {
                TVE_SAPInteg_GetCustomer getCustomers = new TVE_SAPInteg_GetCustomer();
                ID jobID = System.enqueueJob(getCustomers);   
                System.debug('TVE_SAPInteg_GetCustomer - Job Id : ' + jobID);
            }
        }
    }

    public class GetCustomerWrapper
    {
        public List<CustomerSets__x> customer {get;set;}
        public Set<Id> account {get;set;}
    }

    public static GetCustomerWrapper getCustomerSet(List<Id> IDs)
    {   
        //set for unique account ids
        Set<Id> AccIDs = new Set<Id>();    
        Map<Id,Id> projIdNAccId = new Map<Id,Id>();    
        Map<Id, Project__c> mapAccProj = new Map<Id, Project__c>();
        System.debug('Project Ids : '+ IDs);

        //list of project based on parameter                                       
        List<Project__c> projectList = TVE_IntegUtility.getProject(IDs);      
       
        //adding unique account id from child project
        for(Project__c proj : projectList)
        {
            System.debug('Item Proj : '+ proj.Id);
            System.debug('Item SiteOwner__c : '+ proj.SiteOwner__c);
            System.debug('Item AuthorisedRepresentative__c : '+ proj.AuthorisedRepresentative__c);
            if(!String.isBlank(proj.SiteOwner__c))
            {   
              	AccIDs.add(proj.SiteOwner__c);
                projIdNAccId.put(proj.SiteOwner__c, proj.Id);
                mapAccProj.put(proj.SiteOwner__c, proj);
            }
            if(!String.isBlank(proj.AuthorisedRepresentative__c))
            {                
              	AccIDs.add(proj.AuthorisedRepresentative__c);
                projIdNAccId.put(proj.AuthorisedRepresentative__c, proj.Id);
                mapAccProj.put(proj.AuthorisedRepresentative__c, proj);
            }
          
        }        
        System.debug('Account Ids : '+ AccIDs);
        // get all the account details based on AccountId list
        Map<Id, Account> ls = new Map<Id, Account>(
            [SELECT Id,IsPersonAccount,SFDCUniqueId__c,Customer_Type__c,FirstName,LastName,PersonEmail,PersonOtherPhone,
            PersonMobilePhone,PersonMailingCity,PersonMailingStreet,PersonMailingPostalCode,PersonMailingState,
            PersonMailingCountry,SAPCustomer__c, Name,BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry
            FROM Account WHERE Id IN :AccIDs AND SAPCustomer__c = null]
        );
        System.debug('Account List : '+ ls.size());

        // list to collect customer to insert
        List<CustomerSets__x> customers = new List<CustomerSets__x>();
       
        // loop over accont and mapped with CustomerSet
        for(Account acc : ls.values())
        {
            mapAccUniqueIdProjId.put(acc.SFDCUniqueId__c,projIdNAccId.get(acc.Id));
            customers.add(getCustomerMapping(acc, mapAccProj.get(acc.Id)));
        }
        GetCustomerWrapper custWrpp =  new GetCustomerWrapper();
        custWrpp.customer = customers;
        custWrpp.account = ls.keySet();
        return custWrpp;
    }

    // get Customer details mapping from account records
    public static CustomerSets__x getCustomerMapping(Account acc, Project__c proj)
    {
        // split move here
        List<String> splitedString = new List<String>();
        String mailingStreet;
        if(acc.isPersonAccount)
        {
            mailingStreet = format(acc.PersonMailingStreet);
        }else
        {
            mailingStreet = format(acc.BillingStreet);
        }
        System.debug('Mailing Steet : ' + mailingStreet);
        if(!String.isEmpty(mailingStreet))
        {
            splitedString = splitString(mailingStreet);
        }
        else {
            splitedString.add(' ');
            splitedString.add(' ');
        } 
        CustomerSets__x cust = new CustomerSets__x();
        API_Callout_Headers__mdt apiCallout = [SELECT Key__c, SourceSystem__c, TargetSystem__c, ObjectName__c FROM API_Callout_Headers__mdt WHERE objectName__c =: CREATECUST_CALLOUT];           
        if(Test.isRunningTest())
        {              
            System.debug('Mock Data :' + mockedExtCust[0]);            
            cust = (mockedExtCust.size() > 0) ? mockedExtCust[0] : null; 
        }
        else 
        {
            System.debug('Else part');
            cust = prepareCustomer(acc, proj);                     
        }
        System.debug('Cust :' + cust);
        cust.Street1__c=splitedString[0];
        if(splitedString[1] != null && splitedString[1] != ' ' && splitedString[1] != ''){
            cust.Street2__c=splitedString[1];
        }
        cust.Key__c=apiCallout.Key__c;
        cust.ObjectName__c=apiCallout.ObjectName__c;
        cust.SourceSystem__c= apiCallout.SourceSystem__c;
        cust.TargetSystem__c=apiCallout.TargetSystem__c;
        return cust;
    }
   
    @TestVisible
    public static CustomerSets__x prepareCustomer(Account acc, Project__c proj)
    {
        CustomerSets__x cust = new CustomerSets__x();
        cust.Previouseaccno__c = String.valueOf(acc.SFDCUniqueId__c);
        cust.CustomerType__c = (String.isNotBlank(acc.Customer_Type__c) && !acc.Customer_Type__c.startsWith('ELE')) ? acc.Customer_Type__c : 'ELE';
        cust.MsgId__c = TVE_Utility.getUniqueId(mapAccUniqueIdProjId.get(acc.SFDCUniqueId__c));
        List<String> names;
        
        if(acc.isPersonAccount)
        {
            names = TVE_IntegUtility.getSAPNames(new List<String>{format(acc.FirstName), acc.LastName});
            if (!names.isEmpty()) {
                if (String.isNotBlank(names[0])) {
                    cust.CustName1__c=names[0];
                }
                if (String.isNotBlank(names[1])) {
                    cust.CustName2__c=names[1];
                }
            }
            cust.Email__c=format(acc.PersonEmail);
            cust.Telephone__c=format(acc.PersonMobilePhone);
            cust.MobileNumber__c=format(acc.PersonMobilePhone);
            cust.City__c=format(acc.PersonMailingCity);
            cust.Postalcode__c=acc.PersonMailingPostalCode;
            cust.Region__c=StatesMap.containsKey(acc.PersonMailingState) ? StatesMap.get(acc.PersonMailingState) : acc.PersonMailingState;
            cust.Country__c=format(acc.PersonMailingCountry == 'Australia' || String.isBlank(acc.BillingCountry) ? 'AU' : acc.PersonMailingCountry);                                     
        }
        else
        {
            names = TVE_IntegUtility.getSAPNames(new List<String>{acc.Name});
            if (!names.isEmpty()) {
                if (String.isNotBlank(names[0])) {
                    cust.CustName1__c=names[0];
                }
                if (String.isNotBlank(names[1])) {
                	cust.CustName2__c=names[1];
                }
            }
            cust.City__c=format(acc.BillingCity);
            cust.Postalcode__c=acc.BillingPostalCode;
            cust.Region__c=StatesMap.containsKey(acc.BillingState) ? StatesMap.get(acc.BillingState) : acc.BillingState;
            cust.Country__c=format(acc.BillingCountry == 'Australia' || String.isBlank(acc.BillingCountry) ? 'AU' : acc.BillingCountry);                                                                
                                    
            if(proj.AuthorisedRepresentative__c == acc.Id)
            {
                cust.Email__c=format(proj.AuthorizedRepresentativeContact__r.Email);
                cust.Telephone__c=format(proj.AuthorizedRepresentativeContact__r.MobilePhone);
                cust.MobileNumber__c=format(proj.AuthorizedRepresentativeContact__r.MobilePhone);
            }
            else if(proj.SiteOwner__c == acc.Id)
            {
                cust.Email__c=format(proj.PropertyOwnerContact__r.Email);
                cust.Telephone__c=format(proj.PropertyOwnerContact__r.MobilePhone);
                cust.MobileNumber__c=format(proj.PropertyOwnerContact__r.MobilePhone);
            }
        }
        return cust;
    }
    // format the when value is empty it will return null value
    public static String format(String str) {
      return str == NULL ? '' : str;
    }    

    // split string if the char lenght is greather than 60
    public static List<String> splitString(String PersonMailingStreet )
    {       
        List<String> res = new List<String>();
        if(PersonMailingStreet.length() > 60)
        {            
            string comma = ',';
            string slash = '/';
            Integer resultComma = PersonMailingStreet.indexOf(comma);
            Integer resultSlash = PersonMailingStreet.indexOf(slash);
            Integer MaxSixe = PersonMailingStreet.length();
            
            if(resultComma > 0 || resultSlash > 0)
            {
                System.debug('splitString 1');
                res.add(PersonMailingStreet.substring(0, 60));
                if(MaxSixe > 100)
                {
                    res.add(PersonMailingStreet.substring(61, 100));                     
                }
                else
                {
                    res.add(PersonMailingStreet.substring(61, MaxSixe)); 
                }
           
            }
            else
            {
                System.debug('splitString 2');
                res = PersonMailingStreet.split(' ');            
            }	
        }
        else
        {
            System.debug('splitString 3');
             res.add(PersonMailingStreet);
             res.add(' ');
        }      
        return res;
    }
}