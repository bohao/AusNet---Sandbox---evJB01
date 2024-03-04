global without sharing class FnP_TempBatchLoadHistAmderData implements Queueable , Database.Batchable<sObject>,Database.AllowsCallouts{

    Datetime [] passedDateTime = new List<Datetime>();
    Datetime [] failedDateTime = new List<Datetime>();
    
    Datetime startDT = Datetime.newInstance(2022,08,29,00,00,00);
    Datetime actualStartDT = Datetime.newInstance(2022,08,29,00,00,00);
    Datetime endDT = Date.today();
    public FnP_TempBatchLoadHistAmderData(Datetime startDate, Datetime endDate) {
        System.debug('In Constructor');
        if(startDate != null){
            System.debug('startDate is entered'+startDate);
            startDT = startDate;
            actualStartDT = startDate;
        }
        
        if(endDate != null){
            System.debug('End date is entered'+endDate);
            endDT = endDate;
        }
    }
 

    private void createDateTimeList()
    {
    //    Datetime startDT =  Datetime.newInstance(2022,08, 29,0,0,0);
        Map <String, Object> input = new Map <String, Object> ();
        try{
        for(Integer i=0; i<50;i++) {
            System.debug('startDT.isSameDay(Date.today()) :: '+startDT + ' :: ' +Date.today()+ ' :: ' +startDT.isSameDay(Date.today()));
            
            if(startDT.isSameDay(endDT) || startDT.isSameDay((Date.today()).addDays(1))) 
               {  break; }
               
            else if(i==49){
                System.debug('Set i to 0 again, to run for next 100 times'+startDT.addDays(1));
                
            }
            
   			
            startDT = startDT.addDays(1);
//            boolean result = invokeIP(startDT) ;
            
   			invokeIP(startDT, endDT) ;
            
            passedDateTime.add(startDT);
            failedDateTime.add(startDT);
            
		}
            
            input.put('processdate', actualStartDT);
            input.put('enddate', endDT);
         //   FnP_ExtUserObjAccessUtility.integrationLogSuccess(null,JSON.serialize(passedDateTime),'SolarFormRecordType','FnP_TempBatchLoadHistAmderData',JSON.serialize(input),'Update');
        }
        catch(Exception e){
            String exceptionResult = e.getMessage()+'\n'+e.getStackTraceString()+'\n'+e.getLineNumber();
            System.debug('Exception occurred in  ::FnP_TempBatchLoadHistAmderData'+exceptionResult);
            input.put('processdate', actualStartDT);
            input.put('enddate', endDT);
            FnP_ExtUserObjAccessUtility.integrationlog(exceptionResult,'SolarFormRecordType','FnP_TempBatchLoadHistAmderData',JSON.serialize(input),'Update');
        }
		system.debug('Values In Array: '+passedDateTime.size());
    }    

        private  void invokeIP(Datetime startDT, Datetime endDT){
            boolean result = false;
            String procedureName = 'IP_FnP_SendHistDeviceDetailsToAmder';
            Map <String, Object> ipInput = new Map <String, Object> ();
            Map <String, Object> ipOutput = new Map <String, Object> ();
            Map <String, Object> ipOptions = new Map <String, Object> ();
    
            /* Populating input map for an Integration Procedure. Follow whatever structure your VIP expects */
            
            ipInput.put('processdate', startDT);
            ipInput.put('enddate', startDT.addDays(1));
            
            
            System.debug('IP Input: ' + JSON.serializePretty(ipInput));
            
            /* Call the IP via runIntegrationService, and save the output to ipOutput */
            ipOutput = (Map <String, Object>) vlocity_cmt.IntegrationProcedureService.runIntegrationService(procedureName, ipInput, ipOptions);
            
            System.debug('IP Output: ' + ipOutput);
//            passedDateTime.add(startDT);
//            failedDateTime.add(startDT);
//            System.enqueueJob(new FnP_TempBatchLoadHistAmderData(startDT, endDT));
            
          //  return true;
    }

    global void execute(QueueableContext  ctx){
      
      FnP_TempBatchLoadHistAmderData batch = new FnP_TempBatchLoadHistAmderData(startDT, endDT);
      Database.executebatch(batch, 200);
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope){
        System.debug('>>>> execute ' + scope.size());
        createDateTimeList();
        Boolean result;

    }
    
    global Database.Querylocator start(Database.BatchableContext bc){
        System.debug('>>>> start ' );
        
        // Get the recs that already exist in MDT... 
        String query = 'SELECT DeveloperName, MasterLabel, Inverter_Type__c,InverterMfr__c, InverterModel__c,  CEC_ID__c,DRED_Enabled__c, Requested__c,Approved__c,EAI_Ref__c,EAI_Type__c, SID__c,	InverterCapacity__c  from CEC_Inverters__mdt limit 1';
        
        return Database.getQueryLocator(query);
    } 
    
    // The batch job finishes
    global void finish(Database.BatchableContext bc){
        
    }
}