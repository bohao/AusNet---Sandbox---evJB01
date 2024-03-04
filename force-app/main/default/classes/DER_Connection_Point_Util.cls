/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 15 Oct 2019
  @Description : Util Class for Connection_Point__c Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  24/10/2019                    Brajesh                              CMC1401
  12-Nov-19            Pavan Dave                     Since Integration Profile user not able to query external object, chaning to 'without sharing' (CMC-1595)
  -----------------------------------------------------------------------------------------
*/

public without sharing class DER_Connection_Point_Util
{
	public static Boolean isRunning_PopulateExternalNMIRef = false;
	public static Boolean runAsFuture = true;
	public static Boolean updateCase = true;
	@TestVisible private static List<NmiDataSets__x> mockedExtNMI = new List<NmiDataSets__x>();

	@future
	public static void futurePopulateExternalNMIRef(Set<Id> validExtNMIRef_Pop, Set<Id> validExtNMIRef_Clear)
	{
		runAsFuture = false;
		PopulateExternalNMIRef(validExtNMIRef_Pop, validExtNMIRef_Clear);
	}

	public static void PopulateExternalNMIRef(Set<Id> validExtNMIRef_Pop, Set<Id> validExtNMIRef_Clear)
	{
		if (runAsFuture && !System.isFuture())
		{
			futurePopulateExternalNMIRef(validExtNMIRef_Pop, validExtNMIRef_Clear);
			return;
		}

		isRunning_PopulateExternalNMIRef = true;
		List<Connection_Point__c> lstConPointUpd = new List<Connection_Point__c>();
		Connection_Point__c conPoint;
		Set<Id> NMIIds = new Set<Id>();

		if (validExtNMIRef_Pop == null) validExtNMIRef_Pop = new Set<Id>();
		if (validExtNMIRef_Clear == null) validExtNMIRef_Clear = new Set<Id>();

		try
		{
			if (!validExtNMIRef_Pop.isEmpty())
			{
				Map<Id, Connection_Point__c> mapConPoints = new Map<Id, Connection_Point__c>([SELECT Id, NMI__c, Name,
																								Building_Name__c,House_Num_1__c,House_Num_2__c, Haus_Num_2__c,Floor__c,Street__c,
																								Post_Code__c,City__c,Country__c,State__c
																							FROM Connection_Point__c
																							WHERE Id IN :validExtNMIRef_Pop]);
				Set<String> lstExternalId = new Set<String>();
				for (Connection_Point__c item: mapConPoints.values())
				{
					if (item.NMI__c != null)
					{
						lstExternalId.add(item.NMI__c);
					}
				}

				if (!lstExternalId.isEmpty())
				{
					List <NmiDataSets__x> lstExtNMI;
					if (!mockedExtNMI.isEmpty())
					{
						// test data is set using test class
						lstExtNMI = mockedExtNMI;
					}
					else
					{
						lstExtNMI = new List<NmiDataSets__x> ([SELECT Id, ExternalId, Building__c, City1__c, Country__c,
																						Floor__c, HausNum2__c, HouseNum1__c,
																						HouseNum2__c, Location__c, Nmistatuscode__c,
																						Nmi__c, PostCode1__c, RegionalStructure__c,
																						Region__c, Street__c,StrSuppl1__c
																					FROM NmiDataSets__x
																					WHERE ExternalId IN: lstExternalId]);
					}

					Map<String, NmiDataSets__x> mapExtIdExtMtr = new Map<String, NmiDataSets__x>();
					for (NmiDataSets__x item: lstExtNMI)
					{
						mapExtIdExtMtr.put(item.ExternalId, item);
					}

					for (Id item: mapConPoints.keySet())
					{
						conPoint = mapConPoints.get(item);

						if (conPoint.NMI__c != null &&
							mapExtIdExtMtr.containsKey(conPoint.NMI__c) &&
							conPoint.NMI__c == (mapExtIdExtMtr.get(conPoint.NMI__c)).ExternalId)
						{
							conPoint.NMI_Ref__c = (mapExtIdExtMtr.get(conPoint.NMI__c)).ExternalId;
							conPoint.Name = 'NMI: ' + conPoint.NMI__c;
							conPoint.Building_Name__c = (mapExtIdExtMtr.get(conPoint.NMI__c)).StrSuppl1__c;
							conPoint.House_Num_1__c = (mapExtIdExtMtr.get(conPoint.NMI__c)).HouseNum1__c;
							conPoint.House_Num_2__c = (mapExtIdExtMtr.get(conPoint.NMI__c)).HouseNum2__c;
							conPoint.Haus_Num_2__c = (mapExtIdExtMtr.get(conPoint.NMI__c)).HausNum2__c;
							conPoint.Floor__c = (mapExtIdExtMtr.get(conPoint.NMI__c)).Floor__c;
							conPoint.Street__c = (mapExtIdExtMtr.get(conPoint.NMI__c)).Street__c;
							conPoint.Post_Code__c = (mapExtIdExtMtr.get(conPoint.NMI__c)).PostCode1__c;
							conPoint.City__c = (mapExtIdExtMtr.get(conPoint.NMI__c)).City1__c;
							conPoint.Country__c = (mapExtIdExtMtr.get(conPoint.NMI__c)).Country__c;
							conPoint.State__c = (mapExtIdExtMtr.get(conPoint.NMI__c)).Region__c;

							lstConPointUpd.add(conPoint);
							NMIIds.add(conPoint.Id);
						}
						else
						{
							conPoint.NMI_Ref__c = null;
							if (conPoint.NMI__c != null)
								conPoint.Name = 'NMI: ' + conPoint.NMI__c;

							lstConPointUpd.add(conPoint);
							NMIIds.add(conPoint.Id);
						}
					}


				}
			}

			if (!validExtNMIRef_Clear.isEmpty())
			{
				Map<Id, Connection_Point__c> mapConPoints = new Map<Id, Connection_Point__c>([SELECT Id, NMI__c, NMI_Ref__c, Name, Building_Name__c,House_Num_1__c,
																							House_Num_2__c, Haus_Num_2__c,Floor__c,Street__c,
																							Post_Code__c,City__c,Country__c,State__c
																							FROM Connection_Point__c
																							WHERE Id IN: validExtNMIRef_Clear]);

				for (Id item: mapConPoints.keySet())
				{
					conPoint = mapConPoints.get(item);
					conPoint.NMI_Ref__c = null;
					if (conPoint.NMI__c != null)
						conPoint.Name = 'NMI: ' + conPoint.NMI__c;
					conPoint.Building_Name__c = null;
					conPoint.House_Num_1__c = null;
					conPoint.House_Num_2__c = null;
					conPoint.Haus_Num_2__c = null;
					conPoint.Floor__c = null;
					conPoint.Street__c = null;
					conPoint.Post_Code__c = null;
					conPoint.City__c = null;
					conPoint.Country__c = null;
					conPoint.State__c = null;

					lstConPointUpd.add(conPoint);
					NMIIds.add(conPoint.Id);
				}
			}

			if (!lstConPointUpd.isEmpty()) update lstConPointUpd;

			if (!NMIIds.isEmpty() && updateCase)
			{
				List<Case> updCases = [SELECT Id FROM Case 
									   WHERE IsClosed=false 
									   AND DER_Application__r.NMI__c IN :NMIIds];

				if (updCases != null && !updCases.isEmpty())
				{
					for (Case c: updCases)
						c.Case_Ready__c = true;

					update updCases;
				}
			}
		}
		catch(Exception e)
		{
			system.debug('DER_Connection_Point_Util.PopulateExternalNMIRef'+'Exception Occurred. Message: ' + e.getMessage()
										+ ' StackTrace: ' + e.getStackTraceString()
										+ ' Type: ' + e.getTypeName()
										+ ' Cause: ' + e.getCause());
		}
	}
}