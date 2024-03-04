@isTest
public class FnP_ExtUserObjAccessUtilityTest {
    @TestSetup
    public static void createTestData() {
        // Create Test data
        Contact contactRecord = new Contact(FirstName='CityGen',LastName='CityGen',Email='cgen@c.com',MobilePhone='0490213214',OtherPhone='422244222');
        INSERT contactRecord;
    }
    @IsTest
    public static void test01_getRecordData(){
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
        
        FnP_ExtUserObjAccessUtility fnpObject=new FnP_ExtUserObjAccessUtility();
        Boolean result=FnP_ExtUserObjAccessUtility.invokeMethod('getRecordData',inputMap, outputMap, options);
        
        System.assertEquals(true, result);
        Test.stopTest();
    }
    
    @IsTest
    public static void test02_upsertRecordData(){
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
        
        FnP_ExtUserObjAccessUtility fnpObject=new FnP_ExtUserObjAccessUtility();
        Boolean result=FnP_ExtUserObjAccessUtility.invokeMethod('upsertRecordData',inputMap, outputMap, options);
        
        System.assertEquals(true, result);
        Test.stopTest();
    }

}