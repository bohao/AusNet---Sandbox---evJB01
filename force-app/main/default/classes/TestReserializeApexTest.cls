@isTest
public class TestReserializeApexTest {
static testMethod void invokeMethod(){
        Map<String, Object> m;
        string sr='{"CaseId\":\"5005P000009B2p0QAC\",\"YourDetails\":{\"Block2\":{\"ComplaintFile\":[{\"data\":\"0698G000000CsJvQAK\",\"filename\":\"test.png\"}]}}}';
        m = (Map<String, Object>) JSON.deserializeUntyped(sr);
        Map<String,Object> outputMap=new Map<String,Object>();
        Map<String,Object> options=new Map<String,Object>();
        Test.startTest();
        Boolean result=TestReserializeApex.invokeMethod('insertArtifacts',m, outputMap, options);
        Test.stopTest();
    }
    
}