public with sharing class Outage_DataFactory
{
	// *********************************************************************
	// *** Member vars
	public List<vlocity_cmt__Premises__c> premises;
	public List<vlocity_cmt__ServicePoint__c> nmis;
	public List<Account> accs;
	public List<Contact> cons;
	public List<AccountContactRelation> ACRs;
	public List<ContactPointEmail> CPEmails;
	public List<ContactPointPhone> CPPhones;
	public List<ContactPointConsent> CPConsents;
	public Map<String, EngagementChannelType> channels;
	public DataUsePurpose purpose;

	public List<Incident> incidents;
	public List<Task> tasks;
	public List<Affected_Customer__c> affCusts = new List<Affected_Customer__c>();

	public List<Affected_Market_Identifier__c> affectedNMIs;

	public List<String> strNMIs;
	public List<String> strIncIds;

	public Long nmiNumber;
	public Boolean useSequentalNMIs = false;


	// *********************************************************************
	// *** Static vars
	public static Outage_DataFactory OutageDF;
	public static Boolean useFakeMobileNum = true;


	// *********************************************************************
	// *** Constructor
	public Outage_DataFactory()
	{

	}


	// *********************************************************************
	// *** Static Methods
	public static Outage_DataFactory getODF()
	{
		if (OutageDF == null)
			OutageDF = new Outage_DataFactory();
		return OutageDF;
	}


	// *********************************************************************
	// *** Main Instance Methods
	public void generateCustomers(Integer numRecords) { generateCustomers(numRecords, false, true); }

	public void generateCustomers(Integer numRecords, Boolean lifeSupport, Boolean MC_Contact) // 30
	{
		if (numRecords == null || numRecords <= 0)
			return;

		if (lifeSupport == null) lifeSupport = false;

		disableContactSyncTriggers();

		generatePremises(numRecords, lifeSupport);
		generateNMIs(numRecords);
		generateAccs(numRecords);
		generateCons(numRecords, MC_Contact);
		generateACRs();
		generateContactPoints();
		generateConsents();
	}

	public void generateIncidents(Integer numRecords) // 3
	{
		if (numRecords == null || numRecords <= 0)
			return;

		generateIncidentRecords(numRecords);
		generateAffectedNMIs();
	}

	public void generateTasks(Integer numRecords) // 3
	{
		if (numRecords == null || numRecords <= 0)
			return;

		generateCons(numRecords);
		if(incidents==null || incidents.isEmpty()) {
			 generateIncidentRecords(numRecords);
		}

		generateTaskRecords(numRecords);
	}

	// *********************************************************************
	// *** Private Instance Methods
	public void generatePremises(Integer numPrems, Boolean lifeSupport)
	{
		premises = new List<vlocity_cmt__Premises__c>();

		while (numPrems > 0)
		{
			numPrems--;

			vlocity_cmt__Premises__c prem = new vlocity_cmt__Premises__c();

			prem.Name = prem.vlocity_cmt__StreetAddress__c = randomNum(4) + ' ' + randomLastName() + ' ' + randomStreetType();
			prem.vlocity_cmt__City__c = 'Melbourne';
			prem.vlocity_cmt__State__c = 'VIC';
			prem.vlocity_cmt__PostalCode__c = '3001';
			prem.vlocity_cmt__Status__c = 'Connected';

			if (lifeSupport)
				prem.vlocity_cmt__SupplyGuaranteeReason__c = 'Life Support';

			premises.add(prem);
		}

		insert premises;
	}

	public void generateNMIs(Integer numNMIs)
	{
		nmis = new List<vlocity_cmt__ServicePoint__c>();

		while (numNMIs > 0)
		{
			numNMIs--;

			vlocity_cmt__ServicePoint__c nmi = new vlocity_cmt__ServicePoint__c();

			nmi.Name = nmi.vlocity_cmt__MarketIdentifier__c = getNMI();
			nmi.vlocity_cmt__ServiceType__c = 'Electricity';
			nmi.vlocity_cmt__Status__c = Outage_IncidentProcessor.SERV_POINT_STS_ACTIVE;
			nmi.vlocity_cmt__PremisesId__c = premises.get(numNMIs).Id;
			nmi.Data_Duplication__c = Outage_IncidentProcessor.SERV_POINT_ORIG;

			nmis.add(nmi);
		}

		insert nmis;
	}

	public void generateAccs(Integer numAccs)
	{
		accs = new List<Account>();

		while (numAccs > 0)
		{
			numAccs--;

			Account a = new Account();

			// recordtype
			a.RecordTypeId = UtilDatabase.getRecordTypeNames('Account').get(Outage_IncidentProcessor.ACC_SERVICE_RT);

			a.Name = randomName() + ' Service Account';
			a.Market_Identifier__c = nmis.get(numAccs).Id;
			a.vlocity_cmt__PremisesId__c = nmis.get(numAccs).vlocity_cmt__PremisesId__c;
			a.ShippingStreet = premises.get(numAccs).vlocity_cmt__StreetAddress__c;
			a.ShippingCity = premises.get(numAccs).vlocity_cmt__City__c;
			a.ShippingState = premises.get(numAccs).vlocity_cmt__State__c;
			a.ShippingPostalCode = premises.get(numAccs).vlocity_cmt__PostalCode__c;

			accs.add(a);
		}

		insert accs;
	}

	@testvisible private void generateCons(Integer numCons)
	{
		generateCons(numCons, true);
	}

	public void generateCons(Integer numCons, Boolean MC_Contact)
	{
		cons = new List<Contact>();

		while (numCons > 0)
		{
			numCons--;

			Contact con = new Contact();

			// recordtype
			con.RecordTypeId = UtilDatabase.getRecordTypeNames('Contact').get(Outage_IncidentProcessor.CON_DCP_RT);

			String accName = accs.get(numCons).Name.removeEnd(' Service Account');

			con.FirstName = accName.split(' ').get(0);
			con.LastName  = accName.split(' ').get(1);
			con.AccountId = accs.get(numCons).Id;

			con.MobilePhone = getMobileNum();
			con.Phone = '039' + randomNum(7);
			con.Email = con.FirstName.toLowerCase() + '@' + con.LastName.toLowerCase() + '.com.invalid';
			con.MailingStreet     = accs.get(numCons).ShippingStreet;
			con.MailingCity       = accs.get(numCons).ShippingCity;
			con.MailingState      = accs.get(numCons).ShippingState;
			con.MailingPostalCode = accs.get(numCons).ShippingPostalCode;
			con.MC_Contact__c = MC_Contact;

			cons.add(con);
		}

		insert cons;

		// Primary contact Id here
		Map<Id, Account> mapAccs = new Map<Id, Account>(accs);
		List<Account> updAccs = new List<Account>(); 

		for (Contact con: cons)
		{
			Account acc = mapAccs.get(con.AccountId);
			acc.vlocity_cmt__PrimaryContactId__c = con.Id;
			acc.Contact_Matched__c = Outage_AccountContactUtils.CON_MATCHED_FOUND;
			updAccs.add(acc);
		}

		update updAccs;
	}

	@testvisible private void generateContactPoints()
	{
		CPEmails = new List<ContactPointEmail>();
		CPPhones = new List<ContactPointPhone>();

		for (Contact con: cons)
		{
			Boolean isPrimary = true;
			Boolean isPrimaryEmail = true;

			if (con.MobilePhone != null)
			{
				CPPhones.add(generateCPP(con.Id, con.MobilePhone, isPrimary, 'MobilePhone'));
				if (isPrimary) isPrimary = false;
			}

			if (con.Phone != null)
			{
				CPPhones.add(generateCPP(con.Id, con.Phone, isPrimary, 'Phone'));
				if (isPrimary) isPrimary = false;
			}

			if (con.Email != null)
			{
				CPEmails.add(generateCPE(con.Id, con.Email, isPrimaryEmail, 'Email'));
				if (isPrimaryEmail) isPrimaryEmail = false;
			}
		}

		if (!CPEmails.isEmpty()) insert CPEmails;
		if (!CPPhones.isEmpty()) insert CPPhones;
	}

	@testvisible private void generateConsents()
	{
		CPConsents = new List<ContactPointConsent>();

		for (ContactPointEmail cpe: CPEmails)
		{
			ContactPointConsent cpc = new ContactPointConsent();
			cpc.Name = 'CPC record';
			cpc.Contact__c = cpe.Contact__c;
			cpc.ContactPointId = cpe.Id;
			cpc.CaptureSource = 'Test data';
			cpc.CaptureDate = System.now().addDays(-1);
			cpc.EffectiveFrom = cpc.CaptureDate;
			cpc.EngagementChannelTypeId = getChannelId(Outage_IncidentProcessor.CHANNEL_EMAIL);
			cpc.DataUsePurposeId = getPurposeId(Outage_IncidentProcessor.DATAUSE_OUTAGES);
			cpc.Authorised_to_Change__c = 'Authorised';
			cpc.Privacy_Policy__c = 'Agreed';
			// cpc.PrivacyConsentStatus = 'Not Seen';

			CPConsents.add(cpc);
		}

		for (ContactPointPhone cpp: CPPhones)
		{
			if (cpp.PhoneType != 'Mobile') continue;

			ContactPointConsent cpc = new ContactPointConsent();
			cpc.Name = 'CPC record';
			cpc.Contact__c = cpp.Contact__c;
			cpc.ContactPointId = cpp.Id;
			cpc.CaptureSource = 'Test data';
			cpc.CaptureDate = System.now().addDays(-1);
			cpc.EffectiveFrom = cpc.CaptureDate;
			cpc.EngagementChannelTypeId = getChannelId(Outage_IncidentProcessor.CHANNEL_SMS);
			cpc.DataUsePurposeId = getPurposeId(Outage_IncidentProcessor.DATAUSE_OUTAGES);
			cpc.Authorised_to_Change__c = 'Authorised';
			cpc.Privacy_Policy__c = 'Agreed';
			// cpc.PrivacyConsentStatus = 'Not Seen';

			// CPConsents.add(cpc);
		}

		if (!CPConsents.isEmpty()) insert CPConsents;
	}

	public void generateACRs()
	{
		ACRs = [SELECT Id, AccountId, ContactId, Roles FROM AccountContactRelation WHERE ContactId IN :cons];

		for (AccountContactRelation acr: ACRs)
		{
			acr.Roles = Outage_IncidentProcessor.ACR_ROLE_MKT_CON;
		}

		update ACRs;
	}

	@testvisible private void generateIncidentRecords(Integer numRecords)
	{
		incidents = new List<Incident>();

		while (numRecords > 0)
		{
			numRecords--;

			// Create an Incident
			Incident newInc = new Incident();
			newInc.uom_Incident_Id__c = getIncId();
			newInc.Status = Outage_IncidentProcessor.INCIDENT_STS_1_REPORTED;
			newInc.Type = 'Unplanned';
			newInc.Priority = '1';
			newInc.Incident_Notifications__c = Outage_IncidentProcessor.INC_NOTIFS_AUTO;
			newInc.StartDateTime = System.now().addMinutes(-10);

			incidents.add(newInc);
		}

		insert incidents;
	}

	@testvisible private void generateAffectedNMIs()
	{
		affectedNMIs = new List<Affected_Market_Identifier__c>();
		Integer numPerIncident = (Integer)nmis.size() / incidents.size(); // 10

		// Load NMIs onto Incidents
		List<Affected_Market_Identifier__c> insNMIs = new List<Affected_Market_Identifier__c>();

		Integer countIncs = -1;
		for (Incident inc: incidents)
		{
			countIncs++; // zero indexed
			Integer numNMIs = numPerIncident;

			while (numNMIs > 0)
			{
				numNMIs--;

				// 0*3 + 1
				// IncidentIndex * numPerInc + countPerInc
				Integer indexNMI = (countIncs * numPerIncident) + numNMIs;

				vlocity_cmt__ServicePoint__c spNMI = nmis.get(indexNMI);

				Affected_Market_Identifier__c affNMI = new Affected_Market_Identifier__c();
				affNMI.uom_Incident__c = inc.Id;
				affNMI.Name = spNMI.Name;
				affNMI.uom_Unique_Market_Identifier__c = inc.uom_Incident_Id__c +'_'+ affNMI.Name;
				affNMI.uom_Status_Code__c = Outage_IncidentProcessor.AFF_NMI_CODE_PRED ;
				affectedNMIs.add(affNMI);
			}
		}

		insert affectedNMIs;
	}

	@testvisible private void generateTaskRecords(Integer numRecords)
	{
		tasks = new List<Task>();
		Set<Id> incis = new Set<Id>();
		for(Incident inci : incidents){
			incis.add(inci.Id);
		}

		affCusts = [SELECT Id, Name, uom_Life_Support__c
													FROM Affected_Customer__c
													WHERE uom_Incident__c IN :incis];

		if (affCusts == null || affCusts.isEmpty())
		{
			// Error
			System.debug('Error: Affected Customers not found');
			return;
		}

		Group grp = [select Id , Name , Type from Group where Type='Queue' AND DeveloperName= :Outage_IncidentProcessor.LSC_TASK_QUEUE_NAME];

		for (Integer num=0;num<numRecords;num++)
		{


			// Create an Incident
			Task newTask = new Task();
			newTask.Priority = 'Normal';
			newTask.Status = 'Not Started';
			newTask.OwnerId = grp.Id;
			newTask.Subject = '';
			newTask.RecordTypeId = UtilDatabase.getRecordTypeNames('Task').get(Outage_IncidentProcessor.LSC_TASK_RT_NAME);
			newTask.WhatId = affCusts.get(num).Id;
			newTask.WhoId = cons.get(num).Id;
			newTask.Close_On_Incident_Resolved__c = true;
			tasks.add(newTask);
		}

		insert tasks;
	}

	// *********************************************************************
	// *** Helper Methods
	public static ContactPointPhone generateCPP(Id conId, String phnum, Boolean isPrimary, String fld)
	{
		ContactPointPhone cpp = new ContactPointPhone();

		cpp.Contact__c = conId;
		cpp.IsPrimary = isPrimary;
		cpp.TelephoneNumber = phnum;
		cpp.Data_Type__c = Outage_IncidentProcessor.DATATYPE_RETAILER;
		cpp.Source_Field__c = fld;

		if (cpp.TelephoneNumber.startsWith('04'))
		{
			cpp.PhoneType = Outage_IncidentProcessor.CPP_PHONE_TYPE_MOBILE;
			cpp.IsSmsCapable = true;
		}
		else if (cpp.TelephoneNumber.startsWith('03'))
		{
			cpp.PhoneType = Outage_IncidentProcessor.CPP_PHONE_TYPE_HOME;
			cpp.IsSmsCapable = false;
		}

		return cpp;
	}

	public static ContactPointEmail generateCPE(Id conId, String emailaddr, Boolean isPrimary, String fld)
	{
		ContactPointEmail cpe = new ContactPointEmail();

		cpe.Contact__c = conId;
		cpe.IsPrimary = isPrimary;
		cpe.EmailAddress = emailaddr;
		cpe.Data_Type__c = Outage_IncidentProcessor.DATATYPE_RETAILER;
		cpe.Source_Field__c = fld;

		return cpe;
	}

	public Id getChannelId(String channelName)
	{
		if (channels == null)
			channels = new Map<String, EngagementChannelType>();

		if (!channels.containsKey(channelName))
		{
			for (EngagementChannelType ect: [SELECT Id, Name
											 FROM EngagementChannelType
											 WHERE Name=:channelName
											 LIMIT 1])
			{
				channels.put(channelName, ect);
			}

			if (!channels.containsKey(channelName))
			{
				String ContactPointType = channelName;
				if (ContactPointType == 'SMS') ContactPointType = 'Phone';

				// create;
				EngagementChannelType ect = new EngagementChannelType();
				ect.Name = channelName;
				ect.ContactPointType = ContactPointType;
				insert ect;
				channels.put(channelName, ect);
			}
		}

		return channels.get(channelName).Id;
	}

	public Id getPurposeId(String purposeName)
	{
		if (purpose == null)
		{
			for (DataUsePurpose dup: [SELECT Id, Name
									  FROM DataUsePurpose
									  WHERE Name=:purposeName
									  LIMIT 1])
			{
				purpose = dup;
			}

			if (purpose == null)
			{
				// create;
				DataUsePurpose dup = new DataUsePurpose();
				dup.Name = purposeName;
				dup.CanDataSubjectOptOut = true;
				insert dup;
				purpose = dup;
			}
		}

		return purpose.Id;
	}

	public String getNMI()
	{
		if (useSequentalNMIs)
		{
			if (nmiNumber == null) nmiNumber = 0;
			String num = String.valueOf(++nmiNumber);
			return num.leftPad(10, '0');
		}

		if (strNMIs == null || strNMIs.isEmpty())
			return randomNum(10);

		return strNMIs.remove(strNMIs.size() -1);
	}

	private String getIncId()
	{
		if (strIncIds == null || strIncIds.isEmpty())
			return 'Inc-' + randomNum(10);

		return strIncIds.remove(strIncIds.size() -1);
	}

	public static String getMobileNum()
	{
		if (useFakeMobileNum)
			return Outage_IncidentProcessor.FAKE_MOBILE_NUM;

		return '04' + randomNum(8);
	}

	public static String randomNum(Integer len)
	{
		final String chars = '1234567890';
		String randStr = '';

		while (randStr.length() < len)
		{
			Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
			randStr += chars.substring(idx, idx+1);
		}
		return randStr;
	}

	// Top 100 male and female from US data in 2014
	// Top 200 last names from US data in 2014
	private static List<String> firstNames = new List<String> {'Aaliyah', 'Abigail', 'Addison', 'Alexa', 'Alexandra', 'Alexis', 'Alice', 'Allison', 'Alyssa', 'Amelia', 'Anna', 'Annabelle', 'Aria', 'Ariana', 'Arianna', 'Ashley', 'Aubree', 'Aubrey', 'Audrey', 'Autumn', 'Ava', 'Avery', 'Bella', 'Brianna', 'Brooklyn', 'Camila', 'Caroline', 'Charlotte', 'Chloe', 'Claire', 'Eleanor', 'Elizabeth', 'Ella', 'Ellie', 'Emily', 'Emma', 'Eva', 'Evelyn', 'Faith', 'Gabriella', 'Genesis', 'Gianna', 'Grace', 'Hadley', 'Hailey', 'Hannah', 'Harper', 'Isabella', 'Isabelle', 'Jasmine', 'Julia', 'Katherine', 'Kaylee', 'Kennedy', 'Khloe', 'Kylie', 'Lauren', 'Layla', 'Leah', 'Lillian', 'Lily', 'London', 'Lucy', 'Lydia', 'Mackenzie', 'Madeline', 'Madelyn', 'Madison', 'Maya', 'Melanie', 'Mia', 'Mila', 'Naomi', 'Natalie', 'Nevaeh', 'Nora', 'Olivia', 'Paisley', 'Penelope', 'Peyton', 'Piper', 'Riley', 'Ruby', 'Sadie', 'Samantha', 'Sarah', 'Savannah', 'Scarlett', 'Serenity', 'Skylar', 'Sofia', 'Sophia', 'Sophie', 'Stella', 'Taylor', 'Victoria', 'Violet', 'Vivian', 'Zoe', 'Zoey', 'Aaron', 'Adam', 'Adrian', 'Aiden', 'Alexander', 'Andrew', 'Angel', 'Anthony', 'Asher', 'Austin', 'Ayden', 'Benjamin', 'Bentley', 'Blake', 'Brandon', 'Brayden', 'Brody', 'Caleb', 'Camden', 'Cameron', 'Carson', 'Carter', 'Charles', 'Chase', 'Christian', 'Christopher', 'Colton', 'Connor', 'Cooper', 'Daniel', 'David', 'Dominic', 'Dylan', 'Easton', 'Eli', 'Elijah', 'Ethan', 'Evan', 'Gabriel', 'Gavin', 'Grayson', 'Henry', 'Hudson', 'Hunter', 'Ian', 'Isaac', 'Isaiah', 'Jace', 'Jack', 'Jackson', 'Jacob', 'James', 'Jason', 'Jaxon', 'Jaxson', 'Jayden', 'Jeremiah', 'John', 'Jonathan', 'Jordan', 'Jose', 'Joseph', 'Joey', 'Joshua', 'Josiah', 'Juan', 'Julian', 'Justin', 'Kayden', 'Kevin', 'Landon', 'Leo', 'Levi', 'Liam', 'Lincoln', 'Logan', 'Lucas', 'Luis', 'Luke', 'Mason', 'Matthew', 'Michael', 'Nathan', 'Nathaniel', 'Nicholas', 'Noah', 'Nolan', 'Oliver', 'Owen', 'Parker', 'Robert', 'Ryan', 'Ryder', 'Samuel', 'Sebastian', 'Seph', 'Thomas', 'Tristan', 'Tyler', 'William', 'Wyatt', 'Xavier', 'Zachary'};
	private static List<String> lastNames = new List<String> {'Adams', 'Alexander', 'Allen', 'Alvarez', 'Anderson', 'Arnold', 'Bailey', 'Baker', 'Barnes', 'Bell', 'Bennett', 'Black', 'Boyd', 'Bradley', 'Brooks', 'Brown', 'Bryant', 'Burns', 'Butler', 'Campbell', 'Carter', 'Castillo', 'Castro', 'Chavez', 'Clark', 'Cole', 'Coleman', 'Collins', 'Cook', 'Cooper', 'Cox', 'Crawford', 'Cruz', 'Cunningham', 'Daniels', 'Davis', 'Diaz', 'Dixon', 'Dunn', 'Edwards', 'Elliott', 'Ellis', 'Evans', 'Ferguson', 'Fernandez', 'Fisher', 'Flores', 'Ford', 'Foster', 'Fox', 'Freeman', 'Garcia', 'Gardner', 'Gibson', 'Gomez', 'Gonzales', 'Gonzalez', 'Gordon', 'Graham', 'Grant', 'Gray', 'Green', 'Griffin', 'Gutierrez', 'Hall', 'Hamilton', 'Hansen', 'Harris', 'Harrison', 'Hart', 'Hawkins', 'Hayes', 'Henderson', 'Henry', 'Hernandez', 'Herrera', 'Hicks', 'Hill', 'Hoffman', 'Holmes', 'Howard', 'Hughes', 'Hunt', 'Hunter', 'Jackson', 'James', 'Jenkins', 'Jimenez', 'Johnson', 'Jones', 'Jordan', 'Kelley', 'Kelly', 'Kennedy', 'Kim', 'King', 'Knight', 'Lee', 'Lewis', 'Long', 'Lopez', 'Marshall', 'Martin', 'Martinez', 'Mason', 'Mcdonald', 'Medina', 'Mendoza', 'Meyer', 'Miller', 'Mills', 'Mitchell', 'Moore', 'Morales', 'Moreno', 'Morgan', 'Morris', 'Murphy', 'Murray', 'Myers', 'Nelson', 'Nguyen', 'Nichols', 'Olson', 'Ortiz', 'Owens', 'Palmer', 'Parker', 'Patel', 'Patterson', 'Payne', 'Perez', 'Perry', 'Peters', 'Peterson', 'Phillips', 'Pierce', 'Porter', 'Powell', 'Price', 'Ramirez', 'Ramos', 'Reed', 'Reyes', 'Reynolds', 'Rice', 'Richardson', 'Rivera', 'Roberts', 'Robertson', 'Robinson', 'Rodriguez', 'Rogers', 'Romero', 'Rose', 'Ross', 'Ruiz', 'Russell', 'Ryan', 'Sanchez', 'Sanders', 'Schmidt', 'Scott', 'Shaw', 'Simmons', 'Simpson', 'Smith', 'Snyder', 'Spencer', 'Stephens', 'Stevens', 'Stewart', 'Stone', 'Sullivan', 'Taylor', 'Thomas', 'Thompson', 'Torres', 'Tran', 'Tucker', 'Turner', 'Vasquez', 'Wagner', 'Walker', 'Wallace', 'Ward', 'Warren', 'Washington', 'Watson', 'Weaver', 'Webb', 'Wells', 'West', 'White', 'Williams', 'Wilson', 'Wood', 'Woods', 'Wright', 'Young', 'Melbourne', 'Sydney', 'Adelaide', 'Darwin'};
	private static List<String> streetTypes = new List<String> { 'Alley', 'Avenue', 'Boulevarde', 'Circle', 'Circuit', 'Close', 'Corner', 'Court', 'Crescent', 'Drive', 'Esplanade', 'Lane', 'Mews', 'Parade', 'Place', 'Road', 'Street', 'Terrace', 'View', 'Walk', 'Way' };

	public static String randomName()
	{
		// Create a random numRecords that corresponds to index in first and last names lists
		Integer firstNameIndex = (Integer)(Math.random() * firstNames.size());
		Integer lastNameIndex = (Integer)(Math.random() * lastNames.size());

		// Select the first and last name from the lists based on random indices
		String firstNameSelected = firstNames[firstNameIndex];
		String lastNameSelected = lastNames[lastNameIndex];

		return firstNameSelected + ' ' + lastNameSelected;
	}

	public static String randomLastName()
	{
		// Create a random numRecords that corresponds to index in first and last names lists
		Integer lastNameIndex = (Integer)(Math.random() * lastNames.size());

		// Select the first and last name from the lists based on random indices
		String lastNameSelected = lastNames[lastNameIndex];

		return lastNameSelected;
	}

	public static String randomStreetType()
	{
		Integer idx = (Integer)(Math.random() * streetTypes.size());
		String randValue = streetTypes[idx];

		return randValue;
	}

	private static void disableContactSyncTriggers()
	{
		CE_ContactPointSync2.isRunningContactUpdate    = true;
		CE_ContactPointSync2.isRunningCPPCPEUpdate     = true;
		CE_ContactPointSync2.disableAccountPrimConTrig = true;
	}

}