global class FnP_SolarFormUtilityExt implements Metadata.DeployCallback, Schedulable {
    /* Below method recieves the 2 parameters 
       1 - Metadata.DeployResult => Object of MetadataContainer class where this method has been implemented.
       2 - Metadata.DeployCallbackContext => Object of the class where this method has been implemented
   */
    global void handleResult(Metadata.DeployResult result,
                             Metadata.DeployCallbackContext context) {
        if (result.status == Metadata.DeployStatus.Succeeded) {
            // Deployment was successful
            System.debug(' success : '+ result);
        } else {
            // Deployment was not successful
            System.debug(' failure : '+ result);
        }
    }
    
    // Write a schedulable batch job. Set up weekly schedule in settings
// https://www.xgeek.net/salesforce/writing-a-schedulable-batch-apex-in-salesforce/

    
    // Execute at regular intervals
    global void execute(SchedulableContext ctx){
      
      CECInverterUtility batch = new CECInverterUtility();
      Database.executebatch(batch, 200);
    }

}