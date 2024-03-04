@isTest
private class Outage_IncidentProcessor_Test
{
	private static Integer numCustomers = 5;
	private static Integer numIncidents = 1;

	public static testMethod void test_AffNMICreateAffCust_success()
	{
		User testUser = UtilDatabase_Test.getTestUser();

		Outage_DataFactory.getODF().generateCustomers(numCustomers);
		Outage_DataFactory.getODF().generateIncidentRecords(numIncidents);

		Test.startTest();
		System.runAs(testUser)
		{
			Outage_DataFactory.getODF().generateAffectedNMIs();
		}

		Test.stopTest();
	}

	public static testMethod void test_AffNMICreateAffCust_dupe_customers()
	{
		User testUser = UtilDatabase_Test.getTestUser();

		Outage_DataFactory.getODF().generateCustomers(numCustomers);

		// Duplicate an existing account
		Outage_DataFactory dupeDF = new Outage_DataFactory();
		dupeDF.accs = new List<Account>();
		dupeDF.accs.add(Outage_DataFactory.getODF().accs[0].clone(false, true, false, false));
		insert dupeDF.accs;

		// and create contact and acr on it.
		dupeDF.generateCons(1);
		dupeDF.generateACRs();

		Outage_DataFactory.getODF().generateIncidentRecords(numIncidents);

		Test.startTest();
		System.runAs(testUser)
		{
			Outage_DataFactory.getODF().generateAffectedNMIs();
		}

		Test.stopTest();
	}

	public static testMethod void test_AffNMICreateAffCust_no_customers()
	{
		User testUser = UtilDatabase_Test.getTestUser();

		Outage_DataFactory df = Outage_DataFactory.getODF();

		df.generatePremises(numCustomers, false);
		df.generateNMIs(numCustomers);
		df.generateAccs(numCustomers);
		df.generateIncidentRecords(numIncidents);

		Test.startTest();
		System.runAs(testUser)
		{
			df.generateAffectedNMIs();
		}

		Test.stopTest();
	}

	public static testMethod void test_AffNMICreateAffCust_multi1()
	{
		User testUser = UtilDatabase_Test.getTestUser();

		Set<Id> incIds = new Set<Id>();
		Id incId1, incId2;

		Outage_DataFactory.getODF().generateCustomers(5);

		Test.startTest();
		System.runAs(testUser)
		{
			resetTrigger();
			Outage_DataFactory.getODF().generateIncidents(1);
			incId1 = Outage_DataFactory.getODF().incidents.get(0).Id;
			incIds.add(incId1);

			// reset sync flag
			resetSyncMCFlag(incIds, null);

			// Run it again, create a second incident with the same customers
			resetTrigger();
			Outage_DataFactory.getODF().generateIncidents(1);
			incId2 = Outage_DataFactory.getODF().incidents.get(0).Id;
			incIds.add(incId2);
		}
		Test.stopTest();

		// verify
		List<SObject> updList = new List<SObject>();

		for (Incident inc: getIncidents(incIds))
		{
			System.debug(JSON.serializePretty(inc));
			String MultiStatus, SyncFlag;

			// check for sync flag, multi mode
			if (inc.Id == incId1)
			{
				SyncFlag    = null;
				MultiStatus = Outage_IncidentProcessor.AFF_NMI_MULTI_INC_1;
			}
			else if (inc.Id == incId2)
			{
				SyncFlag    = null;
				MultiStatus = Outage_IncidentProcessor.AFF_NMI_MULTI_INC_2;
			}

			for (Affected_Customer__c affCust: inc.Affected_Customers__r)
			{
				System.assertEquals(SyncFlag, affCust.MC_Sync__c);
				System.assertEquals(MultiStatus, affCust.Multi_Incident__c); // Bug here (Single Incident)

				// reset the flag
				affCust.MC_Sync__c = null;
				updList.add(affCust);
			}
		}

		// reset the flag
		updateList(updList);

		// Test out another update while in multi mode
		// it should only sync the first
		resetTrigger();
		Incident inc1 = new Incident(Id = incId1);
		inc1.Status = Outage_IncidentProcessor.INCIDENT_STS_4_MAKE_SAFE;
		update inc1;

		// verify
		for (Incident inc: getIncidents(incIds))
		{
			System.debug(JSON.serializePretty(inc));
			String MultiStatus, SyncFlag;

			// check for sync flag, multi mode
			if (inc.Id == incId1)
			{
				SyncFlag    = Outage_IncidentProcessor.SYNC_MC_SYNC_MULTI;
				MultiStatus = Outage_IncidentProcessor.AFF_NMI_MULTI_INC_1;
			}
			else if (inc.Id == incId2)
			{
				SyncFlag    = null;
				MultiStatus = Outage_IncidentProcessor.AFF_NMI_MULTI_INC_2;
			}

			for (Affected_Customer__c affCust: inc.Affected_Customers__r)
			{
				System.assertEquals(SyncFlag, affCust.MC_Sync__c);
				System.assertEquals(MultiStatus, affCust.Multi_Incident__c);

				// reset the flag
				affCust.MC_Sync__c = null;
				updList.add(affCust);
			}
		}

		// reset the flag
		updateList(updList);

		// Let's close out one of them
		resetTrigger();
		inc1.Status = Outage_IncidentProcessor.INCIDENT_STS_7_RESTORED;
		update inc1;

		// verify
		for (Incident inc: getIncidents(incIds))
		{
			System.debug(JSON.serializePretty(inc));
			String MultiStatus, SyncFlag;

			// check for sync flag, multi mode
			if (inc.Id == incId1)
			{
				SyncFlag    = null;
				MultiStatus = null;
			}
			else if (inc.Id == incId2)
			{
				SyncFlag    = null;
				MultiStatus = Outage_IncidentProcessor.AFF_NMI_SINGLE_INC;
			}

			for (Affected_Customer__c affCust: inc.Affected_Customers__r)
			{
				System.assertEquals(SyncFlag, affCust.MC_Sync__c);
				System.assertEquals(MultiStatus, affCust.Multi_Incident__c);

				// reset the flag
				if (inc.Id == incId2)
				{
					affCust.MC_Sync__c = null;
					updList.add(affCust);
				}
			}
		}

		// reset the flag
		updateList(updList);

		// Let's update second incident
		resetTrigger();
		Incident inc2 = new Incident(Id = incId2);
		inc2.Status = Outage_IncidentProcessor.INCIDENT_STS_2_ASSESS;
		update inc2;

		// verify
		for (Incident inc: getIncidents(incIds))
		{
			System.debug(JSON.serializePretty(inc));
			String MultiStatus, SyncFlag;

			// check for sync flag, multi mode
			if (inc.Id == incId1)
			{
				SyncFlag    = null;
				MultiStatus = null;
			}
			else if (inc.Id == incId2)
			{
				SyncFlag    = Outage_IncidentProcessor.SYNC_MC_SYNC;
				MultiStatus = Outage_IncidentProcessor.AFF_NMI_SINGLE_INC;
			}

			for (Affected_Customer__c affCust: inc.Affected_Customers__r)
			{
				System.assertEquals(SyncFlag, affCust.MC_Sync__c);
				System.assertEquals(MultiStatus, affCust.Multi_Incident__c);

				// reset the flag
				if (inc.Id == incId2)
				{
					affCust.MC_Sync__c = null;
					updList.add(affCust);
				}
			}
		}

		// reset the flag
		updateList(updList);

		// Let's update second incident again - and test not syncing on status 1 and 2.
		resetTrigger();
		inc2.Status = Outage_IncidentProcessor.INCIDENT_STS_1_REPORTED;
		update inc2;

		// verify
		for (Incident inc: getIncidents(incIds))
		{
			System.debug(JSON.serializePretty(inc));
			String MultiStatus, SyncFlag;

			// check for sync flag, multi mode
			if (inc.Id == incId1)
			{
				SyncFlag    = null;
				MultiStatus = null;
			}
			else if (inc.Id == incId2)
			{
				SyncFlag    = null;
				MultiStatus = Outage_IncidentProcessor.AFF_NMI_SINGLE_INC;
			}

			for (Affected_Customer__c affCust: inc.Affected_Customers__r)
			{
				System.assertEquals(SyncFlag, affCust.MC_Sync__c);
				System.assertEquals(MultiStatus, affCust.Multi_Incident__c);

				// reset the flag
				if (inc.Id == incId2)
				{
					affCust.MC_Sync__c = null;
					updList.add(affCust);
				}
			}
		}

		// reset the flag
		updateList(updList);

		// Let's update second incident one last time - and set to resolved
		resetTrigger();	
		inc2.Status = Outage_IncidentProcessor.INCIDENT_STS_7_RESTORED;
		update inc2;

		// verify
		for (Incident inc: getIncidents(incIds))
		{
			System.debug(JSON.serializePretty(inc));
			String MultiStatus, SyncFlag;

			// check for sync flag, multi mode
			if (inc.Id == incId1)
			{
				SyncFlag    = null;
				MultiStatus = null;
			}
			else if (inc.Id == incId2)
			{
				SyncFlag    = Outage_IncidentProcessor.SYNC_MC_SYNC;
				MultiStatus = Outage_IncidentProcessor.AFF_NMI_SINGLE_INC;
			}

			for (Affected_Customer__c affCust: inc.Affected_Customers__r)
			{
				System.assertEquals(SyncFlag, affCust.MC_Sync__c);
				System.assertEquals(MultiStatus, affCust.Multi_Incident__c);
			}
		}
	}

	public static testMethod void test_AffNMICreateAffCust_queueable()
	{
		User testUser = UtilDatabase_Test.getTestUser();
		Outage_DataFactory.getODF().generateCustomers(50);
		
		Test.startTest();
		System.runAs(testUser)
		{
			Outage_DataFactory.getODF().generateIncidents(10);
			Map<Id, Outage_IncidentProcessor.IncidentUpdate> incUpdates = new Map<Id, Outage_IncidentProcessor.IncidentUpdate>();
			
			for (Incident inc: Outage_DataFactory.getODF().incidents)
			{
				inc.Status = Outage_IncidentProcessor.INCIDENT_STS_7_RESTORED;

				Outage_IncidentProcessor.IncidentUpdate incUpd = new Outage_IncidentProcessor.IncidentUpdate(inc);
				incUpd.incStatusUpdated = true;
				incUpdates.put(incUpd.incidentId, incUpd);
			}

			Outage_AsyncProcessor AsyncNull = new Outage_AsyncProcessor(null);
			Outage_AsyncProcessor Async = new Outage_AsyncProcessor(incUpdates);
			Id jobId = System.enqueueJob(Async);
			System.debug(jobId);

		}
		Test.stopTest();
	}

	public static testMethod void test_AffNMICreateAffCust_nmiRestored()
	{
		User testUser = UtilDatabase_Test.getTestUser();

		Outage_DataFactory.getODF().generateCustomers(5);
		Outage_DataFactory.getODF().generateIncidents(1);
		Outage_IncidentProcessor.isRunningCreateAffCust = false;

		Test.startTest();
		System.runAs(testUser)
		{
			Affected_Market_Identifier__c affNMI = Outage_DataFactory.getODF().affectedNMIs.get(0);
			affNMI.uom_Status__c = Outage_IncidentProcessor.AFF_NMI_RESOLVED;
			update affNMI;
		}
		Test.stopTest();
	}

	public static testMethod void test_AffNMICreateAffCust_intComplete()
	{
		User testUser = UtilDatabase_Test.getTestUser();

		Outage_DataFactory.getODF().generateCustomers(5);
		Outage_DataFactory.getODF().generateIncidents(1);

		Test.startTest();
		System.runAs(testUser)
		{
			Incident inc = Outage_DataFactory.getODF().incidents.get(0);
			inc.Status = Outage_IncidentProcessor.INCIDENT_STS_3_RESPONDING;
			inc.Integration_Status__c = Outage_IncidentProcessor.INT_STS_COMPLETE;
			update inc;
		}
		Test.stopTest();
	}

	public static testMethod void test_AffNMICreateAffCust_MergedIncidents()
	{
		User testUser = UtilDatabase_Test.getTestUser();

		Outage_DataFactory.getODF().generateCustomers(5);
		Outage_DataFactory.getODF().generateIncidents(1);

		// Create an Incident
		Incident newInc = new Incident(
		uom_Incident_Id__c = 'Inc-1',
		Status = Outage_IncidentProcessor.INCIDENT_STS_1_REPORTED,
		Type = 'Unplanned',
		Priority = '1',
		Incident_Notifications__c = Outage_IncidentProcessor.INC_NOTIFS_AUTO,
		StartDateTime = System.now().addMinutes(-10)
		);
		
		insert newInc;
		Set<Id> incIds = new Set<Id>{ newInc.Id, Outage_DataFactory.getODF().incidents.get(0).Id };
		resetSyncMCFlag(incIds, Outage_IncidentProcessor.SYNC_MC_COMPLETE);

		Test.startTest();
		System.runAs(testUser)
		{
			Incident mergedInc = Outage_DataFactory.getODF().incidents.get(0);
			mergedInc.Status = Outage_IncidentProcessor.INCIDENT_STS_10_MERGED;
			mergedInc.Merged_Incident_Id__c = newInc.uom_Incident_Id__c;
			update mergedInc;
			resetSyncMCFlag(incIds, Outage_IncidentProcessor.SYNC_MC_COMPLETE);

			List<Affected_Customer__c> affCusList = [SELECT Id, NMI__c, uom_Incident_Status__c FROM Affected_Customer__c WHERE uom_Incident__r.uom_Incident_Id__c = :mergedInc.uom_Incident_Id__c];
			// Validate initial incidents size and the first affected customers uom_Incident_Status__c
			Assert.areEqual(5, affCusList.size());
			Assert.areEqual(Outage_IncidentProcessor.INCIDENT_STS_10_MERGED, affCusList.get(0).uom_Incident_Status__c);

			// Store Id to use later to check merge occurs
			Id affCusIdbeforeMerge = affCusList.get(0).Id;

			// Create new Affected Market Identifier on the new Incident created
			Affected_Market_Identifier__c ami = new Affected_Market_Identifier__c(
			Multi_Incident__c = 'Single Incident',
            Name = affCusList.get(0).NMI__c,
			uom_Incident__c = newInc.Id,
			uom_Status__c = 'In Progress',
			uom_Status_Code__c = 'PRED',
			uom_Unique_Market_Identifier__c = 'Inc-1_' + affCusList.get(0).NMI__c
			);

			insert ami;

			// Validate the original incident affected customers is reduced by 1
			affCusList = [SELECT Id FROM Affected_Customer__c WHERE uom_Incident__r.uom_Incident_Id__c = :mergedInc.uom_Incident_Id__c];
			Assert.areEqual(4, affCusList.size());

			// Validate the new incident has 1 affected customers from the original incident
			affCusList = [SELECT Id, uom_Incident_Status__c FROM Affected_Customer__c WHERE uom_Incident__r.uom_Incident_Id__c = :newInc.uom_Incident_Id__c];
			Assert.areEqual(1, affCusList.size());
			Assert.areEqual(affCusIdbeforeMerge, affCusList.get(0).Id);

			// Validate the affected customers reflects the new incidents values (one of few fields updated)
			Assert.areEqual(newInc.Status, affCusList.get(0).uom_Incident_Status__c);
		}
		Test.stopTest();
	}

	public static testMethod void test_AffNMICreateAffCust_NMINoCustomers()
	{
		User testUser = UtilDatabase_Test.getTestUser();
		Integer numCustomers   = 10;
		Integer numNMIsNoCusts = 5;

		// gen real customers
		Outage_DataFactory.getODF().generateCustomers(numCustomers);
		Outage_DataFactory.getODF().generateIncidents(1);

		// gen broken customers
		Outage_DataFactory.getODF().generatePremises(numNMIsNoCusts, false);
		Outage_DataFactory.getODF().generateNMIs(numNMIsNoCusts);

		// add broken nmis to incident
		Incident inc = Outage_DataFactory.getODF().incidents[0];
		Set<Id> incIds = new Set<Id>{inc.Id};
		UtilDatabase db = new UtilDatabase();

		for (vlocity_cmt__ServicePoint__c nmi: Outage_DataFactory.getODF().nmis)
		{
			Affected_Market_Identifier__c affNMI = new Affected_Market_Identifier__c();
			affNMI.uom_Incident__c = inc.Id;
			affNMI.Name = nmi.Name;
			affNMI.uom_Unique_Market_Identifier__c = inc.uom_Incident_Id__c +'_'+ affNMI.Name;
			affNMI.uom_Status_Code__c = Outage_IncidentProcessor.AFF_NMI_CODE_PRED;
			db.addObjForUpsert(affNMI);
		}
		db.upsertObjs();

		resetSyncMCFlag(incIds, Outage_IncidentProcessor.SYNC_MC_COMPLETE);

		// Confirm sizes
		// 50 customers
		// 70 affected nmis
		Incident checkIncident = getIncidents(incIds).get(0);
		System.assertEquals(numCustomers, checkIncident.Affected_Customers__r.size());
		System.assertEquals(numNMIsNoCusts+numCustomers, checkIncident.Affected_Market_Identifiers__r.size());

		Test.startTest();
		System.runAs(testUser)
		{
			Outage_IncidentProcessor.setQueryLimit(numCustomers * 2);

			inc.Status = Outage_IncidentProcessor.INCIDENT_STS_7_RESTORED;
			update inc;
			resetSyncMCFlag(incIds, Outage_IncidentProcessor.SYNC_MC_COMPLETE);

			// Confirm updates
			checkIncident = getIncidents(incIds).get(0);

			for (Affected_Customer__c affCust: checkIncident.Affected_Customers__r)
			{
				System.assertEquals(Outage_IncidentProcessor.INCIDENT_STS_7_RESTORED, affCust.uom_Incident_Status__c);
				System.assertEquals(Outage_IncidentProcessor.AFF_NMI_RESOLVED, affCust.uom_Aff_NMI_Status__c);
			}

			for (Affected_Market_Identifier__c affNMI: checkIncident.Affected_Market_Identifiers__r)
			{
				System.assertEquals(Outage_IncidentProcessor.AFF_NMI_RESOLVED, affNMI.uom_Status__c);
			}
		}
		Test.stopTest();
	}

	public static testMethod void test_AffNMICreateAffCust_IncidentIdText()
	{
		User testUser = UtilDatabase_Test.getTestUser();

		Outage_DataFactory.getODF().generateCustomers(5);
		Outage_DataFactory.getODF().generateIncidentRecords(1);
		Incident inc = Outage_DataFactory.getODF().incidents[0];

		Test.startTest();
		System.runAs(testUser)
		{
			// add broken nmis to incident
			UtilDatabase db = new UtilDatabase();

			for (vlocity_cmt__ServicePoint__c nmi: Outage_DataFactory.getODF().nmis)
			{
				Affected_Market_Identifier__c affNMI = new Affected_Market_Identifier__c();

				affNMI.Name = nmi.Name;
				affNMI.uom_Status_Code__c = Outage_IncidentProcessor.AFF_NMI_CODE_PRED;
				affNMI.IncidentIdText__c = inc.uom_Incident_Id__c;
				affNMI.uom_Unique_Market_Identifier__c = inc.uom_Incident_Id__c +'_'+ affNMI.Name;
				db.addObjForUpsert(affNMI);
			}
			db.upsertObjs();
		}
		Test.stopTest();
	}


	private static void updateList(List<SObject> updList)
	{
		if (updList == null || updList.isEmpty())
			return;

		update updList;
		updList.clear();
	}

	private static List<Incident> getIncidents(Set<Id> incIds)
	{
		return [SELECT Id, Subject, Status,
		(SELECT Id, Name, uom_Incident_Status__c, uom_Affected_Market_Identifier__c, uom_Incident__c,
		uom_Aff_NMI_Status__c, uom_Estimated_assessment_date__c, uom_Estimated_restoration_date__c,
		MC_Sync__c, MC_Sync_History__c, Incident_Notifications__c,
		Multi_Incident__c
		FROM Affected_Customers__r),
		(SELECT Id, Name, Multi_Incident__c, uom_Status__c
		FROM Affected_Market_Identifiers__r)
		FROM Incident
		WHERE Id IN :incIds
		ORDER BY CreatedDate ASC];
	}

	private static void resetSyncMCFlag(Set<Id> incIds, String value)
	{
		List<SObject> updList = new List<SObject>();

		for (Incident inc: getIncidents(incIds))
		{
			for (Affected_Customer__c affCust: inc.Affected_Customers__r)
			{
				affCust.MC_Sync__c = value;
				updList.add(affCust);
			}
		}

		updateList(updList);
	}

	private static void resetTrigger()
	{
		Outage_IncidentProcessor.enableFutureMultiInc = false;
		Outage_IncidentProcessor.isRunningCreateAffCust = false;
		Outage_IncidentProcessor.isRunningUpdateMultiInc = false;
	}
}