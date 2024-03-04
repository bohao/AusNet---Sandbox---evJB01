/*
@Author  : Jie Tan
@Date    : June 2020
@Description : Utility class for Apex managed sharing
*/
public without sharing class TVE_SharingUtility {
    public static void deleteSharingByAccount(Map<Id, Id> projToAcct) {
        List<Project__Share> projShareToDelete = [SELECT Id, ParentId, UserOrGroupId FROM Project__Share WHERE ParentId IN :projToAcct.keySet() AND RowCause = :TVE_Constants.ASP_APPLICANT_ROW_CAUSE];
        if(!projShareToDelete.isEmpty()) {
            delete projShareToDelete;
        }
    }

    public static void createSharingByAccount(Map<Id, Id> projToAcct) {
        Map<Id, Set<Id>> mapAcctToUsers = new Map<Id, Set<Id>>();
        List<Project__Share> projShareToCreate = new List<Project__Share>();

        for(User usr : [SELECT Id, AccountId FROM User WHERE AccountId IN :projToAcct.values() AND UserType = :TVE_Constants.PARTNER_USER_TYPE AND IsActive = true]) {
            if(!mapAcctToUsers.containsKey(usr.AccountId)) {
                mapAcctToUsers.put(usr.AccountId, new Set<Id>());
            }
            mapAcctToUsers.get(usr.AccountId).add(usr.Id);
        }

        for(Id projId : projToAcct.keySet()) {
            if(mapAcctToUsers.containsKey(projToAcct.get(projId))) {
                for(Id userId : mapAcctToUsers.get(projToAcct.get(projId))) {
                    projShareToCreate.add(
                        new Project__Share(
                            ParentId = projId,
                            UserOrGroupId = userId,
                            RowCause = TVE_Constants.ASP_APPLICANT_ROW_CAUSE,
                            AccessLevel = TVE_Constants.ASP_APPLICANT_ACCESS
                        )
                    );
                }
            }
        }
        if(!projShareToCreate.isEmpty()) {
            insert projShareToCreate;
        }
    }
    
    @future
    public static void deleteSharingByUser(Map<Id, Id> userToAcct) {
        List<Project__Share> projShareToDelete = [SELECT Id, ParentId, UserOrGroupId FROM Project__Share WHERE UserOrGroupId IN :userToAcct.keySet() AND RowCause = :TVE_Constants.ASP_APPLICANT_ROW_CAUSE];
        if(!projShareToDelete.isEmpty()) {
            delete projShareToDelete;
        }
    }
    
    @future
    public static void createSharingByUser(Map<Id, Id> userToAcct) {
        Map<Id, Set<Id>> mapAcctToProjs = new Map<Id, Set<Id>>();
        List<Project__Share> projShareToCreate = new List<Project__Share>();

        for(Project__c proj : [SELECT Id, ApplicantAccount__c FROM Project__c WHERE ApplicantAccount__c IN :userToAcct.values()]) {
            if(!mapAcctToProjs.containsKey(proj.ApplicantAccount__c)) {
                mapAcctToProjs.put(proj.ApplicantAccount__c, new Set<Id>());
            }
            mapAcctToProjs.get(proj.ApplicantAccount__c).add(proj.Id);
        }

        for(Id userId : userToAcct.keySet()) {
            if(mapAcctToProjs.containsKey(userToAcct.get(userId))) {
                for(Id projId : mapAcctToProjs.get(userToAcct.get(userId))) {
                    projShareToCreate.add(
                        new Project__Share(
                            ParentId = projId,
                            UserOrGroupId = userId,
                            RowCause = TVE_Constants.ASP_APPLICANT_ROW_CAUSE,
                            AccessLevel = TVE_Constants.ASP_APPLICANT_ACCESS
                        )
                    );
                }
            }
        }
        if(!projShareToCreate.isEmpty()) {
            insert projShareToCreate;
        }
    }
}