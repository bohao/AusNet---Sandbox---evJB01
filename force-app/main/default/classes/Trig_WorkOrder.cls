/*
@author  : lakshay.sharma@ausnetservices.com.au
@created : 27 feb 2020
@Description : Class for WorkOrder Trigger
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-------------------------------------------------------------------------------------------------------
27/02/20          Lakshay Sharma             
-------------------------------------------------------------------------------------------------------
*/
public with sharing class Trig_WorkOrder implements UtilTrigHandle{
    public static Boolean TrigDisabled = false;
    
    public Boolean IsDisabled()
    {
        if (TrigSettings__c.getInstance().WorkOrder_Trigger_Disabled__c)
            return true;
        else
            return TrigDisabled;
    }
    public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs)
    {
        Qualify_WorkOrderEndDate(newSObjs,oldSObjs);
        
    }
    public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs){}
    public void AfterInsert(Map<Id, SObject> newSObj){}
    public void AfterDelete(Map<Id, SObject> oldSObjs) {}
    public void AfterUndelete(Map<Id, SObject> newSObjs) {}
    public void BeforeInsert(List<SObject> newSObjs) {}
    public void BeforeDelete(Map<Id, SObject> oldSObjs) {}
    private static void Qualify_WorkOrderEndDate(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        Map<Id,Id> Map1 = new Map<Id,Id>();
        Map<Id,WorkOrder> Map2= new Map<Id,WorkOrder>();
        WorkOrder newWO;
        WorkOrder oldWO;
        for(id key : newSObj.keySet()){
            newWO = (WorkOrder)newSObj.get(key);
            oldWO =(WorkOrder) oldSObj.get(key);
            
            if(newWO.Type__c == 'Construction' 
            && newWO.EndDate != oldWO.EndDate 
            && newWO.EndDate != null 
            && newWO.Project__c != Null)
        	{
                Map1.put(newWO.Project__c, newWO.Id);
                Map2.put(newWO.id, newWO);                
            }                  
        }       

        System.debug('maps for update'+map1);
        System.debug('maps for update'+map2);
        
        if(!Map1.isEmpty())
        {
            TVE_WorkOrder_Utility.updateWorkOrder(Map1,Map2);
        }            
    }
}