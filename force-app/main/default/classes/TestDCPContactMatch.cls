@isTest
public class TestDCPContactMatch {
    
    @TestSetup
    static void makeData(){
        contact con = new Contact(FirstName='CityGen',LastName='CityGen',Email='cgen@c.com',MobilePhone='0490213214',OtherPhone='422244222');
        insert con;
    }

    @isTest
    private static void testNameMatch(){

        Map<String,Object> inputMap=new Map<String,Object>();
        inputMap.put('FirstName','CityGen');
        inputMap.put('LastName','CityGen');
        inputMap.put('Email','cgen@c.com');
        inputMap.put('MobilePhone','0490213214');
        inputMap.put('OtherPhone','422244222');
        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        DCPContactMatch dcpCM=new DCPContactMatch();
        Boolean result=dcpCM.invokeMethod('Match',inputMap, outputMap, options);
        
        System.assertEquals(true, result);
    }

    @isTest
    private static void testEmailAndMobileMatch(){

        Map<String,Object> inputMap=new Map<String,Object>();
        inputMap.put('FirstName','CityGen');
        inputMap.put('LastName','CityGen');
        inputMap.put('Email','cgen@c.com');
        inputMap.put('MobilePhone','0490213214');
        inputMap.put('OtherPhone','');
        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        DCPContactMatch dcpCM=new DCPContactMatch();
        Boolean result=dcpCM.invokeMethod('Match',inputMap, outputMap, options);
        
        System.assertEquals(true, result);
    }

    @isTest
    private static void testEmailAndOtherPhoneMatch(){
        
        Map<String,Object> inputMap=new Map<String,Object>();
        inputMap.put('FirstName','CityGen');
        inputMap.put('LastName','CityGen');
        inputMap.put('Email','cgen@c.com');
        inputMap.put('MobilePhone','');
        inputMap.put('OtherPhone','422244222');
        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        DCPContactMatch dcpCM=new DCPContactMatch();
        Boolean result=dcpCM.invokeMethod('Match',inputMap, outputMap, options);
        
        System.assertEquals(true, result);
    }

    @isTest
    private static void testEmailOnlyMatch(){

        Map<String,Object> inputMap=new Map<String,Object>();
        inputMap.put('FirstName','CityGen');
        inputMap.put('LastName','CityGen');
        inputMap.put('Email','cgen@c.com');
        inputMap.put('MobilePhone','');
        inputMap.put('OtherPhone','');
        
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        
        DCPContactMatch dcpCM=new DCPContactMatch();
        Boolean result=dcpCM.invokeMethod('Match',inputMap, outputMap, options);
        
        System.assertEquals(true, result);
    }
}