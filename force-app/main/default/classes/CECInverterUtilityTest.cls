@isTest
public class CECInverterUtilityTest {


	@isTest
    public static void BatchMethod() {
        test.startTest();
        CECInverterUtility obj= new CECInverterUtility();
        database.executeBatch(obj);
        test.stopTest();
    }
}