@isTest
public class TVE_RegHandlerTest {

     @TestSetup
    public static void setup() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
		insert r;
        //UserRole portalRole = [Select Id From UserRole Limit 1];
        User testUser = TVE_TestUtility.createTestUser('test11@gmail.com');
        testUser.UserRoleId=r.id;
        insert testUser;
     
    }
    
    static testMethod void testCreateAndUpdateUser() {
        User testUser1 = [SELECT Id FROM User WHERE email='test11@gmail.com' LIMIT 1];
        System.runAs(testUser1){
            Account a=new Account();
            a.name='test Account';
            insert a;
            Contact c = new Contact();
            c.firstName='test'+genRandStr(4);
            c.LastName='lname';
            c.email='test@gmail.com';
            c.AccountId=a.Id;
            c.AD_User_ID__c='6a3c41f7-d2f9-41d3-a6f8-9b4dc7783e18';
            insert c;
            TVE_RegHandler handler = new TVE_RegHandler();
            Auth.UserData sampleData = new Auth.UserData('6a3c41f7-d2f9-41d3-a6f8-9b4dc7783e18', 'testFirst'+genRandStr(4), 'testLast',
                'testFirst testLast', 'testuser@example.org', null, 'testuserlong', 'en_US', 'facebook',
                null, new Map<String, String>{'language' => 'en_US','oid'=>'6a3c41f7-d2f9-41d3-a6f8-9b4dc7783e18','sfdc_networkid'=>'test',
                    'unique_name'=>'testgmail@npausnetservice.com','full_name'=>'test lname','name'=>'test lname'});
            
                test.startTest();
            User u = handler.createUser(null, sampleData);
            
            insert(u);
            
        String uid = u.id;
        
        sampleData = new Auth.UserData('6a3c41f7-d2f9-41d3-a6f8-9b4dc7783e18', 'testNewFirst'+genRandStr(4), 'testNewLast',
            'testNewFirst testNewLast', 'testnewuser@example.org', null, 'testnewuserlong', 'en_US', 'facebook',
            null, new Map<String, String>{'language' => 'en_US','oid'=>'6a3c41f7-d2f9-41d3-a6f8-9b4dc7783e18','sfdc_networkid'=>'test',
                'unique_name'=>'testgmail@npausnetservice.com','full_name'=>'testNewFirst testNewLast','name'=>'testNewFirst testNewLast'});
        handler.updateUser(uid, null, sampleData);
        
        User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:uid];
        test.stopTest();
        }
    }

    private static String genRandStr(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
           Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
           randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}