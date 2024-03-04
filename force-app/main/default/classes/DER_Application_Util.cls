/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 15 Oct 2019
  @Description : Util Class for DER_Application__c Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  12-Nov-19            Pavan Dave                     Since Integration Profile user not able to query external object, chaning to 'without sharing' (CMC-1595)
  -----------------------------------------------------------------------------------------
*/

public without sharing class DER_Application_Util {

	public static Boolean isRunning_PopulateExternalMeter = false;
    public static String DASH = '-';
	@TestVisible private static List<MeterDataSets__x> mockedExtMtr = new List<MeterDataSets__x>();

	@future
	public static void PopulateExternalMeter(List<Id> validExtMeter_Pop, List<Id> validExtMeter_Clear)
	{
		isRunning_PopulateExternalMeter = true;
		List<DER_Application__c> lstDERAppUpd;
		DER_Application__c derApp;
		try{
			if (!validExtMeter_Pop.isEmpty())
			{
				lstDERAppUpd = new List<DER_Application__c>();
				Map<Id, DER_Application__c> mapDERApp = new Map<Id, DER_Application__c>([SELECT Id, Meter_Ref__c, Meter_Install_Type_Code__c,
																								NMI__r.Nmi__c, Meter_Number__c
																							FROM DER_Application__c
																							WHERE Id IN: validExtMeter_Pop]);

				List<String> lstExternalId = new List<String>();
				for(DER_Application__c item: mapDERApp.values())
				{
					if(item.NMI__c != null && String.isNotBlank(item.NMI__r.NMI__c))
					{
						lstExternalId.add(item.NMI__r.NMI__c +DASH+item.Meter_Number__c);
					}
				}
				if(!lstExternalId.isEmpty())
				{
					List <MeterDataSets__x> lstExtMtr;
					if(!mockedExtMtr.isEmpty())
					{
						lstExtMtr = mockedExtMtr;
					}
					else
					{
						lstExtMtr = new List<MeterDataSets__x> ([SELECT Id, ExternalId, Nmi__c, InstallTypeCode__c,
																		SerialNumber__c
																	FROM MeterDataSets__x
																	WHERE ExternalId IN: lstExternalId]);
					}
					Map<String, MeterDataSets__x> mapSerNumExtMtr = new Map<String, MeterDataSets__x>();
					for(MeterDataSets__x item: lstExtMtr)
					{
						mapSerNumExtMtr.put(item.SerialNumber__c, item);
					}

					for(Id item: mapDERApp.keySet())
					{
						derApp = mapDERApp.get(item);

						if(mapSerNumExtMtr.containsKey(derApp.Meter_Number__c)
						&& derApp.Meter_Number__c == (mapSerNumExtMtr.get(derApp.Meter_Number__c)).SerialNumber__c)
						{
							derApp.Meter_Ref__c = (mapSerNumExtMtr.get(derApp.Meter_Number__c)).ExternalId;
							derApp.Meter_Install_Type_Code__c = (mapSerNumExtMtr.get(derApp.Meter_Number__c)).InstallTypeCode__c;
							lstDERAppUpd.add(derApp);
						}
						else
						{
							derApp.Meter_Ref__c = null;
							derApp.Meter_Install_Type_Code__c = null;
							lstDERAppUpd.add(derApp);
						}
					}

					if(!lstDERAppUpd.isEmpty()) update lstDERAppUpd;
				}
			}

			if (!validExtMeter_Clear.isEmpty())
			{
				Map<Id, DER_Application__c> mapDERApp = new Map<Id, DER_Application__c>([SELECT Id, Meter_Ref__c, Meter_Install_Type_Code__c
																							FROM DER_Application__c
																							WHERE Id IN: validExtMeter_Clear]);
				lstDERAppUpd = new List<DER_Application__c>();
				for(Id item: mapDERApp.keySet())
				{
					derApp = mapDERApp.get(item);
					derApp.Meter_Ref__c = null;
					derApp.Meter_Install_Type_Code__c = null;
					lstDERAppUpd.add(derApp);
				}

				if(!lstDERAppUpd.isEmpty()) update lstDERAppUpd;
			}
		}catch(Exception e){
            system.debug('DER_Application_Util.PopulateExternalMeter'+'Exception Occurred. Message: ' + e.getMessage() 
                                        + ' StackTrace: ' + e.getStackTraceString()
                                        + ' Type: ' + e.getTypeName()
                                        + ' Cause: ' + e.getCause());
        }
	}
}