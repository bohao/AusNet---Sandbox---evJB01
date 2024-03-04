public with sharing class CE_ContactSyncBatch implements Database.Batchable<sObject>,  Database.Stateful
{
	private List<Contact> scope;

	public  Integer BatchSize = 2000;
	public  String  additionalCriteria; // Optional input

	public  Boolean runSyncRetailerFields     = true;
	public  Boolean runCreateRetailerConsents = true;

	public CE_ContactSyncBatch()
	{

	}

	public static void runContactSync() // CE_ContactSyncBatch.runContactSync();
	{
		runContactSync(null);
	}

	public static void runContactSync(String inputCrit)
	{
		CE_ContactSyncBatch contSync = new CE_ContactSyncBatch();

		if (inputCrit != null)
			contSync.additionalCriteria = inputCrit;

		Database.ExecuteBatch(contSync, contSync.BatchSize);
	}

	public Database.Querylocator start(Database.BatchableContext bc)
	{
		// Get all DCP Contacts
		String query  = 'SELECT RecordTypeId, Id, Phone, Email, MobilePhone, OtherPhone, HomePhone, CE_Email_Address__c, CE_Phone_Number__c ' ;
			   query += 'FROM Contact WHERE RecordType.DeveloperName= \'' + Outage_IncidentProcessor.CON_DCP_RT + '\'' ;

		// Append any additional criteria to the query
		if (additionalCriteria != null)
			query += ' AND ' + this.additionalCriteria;

		// If Testing, apply limit
		if (Test.isRunningTest())
			query += ' LIMIT ' + BatchSize;

		System.debug('query'+query);
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<Contact> scope)
	{
		if (runSyncRetailerFields) CE_ContactPointSync2.forceSyncRetailerFields(scope);

		// TODO
		String msg = '*** Check Limits\n';
		msg += 'DMLRowsLeft: '       + Outage_IncidentProcessor.getDMLRowsLeft() + '\n';
		msg += 'QueryRowsLeft: '     + Outage_IncidentProcessor.getQueryRowsLeft() + '\n';
		msg += 'DMLStatementsLeft: ' + Outage_IncidentProcessor.getDMLStatementsLeft() + '\n';
		System.debug(msg);

		if (runCreateRetailerConsents) CE_ContactPointSync2.createRetailerDefaultConsents(scope);
	}

	public void finish(Database.BatchableContext bc)
	{
		System.debug('>>>> finish ');
	}
}