@isTest
public class FnP_TempBatchLoadHistAmderDataTest {


	@isTest
    public static void BatchMethod() {
        test.startTest();
        FnP_TempBatchLoadHistAmderData obj = new FnP_TempBatchLoadHistAmderData(Date.today(),null);
        database.executeBatch(obj);
        test.stopTest();
    }
}