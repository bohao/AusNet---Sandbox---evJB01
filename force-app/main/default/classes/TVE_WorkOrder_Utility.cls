/*
@author  : lakshay.sharma@ausnetservices.com.au
@created : 27 Feb 2020
@Description : Class for WorkOrder Utility
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
public with sharing class TVE_WorkOrder_Utility {
    public static void updateWorkOrder(Map<Id,Id> mapPrjIdWOid, Map<Id,WorkOrder> mapWO) {
        Project__c proj;
        List<Project__c> projList=new List<Project__c>();
    
        
        for(Id projId:mapPrjIdWOid.keySet()){
            proj=new Project__c(Id=projId,ConstructionCompletionDate__c=mapWO.get(mapPrjIdWOid.get(projId)).EndDate.date());
            projList.add(proj);
            
        }
        System.debug('projList'+projList);
        if(!projList.isEmpty())
        {
            update projList;
        }        
    }
         
        


}