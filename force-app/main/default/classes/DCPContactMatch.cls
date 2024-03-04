global class DCPContactMatch implements vlocity_cmt.VlocityOpenInterface {
    public SFContact con;
    
    public class SFContact {        
        public String FirstName;
        public String LastName;
        public String Email;
        public String MobilePhone;
        public String OtherPhone;
    }
    
    public Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        
        try {
            if (methodName=='Match') {
                System.debug('inputs: '+inputMap);
                con = new SFContact();
                con.FirstName = (String)inputMap.get('FirstName');
                con.LastName = (String)inputMap.get('LastName');
                con.Email = (String)inputMap.get('Email');
                con.MobilePhone = (String)inputMap.get('MobilePhone');
                con.OtherPhone = (String)inputMap.get('OtherPhone');
                
                String query = createQuery();
                
                List<Contact> cts = Database.query(query); System.debug('***query:'+query);
                if(cts.size()>0) {
                    outMap.put('Contact',cts[0]);
                }
                else {
                    outMap.put('Contact','');
                }
                return true;
            }
        }
        catch(Exception e) {
            System.debug('exception message: '+e.getMessage());
            System.debug('exception stacktrace: '+e.getStackTraceString());
            return false;
        }
        return false;
    }
    
    private String createQuery() {

        String selectfields = 'FirstName,lastname,mobilephone,otherphone,email,AccountId ';
        String filter=' firstname=\''+con.FirstName+'\'  AND lastname=\''+con.LastName+'\' ';
        filter += ' AND RecordType.DeveloperName = \'dcp_Contact\' ';

        if (con.MobilePhone!='' || con.OtherPhone!='' || con.Email!='') {
            
            filter+= ' AND ( ';
            
            if (con.MobilePhone!='') {
                filter+='(mobilephone=\''+con.MobilePhone+'\''+' OR '+'otherphone=\''+con.MobilePhone+'\')';
            }
            if (con.MobilePhone!='' && con.OtherPhone!='') {
                filter+=' OR ';
            }
            if (con.OtherPhone!=''){
                filter+='(otherphone=\''+con.OtherPhone+'\''+' OR '+'mobilephone=\''+con.OtherPhone+'\')';
            }
            if ((con.MobilePhone!='' || con.OtherPhone!='') && con.Email!=''){
                filter+=' OR ';
            }
            if (con.Email!=''){
                filter+='email=\''+con.Email+'\'';
            }

            filter+=')';
        }

        String contactQuery = 'SELECT Id, '+selectfields+
            'FROM Contact WHERE '+filter;
        
        System.debug('contactQuery '+contactQuery);
        return contactQuery;
    }
}