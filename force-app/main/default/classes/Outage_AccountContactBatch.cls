global without sharing class Outage_AccountContactBatch implements Database.Batchable<SObject>
{

	/********** Members **********/
	public String  query;
	public Integer batchSize = 200;
	public Boolean runAccountContactMatching = true;
	public Boolean runMCContactCheckbox = true;


	/********** Static Members **********/
	private static String ClassName = 'Outage_AccountContactBatch';


	/********** Constructor **********/
	global Outage_AccountContactBatch()
	{
		System.debug('*** ' + ClassName + ' Constructor');
		query = getBatchQuery();
	}

	public static String getBatchQuery()
	{
		return
		'SELECT Id, ContactId, AccountId, Roles, Account.vlocity_cmt__PrimaryContactId__c, Account.Contact_Matched__c ' +
		'FROM AccountContactRelation ' +
		'WHERE Roles INCLUDES (\'' + Outage_IncidentProcessor.ACR_ROLE_MKT_CON + '\') ' +
		'AND Account.Recordtype.Name = \''+ Outage_IncidentProcessor.ACC_SERVICE_RT + '\' ' +
		'AND Account.Market_Identifier__c != null ' +
		'AND Account.Market_Identifier__r.vlocity_cmt__Status__c = \'Connected\' ' +
		'AND Account.Market_Identifier__r.vlocity_cmt__ServiceType__c = \'Electricity\' ' +
		'AND Account.Market_Identifier__r.dcp_NMIStatus_To_Date__c = null';
	}


	/********** Calling methods **********/
		// Outage_AccountContactBatch.runBatch();
	public static void runBatch()
	{
		runBatch(null);
	}

	public static void runBatch(Integer batchSize)
	{
		System.debug('*** ' + ClassName);
		System.debug('** Start runBatch');

		Outage_AccountContactBatch accountContactBatch = new Outage_AccountContactBatch();

		if (batchSize != null)
			accountContactBatch.batchSize = batchSize;

		Database.ExecuteBatch(accountContactBatch, accountContactBatch.batchSize);

		System.debug('** End runBatch');
	}

	/********** Batch methods **********/
	global Database.QueryLocator start(Database.BatchableContext bc) {
		System.debug('* Start');
		System.debug('Batch Size: ' + batchSize);

		if (!runAccountContactMatching && !runMCContactCheckbox)
		{
			// Error
			System.debug('No methods active to run.');
			return null;
		}

		// Test mode - set query limit size
		if (Test.isRunningTest()) {
			query += ' LIMIT ' + batchSize;
		}

		System.debug('Query: ' + query);
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext bc, List<AccountContactRelation> queryResult)
	{
		System.debug('* Execute');
		System.debug('Query result size: ' + queryResult.size());

		Set<Id> accIds = new Set<Id>();
		for (AccountContactRelation acr: queryResult)
			accIds.add(acr.AccountId);

		List<Account> accs = [SELECT Id, Name, vlocity_cmt__PrimaryContactId__c, Contact_Matched__c,
							  (SELECT Id, ContactId, AccountId, Roles
								FROM AccountContactRelations
								LIMIT 2)
							  FROM Account 
							  WHERE Id IN :accIds];

		if (accs == null || accs.isEmpty())
		{
			// crash
			System.debug('bad');
			return ;
		}

		if (runAccountContactMatching) Outage_AccountContactUtils.processAccountContactMatching(accs);
		if (runMCContactCheckbox) Outage_AccountContactUtils.processMCContactCheckbox(accs);
	}

	global void finish(Database.BatchableContext bc) {
		System.debug('* Finish');
		System.debug('End.');
	}
}