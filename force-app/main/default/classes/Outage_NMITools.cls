public with sharing class Outage_NMITools
{
	public static String SEGMENT_CAMPAIGN_REC_TYPE = 'Segment_Message';
	public static String CMPGN_MEM_STATUS          = 'Loaded';

	public static String getNMI11(String nmiNum10) // System.debug(Outage_NMITools.getNMI11('6305000386'));
	{
		if (nmiNum10 == null || nmiNum10.length() != 10) return nmiNum10;

		Integer v = 0;
		Boolean multiply = true;

		for (Integer i = nmiNum10.length(); i > 0; i--)
		{
			Integer d = (Integer) nmiNum10.charAt(i - 1);

			if (multiply) {
				d *= 2;
			}

			multiply = !multiply;
			while (d > 0) {
				v += Math.mod(d, 10);
				d /= 10;
			}
		}
		Integer checksum = Math.mod((10 - (Math.mod(v, 10))), 10);

		return nmiNum10 + checksum;
	}

	// This method will 
	//		Take the Segment Loader record
	//		and match/generate a Campaign for it (based on Campaign Name field)
	//		and match a Campaign member for it (based on NMI field)
	public static void SL_CreateCampaigns(List<Segment_Loader__c> SLs)
	{
		// Iterate SLs
		// Find the campaign for them
		// create campaign if required
		Map<String, List<SegmentMember>> CampaignSegmentMembers = new Map<String, List<SegmentMember>>();
		Set<String> NMIs = new Set<String>();

		for (Segment_Loader__c SegLdr: SLs)
		{
			String campaignName = SegLdr.Campaign_Name__c;
			String nmi = SegLdr.NMI__c;

			if (!CampaignSegmentMembers.containsKey(campaignName))
				CampaignSegmentMembers.put(campaignName, new List<SegmentMember>());

			SegmentMember sm = new SegmentMember();
			sm.nmi = nmi;
			sm.campaign = campaignName;

			CampaignSegmentMembers.get(campaignName).add(sm);
			NMIs.add(nmi);
		}

		Map<String, Id> campaignMap = new Map<String, Id>();
		for (Campaign campaign: [SELECT Id, Name FROM Campaign
								 WHERE Name IN :CampaignSegmentMembers.keySet()
								 AND RecordType.DeveloperName = :SEGMENT_CAMPAIGN_REC_TYPE])
		{
			String campaignName = campaign.Name;
			campaignMap.put(campaignName, campaign.Id);

			for (SegmentMember SM: CampaignSegmentMembers.get(campaignName))
			{
				SM.campaignId = campaign.Id;
			}
		}

		// Find which SMs do not have a campaign - and create campaign on the fly
		List<Campaign> newCampaigns = new List<Campaign>();
		Id RTId = UtilDatabase.getRecordTypeNames('Campaign').get(SEGMENT_CAMPAIGN_REC_TYPE);

		for (String campaignName: CampaignSegmentMembers.keySet())
		{
			if (!campaignMap.containsKey(campaignName))
			{
				// create a campaign
				Campaign newCamp = new Campaign();
				newCamp.Name         = campaignName;
				newCamp.RecordTypeId = RTId;
				newCamp.IsActive     = true;

				newCampaigns.add(newCamp);
			}
		}

		if (!newCampaigns.isEmpty())
		{
			insert newCampaigns;

			List<CampaignMemberStatus> CMStatus = new List<CampaignMemberStatus>();

			for (Campaign newCamp: newCampaigns)
			{
				String campaignName = newCamp.Name;
				campaignMap.put(campaignName, newCamp.Id);

				for (SegmentMember SM: CampaignSegmentMembers.get(campaignName))
				{
					SM.campaign   = campaignName;
					SM.campaignId = newCamp.Id;
				}

				CampaignMemberStatus cms = new CampaignMemberStatus();
				cms.CampaignId           = newCamp.Id;
				cms.Label                = CMPGN_MEM_STATUS;
				cms.HasResponded         = false;
				cms.SortOrder            = 0;
				CMStatus.add(cms);
			}

			if (!CMStatus.isEmpty())
				insert CMStatus;

			newCampaigns.clear();
		}


		// find campaign's existing members
		Map<String, Set<Id>> campaignNameToContactIds = new Map<String, Set<Id>>();
		for (CampaignMember cmItr: [SELECT Id, Service_Point__r.vlocity_cmt__MarketIdentifier__c, ContactId, CampaignId, Campaign.Name
									FROM CampaignMember
									WHERE CampaignId IN :campaignMap.values()])
		{
			String campaignName = cmItr.Campaign.Name;

			if (!campaignNameToContactIds.containsKey(campaignName))
				campaignNameToContactIds.put(campaignName, new Set<Id>());

			campaignNameToContactIds.get(campaignName).add(cmItr.ContactId);
		}


		// Find the contact for them
		// Get NMI list
		// Run query
		Map<String, Account> NMIAccs = new Map<String, Account>();

		for (Account acc: [SELECT Id, Name, RecordType.Name,
							vlocity_cmt__PrimaryContactId__c, vlocity_cmt__PrimaryContactId__r.Name,
							vlocity_cmt__PrimaryContactId__r.Email, vlocity_cmt__PrimaryContactId__r.MobilePhone, vlocity_cmt__PrimaryContactId__r.Phone,
							vlocity_cmt__PrimaryContactId__r.CE_Email_Address__c, vlocity_cmt__PrimaryContactId__r.CE_Phone_Number__c,

							Market_Identifier__r.vlocity_cmt__MarketIdentifier__c,
							vlocity_cmt__PremisesId__c, vlocity_cmt__PremisesId__r.Name,
							Contact_Matched__c

							// (SELECT Id, ContactId, Contact.Name,
							// Contact.CE_Email_Address__c, Contact.CE_Phone_Number__c, toLabel(Roles)
							// FROM AccountContactRelations WHERE Roles = 'Secondary Contact')

							FROM Account
							WHERE Recordtype.Name = 'Service'
							AND Market_Identifier__r.vlocity_cmt__MarketIdentifier__c IN :NMIs
							AND Market_Identifier__r.vlocity_cmt__ServiceType__c = 'Electricity'
							AND Market_Identifier__r.dcp_NMIStatus_To_Date__c = null
							AND Market_Identifier__r.Data_Duplication__c = 'Original'
							AND Contact_Matched__c = 'Contact Found'])
		{
			String NMI = acc.Market_Identifier__r.vlocity_cmt__MarketIdentifier__c;
			NMIAccs.put(NMI, acc);
		}

		List<SegmentMember> allSMs = new List<SegmentMember>();
		for (List<SegmentMember> SMs: CampaignSegmentMembers.values())
			allSMs.addAll(SMs);

		for (SegmentMember SM: allSMs)
		{
			String NMI = SM.nmi;

			if (!NMIAccs.containsKey(NMI))
			{
				// not found
				continue;
			}

			Account nmiAcc = NMIAccs.get(NMI);

			// TODO: this only works with primary contact
			//			one NMI -> one con.
			//		One day, Ausnet may want secondary contacts,
			//		but not yet.

			SM.contactId      = nmiAcc.vlocity_cmt__PrimaryContactId__c;
			SM.accountId      = nmiAcc.Id;
			SM.nmi            = NMI;
			SM.servicePointId = nmiAcc.Market_Identifier__c;
		}

		// Find the con's prefs
		setCustomerPreferences(allSMs);

		// add to a campaign member
		List<CampaignMember> newCMs = new List<CampaignMember>();

		for (SegmentMember SM: allSMs)
		{
			if (SM.campaignId == null || SM.contactId == null)
			{
				// error
				continue;
			}

			String NMI = SM.nmi;
			String campaignName = SM.campaign;
			Id conId = SM.contactId;

			// check if already on campaign
			if (!campaignNameToContactIds.containsKey(campaignName))
				campaignNameToContactIds.put(campaignName, new Set<Id>());

			if (campaignNameToContactIds.get(campaignName).contains(conId))
			{
				// already there, skip
				continue;
			}

			// create CM
			CampaignMember newCM             = new CampaignMember();
			newCM.ContactId                  = conId;
			newCM.CampaignId                 = SM.campaignId;
			newCM.Status                     = CMPGN_MEM_STATUS;
			newCM.NMI__c                     = SM.nmi;
			newCM.Account__c                 = SM.accountId;
			newCM.Service_Point__c           = SM.servicePointId;

			newCM.Notification_Preference__c = SM.Notification_Preference;
			newCM.Customer_Email__c          = SM.Customer_Email;
			newCM.Customer_Phone__c          = SM.Customer_Phone;

			newCMs.add(newCM);

			campaignNameToContactIds.get(campaignName).add(conId);
		}

		if (!newCMs.isEmpty())
		{
			insert newCMs;
		}

		return;
	}

	public static void setCustomerPreferences(List<SegmentMember> SMs)
	{
		if (SMs == null || SMs.isEmpty())
			return;

		// Make preference request
		List<Outage_GetPreferences.Preference> Prefs = new List<Outage_GetPreferences.Preference>();

		for (SegmentMember SM: SMs)
		{
			if (SM.contactId == null)
				continue;

			Outage_GetPreferences.Preference Pref = new Outage_GetPreferences.Preference();
			Pref.ContactId = SM.contactId;
			Prefs.add(Pref);
		}

		if (Prefs.isEmpty())
		{
			// nothing to do
			return;
		}

		Map<String, Outage_GetPreferences.Preference> mapPrefs = Outage_GetPreferences.toMap(Outage_GetPreferences.getCustomerPreference(Prefs, Outage_IncidentProcessor.DATAUSE_OUTAGES));

		for (SegmentMember SM: SMs)
		{
			SM.Notification_Preference = null;
			SM.Customer_Email          = null;
			SM.Customer_Phone          = null;

			if (SM.contactId == null)
				continue;

			String key = SM.contactId;
			if (!mapPrefs.containsKey(key)) continue;

			Outage_GetPreferences.Preference Pref = mapPrefs.get(key);
			if (Pref.Active)
			{
				SM.Notification_Preference = Pref.Channel;
				SM.Customer_Email          = Pref.Email;
				SM.Customer_Phone          = Pref.PhoneNum;
			}
		}
	}

	//  class to store fields values to be mapped to CM records from NMI details
	public class SegmentMember
	{
		public Id contactId;
		public Id accountId;

		public String nmi;
		public Id servicePointId;

		public Id campaignId;
		public String campaign;

		public Id campaignMemberId;

		public String Notification_Preference;
		public String Customer_Email;
		public String Customer_Phone;
	}
}