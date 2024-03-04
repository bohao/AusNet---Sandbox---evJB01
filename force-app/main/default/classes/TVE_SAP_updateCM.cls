public class TVE_SAP_updateCM {
    public static void checkProject(List<id> ProjectIDList,Map<Id, SObject> newSObj)
    {
        Map<String,String> projIntMap = new Map<String,String>();
        Map<String,String> projIntMap2 = new Map<String,String>();
        List<id> ProjList = new List<id>();
        List<id> ProjListinsert = new List<id>();
        Map<Id,String> recordMap= new Map<Id,string>();
        Map<String,String> creatIntTaskMap = new Map<String,string>();
        List<Integration_Task__c> intTaskList=[select id,ParentId__c from Integration_Task__c 
                                               where ParentId__c IN: ProjectIDList and Type__c='GetCM'                                               
       										   and 	(Status__c='Ready' or Status__c='In Progress')]; 
       										  
        for(Integration_Task__c intg: intTaskList)
        {
            projIntMap.put(intg.ParentId__c,intg.id);
        }
        for(ID projID:ProjectIDList)
        {
            Project__c proj = (Project__c)newSObj.get(projID);
            if(projIntMap.containsKey(projID))
                proj.addError('Update is pending to receive from SAP or integration is in progress. Please try again later');
            else
                ProjList.add(projID);
        }
        if(ProjList.size()>0)
        {
            List<Integration_Task__c> intTList = [select id,ParentId__c from Integration_Task__c 
                                                  where ParentId__c IN: ProjList and Type__c='UpdateCM'
                                                  and Status__c='Ready'];
            if(intTList.size()>0)
            {
                for(Integration_Task__c intg: intTList)
                    projIntMap2.put(intg.ParentId__c,intg.id);
            }
            for(ID projID:ProjList)
            {
                Project__c proj = (Project__c)newSObj.get(projID);
                if(!projIntMap2.containsKey(projID))
                    recordMap.put(projID,projID);
            }
        }
        System.debug('recordMap: ' + recordMap);
        System.debug('projIntMap2: ' + projIntMap2);
        if(recordMap.size()>0)
        {
            creatIntTaskMap.put('Operation__c','Update');
            creatIntTaskMap.put('SObject__c','Project__c');
            creatIntTaskMap.put('Type__c','UpdateCM');
            creatIntTaskMap.put('Status__c','Ready');
            TVE_IntegUtility.CreateInteTask(recordMap,creatIntTaskMap);
        }
    }
    
}