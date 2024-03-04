@IsTest 
public class TestTVE_AzureB2CAuthProviderPlugin {
    
    private static final String OAUTH_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwib2lkIjoiNmEyZWMzNmUtMmIzZC00NjdhLWJiYTItYTUxNTg4ZWQxNmI0IiwiZ2l2ZW5fbmFtZSI6InRlc3RGaXJzdE5hbWUiLCJmYW1pbHlfbmFtZSI6InRlc3RMYXN0TmFtZSIsImVtYWlscyI6WyJ0ZXN0QEVtYWlsQWRkcmVzcy5jb20iXSwiaWF0IjoxNTE2MjM5MDIyfQ.aaBDoTBkMrDcdDH9QXSy-mVKVdMGxrDj-0qHiJjIDqk';
    private static final String STATE = 'mocktestState'; 
    private static final String REFRESH_TOKEN = 'refreshToken'; 
    private static final String LOGIN_ID = 'testLoginId'; 
    private static final String USERNAME = 'testUsername'; 
    private static final String FIRST_NAME = 'testFirstName'; 
    private static final String LAST_NAME = 'testLastName'; 
    private static final String EMAIL_ADDRESS = 'test@EmailAddress.com'; 
    private static final String LOCALE_NAME = 'en_AU'; 
    private static final String FULL_NAME = FIRST_NAME + ' ' + LAST_NAME; 
    private static final String PROVIDER = 'Ausnet_AzureAD'; 
    private static final String REDIRECT_URL = 
        'http://localhost/services/authcallback/orgId/Ausnet_AzureAD'; 
    private static final String KEY = 'testKey'; 
    private static final String SECRET = 'testSecret'; 
    private static final String STATE_TO_PROPOGATE = 'testState'; 
    private static final String ACCESS_TOKEN_URL = 
        'http://www.dummyhost.com/accessTokenUri'; 
    private static final String API_USER_VERSION_URL = 
        'http://www.dummyhost.com/user/20/1'; 
    private static final String AUTH_URL = 
        'http://www.dummy.com/authurl'; 
    private static final String API_USER_URL = 
        'www.concursolutions.com/user/api'; 
    private static final String POLICY = 'B2C_1_SIGNINV2';
    private static final String AUTHPROVIDERNAME = 'Ausnet_AzureAD';
    private static final String PORTALNAME = 'CustomerCommunity';

    
    // In the real world scenario, the key and value would be read 
    // from the (custom fields in) custom metadata type record. 
    private static Map<String,String> setupAuthProviderConfig () 
    { 
        Map<String,String> authProviderConfiguration = new Map<String,String>(); 
        authProviderConfiguration.put('Consumer_Key__c', KEY); 
        authProviderConfiguration.put('Auth_Url__c', AUTH_URL); 
        authProviderConfiguration.put('Consumer_Secret__c', SECRET); 
        authProviderConfiguration.put('Access_Token_Url__c', ACCESS_TOKEN_URL); 
        authProviderConfiguration.put('API_User_Url__c',API_USER_URL); 
        authProviderConfiguration.put('API_User_Version_Url__c',
                                      API_USER_VERSION_URL); 
        authProviderConfiguration.put('Redirect_Url__c',REDIRECT_URL); 
        authProviderConfiguration.put('Policy__c',POLICY); 
        authProviderConfiguration.put('PortalName__c',PORTALNAME); 
        authProviderConfiguration.put('AuthProviderName__c',AUTHPROVIDERNAME); 
        
        
        return authProviderConfiguration; 
        
    } 
    
    static testMethod void testInitiateMethod() 
    { 
        String stateToPropogate = 'mocktestState'; 
        Map<String,String> authProviderConfiguration = setupAuthProviderConfig(); 
        TVE_AzureB2CAuthProviderPlugin AzureB2CCls = new TVE_AzureB2CAuthProviderPlugin(); 
        AzureB2CCls.redirectUrl = authProviderConfiguration.get('Redirect_Url__c'); 
        PageReference expectedUrl = new PageReference(authProviderConfiguration.get('Auth_Url__c') + '?client_id='+ 
                                                      authProviderConfiguration.get('Consumer_Key__c') + '&p=' +
                                                      authProviderConfiguration.get('Policy__c') +'&prompt=login&redirect_uri='+ 
                                                      authProviderConfiguration.get('Proxy_Redirect_URL__c') + '&response_type=code&scope=openid&state=' + 
                                                      STATE_TO_PROPOGATE); 
        PageReference actualUrl = AzureB2CCls.initiate(authProviderConfiguration, STATE_TO_PROPOGATE); 
        System.assertEquals(expectedUrl.getUrl(), actualUrl.getUrl());
    } 
    
    static testMethod void testHandleCallback() 
    { 
        Map<String,String> authProviderConfiguration = 
            setupAuthProviderConfig(); 
        TVE_AzureB2CAuthProviderPlugin AzureB2CCls = new TVE_AzureB2CAuthProviderPlugin(); 
        AzureB2CCls.redirectUrl = authProviderConfiguration.get('Redirect_Url__c'); 
        
        Test.setMock(HttpCalloutMock.class, new 
                     AzureB2CMockHttpResponseGenerator()); 
        
        Map<String,String> queryParams = new Map<String,String>(); 
        queryParams.put('code','code'); 
        queryParams.put('state',STATE_TO_PROPOGATE); 
        Auth.AuthProviderCallbackState cbState = 
            new Auth.AuthProviderCallbackState(null,null,queryParams); 
        Auth.AuthProviderTokenResponse actualAuthProvResponse = 
            AzureB2CCls.handleCallback(authProviderConfiguration, cbState); 
        Auth.AuthProviderTokenResponse expectedAuthProvResponse = 
            new Auth.AuthProviderTokenResponse(
                'Ausnet_AzureAD', OAUTH_TOKEN, SECRET, STATE_TO_PROPOGATE); 
        
        System.assertEquals(expectedAuthProvResponse.provider, 
                            actualAuthProvResponse.provider); 
        System.assertEquals(expectedAuthProvResponse.oauthToken, 
                            actualAuthProvResponse.oauthToken); 
        System.assertEquals(expectedAuthProvResponse.oauthSecretOrRefreshToken, 
                            actualAuthProvResponse.oauthSecretOrRefreshToken); 
        System.assertEquals(expectedAuthProvResponse.state, 
                            actualAuthProvResponse.state); 
        
    } 
    
    static testMethod void testGetUserInfo() 
    { 
        Map<String,String> authProviderConfiguration = 
            setupAuthProviderConfig(); 
        TVE_AzureB2CAuthProviderPlugin AzureB2CCls = new TVE_AzureB2CAuthProviderPlugin(); 
        
        Test.setMock(HttpCalloutMock.class, new 
                     AzureB2CMockHttpResponseGenerator()); 
        
        Auth.AuthProviderTokenResponse response = 
            new Auth.AuthProviderTokenResponse(
                PROVIDER, OAUTH_TOKEN ,'sampleOauthSecret', STATE); 
        Auth.UserData actualUserData = AzureB2CCls.getUserInfo(
            authProviderConfiguration, response) ; 
        
        Map<String,String> provMap = new Map<String,String>(); 
        provMap.put('key1', 'value1'); 
        provMap.put('key2', 'value2'); 
        
        Auth.UserData expectedUserData = new Auth.UserData(LOGIN_ID, 
                                                           FIRST_NAME, LAST_NAME, FULL_NAME, EMAIL_ADDRESS, 
                                                           null, LOCALE_NAME, null, PROVIDER, null, provMap); 
        
        System.assertNotEquals(expectedUserData,null); 
        System.assertEquals(expectedUserData.firstName, 
                            actualUserData.firstName); 
        System.assertEquals(expectedUserData.lastName, 
                            actualUserData.lastName); 
        System.assertEquals(expectedUserData.fullName, 
                            actualUserData.fullName); 
        System.assertEquals(expectedUserData.email, 
                            actualUserData.email); 
        System.assertEquals(expectedUserData.username, 
                            actualUserData.username); 
        System.assertEquals(expectedUserData.locale, 
                            actualUserData.locale); 
        System.assertEquals(expectedUserData.provider, 
                            actualUserData.provider); 
        
    } 
    
    
    // Implement a mock http response generator for AzureB2C. 
    public class AzureB2CMockHttpResponseGenerator implements HttpCalloutMock 
    { 
        public HTTPResponse respond(HTTPRequest req) 
        {  
            // Create a fake response 
            HttpResponse res = new HttpResponse(); 
            res.setHeader('Content-Type', 'application/json'); 
            res.setBody('{"id_token": "' + OAUTH_TOKEN + '"}'); 
            res.setStatusCode(200); 
            return res; 
        } 
        
    } 
}