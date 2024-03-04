public class DCPCaseEWOVHandler {
    public DCPCaseNewEWOVParser parser=new DCPCaseNewEWOVParser(); 
    public DCPCaseUpgradeEWOVParser upgradeParser= new DCPCaseUpgradeEWOVParser();
    
    public void beforeInsert(List<Case> cases) {                
        try{
            Id caseEWOVRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('dcp_EWOV').getRecordTypeId();
            List<Case> evovNewCases=new List<Case>();
            List<Case> evovExistingCases=new List<Case>();
            for(Case c: cases){                 
                if(c.RecordTypeId==caseEWOVRecordTypeId && c.Subject.startsWithIgnoreCase('New Assisted Referral')){                    
                    evovNewCases.add(c);
                }
                if(c.RecordTypeId==caseEWOVRecordTypeId && (c.Subject.startsWithIgnoreCase('Upgrade notification') || c.Subject.startsWithIgnoreCase('Further information') || c.Subject.startsWithIgnoreCase('New Stage'))){                    
                    evovExistingCases.add(c);
                }
            } 
            if(evovNewCases.size()>0){
                this.processNewEWOVCases(evovNewCases);
            }
            if(evovExistingCases.size()>0){
                this.processUpgradeNotification(evovExistingCases);
            }
        }
        catch(Exception e){System.debug('**Exception in beforeInsert');}
    }
    public void afterInsert(List<Case> cases) {    
        Id caseEWOVRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('dcp_EWOV').getRecordTypeId();
        List<Case> evovExistingCases=new List<Case>();
        Set<String> ewovReferences=new Set<String>();
        Map<String, Case> caseFromEWOVReference = new Map<String, Case>();
        for(Case c: cases){
            if(c.RecordTypeId==caseEWOVRecordTypeId && c.Subject<>NULL && (c.Subject.startsWithIgnoreCase('Upgrade notification') || c.Subject.startsWithIgnoreCase('Further information') || c.Subject.startsWithIgnoreCase('New Stage'))){                    
                evovExistingCases.add(c);
                ewovReferences.add(c.dcp_EWOV_Case_Number__c);
                caseFromEWOVReference.put(c.dcp_EWOV_Case_Number__c, c);
            }
        }
        List<Case> parentCases=[Select Id, dcp_EWOV_Case_Number__c, dcp_EWOV_Level__c, dcp_Stage_1_Date__c, dcp_Stage_2_Date__c, dcp_Stage_3_Date__c, dcp_Final_Stage_Date__c 
                                From Case
                                Where dcp_EWOV_Case_Number__c in :ewovReferences and IsDeleted=false];
        
        if(parentCases.size()>0){
            for(Case pc: parentCases){
                if(caseFromEWOVReference.containsKey(pc.dcp_EWOV_Case_Number__c)){
                    if(caseFromEWOVReference.get(pc.dcp_EWOV_Case_Number__c).Subject.startsWithIgnoreCase('Upgrade notification') || caseFromEWOVReference.get(pc.dcp_EWOV_Case_Number__c).Subject.startsWithIgnoreCase('New Stage')){
                        pc.dcp_EWOV_Level__c=caseFromEWOVReference.get(pc.dcp_EWOV_Case_Number__c).dcp_EWOV_Level__c;
                        pc.dcp_Stage_1_Date__c=pc.dcp_EWOV_Level__c=='Stage 1'?(caseFromEWOVReference.get(pc.dcp_EWOV_Case_Number__c).dcp_Stage_1_Date__c):Null;
                        pc.dcp_Stage_2_Date__c=pc.dcp_EWOV_Level__c=='Stage 2'?(caseFromEWOVReference.get(pc.dcp_EWOV_Case_Number__c).dcp_Stage_2_Date__c):Null;
                        pc.dcp_Stage_3_Date__c=pc.dcp_EWOV_Level__c=='Stage 3'?(caseFromEWOVReference.get(pc.dcp_EWOV_Case_Number__c).dcp_Stage_3_Date__c):Null;
                        pc.dcp_Final_Stage_Date__c=pc.dcp_EWOV_Level__c=='Final Stage'?(caseFromEWOVReference.get(pc.dcp_EWOV_Case_Number__c).dcp_Final_Stage_Date__c):Null;
                    }
                }
            }
            update parentCases;
        }
    }
    public void processNewEWOVCases(List<Case> newEWOVCases){
        for(Case c: newEWOVCases){
            c.dcp_EWOV_Level__c='Assisted Referral';
            c.dcp_Assisted_Referral_Date__c=Date.today();
            c.dcp_EWOV_Case_Number__c=this.parser.getEWOVReferenceNumber(c.Subject)!='0'?this.parser.getEWOVReferenceNumber(c.Subject):'';
            //c.dcp_EWOV_Salutation__c=this.parser.getEWOVReferenceNumber(c.Subject)!='0'?this.parser.getCustomerSalutation(c.Subject):'';
            c.SuppliedName=this.parser.getEWOVReferenceNumber(c.Subject)!='0'?this.parser.getCustomerName(c.Subject):'';
            c.dcp_Resolution_Sought__c=this.parser.getResolutionFromDescriptionBeforeInsert(c.Description, c);
            c.dcp_EWOV_Customer_Statement__c=this.parser.getCustomerStatementFromDescriptionBeforeInsert(c.Description, c);
            c.SuppliedPhone=this.parser.getMobileNumberFromDescriptionBeforeInsert(c.Description, c);
            c.dcp_Applicant_Email__c=this.parser.getEmailFromDescriptionBeforeInsert(c.Description, c);
            c.dcp_claim_Mailing_Address__c=this.parser.getMailingAddressFromDescriptionBeforeInsert(c.Description, c);
            c.dcp_Due_Date__c=this.parser.getDueDateDescriptionBeforeInsert(c.Description, c);
            c.Description=this.parser.getShortDescriptionFromDescriptionBeforeInsert(c.Description, c);
        }
    }
    public void processUpgradeNotification(List<Case> existingEWOVCases){
        List<String> ewovReferences=new List<String>();
        Map<String, Case> caseFromEWOVReference = new Map<String, Case>();
        
        System.debug('**existingEWOVCases size:'+existingEWOVCases.size());
        
        for(Case c: existingEWOVCases){
            System.debug('*** c.dcp_EWOV_Case_Number__c'+c.dcp_EWOV_Case_Number__c);
            if(c.Subject.startsWithIgnoreCase('Upgrade notification')){
                c.dcp_EWOV_Case_Number__c=this.upgradeParser.getEWOVReferenceNumber(c.Subject)!='0'?this.upgradeParser.getEWOVReferenceNumber(c.Subject):'';
                c.dcp_EWOV_Level__c=this.upgradeParser.getStageFromDescriptionBeforeInsert(c.Description, c);
                c.dcp_Stage_1_Date__c=c.dcp_EWOV_Level__c=='Stage 1'?(Date.today()):Null;
                c.dcp_Stage_2_Date__c=c.dcp_EWOV_Level__c=='Stage 2'?(Date.today()):Null;
                c.dcp_Stage_3_Date__c=c.dcp_EWOV_Level__c=='Stage 3'?(Date.today()):Null;
                c.dcp_Final_Stage_Date__c=c.dcp_EWOV_Level__c=='Final Stage'?(Date.today()):Null;
            }
            else if(c.Subject.startsWithIgnoreCase('New Stage')){
                c.dcp_EWOV_Case_Number__c=this.upgradeParser.getEWOVReferenceNumberForNewStageEmails(c.Subject)!='0'?this.upgradeParser.getEWOVReferenceNumberForNewStageEmails(c.Subject):'';
                c.dcp_EWOV_Level__c=this.upgradeParser.getStageFromDescriptionBeforeInsert(c.Description, c);
                c.dcp_Stage_1_Date__c=c.dcp_EWOV_Level__c=='Stage 1'?(Date.today()):Null;
                c.dcp_Stage_2_Date__c=c.dcp_EWOV_Level__c=='Stage 2'?(Date.today()):Null;
                c.dcp_Stage_3_Date__c=c.dcp_EWOV_Level__c=='Stage 3'?(Date.today()):Null;
                c.dcp_Final_Stage_Date__c=c.dcp_EWOV_Level__c=='Final Stage'?(Date.today()):Null;
            }                           
            else if(c.Subject.startsWithIgnoreCase('Further information')){
                c.dcp_EWOV_Case_Number__c=this.upgradeParser.getEWOVReferenceNumberForFurtherInformationEmails(c.Subject)!='0'?this.upgradeParser.getEWOVReferenceNumberForFurtherInformationEmails(c.Subject):'';
            }
            
            if(c.dcp_EWOV_Case_Number__c<>'' && c.dcp_EWOV_Case_Number__c<>null){ewovReferences.add(c.dcp_EWOV_Case_Number__c);}                           
        }
        System.debug('**ewovReferences size:'+ewovReferences.size());
        
        List<Case> parentCases=[Select Id, dcp_EWOV_Case_Number__c, dcp_EWOV_Level__c, dcp_Stage_1_Date__c, dcp_Stage_2_Date__c, dcp_Stage_3_Date__c, dcp_Final_Stage_Date__c 
                                From Case
                                Where dcp_EWOV_Case_Number__c in :ewovReferences and IsDeleted=false];
        
        System.debug('**parentCases size:'+parentCases.size());
        
        if(parentCases.size()>0){ 
            System.debug('*** 1');
            for(Case c: parentCases){ 
                System.debug('*** 11');
                caseFromEWOVReference.put(c.dcp_EWOV_Case_Number__c, c); System.debug('*** 111');           
            }
            
            for(Case c: existingEWOVCases){ 
                System.debug('*** 2');
                if(caseFromEWOVReference.containsKey(c.dcp_EWOV_Case_Number__c)){ 
                    System.debug('*** 22');
                    c.ParentId=caseFromEWOVReference.get(c.dcp_EWOV_Case_Number__c).Id; System.debug('*** 222');
                    c.dcp_Skip_Validations__c=true;                                                            
                    c.Status='Closed';
                }
            }
        }
        
    }
    
}