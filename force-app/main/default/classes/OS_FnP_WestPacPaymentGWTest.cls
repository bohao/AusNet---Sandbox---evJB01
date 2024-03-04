@isTest
public class OS_FnP_WestPacPaymentGWTest {
	
    @TestSetup
    public static void createTestData() {
        // Create Test data
        Contact contactRecord = new Contact(FirstName='CityGen',LastName='CityGen',Email='cgen@c.com',MobilePhone='0490213214',OtherPhone='422244222');
        insert contactRecord;
    }

    @IsTest
    public static void test01_postPaymentWestPac(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        
        Map<String,Object> fieldMapping=new Map<String,Object>();
        fieldMapping.put('FirstName','FirstName');
        fieldMapping.put('LastName','LastName');
        fieldMapping.put('Email','Email');
        fieldMapping.put('MobilePhone','MobilePhone');
        fieldMapping.put('OtherPhone','OtherPhone');
        
        List<Object> sObjectFieldLst = new List<Object>();
        sObjectFieldLst.add(fieldMapping);
        
        Map<String,Object> inputMap=new Map<String,Object>();
        inputMap.put('FirstName','CityGen');
        inputMap.put('LastName','CityGen');
        inputMap.put('Email','cgen@c.com');
        inputMap.put('MobilePhone','0490213214');
        inputMap.put('OtherPhone','422244222');
        inputMap.put('sObjectFieldLst',sObjectFieldLst);
        inputMap.put('sobjectApiName','Contact');
        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        OS_FnP_WestPacPaymentGW fnpObject=new OS_FnP_WestPacPaymentGW();
        Boolean result=fnpObject.invokeMethod('postPaymentWestPac',inputMap, outputMap, options);
        System.debug('result'+result);
	    System.assertEquals(true, result);
        Test.stopTest();
    }
    
    @IsTest
    public static void test02_populateExpiryYears(){
        Test.startTest();
        
        Map<String,Object> fieldMapping=new Map<String,Object>();
        fieldMapping.put('FirstName','CityGen');
        fieldMapping.put('LastName','CityGen');
        fieldMapping.put('Email','cgen@c.com');
        fieldMapping.put('MobilePhone','0490213214');
        fieldMapping.put('OtherPhone','422244222');
        
        List<Object> sObjectFieldLst = new List<Object>();
        sObjectFieldLst.add(fieldMapping);
        
        
        Map<String,Object> inputMap=new Map<String,Object>();
        inputMap.put('FirstName','CityGen');
        inputMap.put('LastName','CityGen');
        inputMap.put('Email','cgen@c.com');
        inputMap.put('MobilePhone','0490213214');
        inputMap.put('OtherPhone','422244222');
        inputMap.put('sObjectFieldLst',sObjectFieldLst);
        inputMap.put('sobjectApiName','Contact');
        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        OS_FnP_WestPacPaymentGW fnpObject=new OS_FnP_WestPacPaymentGW();
        Boolean result=fnpObject.invokeMethod('populateExpiryYears',inputMap, outputMap, options);
        
        System.assertEquals(true, result);
        Test.stopTest();
    }

    @IsTest
    public static void test03_getFirmOfferForElecForm(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        
        Map<String,Object> fieldMapping=new Map<String,Object>();
        fieldMapping.put('FirstName','FirstName');
        fieldMapping.put('LastName','LastName');
        fieldMapping.put('Email','Email');
        fieldMapping.put('MobilePhone','MobilePhone');
        fieldMapping.put('OtherPhone','OtherPhone');
        
        List<Object> sObjectFieldLst = new List<Object>();
        sObjectFieldLst.add(fieldMapping);
        
        
        Map<String,Object> inputMap=new Map<String,Object>();
        inputMap.put('FirstName','CityGen');
        inputMap.put('LastName','CityGen');
        inputMap.put('Email','cgen@c.com');
        inputMap.put('MobilePhone','0490213214');
        inputMap.put('OtherPhone','422244222');
        inputMap.put('sObjectFieldLst',sObjectFieldLst);
        inputMap.put('sobjectApiName','Contact');
        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        OS_FnP_WestPacPaymentGW fnpObject=new OS_FnP_WestPacPaymentGW();
        Boolean result=fnpObject.invokeMethod('getFirmOfferForElecForm',inputMap, outputMap, options);
        
        System.assertEquals(true, result);
        Test.stopTest();
    }
    
    private class RestMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
           String fullJson = '{"status": "OK","statusMessage": "Load ECM file completed successfully.","initiating_msgId": "123456","msgId": "123456","payload": {    "PDF": "your json response"  }}';            
           //String fullJson = '{"payDtls":[{"Block1":[{"cardholderName": "saradhi","expiryDateMonth":"12-12","expiryDateYear":"2024","cvn":"296"}]}]}';           

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}