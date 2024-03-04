@isTest
public class Trig_ServicePointTest
{
	public static testMethod void test_CheckforDuplicates_1()
	{
		// Write Apex test class for this trigger
		User testUser = UtilDatabase_Test.getTestUser();
		Test.startTest();

		// Create a premise record (as per Data factory)
		// Create new, unique NMI record
		// populate Name, Service Type, Status, Market Identifier, Premise values.
		Outage_DataFactory.getODF().generatePremises(1, false);
		vlocity_cmt__Premises__c premise = Outage_DataFactory.getODF().premises[0];

		String NMI1 = 'test-001';
		vlocity_cmt__ServicePoint__c NMI_1 = new vlocity_cmt__ServicePoint__c();
		NMI_1.Name = NMI_1.vlocity_cmt__MarketIdentifier__c = NMI1;
		NMI_1.vlocity_cmt__ServiceType__c = 'Electricity';
		NMI_1.vlocity_cmt__Status__c = Outage_IncidentProcessor.SERV_POINT_STS_ACTIVE;
		NMI_1.vlocity_cmt__PremisesId__c = premise.Id;

		insert NMI_1;
		Trig_ServicePoint.isRunningCheckforDuplicates = false;

		// Query the NMI record: assert Data Duplication=”Original”
		Set<Id> nmiIds = new Set<Id>{NMI_1.Id};
		for (vlocity_cmt__ServicePoint__c nmi: getNMIs(nmiIds))
		{
			System.assertEquals(Outage_IncidentProcessor.SERV_POINT_ORIG, nmi.Data_Duplication__c);
			break;
		}


		// Clone the NMI record and insert into database
		// Query the NMI records:
		// assert first record is Data Duplication=”Original”
		// assert second record is Data Duplication=”Duplicate”
		vlocity_cmt__ServicePoint__c NMI_2 = NMI_1.clone(false, true, false, false);
		insert NMI_2;
		Trig_ServicePoint.isRunningCheckforDuplicates = false;
		nmiIds.add(NMI_2.Id);

		for (vlocity_cmt__ServicePoint__c nmi: getNMIs(nmiIds))
		{
			if (nmi.Id == NMI_1.Id)
			{
				System.assertEquals(Outage_IncidentProcessor.SERV_POINT_ORIG, nmi.Data_Duplication__c);
			}
			else if (nmi.Id == NMI_2.Id)
			{
				System.assertEquals(Outage_IncidentProcessor.SERV_POINT_DUPE, nmi.Data_Duplication__c);
			}
		}


		// update the first record - set as Status=Inactive
		// Query the NMI records:
		// assert first record is Data Duplication=null
		// assert second record is Data Duplication=”Original”
		NMI_1.vlocity_cmt__Status__c = Outage_IncidentProcessor.SERV_POINT_STS_INACTIVE;
		update NMI_1;
		Trig_ServicePoint.isRunningCheckforDuplicates = false;

		for (vlocity_cmt__ServicePoint__c nmi: getNMIs(nmiIds))
		{
			if (nmi.Id == NMI_1.Id)
			{
				System.assertEquals(null, nmi.Data_Duplication__c);
			}
			else if (nmi.Id == NMI_2.Id)
			{
				System.assertEquals(Outage_IncidentProcessor.SERV_POINT_ORIG, nmi.Data_Duplication__c);
			}
		}


		// Insert third NMI record, with
		// same Market Identifier value
		// Status=Inactive
		// Query the NMI records:
		// assert first record is Data Duplication=null
		// assert second record is Data Duplication=”Original”
		// assert third record is Data Duplication=null
		vlocity_cmt__ServicePoint__c NMI_3 = NMI_1.clone(false, true, false, false);
		insert NMI_3;
		Trig_ServicePoint.isRunningCheckforDuplicates = false;
		nmiIds.add(NMI_3.Id);

		for (vlocity_cmt__ServicePoint__c nmi: getNMIs(nmiIds))
		{
			if (nmi.Id == NMI_1.Id)
			{
				System.assertEquals(null, nmi.Data_Duplication__c);
			}
			else if (nmi.Id == NMI_2.Id)
			{
				System.assertEquals(Outage_IncidentProcessor.SERV_POINT_ORIG, nmi.Data_Duplication__c);
			}
			else if (nmi.Id == NMI_3.Id)
			{
				System.assertEquals(null, nmi.Data_Duplication__c);
			}
		}


		// update third NMI record to Status=Active
		// Query the NMI records:
		// assert first record is Data Duplication=null
		// assert second record is Data Duplication=”Original”
		// assert third record is Data Duplication=”Duplicate”
		NMI_3.vlocity_cmt__Status__c = Outage_IncidentProcessor.SERV_POINT_STS_ACTIVE;
		update NMI_3;
		Trig_ServicePoint.isRunningCheckforDuplicates = false;

		for (vlocity_cmt__ServicePoint__c nmi: getNMIs(nmiIds))
		{
			if (nmi.Id == NMI_1.Id)
			{
				System.assertEquals(null, nmi.Data_Duplication__c);
			}
			else if (nmi.Id == NMI_2.Id)
			{
				System.assertEquals(Outage_IncidentProcessor.SERV_POINT_ORIG, nmi.Data_Duplication__c);
			}
			else if (nmi.Id == NMI_3.Id)
			{
				System.assertEquals(Outage_IncidentProcessor.SERV_POINT_DUPE, nmi.Data_Duplication__c);
			}
		}


		// update first NMI record to Status=Active
		// Query the NMI records:
		// assert first record is Data Duplication=”Original”
		// assert second record is Data Duplication=”Duplicate”
		// assert third record is Data Duplication=”Duplicate”
		NMI_1.vlocity_cmt__Status__c = Outage_IncidentProcessor.SERV_POINT_STS_ACTIVE;
		update NMI_1;
		Trig_ServicePoint.isRunningCheckforDuplicates = false;

		for (vlocity_cmt__ServicePoint__c nmi: getNMIs(nmiIds))
		{
			if (nmi.Id == NMI_1.Id)
			{
				System.assertEquals(Outage_IncidentProcessor.SERV_POINT_ORIG, nmi.Data_Duplication__c);
			}
			else if (nmi.Id == NMI_2.Id)
			{
				System.assertEquals(Outage_IncidentProcessor.SERV_POINT_DUPE, nmi.Data_Duplication__c);
			}
			else if (nmi.Id == NMI_3.Id)
			{
				System.assertEquals(Outage_IncidentProcessor.SERV_POINT_DUPE, nmi.Data_Duplication__c);
			}
		}

		Test.stopTest();
	}

	private static List<vlocity_cmt__ServicePoint__c> getNMIs(Set<Id> nmiIds)
	{
		return [SELECT Id, Name, vlocity_cmt__MarketIdentifier__c, vlocity_cmt__ServiceType__c,
				vlocity_cmt__Status__c, vlocity_cmt__PremisesId__c, Data_Duplication__c
				FROM vlocity_cmt__ServicePoint__c
				WHERE Id IN :nmiIds
				ORDER BY CreatedDate ASC];
	}
}