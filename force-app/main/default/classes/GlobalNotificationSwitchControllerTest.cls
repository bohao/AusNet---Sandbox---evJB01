@isTest
public class GlobalNotificationSwitchControllerTest {
	 @IsTest
    public static void testMethod1(){
        
        Map<String, Object> resultMap = new Map<String, Object>();
        Test.startTest();
    	resultMap=GlobalNotificationSwitchController.fetchIncidentSetup();
        resultMap=GlobalNotificationSwitchController.setIncidentSetup(true);
        Test.stopTest();
    }
}