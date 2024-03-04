// *****************************************************************
// ** MC_BitlyAPICallOut
// ** Description : This Class will have methods to
// *1 Get short URL for the incident/any full address link
// *2
// *****************************************************************

public with sharing class API_BitlyCallOut
{
	// *****************************************************************
	@testvisible private static Set<String> URL_Schemas = new Set<String>{'http://', 'https://'};

	// *****************************************************************
	// ** Main methods
	// *1 getShortURL
	// ** This method fetches shortURL for the long URL provided.
	@AuraEnabled
	public static String getShortURL(String longURL)
	{
		String shortURL;

		Map<String, String> JSONParameters = new Map<String, String>
		{
			'group_guid' => 'Bk9i0vdTIKx',
			'domain' => 'bit.ly',
			'long_url' => longURL
		};

		String strJSON = JSON.serializePretty(JSONParameters);

		HttpRequest req = new HttpRequest();
		req.setEndpoint('callout:Bitly');
		req.setMethod('POST');
		req.setBody(strJSON);
		req.setHeader('Accept', '*/*');
		req.setHeader('Authorization', 'Bearer {!$Credential.Password}');
		req.setHeader('Content-Type', 'application/json');

		Http http = new Http();
		HTTPResponse res ;
		Map<String, Object> bitlyResponse = new Map<String, Object>();
		if(Test.isRunningTest()){
			bitlyResponse.put('link','https://example.com');
		}
		else{
			res = http.send(req);

			// *** Process response
			bitlyResponse = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
		}

		if (bitlyResponse.containsKey('link'))
			shortURL = (String)bitlyResponse.get('link');

		// Remove schema from URL
		for (String schema: URL_Schemas)
			if (shortURL.startsWith(schema))
				shortURL = shortURL.removeStart(schema);

		return shortURL;
	}
}