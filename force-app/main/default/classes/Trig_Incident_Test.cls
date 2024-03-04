@isTest
public class Trig_Incident_Test {
public static testMethod void incident_insert_success()
	{
        
        
        Outage_DataFactory odf = Outage_DataFactory.getODF();
        odf.generateCustomers(1);
        odf.generateIncidents(2);
        
        
        odf.generateTasks(1);
		odf.incidents[0].Status = Outage_IncidentProcessor.INCIDENT_STS_7_RESTORED;

        update odf.incidents[0];
        
        delete odf.incidents[1];
        undelete odf.incidents[1];
        
    }
    
    public static testMethod void setIncidentCauseAndDelay()
    {
        Outage_DataFactory odf = Outage_DataFactory.getODF();
        odf.generateCustomers(1);
        odf.generateIncidents(4);
        odf.generateTasks(1);
        odf.incidents[0].uom_Delay_Reason__c = 'DR05';
        odf.incidents[0].Status = 'Restored';
        odf.incidents[1].uom_Cause__c = 'DR03';
        odf.incidents[2].uom_Delay_Reason__c = 'DF04';
        odf.incidents[2].Status = 'Awaiting Assessment';
        odf.incidents[2].uom_Cause__c = 'DF04';
        test.startTest();
        update odf.incidents[0];
        update odf.incidents[1];
		update odf.incidents[2];
        test.stopTest();
        Trig_Incident.setIncidentCauseAndDelay(new list<Incident>());
        
    }
}