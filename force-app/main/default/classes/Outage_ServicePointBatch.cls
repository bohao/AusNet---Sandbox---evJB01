public with sharing class Outage_ServicePointBatch implements Database.Batchable<sObject>
{
	// private List<vlocity_cmt__ServicePoint__c> scope;

	public  Integer BatchSize = 2000;
	public  String  additionalCriteria; // Optional input

	public Outage_ServicePointBatch()
	{

	}

	public static void runServPointSync() // Outage_ServicePointBatch.runServPointSync();
	{
		runServPointSync(null);
	}

	public static void runServPointSync(String inputCrit)
	{
		Outage_ServicePointBatch SPSync = new Outage_ServicePointBatch();

		if (inputCrit != null)
			SPSync.additionalCriteria = inputCrit;

		Database.ExecuteBatch(SPSync, SPSync.BatchSize);
	}

	public Database.Querylocator start(Database.BatchableContext bc)
	{
		// Get all DCP Contacts
		String query  = 'SELECT Id, vlocity_cmt__MarketIdentifier__c ' ;
			   query += 'FROM vlocity_cmt__ServicePoint__c ';
			   query += 'WHERE vlocity_cmt__ServiceType__c = \'Electricity\' ';

		// Append any additional criteria to the query
		if (additionalCriteria != null)
			query += ' AND ' + this.additionalCriteria;

		// If Testing, apply limit
		if (Test.isRunningTest())
			query += ' LIMIT ' + BatchSize;

		System.debug('query: ' + query);
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext BC, List<vlocity_cmt__ServicePoint__c> scope)
	{
		Set<String> NMIList = new Set<String>();

		for (vlocity_cmt__ServicePoint__c sp: scope)
			NMIList.add(sp.vlocity_cmt__MarketIdentifier__c);

		Trig_ServicePoint.updateNMIDuplicateFlag(NMIList);
	}

	public void finish(Database.BatchableContext bc)
	{
		System.debug('>>>> finish ');
	}
}