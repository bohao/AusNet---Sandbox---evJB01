@isTest
public class Trig_AffectedCustomer_Test {

	public static testMethod void affCust_insert_success()
	{
			Outage_DataFactory odf = Outage_DataFactory.getODF();
			odf.generateCustomers(1,true, true);
			odf.generateIncidents(1);

			List<Affected_Customer__c> affCusts = [SELECT Id, Name, uom_Life_Support__c
										   FROM Affected_Customer__c
										   WHERE uom_Incident__c = :odf.incidents[0].Id];

			if (affCusts == null || affCusts.isEmpty())
			{
				// Error
				System.debug('Error: Affected Customers not found');
				return;
			}


			affCusts[0].uom_Incident_Status__c=Outage_IncidentProcessor.INCIDENT_STS_7_RESTORED;

			update affCusts[0];
			delete affCusts[0];
			undelete affCusts[0];


	}

}