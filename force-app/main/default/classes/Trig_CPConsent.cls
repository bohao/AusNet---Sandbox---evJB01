public with sharing class Trig_CPConsent implements UtilTrigHandle
{
	// *********************************************************************
	// *** Disable logic
	public static Boolean TrigDisabled = false;
	public static Boolean isSetOptedOutCheckbox = false;

	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().CPC_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}


	// *********************************************************************
	// *** Trigger contexts
	public void BeforeInsert(List<SObject> newSObjs)
	{
		setCPEndpoint(newSObjs);
		setCPName(newSObjs);
		handleOptedOutCheckboxes(newSObjs);
	}

	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
	{
		setCPEndpoint(newSObjs.values());
		updateSetCPName(newSObjs.values());
		setOptedOutCheckbox(newSObjs.values(), (Map<Id, ContactPointConsent>) oldSObjs);
		handleOptedOutCheckboxes(newSObjs.values());
	}


	// if context is not implemented, condense into one-liners
	public void AfterInsert(Map<Id, SObject> newSObjs) {}
	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) {}
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> oldSObjs) {}


	// *********************************************************************
	// *** Trigger methods

	private static void setCPEndpoint(List<ContactPointConsent> newCPCs)
	{
		Map<Id, String> CPPhoneIds = new Map<Id, String>();
		Map<Id, String> CPEmailIds = new Map<Id, String>();

		String CPE_Prefix = '9Vl';
		String CPP_Prefix = '0Ow';

		for (ContactPointConsent CPC: newCPCs)
		{
			if (CPC.ContactPointId == null) continue;
			if (CPC.Status__c != Outage_IncidentProcessor.CPC_STS_ACTIVE) continue;

			String CPId = CPC.ContactPointId; // cheating here, Id into String type

			if (CPId.startsWith(CPE_Prefix))
				CPEmailIds.put(CPId, null);

			if (CPId.startsWith(CPP_Prefix))
				CPPhoneIds.put(CPId, null);
		}

		if (!CPPhoneIds.isEmpty())
		{
			// run query
			for (ContactPointPhone cpp: [SELECT Id, Name, TelephoneNumber FROM ContactPointPhone WHERE Id IN :CPPhoneIds.keySet()])
				CPPhoneIds.put(cpp.Id, cpp.TelephoneNumber);
		}

		if (!CPEmailIds.isEmpty())
		{
			// run query
			for (ContactPointEmail cpe: [SELECT Id, Name, EmailAddress FROM ContactPointEmail WHERE Id IN :CPEmailIds.keySet()])
				CPEmailIds.put(cpe.Id, cpe.EmailAddress);
		}

		for (ContactPointConsent CPC: newCPCs)
		{
			if (CPC.ContactPointId == null) continue;

			String CPId = CPC.ContactPointId; // cheating here, Id into String type

			if (CPId.startsWith(CPE_Prefix) && CPEmailIds.containsKey(CPId))
				CPC.Contact_Point__c = CPEmailIds.get(CPId);

			if (CPId.startsWith(CPP_Prefix) && CPPhoneIds.containsKey(CPId))
				CPC.Contact_Point__c = CPPhoneIds.get(CPId);
		}

	}

	private static void updateSetCPName(List<ContactPointConsent> newCPCs)
	{
		List<ContactPointConsent> CPCs = new List<ContactPointConsent>();

		for (ContactPointConsent CPC: newCPCs)
		{
			String CPCId = CPC.Id;
			if (CPC.Name == null || CPC.Name == CPCId)
				CPCs.add(CPC);
		}

		if (!CPCs.isEmpty()) setCPName(CPCs);
	}

	private static void setCPName(List<ContactPointConsent> newCPCs)
	{
		Map<Id, String> Purposes = new Map<Id, String>();
		Map<Id, String> Channels = new Map<Id, String>();

		for (ContactPointConsent CPC: newCPCs)
		{
			if (CPC.DataUsePurposeId == null && CPC.EngagementChannelTypeId == null) CPC.Name = 'CPConsent Record';

			if (CPC.DataUsePurposeId != null)        Purposes.put(CPC.DataUsePurposeId, null);
			if (CPC.EngagementChannelTypeId != null) Channels.put(CPC.EngagementChannelTypeId, null);
		}

		if (!Purposes.isEmpty())
		{
			// run query
			for (DataUsePurpose dup: [SELECT Id, Name FROM DataUsePurpose WHERE Id IN :Purposes.keySet()])
				Purposes.put(dup.Id, dup.Name);
		}

		if (!Channels.isEmpty())
		{
			// run query
			for (EngagementChannelType chan: [SELECT Id, Name FROM EngagementChannelType WHERE Id IN :Channels.keySet()])
				Channels.put(chan.Id, chan.Name);
		}

		for (ContactPointConsent CPC: newCPCs)
		{
			if (CPC.DataUsePurposeId == null && CPC.EngagementChannelTypeId == null) continue;

			String newName = '';

			if (CPC.DataUsePurposeId != null && Purposes.containsKey(CPC.DataUsePurposeId))
				newName += Purposes.get(CPC.DataUsePurposeId);

			if (CPC.EngagementChannelTypeId != null && Channels.containsKey(CPC.EngagementChannelTypeId))
			{
				if (newName != '') newName += '-';
				newName += Channels.get(CPC.EngagementChannelTypeId);
			}

			CPC.Name = newName;
		}

	}

	private static void setOptedOutCheckbox(List<ContactPointConsent> newCPCs, Map<Id, ContactPointConsent> oldCPCsMap) {
		// Catch to stop trigger re-running (isSetOptedOutCheckbox)
		if (isSetOptedOutCheckbox) return;
		isSetOptedOutCheckbox = true;

		for (ContactPointConsent cpc: newCPCs) {

			if (cpc.DataUsePurposeName__c != Outage_IncidentProcessor.DATAUSE_OUTAGES || cpc.Status__c != Outage_IncidentProcessor.CPC_STS_INACTIVE) continue;
			ContactPointConsent oldCPC = oldCPCsMap.get(cpc.Id);

			if (oldCPC != null && oldCPC.Status__c == Outage_IncidentProcessor.CPC_STS_ACTIVE) {
				cpc.Opted_Out__c = true;
			}
		}
	}

	private static void handleOptedOutCheckboxes(List<ContactPointConsent> newCPCs)
	{
		if (isSetOptedOutCheckbox) return;
		Map<Id, Set<String>> contactToConPointSetMap = new Map<Id, Set<String>>();

		for (ContactPointConsent newCPC: newCPCs) 
		{
			if (newCPC.DataUsePurposeName__c != Outage_IncidentProcessor.DATAUSE_OUTAGES || 
				newCPC.Status__c != Outage_IncidentProcessor.CPC_STS_ACTIVE) 
				continue;

			if (!contactToConPointSetMap.containsKey(newCPC.Contact__c)) 
				contactToConPointSetMap.put(newCPC.Contact__c, new Set<String>());

			contactToConPointSetMap.get(newCPC.Contact__c).add(newCPC.Contact_Point__c);
		}

		if (!contactToConPointSetMap.isEmpty())
		{
			updateOptedOutCheckboxes(contactToConPointSetMap);
		}
	}

	private static void updateOptedOutCheckboxes(Map<Id, Set<String>> contactToConPointSetMap) 
	{
		List<ContactPointConsent> cpcListToUpdate = new List<ContactPointConsent>();

		for (ContactPointConsent cpc : [SELECT id, Contact__c, Contact_Point__c, Opted_Out__c
										FROM ContactPointConsent
										WHERE Opted_Out__c = true
										AND DataUsePurposeName__c = :Outage_IncidentProcessor.DATAUSE_OUTAGES
										AND Contact__c IN :contactToConPointSetMap.keySet()])
		{
			if (contactToConPointSetMap.get(cpc.Contact__c).contains(cpc.Contact_Point__c)) {
				cpc.Opted_Out__c = false;
				cpcListToUpdate.add(cpc);
			}
		}

		if (!cpcListToUpdate.isEmpty()) 
		{
			isSetOptedOutCheckbox = true;
			update cpcListToUpdate;
		}
	}
	
}