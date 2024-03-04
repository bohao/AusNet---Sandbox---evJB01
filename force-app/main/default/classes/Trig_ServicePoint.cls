public with sharing class Trig_ServicePoint implements UtilTrigHandle
{
	// *********************************************************************
	// *** Disable logic
	public static Boolean TrigDisabled = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().Service_Point_Trig_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}


	// *********************************************************************
	// *** Member variables
	public static Boolean isRunningCheckforDuplicates = false;


	// *********************************************************************
	// *** Trigger contexts
	public void BeforeInsert(List<SObject> newSObjs)
	{
		checkNMILength(newSObjs);
	}

	public void AfterInsert(Map<Id, SObject> newSObjs)
	{
		insertCheckforDuplicates(newSObjs.values());
	}

	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		// checkNMILength(newSObjs.values());
	}

	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		updateCheckforDuplicates(newSObjs.values(), (Map<Id, vlocity_cmt__ServicePoint__c>)oldSObjs);
	}

	// if context is not implemented, condense into one-liners
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> oldSObjs) {}


	// *********************************************************************
	// *** Trigger methods
	public static void checkNMILength(List<vlocity_cmt__ServicePoint__c> servPoints)
	{
		if (servPoints == null || servPoints.isEmpty())
			return;

		for (vlocity_cmt__ServicePoint__c servPt: servPoints)
		{
			if (servPt.vlocity_cmt__MarketIdentifier__c == null || servPt.vlocity_cmt__MarketIdentifier__c.length() != 10) continue;

			String nmiNum10 = servPt.vlocity_cmt__MarketIdentifier__c;
			String nmiNum11 = Outage_NMITools.getNMI11(nmiNum10);
			servPt.Name = servPt.vlocity_cmt__MarketIdentifier__c = nmiNum11;
		}
	}

	// insertCheckforDuplicates profile:
	// Runs in after insert context
	// 0 SOQLs
	// 0 DMLs
	public static void insertCheckforDuplicates(List<vlocity_cmt__ServicePoint__c> newServicePoints)
	{
		System.debug('* insertCheckforDuplicates');

		if (isRunningCheckforDuplicates) return;
		isRunningCheckforDuplicates = true;

		Set<String> NMIs = new Set<String>();

		// Qualify
		for (vlocity_cmt__ServicePoint__c NMI: newServicePoints)
		{
			if (NMI.vlocity_cmt__ServiceType__c      == 'Electricity' &&
				NMI.vlocity_cmt__Status__c           == Outage_IncidentProcessor.SERV_POINT_STS_ACTIVE   &&
				NMI.vlocity_cmt__MarketIdentifier__c != null)
			{
				// qualifies
				System.debug('qualifies');
				NMIs.add(NMI.vlocity_cmt__MarketIdentifier__c);
			}
		}

		if (!NMIs.isEmpty())
		{
			updateNMIDuplicateFlag(NMIs);
		}
	}

	// updateCheckforDuplicates profile:
	// Runs in after update context
	// 0 SOQLs
	// 0 DMLs
	public static void updateCheckforDuplicates(List<vlocity_cmt__ServicePoint__c> newServicePoints, Map<Id, vlocity_cmt__ServicePoint__c> oldServicePoints)
	{
		System.debug('* updateCheckforDuplicates');

		if (isRunningCheckforDuplicates) return;
		isRunningCheckforDuplicates = true;

		Set<String> NMIs = new Set<String>();

		// Qualify
		for (vlocity_cmt__ServicePoint__c newNMI: newServicePoints)
		{
			vlocity_cmt__ServicePoint__c oldNMI = oldServicePoints.get(newNMI.Id);

			if (newNMI.vlocity_cmt__ServiceType__c      != oldNMI.vlocity_cmt__ServiceType__c ||
				newNMI.vlocity_cmt__Status__c           != oldNMI.vlocity_cmt__Status__c      ||
				newNMI.vlocity_cmt__MarketIdentifier__c != oldNMI.vlocity_cmt__MarketIdentifier__c)
			{
				// qualifies
				NMIs.add(newNMI.vlocity_cmt__MarketIdentifier__c);

				if (newNMI.vlocity_cmt__MarketIdentifier__c != oldNMI.vlocity_cmt__MarketIdentifier__c)
					NMIs.add(oldNMI.vlocity_cmt__MarketIdentifier__c);
			}
		}

		if (!NMIs.isEmpty())
		{
			updateNMIDuplicateFlag(NMIs);
		}
	}

	// updateNMIDuplicateFlag profile:
	// Runs in after context
	// 1 SOQLs
	// 1 DMLs
	public static void updateNMIDuplicateFlag(Set<String> NMIs)
	{
		System.debug('* updateNMIDuplicateFlag');

		// Query
		String lastNMI;
		List<vlocity_cmt__ServicePoint__c> updNMIs = new List<vlocity_cmt__ServicePoint__c>();

		for (vlocity_cmt__ServicePoint__c NMI: [SELECT Id, Name, vlocity_cmt__MarketIdentifier__c, vlocity_cmt__ServiceType__c, vlocity_cmt__Status__c
												FROM vlocity_cmt__ServicePoint__c
												WHERE vlocity_cmt__MarketIdentifier__c IN :NMIs
												ORDER BY vlocity_cmt__MarketIdentifier__c ASC, CreatedDate ASC])
		{
			String NMINum = NMI.vlocity_cmt__MarketIdentifier__c;
			System.debug('NMINum: ' + NMINum);

			// Query assumes
				// Ordered by NMI num (ascending), then by created date (ascending)

			// Check if record matching criteria
			if (NMI.vlocity_cmt__ServiceType__c != 'Electricity' ||
				NMI.vlocity_cmt__Status__c != Outage_IncidentProcessor.SERV_POINT_STS_ACTIVE)
			{
				System.debug('Does not match, set to null...');
				// Does not match....
				// set to null
				NMI.Data_Duplication__c = null;
			}

			// For the first record found, set as original
			// For the other records found, set as duplicate
			else if (lastNMI != NMINum)
			{
				// assume this is the first?
				System.debug('First found.');
				NMI.Data_Duplication__c = Outage_IncidentProcessor.SERV_POINT_ORIG;
				lastNMI = NMINum;
			}
			else
			{
				// assume we have already seen this?
				System.debug('Repeat found.');
				NMI.Data_Duplication__c = Outage_IncidentProcessor.SERV_POINT_DUPE;
			}

			updNMIs.add(NMI);
		}

		// Update records
		update updNMIs;
	}
}