public with sharing class Outage_AsyncProcessor implements Queueable
{
	private Map<Id, Outage_IncidentProcessor.IncidentUpdate> incUpdates;

	public Outage_AsyncProcessor(Map<Id, Outage_IncidentProcessor.IncidentUpdate> incupd)
	{
		incUpdates = incupd;
	}

	public void execute(QueueableContext context)
	{
		System.debug('*** Outage_AsyncProcessor.execute');

		if (incUpdates == null || incUpdates.isEmpty())
		{
			System.debug('Error: incUpdates is null or empty.');
			return;
		}

		if (Test.isRunningTest())
		{
			Integer intLimit = incUpdates.values().get(0).queryLimit;
			Outage_IncidentProcessor.setQueryLimit(intLimit);
		}

		Outage_IncidentProcessor.processIncidentUpdAffCusts(incUpdates);
	}
}