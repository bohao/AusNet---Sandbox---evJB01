// *****************************************************************
// ** Outage_ManualMessagingUtility
// ** Description : This Class will have methods to
// *1 Get MC_Templates
// *2 Get Recipient List
// *3 Translate Messages
// *4 Insert into Messaging Queue
// *****************************************************************

public with sharing class Outage_ManualMessagingUtility
{

	// *****************************************************************
	// ** Member vars
	public static List<String> MM_MERGE_LIST = new List<String>
	{
		'%%FirstName%%',
		'%%LastName%%',
		'%%IncidentNumber%%',
		'%%Street%%',
		'%%NMI%%',
		'%%ETR%%',
		'%%ETA%%'
	};

	public static List<recipientDtlsClass> recipientList {get;set;}
	static Map<String, SObject> msgQueueMap = new Map<String, SObject>();
	public static Map<String, Object> returnMap = new Map<String, Object>();

	public class recipientDtlsClass {
		Public String ContactId; // Input Field May be a merge field to show relates to
		Public String IncidentId; // Input Field May be a merge field to show relates to
		Public String CampaignId; // Input Field May be a merge field to show relates to
		Public String msgBody ; // Input Field For both SMS and Emails.
		Public String mode; //Input Field. Preview/Send
		Public String subject; //Input Field. for email only
		Public String ScheduledDateTime; // Input Field.
		Public String overrideCustPref; // Input Field
		Public String channel; //Input Field
		String ContactPointId;
		String ServiceAccountId; // The linked service account to contact/campaign members/affecvted customers.
		String ContactFirstName; // Merge field to show First name
		String ContactLastName; // Merge field to show last name
		String TelephoneNumber; // ContactPointPhone number
		String EmailAddress; // ContactPointEmail Address
		// Think of more and add here. Keep all strings only.

		String msgBodyTranslated; // Output field
		String EmailSubject; // Only for emails. Output field

		String IncidentNumber; // Output field
		String CustomerStreet;
		String CustomerAddress;
		String EstimatedRestorationDate;
		String EstimatedAssessmentDate;
		String AffectedCustomer;
		String ServicePoint;
		string nmi;
	}

	public recipientDtlsClass rec ;

	// *****************************************************************
	// ** Constructor
	public Outage_ManualMessagingUtility() {
		rec = new recipientDtlsClass();
	}

	// *****************************************************************
	// ** Main methods
	// *1 Get_MC_Templates
	// ** This method fetches Marketing Cloud Templates to be displayed on UI.
	// ** Returns a map having 2 elements, sms templates list and email templates list.

	@AuraEnabled(cacheable=true)
	public static Map<String,Map<String,List<String>>> getMMPickLists(){
		Map<String,Map<String,List<String>>> pickLst = new  Map<String,Map<String,List<String>>>();

		pickLst = get_MC_Templates();
		Map<String,List<String>> mergePL  = getMergeFieldPickList();
		pickLst.put('mergeFields', mergePL);

		return pickLst;
	}

	public static Map<String,Map<String,List<String>>> get_MC_Templates(){
		Map<String,Map<String,List<String>>> mcTmpls = new Map<String,Map<String,List<String>>>();
		List<SObject> mcTmplsList = new List<SObject>();
		Map<String,List<String>> smsTmpls = new Map<String,List<String>>();
		Map<String,List<String>> emailTmpls = new Map<String,List<String>>();
		MC_Template__c itrTemp = new MC_Template__c();
		List<String> messageContents = new List<String>();
		if(Test.isRunningTest()){
			mcTmplsList = [SELECT Message_Body__c, Name, Email_Subject__c, Channel__c  FROM MC_Template__c Limit 1];
		}
		else
			mcTmplsList = [SELECT Message_Body__c, Name, Email_Subject__c, Channel__c  FROM MC_Template__c];
		for(SObject itr : mcTmplsList){
			messageContents = new List<String>();
			itrTemp = (MC_Template__c)itr;
			messageContents.add(itrTemp.Message_Body__c);
			if(itrTemp.Email_Subject__c != ''){
				messageContents.add(itrTemp.Email_Subject__c);
			}
			if(itrTemp.Channel__c == 'SMS')
				smsTmpls.put(itrTemp.Name, messageContents);
			else if(itrTemp.Channel__c == 'Email')
				emailTmpls.put(itrTemp.Name, messageContents);

		}

		mcTmpls.put('sms', smsTmpls);
		mcTmpls.put('email', emailTmpls);
		return mcTmpls;
	}

	// *****************************************************************
	// ** Main methods
	// *2 Get_MM_RecipientList
	// ** This method fetches all recipients to whom the message has to be sent.
	// ** Returns a map having recipients details list.

	public static Integer get_MM_RecipientList(Id mmid, String objectName, String channel, String overrideCustPref){
		/*
			Select <<fieldlist>> from Contact where Id =: mmid
			Select <<fieldlist>> from CampaignMember where CampaignId = :mmid
			Select <<fieldlist>> from Affected_Customer__c where uom_Incident__c = :mmid
		*/
		recipientList = new List<recipientDtlsClass>();
		List<SObject> cpList = new List<SObject>();
		String query ;
		List<String> contactId = new List<String>();
		List<SObject> contactids = new List<SObject>();
		List<String> contactpointIds = new List<String>();
		// First get the ContactPointId from Consent Object.
		switch on objectName{
			when 'Contact' {
				// Only 1 contact.
				contactId.add('\''+mmid+'\'');
				contactids = [Select Id, AccountId, FirstName, LastName from Contact where Id=:mmid];
			}
			 when 'Campaign' {
				// Get the Contact Point Phone and Email as well here only?.
				// >=1 Contacts
				contactids = [Select Id, ContactId, CampaignId, Contact.AccountId, Contact.FirstName, Contact.LastName, uom_Estimated_Time_of_Restoration__c,Service_Point__r.vlocity_cmt__MarketIdentifier__c from CampaignMember where CampaignId =: mmid ];
				for(SObject cid: contactids){

					// contactids is the string list used for IN operation on next query.
					contactId.add('\''+(String)cid.get('ContactId')+'\'');
				}
			}
			when 'Incident' {
				// Get the Contact Point Phone and Email as well here only?.
				// >=1 Contacts
				contactids = [SELECT Id, uom_Contact__c, uom_Incident__c,uom_Affected_Market_Identifier__r.uom_Service_Point__c ,uom_Affected_Market_Identifier__r.Name, uom_Contact__r.AccountId, uom_Contact__r.FirstName, uom_Contact__r.LastName, uom_Customer_Street__c,uom_Estimated_restoration_date__c,uom_Estimated_assessment_date__c,uom_Incident__r.uom_Incident_Id__c 
							  FROM Affected_Customer__c 
							  WHERE uom_Incident__c =:mmid 
							  AND uom_Aff_NMI_Status__c = :Outage_IncidentProcessor.AFF_NMI_IN_PROG];

				for(SObject cid: contactids){

					// contactids is the string list used for IN operation on next query.
					contactId.add('\''+(String)cid.get('uom_Contact__c')+'\'');
				}
			}
			when else {
				// Error.
			}


		}
		//If no contact ids found
		if(contactId.size()==0){
			if(objectName=='Campaign'){
				returnMap.put('Error','Error: Cannot send message to this Campaign - no customers found.');
			}else{
				returnMap.put('Error','Error: Cannot send message to this Incident - no customers found.');
			}
			return 0;
		}

		List<SObject> cpIds = new List<SObject>();
		if(overrideCustPref == 'No'){
			// Get the ContactPointConsent Records for the contactIds.. when OVerride Custpmer PReference is No.
			// For OVerride Custpmer PReference as Yes, then consent record not to be checked. Pick the primary record
			// From ContactPointPhone or ContactPointEmail for the contact directly..

			query = 'Select ContactPointId,Contact__c from ContactPointConsent where Contact__c IN '+contactId+' and DataUsePurpose.Name = \'Outage Notifications\' AND Status__c=\'Active\'';


				cpIds = Database.query(query);


			// cpIds will be used later to merge details into 1 recipient list. here for bindvariable to execute query,
			// take only contactpointid only into string list
			for(SObject cpId : cpIds){
				contactpointIds.add((String)cpId.get('ContactPointId'));
			}
		}

		// Fetch contactpoint phone/email directly. where isPrimary is True.


		// For each contactpoint id, get TelephoneNumber. Also FirstName, LastName and an other details needed for merging.
		// The next query will give accurate number of messages to be sent. For that check IsPrimary, isActive, IsSmsCapable,
		switch on channel{
			when 'SMS' {
				if(overrideCustPref == 'No'){
					// just get the contactpointphone record linked. no need to check isPrimary and isSMSCapable.
					cpList  = [Select Id, TelephoneNumber,Contact__c from ContactPointPhone where Id IN :contactpointIds];
				}
				else{
				//  When override is Yes, directly get from contactpintphone object for the contactIds. this may return >1 record for each contact.
					query = 'Select Id, TelephoneNumber,Contact__c from ContactPointPhone where Contact__c IN '+ contactId+' and IsPrimary = true and isSmsCapable=true';
					System.debug(query);
					cpList = Database.query(query);
				}
			}
			when 'Email' {
				if(overrideCustPref == 'No'){
					// just get the contactpointemail record linked. no need to check isPrimary.
					cpList  = [Select Id, EmailAddress, Contact__c from ContactPointEmail where Id IN :contactpointIds];
				}
				else{
				   //  When override is Yes, directly get from contactpintemail object for the contactIds. this may return >1 record for each contact.
					query = 'Select Id, EmailAddress,Contact__c from ContactPointEmail where Contact__c IN '+ contactId+' and IsPrimary = true ';
					cpList = Database.query(query);
				}
			}
			when else {
				// Error.
			}
		}

		// Merge contactids, cpIds and cpList into one List.
		mergeListsToOne(objectName, contactids, cpIds, cpList, channel);

		return recipientList.size();
	}

	// *****************************************************************
	// ** Main methods
	// *3.1 translateMessagesForMM
	// ** This method translates recipients msg body to whom the message has to be sent.
	// ** Returns a map having recipients details depending on mde. If preview mode, just 1 rec else all recs.
	@AuraEnabled
	public static Map<String, Object> translateMessagesForMM(Object inputRecLWC){
		recipientDtlsClass inputRec = (recipientDtlsClass) JSON.deserialize(JSON.serializePretty(inputRecLWC), recipientDtlsClass.class);

		Id mmid ;
		String objectName;
		if(inputRec.ContactId != ''){
			mmid = inputRec.ContactId;
			objectName = 'Contact';
		}
		else if(inputRec.IncidentId != ''){
			mmid = inputRec.IncidentId;
			objectName = 'Incident';
		}
		else if(inputRec.CampaignId != ''){
			mmid = inputRec.CampaignId;
			objectName = 'Campaign';
		}

		String msgBodyTranslated;
		Message_Queue__c msgQueue = new Message_Queue__c();
		Integer size = get_MM_RecipientList(mmid, objectName,inputRec.channel,inputRec.overrideCustPref);
		if(size==0 && !returnMap.containsKey('Error')){
			// Its error. no messages can be sent.
			returnMap.put('Error', 'Error. No recipients to send '+inputRec.channel);
			return returnMap;
		}

			// tokenise and get the merge fields from message body.
			List<String> mergeFields = getMergeFields(inputRec.msgBody);
			// Check from which object and field the merge fields to be translated.
			List<String> mergeFieldsSub = (inputRec.channel == 'Email')?getMergeFields(inputRec.subject):null;


			// If recipients exist
			for(recipientDtlsClass recipient: recipientList){
				// Iterate through mergemap
				// If objectname == 'Contact', Get the details from ContactPhone : Phone
				msgBodyTranslated = getMergeMappings(mergeFields, recipient, inputRec.msgBody);
				recipient.msgBodyTranslated = msgBodyTranslated;
				if(inputRec.channel == 'Email')
					recipient.EmailSubject = getMergeMappings(mergeFieldsSub, recipient, inputRec.subject); // Only for emails.
				recipient.ScheduledDateTime = inputRec.ScheduledDateTime;
				// Add the message queue record to map.
				msgQueue = populateMessageQueueRecord(recipient, objectName, inputRec.mode);
				if(inputRec.mode=='Preview'){
					returnMap.put('previewRecipient', JSON.deserializeUntyped(JSON.serializePretty(recipient)));
					break; // Just one rec enough for preview.
				}

				msgQueueMap.put(recipient.ContactId, msgQueue);
			}

			// insert the message queue map
			if(inputRec.mode=='Send' || inputRec.mode=='Schedule'){
				insertIntoMessageQueue();
				if(objectName=='Campaign'){
					List<CampaignMember> updateCMLst = new List<CampaignMember>();

					Campaign cmp = new Campaign(Id=mmid, Status='Completed');
					update cmp;
					for(CampaignMember cmitr : [SELECT Id FROM CampaignMember WHERE CampaignId =: mmid]){
					   updateCMLst.add(new CampaignMember( Id =cmitr.Id,
														  Status = 'Sent'));
					}
					if(updateCMLst!=null){
						UPDATE updateCMLst;
					}
				}
			}

			returnMap.put('size', size);
		return returnMap;
	}



	// *****************************************************************
	// ** Main methods
	// *4 insertIntoMessageQueue
	// ** This method translates all recipients to whom the message has to be sent.
	// ** Returns a map having recipients details.
	public static void insertIntoMessageQueue(){


		if(!msgQueueMap.isEmpty())
		// Error Handling...
			insert msgQueueMap.values();


	}

	// *****************************************************************
	// ** Main methods
	// *5 getMergeFields
	// ** This method fetches the merge fields from the message body to be sent.
	// ** Returns a list of strings having merge fields details.
	public static List<String> getMergeFields(String msgBody){
		List<String> mergeFlds = new List<String>();
		String locMsgBody = msgBody.trim();
		Map<String,String> mergeFldsMap = new Map<String,String>();
		// Split with space as seperator to get words. Can there be any other seperator? check for possibilities
		// Words startingwith %, put into list.
		locMsgBody = locMsgBody.replaceAll('<p>', ' ');
		locMsgBody = locMsgBody.replaceAll('</p>', ' ');
		locMsgBody = locMsgBody.replaceAll('<br>', ' ');
		List<String> words = locMsgBody.split(' ');
		String mergefldstr ;
		for(String word : words){
			// Check if the word contains the merge field. it starts and ends with %%.
			if(word.contains('%%')){
				// If the word contains %%, then check if it starts with %%.
				if(word.startsWith('%%')){
					// Also check if it ends with %. Otherwise, a different seperator like comma might be present.
					if(word.endsWith('%%')){
						mergefldstr = word;
					}
					else{
						// Starts with % but doesnt end. What to do? Take those chars untill %%.
						mergefldstr = word.left(word.lastIndexOf('%')+1);
					}
				}
				else{
					// Doesn't Start with %% but ends with %%
					if(word.endsWith('%%')){
						// Subsctring from % till end
						mergefldstr = word.substring(word.indexOf('%'));
					}
					else{
						// Doesn't Start with %% doesn't end with %%. Take those chars starting from %% untill %%.
						mergefldstr = word.substring(word.indexOf('%'), word.lastIndexOf('%')+1);
					}
				}

				// Check if the mergefield is really a mergefield or just %%....
				String locStr = mergefldstr.replaceAll('%%','');
				if(locStr.length() >0)
					mergeFldsMap.put(mergefldstr,mergefldstr);
			}

		}
		return mergeFldsMap.values();

	}

	// *****************************************************************
	// ** Main methods
	// *6 getMergeMappings
	// ** This method fetches the object name and fields from where actual values are to be fetched
	// ** for merge fields .
	// ** Returns a map of values to map the merge fields .

	public static String getMergeMappings(List<String> mergeFields, recipientDtlsClass recipient, String msgBody){

	   String msgBodyTranslated = msgBody;
	   String locfld;
		for(String field: mergeFields){
			locfld = field.substring(2,field.length()-2);

				if(locfld.equalsIgnoreCase('FirstName')){
					msgBodyTranslated = (recipient.ContactFirstName!=null)?msgBodyTranslated.replaceAll(field,recipient.ContactFirstName):msgBodyTranslated.replaceAll(field,'');
				}else if(locfld.equalsIgnoreCase('LastName')){
					msgBodyTranslated = (recipient.ContactLastName != null ) ?msgBodyTranslated.replaceAll(field,recipient.ContactLastName):msgBodyTranslated.replaceAll(field,'');
				}else if(locfld.equalsIgnoreCase('IncidentNumber')){ // %%Affected_Customer__c:uom_Incident__r:IncidentNumber%%
					msgBodyTranslated = (String.isNotBlank(recipient.IncidentNumber))?msgBodyTranslated.replaceAll(field,recipient.IncidentNumber):msgBodyTranslated.replaceAll(field,'');
				}else if(locfld.equalsIgnoreCase('Street')){ // %%Affected_Customer__c:uom_Customer_Street__c%%
					msgBodyTranslated = (recipient.CustomerStreet!=null)?msgBodyTranslated.replaceAll(field,recipient.CustomerStreet):msgBodyTranslated.replaceAll(field,'');
				}else if(locfld.equalsIgnoreCase('ETR')){
					msgBodyTranslated = (recipient.EstimatedRestorationDate!=null)?msgBodyTranslated.replaceAll(field,recipient.EstimatedRestorationDate):msgBodyTranslated.replaceAll(field,'');
				}else if(locfld.equalsIgnoreCase('ETA')){
					msgBodyTranslated = (recipient.EstimatedAssessmentDate!=null)?msgBodyTranslated.replaceAll(field,recipient.EstimatedAssessmentDate):msgBodyTranslated.replaceAll(field,'');
				}else if(locfld.equalsIgnoreCase('NMI')){
					msgBodyTranslated = (recipient.nmi!=null)?msgBodyTranslated.replaceAll(field,recipient.nmi):msgBodyTranslated.replaceAll(field,'');
				}else{
					msgBodyTranslated = msgBodyTranslated.replaceAll(field,'');
				}

			}
		return msgBodyTranslated;
	}

	// *****************************************************************
	// ** Main methods
	// *7 populateMessageQueueRecord
	// ** This method populates the MessageQueue record details
	// **
	// ** Returns nothing .
	public static Message_Queue__c populateMessageQueueRecord(recipientDtlsClass recipient, String objectName , String mode){
		// Populate the MEssageQueue record and return.
		Message_Queue__c msgQueue = new Message_Queue__c();
				msgQueue.Channel__c = recipient.channel;
				msgQueue.Contact__c = recipient.ContactId;
				msgQueue.Email_Address__c = recipient.EmailAddress;
				msgQueue.Email_Subject__c = recipient.EmailSubject;
				msgQueue.Message_Body_RTF__c = recipient.msgBodyTranslated;
			   // msgQueue.OwnerId = '';
				msgQueue.SMS_Phone__c = recipient.TelephoneNumber;
				msgQueue.Affected_Customer__c = recipient.AffectedCustomer;
				msgQueue.Incident__c = recipient.IncidentId;
				msgQueue.Service_Point__c = recipient.ServicePoint;

				if(mode=='Schedule'){
					// Populate schedule related fields.
					msgQueue.Status__c = 'Pending';
					DateTime dt = (Datetime) JSON.deserialize('"'+recipient.ScheduledDateTime+'"',Datetime.class); // Needs formatted String converted to Date?
  					msgQueue.Scheduled_Date__c = DateTime.newInstance(dt.date(), dt.time());
				}
				else{
					msgQueue.Status__c = 'Ready To Send';
				}
		return msgQueue;

	}

// *****************************************************************
	// ** Main methods
	// *8 mergeListsToOne
	// ** This method will merge 3 lists having diffrent data, but needed for translation
	// ** into 1 list..
	// ** Returns a list of values with recipient details .
	public static void mergeListsToOne(String objectName, List<SObject> contactids,List<SObject>  cpIds,List<SObject>  cpList, String channel){
		 // cpList has contactpoint id, telephone number, email address.
		 // cpIds has contactpoint id and service account id.
		 // contactids has firstname, lastname, contact id, service account id.
		 Map<String, recipientDtlsClass> resultMap = new Map<String, recipientDtlsClass>();
		 recipientDtlsClass locRec = new recipientDtlsClass();


		 // Make cpList a map.
		 for(SObject cprec:cpList){
			locRec = new recipientDtlsClass();
		 	locRec.channel = channel;
			locrec.ContactPointId = (String)cprec.get('Id') ; //Contact point id.
			locRec.ContactId = (String)cprec.get('Contact__c');
			if(channel=='SMS')
				locrec.TelephoneNumber=(String)cprec.get('TelephoneNumber'); // Telephone number
			else
				locrec.EmailAddress= (String)cprec.get('EmailAddress') ; // Email Address.
			resultMap.put(locRec.ContactId,locrec);
		}
		if(cpList.size()==0){
			System.debug('Error :: ContactPoint record for the channel '+ channel + ' is not present');

		 }
		 else {
			// First merge cpMap and cpIds based on contactpointid.
			// resultMap will have contactpointid, service account id, telephone number, email address.
		/*    for(SObject cpId : cpIds){
				Id cpIdOnConsent = (Id)cpId.get('Contact__c');
				If((cpIdOnConsent.getSObjectType().getDescribe().getName() == 'ContactPointPhone' && channel=='SMS')
				  || (cpIdOnConsent.getSObjectType().getDescribe().getName() == 'ContactPointEmail' && channel=='Email')){


					locRec = new recipientDtlsClass();
					locRec = (recipientDtlsClass)resultMap.get((String)cpId.get('ContactPointId'));
					locRec.ContactId = (String)cpId.get('Contact__c');
					// Remove the entry with contactpointid as key string.
					resultMap.remove((String)cpId.get('Contact__c'));
					// Add the one with ContactId as key string.
					resultMap.put(locRec.ContactId,locRec);
				}
			}
			*/
			// Next merge resultmap with contactids based on service account.
			// Now result map will have contactpointid, service account id, contact id, telephone number, email address, firstname, lastname
			for(SObject conId : contactids){
				locRec = new recipientDtlsClass();
				switch on objectName{
					when 'Contact' {
						locRec = (recipientDtlsClass)resultMap.get((String)conId.get('Id'));
						if(locRec!=null){
							locRec.ContactFirstName =(String)conId.get('FirstName');
							locRec.ContactLastName = (String)conId.get('LastName');
						}
					}
					when 'Campaign' {
						locRec = (recipientDtlsClass)resultMap.get((String)conId.get('ContactId'));
						if(locRec!=null){
							locRec.CampaignId = (String)conId.get('CampaignId');
							locRec.ContactFirstName =(String)conId.getSobject('Contact').get('FirstName');
							locRec.ContactLastName =(String)conId.getSobject('Contact').get('LastName');
							locRec.ServiceAccountId =(String)conId.getSobject('Contact').get('AccountId');
							//locRec.EstimatedRestorationDate = String.valueOf((DateTime)conId.get('uom_Estimated_Time_of_Restoration__c'));
							locRec.nmi = (string) conId.getSobject('Service_Point__r').get('vlocity_cmt__MarketIdentifier__c');
						}
					}
					when 'Incident' {
						locRec = (recipientDtlsClass)resultMap.get((String)conId.get('uom_Contact__c'));
						if(locRec!=null){
							locRec.IncidentNumber = (String)conId.getSobject('uom_Incident__r').get('uom_Incident_Id__c');
							locRec.AffectedCustomer = (String)conId.get('Id');
							locRec.IncidentId = (String)conId.get('uom_Incident__c');
							locRec.ServicePoint = (String)conId.getSObject('uom_Affected_Market_Identifier__r').get('uom_Service_Point__c');
							locRec.CustomerStreet = (String)conId.get('uom_Customer_Street__c');
							locRec.ServiceAccountId =(String)conId.getSobject('uom_Contact__r').get('AccountId');
							locRec.ContactFirstName =(String)conId.getSobject('uom_Contact__r').get('FirstName');
							locRec.ContactLastName =(String)conId.getSobject('uom_Contact__r').get('LastName');
							locRec.EstimatedAssessmentDate = String.valueOf((DateTime)conId.get('uom_Estimated_assessment_date__c'));
							locRec.EstimatedRestorationDate = String.valueOf((DateTime)conId.get('uom_Estimated_restoration_date__c'));
							locRec.nmi = (string)conId.getSobject('uom_Affected_Market_Identifier__r').get('Name');
						}
					}
				}
				if(locRec!=null){
					resultMap.remove(locRec.ContactId);
					resultMap.put(locRec.ContactId, locRec);
				}
			}

			recipientList = (List<recipientDtlsClass>)resultMap.values();
		 }
	}

	// *****************************************************************
	// ** Main methods
	// *9 getMergeFieldPickList
	// ** This method populates merge field list to be displayed on UI.
	// ** Returns a map having merge fields list.

	public static Map<String,List<String>> getMergeFieldPickList()
	{
		Map<String,List<String>> mergeFieldsMap = new Map<String,List<String>>();

		mergeFieldsMap.put('mergeFields', MM_MERGE_LIST);
		return mergeFieldsMap;
	}

	// *****************************************************************
	// ** Main methods
	// *10refresh_MC_Templates
	// ** This method fetches Marketing Cloud Templates to be displayed on UI.
	// ** Returns a map having 3 elements, refresh status, sms templates list and email templates list.

	@AuraEnabled(cacheable=false)
	public static Map<String,Map<String,List<String>>> refreshMCTemplates(){
		Map<String,Map<String,List<String>>> mcTmpls = new Map<String,Map<String,List<String>>>();
		Map<String,List<String>> results = new Map<String,List<String>>();
		String result = 'OK';
		List<String> strLst = new List<String>();
		if(!Test.isRunningTest()){
		   result = MC_Client.cacheAllTemplates();
		}
		strLst.add(result);
		results.put('refreshStatus',strLst);
		// If one of them also succeeded, populate the picklist with latest values.
		if(result == 'OK'){
			mcTmpls = get_MC_Templates();
		}
		mcTmpls.put('refresh',results);
		// mcTmpls will have 'refresh', 'sms', 'email' maps in the return.
		return mcTmpls;
	}

	// *****************************************************************
	// ** Main methods
	// *11getContactPreference
	// ** This method populates contact preference to be displayed on UI.
	// ** Also use to get contact number/email while sending message
	// ** Returns a String SMS or Email or SMS+Email.
	@AuraEnabled
	public static String getContactPreference(String contactId){
		String contactPref = '';
		// UI will invoke this method only for Contact record.
		// Get the ContactPointConsent record/s for the contact Id where status is Active and Data Purpose is Outage Notifications.
		List<Sobject> consents = [Select ContactPointId,Contact__c from ContactPointConsent where Contact__c =:contactId and DataUsePurpose.Name = 'Outage Notifications' AND Status__c='Active'];
		// Get the ContactPointPhone/ContactPointEmail records for these consent records where isPrimary is true
		for(SObject consent : consents){
			// For each consent record, get the ContactPointId and check is SObjectType
			Id cpId = (Id)consent.get('ContactPointId') ;
			String objType = cpId.getSObjectType().getDescribe().getName();
			If(objType == 'ContactPointPhone'){
				// If ContactPointPhone has a record, contactPref = SMS
				contactPref=(ContactPref=='Email') ? Outage_IncidentProcessor.CHANNEL_SMS_EMAIL:Outage_IncidentProcessor.CHANNEL_SMS;
			}

			// If ContactPointEmail has a record, and contactPref = SMS, contactPRef = SMS+Email
			If(objType == 'ContactPointEmail'){
				// If ContactPointPhone has a record, contactPref = SMS
				// If ContactPointEmail has a record, and contactPref = '', contactPRef = Email
				contactPref=(ContactPref=='SMS') ? Outage_IncidentProcessor.CHANNEL_SMS_EMAIL:Outage_IncidentProcessor.CHANNEL_EMAIL;
			}

		}
		// Return contactPref
		return contactPref;
	}

}