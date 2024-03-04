/*
@author  : Arti.foglae@ausnetservices.com.au
@created : 13 Mar  2020
@Description :  Controller class for lwc tveInternalUsersLookup
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
11 Jun 2020         dave.pavan@in.ibm.com           TV-3343 Allow users with profile "Unified of DER and TVE11" to be searched 
-----------------------------------------------------------------------------------------
*/

public without sharing class TVE_InternalUsersLookupCtrl {
    private static final Set<string> profiles = new Set<String>{'TVE-11 AST Standard User', 'DER TVE-11 Unified User'};
    
   @AuraEnabled(cacheable=true)
    public static List<UserResult> getResults( String value) 
    {            
        String UserId=Userinfo.getUserId();
        
        String newSearchText = '%'+value+'%';
        system.debug('newSearchText:'+newSearchText);
        List<UserResult>userList =new List<UserResult>();
        List<contact>relatedContacts=new List<Contact>();
        
        List<Profile> validProfiles = new List<Profile>([SELECT id, Name FROM Profile WHERE Name IN: profiles]);
                
        if(!validProfiles.isEmpty() && String.isNotEmpty(value))
        {
            List<User> internalUsers = [SELECT Id, Name FROM User 
                                                    WHERE ProfileId IN: validProfiles 
                                                    AND Name LIKE :newSearchText
                                                    AND IsActive = true];
            
            system.debug('internalUsers:'+internalUsers);
            
            for(user u : internalUsers)
            {
                userList.add(new UserResult(u.Name,u.id));
            }
        }

        system.debug('userid:'+UserId);
        
        Id conId =[Select contactId from user where id=:UserId].contactId;
        Id accId;
        if(conId !=null)
            {
                accId =[select accountId from contact where id=:conId ].accountId;
            }
        
        if(accId!=null)
        {  
            relatedContacts=[Select id from contact where accountid=:accId];
            
        }
        
        if(!relatedContacts.isEmpty() && String.isNotEmpty(value))
            
        {
                
            for(user u :[select id, Name from user 
                                        where contactId in :relatedContacts  
                                        and id !=:UserId 
                                        and Name like :newSearchText])
            {
                userList.add(new UserResult(u.Name,u.id));
            }
            
        }
        
        system.debug('userList:'+userList);
        return   userList;   
    }

    public class UserResult {
        @AuraEnabled
        public String userName;
        @AuraEnabled
        public Id userId;
        
        public UserResult(String recNameTemp, Id recIdTemp) {
            userName = recNameTemp;
            userId = recIdTemp;
        }
    }
}