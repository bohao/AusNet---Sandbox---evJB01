/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 29 Sep 2019
  @Description : Test Class for Contact Triggers
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                                 NA
  -----------------------------------------------------------------------------------------
*/
@isTest
private class Trig_Contact_Test
{
    private static String custEmailNotifLogic = 'customer@test12345.com';
	
	@testSetup static void setup()
    {
		// ------------------------------------------------------------- //
        // -------- Data setup for Notification field: Start------------ //
        // ------------------------------------------------------------ //

        //Create Individual Account
        Account testCustomer = DER_TestUtility.createPersonAccount('Person Account', 'test@test12345.com');
        insert testCustomer;
        
        //Create Connection Point
        Connection_Point__c testConnectionPoint = DER_TestUtility.createConnectionPoint(testCustomer.Id);
        Insert testConnectionPoint;
        
        DER_Application__c testDERApp = DER_TestUtility.createDERApplication(testConnectionPoint.Id);
        Insert testDERApp;
        
        //Create Business Account
        Account testInstaller = DER_TestUtility.createBusinessAccount('Business Account');
        insert testInstaller;
        
        //Create Business Account's Contact
        Contact testInstallerContact = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Installer', custEmailNotifLogic);
        insert testInstallerContact;

        //Create Business Account
        Account testRepAcc = DER_TestUtility.createBusinessAccount('Representative Business Account');
        insert testRepAcc;
        
        //Create Business Account's Contact
        Contact testRep = DER_TestUtility.createBusinessAccountContact(testInstaller.Id, 'Test', 'Representative', 'representative@test12345.com');
        insert testRep;

        //Create case with customer, installer & representative
        Case testCaseNotifLogic = DER_TestUtility.createCaseWith_Installer_Customer_Rep(testDERApp.Id,
                                                                         DER_REST_Application_v1.CASE_RECORDTYPE_AUTO, 
                                                                         'New', 'Email', 'Medium', 
                                                                         testInstaller.Id, testInstallerContact.Id, 
                                                                         testCustomer.Id, testRep.Id,
                                                                         Trig_Case.APPLICANT_REP, Trig_Case.RESP_PARTY_REP);
        insert testCaseNotifLogic;

        // -------- Data setup for Notification field: End ------------ //
	}

	@isTest static void test_REP_UPDATE()
	{
		String queryCase = '';
            queryCase += UtilDatabase.getAllFields('Case');
            queryCase += ' FROM Case ';
			queryCase += ' WHERE ContactEmail =\''+ custEmailNotifLogic + '\' LIMIT 1';  
		
		List<Case> lstCase = Database.query(queryCase);

        Contact rep = DER_TestUtility.createBusinessAccountContact(lstCase[0].AccountId, 'Rep', 'Test', 'test@testapplicanttypeREP.com');
		Insert rep;
        
		lstCase[0].Applicant_Type__c = Trig_Case.APPLICANT_REP;
        lstCase[0].Responsible_Party__c = Trig_Case.RESP_PARTY_REP;
        lstCase[0].Representative__c = rep.Id;
		update lstCase[0];
		
		test.startTest();
		
	    rep.FirstName = 'Test';
        rep.LastName = 'Test';
        rep.Email = 'test@testinstallerupdate.com';
        
        update rep;       
				
		test.stopTest();            
		
		lstCase = Database.query(queryCase);

		System.assertEquals('Test' + ' ' + 'Test', lstCase[0].Applicant_Name__c);
        System.assertEquals('Test' + ' ' + 'Test', lstCase[0].Resp_Party_Name__c);
        System.assertEquals('test@testinstallerupdate.com', lstCase[0].Applicant_Email__c);
        System.assertEquals('test@testinstallerupdate.com', lstCase[0].Resp_Party_Email__c);
	}

    @isTest static void test_INSTALLER_UPDATE()
	{
		String queryCase = '';
            queryCase += UtilDatabase.getAllFields('Case');
            queryCase += ' FROM Case ';
			queryCase += ' WHERE ContactEmail =\''+ custEmailNotifLogic + '\' LIMIT 1';  

		List<Case> lstCase = Database.query(queryCase);
		lstCase[0].Responsible_Party__c = Trig_Case.APPLICANT_INSTALLER;
        lstCase[0].Applicant_Type__c = Trig_Case.RESP_PARTY_INSTALLER;
        update lstCase[0];

		System.assertNotEquals(null, lstCase[0].ContactId);

		test.startTest();

		Contact installerContact = [SELECT Id, FirstName, LastName, Email
									FROM Contact 
									WHERE Id =: lstCase[0].ContactId LIMIT 1];
                
        installerContact.FirstName = 'Test';
        installerContact.LastName = 'Test';
        installerContact.Email = 'test@testinstallerupdate.com';
        
        update installerContact;
        
		test.stopTest();            
		
        queryCase = '';
            queryCase += UtilDatabase.getAllFields('Case');
            queryCase += ' FROM Case ';
			queryCase += ' WHERE ContactEmail =\'test@testinstallerupdate.com\' LIMIT 1';  

		lstCase = Database.query(queryCase);

		System.assertEquals('Test' + ' ' + 'Test', lstCase[0].Applicant_Name__c);
        System.assertEquals('Test' + ' ' + 'Test', lstCase[0].Resp_Party_Name__c);
        System.assertEquals('test@testinstallerupdate.com', lstCase[0].Applicant_Email__c);
        System.assertEquals('test@testinstallerupdate.com', lstCase[0].Resp_Party_Email__c);
	}	
    
    @isTest static void test_UOMContactInsert1()
    {
        test.startTest();
        Outage_DataFactory odf = Outage_DataFactory.getODF();
        odf.generateCustomers(2);
        
        odf.cons[0].HomePhone = '04' + Outage_DataFactory.randomNum(8);
        odf.cons[0].CE_Email_Address__c = odf.cons[0].FirstName.toLowerCase()+Outage_DataFactory.randomNum(1) + '@' + odf.cons[0].LastName.toLowerCase() + '.com.invalid';
        odf.cons[0].CE_Phone_Number__c='04' + Outage_DataFactory.randomNum(8);
        
        odf.cons[1].Email = '';
        odf.cons[1].Phone = '';
        
        update odf.cons;

        odf.cons[0].Email = '';
        odf.cons[0].Phone = '';
        odf.cons[0].HomePhone = '';
        odf.cons[0].CE_Email_Address__c = '';
        odf.cons[0].CE_Phone_Number__c='';
        
        odf.cons[1].Email = odf.cons[0].FirstName.toLowerCase()+Outage_DataFactory.randomNum(1) + '@' + odf.cons[0].LastName.toLowerCase() + '.com.invalid';
        odf.cons[1].Phone = '04' + Outage_DataFactory.randomNum(8);
        odf.cons[1].HomePhone = '4' + Outage_DataFactory.randomNum(8);
        odf.cons[1].CE_Email_Address__c = odf.cons[0].FirstName.toLowerCase() +Outage_DataFactory.randomNum(1)+ '@' + odf.cons[0].LastName.toLowerCase() + '.com.invalid';
        odf.cons[1].CE_Phone_Number__c='04' + Outage_DataFactory.randomNum(8);
        
		update odf.cons;
        
        odf.cons[0].Email = odf.cons[0].FirstName.toLowerCase()+Outage_DataFactory.randomNum(1) + '@' + odf.cons[0].LastName.toLowerCase() + '.com.invalid';
        odf.cons[0].Phone = '04' + Outage_DataFactory.randomNum(8);
        odf.cons[0].HomePhone = '4' + Outage_DataFactory.randomNum(8);
        odf.cons[0].CE_Email_Address__c = odf.cons[0].FirstName.toLowerCase() +Outage_DataFactory.randomNum(1)+ '@' + odf.cons[0].LastName.toLowerCase() + '.com.invalid';
        odf.cons[0].CE_Phone_Number__c='04' + Outage_DataFactory.randomNum(8);
        
        odf.cons[1].Email = odf.cons[0].FirstName.toLowerCase()+Outage_DataFactory.randomNum(1) + '@' + odf.cons[0].LastName.toLowerCase() + '.com.invalid';
        odf.cons[1].Phone = '04' + Outage_DataFactory.randomNum(8);
        odf.cons[1].HomePhone = '4' + Outage_DataFactory.randomNum(8);
        odf.cons[1].CE_Email_Address__c = odf.cons[0].FirstName.toLowerCase() +Outage_DataFactory.randomNum(1)+ '@' + odf.cons[0].LastName.toLowerCase() + '.com.invalid';
        odf.cons[1].CE_Phone_Number__c='04' + Outage_DataFactory.randomNum(8);
       
        update odf.cons;
        test.stopTest();  
    } 

    @isTest
    static void AfterUpdateHandleMarketingCloudContactTest() {
        Integer numCustomers = 2;
        Outage_DataFactory.getODF().generateCustomers(numCustomers);
        List<Contact> consODF = Outage_DataFactory.getODF().cons;
        List<Account> accsODF = Outage_DataFactory.getODF().accs;
        List<AccountContactRelation> acrsODF = Outage_DataFactory.getODF().ACRs;
        
        // Update ACRS and Account so that Contacts MC_Contact__c fields are set to false
        List<AccountContactRelation> acrsToUpdate = new List<AccountContactRelation>();
        for (AccountContactRelation acr : acrsODF) {
            acr.Roles = '';
            acrsToUpdate.add(acr);
        }
        update acrsToUpdate;

        // Get Contacts
        List<Contact> conList = [SELECT Id, AccountId, MC_Contact__c FROM Contact WHERE Id IN :consODF];
        Contact con1 = conList.get(0);
        Contact con2 = conList.get(1);
        Id acc1Id = con1.AccountId;
        Id acc2Id = con2.AccountId;

        List<Contact> consToUpdate = new List<Contact>();
        // Set one record type to a non (dcp_Contact) record type and remove account lookup
        con1.RecordTypeId = UtilDatabase.getRecordTypeNames('Contact').get('REMI_Contact');
        con1.AccountId = null;
        consToUpdate.add(con1);

        con2.AccountId = null;
        consToUpdate.add(con2);

        update consToUpdate;

        // set MC_Contact__c fields to false
        for (Contact con : consToUpdate) {
            con.MC_Contact__c = false;
        }
        
        update consToUpdate;

        con1 = [SELECT Id, MC_Contact__c FROM Contact WHERE id = :con1.Id LIMIT 1];
        con2 = [SELECT Id, MC_Contact__c FROM Contact WHERE id = :con2.Id LIMIT 1];
        
        Test.startTest();
        // Validate initial data setup is correct
        Assert.isFalse(con1.MC_Contact__c, 'MC_Contact__c should be set to false');
        Assert.isFalse(con2.MC_Contact__c, 'MC_Contact__c should be set to false');

        // Reset Trigger catch so method tries to execute
        Trig_Contact.isRunningHandleMarketingCloudContact = false;

        // Update contact and retrieve the updated contact
        con1.AccountId = acc1Id;
        update con1;

        con1 = [SELECT Id, MC_Contact__c FROM Contact WHERE id = :con1.Id LIMIT 1];
        
        // Validate MC_Contact__c did not update for non (dcp_Contact)
        Assert.isFalse(con1.MC_Contact__c, 'MC_Contact__c should be set to false');

        // Reset Trigger catch so method tries to execute
        Trig_Contact.isRunningHandleMarketingCloudContact = false;

        // Update contact and retrieve the updated contact
        con2.AccountId = acc2Id;
        update con2;

        con2 = [SELECT Id, MC_Contact__c FROM Contact WHERE id = :con2.Id LIMIT 1];

        // Validate MC_Contact__c did update for a (dcp_Contact)
        Assert.isTrue(con2.MC_Contact__c, 'MC_Contact__c should be set to true');

        Test.stopTest();
	}
}