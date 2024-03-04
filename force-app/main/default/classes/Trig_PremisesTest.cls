@isTest
public class Trig_PremisesTest {
	
     @IsTest
    public static void testMethod1(){
    	vlocity_cmt__Premises__c testPremise = new vlocity_cmt__Premises__c();
        testPremise.Name = 'Test Data 1';
       	testPremise.Test_NMI__c = 'T11100000001';
        testPremise.Test_Data__c = true;
        test.startTest();
        INSERT testPremise;

        testPremise.Delete_Test_Data__c = true;
        
        UPDATE testPremise;
        test.stopTest();
    }
    
}