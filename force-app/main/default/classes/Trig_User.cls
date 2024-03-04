/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 09 Feb 2020
@Description : Class for User Trigger
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-------------------------------------------------------------------------------------------------------
09/2/20         Brajesh Tiwary             Added method Qualify_updateContactCommunityUrl() on  Before Insert
-------------------------------------------------------------------------------------------------------
*/
public with sharing class Trig_User implements UtilTrigHandle{
    public static Boolean TrigDisabled = false;
    
    public Boolean IsDisabled()
    {
        if (TrigSettings__c.getInstance().User_Trigger_Disabled__c)
            return true;
        else
            return TrigDisabled;
    }
    public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
    {
        Qualify_updateCommunityUser(newSObjs, oldSObjs);
        Qualify_handleSharing(newSObjs, oldSObjs);
    }
    // if context is not implemented, condense into one-liners
    public void AfterInsert(Map<Id, SObject> newSObj)
    {	
        Qualify_updateCommunityUser(newSObj,null);
        Qualify_handleSharing(newSObj,null);
    }
    public void AfterDelete(Map<Id, SObject> oldSObjs) {}
    public void AfterUndelete(Map<Id, SObject> newSObjs) {}
    public void BeforeInsert(List<SObject> newSObjs) {}
    public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
    public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs){}
    // *********************************************************************
    // *** Trigger methods
    
    private static void Qualify_updateCommunityUser(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        List<User> listValidUser = new List<User>();
        List<User> listActivateExistingValidUser = new List<User>();
        List<User> listInactiveUser = new List<User>();
        User newUser;
        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for(sObject sObjItem: newSObj.values())
                {					
                    newUser = (User)sObjItem;
                    if(newUser.ContactId != null )
                    {
                        listValidUser.add((User)newUser);
                    }                    
                }
            }
            when AFTER_UPDATE
            {
                User newUserObj;
                User oldUserObj;
                system.debug('newSObj.values()'+newSObj.values());
                for(sObject sObjItem: newSObj.values()){
                    newUserObj = (User)sObjItem;
                    oldUserObj = (User)oldSObj.get(newUserObj.Id);
                    if(newUserObj.ContactId!=null 
                    && newUserObj.IsActive 
                     && 
                      (isPopulated('City', newUserObj, oldUserObj) || isPopulated('CommunicationPreference__c', newUserObj, oldUserObj)
                       || isPopulated('Country', newUserObj, oldUserObj) || isPopulated('Email', newUserObj, oldUserObj)
                       || isPopulated('FirstName', newUserObj, oldUserObj)
                       || isPopulated('LastName', newUserObj, oldUserObj)
                       || isPopulated('MobilePhone', newUserObj, oldUserObj)
                       || isPopulated('Phone', newUserObj, oldUserObj)
                       || isPopulated('PostalCode', newUserObj, oldUserObj)
                       || isPopulated('State', newUserObj, oldUserObj)|| isPopulated('Street', newUserObj, oldUserObj)
                       ))
                    {
                        listActivateExistingValidUser.add(newUserObj);
                    }else if(newUserObj.IsActive == false 
                         && newUserObj.ContactId != null 
                         && isPopulated('IsActive', newUserObj, oldUserObj))
                    {
                        listInactiveUser.add(newUserObj);
                    }
                }
            }
        }
        if(!listValidUser.isEmpty()){
            TVE_User_Utility.updateUserCommLicense(listValidUser);
        }
        if(!listInactiveUser.isEmpty()){
            TVE_User_Utility.updateUnregisteredCommUser(listInactiveUser);
        }
        if(!listActivateExistingValidUser.isEmpty()){
            TVE_User_Utility.updateUserCommLicense(listActivateExistingValidUser);
        }
    }
    
    private static void Qualify_handleSharing(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        Map<Id, Id> mapToDelete = new Map<Id, Id>();
        Map<Id, Id> mapToCreate = new Map<Id, Id>();
        switch on Trigger.operationType
        {
            when AFTER_INSERT
            {
                for(sObject sObjItem : newSObj.values())
                {					
                    User newUser = (User)sObjItem;
                    if(newUser.AccountId != null && newUser.UserType == TVE_Constants.PARTNER_USER_TYPE && newUser.IsActive)
                    {
                        mapToCreate.put(newUser.Id, newUser.AccountId);
                    }
                }
            }
            when AFTER_UPDATE
            {
                User newUser;
                User oldUser;
                for(sObject sObjItem : newSObj.values()){
                    newUser = (User)sObjItem;
                    oldUser = (User)oldSObj.get(newUser.Id);
                    if(oldUser.AccountId != newUser.AccountId || oldUser.UserType != newUser.UserType || oldUser.IsActive != newUser.IsActive){
                        if(oldUser.AccountId != null && oldUser.UserType == TVE_Constants.PARTNER_USER_TYPE && oldUser.IsActive){
                            mapToDelete.put(oldUser.Id, oldUser.AccountId);
                        }
                        if(newUser.AccountId != null && newUser.UserType == TVE_Constants.PARTNER_USER_TYPE && newUser.IsActive){
                            mapToCreate.put(newUser.Id, newUser.AccountId);
                        }
                    }
                }
            }
        }

        if(!mapToDelete.isEmpty()) {
            TVE_SharingUtility.deleteSharingByUser(mapToDelete);
        }
        if(!mapToCreate.isEmpty()) {
            TVE_SharingUtility.createSharingByUser(mapToCreate);
        }
    }

    // ---------------------------------------------------//
    //------- User Trigger utility methods ---------------//
    // ---------------------------------------------------//
    private static Boolean isPopulated(String f, User newUser, User oldUser)
    {
        Boolean isFieldPopulated = false;
        if(newUser.get(f) == null)
            isFieldPopulated = false;
        else if(newUser.get(f) instanceof Boolean)
            isFieldPopulated = newUser.get(f) != null && ((Boolean)newUser.get(f)) != ((Boolean)oldUser.get(f));
        else
            isFieldPopulated = String.isNotBlank((String)newUser.get(f)) && ((String)newUser.get(f)) != ((String)oldUser.get(f));
        return isFieldPopulated;
    }
    
}