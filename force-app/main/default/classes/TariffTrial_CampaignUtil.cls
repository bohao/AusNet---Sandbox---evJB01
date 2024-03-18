public with sharing class TariffTrial_CampaignUtil {

    public static void createOrUpdateCampaigns(List<Tariff_Trial__c> tariffTrials) {
        Map<String, Campaign> eventToCampaignMap = new Map<String, Campaign>();
        List<CampaignMember> newCampaignMembers = new List<CampaignMember>();
        Set<String> nmis = new Set<String>();
        Set<String> eventIds = new Set<String>();

        // Step 1: Build set of NMIs for querying matching accounts
        // Build event ID to Campaign mapping
        for (Tariff_Trial__c tariffTrial : tariffTrials) {
            nmis.add(tariffTrial.NMI__c);
            eventIds.add(tariffTrial.Event_Id__c);
        }

        // Step 2: Query matching accounts based on NMIs
        // TODO: need to extend query conditions
        // Note: there is a risk if the account doesn't have a contact
        Map<String, Account> nmiToAccountMap = new Map<String, Account>();
        for (Account acc : [SELECT Id, vlocity_cmt__PrimaryContactId__c, Market_Identifier__r.vlocity_cmt__MarketIdentifier__c
                            FROM Account 
                            WHERE Market_Identifier__r.vlocity_cmt__MarketIdentifier__c IN :nmis]) {
            nmiToAccountMap.put(acc.Market_Identifier__r.vlocity_cmt__MarketIdentifier__c, acc);
        }


        // Step 3: Query matching Campaigns
        for(Campaign campaign : [SELECT Id, Name, Event_Id__c 
                                 FROM Campaign 
                                 WHERE Event_Id__c IN :eventIds 
                                 AND RecordType.DeveloperName = 'Tariff_Trial_Event']) {
            eventToCampaignMap.put(campaign.Event_Id__c, campaign);
        }
        
        // Step 2: Create new Campaigns
        for(Tariff_Trial__c tariffTrial : tariffTrials) {
            if(!eventToCampaignMap.containsKey(tariffTrial.Event_Id__c)) {
                Campaign campaign = new Campaign();
                campaign.Name = tariffTrial.Campaign_Name__c;
                campaign.Event_Id__c = tariffTrial.Event_Id__c;
                campaign.IsActive = true;
                campaign.Start_Date_Time__c = tariffTrial.Start_DateTime__c;
                campaign.Duration__c = tariffTrial.Duration__c;
                campaign.RecordTypeId = Schema.SObjectType.Campaign.RecordTypeInfosByDeveloperName.get('Tariff_Trial_Event').RecordTypeId;
                // newCampaigns.add(campaign);
                eventToCampaignMap.put(tariffTrial.Event_Id__c, campaign);
            }
            else {
                Campaign campaign = eventToCampaignMap.get(tariffTrial.Event_Id__c);
                campaign.Name = tariffTrial.Campaign_Name__c;
                campaign.Start_Date_Time__c = tariffTrial.Start_DateTime__c;
                campaign.Duration__c = tariffTrial.Duration__c;
                eventToCampaignMap.put(tariffTrial.Event_Id__c, campaign);
            }
        }
        
        // Step 3: Insert new Campaigns and retrieve Campaign Ids
        if(!eventToCampaignMap.isEmpty()) {
            upsert eventToCampaignMap.values() Event_Id__c;
        }
        
        // Step 4: Create or update Campaign Members
        for(Tariff_Trial__c tariffTrial : tariffTrials) {
            Campaign campaign = eventToCampaignMap.get(tariffTrial.Event_Id__c);
            
            String participantId = tariffTrial.Event_Id__c + '-' + tariffTrial.NMI__c;
            
            Account matchingAccount = nmiToAccountMap.get(tariffTrial.NMI__c);
            if (matchingAccount != null) {
                CampaignMember newMember = new CampaignMember(
                    CampaignId = campaign.Id,
                    Participant_Id__c = participantId,
                    ContactId = matchingAccount.vlocity_cmt__PrimaryContactId__c, 
                    First_Name__c = tariffTrial.Participant_First_Name__c, 
                    Last_Name__c = tariffTrial.Participant_Last_Name__c,
                    Retailer_Id__c = tariffTrial.Retailer_Id__c,
                    Mobile_Phone__c = tariffTrial.Mobile__c,
                    Email__c = tariffTrial.Email__c,
                    NMI__c = tariffTrial.NMI__c,
                    Account__c = matchingAccount.Id,
                    Service_Point__c = matchingAccount.Market_Identifier__c,
                    Baseline__c = tariffTrial.Baseline__c,
                    Performance__c = tariffTrial.Performance__c
                );
                newCampaignMembers.add(newMember);
            }
        }
        
        // Step 5: Insert new Campaign Members
        if(!newCampaignMembers.isEmpty()) {
            upsert newCampaignMembers Participant_Id__c;
        }
    }    
}