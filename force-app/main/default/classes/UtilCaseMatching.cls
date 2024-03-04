/*
  @author  : brajesh.tiwary@ausnetservices.com.au
  @created : 31 Oct 2019
  @Description : Match NMI and meter and update case
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  31 Oct 2019           Brajesh                        Added method updateCaseMatchingNmiMeter
  -----------------------------------------------------------------------------------------
*/
public class UtilCaseMatching
{
	public static Boolean isRunning_casesMatched = false;
	private static Set<String> DER_RecordTypes = new Set<String>{DER_REST_Application_v1.CASE_RECORDTYPE_AUTO, DER_REST_Application_v1.CASE_RECORDTYPE_MANUAL};

	//----Update Case status and cancelled reason-----//
	public static void updateCaseMatchingNmiMeter(map<string,string> mapNMIMeter)
	{
		isRunning_casesMatched = true;
		List<Case> lstCaseUpd = new List<Case>();

		for(Case caseItem: [SELECT Id, Status, DER_Application__c, Cancelled_Reason__c,
							DER_Application__r.NMI__c, DER_Application__r.Meter_Number__c
							FROM Case
							WHERE DER_Application__r.NMI__c IN :mapNMIMeter.keySet()
							AND DER_Application__r.Meter_Number__c IN :mapNMIMeter.values()
							AND IsClosed = false
							AND RecordType.DeveloperName IN :DER_RecordTypes])
		{
			if (mapNMIMeter.containsKey(caseItem.DER_Application__r.NMI__c) &&
				mapNMIMeter.get(caseItem.DER_Application__r.NMI__c) != null &&
				mapNMIMeter.get(caseItem.DER_Application__r.NMI__c) == caseItem.DER_Application__r.Meter_Number__c)
			{
				Case updCase = new Case(Id = caseItem.Id);
				updCase.Status = 'Cancelled';
				updCase.Cancelled_Reason__c = 'Applicant Declined';
				lstCaseUpd.add(updCase);
			}
		}

		if (!lstCaseUpd.isEmpty()) update lstCaseUpd;
	}
}