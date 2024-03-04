global without sharing class TVE_SF_Azure_Utility {
    @TestVisible public static  EmailTemplate emailTemplate;
    public static void azureInteg(List<id> conIdList){
        List<Contact> validConLst = new List<Contact>();
        if(conIdList.size()>0)
        {
            for(Contact conItem: getContacts(conIdList))
            {
                if(conItem.AD_User_ID__c == null)
                {
                    validConLst.add(conItem);
                }
            }
        }
        System.debug('validConLst in azure utility'+validConLst);
        if(!validConLst.isEmpty())
            System.enqueuejob(new  TVE_SF_Azure_Integration(validConLst));
        
    }
    
    public static List<Contact> getContacts(List<id> conIDList){
        List<Contact> conRecordTemp = [select id,AD_User_ID__c,FirstName,LastName,MobilePhone,Email,MailingCity,MailingCountry,
                                       Department,Name,Title,MailingPostalCode,MailingState,MailingStreet,Account.Customer_Company_Name__c,
                                       Account.IsPersonAccount,Account.ASPAccreditaionId__c
                                       from Contact where Id IN:conIdList];
        return conRecordTemp;
    }
    
    public static String getAccessToken(){
        
        string accessToken;
        TVE_Azure_Call__mdt azureInfo=[select ClientId__c,ClientSecret__c,TenantID__c from TVE_Azure_Call__mdt where DeveloperName='Azure_User_Creation'];
        
        String clientId = azureInfo.ClientId__c;
        String clientSecret =azureInfo.ClientSecret__c;
        String TenantID = azureInfo.TenantID__c;
        
        String reqbody = 'grant_type=client_credentials&client_id=' + clientId + '&client_secret=' + clientSecret + '&scope=https://graph.microsoft.com/.default';
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setHeader('SdkVersion','postman-graph/v1.0');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setEndpoint('https://login.microsoftonline.com/'+TenantID+'/oauth2/v2.0/token');
        if(!Test.isRunningTest()){
            HttpResponse res = h.send(req);
            OAuth2 objAuthenticationInfo = (OAuth2)JSON.deserialize(res.getbody(), OAuth2.class);
            accessToken= objAuthenticationInfo.access_token;
        }
        else {
            accessToken='eyJ0eXAiOiJKV1QiLCJub25jZSI6ImdIbk1RUFljXzg0S1VtcEVDQ1I0Umh1b2hGV2w1OUFySWZTWDhOZC1QVDAiLCJhbGciOiJSUzI1NiIsIng1dCI6IllNRUxIVDBndmIwbXhvU0RvWWZvbWpxZmpZVSIsImtpZCI6IllNRUxIVDBndmIwbXhvU0RvWWZvbWpxZmpZVSJ9.eyJhdWQiOiJodHRwczovL2dyYXBoLm1pY3Jvc29mdC5jb20iLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC83ZWE5OThmYi0yM2U3LTQxMGMtYWEzNC01Y2QwOWY3NzljMDEvIiwiaWF0IjoxNTg1MTQwMTg3LCJuYmYiOjE1ODUxNDAxODcsImV4cCI6MTU4NTE0NDA4NywiYWlvIjoiNDJkZ1lQZ1QwcmNxM3ZkSDNmNy92KzVYRzhndEF3QT0iLCJhcHBfZGlzcGxheW5hbWUiOiJTYWxlc2ZvcmNlLUNsaWVudC1BcHAiLCJhcHBpZCI6IjVhODA5Y2EzLTQzOTUtNDJjOS1iMmUzLWYyMzI3NzJiOTA3NyIsImFwcGlkYWNyIjoiMSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzdlYTk5OGZiLTIzZTctNDEwYy1hYTM0LTVjZDA5Zjc3OWMwMS8iLCJvaWQiOiIzZDVmZTc0ZC1lMTMzLTQwMTAtOGU5Mi1jYWIxODhlOGU3NjgiLCJyb2xlcyI6WyJVc2VyLlJlYWRXcml0ZS5BbGwiXSwic3ViIjoiM2Q1ZmU3NGQtZTEzMy00MDEwLThlOTItY2FiMTg4ZThlNzY4IiwidGlkIjoiN2VhOTk4ZmItMjNlNy00MTBjLWFhMzQtNWNkMDlmNzc5YzAxIiwidXRpIjoiWFFRcG5hMExjRXlva2JpNkczVjFBQSIsInZlciI6IjEuMCIsInhtc190Y2R0IjoxNTgzMTg4ODQ1fQ.aoT1oqSTRrOauePWxxFs_z2EhwhzdzXsFeaajuBhyVYdI7mbYfcnoSMnYi7PYhVZHKhr92bcfEbIaRjP61oCbJC9koc0QQNc2YlUb3R8xxv4HOH2GYPw2YWHS7W5Fy';
        }
        return accessToken;
    }
    
    public static String generatePassword(Integer strSize){
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz1234567890';
        String randStr ='';
        while (randStr.length() < strSize) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
    
    global static void sendAzureEmail(String Username,String password,String contactFname){
        Enhancedletterhead letterHead;
        String passwordlink;
        if(!Test.isRunningTest()){
            emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName =:'Azure_Registration_Email'];
            letterHead=[SELECT Id, LetterheadFooter,  Name,  Description, LetterheadHeader FROM EnhancedLetterhead where name='TVE-Customer Communications Letterhead'];
        }
        passwordlink=RedirectOAuthExt.constructB2CPasswordURL();
        List<String> EmailIDs= new List<String>();
        EmailIDs.add(Username);
        String CustomerCommunity=[SELECT CommunityHome__c FROM TVE_AzureB2CAuthProvider__mdt WHERE DeveloperName = 'Ausnet_AzureAD' LIMIT 1].CommunityHome__c;
        // process the merge fields
        String subject = emailTemplate.Subject;
        
        String htmlBody = emailTemplate.HtmlValue;
        htmlBody = htmlBody.replace('{Contact.Name}', contactFname);
        htmlBody = htmlBody.replace('AzureUsername', Username);
        htmlBody = htmlBody.replace('AzurePasswordLink', passwordlink);
        htmlBody = htmlBody.replace('{CustomerCommunity}', CustomerCommunity);
        
        //build the email message
        Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
        List<OrgWideEmailAddress> orgEmail=[SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = :TVE_Constants.ORG_WIDE_EMAIL];
        if(!Test.isRunningTest()) email.setOrgWideEmailAddressId(orgEmail[0].Id);
        email.setToAddresses(EmailIDs);
        email.setSubject(subject);
        if(!Test.isRunningTest()){
            htmlbody=letterHead.LetterheadHeader +  htmlBody + letterHead.LetterheadFooter;
        email.setHtmlBody(htmlBody);
        
        Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});}
    }
    
    @InvocableMethod(label='Send Azure Emails')
    global static void sendAzureEmails(List<AzureEmailAction> requests){
        
        for(AzureEmailAction request : requests){
            System.debug('request.Username'+request.Username);
            System.debug('request.password'+request.password);
            System.debug('request.firstName'+request.firstName);
            sendAzureEmail(request.Username, request.password, request.firstName);
        }
    }
    
    global class AzureEmailAction {
        
        @InvocableVariable
        global String Username;
        
        @InvocableVariable
        global String password;
        
        @InvocableVariable
        global String firstName;
        
    }
    
}