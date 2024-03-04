@isTest
public class API_BitlyCallOutTest {
@IsTest
    public static void test01_getShortUrl(){
        Test.startTest();
        
        String result=API_BitlyCallOut.getShortURL('https://ausnetservices--uomra1.sandbox.lightning.force.com/lightning/r/CampaignMember/00vBo000000hjDBIAY/view');
        
     
        Test.stopTest();
    }
}