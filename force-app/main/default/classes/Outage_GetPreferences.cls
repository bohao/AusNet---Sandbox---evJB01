public with sharing class Outage_GetPreferences
{
	public static Set<String> Channels = new Set<String>
	{
		Outage_IncidentProcessor.CHANNEL_SMS,
		Outage_IncidentProcessor.CHANNEL_EMAIL
	};

	public static List<Preference> getCustomerPreference(List<Preference> Prefs, String DataUsePurpose)
	{
		if (DataUsePurpose == null)
		{
			System.debug('Error: DataUsePurpose is null.');
			return null;
		}

		if (Prefs == null || Prefs.isEmpty())
			return Prefs;

		// put into map
		Map<String, Preference> ContactPrefMap = new Map<String, Preference>();
		Set<Id> ContactIds = new Set<Id>();
		for (Preference p: Prefs)
		{
			if (p.ContactId == null)
			{
				System.debug('Error: Contact Id is null.');
				continue;
			}

			String key = p.getKey();
			p.Active = false;

			ContactPrefMap.put(key, p);
			ContactIds.add(p.ContactId);
		}


		// get Consent query
		for (ContactPointConsent CPC: [SELECT Id, Name, Contact__c, ContactPointId, DataUsePurpose.Name, EngagementChannelType.Name,
									   Status__c,
									   TYPEOF ContactPoint WHEN ContactPointPhone THEN IsPrimary,TelephoneNumber,PhoneType,IsSmsCapable END,
									   TYPEOF ContactPoint WHEN ContactPointEmail THEN IsPrimary,EmailAddress END
									   FROM ContactPointConsent
									   WHERE Contact__c IN :ContactIds
									   AND DataUsePurpose.Name = :DataUsePurpose
									   AND EngagementChannelType.Name IN :Channels
									   AND Status__c = 'Active'])
		{
			String key = CPC.Contact__c;
			Preference ConPref = ContactPrefMap.get(key);

			// Set email or phone num
			if (CPC.ContactPoint instanceOf ContactPointPhone)
			{
				// Check is this a mobile?
				ContactPointPhone CPPhone = (ContactPointPhone)CPC.ContactPoint;
				ConPref.PhoneNum = CPPhone.TelephoneNumber;
			}
			else if (CPC.ContactPoint instanceOf ContactPointEmail)
			{
				ContactPointEmail CPEmail = (ContactPointEmail)CPC.ContactPoint;
				ConPref.Email = CPEmail.EmailAddress;
			}

			ConPref.DataUsePurpose = DataUsePurpose;
			ConPref.Active = true;
			ConPref.Channel = CPC.EngagementChannelType.Name;

			// If both fields are populated, then set channel as both
			if (ConPref.PhoneNum != null && ConPref.Email != null)
				ConPref.Channel = Outage_IncidentProcessor.CHANNEL_SMS_EMAIL;
		}

		return ContactPrefMap.values();
	}



	public static Map<String, Preference> toMap(List<Preference> Prefs)
	{
		if (Prefs == null) return null;
		Map<String, Preference> mapPrefs = new Map<String, Preference>();

		for (Preference p: Prefs)
		{
			mapPrefs.put(p.getKey(), p);
		}

		return mapPrefs;
	}




	public class Preference
	{
		public Id ContactId;
		public String NMI;
		public String DataUsePurpose;

		public Boolean Active = false;
		public String Channel;
		public String Email;
		public String PhoneNum;

		public String getKey()
		{
			return ContactId;
		}
	}
}