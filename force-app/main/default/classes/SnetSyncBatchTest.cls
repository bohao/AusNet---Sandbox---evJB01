@isTest
private class SnetSyncBatchTest {
    public class ExampleCalloutMock implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
            HttpResponse res = new HttpResponse();
            res.setStatus('OK');
            res.setStatusCode(200);
            res.setBody('[{"response":{\"result\":\"1\",\"code\":\"200\",\"message\":\"The application is successfully created\",\"initiating_msgid\":\"SOL-20230609716792\",\"salesforceId\":\"CAYL4WJDRY3EA\"}}]');
            return res;
        }
    }

    static testMethod void testBatchJob() {
    
        Account Acc= new Account();
        Acc.Name = 'TestAccount' ;
        Acc.Customer_Type__c='ELE - CINCL';
        insert Acc;
        
        
        
        Contact con = new contact();
        con.lastname='test1';
        con.Email='test@ausnet.com';
        con.AccountId=Acc.Id;
        insert con;
        
        
        Connection_Point__c cp = new Connection_Point__c();
        cp.NMI_Ref__c='1234';
        cp.NMI__c='1234';
        insert cp;
        
        DER_Application__c derApp = new DER_Application__c();
        derApp.Ph_C_New_Export__c= 2.13;
        derApp.Ph_A_New_Export__c=0;
        derApp.Ph_B_New_Export__c=2.02;
        derApp.Has_Battery__c =true;
        derApp.Has_Solar__c=true;
        derApp.Meter_Number__c='xy123';
        derApp.NMI__c=cp.Id;
        derApp.FE_Reg_Status__c = true;
        insert derApp;
        
        DER_Agreement__c DerAgree = new DER_Agreement__c();
        DerAgree.DER_Application__c=derApp.Id;
        DerAgree.NMI__c=cp.Id;
        DerAgree.Account__c=Acc.Id;
        insert DerAgree;        
        
        Case c1= new case();        
        c1.Application_Number__c='1234';  
        c1.Auto_Applicant_Email__c='test@ausnet.com';
        c1.DER_Application__c=derApp.Id;
        c1.AccountId=Acc.Id;
        c1.ContactId=con.Id;
        c1.Representative__c=con.Id;      
        insert c1;
        //c1 = [Select Id,FE_Reg_Status__c from Case where DER_Application__c= :derApp.Id LIMIT 1];
        
        Device__c dev1 = new Device__c();
        dev1.AC_Equip_Sub_Type__c=' Battery';
        dev1.AC_Equip_Type__c='Inverter';
        dev1.AC_DC_Coupling__c='AC';
        dev1.DER_Application__c=derApp.Id;
        insert dev1;
        
        Device__c dev2 = new Device__c();
        dev2.AC_Equip_Sub_Type__c=' Battery';
        dev2.AC_Equip_Type__c='Inverter';
        dev2.AC_DC_Coupling__c='AC';
        dev2.DER_Application__c=derApp.Id;
        dev2.Parent_Device__c=dev1.Id;
        insert dev2;

        SNET__c setting = new SNET__c();
		setting.Name = 'SNET';
		setting.Endpoint__c = 'https://stg-gw.apin.ausnetservices.com.au/DERApplications/Update';
		insert setting;

        // Create batch job instance and execute
        
        SnetSyncBatch batch = new SnetSyncBatch();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        Database.executeBatch(batch);
        Test.stopTest();

       
        System.assertEquals(dev1.DER_Application__c, dev2.DER_Application__c);
    }
}