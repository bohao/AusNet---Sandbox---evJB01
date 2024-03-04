global without sharing class FnP_ExtUserObjAccessUtility implements vlocity_cmt.VlocityOpenInterface {
    public static string workTaskId ='workTaskId';
	public static string sobjectData ='sobjectData';
    public static string getRecordData = 'getRecordData';
	public static string upsertRecordData = 'upsertRecordData';
	public static string sObjectFieldLst = 'sObjectFieldLst';
	public static string orderBy = 'orderBy';
	public static string querylimit = 'querylimit';
	public static string sobjectApiName = 'sobjectApiName';
	public static string strQuery = 'SELECT Id';
	public static string strFrm = 'FROM ';
	public static string strComma = ' , ';
	public static string strWhereCondition = 'whereCondition';
	public static string strSpace = ' ';
	public static string objRecordTypeId = 'objRecordTypeId';
	public static string dateRegex = '[0-9]{4}-[0-9]{0,2}-[0-9]{0,2}';
	public static string erroMsg = 'Error Message: ';
    public static string nextLineStr = '\n';

	global static Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
        string recordId;
        try
        {
            if (methodName.equals('getRecordData')){
                getRecordData(inputMap,outMap,options);
            }
			else if (methodName.equals('upsertRecordData')){
                SObject sObjRecord = upsertRecordData(inputMap,outMap,options);
                recordId=(String)sObjRecord.Id;
                integrationLogSuccess(sObjRecord.Id,JSON.serialize(sObjRecord),'ElectricalFormRecordType','upsertRecordData',JSON.serialize(inputMap),'Create');
                outMap.put('Id',sObjRecord.Id);    
            }
            else if (methodName.equals('insertIntegrationlog')){
                insertIntegrationlog(inputMap,outMap,options);
            }
        }
        catch(Exception excep)
        {
            System.debug('ExtUserWTAccessUtility:invokeMethod -> exception: '+excep);
            System.debug('linenumber -> exception: '+excep.getLinenumber());
            System.debug('recordId: '+recordId);
            // Prepare a response body and set the output. 
            String exceptionResult = excep.getMessage()+'\n'+excep.getStackTraceString()+'\n'+excep.getLineNumber();
            System.debug(LoggingLevel.ERROR, 'Exception upsertRecordData :\n'+exceptionResult);
            String recType = (methodName.equals('insertIntegrationlog')?'SolarFormRecordType':'ElectricalFormRecordType');
            
            integrationlog(exceptionResult,recType, methodName,JSON.serialize(inputMap), 'Create');
            if(recordId==null){
                outMap.put('DMLError',exceptionResult); 
            } 
        }
        return result;
    }

    public static void getRecordData(Map<String, Object> inputMap,Map<String, Object> outMap,Map<String, Object> options) {
        
        System.debug('inputMap1'+inputMap);
        System.debug('outMap1'+outMap);
        System.debug('options1'+options);
        Map<String, Object> fieldValueMap = new Map<String, Object>();
		List<Object> lstfieldMapping = new List<Object>();
		
        if(inputMap.containsKey(sObjectFieldLst)){
            String query;
			lstfieldMapping = (List<Object>)inputMap.get(sObjectFieldLst);
			
			fieldValueMap = getFieldValues(lstfieldMapping);
			system.debug('fieldValues map '+fieldValueMap);
			
			query = strQuery;
			
			//Query record fields
			if(fieldValueMap != null && !fieldValueMap.isEmpty()){
				query+=strComma;
				for(String fieldName : fieldValueMap.keySet()){
					query+=((String)fieldValueMap.get(fieldName)) + strComma;
				}
                query = query.removeEnd(strComma) + strSpace;
			}
			
			query+= strFrm +(String)inputMap.get(sobjectApiName);
			
			//where condition
			if(inputMap.containsKey(strWhereCondition)){
				query+= strSpace + (String)inputMap.get(strWhereCondition);
			}
			
			//orderBy condition
			if(inputMap.containsKey(orderBy)){
				query+= strSpace + (String)inputMap.get(orderBy);
			}
			
			//limit value
			if(inputMap.containsKey(querylimit)){
				query+= strSpace + (String)inputMap.get(querylimit);
			}
			
            if(String.isNOTBlank(query)){
                system.debug('str Query '+query);
                outMap.put(sobjectData,Database.query(query)); //NOPMD
            }
        }
    }
	
	public static SObject upsertRecordData(Map<String, Object> inputMap,Map<String, Object> outMap,Map<String, Object> options) {

        System.debug('inputMap2'+inputMap);
        System.debug('outMap2'+outMap);
        System.debug('options2'+options);  
        
        double paymentamt;
        List<Object> lstfieldMapping = new List<Object>();
        sObject sObjRecord;
        String objectName = (String)inputMap.get(sobjectApiName);
        Pattern datePattern = Pattern.compile(dateRegex);
			 System.debug('(Id)inputMap.get(objRecordTypeId)'+(Id)inputMap.get(objRecordTypeId));
        if(inputMap.containsKey(objRecordTypeId)){
           System.debug('RecordType input is present');
            sObjRecord = Schema.getGlobalDescribe().get(objectName).newSObject((Id)inputMap.get(objRecordTypeId), true);
        }
        else {
            System.debug('Taking default RT');
            sObjRecord = Schema.getGlobalDescribe().get(objectName).newSObject();
        }	
        
        if(inputMap.containsKey(sObjectFieldLst)) {

            lstfieldMapping = (List<Object>)inputMap.get(sObjectFieldLst);
            Map<String, Object> fieldValueMap = new Map<String, Object>();
            fieldValueMap = getFieldValues(lstfieldMapping);
        
            //Upsert sObject Data
            if(fieldValueMap != null && !fieldValueMap.isEmpty()){
                for(String fieldName : fieldValueMap.keySet()){
                    if(String.ValueOf(fieldValueMap.get(fieldName)) != ''){
                        
                        Matcher matchDate = datePattern.matcher(String.ValueOf(fieldValueMap.get(fieldName)));
                        //   Matcher matchNum = numPattern.matcher(String.ValueOf(fieldValueMap.get(fieldName)));
                        //   system.debug('str Match num val  :: '+ fieldName + '::' + matchNum.matches() );
                        if(matchDate.matches() == true){
                            Date dateValue = Date.ValueOf((String)fieldValueMap.get(fieldName));
                            sObjRecord.put(fieldName, dateValue);
                        }
                        else {
                            System.debug('str Exception  :: '+ fieldName + '::' + fieldValueMap.get(fieldName) );
                            try {
                                sObjRecord.put(fieldName, fieldValueMap.get(fieldName));
                            } catch(Exception e){
                                system.debug('Exception e----->'+ fieldName + '::' + e.getStackTraceString());
                                sObjRecord.put(fieldName, Integer.valueOf(fieldValueMap.get(fieldName)));
                                
                            }
                        }
                    }
                    else {
                        System.debug('Field doesnt have value: ' + fieldName);
                    }
                }
                
                if(sObjRecord != null) {
                    upsert sObjRecord;
                }
            }
        }
        
        return sObjRecord;
    }
	
	//dynamic field values map
	public static Map<String,Object> getFieldValues(List<Object> lstfieldMapping){
        
        System.debug('lstfieldMapping'+lstfieldMapping);
		Map<String,Object> fieldValuesMap = new Map<String,Object>();
		if(!lstfieldMapping.isEmpty()){
			Set<String> keySet = new Set<String>();
			Map<String,Object> listMap = new Map<String,Object>();
			for(Object listobj:lstfieldMapping){
                // Listobj.PaymentAmount__c='';
				Map<String,Object> listMapKey = (Map<String, Object>)listobj;
				// String payAmtStr = (String)listMapKey.get('PaymentAmount__c');
				listMap.putall(listMapKey);
				keySet.addAll(listMapKey.keySet());
			}
			if(!keySet.isEmpty()) {
				for(String keyVal:keySet){
					System.debug('keyHeader '+keyVal);
					System.debug('headerValue '+listMap.get(keyVal));
					fieldValuesMap.put(keyVal,listMap.get(keyVal));
                    System.debug('fieldValuesMap###'+fieldValuesMap.values());
				}
			}
            for (String paymentAmount: fieldValuesMap.keyset()){
                System.debug('test'+fieldValuesMap.get(paymentAmount));
            }
		}
		
		return fieldValuesMap;
	}
    
    
    public static void insertIntegrationlog(Map<String, Object> inputMap,Map<String, Object> outMap,Map<String, Object> options) {
        /*
         *  "rec": "%amderAssessmentRequest:sales_force_id%",
            "res": "%PayloadResponse%",
            "recType": "SolarFormRecordType",
            "methodName": "IP_FnP_SendDeviceDetailsToAmder",
            "mapDetails": "%amderAssessmentRequest%",
            "operation": "CREATE"
         */
        System.debug('inputMap1'+inputMap);
        System.debug('inputMap.containsKey(inputMap)'+inputMap.containsKey('inputMap'));
        if(inputMap.containsKey('inputMap') ){
            Map<String, Object> inpmapdetails = (Map<String, Object>) inputMap.get('inputMap');
            System.debug('inpmapdetails'+JSON.serializePretty(inpmapdetails));
        	if(inpmapdetails.containsKey('rec')){
                System.debug('success');
                // rec is populated for success logs.. so invoke success log.
                integrationLogSuccess(String.valueOf(inpmapdetails.get('rec')),String.valueOf(inpmapdetails.get('res')),String.valueOf(inpmapdetails.get('recType')),String.valueOf(inpmapdetails.get('methodName')),String.valueOf(inpmapdetails.get('mapDetails')),String.valueOf(inpmapdetails.get('operation')));
                
            }
            else{
                
                System.debug('failure');
                
                // rec is populated for success logs.. so invoke failure log.
                integrationlog(String.valueOf(inpmapdetails.get('res')),String.valueOf(inpmapdetails.get('recType')),String.valueOf(inpmapdetails.get('methodname')),String.valueOf(inpmapdetails.get('mapdetails')),String.valueOf(inpmapdetails.get('operation')));
                
            }
        
    }
    }
    public static void integrationlog(string res,string recType , string methodname,string mapdetails,string operation) {
		System.debug('inputs:::'+'::'+operation+'::');
        Id recordtypeId = Schema.SObjectType.Integration_Log__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();
        //Integration Task & log insertion starts here//
        list<Integration_Task__c> integrationTasks = new list<Integration_Task__c>();
        Integration_Task__c intgTask = new Integration_Task__c();
        intgTask.Operation__c=operation;
        intgTask.Status__c='Failed';
        Integer maxLength = 131072;
        Integer reqBodyLength;
        switch on recType {
            when 'ElectricalFormRecordType' {
                intgTask.SObject__c='Project__c'; 
            }
            when 'SolarFormRecordType' {
                intgTask.SObject__c='DER_Application__c'; 
            }
        }
        
        intgTask.type__c=methodname;
        integrationTasks.add(intgTask);

        insert integrationTasks;

        list<Integration_Log__c> loglist= new list<Integration_Log__c>();
        for(Integration_Task__c Task:integrationTasks) {

            Integration_Log__c log= new Integration_Log__c();
            log.Integration_Task__c=Task.id;
            log.Type__c=Task.Type__c;
            switch on recType {
                when 'ElectricalFormRecordType' {
                    log.Application_Type__c ='Electrical Form';
                }
                when 'SolarFormRecordType' {
                    log.Application_Type__c ='Solar Form';
                }
            }

         //   log.RecordTypeId=recordtypeId;
            log.Status__c=Task.Status__c;
            log.ReqBody__c=mapdetails;
            reqBodyLength = mapDetails.length();
            System.debug('Request body length::::'+reqBodyLength);
            
            /* Added to test no success log creation on salesforce: start */
            log.ReqBody__c = mapDetails.length() > maxLength ? mapDetails.substring(0, maxLength) : mapDetails;
            if(res!=null & res!=''){
            log.Error_Message__c = res.length() > maxLength ? res.substring(0, maxLength) : res;
        }
            log.Error_Message__c=res;
            loglist.add(log);
        }

        insert loglist;
    } 

    public static void integrationLogSuccess(string rec, string res,string recType , string methodName,string mapDetails,string operation) {

        Id recordtypeId=Schema.SObjectType.Integration_Log__c.getRecordTypeInfosByName().get(recType).getRecordTypeId();
        //Integration Task & log insertion starts here//
        Integration_Task__c intgTask = new Integration_Task__c();
        intgTask.Operation__c=operation;
        intgTask.Status__c='Successful';
        intgTask.ParentId__c = rec;
        Integer maxLength = 131072;
        switch on recType {
            when 'ElectricalFormRecordType' {
                intgTask.SObject__c='Project__c'; 
            }
            when 'SolarFormRecordType' {
                intgTask.SObject__c='DER_Application__c'; 
            }
        }

        intgTask.type__c=methodname;
        insert intgTask;

        Integration_Log__c log= new Integration_Log__c();
        log.Integration_Task__c=intgTask.id;
        log.Type__c=intgTask.Type__c;

        switch on recType {
            when 'ElectricalFormRecordType' {
                log.Application_Type__c ='Electrical Form';
            }
            when 'SolarFormRecordType' {
                log.Application_Type__c ='Solar Form';
            }
        }
        
        log.RecordTypeId=recordtypeId;
        log.Status__c=intgTask.Status__c;
        //log.ReqBody__c=mapdetails;
        log.ReqBody__c = mapDetails.length() > maxLength ? mapDetails.substring(0, maxLength) : mapDetails;
        if(res!=null & res!=''){
            log.Error_Message__c = res.length() > maxLength ? res.substring(0, maxLength) : res;
        }
        //Integer reqBodyLength = mapDetails.length();
        //System.debug('Request body length::::'+reqBodyLength);
        log.Success_Json__c=res;
        log.Success_Id__c = rec;
        insert log;
    } 
}