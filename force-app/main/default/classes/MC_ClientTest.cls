/*
@description: Apex Test Class For MC_Client 
*/
@isTest
public with sharing class MC_ClientTest {

    @testSetup
    static void setup() {

        Contact con = new Contact(FirstName = 'Test', LastName = 'MCClientTest');
        insert con;

        Incident inc = new Incident(uom_Incident_Id__c = 'TestInc-1', Status = 'New', Subject = 'Power out', Priority = 'Critical');
        insert inc;

        vlocity_cmt__Premises__c premises = new vlocity_cmt__Premises__c(Name = '123 Fake Street', vlocity_cmt__StreetAddress__c = '123 Fake Street', vlocity_cmt__City__c = 'Melbourne', vlocity_cmt__State__c = 'VIC', vlocity_cmt__PostalCode__c = '3000');
        insert premises;

        vlocity_cmt__ServicePoint__c sp = new vlocity_cmt__ServicePoint__c(Name = '12345678901', vlocity_cmt__MarketIdentifier__c = '12345678901', vlocity_cmt__ServiceType__c = 'Electricity', vlocity_cmt__Status__c = 'Connected', vlocity_cmt__PremisesId__c = premises.Id);
        insert sp;
    }
    
    @isTest
    static void queryCommLogTest() {
        final Date date1 = Date.newInstance(2023, 08, 20);
        final Date date2 = Date.newInstance(2023, 08, 21);
        final Date date3 = Date.newInstance(2023, 08, 22);
        
        Test.setMock(HttpCalloutMock.class, new MC_ClientMockHttpResponse());
       
        Test.startTest();
        // Validate both records are returned as they are after start date
        String result = MC_Client.queryCommLog('subscriberkey', '', 'sentdate', 'desc', date1, null, 1, 10);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        Decimal recordCount = (Decimal) responseMap.get('count');
        Assert.areEqual(2, recordCount);

        List<Object> itemsList = (List<Object>) responseMap.get('items');
        Assert.areEqual(2, itemsList.size());

        // Validate one record is returned as it is after start date (12am onwards)
        result = MC_Client.queryCommLog('subscriberkey', '', 'sentdate', 'desc', date2, null, 1, 10);
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        recordCount = (Decimal) responseMap.get('count');
        Assert.areEqual(1, recordCount);

        itemsList = (List<Object>) responseMap.get('items');
        Assert.areEqual(1, itemsList.size());

        Map<String, Object> firstItem = (Map<String, Object>) itemsList.get(0);
        Map<String, Object> valuesMap = (Map<String, Object>) firstItem.get('values');
        String sentDate = (String) valuesMap.get('sentdate');
        Assert.areEqual('8/21/2023 11:46:00 AM', sentDate);

        // Validate one record is returned as it is before end date (same date inclusive)
        result = MC_Client.queryCommLog('subscriberkey', '', 'sentdate', 'desc', null, date1, 1, 10);
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        recordCount = (Decimal) responseMap.get('count');
        Assert.areEqual(1, recordCount);

        itemsList = (List<Object>) responseMap.get('items');
        Assert.areEqual(1, itemsList.size());

        firstItem = (Map<String, Object>) itemsList.get(0);
        valuesMap = (Map<String, Object>) firstItem.get('values');
        sentDate = (String) valuesMap.get('sentdate');
        Assert.areEqual('8/20/2023 11:46:00 AM', sentDate);

        // Validate no records are returned as records are after the specified start date
        result = MC_Client.queryCommLog('subscriberkey', '', 'sentdate', 'desc', date3, null, 1, 10);
        responseMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        recordCount = (Decimal) responseMap.get('count');
        Assert.areEqual(0, recordCount);

        itemsList = (List<Object>) responseMap.get('items');
        Assert.isNull(itemsList);

        Test.stopTest();
    }

    @isTest
    static void getCommLogDataTest() {
        final Date startDate = Date.newInstance(2023, 08, 20);

        Test.setMock(HttpCalloutMock.class, new MC_ClientMockHttpResponse());
        vlocity_cmt__ServicePoint__c sp = [SELECT Id, Name FROM vlocity_cmt__ServicePoint__c WHERE Name = '12345678901'];

        Test.startTest(); 
        Map<String, Object> result = (Map<String, Object>) MC_Client.getCommLogData('vlocity_cmt__ServicePoint__c', String.valueOf(sp.Id), 'sentdate', 'desc', startDate, null, 1, 10);

        // Validate map size (CommLogInfo and CommLogValues)
        Assert.areEqual(2, result.size());

        // Validate CommLogInfo info nmiResponse mock data has only one 1 record
        Map<String, Object> commLogInfoMapList = (Map<String, Object>) result.get('CommLogInfo');
        Assert.areEqual(1, commLogInfoMapList.get('count'));

        // Validate CommLogValues size is 1 with nmi 12345678901.
        List<Map<String, Object>> commLogValuesMapList = (List<Map<String, Object>>) result.get('CommLogValues');
        Assert.areEqual(1, commLogValuesMapList.size());

        // Validate record found using nmi as the filter
        Map<String, Object> firstCommLog = (Map<String, Object>) commLogValuesMapList.get(0);
        Assert.areEqual(sp.Name, firstCommLog.get('nmiidentifier'));

        Test.stopTest();
    }
    
    @isTest
    static void getCommLogFilterKeyTest() {

        Test.startTest();
        String filterKey = MC_Client.getCommLogFilterKey('Contact');
        Assert.areEqual('subscriberkey', filterKey);

        filterKey = MC_Client.getCommLogFilterKey('vlocity_cmt__ServicePoint__c');
        Assert.areEqual('nmi', filterKey);

        filterKey = MC_Client.getCommLogFilterKey('Incident');
        Assert.areEqual('incidentid', filterKey);

        filterKey = MC_Client.getCommLogFilterKey('Affected_Customer__c');
        Assert.areEqual('affectedcustomerid', filterKey);

        filterKey = MC_Client.getCommLogFilterKey('Affected_Market_Identifier__c');
        Assert.areEqual('marketidentifier', filterKey);

        filterKey = MC_Client.getCommLogFilterKey('TestForNullResponse');
        Assert.isNull(filterKey);
        
        Test.stopTest();
    }

    @isTest
    static void createCommLogInfoMapTest() {

        Test.setMock(HttpCalloutMock.class, new MC_ClientMockHttpResponse());

        Test.startTest();
        String result = MC_Client.queryCommLog('subscriberkey', '', 'sentdate', 'desc', null, null, 1, 10);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        // check key/value pairs correctly returned and totalPageCount logic correct based on using pageSize:10 in responseMap
        Map<String, Object> commLogInfoMap = MC_Client.createCommLogInfoMap(responseMap);
        Assert.areEqual(1, commLogInfoMap.get('totalPageCount'));
        Assert.areEqual(1, commLogInfoMap.get('page'));
        Assert.areEqual(2, commLogInfoMap.get('count'));

        responseMap.put('count', 0);
        commLogInfoMap = MC_Client.createCommLogInfoMap(responseMap);
        Assert.areEqual(1, commLogInfoMap.get('totalPageCount'));

        responseMap.put('count', 11);
        commLogInfoMap = MC_Client.createCommLogInfoMap(responseMap);
        Assert.areEqual(2, commLogInfoMap.get('totalPageCount'));

        Test.stopTest();
    }

    @isTest
    static void createCommLogValuesMapListTest() {
        // setup data for test case
        final String baseRecordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
        Contact con = [SELECT Id, Name FROM Contact WHERE LastName = 'MCClientTest'];
        Incident inc = [SELECT Id, incidentNumber FROM Incident WHERE uom_Incident_Id__c = 'TestInc-1'];
        vlocity_cmt__ServicePoint__c sp = [SELECT Id, Name FROM vlocity_cmt__ServicePoint__c WHERE Name = '12345678901'];

        Test.setMock(HttpCalloutMock.class, new MC_ClientMockHttpResponse());
        
        Test.startTest();
        // setup data for test case using mock data
        String result = MC_Client.queryCommLog('subscriberkey', '', 'sentdate', 'desc', null, null, 1, 10);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        List<Object> itemsList = (List<Object>) responseMap.get('items');
        Map<String, Object> firstItem = (Map<String, Object>) itemsList.get(0);
        Map<String, Object> keysMap = (Map<String, Object>) firstItem.get('keys');
        keysMap.put('subscriberkey', con.Id);
        Map<String, Object> valuesMap = (Map<String, Object>) firstItem.get('values');
        valuesMap.put('incidentid', inc.Id);

        List<Map<String, Object>> commLogValuesMapList = MC_Client.createCommLogValuesMapList(itemsList);
        
        // validate returned list size consistant with test data
        Assert.isTrue(commLogValuesMapList.size() == 2);

        // get CommLogs for test validations
        Map<String, Object> firstCommLog = (Map<String, Object>) commLogValuesMapList.get(0);
        Map<String, Object> secondCommLog = (Map<String, Object>) commLogValuesMapList.get(1);

        // validate record page links and label values correctly assigned
        Assert.areEqual(baseRecordUrl + con.id, firstCommLog.get('subscriberkey'));
        Assert.areEqual(con.Name, firstCommLog.get('contactname'));

        Assert.areEqual(baseRecordUrl + inc.id, firstCommLog.get('incidentid'));
        Assert.areEqual(inc.incidentNumber, firstCommLog.get('incidentnumber'));

        Assert.areEqual(sp.Name, firstCommLog.get('nmiidentifier'));
        Assert.areEqual(baseRecordUrl + sp.id, firstCommLog.get('nmi'));

        // validate sentto and disablesmsbutton values are correctly assigned (communicationtype = SMS)
        Assert.areEqual('6149123123', firstCommLog.get('sentto'));
        Assert.isTrue(String.isNotBlank(String.valueOf(firstCommLog.get('messagetext'))));
        Assert.areEqual(false, firstCommLog.get('disablesmsbutton'));

        // validate sentto and disablesmsbutton values are correctly assigned (communicationtype = Email)
        Assert.areEqual('test@test.ausnetservices.com.au.invalid', secondCommLog.get('sentto'));
        Assert.isTrue(String.isBlank(String.valueOf(secondCommLog.get('messagetext'))));
        Assert.areEqual(true, secondCommLog.get('disablesmsbutton'));

        Test.stopTest();
    }

    @isTest
    static void queryCommLogFailuresTest() {

        Test.setMock(HttpCalloutMock.class, new MC_ClientTestRestMockFailure());
        Exception eMock;

        Test.startTest();
        try {
            String result = MC_Client.queryCommLog('subscriberkey', '', 'sentdate', 'desc', null, null, 1, 10);
        } catch (Exception e) {
            eMock = e;
        }

        Assert.areEqual('Error.', eMock.getMessage());

        Test.stopTest();
    }

    @isTest
    static void createDateTimeTest() {
        String stringDate = '8/30/2023 11:12:03 PM'; // day, mth, yr, hr, min, sec
        DateTime dtExpected = DateTime.newInstance(2023, 8, 30, 23, 12, 3); // yr, mth, day, hr, min, sec
        String stringDate12am = '9/13/2023 12:15:00 AM'; // day, mth, yr, hr, min, sec
        DateTime dtExpected12am = DateTime.newInstance(2023, 9, 13, 0, 15, 0); // yr, mth, day, hr, min, sec
        String stringDate12pm = '10/13/2023 12:15:00 PM'; // day, mth, yr, hr, min, sec
        DateTime dtExpected12pm = DateTime.newInstance(2023, 10, 13, 12, 15, 0); // yr, mth, day, hr, min, sec

        Test.startTest();
        DateTime dt = MC_Client.createDateTime(stringDate);
        Assert.areEqual(dtExpected, dt);

        dt = MC_Client.createDateTime(stringDate12am);
        Assert.areEqual(dtExpected12am, dt);

        dt = MC_Client.createDateTime(stringDate12pm);
        Assert.areEqual(dtExpected12pm, dt);

        Test.stopTest();
    }

    private class MC_ClientMockHttpResponse implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String jsonBody;

            if (req.getEndpoint().Contains('v2/token')) {
                jsonBody = '{\"access_token\":123}';
            } else if (req.getEndpoint().Contains('filter=nmi')) {
                jsonBody = '{\"pageSize\":10,\"page\":1,\"count\":1,\"items\":[{\"keys\":{\"subscriberkey\":\"\",\"jobid\":\"\",\"batchid\":\"\"},\"values\":{\"email\":\"\",\"mobile\":\"6149123123\",\"communicationtype\":\"SMS\",\"messagename\":\"\",\"messagestatus\":\"\",\"affectedcustomerid\":\"\",\"incidentid\":\"\",\"nmi\":\"12345678901\",\"marketidentifier\":\"\",\"lifesupportcustomer\":\"\",\"sentdate\":\"8/21/2023 11:46:00 AM\",\"modifieddate\":\"\",\"journeyname\":\"\",\"journeyversion\":\"\",\"triggeredsendid\":\"\",\"incidenttype\":\"\",\"messagetext\":\"test sms message text\"}}]}';
            } else if (req.getEndpoint().Contains('sentdate%20gte%20\'2023-08-21\'')){
                jsonBody = '{\"pageSize\":10,\"page\":1,\"count\":1,\"items\":[{\"keys\":{\"subscriberkey\":\"\",\"jobid\":\"\",\"batchid\":\"\"},\"values\":{\"email\":\"\",\"mobile\":\"6149123123\",\"communicationtype\":\"SMS\",\"messagename\":\"\",\"messagestatus\":\"\",\"affectedcustomerid\":\"\",\"incidentid\":\"\",\"nmi\":\"12345678901\",\"marketidentifier\":\"\",\"lifesupportcustomer\":\"\",\"sentdate\":\"8/21/2023 11:46:00 AM\",\"modifieddate\":\"\",\"journeyname\":\"\",\"journeyversion\":\"\",\"triggeredsendid\":\"\",\"incidenttype\":\"\",\"messagetext\":\"test sms message text\"}}]}';
            }else if (req.getEndpoint().Contains('sentdate%20lt%20\'2023-08-21\'')) {
                jsonBody = '{\"pageSize\":10,\"page\":1,\"count\":1,\"items\":[{\"keys\":{\"subscriberkey\":\"\",\"jobid\":\"\",\"batchid\":\"\"},\"values\":{\"email\":\"test@test.ausnetservices.com.au.invalid\",\"mobile\":\"\",\"communicationtype\":\"Email\",\"messagename\":\"\",\"messagestatus\":\"\",\"affectedcustomerid\":\"\",\"incidentid\":\"\",\"nmi\":\"\",\"marketidentifier\":\"\",\"lifesupportcustomer\":\"\",\"sentdate\":\"8/20/2023 11:46:00 AM\",\"modifieddate\":\"\",\"journeyname\":\"\",\"journeyversion\":\"\",\"triggeredsendid\":\"\",\"incidenttype\":\"\",\"messagetext\":\"\"}}]}';
            }else if (req.getEndpoint().Contains('sentdate%20gte%20\'2023-08-22\'')) {
                jsonBody = '{\"pageSize\":10,\"page\":1,\"count\":0}';
            }else {
                jsonBody = '{\"pageSize\":10,\"page\":1,\"count\":2,\"items\":[{\"keys\":{\"subscriberkey\":\"\",\"jobid\":\"\",\"batchid\":\"\"},\"values\":{\"email\":\"\",\"mobile\":\"6149123123\",\"communicationtype\":\"SMS\",\"messagename\":\"\",\"messagestatus\":\"\",\"affectedcustomerid\":\"\",\"incidentid\":\"\",\"nmi\":\"12345678901\",\"marketidentifier\":\"\",\"lifesupportcustomer\":\"\",\"sentdate\":\"8/21/2023 11:46:00 AM\",\"modifieddate\":\"\",\"journeyname\":\"\",\"journeyversion\":\"\",\"triggeredsendid\":\"\",\"incidenttype\":\"\",\"messagetext\":\"test sms message text\"}},{\"keys\":{\"subscriberkey\":\"\",\"jobid\":\"\",\"batchid\":\"\"},\"values\":{\"email\":\"test@test.ausnetservices.com.au.invalid\",\"mobile\":\"\",\"communicationtype\":\"Email\",\"messagename\":\"\",\"messagestatus\":\"\",\"affectedcustomerid\":\"\",\"incidentid\":\"\",\"nmi\":\"\",\"marketidentifier\":\"\",\"lifesupportcustomer\":\"\",\"sentdate\":\"8/20/2023 11:46:00 AM\",\"modifieddate\":\"\",\"journeyname\":\"\",\"journeyversion\":\"\",\"triggeredsendid\":\"\",\"incidenttype\":\"\",\"messagetext\":\"\"}}]}';
            }

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');
            res.setBody(jsonBody);
            res.setStatusCode(200);
            return res;
        }
    }

    private class MC_ClientTestRestMockFailure implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String jsonBody;
            Integer statusCode;

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-type', 'application/json');

            if (req.getEndpoint().Contains('v2/token')) {
                jsonBody = '{\"access_token\":123}';
                statusCode = 200;
            } else {
                jsonBody = '{\"message\":\"\"Error.\"\"}';
                statusCode = 500;
                res.setStatus('Server Error');
            }

            res.setBody(jsonBody);
            res.setStatusCode(statusCode);
            return res;
        }
    }

}