public class DCPCaseUpgradeEWOVParser {    
	public String getEWOVReferenceNumber(String subject){
        List<String> parts = subject.split(' ');
        String refNumber=parts.size()>2?parts[2]:'0';
        return refNumber;       
    }
    public String getEWOVReferenceNumberForFurtherInformationEmails(String subject){
        List<String> parts = subject.split(' ');
        String refNumber=parts.size()>3?parts[3]:'0';
        return refNumber;       
    }
    public String getEWOVReferenceNumberForNewStageEmails(String subject){
        List<String> parts = subject.split(' ');
        String refNumber=parts.size()>3?parts[3]:'0';
        return refNumber;       
    }
    public String getStageFromDescriptionBeforeInsert(String description, Case c){
        System.debug('***in getStageFromDescriptionBeforeInsert');
        String stage='';        
        List<String> parts = description.split('\n');        
        for(Integer i = 0; i < parts.size(); i++){            
            if(parts[i]==CaseEWOVConstants.STAGE_1_SEARCH_KEY1 || parts[i]==CaseEWOVConstants.STAGE_1_SEARCH_KEY2){                                                             
                stage=CaseEWOVConstants.STAGE_1; break;                
            }
            if(parts[i]==CaseEWOVConstants.STAGE_2_SEARCH_KEY1 || parts[i]==CaseEWOVConstants.STAGE_2_SEARCH_KEY2){                                                             
                stage=CaseEWOVConstants.STAGE_2; break;                
            }
            if(parts[i]==CaseEWOVConstants.STAGE_3_SEARCH_KEY){                                                             
                stage=CaseEWOVConstants.STAGE_3; break;                 
            }
			if(parts[i]==CaseEWOVConstants.FINAL_STAGE_SEARCH_KEY){                                                             
                stage=CaseEWOVConstants.FINAL_STAGE; break;                
            }            
        }
        return stage;
    }
}