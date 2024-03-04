public class DCPCaseNewEWOVParser {
    public String getEWOVReferenceNumber(String subject){
        List<String> parts = subject.split(' ');
        String refNumber=parts.size()>3?parts[3]:'0';
        return refNumber;       
    }
    public String getCustomerSalutation(String subject){
        List<String> parts = subject.split(' ');
        String salutation=parts.size()>4?parts[4]:'0';
        return salutation;                
    }
    public String getCustomerName(String subject){
        List<String> parts = subject.split(' ');
        String customerName=parts.size()>5?parts[5]+' '+parts[6]:'0';
        return customerName;        
    }
    public String getMobileNumberFromDescriptionBeforeInsert(String description, Case c){
        System.debug('***in getMobileNumberFromDescriptionBeforeInsert');
        String mobile='';        
        List<String> parts = description.split('\n');
        System.debug('****parts size:'+parts.size());
        for(Integer i = 0; i < parts.size(); i++){
            System.debug('**** '+i+' ****:'+parts[i]);
            if(parts[i]=='Mobile phone:'){                                                             
                mobile=String.format('{0}',new List<String>{parts[i+1]}); break;                
            }            
        }
        return mobile;
    }
     public String getEmailFromDescriptionBeforeInsert(String description, Case c){
        System.debug('***in getEmailFromDescriptionBeforeInsert');
        String email='';        
        List<String> parts = description.split('\n');
        System.debug('****parts size:'+parts.size());
        for(Integer i = 0; i < parts.size(); i++){
            System.debug('**** '+i+' ****:'+parts[i]);
            if(parts[i]=='Email:'){                                                             
                email=String.format('{0}',new List<String>{parts[i+1]}); break;                
            }            
        }
        return email;
    }
    public String getShortDescriptionFromDescriptionBeforeInsert(String description, Case c){
        System.debug('***in getMobileNumberFromDescriptionBeforeInsert');
        String shortDescription='';        
        List<String> parts = description.split('\n');
        System.debug('****parts size:'+parts.size());
        Integer size=parts.size();
        for(Integer i = 0; i < parts.size(); i++){
            System.debug('**** '+i+' ****:'+parts[i]);
            if(i+2<size && parts[i+2]=='Customer details'){                                                             
                shortDescription=String.format('{0}',new List<String>{parts[i+1]}); break;                
            }
            if(i+3<size && parts[i+3]=='Customer details'){                                                             
                shortDescription=String.format('{0}\n{1}',new List<String>{parts[i+1],parts[i+2]}); break;                
            }
            if(i+4<size && parts[i+4]=='Customer details'){                                                             
                shortDescription=String.format('{0}\n{1}\n{2}',new List<String>{parts[i+1],parts[i+2],parts[i+3]}); break;                
            }
            if(i+5<size && parts[i+5]=='Customer details'){                                                             
                shortDescription=String.format('{0}\n{1}\n{2}\n{3}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4]}); break;                
            }            
        }
        return shortDescription;
    }
    public String getMailingAddressFromDescriptionBeforeInsert(String description, Case c){
        System.debug('***in getMailingAddressFromDescriptionBeforeInsert');
        String address='';        
        List<String> parts = description.split('\n');
        Integer size=parts.size();
        System.debug('****parts size:'+parts.size());
        for(Integer i = 0; i < parts.size(); i++){
            System.debug('**** '+i+' ****:'+parts[i]);
            if(i+2<size && parts[i]=='Postal address:' && parts[i+2]=='Mobile phone:'){                                                             
                address=String.format('{0}',new List<String>{parts[i+1]}); break;                
            }
            if(i+3<size && parts[i]=='Postal address:' && parts[i+3]=='Mobile phone:'){                                                             
                address=String.format('{0} {1}',new List<String>{parts[i+1],parts[i+2]}); break;                
            }
            if(i+4<size && parts[i]=='Postal address:' && parts[i+4]=='Mobile phone:'){                                                             
                address=String.format('{0} {1} {2}',new List<String>{parts[i+1],parts[i+2],parts[i+3]}); break;                
            }            
        }
        return address;
    }
    public String getResolutionFromDescriptionBeforeInsert(String description, Case c){
        System.debug('***in getResolutionFromDescriptionBeforeInsert');
        String resolution='';
        //List<String> parts = description.split('\r\n');
        List<String> parts = description.split('\n');
        System.debug('****parts size:'+parts.size());
        Integer size=parts.size();
        for(Integer i = 0; i < parts.size(); i++){
            System.debug('**** '+i+' ****:'+parts[i]);
            if(parts[i]=='Resolution sought' && i+2<size && parts[i+2]=='What AusNet Services needs to do next'){                                                             
                resolution=String.format('{0}',new List<String>{parts[i+1]}); break;                
            }
            if(parts[i]=='Resolution sought' && i+3<size && parts[i+3]=='What AusNet Services needs to do next'){                                                             
                resolution=String.format('{0}\n{1}',new List<String>{parts[i+1],parts[i+2]}); break;                
            }
            if(parts[i]=='Resolution sought' && i+4<size && parts[i+4]=='What AusNet Services needs to do next'){                                                             
                resolution=String.format('{0}\n{1}\n{2}',new List<String>{parts[i+1],parts[i+2],parts[i+3]}); break;                
            }
            if(parts[i]=='Resolution sought' && i+5<size && parts[i+5]=='What AusNet Services needs to do next'){                                                             
                resolution=String.format('{0}\n{1}\n{2}\n{3}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4]}); break;                
            }
            if(parts[i]=='Resolution sought' && i+6<size && parts[i+6]=='What AusNet Services needs to do next'){                                                             
                resolution=String.format('{0}\n{1}\n{2}\n{3}\n{4}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5]}); break;                
            }
        }
        return resolution;
    }
    public String getCustomerStatementFromDescriptionBeforeInsert(String description, Case c){
        System.debug('***in getCustomerStatementFromDescriptionBeforeInsert');
        String statement='';
        //List<String> parts = description.split('\r\n');
        List<String> parts = description.split('\n');
        System.debug('****parts size:'+parts.size());
        Integer size=parts.size();
        for(Integer i = 0; i < parts.size(); i++){
            System.debug('**** '+i+' ****:'+parts[i]);
            if(i+2<size && parts[i]=='Customer statement' && parts[i+2]=='Resolution sought'){                                                             
                statement=String.format('{0}',new List<String>{parts[i+1]}); break;                
            }
            if(i+3<size && parts[i]=='Customer statement' && parts[i+3]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}',new List<String>{parts[i+1],parts[i+2]}); break;                
            }
            if(i+4<size && parts[i]=='Customer statement' && parts[i+4]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}\n{2}',new List<String>{parts[i+1],parts[i+2],parts[i+3]}); break;                
            }
            if(i+5<size && parts[i]=='Customer statement' && parts[i+5]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}\n{2}\n{3}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4]}); break;                
            }
            if(i+6<size && parts[i]=='Customer statement' && parts[i+6]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5]}); break;                
            }
            if(i+7<size && parts[i]=='Customer statement' && parts[i+7]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}\n{5}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5],parts[i+6]}); break;                
            }
            if(i+8<size && parts[i]=='Customer statement' && parts[i+8]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}\n{5}\n{6}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5],parts[i+6],parts[i+7]}); break;                
            }
            if(i+9<size && parts[i]=='Customer statement' && parts[i+9]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}\n{5}\n{6}\n{7}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5],parts[i+6],parts[i+7],parts[i+8]}); break;                
            }
            if(i+10<size && parts[i]=='Customer statement' && parts[i+10]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}\n{5}\n{6}\n{7}\n{8}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5],parts[i+6],parts[i+7],parts[i+8],parts[i+9]}); break;                
            }
            if(i+11<size && parts[i]=='Customer statement' && parts[i+11]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}\n{5}\n{6}\n{7}\n{8}\n{9}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5],parts[i+6],parts[i+7],parts[i+8],parts[i+9],parts[i+10]}); break;                
            }
            if(i+12<size && parts[i]=='Customer statement' && parts[i+12]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}\n{5}\n{6}\n{7}\n{8}\n{9}\n{10}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5],parts[i+6],parts[i+7],parts[i+8],parts[i+9],parts[i+10],parts[i+11]}); break;                
            }
            if(i+13<size && parts[i]=='Customer statement' && parts[i+13]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}\n{5}\n{6}\n{7}\n{8}\n{9}\n{10}\n{11}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5],parts[i+6],parts[i+7],parts[i+8],parts[i+9],parts[i+10],parts[i+11],parts[i+12]}); break;                
            }
            if(i+14<size && parts[i]=='Customer statement' && parts[i+14]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}\n{5}\n{6}\n{7}\n{8}\n{9}\n{10}\n{11}\n{12}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5],parts[i+6],parts[i+7],parts[i+8],parts[i+9],parts[i+10],parts[i+11],parts[i+12],parts[i+13]}); break;                
            }
            if(i+15<size && parts[i]=='Customer statement' && parts[i+14]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}\n{5}\n{6}\n{7}\n{8}\n{9}\n{10}\n{11}\n{12}\n{13}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5],parts[i+6],parts[i+7],parts[i+8],parts[i+9],parts[i+10],parts[i+11],parts[i+12],parts[i+13],parts[i+14]}); break;                
            }
            if(i+16<size && parts[i]=='Customer statement' && parts[i+15]=='Resolution sought'){                                                             
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}\n{5}\n{6}\n{7}\n{8}\n{9}\n{10}\n{11}\n{12}\n{13}\n{14}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5],parts[i+6],parts[i+7],parts[i+8],parts[i+9],parts[i+10],parts[i+11],parts[i+12],parts[i+13],parts[i+14],parts[i+15]}); break;                
            }
            if(i+17<size && parts[i]=='Customer statement' && parts[i+16]=='Resolution sought'){                                                            
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}\n{5}\n{6}\n{7}\n{8}\n{9}\n{10}\n{11}\n{12}\n{13}\n{14}\n{15}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5],parts[i+6],parts[i+7],parts[i+8],parts[i+9],parts[i+10],parts[i+11],parts[i+12],parts[i+13],parts[i+14],parts[i+15],parts[i+16]}); break;                
            }
            if(i+18<size && parts[i]=='Customer statement' && parts[i+17]=='Resolution sought'){                                                            
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}\n{5}\n{6}\n{7}\n{8}\n{9}\n{10}\n{11}\n{12}\n{13}\n{14}\n{15}\n{16}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5],parts[i+6],parts[i+7],parts[i+8],parts[i+9],parts[i+10],parts[i+11],parts[i+12],parts[i+13],parts[i+14],parts[i+15],parts[i+16],parts[i+17]}); break;                
            }
            if(i+19<size && parts[i]=='Customer statement' && parts[i+18]=='Resolution sought'){                                                            
                statement=String.format('{0}\n{1}\n{2}\n{3}\n{4}\n{5}\n{6}\n{7}\n{8}\n{9}\n{10}\n{11}\n{12}\n{13}\n{14}\n{15}\n{16}\n{17}',new List<String>{parts[i+1],parts[i+2],parts[i+3],parts[i+4],parts[i+5],parts[i+6],parts[i+7],parts[i+8],parts[i+9],parts[i+10],parts[i+11],parts[i+12],parts[i+13],parts[i+14],parts[i+15],parts[i+16],parts[i+17],parts[i+18]}); break;                
            }
        }
        return statement;
    }
    public Date getDueDateDescriptionBeforeInsert(String description, Case c){
        System.debug('***in getDueDateDescriptionBeforeInsert');
        String dueDate='';        
        List<String> parts = description.split('\n');
        System.debug('****parts size:'+parts.size());
        Integer size=parts.size();
        for(Integer i = 0; i < parts.size(); i++){
            //call or write to the customer to discuss their concerns by 17 May 2021
            if(parts[i].startsWith('call or write to the customer to discuss their concerns by')){                                                             
                dueDate=parts[i].removeStart('call or write to the customer to discuss their concerns by ').trim(); System.debug('***dueDate is:'+dueDate);
                break;                
            }     
            //System.debug('**** '+i+' ****:'+parts[i]);                     
        }
        return Date.valueOf(this.getTransformedDate(dueDate));
    }
    public String getTransformedDate(String rawDateString){ //17 May 2021
        List<String> parts = rawDateString.split(' ');
        return parts[2]+'-'+getMonthInDigits(parts[1])+'-'+parts[0];
    }
    public String getMonthInDigits(String rawMonthString){
        switch on rawMonthString {
            when 'Jan','January' {
                return '01';
            }
            when 'Feb','February' {
                return '02';
            }
            when 'Mar','March' {
                return '03';
            }
            when 'Apr','April' {
                return '04';
            }
            when 'May' {
                return '05';
            }
            when 'Jun','June' {
                return '06';
            }
            when 'Jul','July' {
                return '07';
            }
            when 'Aug','August' {
                return '08';
            }
            when 'Sep','September' {
                return '09';
            }
            when 'Oct','October' {
                return '10';
            }
            when 'Nov','November' {
                return '11';
            }
            when 'Dec','December' {
                return '12';
            }
        }
        return 'NA';
    }
}