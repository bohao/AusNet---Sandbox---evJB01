public class TVE_SF_Azure_IntegrationTesting{

 @future(callout = true)
 public static void  callAzureAPI(Id conId,List<Id> ids){
        Contact con =[select id,firstname,lastname,name,Phone,MobilePhone,Email from contact where id=:conId];
        List<Project__c> relatedProjList = [select id, ApplicantContact__c from  Project__c where id IN : ids];
        String adUserId;
        HttpResponse res1;
        String accessToken;
        List<String> emailList = new List<String>();
        emailList.add(con.Email);        
        accessToken=TVE_SF_Azure_Utility.getAccessToken();
        if(accessToken!=null)
        {
            String password=TVE_SF_Azure_Utility.generatePassword(35);
            
            Http h1 = new Http();
            HttpRequest req1 = new HttpRequest();
            
            req1.setHeader('Authorization','Bearer '+accessToken);
            req1.setHeader('Content-Type', 'application/json');
            req1.setHeader('SdkVersion','postman-graph/v1.0');
            req1.setHeader('Accept', 'application/json');
            req1.setEndpoint('https://graph.microsoft.com/v1.0/users');
            req1.setMethod('POST');
            
            TVE_Azure_Call__mdt azureInfo=[SELECT Issuer__c FROM TVE_Azure_Call__mdt WHERE DeveloperName='Azure_User_Creation'];

            passwordProfile pword = new passwordProfile(password, false);
            identities emailId = new identities(TVE_IntegUtility.checkString(con.Email), TVE_IntegUtility.checkString(azureInfo.Issuer__c));
            JSONGenerator gen = JSON.createGenerator(true);  
            gen.writeStartObject();      
            gen.writeStringField('displayName', TVE_IntegUtility.checkString(con.Name));//required
            gen.writeStringField('passwordPolicies','DisablePasswordExpiration');
            gen.writeFieldName('passwordProfile');
            gen.writeObject(pword);
            gen.writeStringField('givenName',TVE_IntegUtility.checkString(con.FirstName));
            gen.writeStringField('surname', TVE_IntegUtility.checkString(con.LastName));
            gen.writeStringField('mobilePhone',formatInternationalMobile(TVE_IntegUtility.checkString(con.MobilePhone)));
            gen.writeFieldName('identities');
            gen.writeStartArray();
            gen.writeObject(emailId);
            gen.writeEndArray();
            
            gen.writeEndObject();    
            
            String reqbody1 = gen.getAsString();
            
            System.debug('jsonMaterials '+reqbody1);
            req1.setBody(reqbody1);  
            if(!Test.isRunningTest()){
                res1 = h1.send(req1);
                
                System.debug('response in azure '+res1.getBody()+'response'+res1);
                if(res1.getStatusCode()==201){
                    AzureResponse AZ=(AzureResponse)JSON.deserialize(res1.getBody(),AzureResponse.class);
                    if(AZ.id!=null){
                        //Flow used to introduce delay of email
                        Flow.Interview flow = new Flow.Interview.Delay_Registration_Emails(new map<String,Object>{
                            'Uname' => con.Email,
                            'Pword' => password, 
                            'Fname'  => con.FirstName});     
                        flow.start();
                        //TVE_SF_Azure_Utility.sendAzureEmail(con.Email,password,con);
                        adUserId=AZ.id;
                        if(adUserId!=null){
                        con.AD_User_ID__c = adUserId;
                        update con;
                        }
                    }
                }
                else{
                    //AzureResponse AZ=(AzureResponse)JSON.deserialize(res1.getBody(),AzureResponse.class);
                    system.debug('response message:'+res1.getBody());
                    createIntegrationLog(res1.getBody(),relatedProjList,con.id);
                }
            }       
            
        }
        
        System.debug('adUserId'+adUserId);
    }
    
    
    
    public static void createIntegrationLog(String response,List<Project__c> projIds,Id contactId)
    {
        Integration_Log__c intLog=new Integration_Log__c();
        intLog.Error_Message__c='Error on Azure customer creation for below list of Projects:'+projIds+'and Contact:'+contactId+'-'+response;         
        intLog.Status__c='Failed';
        intLog.Type__c='Azure create customer';
        insert intLog;
    }
    public class passwordProfile { 
        String password;
        Boolean forceChangePasswordNextSignIn; 
        public passwordProfile(String s, Boolean b) { 
            password = s; 
            forceChangePasswordNextSignIn = b;
        }
    }
    
    public static String formatInternationalMobile(String mobile){
        String formattedMobile= mobile.replaceAll( '\\s+', '');
        formattedMobile='+61 ' + formattedMobile.substring(1);
        System.debug('formattedMobile' + formattedMobile);
        return formattedMobile;
    }
    
    
    public class identities { 
        String signInType;
        String issuer;
        String issuerAssignedId;
        public identities(String s, String iss) { 
            signInType = 'emailAddress'; 
            issuer = iss;
            issuerAssignedId = s;
        }
    }
    
    public class AzureResponse{
        public String id ;
        public String statusMessage;
    }

}