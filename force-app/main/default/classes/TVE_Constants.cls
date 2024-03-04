/*
@Author  : JTan
@Created : 21/04/2020
@Desc    : Class for TVE11 Constant Variables
*/

public without sharing class TVE_Constants {
    //Added by JTan on 21/04/2020 for TV-2898
    //Set of status allowed to update from SF to Sitecore
    public final static Set<String> ALLOWED_STATUS = new Set<String>{'AWIN', 'CNCL', 'SUSP', 'RJCT', 'COMT'};

    public final static String ORG_WIDE_EMAIL = 'AusNet Services';

    public final static String PARTNER_USER_TYPE = 'PowerPartner';

    public final static String ASP_APPLICANT_ROW_CAUSE = Schema.Project__Share.RowCause.Applicant_Account__c;
    
    public final static String ASP_APPLICANT_ACCESS = 'Edit';
}