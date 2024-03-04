public class DER_Application_Controller {
	@AuraEnabled 
	public static String retrieveNmi(String extId) {
		List<MeterDataSets__x> mdsList = new List<MeterDataSets__x>();
		List<NmiDataSets__x> nmiList;
		try {
			nmiList = [SELECT   Id, Nmi__c, 
							StrSuppl1__c,
							HouseNum1__c, 
							HouseNum2__c, 
							HausNum2__c,
							Floor__c, 
							Street__c, 
							Region__c, 
							City1__c,
							PostCode1__c 
					FROM    NmiDataSets__x 
					WHERE   ExternalId = :extId];

		} catch(Exception e) {
			return 'None';
		}

		try {
			mdsList = [SELECT   Id, 
								CurrentStatus__c, 
								SerialNumber__c, 
								DeviceType__c, 
								InstallTypeCode__c, 
								MeterPrefix__c, 
								MeterProgram__c, 
								Nmi__c 
						FROM    MeterDataSets__x 
						WHERE   Nmi__c = :extId];
		} catch (Exception e) {

		}

		if(!nmiList.isEmpty()) {
			MeterWrapper wrapper = new MeterWrapper();
			NmiDataSets__x nmi = nmiList[0];
			wrapper.address = '';
			if(nmi.StrSuppl1__c != null) {
				wrapper.address += nmi.StrSuppl1__c + ' ';
			} 
			if(nmi.HouseNum1__c != null) {
				wrapper.address += nmi.HouseNum1__c + ' ';
			}
			if(nmi.HouseNum2__c != null) {
				wrapper.address += nmi.HouseNum2__c + ' ';
			}
			if(nmi.HausNum2__c != null) {
				wrapper.address += nmi.HausNum2__c + ' ';
			}
			if(nmi.Floor__c != null) {
				wrapper.address += nmi.Floor__c + ' ';
			}
			if(nmi.Street__c != null) {
				wrapper.address += nmi.Street__c + ' ';
			}
			if(nmi.PostCode1__c != null) {
				wrapper.address += nmi.PostCode1__c + ' ';
			}
			if(nmi.City1__c != null) {
				wrapper.address += nmi.City1__c + ' ';
			}
			if(nmi.Region__c != null) {
				wrapper.address += nmi.Region__c;
			}

			for(MeterDataSets__x mds : mdsList) {
				wrapper.serialList.add(mds.SerialNumber__c);
			}

			return JSON.serialize(wrapper);
		} else {
			return 'None';
		}
		
	}

	public class MeterWrapper {
		String address;
		List<String> serialList = new List<String>();
	}

	@AuraEnabled
	public static String saveRecords(
		ResultWrapper wrapper
	) {
		System.debug('wrapper is: ' + wrapper);
		String CASE_ORIGIN_DIRECT_ENTRY = 'Direct Entry';
		try {
			Connection_Point__c cp = new Connection_Point__c();
			List<Connection_Point__c> cplist = [Select Id, Name, NMI__c From Connection_Point__c Where NMI__c = :wrapper.nmi];
			if(!cpList.isEmpty()) {
				cp = cpList[0];
			} else {
				cp.NMI__c = wrapper.nmi;
				cp.Name = wrapper.nmi;
				insert cp;
			}

			Account customerAcc = new Account();
			customerAcc.Salutation = wrapper.customerSalutation;
			customerAcc.FirstName = wrapper.customerFirstName;
			customerAcc.LastName = wrapper.customerLastName;
			customerAcc.PersonEmail = wrapper.customerEmail;
			customerAcc.Phone = wrapper.customerPhone;
			customerAcc.PersonMailingStreet = wrapper.mailingStreet;
			customerAcc.PersonMailingCity = wrapper.mailingCity;
			customerAcc.PersonMailingState = wrapper.mailingState;
			customerAcc.PersonMailingPostalCode = wrapper.mailingPostal;
			customerAcc.PersonMailingCountry = wrapper.mailingCountry;
			customerAcc.RecordTypeId = UtilDatabase.getRecordTypeNames('Account').get(DER_REST_Application_v1.ACCOUNT_RECORDTYPE_INDIVIDUAL);
			customerAcc.Customer_Type__c = 'ELE - DER';
			insert customerAcc;

			Account installerAcc = new Account();
			if(wrapper.installerAccId != null && wrapper.installer != '') {
				installerAcc.Id = wrapper.installerAccId;
			} else {
				installerAcc.Name = wrapper.installer;
				installerAcc.ABN__c = wrapper.abn;
				installerAcc.Phone = wrapper.phone;
				installerAcc.ShippingStreet = wrapper.shippingStreet;
				installerAcc.ShippingCity = wrapper.shippingCity;
				installerAcc.ShippingState = wrapper.shippingState;
				installerAcc.ShippingPostalCode = wrapper.shippingPostal;
				installerAcc.ShippingCountry = wrapper.shippingCountry;
				installerAcc.Type = 'Installer';
				installerAcc.Customer_Type__c = 'ELE - DER';

				insert installerAcc;
			}
			
			Contact installerCon = new Contact();
			if(wrapper.installerContactId != null && wrapper.installerContactId != '') {
				installerCon.Id = wrapper.installerContactId;
			} else {
				installerCon.Salutation = wrapper.installerSalutation;
				installerCon.FirstName = wrapper.installerFirstName;
				installerCon.LastName = wrapper.installerLastName;
				installerCon.Acceditation_Type__c = wrapper.accreditationType;
				installerCon.Accreditation_Number__c = wrapper.accreditationNumber;
				installerCon.Email = wrapper.installerContactEmail;
				installerCon.Phone = wrapper.installerContactPhone;
				installerCon.AccountId = installerAcc.Id;
				installerCon.Title = 'Installer';

				insert installerCon;
			}

			// TODO: Wizard is created orphaned Rep contacts. This is no good.
			Contact rep = new Contact();
			Boolean repExist = true;
			if(wrapper.repId != null && wrapper.repId != '') {
				rep.Id = wrapper.repId;
			} else {
				if(String.isNotBlank(wrapper.repLastName) && String.isNotEmpty(wrapper.repLastName)) {
					rep.Salutation = wrapper.repSalutation;
					rep.FirstName = wrapper.repFirstName;
					rep.LastName = wrapper.repLastName;
					rep.Email = wrapper.repEmail;
					rep.Title = 'Customer Representative';

					insert rep;
				} else {
					repExist = false;
				}
			}

			DER_Application__c app = new DER_Application__c();
			app.NMI__c = cp.Id;
			app.Meter_Number__c = wrapper.meter;
			app.Case_Status__c  = wrapper.caseStatus;
			app.Case_Type__c  = wrapper.caseType;
			app.DER_Scenario__c = 'Manual';
			app.Case_Origin__c = CASE_ORIGIN_DIRECT_ENTRY;
			app.Import_Existing_Assets__c = wrapper.importExistingAssets;
			insert app;

			Id queueId = [SELECT Id FROM Group WHERE Name = 'DER Apps - New Conns' AND Type = 'Queue'][0].Id;

			Case c = new Case();
			c.AccountId = installerAcc.Id;
			c.ContactId = installerCon.Id;
			c.Customer__c = customerAcc.Id;
			c.Status = wrapper.caseStatus;
			c.DER_Application__c = app.Id;
			c.Invoice_Number__c = wrapper.invNum;
			c.RecordTypeId = UtilDatabase.getRecordTypeNames('Case').get(DER_REST_Application_v1.CASE_RECORDTYPE_MANUAL);
			c.Origin = CASE_ORIGIN_DIRECT_ENTRY;
			c.DER_Application_Scenario__c = 'Manual';
			c.Agreement_Type__c = wrapper.agreementType;
			c.Applicant_Type__c = wrapper.applicantType;
			c.Responsible_Party__c = wrapper.resParty;
			c.Enable_Notifications__c = wrapper.enableNotifications;
			c.Type = wrapper.caseType;

			if (repExist)
				c.Representative__c = rep.Id;

			if (queueId != null)
				c.OwnerId = queueId;

			insertCase(c);

			// app.Import_Existing_Assets__c = wrapper.importExistingAssets;
			// update app;

			if(wrapper.createAgreement) {
				DER_Agreement__c agg = new DER_Agreement__c();
				agg.Account__c = installerAcc.Id;
				agg.Offer_Type__c = wrapper.agreementType;
				agg.DER_Application__c = app.Id;
				agg.NMI__c = cp.Id;
				agg.Status__c = wrapper.agreementStatus;
				agg.Offer_Accepted_Date__c = wrapper.acceptedDate;
				agg.Contract_Active_Date__c = wrapper.activeDate;
				agg.Offer_Made_Date__c = wrapper.offerMadeDate;
				insert agg;
			}

			return c.Id;
		} catch (Exception e) {
			return 'Error: ' + e.getMessage();
		}
	}

	@AuraEnabled(cacheable=true)
	public static string getRecordTypeId(String objAPIName, String rtDevName){
		return Id.valueOf(UtilDatabase.getRecordTypeNames(objAPIName).get(rtDevName));
	}

	public class ResultWrapper {
		@AuraEnabled public String nmi {get; set;}
		@AuraEnabled public String meter {get; set;}
		@AuraEnabled public String installer {get; set;}
		@AuraEnabled public String agreementStatus {get; set;}
		@AuraEnabled public String installerSalutation {get; set;}
		@AuraEnabled public String installerFirstName {get; set;}
		@AuraEnabled public String installerLastName {get; set;}
		@AuraEnabled public String accreditationType {get; set;}
		@AuraEnabled public String accreditationNumber {get; set;}
		@AuraEnabled public String installerContactEmail {get; set;}
		@AuraEnabled public String installerContactPhone {get; set;}
		@AuraEnabled public String installerAccId {get; set;}
		@AuraEnabled public String installerContactId {get; set;}
		@AuraEnabled public String repId {get; set;}
		@AuraEnabled public String abn {get; set;}
		@AuraEnabled public String phone {get; set;}
		@AuraEnabled public String shippingStreet {get; set;}
		@AuraEnabled public String shippingCity {get; set;}
		@AuraEnabled public String shippingState {get; set;}
		@AuraEnabled public String shippingPostal {get; set;}
		@AuraEnabled public String shippingCountry {get; set;}
		@AuraEnabled public String mailingStreet {get; set;}
		@AuraEnabled public String mailingCity {get; set;}
		@AuraEnabled public String mailingState {get; set;}
		@AuraEnabled public String mailingPostal {get; set;}
		@AuraEnabled public String mailingCountry {get; set;}
		@AuraEnabled public String repSalutation {get; set;}
		@AuraEnabled public String repFirstName {get; set;}
		@AuraEnabled public String repLastName {get; set;}
		@AuraEnabled public String repEmail {get; set;}
		@AuraEnabled public String customerSalutation {get; set;}
		@AuraEnabled public String customerFirstName {get; set;}
		@AuraEnabled public String customerLastName {get; set;}
		@AuraEnabled public String customerEmail {get; set;}
		@AuraEnabled public String customerPhone {get; set;}
		@AuraEnabled public String caseStatus {get; set;}
		@AuraEnabled public String invNum {get; set;}
		@AuraEnabled public String agreementType {get; set;}
		@AuraEnabled public String applicantType {get; set;}
		@AuraEnabled public String caseType {get; set;}
		@AuraEnabled public String resParty {get; set;}
		@AuraEnabled public Boolean createAgreement {get; set;}
		@AuraEnabled public Date acceptedDate {get; set;}
		@AuraEnabled public Date activeDate {get; set;}
		@AuraEnabled public Date offerMadeDate {get; set;}
		@AuraEnabled public Boolean enableNotifications {get; set;}
		@AuraEnabled public Boolean importExistingAssets {get; set;}
	}

	private static void insertCase(Case derCase)
	{
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule = false;
		derCase.setOptions(dmo);
		insert derCase;
	}
}