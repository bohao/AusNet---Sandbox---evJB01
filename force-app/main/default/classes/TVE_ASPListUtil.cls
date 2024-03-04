/*
@author  : brajesh.tiwary@ausnetservices.com.au
@created : 28 Jan 2020
@Description : Class for ASP related integrations (List TV-255, TV-256)
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
global class TVE_ASPListUtil {
    private static final String ASPLIST_CALLOUT = 'ASPMatrixCSV';
    private static final String ASPPDF_CALLOUT = 'ASPMatrixPDF';
    @AuraEnabled(cacheable=true)
    public static list<Object> callGetAspListIntWCode(String wCode, Id projectId){
        Map<String, Object> inputMap = new Map<String, Object>();
        inputMap.put('applicationType','');
        Map<String, Object> ipOptionsMap=new Map<String, Object>();
        Map<String, Object> ipOutputMap = (Map<String, Object>)vlocity_cmt.IntegrationProcedureService.runIntegrationService('IP_FNP_AspCompleteList', inputMap, ipOptionsMap);
        List<Object> aspList=(List<Object>)ipOutputMap.get('ASPList');
        //return callGetAspListInt(new List<String>{wCode}, projectId);
        return aspList;
    }

    @AuraEnabled(cacheable=true)
    public static list<ServiceProvider> callGetAspListInt(list<string> workCodeList, Id projectId){
        system.debug('workCodeList----->'+workCodeList);
        //Sample values for workCodeList - ['1018','1034']
        system.debug('projectId----->'+projectId);
        list<ServiceProvider> listSP = new list<ServiceProvider>();
        API_Callout_Headers__mdt apiCallHea = [SELECT key__c, sourceSystem__c, targetSystem__c, objectName__c, endpoint__c FROM API_Callout_Headers__mdt WHERE objectName__c =: ASPLIST_CALLOUT];
        string msgId = TVE_Utility.getUniqueId(projectId);
        JSONGenerator gen = JSON.createGenerator(true);
        list<string> filterList = new list<string>{'Company Name','Address','AusNet Services Accreditation ID No. EVNxxxxx'};
        
        list<string> categoryList = new list<string>{'External Design'};
        gen.writeStartObject();
        gen.writeFieldName('request');
        gen.writeStartObject();
        gen.writeStringField('key', apiCallHea.key__c);
        gen.writeStringField('msgId', msgId);
        gen.writeStringField('sourceSystem', apiCallHea.sourceSystem__c);
        gen.writeStringField('targetSystem', apiCallHea.targetSystem__c);
        gen.writeStringField('objectName', apiCallHea.objectName__c);
        gen.writeFieldName('payload');
        gen.writeStartObject();
        gen.writeStringField('fileName', 'ecmsftp/QM.csv');
        gen.writeFieldName('filterList');
        gen.writeObject(filterList);
        gen.writeFieldName('categoryList');
        gen.writeObject(categoryList);
        gen.writeFieldName('workCodeList');
        gen.writeObject(workCodeList);
        gen.writeEndObject();
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        system.debug('jsonData++'+jsonData);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setClientCertificateName('eains');
        request.setBody(jsonData);
        system.debug('requestBody++'+request.getBody());
        request.setEndpoint(apiCallHea.endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        HttpResponse response = http.send(request);
        system.debug('responseBody++'+response.getBody());
        ASPWrapper aspPayload;
        if(response.getstatusCode() == 200 && response.getbody() != null){
        aspPayload = (ASPWrapper) System.JSON.deserialize(response.getBody(), ASPWrapper.class);
        }
        if(aspPayload != null){
            listSP = aspPayload.payload.ASPs;
        }
        return listSP;
    }
    
    public class ASPWrapper {
        
        @auraEnabled public String status{get; set;}
        @auraEnabled public String statusMessage{get; set;}
        @auraEnabled public String initiating_msgId{get; set;}
        @auraEnabled public String msgId{get; set;}
        @auraEnabled public Payload payload{get; set;}
    }
    public class Payload {
        @auraEnabled public List<ServiceProvider> ASPs{get; set;}
        @auraEnabled public string PDF {get; set;}
    }
    public class ServiceProvider {
        @auraEnabled public String CompanyName{get; set;}
        @auraEnabled public String Address{get; set;}
        @auraEnabled public String AusNetServicesAccreditationIDNo{get; set;}
        @auraEnabled public String Category{get; set;}
        @auraEnabled public String ContactDetails{get; set;}
        @auraEnabled public String Phone{get; set;}
        @auraEnabled public String Email{get; set;}
        @auraEnabled public String VEDNAccreditationIDNo{get; set;}
        @auraEnabled public String ExpiryDate{get; set;}
        @auraEnabled public String Grade{get; set;}
    }
    @AuraEnabled
    public static id callGetPDFIntBlob(Id recordId) {
        string msgId = TVE_Utility.getUniqueId(recordId);
        API_Callout_Headers__mdt apiCallHea = [SELECT key__c, sourceSystem__c, targetSystem__c, objectName__c, endpoint__c FROM API_Callout_Headers__mdt WHERE objectName__c =: ASPPDF_CALLOUT];
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('request');
        gen.writeStartObject();
        gen.writeStringField('key', apiCallHea.key__c);
        gen.writeStringField('msgId', msgId);
        gen.writeStringField('sourceSystem', apiCallHea.sourceSystem__c);
        gen.writeStringField('targetSystem', apiCallHea.targetSystem__c);
        gen.writeStringField('objectName', apiCallHea.objectName__c);
        gen.writeFieldName('payload');
        gen.writeStartObject();
        gen.writeStringField('fileName', 'ecmsftp/QM.pdf');
        gen.writeEndObject();
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setClientCertificateName('eains');
        request.setBody(jsonData);
        system.debug('requestBody++'+request.getBody());
        request.setEndpoint(apiCallHea.endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        HttpResponse response = http.send(request);
        system.debug('responseBody++'+response.getBody());
        ASPWrapper aspPdfPayload;
        if(response.getstatusCode() == 200 && response.getbody() != null){
            aspPdfPayload = (ASPWrapper) System.JSON.deserialize(response.getBody(), ASPWrapper.class);
        }
        Blob data = EncodingUtil.base64Decode(aspPdfPayload.payload.PDF);
        system.debug('data'+data);
        ContentVersion contentVersion = new ContentVersion(
            Title = 'ASP Matrix',
            PathOnClient = 'ASP Matrix.pdf',
            VersionData = data,
            IsMajorVersion = true,
            ContentLocation='S'
        );

        insert contentVersion;
        return contentVersion.id;
    }
}