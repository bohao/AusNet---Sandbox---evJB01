public class DER_updateSendOffer {
    public static Id manualRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('DER Application - Manual').getRecordTypeId();
    public static string DER_AGREEMENT_STATUS = 'Offer Expired';
    @AuraEnabled
    public static string updateOfferOnManualPage(string recId){
        Boolean isError = false;
        set<id> appId = new set<id>();
        string errorOccured ='';
        List<Case> csList = [Select id, recordTypeId, DER_Application__c, isClosed, 
                                Agreement_Type__c, DER_Offer_URL__c, Send_DER_Offer__c
                                from Case 
                                where id=:recId
                                and DER_Application__c <> null];
        
        if(csList.isEmpty()){
            errorOccured = errorOccured +'DER Application not found <br/>';
        }else{
            Case cs = csList[0];       

            DER_Application__c dr = [select id, (Select id from DER_Agreements__r where Status__c !=:DER_AGREEMENT_STATUS) 
                                                from DER_Application__c 
                                                where id =: cs.DER_Application__c];

            if(cs.recordTypeId != manualRecordTypeId){
                    errorOccured = errorOccured +'Error: Generate Offer URL is only applicable for Manual cases.<br/>';
            }            
            if(cs.IsClosed ){
                errorOccured = errorOccured +'Error: DER Offer URL cannot be generated as this Case is Closed (Completed or Cancelled). <br/>';            
            }
            if(cs.DER_Offer_URL__c != null && dr != null && dr.DER_Agreements__r.size()==1){
                errorOccured = errorOccured +'Error: DER Offer URL has already been generated. See DER Offer URL field on the Case. <br/>';
            }   
            if(cs.Send_DER_Offer__c == true)
            {
                errorOccured = errorOccured +'Error: DER Offer URL cannot be generated as the offer has already been sent. <br/>';
            }
            if(dr != null && dr.DER_Agreements__r.size()>1){
                errorOccured = errorOccured +'Error: DER Offer URL cannot be generated as there are multiple DER Agreement records. <br/>';
            }            
         
            if(String.isBlank(errorOccured)){
                cs.Send_DER_Offer__c = true;
                update cs;
            }
        }
        
        return errorOccured;
    }
}