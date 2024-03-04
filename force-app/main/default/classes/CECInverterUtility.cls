global without sharing class CECInverterUtility implements Database.Batchable<sObject>,Database.AllowsCallouts{

    public CECInverterUtility() {

    }



    public void getInverters(){
        try {

            Auth.JWT jwt = new Auth.JWT();
            jwt.setSub('4013bde4-a2b8-408a-a762-bba6cc621123'); 
            // jwt.setAud('https://login.microsoftonline.com/ausnetservices.com.au/v2.0');
            jwt.setAud('https://login.microsoftonline.com/ausnetservices.com.au');
            jwt.setIss('4013bde4-a2b8-408a-a762-bba6cc621123');
            jwt.setValidityLength(Math.round(3600 + System.now().millisecond()/1000));
            
            //Additional claims to set scope
            // Map<String, Object> claims = new Map<String, Object>();
            // claims.put('scope', 'api://2b43e708-7ad4-4bfa-998a-de8917bea9d9/.default');
            // claims.put('grant_type', 'client_credentials');
            // claims.put('client_id', '4013bde4-a2b8-408a-a762-bba6cc621123');
            // claims.put('client_assertion_type', 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer');
                
            // jwt.setAdditionalClaims(claims);
    
            //Create the object that signs the JWT bearer token
            Auth.JWS jws = new Auth.JWS(jwt, 'salesforce_nonprod');
            
            //Get the resulting JWS in case debugging is required
            String token = jws.getCompactSerialization();
            
            //Set the token endpoint that the JWT bearer token is posted to
            // String tokenEndpoint = 'https://login.microsoftonline.com/ausnetservices.com.au/v2.0/oauth2/token';
            String tokenEndpoint = 'https://login.microsoftonline.com/v2.0/oauth2/token';
            
            //POST the JWT bearer token
            Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws);
            // bearer.setGrantType('client_credentials');

            System.debug('@bearer\n'+JSON.serializePretty(bearer));

            System.debug('@bearer.getHttpResponse():'+bearer.getHttpResponse());

            //Get the access token
            String accessToken = bearer.getAccessToken();
            
            // HttpRequest httpReq = new HttpRequest();
            // httpReq.setEndpoint('https://stg-gw.apin.ausnetservices.com.au/cec/CECSolarToolInverter');
            // httpReq.setMethod('GET');
            // httpReq.setHeader('Accept', '*/*');
            // httpReq.setHeader('Content-Type', 'application/json');
            // httpReq.setHeader('Bearer', accessToken);
            // // httpReq.setClientCertificateName('salesforce_nonprod');

            // HTTP http = new HTTP();
            // HttpResponse response = http.send(httpReq);

            // System.debug('@getBody():\n'+response.getBody());

            // if (response.getStatusCode() != 200) {
            //     // error state
            //     // integrationlog(responseResult,'getInverters',null,'GET');
            //     return;
            // } 
            // else {
            //     // integrationLogSuccess(null,'getInverters',null,'GET');
            // }
        }
        catch(Exception ex) {

            String exceptionResult = ex.getMessage()+'\n'+ex.getStackTraceString()+'\n'+ex.getLineNumber();
            System.debug(LoggingLevel.ERROR, 'Exception getInverters:\n'+exceptionResult);
        }
    }
    
    
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        System.debug('>>>> execute ' + scope.size());
        Boolean result;
        List<Object> inverterLst = new List<Object>();
        try{
            System.debug('>>>> Execute ');
            // Get the recs that already exist in MDT... 
          //  String query = 'SELECT DeveloperName, MasterLabel, Inverter_Type__c,CEC_ID__c,DRED_Enabled__c, Requested__c,Approved__c,EAI_Ref__c,EAI_Type__c, SID__c,InverterMfr__c, InverterModel__c  from CEC_Inverters__mdt';
          //  if(Test.isRunningTest()){
          //      query = 'SELECT DeveloperName, MasterLabel, Inverter_Type__c,CEC_ID__c,DRED_Enabled__c, Requested__c,Approved__c,EAI_Ref__c,EAI_Type__c, SID__c,InverterMfr__c, InverterModel__c  from CEC_Inverters__mdt limit 199';
          //  }
          //  List<CEC_Inverters__mdt> selRecs = (List<CEC_Inverters__mdt>)Database.query(query);
          //  System.debug('>>>> Execute ::: ' + selRecs.size());
            // Establish connection to Clean Energy. and get the List.
            inverterLst = fetchInverters(); 
            if(inverterLst!=null){
                // Iterate through the list. Do duplicate check and insert into CEC_Inverters__mdt.
            //    result = deleteCECInvertersMDT(inverterLst,  selRecs);
            //    result = insertIntoCECInvertersMDT(inverterLst,  selRecs);
                /*    if(Test.isRunningTest()){
                    throw new StringException('Invalid Value');
                } */
            }
            
            List<CECInverter__c> cecRecs = (List<CECInverter__c>)scope;
            if(inverterLst!=null){
                // Iterate through the list. Do duplicate check and insert into CECInverters__c.
                result = deleteAndInsertCECInverters(inverterLst,  cecRecs);
                
                
            }
        }
        catch(Exception e){
            /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {'salesforce.support@ausnetservices.com.au'};
                mail.setToAddresses(toAddresses);
            mail.setSubject('Invoking mytestbatch ' );
            mail.setSenderDisplayName('Inverters Batch Processing Exception occurred ');
            //You can add more detail about error from Exception object
            String mailBody = 'In execute insert result is ' + String.valueOf(result);
            mailBody = mailBody + '\n The input list size is ' + scope.size() ;
            mailBody = mailBody + '\n Exception Details : ' + e.getStackTraceString() + ' \n' + e.getCause();
            mail.setPlainTextBody(mailBody);
            
            Messaging.sendEmail(new Messaging.SingleemailMessage[] { mail });
            system.debug('cause::'+e.getCause());
			system.debug('message::'+e.getMessage());
            system.debug('line::'+e.getLineNumber());
            system.debug('stack::'+e.getStackTraceString());
            //     throw e;
     */   }
        System.debug('>>>> execute ' + String.valueOf(result));     
      //  System.debug('>>>> execute ' + String.valueOf(inverterLst));
        System.debug('>>>> execute ' + inverterLst.size());
    }
    
    global Database.Querylocator start(Database.BatchableContext bc){
        System.debug('>>>> start ' );
        
        // Get the recs that already exist in MDT... 
     //   String query = 'SELECT DeveloperName, MasterLabel, Inverter_Type__c,InverterMfr__c, InverterModel__c,  CEC_ID__c,DRED_Enabled__c, Requested__c,Approved__c,EAI_Ref__c,EAI_Type__c, SID__c,	InverterCapacity__c,AC_DC_Coupling__c  from CEC_Inverters__mdt limit 1';
     //   if(Test.isRunningTest()){
     //       query = 'SELECT DeveloperName, MasterLabel, Inverter_Type__c,InverterMfr__c, InverterModel__c,  CEC_ID__c,DRED_Enabled__c, Requested__c,Approved__c,EAI_Ref__c,EAI_Type__c, SID__c,	InverterCapacity__c,AC_DC_Coupling__c  from CEC_Inverters__mdt limit 199';
     //   }

        


// Radhika     
		String query = UtilDatabase.getAllFields('CECInverter__c'); 
        if(Test.isRunningTest()){   
        	query += ' FROM CECInverter__c LIMIT 10' ;
         }
        else
            query += ' FROM CECInverter__c' ;
        
        return Database.getQueryLocator(query);
    } 
    
    // The batch job finishes
    global void finish(Database.BatchableContext bc){
/*        String [] email = new String[] {'salesforce.support@ausnetservices.com.au'};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        // Below code will fetch the job Id
        AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors,
                          a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById,
                          a.CompletedDate From AsyncApexJob a WHERE id = :bc.getJobId()];
        
        // get the job Id
        System.debug('$$$ Finish Jobid is'+bc.getJobId());
        
        // below code will send an email to User about the status
        mail.setToAddresses(email);
        mail.setReplyTo('salesforce.support@ausnetservices.com.au'); // Add here your email address
        mail.setSenderDisplayName('Inverters Batch Processing ');
        mail.setSubject('Batch Processing '+a.Status);
        mail.setPlainTextBody('The Batch Apex job processed. $$$ Jobid is'+bc.getJobId()+ '  ' + a.TotalJobItems+'batches with '+a.NumberOfErrors+'failures'+'Job Item processed are'+a.JobItemsProcessed);
        Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
 */   }
    
    public List<Object> fetchInverters() {
        
        List<Object> invertersLst = new List<Object>();
        // CEC integration....
         try {
            HTTP http = new HTTP();
            
            String reqBody = '';
         
            CleanEnergyListSet__c customSett = 	CleanEnergyListSet__c.getValues('cec');
            System.debug('CustomSett'+customSett.endpoint__c);
            HttpRequest httpReq = new HttpRequest();
           //  httpReq.setEndpoint('https://prd-gw.apip.ausnetservices.com.au/cec/CECSolarToolInverter');
           httpReq.setEndpoint(customSett.endpoint__c);
           // string username = 'SalesforceUser';
           // string password='T@ssiedevil01';
            
            Blob headerValue = Blob.valueOf(customSett.username__c + ':' + customSett.password__c);
            String authHeader =  'Basic ' + EncodingUtil.base64Encode(headerValue);
             
            httpReq.setMethod('GET');
            httpReq.setHeader('Accept', '*/*');
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setHeader('Authorization', authHeader);
          
            string methodname = 'fetchInverters';
            string mapdetails = ''; 
            string operation = 'Create';
            HttpResponse response = http.send(httpReq);
            if (response.getStatusCode() != 200) {

                String responseResult = response.getStatusCode() + ' and status ' + response.getStatus() + ' and body ' + response.getBody();
                System.debug('AMDER CEC list Response endpoint'+ httpReq.getEndpoint());
                System.debug('AMDER EC list Response status code returned was not expected: '+responseResult);
                //outMap.put('httpTokenResponseError',JSON.deserializeUntyped(response.getBody()));
                FnP_ExtUserObjAccessUtility.integrationlog(responseResult,'SolarFormRecordType',methodname,mapdetails,operation);
                return null;
            } else {

                System.debug('AMDER CEC list No Error Line 1' + response.getBody());
                System.debug('AMDER CEC List No Error Line 2' + response.getHeaderKeys());
                if(response.getBody().contains('inverter') ){
            		System.debug('inverters is fetched');
                    Map<String,Object> resp = new Map<String,Object>();
                    List<Object> inverters = new List<Object>();
                    resp = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                    resp = (Map<String,Object>)resp.get('response');
                    invertersLst = (List<Object>)resp.get('inverter');
                    System.debug('inverters size fetched ::'+invertersLst.size());
                    
        		}
                
                 
            }
        } catch(Exception ex) {

            String exceptionResult = ex.getMessage()+'\n'+ex.getStackTraceString()+'\n'+ex.getLineNumber();
            System.debug(LoggingLevel.ERROR, 'Exception fetchInverters:\n'+exceptionResult);
            
            
            FnP_ExtUserObjAccessUtility.integrationlog(exceptionResult,'SolarFormRecordType','fetchInverters','','Create');
        }
       
        return invertersLst;
    }
    
 /*   global Boolean insertIntoCECInvertersMDT(List<Object> inverterLst,List<CEC_Inverters__mdt> selRecs){
        Boolean result = true;
        List<CEC_Inverters__mdt> insertData = new List<CEC_Inverters__mdt>();
        Map<String, CEC_Inverters__mdt> insertDataMap = new Map<String, CEC_Inverters__mdt>();
        List<CEC_Inverters__mdt> newlist = new List<CEC_Inverters__mdt>();
        CEC_Inverters__mdt insertRec = new CEC_Inverters__mdt();
        System.debug('>>>> insertIntoCECInvertersMDT selRecs.size()' + selRecs.size());
        System.debug('>>>> insertIntoCECInvertersMDT inverterLst.size()' + inverterLst.size());
        // Iterate through the  input. 
        for(Object inv : inverterLst){
            
            insertRec = new CEC_Inverters__mdt();
            //Map<String, Object> inverter = (Map<String, Object>)inv;
            Map<String, Object> inverter = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(inv));
            
            // Populate insertData structure.
            
            // An inverter can be both solar and battery. 
             // First check for solar or battery. let the current rec be for just solar or just battery
             // If both solar and battery , add a new rec for battery.
             //
            if((Integer)inverter.get('is_solar') == 1) {
                insertRec.DeveloperName = (String)inverter.get('inverter_number') + 'S' ; // This should be the unique number for matching.
            	insertRec.MasterLabel = (String)inverter.get('inverter_number') + 'S'; // This should be the unique number for matching.
                
                insertRec.Inverter_Type__c = 'Solar';
                insertRec.CEC_ID__c = (String) inverter.get('inverter_number');
            insertRec.DRED_Enabled__c =    'Yes';
            insertRec.Requested__c =      true;
            insertRec.Approved__c =      true;
            insertRec.EAI_Ref__c =      (String)inverter.get('inverter_number');
            insertRec.EAI_Type__c =       'Device_L2';
            insertRec.SID__c =       (String)inverter.get('inverter_number');
            insertRec.InverterMfr__c = (String)inverter.get('manufacturer');
            insertRec.InverterModel__c = (String)inverter.get('model_number'); 
            Set<CEC_Inverters__mdt> setselRecs = new Set<CEC_Inverters__mdt>(selRecs);
            insertRec.InverterCapacity__c = (Decimal.valueOf(((Double)inverter.get('rated_apparent_va'))/1000)).SetScale(2);
            insertRec.AC_DC_Coupling__c = 'AC';
            newlist.add(insertRec);
            insertData.add(insertRec);
            insertDataMap.put(insertRec.DeveloperName,insertRec);
            }
            
            
            if((Integer)inverter.get('is_battery') == 1) {
                insertRec = new CEC_Inverters__mdt();
                insertRec.DeveloperName = (String)inverter.get('inverter_number') +'B' ; // This should be the unique number for matching.
            insertRec.MasterLabel = (String)inverter.get('inverter_number') +'B'; // This should be the unique number for matching.
                
                insertRec.Inverter_Type__c = 'Battery';
            
                
                insertRec.DeveloperName = (String)inverter.get('inverter_number') + 'B'  ; // This should be the unique number for matching.
            	insertRec.MasterLabel = (String)inverter.get('inverter_number') +'B' ; // This should be the unique number for matching.
                insertRec.Inverter_Type__c = 'Battery';
                insertRec.CEC_ID__c = (String) inverter.get('inverter_number');
                insertRec.DRED_Enabled__c =    'Yes';
                insertRec.Requested__c =      true;
                insertRec.Approved__c =      true;
                insertRec.EAI_Ref__c =      (String)inverter.get('inverter_number');
                insertRec.EAI_Type__c =       'Device_L2';
                insertRec.SID__c =       (String)inverter.get('inverter_number');
                insertRec.InverterMfr__c = (String)inverter.get('manufacturer');
                insertRec.InverterModel__c = (String)inverter.get('model_number'); 
                insertRec.InverterCapacity__c = (Decimal.valueOf(((Double)inverter.get('rated_apparent_va'))/1000)).SetScale(2);
                insertRec.AC_DC_Coupling__c = 'AC';
                newlist.add(insertRec);    
               
                	insertData.add(insertRec);
                insertDataMap.put(insertRec.DeveloperName,insertRec);

            }
        }
        
  		
        
        try {
            
            updateAndDeployMetadata(insertDataMap);
          //  updateAndDeployMetadata(insertData);
            result = true;
        }
        catch(DmlException dmle) {
            string operation='Create';
            FnP_ExtUserObjAccessUtility.integrationlog(dmle.getMessage()+' '+dmle.getStackTraceString()+' '+dmle.getLineNumber(),'SolarFormRecordType','insertIntoCECInvertersMDT',JSON.serialize(insertData),operation);
            System.debug('An unexpected error has occurred: ' + dmle.getMessage());
            result = false;
            //   throw dmle;
        }
        
        return result;
    } 
*/
 /*   global Boolean deleteCECInvertersMDT(List<Object> inverterLst,List<CEC_Inverters__mdt> selRecs){
        Boolean result = true;
        try{
            System.debug('Before delete for loop:::'+selRecs.size());
            
            MetadataService.MetadataPort service = new  MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
        	service.SessionHeader.sessionId = UserInfo.getSessionId();
            MetadataService.DeleteResult [] results = new MetadataService.DeleteResult []{};
            List<String> recordsToDelete = new List<String>();
            Set<String> setRecs = new Set<String>();
            for(Object inv : inverterLst){
                Map<String, Object> setRec = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(inv));
                setRecs.add((String)setRec.get('inverter_number'));
            }
            
            
            String locCec = null;
            // Iterate through the  input. 
        	for(CEC_Inverters__mdt selrec : selRecs){

                locCec = null;
                locCec = (String)(selrec.get('CEC_ID__c'));
                
                
                locCec = locCec.substring(0, 11);
                
                
                if(setRecs.contains(locCec)){
                    System.debug('Record is present. no need to delete..' + locCec);
                    
                } else
                	recordsToDelete.add('CEC_Inverters__mdt.'+selrec.DeveloperName);
               	 
            	if(recordsToDelete.size()==200)
                {
                    System.debug('After delete for loop:::'+recordsToDelete.size());
                    results = service.deleteMetadata('CustomMetadata', recordsToDelete);
                    recordsToDelete = new List<String>();
                }
            }
            if(recordsToDelete.size()>0)
                {
                    System.debug('After delete for loop:::'+recordsToDelete.size());
                    results = service.deleteMetadata('CustomMetadata', recordsToDelete);
                   
                }
        }
        catch(Exception e){
            System.debug('Exception Occurred while deleting custom metadata records.. '+e.getMessage());
            result = false;
        }
        return result;
    } */

/*    private void updateAndDeployMetadata(Map<String, CEC_Inverters__mdt> insertLst) {
        // Setup custom metadata to be created in the subscriber org.
        Metadata.CustomMetadata customMetadata =  new Metadata.CustomMetadata();
        Metadata.CustomMetadataValue customField = new Metadata.CustomMetadataValue();
        Metadata.DeployContainer mdContainer = new Metadata.DeployContainer();
        Integer count = 0;
        
        for(String cecid : insertLst.keySet()){
            CEC_Inverters__mdt insertRec = (CEC_Inverters__mdt)insertLst.get(cecid);
            
            customMetadata =  new Metadata.CustomMetadata();
            customMetadata.fullName = 'CEC_Inverters__mdt.'+insertRec.DeveloperName ;
          //  customMetadata.fullName = insertRec.DeveloperName ;
            customMetadata.label = insertRec.MasterLabel;
            
            //1
            
            //2
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'InverterMfr__c';
            customField.value = insertRec.InverterMfr__c;    
            customMetadata.values.add(customField);
            //3
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'InverterModel__c';
            customField.value = insertRec.InverterModel__c;    
            customMetadata.values.add(customField);
            //4
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'CEC_ID__c';
            customField.value = insertRec.CEC_ID__c;    
            customMetadata.values.add(customField);
            //5
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'Approved__c';
            customField.value = insertRec.Approved__c;    
            customMetadata.values.add(customField);
            //6
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'DRED_Enabled__c';
            customField.value = insertRec.DRED_Enabled__c;    
            customMetadata.values.add(customField);
            //7
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'EAI_Ref__c';
            customField.value = insertRec.EAI_Ref__c;    
            customMetadata.values.add(customField);
            //8
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'EAI_Type__c';
            customField.value = insertRec.EAI_Type__c;    
            customMetadata.values.add(customField);
            //9
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'Inverter_Type__c';
            customField.value = insertRec.Inverter_Type__c;    
            customMetadata.values.add(customField);
            //10
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'InverterCapacity__c';
            customField.value = insertRec.InverterCapacity__c;    
            customMetadata.values.add(customField);
            //11
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'Requested__c';
            customField.value = insertRec.Requested__c;    
            customMetadata.values.add(customField);
            //12
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'SID__c';
            customField.value = insertRec.SID__c;    
            customMetadata.values.add(customField);
            //13
            customField = new Metadata.CustomMetadataValue();
            customField.field = 'AC_DC_Coupling__c';
            customField.value = insertRec.AC_DC_Coupling__c;    
            customMetadata.values.add(customField);
            
            mdContainer.addMetadata(customMetadata);   
            count++;
            
           
        } 
        
                try{
                   FnP_SolarFormUtilityExt callback = new FnP_SolarFormUtilityExt();
                    
                    
                    // Enqueue custom metadata deployment
                    Id deployRequestId;
                    if (!Test.isRunningTest()) {
                        deployRequestId = Metadata.Operations.enqueueDeployment(mdContainer, callback);
                      //  FnP_ExtUserObjAccessUtility.integrationLogSuccess(deployRequestId,deployRequestId,'SolarFormRecordType','updateAndDeployMetadata',JSON.serialize(mdContainer),'Create');
                    } 
                    
                }
                catch(Exception ex){
                    string operation='Update';
                    System.debug('Metadata deployment exception...'+ex.getMessage());
                    FnP_ExtUserObjAccessUtility.integrationlog(ex.getMessage()+' '+ex.getStackTraceString()+' '+ex.getLineNumber(),'SolarFormRecordType','updateAndDeployMetadata',JSON.serialize(mdContainer),operation);
                }
   	} */
   
    global Boolean deleteAndInsertCECInverters(List<Object> inverterLst,List<CECInverter__c> selRecs){
        Boolean result = true;
        try{
            System.debug('Before delete for loop:::'+selRecs.size());
            
            
            List<CECInverter__c> recordsToDelete = new List<CECInverter__c>();
            Set<String> setRecs = new Set<String>();
            List<CECInverter__c> invRecs = new List<CECInverter__c>();
            CECInverter__c insertRec = new CECInverter__c ();
            Map<String, Object> inverter = new Map<String, Object>();
            for(Object inv : inverterLst){
                inverter = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(inv));
				if((Integer)inverter.get('is_solar') == 1) {
                    insertRec = new CECInverter__c ();
                    insertRec.AC_DC_Coupling__c = 'AC';
                    insertRec.AC_Equip_Type__c = 'Inverter';
                    insertRec.APPROVAL_DATE__c = '';
                    insertRec.Approved__c =      true;
                    insertRec.CEC_APPROVED_DATE__c = '';
                    insertRec.CEC_ID__c = (String)inverter.get('inverter_number') ;
                    insertRec.Name = (String)inverter.get('inverter_number') + 'S' ;
                    insertRec.CERT_ID__c = '';
                    insertRec.CERT_NUMBER__c = '';
                    insertRec.EAI_Ref__c =      (String)inverter.get('inverter_number');
                    insertRec.EAI_Type__c =       'Device_L2';
                    insertRec.EXPIRY_DATE__c = '';
                    insertRec.INVERTER_ID__c = 0;
                    insertRec.INVERTER_NUMBER__c = '';
                    insertRec.Inverter_Type__c = 'Solar';
                    insertRec.InverterCapacity__c = (Decimal.valueOf(((Double)inverter.get('rated_apparent_va'))/1000)).SetScale(2);
                    insertRec.InverterMfr__c = (String)inverter.get('manufacturer');
                    insertRec.InverterModel__c = (String)inverter.get('model_number'); 
                    insertRec.IS_BATTERY__c = (Integer)inverter.get('is_battery');
                    insertRec.IS_DISABLED__c = 0;
                    insertRec.IS_SOLAR__c = (Integer)inverter.get('is_solar');
                    insertRec.NOMINAL_AC_POWER__c = (Double)inverter.get('rated_apparent_va');
                    insertRec.Phase__c = 0;
                    insertRec.SID__c =       (String)inverter.get('inverter_number');
                    setRecs.add(insertRec.Name);
                    invRecs.add(insertRec);
           		}
            
            
               if((Integer)inverter.get('is_battery') == 1) {
                   insertRec = new CECInverter__c();
                   insertRec.AC_DC_Coupling__c = 'AC';
                   insertRec.AC_Equip_Type__c = 'Inverter';
                   insertRec.APPROVAL_DATE__c = '';
                   insertRec.Approved__c =      true;
                   insertRec.CEC_APPROVED_DATE__c = '';
                   insertRec.CEC_ID__c = (String)inverter.get('inverter_number') ;
                   insertRec.Name = (String)inverter.get('inverter_number') + 'B' ;
                   insertRec.CERT_ID__c = '';
                   insertRec.CERT_NUMBER__c = '';
                   insertRec.EAI_Ref__c =      (String)inverter.get('inverter_number');
                   insertRec.EAI_Type__c =       'Device_L2';
                   insertRec.EXPIRY_DATE__c = '';
                   insertRec.INVERTER_ID__c = 0;
                   insertRec.INVERTER_NUMBER__c = '';
                   insertRec.Inverter_Type__c = 'Battery';
                   insertRec.InverterCapacity__c = (Decimal.valueOf(((Double)inverter.get('rated_apparent_va'))/1000)).SetScale(2);
                   insertRec.InverterMfr__c = (String)inverter.get('manufacturer');
                   insertRec.InverterModel__c = (String)inverter.get('model_number'); 
                   insertRec.IS_BATTERY__c = (Integer)inverter.get('is_battery');
                   insertRec.IS_DISABLED__c = 0;
                   insertRec.IS_SOLAR__c = (Integer)inverter.get('is_solar');
                   insertRec.NOMINAL_AC_POWER__c = (Double)inverter.get('rated_apparent_va');
                   insertRec.Phase__c = 0;
                   insertRec.SID__c =       (String)inverter.get('inverter_number');
                   setRecs.add(insertRec.Name);
                   invRecs.add(insertRec);
                }
            }
            
            
            // Iterate through the  records already existing in object. check if it exists in new list. 
        	for(CECInverter__c selrec : selRecs){
                if(setRecs.contains(selrec.Name)){ // Check if database record present in new list. check for the inverter number.
                //    System.debug('Record is present with no change. no need to delete..' + selrec);
                    
                } else{
                    System.debug('Record is not present. need to delete..' + selrec);
                	recordsToDelete.add(selrec);
                }
               	 
            	
            }
            
            if(recordsToDelete.size()>0)
                {
                    System.debug('Now delete :::'+recordsToDelete.size());
                    //delete recordsToDelete;
                   
                }
            
            // Upsert invRecs thats it..
            if(invRecs.size() >0){
                Integer createdcnt =0 ;
                Integer updatedcnt = 0;
                System.debug('After delete, upsert:::'+invRecs.size());
                Database.UpsertResult[] results = Database.upsert(invRecs, CECInverter__c.Name);
                for(Integer index = 0, size = results.size(); index < size; index++) {
                    if(results[index].isSuccess()) {
                        if(results[index].isCreated()) {
                        	createdcnt++;    
                        } else {
                        	updatedcnt++;
                        }
    			}
                    
}
                System.debug('Created :: '+createdcnt);
                    System.debug('Update :: '+updatedcnt);
            }
        }
        catch(Exception e){
            System.debug('Exception Occurred while upserting/deleting records.. '+e.getMessage());
            result = false;
        }
        return result;
    }
}