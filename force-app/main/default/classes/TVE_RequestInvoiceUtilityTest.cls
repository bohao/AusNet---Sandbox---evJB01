/*
@author  : Arti.foglae@ausnetservices.com.au
@created : 09 Mar  2020
@Description : test class for TVE_RequestInvoiceUtility
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
*/
@istest
public class TVE_RequestInvoiceUtilityTest {

	public static ID IntTask_Artefact_RTId = Schema.SObjectType.Integration_Task__c.getRecordTypeInfosByDeveloperName().get('Artefact').getRecordTypeId();
	public static final string CON_TYPE = 'IDIC';
	public static final string PROGRESS_BAR_STATUS = 'Payment pending (Application submitted)';
	public static final string testUserEmail = 'testuser@TVEArtefactControllerTest'+ randomNum(5)+'.com';
	public static final string INV_TYPE_LINE1 = 'Site Assessment Fee';
	public static final string MAT_CODE_LINE1 = 'CCAAA001';
	public static final string TASK_RT = 'Request_Invoice';

	public static Project__c projObj;
	public static Artefact__c art;
	public static Task tsk;
	public static Integration_Task__c intTask;
	public static User testUser;


	@TestSetup
	public static void setup()
	{
		testUser = TVE_TestUtility.createTestUser(testUserEmail);
		insert testUser;

		Account testInstaller = TVE_TestUtility.createBusinessAccount('Business Account');
		testInstaller.BillingStreet='test Address line 1';
		testInstaller.BillingCity='line 2';
		testInstaller.BillingState='state';
		testInstaller.BillingPostalCode='123456';
		database.insert(testInstaller);

		Contact con = TVE_TestUtility.createContact();
		con.AccountId=testInstaller.id;
		con.FirstName = randomFirstName();
		con.LastName = randomLastName();
		con.Email = con.FirstName + '@' + con.LastName + '.com.invalid';
		con.AD_User_ID__c = randomNum(6);
		Database.insert(con);

		projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
		projObj.AuthorizedRepresentativeContact__c=con.id;
		projObj.ASPContact__c=con.id;
		projObj.OwnerId=testUser.id;
		Database.Insert(projObj);

		art=TVE_TestUtility.createInvoiceArtefact('testArt',projobj.id,testInstaller.id);
		Database.Insert(art);

		tsk=TVE_TestUtility.createTask(projobj.id,testUser.id,'Request Invoice');
		tsk.RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName =: TASK_RT].Id;
		Database.Insert(tsk);

		intTask = TVE_TestUtility.createIntegrationTask(art.Id, 'Create', 'Artefact__c', 'Ready', 'CreateArtefact');
		intTask.recordTypeId = IntTask_Artefact_RTId;
		insert intTask;
	}


	@IsTest
	public static void testGetContactWrapper()
	{
		// Task tskRec=[select id,recordtype.name from Task WHERE Id=:tsk.Id limit 1];
		// system.debug('recordtype:'+tskRec.recordtype.name);
		
		projObj  = [SELECT Id, OwnerId FROM Project__c LIMIT 1];
		testUser = [SELECT Id FROM User WHERE Id = :projObj.OwnerId LIMIT 1];
		art      = [SELECT Id FROM Artefact__c LIMIT 1];
		tsk      = [SELECT Id FROM Task LIMIT 1];

		User testUser2 = TVE_TestUtility.createTestUser('testuser@TVEArtefactControllerTest'+ randomNum(5)+'.com');
		insert testUser2;

		projObj.OwnerId = testUser2.Id;
		update projObj;

		System.assert(testUser   != null, 'Test user is null');
		System.assert(testUser2  != null, 'Test user 2 is null');
		System.assert(projObj    != null, 'projObj is null');
		System.assert(projObj.id != null, 'projObj.id is null');
		System.assert(art        != null, 'art is null');
		System.assert(art.id     != null, 'art.id is null');
		System.assert(tsk        != null, 'tsk is null');
		System.assert(tsk.id     != null, 'tsk.id is null');

		test.startTest();
		// setup();
		System.runAs(testUser2)
		{
			TVE_RequestInvoiceUtility.getContactWrapper(projObj.id, art.id);
			TVE_RequestInvoiceUtility.createTask(projObj.id, 'test', tsk.id);
		}
		test.stopTest();
	}

	@IsTest
	public static void testCreateArtefact(){


		Project__c proj = [select id from Project__c limit 1];
		Artefact__c artRecord=[select id from Artefact__c limit 1];
		Task tskRec=[select id from Task limit 1];
		Contact con = [SELECT Id FROM Contact Limit 1];
		test.startTest();
		TVE_RequestInvoiceUtility.getContactWrapper(proj.id,artRecord.id);
		TVE_RequestInvoiceUtility.createArtefact(con.Id, INV_TYPE_LINE1, INV_TYPE_LINE1, INV_TYPE_LINE1,
													33, MAT_CODE_LINE1, MAT_CODE_LINE1, MAT_CODE_LINE1,
													proj.Id, 10, 10, 10);
		test.stopTest();
	}


	@IsTest
	public static void test_hasWarningMsg(){


		Project__c proj = [select id from Project__c limit 1];

		test.startTest();
		TVE_RequestInvoiceUtility.hasWarningMsg(proj.Id);
		test.stopTest();
	}


	// Top 100 male and female from US data in 2014
	// Top 200 last names from US data in 2014
	private static List<String> firstNames = new List<String> {'Aaliyah', 'Abigail', 'Addison', 'Alexa', 'Alexandra', 'Alexis', 'Alice', 'Allison', 'Alyssa', 'Amelia', 'Anna', 'Annabelle', 'Aria', 'Ariana', 'Arianna', 'Ashley', 'Aubree', 'Aubrey', 'Audrey', 'Autumn', 'Ava', 'Avery', 'Bella', 'Brianna', 'Brooklyn', 'Camila', 'Caroline', 'Charlotte', 'Chloe', 'Claire', 'Eleanor', 'Elizabeth', 'Ella', 'Ellie', 'Emily', 'Emma', 'Eva', 'Evelyn', 'Faith', 'Gabriella', 'Genesis', 'Gianna', 'Grace', 'Hadley', 'Hailey', 'Hannah', 'Harper', 'Isabella', 'Isabelle', 'Jasmine', 'Julia', 'Katherine', 'Kaylee', 'Kennedy', 'Khloe', 'Kylie', 'Lauren', 'Layla', 'Leah', 'Lillian', 'Lily', 'London', 'Lucy', 'Lydia', 'Mackenzie', 'Madeline', 'Madelyn', 'Madison', 'Maya', 'Melanie', 'Mia', 'Mila', 'Naomi', 'Natalie', 'Nevaeh', 'Nora', 'Olivia', 'Paisley', 'Penelope', 'Peyton', 'Piper', 'Riley', 'Ruby', 'Sadie', 'Samantha', 'Sarah', 'Savannah', 'Scarlett', 'Serenity', 'Skylar', 'Sofia', 'Sophia', 'Sophie', 'Stella', 'Taylor', 'Victoria', 'Violet', 'Vivian', 'Zoe', 'Zoey', 'Aaron', 'Adam', 'Adrian', 'Aiden', 'Alexander', 'Andrew', 'Angel', 'Anthony', 'Asher', 'Austin', 'Ayden', 'Benjamin', 'Bentley', 'Blake', 'Brandon', 'Brayden', 'Brody', 'Caleb', 'Camden', 'Cameron', 'Carson', 'Carter', 'Charles', 'Chase', 'Christian', 'Christopher', 'Colton', 'Connor', 'Cooper', 'Daniel', 'David', 'Dominic', 'Dylan', 'Easton', 'Eli', 'Elijah', 'Ethan', 'Evan', 'Gabriel', 'Gavin', 'Grayson', 'Henry', 'Hudson', 'Hunter', 'Ian', 'Isaac', 'Isaiah', 'Jace', 'Jack', 'Jackson', 'Jacob', 'James', 'Jason', 'Jaxon', 'Jaxson', 'Jayden', 'Jeremiah', 'John', 'Jonathan', 'Jordan', 'Jose', 'Joseph', 'Joey', 'Joshua', 'Josiah', 'Juan', 'Julian', 'Justin', 'Kayden', 'Kevin', 'Landon', 'Leo', 'Levi', 'Liam', 'Lincoln', 'Logan', 'Lucas', 'Luis', 'Luke', 'Mason', 'Matthew', 'Michael', 'Nathan', 'Nathaniel', 'Nicholas', 'Noah', 'Nolan', 'Oliver', 'Owen', 'Parker', 'Robert', 'Ryan', 'Ryder', 'Samuel', 'Sebastian', 'Seph', 'Thomas', 'Tristan', 'Tyler', 'William', 'Wyatt', 'Xavier', 'Zachary'};
	private static List<String> lastNames = new List<String> {'Adams', 'Alexander', 'Allen', 'Alvarez', 'Anderson', 'Arnold', 'Bailey', 'Baker', 'Barnes', 'Bell', 'Bennett', 'Black', 'Boyd', 'Bradley', 'Brooks', 'Brown', 'Bryant', 'Burns', 'Butler', 'Campbell', 'Carter', 'Castillo', 'Castro', 'Chavez', 'Clark', 'Cole', 'Coleman', 'Collins', 'Cook', 'Cooper', 'Cox', 'Crawford', 'Cruz', 'Cunningham', 'Daniels', 'Davis', 'Diaz', 'Dixon', 'Dunn', 'Edwards', 'Elliott', 'Ellis', 'Evans', 'Ferguson', 'Fernandez', 'Fisher', 'Flores', 'Ford', 'Foster', 'Fox', 'Freeman', 'Garcia', 'Gardner', 'Gibson', 'Gomez', 'Gonzales', 'Gonzalez', 'Gordon', 'Graham', 'Grant', 'Gray', 'Green', 'Griffin', 'Gutierrez', 'Hall', 'Hamilton', 'Hansen', 'Harris', 'Harrison', 'Hart', 'Hawkins', 'Hayes', 'Henderson', 'Henry', 'Hernandez', 'Herrera', 'Hicks', 'Hill', 'Hoffman', 'Holmes', 'Howard', 'Hughes', 'Hunt', 'Hunter', 'Jackson', 'James', 'Jenkins', 'Jimenez', 'Johnson', 'Jones', 'Jordan', 'Kelley', 'Kelly', 'Kennedy', 'Kim', 'King', 'Knight', 'Lee', 'Lewis', 'Long', 'Lopez', 'Marshall', 'Martin', 'Martinez', 'Mason', 'Mcdonald', 'Medina', 'Mendoza', 'Meyer', 'Miller', 'Mills', 'Mitchell', 'Moore', 'Morales', 'Moreno', 'Morgan', 'Morris', 'Murphy', 'Murray', 'Myers', 'Nelson', 'Nguyen', 'Nichols', 'Olson', 'Ortiz', 'Owens', 'Palmer', 'Parker', 'Patel', 'Patterson', 'Payne', 'Perez', 'Perry', 'Peters', 'Peterson', 'Phillips', 'Pierce', 'Porter', 'Powell', 'Price', 'Ramirez', 'Ramos', 'Reed', 'Reyes', 'Reynolds', 'Rice', 'Richardson', 'Rivera', 'Roberts', 'Robertson', 'Robinson', 'Rodriguez', 'Rogers', 'Romero', 'Rose', 'Ross', 'Ruiz', 'Russell', 'Ryan', 'Sanchez', 'Sanders', 'Schmidt', 'Scott', 'Shaw', 'Simmons', 'Simpson', 'Smith', 'Snyder', 'Spencer', 'Stephens', 'Stevens', 'Stewart', 'Stone', 'Sullivan', 'Taylor', 'Thomas', 'Thompson', 'Torres', 'Tran', 'Tucker', 'Turner', 'Vasquez', 'Wagner', 'Walker', 'Wallace', 'Ward', 'Warren', 'Washington', 'Watson', 'Weaver', 'Webb', 'Wells', 'West', 'White', 'Williams', 'Wilson', 'Wood', 'Woods', 'Wright', 'Young', 'Melbourne', 'Sydney', 'Adelaide', 'Darwin'};

	private static String randomFirstName()
	{
		// Create a random numRecords that corresponds to index in first and last names lists
		Integer firstNameIndex = (Integer)(Math.random() * firstNames.size());

		// Select the first and last name from the lists based on random indices
		String firstNameSelected = firstNames[firstNameIndex];

		return firstNameSelected;
	}
	private static String randomLastName()
	{
		// Create a random numRecords that corresponds to index in first and last names lists
		Integer lastNameIndex = (Integer)(Math.random() * lastNames.size());

		// Select the first and last name from the lists based on random indices
		String lastNameSelected = lastNames[lastNameIndex];

		return lastNameSelected;
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

}