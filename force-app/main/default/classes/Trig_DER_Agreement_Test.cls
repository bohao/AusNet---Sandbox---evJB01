/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 07 Oct 2019
  @Description : Test Class for Trig_DER_Agreement and DERAgreementTrigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                                 NA
  -----------------------------------------------------------------------------------------
*/
@isTest
private class Trig_DER_Agreement_Test
{
    private static String customerEmail = 'customer@test12345.com';
    private static String installerEmail = 'installer@test12345.com';
    private static String repEmail = 'rep@test12345.com';
	private static String DER_AGMT_STATUS_OFFER_MADE = 'Offer Made';
    private static String DER_AGMT_STATUS_OFFER_ACCPT = 'Offer Accepted';
    private static String DER_AGMT_STATUS_DECLINED = 'Offer Declined';
    private static String CASE_REASON_DECLINED = 'Applicant Declined';
    private static String CASE_STATUS_CANCELLED = 'Cancelled';
    private static String DER_AGMT_OFFERTYPE_BASIC_MICRO = 'Basic Micro EG MSO';
    private static String CASE_STATUS_INSTALLATION_PENDING = 'Installation Pending';
        
	@testSetup static void setup()
    {
		Id testDERAppId = DER_TestUtility.loadDERAppRecords(customerEmail, installerEmail, repEmail);
	}

	@isTest static void test_Agreement_INSERT()
	{
		String queryCase = '';
            queryCase += UtilDatabase.getAllFields('Case');
            queryCase += ' FROM Case ';
			queryCase += ' WHERE ContactEmail =\''+ installerEmail + '\' LIMIT 1';  
		
		List<Case> lstCase = Database.query(queryCase);
		System.assertEquals(null, lstCase[0].Contract_Status__c);
        System.assertEquals(null, lstCase[0].Offer_Accepted_Date__c);
        System.assertEquals(null, lstCase[0].Offer_Expiration_Date__c);

        test.startTest();
	    
        DER_Agreement__c testAgmnt = DER_TestUtility.createAgreement(lstCase[0].DER_Application__c, 
                                                                     lstCase[0].AccountId, 
                                                                     DER_AGMT_STATUS_OFFER_MADE, 
                                                                     System.today() + 5,
                                                                     System.today(), 
                                                                     DER_AGMT_OFFERTYPE_BASIC_MICRO);
        insert testAgmnt;
				
		test.stopTest();            
		
		lstCase = Database.query(queryCase);
        testAgmnt = [SELECT Id, Offer_Expiration_Date__c 
                        FROM DER_Agreement__c 
                        WHERE Id =: testAgmnt.Id];

		System.assertEquals(DER_AGMT_STATUS_OFFER_MADE, lstCase[0].Contract_Status__c);
        System.assertEquals(System.today() + 5, lstCase[0].Offer_Accepted_Date__c);
        System.assertEquals(testAgmnt.Offer_Expiration_Date__c, lstCase[0].Offer_Expiration_Date__c);
	}
    
    @isTest static void test_Agreement_INSERT_OfferAccepted()
	{
		String queryCase = '';
            queryCase += UtilDatabase.getAllFields('Case');
            queryCase += ' FROM Case ';
			queryCase += ' WHERE ContactEmail =\''+ installerEmail + '\' LIMIT 1';  
		
		List<Case> lstCase = Database.query(queryCase);
		System.assertEquals('New', lstCase[0].status);
        test.startTest();
	    
        DER_Agreement__c testAgmnt = DER_TestUtility.createAgreement(lstCase[0].DER_Application__c, 
                                                                     lstCase[0].AccountId, 
                                                                     DER_AGMT_STATUS_OFFER_ACCPT, 
                                                                     System.today() + 5,
                                                                     System.today(), 
                                                                     DER_AGMT_OFFERTYPE_BASIC_MICRO);
        insert testAgmnt;
				
		test.stopTest();            
		
		lstCase = Database.query(queryCase);
        testAgmnt = [SELECT Id, Offer_Expiration_Date__c 
                        FROM DER_Agreement__c 
                        WHERE Id =: testAgmnt.Id];

		System.assertEquals(CASE_STATUS_INSTALLATION_PENDING, lstCase[0].status);
        }
    
    @isTest static void test_Agreement_UPDATE_OFFER_ACCEPTED()
	{
		String queryCase = '';
            queryCase += UtilDatabase.getAllFields('Case');
            queryCase += ' FROM Case ';
			queryCase += ' WHERE ContactEmail =\''+ installerEmail + '\' LIMIT 1';  

        List<Case> lstCase = Database.query(queryCase);
        
        DER_Agreement__c testAgmnt = DER_TestUtility.createAgreement(lstCase[0].DER_Application__c, 
                                                                     lstCase[0].AccountId, 
                                                                     DER_AGMT_STATUS_OFFER_MADE, 
                                                                     System.today() + 5,
                                                                     System.today(), 
                                                                     DER_AGMT_OFFERTYPE_BASIC_MICRO);
        insert testAgmnt;
		
        test.startTest();
        
		DER_Agreement__c agmtUpd = [SELECT Id, Status__c, DER_Application__c, Offer_Accepted_Date__c, Offer_Made_Date__c
									FROM DER_Agreement__c 
									WHERE Id =: testAgmnt.Id LIMIT 1];
                
        agmtUpd.Status__c = DER_AGMT_STATUS_OFFER_ACCPT;
        update agmtUpd;
        
        agmtUpd.Contract_Active_Date__c = null;
        agmtUpd.Offer_Accepted_By__c = '';
        update agmtUpd;
        
		test.stopTest();            
		
        lstCase = Database.query(queryCase);
        testAgmnt = [SELECT Id, Offer_Expiration_Date__c 
                                FROM DER_Agreement__c 
                                WHERE Id =: testAgmnt.Id];

		System.assertEquals(CASE_STATUS_INSTALLATION_PENDING, lstCase[0].status);
        }
	@isTest static void test_Agreement_INSERT_Offer_DECLINED()
	{
		String queryCase = '';
            queryCase += UtilDatabase.getAllFields('Case');
            queryCase += ' FROM Case ';
			queryCase += ' WHERE ContactEmail =\''+ installerEmail + '\' LIMIT 1';  
		
		List<Case> lstCase = Database.query(queryCase);
		System.assertEquals('New', lstCase[0].status);
        System.assertEquals(null, lstCase[0].Cancelled_Reason__c);
        test.startTest();
	    
        DER_Agreement__c testAgmnt = DER_TestUtility.createAgreement(lstCase[0].DER_Application__c, 
                                                                     lstCase[0].AccountId, 
                                                                     DER_AGMT_STATUS_DECLINED, 
                                                                     System.today() + 5,
                                                                     System.today(), 
                                                                     DER_AGMT_OFFERTYPE_BASIC_MICRO);
        insert testAgmnt;
				
		test.stopTest();            
		
		lstCase = Database.query(queryCase);
        testAgmnt = [SELECT Id, Offer_Expiration_Date__c 
                        FROM DER_Agreement__c 
                        WHERE Id =: testAgmnt.Id];

		System.assertEquals(CASE_STATUS_CANCELLED, lstCase[0].status);
        System.assertEquals(CASE_REASON_DECLINED, lstCase[0].Cancelled_Reason__c);
        }
    
    @isTest static void test_Agreement_UPDATE_OFFER_DECLINED()
	{
		String queryCase = '';
            queryCase += UtilDatabase.getAllFields('Case');
            queryCase += ' FROM Case ';
			queryCase += ' WHERE ContactEmail =\''+ installerEmail + '\' LIMIT 1';  

        List<Case> lstCase = Database.query(queryCase);
        
        DER_Agreement__c testAgmnt = DER_TestUtility.createAgreement(lstCase[0].DER_Application__c, 
                                                                     lstCase[0].AccountId, 
                                                                     DER_AGMT_STATUS_OFFER_MADE, 
                                                                     System.today() + 5,
                                                                     System.today(), 
                                                                     DER_AGMT_OFFERTYPE_BASIC_MICRO);
        insert testAgmnt;
		
        test.startTest();
        
		DER_Agreement__c agmtUpd = [SELECT Id, Status__c, DER_Application__c, Offer_Accepted_Date__c, Offer_Made_Date__c
									FROM DER_Agreement__c 
									WHERE Id =: testAgmnt.Id LIMIT 1];
                
        agmtUpd.Status__c = DER_AGMT_STATUS_DECLINED;
        update agmtUpd;
        
		test.stopTest();            
		
        lstCase = Database.query(queryCase);
        testAgmnt = [SELECT Id, Offer_Expiration_Date__c 
                                FROM DER_Agreement__c 
                                WHERE Id =: testAgmnt.Id];

		System.assertEquals(CASE_STATUS_CANCELLED, lstCase[0].status);
        System.assertEquals(CASE_REASON_DECLINED, lstCase[0].Cancelled_Reason__c);
        }

    @isTest static void test_Agreement_UPDATE()
	{
		String queryCase = '';
            queryCase += UtilDatabase.getAllFields('Case');
            queryCase += ' FROM Case ';
			queryCase += ' WHERE ContactEmail =\''+ installerEmail + '\' LIMIT 1';  

        List<Case> lstCase = Database.query(queryCase);
        
        DER_Agreement__c testAgmnt = DER_TestUtility.createAgreement(lstCase[0].DER_Application__c, 
                                                                     lstCase[0].AccountId, 
                                                                     DER_AGMT_STATUS_OFFER_MADE, 
                                                                     System.today() + 5, 
                                                                     System.today(),
                                                                     DER_AGMT_OFFERTYPE_BASIC_MICRO);
        insert testAgmnt;
		
        test.startTest();
        
		DER_Agreement__c agmtUpd = [SELECT Id, Status__c, DER_Application__c, Offer_Accepted_Date__c, Offer_Made_Date__c
									FROM DER_Agreement__c 
									WHERE Id =: testAgmnt.Id LIMIT 1];
                
        agmtUpd.Status__c = DER_AGMT_STATUS_OFFER_ACCPT;
        agmtUpd.Offer_Accepted_Date__c = System.today() + 5;
        agmtUpd.Offer_Made_Date__c = System.today();
        update agmtUpd;
        
		test.stopTest();            
		
        lstCase = Database.query(queryCase);
        testAgmnt = [SELECT Id, Offer_Expiration_Date__c 
                                FROM DER_Agreement__c 
                                WHERE Id =: testAgmnt.Id];

		System.assertEquals(DER_AGMT_STATUS_OFFER_ACCPT, lstCase[0].Contract_Status__c);
        System.assertEquals(System.today() + 5, lstCase[0].Offer_Accepted_Date__c);
        System.assertEquals(testAgmnt.Offer_Expiration_Date__c, lstCase[0].Offer_Expiration_Date__c);
	}	

    @isTest static void test_Agreement_CLEAR_STATUS()
	{
		String queryCase = '';
            queryCase += UtilDatabase.getAllFields('Case');
            queryCase += ' FROM Case ';
			queryCase += ' WHERE ContactEmail =\''+ installerEmail + '\' LIMIT 1';  

        List<Case> lstCase = Database.query(queryCase);
        
        DER_Agreement__c testAgmnt = DER_TestUtility.createAgreement(lstCase[0].DER_Application__c, 
                                                                     lstCase[0].AccountId, 
                                                                     DER_AGMT_STATUS_OFFER_MADE, 
                                                                     System.today() + 5, 
                                                                     System.today(),
                                                                     DER_AGMT_OFFERTYPE_BASIC_MICRO);
        insert testAgmnt;
		
        test.startTest();

		DER_Agreement__c agmtUpd = [SELECT Id, Status__c, DER_Application__c, Offer_Accepted_Date__c, Offer_Made_Date__c
									FROM DER_Agreement__c 
									WHERE Id =: testAgmnt.Id LIMIT 1];
                
        agmtUpd.Status__c = null;
        agmtUpd.Offer_Accepted_Date__c = null;
        agmtUpd.Offer_Made_Date__c = null;
        update agmtUpd;
        
		test.stopTest();            
		
        lstCase = Database.query(queryCase);

		System.assertEquals(null, lstCase[0].Contract_Status__c);
        System.assertEquals(null, lstCase[0].Offer_Accepted_Date__c);
        System.assertEquals(null, lstCase[0].Offer_Expiration_Date__c);
	}	

    @isTest static void test_Agreement_CLEAR_DERAPP()
	{
		String queryCase = '';
            queryCase += UtilDatabase.getAllFields('Case');
            queryCase += ' FROM Case ';
			queryCase += ' WHERE ContactEmail =\''+ installerEmail + '\' LIMIT 1';  

        List<Case> lstCase = Database.query(queryCase);
        
        DER_Agreement__c testAgmnt = DER_TestUtility.createAgreement(lstCase[0].DER_Application__c, 
                                                                     lstCase[0].AccountId, 
                                                                     DER_AGMT_STATUS_OFFER_MADE, 
                                                                     System.today() + 5, 
                                                                     System.today(),
                                                                     DER_AGMT_OFFERTYPE_BASIC_MICRO);
        insert testAgmnt;
		
        test.startTest();

		DER_Agreement__c agmtUpd = [SELECT Id, Status__c, DER_Application__c
									FROM DER_Agreement__c 
									WHERE Id =: testAgmnt.Id LIMIT 1];
                
        agmtUpd.DER_Application__c = null;
        update agmtUpd;
        
		test.stopTest();            
		
        lstCase = Database.query(queryCase);

		System.assertEquals(null, lstCase[0].Contract_Status__c);
        System.assertEquals(null, lstCase[0].Offer_Accepted_Date__c);
        System.assertEquals(null, lstCase[0].Offer_Expiration_Date__c);
	}	
}