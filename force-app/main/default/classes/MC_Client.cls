public with sharing class MC_Client
{
	private static Marketing_Cloud_Client__mdt mcc = Marketing_Cloud_Client__mdt.getInstance(getMCCSettings());

	private static String MC_ORG_NAME = mcc.MC_Org__c;

	{
		System.debug(MC_ORG_NAME);
	}

	private static String MC_SCHEMA = mcc.Schema__c;
	private static String MC_HOST_ID = mcc.Host_Id__c;
	private static String MC_HOST_DOMAIN = mcc.Host_Domain__c;
	private static String MC_COMMLOG_MASTER = mcc.Comm_Log_Master__c;

	private static String MC_AUTH_URL = mcc.Auth_Url__c;
	private static String MC_CLIENT_ID = mcc.Client_Id__c;
	private static String MC_CLIENT_SEC = mcc.Client_Sec__c;
	private static String MC_MID = mcc.Mid__c;

	private static String MC_QUERY_CATS_URL = mcc.Query_Cats_Url__c;
	private static String MC_QUERY_ASSETS_URL = mcc.Query_Assets_Url__c;
	private static String MC_QUERY_DE_URL = mcc.Query_De_Url__c;

	private static String MC_ACCESS_TOKEN;
	private static Boolean showToken = false;

	private static String MC_CATEGORY_NAME = 'Manual Messaging';
	private static String MC_EMAIL_CAT_NAME = 'Emails';
	private static String MC_SMS_CAT_NAME = 'SMS';

	private static Set<String> ValidChannels = new Set<String>{MC_EMAIL_CAT_NAME, MC_SMS_CAT_NAME};

	// *****************************************************************
	// ** Constructor
	public MC_Client()
	{

	}


	// *****************************************************************
	// ** Main methods
	private static String getMCCSettings()
	{
		Id OrgId     = UserInfo.getOrganizationId();

		Id ProdId    = UtilFieldCalcs.PROD_ORG_ID;
		Id PreProdId = '00D5P0000008aigUAA';

		Set<Id> ProdIds = new Set<Id>{ ProdId, PreProdId };

		// If Prod or PreProd
		if (ProdIds.contains(OrgId))
			return 'MC_Client_Prod';

		return 'MC_Client';
	}

	public static String cacheTemplates(String channel)
	{
		List<MC_Asset> mc_assets = queryTemplates(channel);
		String output = processTemplates(mc_assets);
		return output;
	}

	public static String cacheAllTemplates()
	{
		List<MC_Asset> mc_assets = new List<MC_Asset>();

		for (String channel: ValidChannels)
		{
			mc_assets.addAll(queryTemplates(channel));
		}

		String output = processTemplates(mc_assets);
		return output;
	}

	public static List<MC_Asset> queryTemplates(String channel)
	{
		if (channel == null)
		{
			// Error
			String errorMsg = 'Error: channel is null.';
			throw new MC_Exception(errorMsg);
		}
		if (!ValidChannels.contains(channel))
		{
			// Error
			String errorMsg = 'Error channel is invalid: ' + channel;
			throw new MC_Exception(errorMsg);
		}

		System.debug('channel: '+channel);

		// run MC get method
		List<MC_Asset> mc_assets;
		if (channel == MC_SMS_CAT_NAME)
		{
			mc_assets = getSMSTemplates();
		}
		else if (channel == MC_EMAIL_CAT_NAME)
		{
			mc_assets = getEmailTemplates();
		}

		if (mc_assets == null || mc_assets.isEmpty())
		{
			// Error
			String errorMsg = 'Error getting templates.';
			throw new MC_Exception(errorMsg);
		}
		if (mc_assets.get(0).isError)
		{
			// Error
			String errorMsg = 'Error getting templates.\n' + mc_assets.get(0).errorMsg;
			throw new MC_Exception(errorMsg);
		}

		return mc_assets;
	}

	public static String processTemplates(List<MC_Asset> mc_assets)
	{
		Set<String> channels = new Set<String>();

		for (MC_Asset mca: mc_assets)
		{
			// A bit of translate on the fly....
			if (mca.channel == MC_EMAIL_CAT_NAME)
				mca.channel = 'Email';

			channels.add(mca.channel);
		}

		// Flush MC template object?
		List<MC_Template__c> mc_tmpls = [SELECT Id, Channel__c FROM MC_Template__c WHERE Channel__c IN :channels];
		if (mc_tmpls != null && !mc_tmpls.isEmpty())
		{
			delete mc_tmpls;
		}

		mc_tmpls = new List<MC_Template__c>();

		// iterate and create records
		for (MC_Asset mca: mc_assets)
		{
			MC_Template__c mc_tmpl   = new MC_Template__c();
			mc_tmpl.Name             = mca.name;
			mc_tmpl.Channel__c       = mca.channel;
			mc_tmpl.MC_Id__c         = String.valueOf(mca.id);
			mc_tmpl.Message_Body__c  = mca.body;
			mc_tmpl.Email_Subject__c = mca.emailSubject;

			mc_tmpls.add(mc_tmpl);
		}

		insert mc_tmpls;
		return 'OK';
	}

	public static List<MC_Asset> getSMSTemplates() // MC_Client.getSMSTemplates();
	{
		List<MC_Asset> output = new List<MC_Asset>();

		// find the SMS cat
		String categoryId = getCategory(MC_SMS_CAT_NAME);
		if (categoryId == null || categoryId.startsWith('Error'))
		{
			// Error
			MC_Asset mca = new MC_Asset();
			mca.isError = true;
			mca.errorMsg = 'Cat Id error';
			mca.channel = MC_SMS_CAT_NAME;

			if (categoryId != null)
				mca.errorMsg += '\n' + categoryId;

			output.add(mca);

			return output;
		}

		System.debug('categoryId: '+categoryId);

		// find the assets with that cat Id
		output = queryAssets(Integer.valueOf(categoryId), MC_SMS_CAT_NAME);

		// for (MC_Asset mc_asset: output)
		// {
		// 	System.debug(mc_asset);
		// }

		return output;
	}

	public static List<MC_Asset> getEmailTemplates() // MC_Client.getEmailTemplates();
	{
		List<MC_Asset> output = new List<MC_Asset>();

		// find the SMS cat
		String categoryId = getCategory(MC_EMAIL_CAT_NAME);
		if (categoryId == null || categoryId.startsWith('Error'))
		{
			// Error
			MC_Asset mca = new MC_Asset();
			mca.isError = true;
			mca.errorMsg = 'Cat Id error';
			mca.channel = MC_EMAIL_CAT_NAME;

			if (categoryId != null)
				mca.errorMsg += '\n' + categoryId;

			output.add(mca);

			return output;
		}

		System.debug('categoryId: '+categoryId);

		// find the assets with that cat Id
		output = queryAssets(Integer.valueOf(categoryId), MC_EMAIL_CAT_NAME);

		// for (MC_Asset mc_asset: mc_assets)
		// {
		// 	System.debug(mc_asset);
		// }

		return output;
	}

	public static String getCategory(String catName)
	{
		// Authorise / get Token
		MCAuthToken();


		// Build URL
		String url = MC_SCHEMA + MC_HOST_ID + '.rest' + MC_HOST_DOMAIN + MC_QUERY_CATS_URL;

		url = url.replace(' ', '%20');
		// System.debug('URL: '+url);

		// Send to Rest web service
		Map<String, String> headers = new Map<String, String>{'Authorization' => 'Bearer ' + MC_ACCESS_TOKEN};
		HttpResponse response = JSONGetCall(url, headers);

		Integer ResCode = response.getStatusCode();
		// System.debug('response: ' + ResCode);
		// System.debug(response.getBody());


		// Process response
		if (ResCode != 200)
		{
			// Error
			return 'Error.';
		}

		// assume 200
		// process output
		Map<String, Object> queryResponseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		List<Object> categoryList = (List<Object>)queryResponseMap.get('items');

		List<MC_Category> categories = new List<MC_Category>();
		Integer ParentCatId;

		for (Object oCat: categoryList)
		{
			MC_Category cat = new MC_Category(oCat);
			categories.add(cat);

			// find me the parent category and grab the Id
			if (cat.name == MC_CATEGORY_NAME)
				ParentCatId = cat.id;
		}

		// System.debug('ParentCatId: '+ParentCatId);
		if (ParentCatId == null)
		{
			// Error
			return 'Error.';
		}

		// now, find me the category requested (which is a child of the parent Category above)
		String catId;

		for (MC_Category cat: categories)
		{
			// Find me folders with parentId == MM.Id
			if (cat.parentId == ParentCatId)
			{
				// System.debug('Found: ' +cat.name + ' [Id: '+cat.id+']');

				if (cat.name == catName)
					catId = String.valueOf(cat.id);
			}
		}

		if (catId == null)
		{
			// Error
			catId = 'Error: catId not found for requested category name.';
		}

		return catId;
	}

	public static List<MC_Asset> queryAssets(Integer categoryId, String catName) // MC_Client.queryAssets(69116);
	{
		// Authorise / get Token
		MCAuthToken();


		// Build URL
		String url = MC_SCHEMA + MC_HOST_ID + '.rest' + MC_HOST_DOMAIN + MC_QUERY_ASSETS_URL;
		// parameters
		url += '?$page=1';
		url += '&$pagesize=100';
		url += '&$orderBy=name asc';
		url += '&$filter=category.id eq ' + categoryId;

		url = url.replace(' ', '%20');
		// System.debug('URL: '+url);

		// Send to Rest web service
		Map<String, String> headers = new Map<String, String>{'Authorization' => 'Bearer ' + MC_ACCESS_TOKEN};
		HttpResponse response = JSONGetCall(url, headers);

		Integer ResCode = response.getStatusCode();
		// System.debug('response: ' + ResCode);
		// System.debug(response.getBody());

		if (ResCode != 200)
		{
			// Error
			String errorMsg = 'Error.';
			throw new MC_Exception(errorMsg);
		}

		// assume 200
		// process output
		Map<String, Object> queryResponseMap = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
		List<Object> assetList = (List<Object>)queryResponseMap.get('items');

		List<MC_Asset> mc_assets = new List<MC_Asset>();

		for (Object oAsset: assetList)
		{
			MC_Asset mc_asset = new MC_Asset(oAsset);
			mc_asset.channel = catName;
			mc_assets.add(mc_asset);

			// System.debug('Found: ' +mc_asset.name + ' [Id: '+mc_asset.id+']');
		}

		// query body
		for (MC_Asset mc_asset: mc_assets)
		{
			if (mc_asset.body != null)
				continue;

			String assetBody;

			if (catName == MC_SMS_CAT_NAME)
				assetBody = getAssetBodySMS(Integer.valueOf(mc_asset.id));
			else if (catName == MC_EMAIL_CAT_NAME)
				assetBody = getAssetBodyEmail(mc_asset);

			if (assetBody == null || assetBody.startsWith('Error'))
			{
				String errorMsg = 'Error: assetBody is null.';
				if (assetBody != null)
					errorMsg = 'Error: '+assetBody;

				// System.debug(JSON.serializePretty(mc_asset));
				throw new MC_Exception(errorMsg);
			}

			mc_asset.body = assetBody;
		}

		return mc_assets;
	}

	public static String getAssetBodySMS(Integer assetId) // MC_Client.getAssetBodySMS(115823);
	{
		String responseBody = queryAssetBody(assetId);

		// find value for key: availableViews
		Object obj = (Object)JSON.deserializeUntyped(responseBody);

		String view;
		{
			String k = 'availableViews';

			List<Object> availViews = (List<Object>)getObject(obj, k);
			// System.debug(availViews);

			if (availViews != null && !availViews.isEmpty())
				view = (String)availViews.get(0);
		}
		// System.debug(view);

		// find value for key: views.sMS.meta.options.customBlockData.display:message
		List<String> keys = new List<String>
		{
			'views',
			view,
			'meta',
			'options',
			'customBlockData',
			'display:message'
		};

		// Object obj = (Object)JSON.deserializeUntyped(responseBody);
		for (String k: keys)
		{
			Map<String, Object> objMap = (Map<String, Object>)obj;
			if (!objMap.containsKey(k))
			{
				// Error
				return 'Error: Key not found ['+k+'].';
			}

			// System.debug('Found: ' +k);
			obj = (Object)objMap.get(k);
		}

		// assume we have 'display:message' ??
		String body = (String)obj;
		// System.debug('body: ' +body);

		return body;
	}

	public static String getAssetBodyEmail(MC_Asset mc_asset)
	{
		if (mc_asset == null)
			return null;

		if (mc_asset.content != null)
		{
			// System.debug(JSON.serializePretty(mc_asset.content));
			return mc_asset.content;
		}

		String responseBody = queryAssetBody(mc_asset.id);
		// System.debug(responseBody);

		// Need to know:
		//		** Status draft? Keep or ditch?

		// JSON path
		// 	views.subjectline.content
		// 	views.html.slots.banner.blocks.[0].content

		// Make a JSON struct from the body
		Object obj = (Object)JSON.deserializeUntyped(responseBody);

		// Get Email subject
		List<String> keys = new List<String>{'views', 'subjectline', 'content'};
		String emailSubject = getJsonKey(obj, keys);
		mc_asset.emailSubject = emailSubject;
		System.debug('emailSubject: ' + emailSubject);

		// Get html content
		keys = new List<String>{'views', 'html', 'slots', 'banner', 'blocks', '*', 'content'};
		String emailBody = getJsonKey(obj, keys);
		System.debug('emailBody: ' + emailBody);

		return emailBody;
	}


	private static String queryAssetBody(Integer assetId)
	{
		// Authorise / get Token
		MCAuthToken();

		// Build URL
		String url = MC_SCHEMA + MC_HOST_ID + '.rest' + MC_HOST_DOMAIN + MC_QUERY_ASSETS_URL;
		url += '/' + assetId;

		url = url.replace(' ', '%20');
		// System.debug('URL: '+url);

		// Send to Rest web service
		Map<String, String> headers = new Map<String, String>{'Authorization' => 'Bearer ' + MC_ACCESS_TOKEN};
		HttpResponse response = JSONGetCall(url, headers);

		Integer ResCode = response.getStatusCode();
		// System.debug('response: ' + ResCode);
		// System.debug(response.getBody());

		if (ResCode != 200)
		{
			// Error
			// System.debug(JSON.serializePretty(response));
			return 'Error Non 200 code: ' + ResCode;
		}

		// assume 200
		// process output
		return response.getBody();
	}

	private static String getJsonKey(Object jsonObj, List<String> keyHierarchy)
	{
		String output;
		Object obj = jsonObj;

		for (String k: keyHierarchy)
		{
			Map<String, Object> objMap = (Map<String, Object>)obj;

			if (k == '*')
			{
				// just get first key?
				k = getFirst(objMap.keySet());
			}

			if (!objMap.containsKey(k))
			{
				// Error
				String errorMsg = 'Error: Key not found ['+k+'].';
				throw new MC_Exception(errorMsg);
			}

			// System.debug('Found: ' +k);
			obj = (Object)objMap.get(k);
		}

		return (String)obj;
	}


	// MC_Client.queryCommLog();
	public static String queryCommLog(String filterKey, String filterValue, String sortedBy, String sortDirection, Date startDate, Date endDate, Integer pageNumber, Integer recordsPerPage)
	{

		// Authorise / get Token
		MCAuthToken();

		// Build URL
		String url = MC_SCHEMA + MC_HOST_ID + '.rest' + MC_HOST_DOMAIN + MC_QUERY_DE_URL + '/' + MC_COMMLOG_MASTER + '/rowset';

		// url parameters
		url += '?$page=' + pageNumber;
		url += '&$pagesize=' + recordsPerPage;
		url += '&$orderBy=' + sortedBy + ' ' + sortDirection;
		url += '&$filter=' + filterKey + ' eq \'' + filterValue + '\'';

		if (startDate != null) {
			url += ' and sentdate gte \'' + String.valueOf(startDate) + '\'';
		}

		if (endDate != null) {
			endDate = endDate.addDays(1);
			url += ' and sentdate lt \'' + String.valueOf(endDate) + '\'';
		}

		url = url.replace(' ', '%20');

		// Send to Rest web service
		Map<String, String> headers = new Map<String, String>{'Authorization' => 'Bearer ' + MC_ACCESS_TOKEN};
		HttpResponse response = JSONGetCall(url, headers);

		Integer ResCode = response.getStatusCode();

		if (ResCode != 200) {
			// Error
			String errorMsg = 'Error.';
			throw new MC_Exception(errorMsg);
		}

		return response.getBody();
	}

	@AuraEnabled
	public static Object getCommLogData(String objectName, String recordId, String sortedBy, String sortDirection, Date startDate, Date endDate, Integer pageNumber, Integer recordsPerPage)
	{
		String filterKey = getCommLogFilterKey(objectName);
		String filterValue = recordId;

		if (filterKey == 'nmi') {
			vlocity_cmt__ServicePoint__c servicePoint = [SELECT Name FROM vlocity_cmt__ServicePoint__c WHERE Id = :recordId LIMIT 1];
			filterValue = servicePoint.Name;
		}

		String commLogQueryResults = queryCommLog(filterKey, filterValue, sortedBy, sortDirection, startDate, endDate, pageNumber, recordsPerPage);

		// Deserialize the JSON response
		Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(commLogQueryResults);

		// create inner maps for the final map
		Map<String, Object> commLogInfoMap = createCommLogInfoMap(responseMap);
		List<Object> itemsList = (List<Object>) responseMap.get('items');
		List<Map<String, Object>> commLogValuesMapList = createCommLogValuesMapList(itemsList);

		// create final map to return
		Map<String, Object> finalCommLogMap = new Map<String, Object>();
		finalCommLogMap.put('CommLogInfo', commLogInfoMap);
		finalCommLogMap.put('CommLogValues', commLogValuesMapList);
		return finalCommLogMap;
	}

	// *****************************************************************
	// ** Helper methods

	@testVisible
	private static String getCommLogFilterKey(String objectName)
	{
		String filterKey;

		switch on objectName {
			when 'Contact' {
				filterKey = 'subscriberkey';
			}
			when 'vlocity_cmt__ServicePoint__c' {
				filterKey = 'nmi';
			}
			when 'Incident' {
				filterKey = 'incidentid';
			}
			when 'Affected_Customer__c' {
				filterKey = 'affectedcustomerid';
			}
			when 'Affected_Market_Identifier__c' {
				filterKey = 'marketidentifier';
			}
		}

		return filterKey;
	}

	@testVisible
	private static Map<String, Object> createCommLogInfoMap (Map<String, Object> responseMap)
	{
		Map<String, Object> commLogInfoMap = new Map<String, Object>();

		Decimal recordCount = (Decimal) responseMap.get('count');
		Integer pageSize = (Integer) responseMap.get('pageSize');
		Integer totalPageCount =  Math.ceil(recordCount / pageSize).intValue();

		commLogInfoMap.put('totalPageCount', totalPageCount == 0 ? 1 : totalPageCount);
		commLogInfoMap.put('page', responseMap.get('page'));
		commLogInfoMap.put('count', recordCount);

		return commLogInfoMap;
	}

	@testVisible
	private static List<Map<String, Object>> createCommLogValuesMapList (List<Object> itemsList)
	{
		final List<String> validationKeyList = new List<String>{'incidentid', 'nmi', 'messagename', 'communicationtype', 'messagestatus','lifesupportcustomer', 'sentdate', 'email', 'mobile', 'messagetext' };
		final String baseRecordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
		List<Map<String, Object>> commLogValuesMapList = new List<Map<String, Object>>();
		Set<Id> contactIds = new Set<Id>();
		Set<Id> incidentIds = new Set<Id>();
		Set<String> nmiIdentifiers = new Set<String>();
		if (itemsList != null) {
			// Loop through each item and access the 'keys' and "values" map
			for (Object item : itemsList) {
				String subscriberKey = (String) ((Map<String, Object>) ((Map<String, Object>) item).get('keys')).get('subscriberkey');
				Map<String, Object> valuesMap = (Map<String, Object>) ((Map<String, Object>) item).get('values');
				Map<String, Object> sentToKeyValuePairs = new Map<String, Object>();
				Map<String, Object> validKeyValuePairs = new Map<String, Object>();

				if (String.isNotBlank(subscriberKey)) {
					contactIds.add(subscriberKey);
					validKeyValuePairs.put('subscriberkey', subscriberKey);
				}

				for (String key : valuesMap.keySet()) {

					if (validationKeyList.contains(key)) {
						Object value = valuesMap.get(key);

						if (String.isNotBlank(String.valueOf(value))) {
							if (key == 'incidentid') {
								incidentIds.add(String.valueOf(value));
							} else if (key == 'nmi') {
								nmiIdentifiers.add(String.valueOf(value));
							}
						}

						if (key == 'communicationtype' || key == 'email' || key == 'mobile') {
							sentToKeyValuePairs.put(key, value);
						} else if (key == 'messagetext') {

							if (String.isNotBlank(String.valueOf(value))) {
								validKeyValuePairs.put('disablesmsbutton', false);
                                validKeyValuePairs.put(key, String.valueOf(value).unescapeHtml4());
							} else {
								validKeyValuePairs.put('disablesmsbutton', true);
                                validKeyValuePairs.put(key, value);
							}

						} else if (key == 'sentdate') {
							DateTime dt = createDateTime(String.valueOf(value));
							validKeyValuePairs.put(key, dt);
						} else if (key == 'lifesupportcustomer') {
                            validKeyValuePairs.put(key, Boolean.valueOf(value));
                        } else {
							validKeyValuePairs.put(key, value);
						}
					}
				}

				// set sentto value using communicationtype
				if (!sentToKeyValuePairs.isEmpty()) {

					if (sentToKeyValuePairs.get('communicationtype') == 'Email') {
						validKeyValuePairs.put('sentto', sentToKeyValuePairs.get('email'));
					} else if (sentToKeyValuePairs.get('communicationtype') == 'SMS') {
						validKeyValuePairs.put('sentto', sentToKeyValuePairs.get('mobile'));
					}
				}

				commLogValuesMapList.add(validKeyValuePairs);
			}

			// create record detail page URL links
			if (!contactIds.isEmpty()) {
				Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :contactIds]);

				if (!contactMap.isEmpty()) {
					for (Map<String, Object> data : commLogValuesMapList) {
						String contactId = String.valueOf(data.get('subscriberkey'));
						Contact contact;

						if (String.isNotBlank(contactId)) {
							contact = contactMap.get(contactId);
						}

						if (contact != null) {
							data.put('contactname', contact.Name);
							data.put('subscriberkey', baseRecordUrl + contactId);
						}
					}
				}
			}

			if (!incidentIds.isEmpty()) {
				Map<Id, Incident> incidentMap = new Map<Id, Incident>([SELECT Id, IncidentNumber FROM Incident WHERE Id IN :incidentIds]);

				if (!incidentMap.isEmpty()) {
					for (Map<String, Object> data : commLogValuesMapList) {
						String incidentId = String.valueOf(data.get('incidentid'));
						Incident incident;

						if (String.isNotBlank(incidentId)) {
							incident = incidentMap.get(incidentId);
						}

						if (incident != null) {
							data.put('incidentnumber', incident.incidentNumber);
							data.put('incidentid', baseRecordUrl + incidentId);
						}
					}
				}
			}

			if (!nmiIdentifiers.isEmpty()) {
				Map<String, Id> servicePointNameToIdMap = new Map<String, Id>();
				Map<String, Id> servicePoint10DigitToIdMap = new Map<String, Id>();
				List<vlocity_cmt__ServicePoint__c> servicePoints = [SELECT Id, Name, NMI_10__c FROM vlocity_cmt__ServicePoint__c WHERE Name IN :nmiIdentifiers OR NMI_10__c IN :nmiIdentifiers];

				if (!servicePoints.isEmpty()) {

					for (vlocity_cmt__ServicePoint__c sp : servicePoints) {
						servicePointNameToIdMap.put(sp.Name, sp.Id);
						servicePoint10DigitToIdMap.put(sp.NMI_10__c, sp.Id);
					}

					for (Map<String, Object> data : commLogValuesMapList) {
						String nmiIdentifier = String.valueOf(data.get('nmi'));
						String nmiId;

						if (String.isBlank(nmiIdentifier)) continue;

						if (nmiIdentifier.length() == 11) {
							nmiId = servicePointNameToIdMap.get(nmiIdentifier);
						} else {
							nmiId = servicePoint10DigitToIdMap.get(nmiIdentifier);
						}

						if (nmiId != null) {
							data.put('nmiidentifier', nmiIdentifier);
							data.put('nmi', baseRecordUrl + nmiId);
						}
					}
				}
			}
		}

		return commLogValuesMapList;
	}

	@testVisible
	private static DateTime createDateTime (String dateString)
	{
		// Create a Datetime value from passed in date String "MM/DD/YYYY HH:MM:SS AM/PM"
		List<String> DT_Parts = dateString.split(' '); // 0: date 1: time 2: am/pm
		List<String> D_Parts = DT_Parts[0].split('/'); // 0: mm 1: dd 2: yyyy
		List<String> T_Parts = DT_Parts[1].split(':'); // 0: h 1: m 2: ss

		Integer mth = Integer.valueOf(D_Parts[0]);
		Integer day = Integer.valueOf(D_Parts[1]);
		Integer yr  = Integer.valueOf(D_Parts[2]);

		Integer hr  = Integer.valueOf(T_Parts[0]);
		Integer min = Integer.valueOf(T_Parts[1]);
		Integer sec = Integer.valueOf(T_Parts[2]);

		if (hr < 12 && DT_Parts[2].toLowerCase() == 'pm') {
			hr += 12;
		} else if (hr == 12 && DT_Parts[2].toLowerCase() == 'am') {
            hr = 0;
        }

		DateTime dt = DateTime.newInstance(yr, mth, day, hr, min, sec);

		return dt;
	}

	private static String getMarketingCloudOAuthToken(String clientId, String clientSecret, String clientMID)
	{
		String requestBody  = JSON.serialize(
				new Map<String, String>{
						'grant_type' => 'client_credentials',
						'client_id' => clientId,
						'client_secret' => clientSecret,
						'account_id' => clientMID
					});
		HttpResponse response = JSONPostCall(MC_SCHEMA + MC_HOST_ID + '.auth' + MC_HOST_DOMAIN + MC_AUTH_URL, null, requestBody);

		if (response.getStatusCode() != 200)
		{
			// Error
			return null;
		}

		Map<String, String> responseMap = (Map<String, String>)JSON.deserialize(response.getBody(), Map<String, String>.class);
		return responseMap.get('access_token');
	}

	private static HttpResponse JSONPostCall(String endPoint, Map<String, String> headers, String soapBody)
	{
		Http h = new Http();
		HttpRequest r = new HttpRequest();
		r.setTimeout(60000);
		r.setEndpoint(endPoint);
		r.setMethod('POST');
		r.setHeader('Content-type', 'application/json');

		if (headers != null)
		{
			for (String key: headers.keySet())
			{
				r.setHeader(key, headers.get(key));
			}
		}

		r.setBody(soapBody);
		HttpResponse res = h.send(r);
		return res;
	}

	private static HttpResponse JSONGetCall(String endPoint, Map<String, String> headers)
	{
		Http h = new Http();
		HttpRequest r = new HttpRequest();
		r.setTimeout(60000);
		r.setEndpoint(endPoint);
		r.setMethod('GET');
		r.setHeader('Content-type', 'application/json');

		if (headers != null)
		{
			for (String key: headers.keySet())
			{
				r.setHeader(key, headers.get(key));
			}
		}

		// r.setBody(soapBody);
		HttpResponse res = h.send(r);
		return res;
	}

	private static void MCAuthToken()
	{
		// Authorise / get Token
		if (MC_ACCESS_TOKEN == null)
		{
			MC_ACCESS_TOKEN = getMarketingCloudOAuthToken(MC_CLIENT_ID, MC_CLIENT_SEC, MC_MID);

			if (UserInfo.getOrganizationId() != UtilFieldCalcs.PROD_ORG_ID && showToken)  // do not show in Prod.
				System.debug('MC_ACCESS_TOKEN: '+MC_ACCESS_TOKEN);

			if (MC_ACCESS_TOKEN == null)
			{
				// Big error.
				String error = 'Error: Access token null.';
				System.debug(error);
				throw new MC_Exception(error);
			}
		}
	}

	private static Object getObject(Object obj, String key)
	{
		Object output;
		Map<String, Object> objMap = (Map<String, Object>)obj;

		if (!objMap.containsKey(key))
		{
			// Error
			output = 'Error: Key not found ['+key+'].';
			return output;
		}

		output = (Object)objMap.get(key);

		return output;
	}

	private static String getFirst(Set<String> setStrings)
	{
		String output = '';
		if (setStrings == null || setStrings.isEmpty())
			return output;

		for (String s: setStrings)
		{
			output = s;
			break;
		}

		return output;
	}



	// *****************************************************************
	// ** Custom classes
	public class MC_Category
	{
		Integer id;
		String  description;
		Integer enterpriseId;
		Integer memberId;
		String  name;
		Integer parentId;
		String  categoryType;

		public void loadJson(Object cat)
		{
			Map<String, Object> category = (Map<String, Object>)cat;

			id = Integer.valueOf(category.get('id'));
			description = String.valueOf(category.get('description'));
			enterpriseId = Integer.valueOf(category.get('enterpriseId'));
			memberId = Integer.valueOf(category.get('memberId'));
			name = String.valueOf(category.get('name'));
			parentId = Integer.valueOf(category.get('parentId'));
			categoryType = String.valueOf(category.get('categoryType'));
		}

		public MC_Category() { }
		public MC_Category(Object cat) { loadJson(cat); }
	}

	public class MC_Asset
	{
		Integer id;
		String  customerKey;
		String  objectID;
		String  name;

		Integer enterpriseId;
		Integer memberId;
		Integer modelVersion;

		String body;
		String content;
		String channel;
		String emailSubject;

		public Boolean isError = false;
		public String errorMsg;

		public void loadJson(Object asst)
		{
			Map<String, Object> assett = (Map<String, Object>)asst;

			id = Integer.valueOf(assett.get('id'));
			customerKey = String.valueOf(assett.get('customerKey'));
			objectID = String.valueOf(assett.get('objectID'));
			name = String.valueOf(assett.get('name'));

			enterpriseId = Integer.valueOf(assett.get('enterpriseId'));
			memberId = Integer.valueOf(assett.get('memberId'));
			modelVersion = Integer.valueOf(assett.get('modelVersion'));

			if (assett.containsKey('content'))
				content = String.valueOf(assett.get('content'));
		}

		public void error(String e_msg)
		{
			isError = true;
			errorMsg = e_msg;
		}

		public MC_Asset() { }
		public MC_Asset(Object asst) { loadJson(asst); }
		public MC_Asset(String argName) { name = argName; }
	}

	public class MC_Exception extends Exception
	{

	}

}