/*
@author  : Rohit.Middha@ausnetservices.com.au 
@created : 14 Oct 2019
@Description : For setting default values to device and der application object.
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
public with sharing class DER_Defaults {
    
    PRIVATE STATIC Schema.SObjectType t = Schema.getGlobalDescribe().get('DER_Application__c');
    PRIVATE STATIC Schema.DescribeSObjectResult r = t.getDescribe();
    
    PRIVATE STATIC Schema.SObjectType t1 = Schema.getGlobalDescribe().get('Device__c');
    PRIVATE STATIC Schema.DescribeSObjectResult r1 = t1.getDescribe();
    
    public static void applyDefaults(Map<Id,String> derAppIdOfferTypeMap)
    {
        Map<Id,List<Device__c>> derIdDevicesMap = new  Map<Id,List<Device__c>>();
        Map<Id,DER_Application__c> derIdObjMap = new Map<Id,DER_Application__c>();
        Set<Id> derAppIdOfferTypeMapKeySet = derAppIdOfferTypeMap.keySet();
        
        String queryApp = '';
        queryApp += UtilDatabase.getAllFields('DER_Application__c');
        queryApp += ' FROM DER_Application__c ';
        queryApp += 'WHERE Id in :derAppIdOfferTypeMapKeySet';  
        
        List<SObject> objList = Database.query(queryApp);
        
        String queryDevice = '';
        queryDevice += UtilDatabase.getAllFields('Device__c');
        queryDevice += ' FROM Device__c ';
        queryDevice += 'WHERE DER_Application__c in :derAppIdOfferTypeMapKeySet';  
        queryDevice += ' AND Existing_Device__c = false'; 
        
        String queryDerDefaults = '';
        queryDerDefaults += UtilDatabase.getAllFields('DER_Default__c');
        queryDerDefaults += ' FROM DER_Default__c ';
        List<SObject> derDefaults = Database.query(queryDerDefaults);
        
        for(DER_Application__c derapp :(List<DER_Application__c>) objList)
        {
            derIdObjMap.put(derapp.Id,derapp);
        }
        
        
        for(Device__c dev : (List<Device__c>) Database.query(queryDevice))
        {
            List<Device__c> temp = derIdDevicesMap.get(dev.DER_Application__c);
            if(temp == null) {
                derIdDevicesMap.put(dev.DER_Application__c, new List<Device__c>{dev});
            } else {
                temp.add(dev);
            }
        }
        Set<DER_Application__c> derAppList = new Set<DER_Application__c>();
        Set<Device__c> devList = new Set<Device__c>();
        
        for(Id appId :derAppIdOfferTypeMap.keySet() )
        {
            if(derAppIdOfferTypeMap.get(appId) == 'Basic Micro EG MSO')
            { 
                DER_Application__c  derApp = derIdObjMap.get(appId);
                blankOutDerAppFields(derApp,(List<DER_Default__c>)derDefaults);
                for(DER_Default__c def : (List<DER_Default__c>)derDefaults)    
                            {
                                 if(def.Offer_MSO__c == true && def.Object__c == 'DER_Application__c')
                                {
                                    getDerAppAfterFieldUpdate(def,derApp);
                                }
                            }
                List<Device__c> devList1 = (List<Device__c>) derIdDevicesMap.get(appId);
                if(devList1 != null)
                {
                    for(Device__c dev :  devList1)
                    {
                        blankOutDeviceFields(dev,(List<DER_Default__c>)derDefaults);
                        if(dev.AC_Equip_Type__c == 'Inverter')
                        {
                            for(DER_Default__c def : (List<DER_Default__c>)derDefaults)    
                            {
                                if(def.Offer_MSO__c == true)
                                {
                                    if(def.Object__c == 'Device__c' && def.Equip_Inverter__c == true)
                                    {   
                                        getDeviceAfterFieldUpdate(def, dev);
                                    }
                                 }
                            }
                            if(dev != null)
                            {
                                devList.add(dev);
                            }
                        }
                        else if(dev.AC_Equip_Type__c == 'Non-Inverter')
                        {
                            for(DER_Default__c def : (List<DER_Default__c>)derDefaults)    
                            {
                                if(def.Equip_Non_Inverter__c== true && def.Offer_MSO__c == true)
                                {
                                   if(def.Object__c == 'Device__c' && def.Equip_Non_Inverter__c == true)
                                    { 
                                        getDeviceAfterFieldUpdate(def, dev);
                                    }
                                }

                            }
                            if(dev != null)
                            {
                                devList.add(dev);
                            }
                        }
                    }
                }
                 if(derApp != null)
                            {
                                derAppList.add(derApp);
                            }
            }
            else if (derAppIdOfferTypeMap.get(appId) == 'Negotiated >5MW NEA' || derAppIdOfferTypeMap.get(appId) == 'Negotiated 0-5MW'
                     || derAppIdOfferTypeMap.get(appId) == 'Negotiated >5MW NEA&NMA')
            {
                DER_Application__c  derApp = derIdObjMap.get(appId);
                blankOutDerAppFields(derApp,(List<DER_Default__c>)derDefaults);
                   for(DER_Default__c def : (List<DER_Default__c>)derDefaults)    
                            {
                                 if((def.Offer_Neg_0__c == true || def.Offer_Neg_5__c == true)  && def.Object__c == 'DER_Application__c')
                                {
                                    getDerAppAfterFieldUpdate(def,derApp);
                                }
                            }
                List<Device__c> devList2 = derIdDevicesMap.get(appId);
                if(devList2 != null)
                {
                    for(Device__c dev : devList2)
                    {
                        blankOutDeviceFields(dev,(List<DER_Default__c>)derDefaults);
                        if(dev.AC_Equip_Type__c == 'Inverter')
                        { 
                            for(DER_Default__c def : (List<DER_Default__c>)derDefaults)    
                            {
                                 if(def.Object__c == 'Device__c' && def.Equip_Inverter__c == true && (def.Offer_Neg_0__c == true || def.Offer_Neg_5__c == true))
                                    { 
                                        getDeviceAfterFieldUpdate(def, dev);
                                    }
                            }
                            if(dev != null)
                            {
                                devList.add(dev);
                            }
                        }
                        else if(dev.AC_Equip_Type__c == 'Non-Inverter')
                        {
                            for(DER_Default__c def : (List<DER_Default__c>)derDefaults)    
                            {
                                if(def.Equip_Non_Inverter__c== true && def.Object__c == 'Device__c' && (def.Offer_Neg_0__c == true || def.Offer_Neg_5__c == true))
                                {
                                    getDeviceAfterFieldUpdate(def, dev);
                                }
                            }
                            if(dev != null)
                            {
                                devList.add(dev);
                            }
                        }
                    }
                }
                if(derApp != null)
                            {
                                derAppList.add(derApp);
                            }
            }
        }
        List<DER_Application__c> derList  = new  List<DER_Application__c>() ;
        derList.addAll(derAppList);
        List<Device__c> deviceList  = new  List<Device__c>() ;
        deviceList.addAll(devList);
        if(deviceList != null)
            update deviceList;
        if(derList != null)
            update derList;
        
        
    }
    
    
      public static void applyDefault(Map<Device__c,String> deviceOfferTypeMap)
    {
        
        List<Device__c> devList = new List<Device__c>();
        
        String queryDerDefaults = '';
        queryDerDefaults += UtilDatabase.getAllFields('DER_Default__c');
        queryDerDefaults += ' FROM DER_Default__c ';
        List<SObject> derDefaults = Database.query(queryDerDefaults);        
        for(Device__c dev : deviceOfferTypeMap.keySet())
        {
            String aggrementType = deviceOfferTypeMap.get(dev);
            blankOutDeviceFields(dev,(List<DER_Default__c>)derDefaults);
            if(aggrementType == 'Basic Micro EG MSO')
            {
                if(dev.AC_Equip_Type__c == 'Inverter')
                {
                    for(DER_Default__c def : (List<DER_Default__c>)derDefaults)    
                    {
                        if(def.Equip_Inverter__c == true && def.Offer_MSO__c == true )
                        {
                            
                            if(def.Object__c == 'Device__c')
                            {
                                getDeviceAfterFieldUpdate(def, dev);
                            }
                        }
                    }
                    if(dev != null)
                            {
                                devList.add(dev);
                            }
                }
                else if(dev.AC_Equip_Type__c == 'Non-Inverter')
                {
                    for(DER_Default__c def : (List<DER_Default__c>)derDefaults)    
                    {
                        if(def.Equip_Non_Inverter__c == true && def.Offer_MSO__c == true )
                        {
                            
                            if(def.Object__c == 'Device__c')
                            {
                                getDeviceAfterFieldUpdate(def, dev);
                            }
                        }
                    }
                    if(dev != null)
                            {
                                devList.add(dev);
                            }
                }
              
            }
            else if(aggrementType == 'Negotiated >5MW NEA' || aggrementType == 'Negotiated 0-5MW'
                    || aggrementType == 'Negotiated >5MW NEA&NMA')
            {
                if(dev.AC_Equip_Type__c == 'Inverter')
                {
                    for(DER_Default__c def : (List<DER_Default__c>)derDefaults)    
                    {
                        if(def.Equip_Inverter__c == true && (def.Offer_Neg_0__c == true || def.Offer_Neg_5__c == true))
                        {
                            
                            if(def.Object__c == 'Device__c')
                            {
                                getDeviceAfterFieldUpdate(def, dev);
                            }
                        }
                    }
                }
                else if(dev.AC_Equip_Type__c == 'Non-Inverter')
                {
                    for(DER_Default__c def : (List<DER_Default__c>)derDefaults)    
                    {
                        if(def.Equip_Non_Inverter__c == true && (def.Offer_Neg_0__c == true || def.Offer_Neg_5__c == true))
                        {
                            
                            if(def.Object__c == 'Device__c')
                            {
                                getDeviceAfterFieldUpdate(def, dev);
                            }
                        }
                    }
                }
              
            }
            
        }
       
    }

    public static DER_Application__c blankOutDerAppFields(DER_Application__c derApp,List<DER_Default__c> derDefaults)
    {
        for(DER_Default__c def : derDefaults)
        {
            if(def.Object__c == 'DER_Application__c')
            {
                derApp.put(def.Field__c,null);
            }
        }
        return derApp;
    }

    public static Device__c blankOutDeviceFields(Device__c dev,List<DER_Default__c> derDefaults)
    {
        for(DER_Default__c def : derDefaults)
        {
            if(def.Object__c == 'Device__c')
            {
                dev.put(def.Field__c,null);
            }
        }
        return dev;
    }
    
    public static DER_Application__c getDerAppAfterFieldUpdate(DER_Default__c def,DER_Application__c derApp)
    {
        Schema.DescribeFieldResult f = r.fields.getMap().get(def.Field__c).getDescribe();
        
        if(f.getType() == Schema.DisplayType.Boolean)
        {
            derApp.put(def.Field__c, Boolean.valueOf(def.Value__c) );  
        }
        else if(f.getType() == Schema.DisplayType.Double)
        {
            derApp.put(def.Field__c, Double.valueOf(def.Value__c) );
        }
        else if (f.getType() == Schema.DisplayType.Integer)
        {
            derApp.put(def.Field__c, Integer.valueOf(def.Value__c) );
        }       
        else if (f.getType() == Schema.DisplayType.String)
        {
            derApp.put(def.Field__c, String.valueOf(def.Value__c) );
        }  
        else if (f.getType() == Schema.DisplayType.Picklist)
        {
            derApp.put(def.Field__c, String.valueOf(def.Value__c) );
        }  
        else
        {
            derApp.put(def.Field__c, Decimal.valueOf(def.Value__c) );
        }
        return derApp;
    }
    
    public static Device__c getDeviceAfterFieldUpdate(DER_Default__c def,Device__c device)
    {
        Schema.DescribeFieldResult f = r1.fields.getMap().get(def.Field__c).getDescribe();
        if(f.getType() == Schema.DisplayType.Boolean)
        {
            device.put(def.Field__c, Boolean.valueOf(def.Value__c) );  
        }
        else if(f.getType() == Schema.DisplayType.Double)
        {
            device.put(def.Field__c, Double.valueOf(def.Value__c) );
        }
        else if (f.getType() == Schema.DisplayType.Integer)
        {
            device.put(def.Field__c, Integer.valueOf(def.Value__c) );
        }       
        else if (f.getType() == Schema.DisplayType.String)
        {
            device.put(def.Field__c, String.valueOf(def.Value__c) );
        } 
        else if (f.getType() == Schema.DisplayType.Picklist)
        {
            device.put(def.Field__c, String.valueOf(def.Value__c) );
        } 
        else
        {
            device.put(def.Field__c, Decimal.valueOf(def.Value__c) );
        }
        return device;
    }
}