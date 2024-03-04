@isTest
private class TVE_SAPInteg_GetCustomerTest{

    public static final string testUserEmail = 'testuser@TVECustomerDetailsSAP.com';
    public static final string CON_TYPE = 'IDIC';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
	@testSetup static void setup(){

		//Create User
		User testUser = TVE_TestUtility.createTestUser(testUserEmail);
		insert testUser;

		Account testAccount = TVE_TestUtility.createPersonAccount('acctName', testUserEmail);
		testAccount.PersonMailingStreet = 'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean m';   		
		insert testAccount;
		
		Account testAcc1 = TVE_TestUtility.createPersonAccount('acctName1', testUserEmail);
		insert testAcc1;       

		
		eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
		eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
		insert eSignObj;
			
		List<Project__c> lstProj = new List<Project__c>();
		lstProj.add(TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE));
		lstProj[0].AuthorisedRepresentative__c = testAccount.Id;
		//lstProj.add(TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE));
		lstProj[0].SiteOwner__c = testAcc1.Id;
         lstProj.add(TVE_TestUtility.createProject('test1',PROGRESS_BAR_STATUS,CON_TYPE));
		Insert lstProj;
        
        Map<Id,String> recordMap = new Map<Id,String>(); 
        recordMap.put(lstProj[0].id, lstProj[0].id);
        Map<String,String> creatIntTaskMap = new Map<String,String>();
        creatIntTaskMap.put('Operation__c', 'Get');
        creatIntTaskMap.put('SObject__c', 'Project__c');       
        creatIntTaskMap.put('Type__c', 'GetCustomer');
        creatIntTaskMap.put('Status__c', 'In Progress');        
        TVE_IntegUtility.CreateInteTask(recordMap,creatIntTaskMap); 
        
        Map<Id,String> recordMapReady = new Map<Id,String>(); 
        recordMapReady.put(lstProj[1].id, lstProj[1].id);
        Map<String,String> creatIntTaskMapReady = new Map<String,String>();
        creatIntTaskMapReady.put('Operation__c', 'Get');
        creatIntTaskMapReady.put('SObject__c', 'Project__c');       
        creatIntTaskMapReady.put('Type__c', 'GetCustomer');
        creatIntTaskMapReady.put('Status__c', 'Ready');  
        TVE_IntegUtility.CreateInteTask(recordMapReady,creatIntTaskMapReady); 
		 
	}

    @isTest static void testMethod1() {
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        List<Account> accList = [SELECT Id, SFDCUniqueId__c from Account];
     
         CustomerSets__x mockedCust1 = new CustomerSets__x(
                    City__c = 'Melbourne',
                    Country__c = 'AU',
                    CustName1__c = 'Test',
                    CustName2__c = 'Customer',
                    CustomerType__c = 'ELE',
                    Email__c = 'test@test.com',
                    Key__c = 'NC',
                    MsgId__c = 'a0E2N000000EDvC',
                    MobileNumber__c = '911',
                    ObjectName__c = 'CreateCustomer',
                    SourceSystem__c = 'Salesforce',
                    TargetSystem__c = 'ERP',
                    Postalcode__c = '3000', 
                    Previouseaccno__c = accList[0].SFDCUniqueId__c,
                    Region__c = 'VIC',
                    Street1__c = 'Unit 30',
                    Street2__c = '20 King Street',
                    Telephone__c = '911',
                    CustNumber__c = 'Cust0001' 
                );        
     	 	CustomerSets__x mockedCust2 = new CustomerSets__x(
                    City__c = 'Melbourne',
                    Country__c = 'AU',
                    CustName1__c = 'Test',
                    CustName2__c = 'Customer',
                    CustomerType__c = 'ELE',
                    Email__c = 'test@test.com',
                    Key__c = 'NC',
                    MsgId__c = 'a0E2N000000EDvC',
                    MobileNumber__c = '9116456456',
                    ObjectName__c = 'CreateCustomer',
                    SourceSystem__c = 'Salesforce',
                    TargetSystem__c = 'ERP',
                    Postalcode__c = '3000555', 
                    Previouseaccno__c = accList[1].SFDCUniqueId__c,
                    Region__c = 'VIC',
                    Street1__c = 'Unit 30',
                    Street2__c = '20 King Street',
                    Telephone__c = '911545435',
                    CustNumber__c = 'Cust0002' 
                );                
				
                TVE_SAPInteg_GetCustomer.mockedExtCust.add(mockedCust1);     
                TVE_SAPInteg_GetCustomer.mockedExtCust.add(mockedCust2);
        		TVE_SAPInteg_GetCustomer.mockedAccount.add(accList[0]);
        		TVE_SAPInteg_GetCustomer.mockedAccount.add(accList[1]);
        		TVE_SAPInteg_GetCustomer.ExceptionFlag = false;
        
            TVE_SAPInteg_GetCustomer getCustomer =  new TVE_SAPInteg_GetCustomer();       
            system.runas(testUser){                        
                System.enqueueJob(getCustomer);
            }       
    }	
    
     @isTest static void testMethod2() {
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        List<Account> accList = [SELECT Id, SFDCUniqueId__c from Account];
     
         CustomerSets__x mockedCust1 = new CustomerSets__x(
                    City__c = 'Melbourne',
                    Country__c = 'AU',
                    CustName1__c = 'Test',
                    CustName2__c = 'Customer',
                    CustomerType__c = 'ELE',
                    Email__c = 'test@test.com',
                    Key__c = 'NC',
                    MsgId__c = 'a0E2N000000EDvC',
                    MobileNumber__c = '911',
                    ObjectName__c = 'CreateCustomer',
                    SourceSystem__c = 'Salesforce',
                    TargetSystem__c = 'ERP',
                    Postalcode__c = '3000', 
                    Previouseaccno__c = accList[0].SFDCUniqueId__c,
                    Region__c = 'VIC',
                    Street1__c = 'Unit 30',
                    Street2__c = '20 King Street',
                    Telephone__c = '911',
                    CustNumber__c = 'Cust0001' 
                );        
     	 	CustomerSets__x mockedCust2 = new CustomerSets__x(
                    City__c = 'Melbourne',
                    Country__c = 'AU',
                    CustName1__c = 'Test',
                    CustName2__c = 'Customer',
                    CustomerType__c = 'ELE',
                    Email__c = 'test@test.com',
                    Key__c = 'NC',
                    MsgId__c = 'a0E2N000000EDvC',
                    MobileNumber__c = '9116456456',
                    ObjectName__c = 'CreateCustomer',
                    SourceSystem__c = 'Salesforce',
                    TargetSystem__c = 'ERP',
                    Postalcode__c = '3000555', 
                    Previouseaccno__c = accList[1].SFDCUniqueId__c,
                    Region__c = 'VIC',
                    Street1__c = 'Unit 30',
                    Street2__c = '20 King Street',
                    Telephone__c = '911545435',
                    CustNumber__c = 'Cust0002' 
                );                
				
                TVE_SAPInteg_GetCustomer.mockedExtCust.add(mockedCust1);     
                TVE_SAPInteg_GetCustomer.mockedExtCust.add(mockedCust2);
        		TVE_SAPInteg_GetCustomer.mockedAccount.add(accList[0]);
         		TVE_SAPInteg_GetCustomer.mockedAccount.add(accList[1]);
        		TVE_SAPInteg_GetCustomer.ExceptionFlag = true;
            TVE_SAPInteg_GetCustomer getCustomer =  new TVE_SAPInteg_GetCustomer();       
            system.runas(testUser){                        
                System.enqueueJob(getCustomer);
            }       
    }	
    
}