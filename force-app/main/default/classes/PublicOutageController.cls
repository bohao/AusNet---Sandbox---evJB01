public without sharing class PublicOutageController {
    @AuraEnabled(cacheable=true)
    public static List<Incident> getIncidents() {
        return [SELECT Id, uom_Incident_Id__c, Public_Status__c, Type,uom_Estimated_restoration_date__c, 
        Public_Assessment_Date__c, uom_Operating_Zone__c, Affected_Suburbs__c, StartDateTime, Category, uom_Number_Off_Supply__c
        FROM Incident
        WHERE Status != 'Merged' AND Status != 'Cancelled' AND Status != 'Restored' AND uom_Number_Off_Supply__c != 0
        ORDER BY uom_Operating_Zone__c ASC, StartDateTime ASC];
    }
}