public with sharing class TVE_SAPInteg_RequestInvoiceUtil {
    public static HttpResponse callRequestInvoice(Artefact__c artfctRecord,API_Callout_Headers__mdt apiCallHea) {

        Project__c projRec = [SELECT Id, SalesOrder__c FROM Project__c WHERE Id =: artfctRecord.Project__c];
        //RequestInvoiceSAPInteg reqInvIntegSAP = new RequestInvoiceSAPInteg();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('request');
        gen.writeStartObject();
        gen.writeStringField('key', apiCallHea.key__c);
        gen.writeStringField('msgId', TVE_Utility.getUniqueId(artfctRecord.Id));
        gen.writeStringField('sourceSystem', apiCallHea.sourceSystem__c);
        gen.writeStringField('targetSystem', apiCallHea.targetSystem__c);
        gen.writeStringField('objectName', apiCallHea.objectName__c);
        gen.writeFieldName('payload');
        gen.writeStartObject();
        gen.writeFieldName('d');
        gen.writeStartObject();
        gen.writeStringField('InvoiceNo','');
        gen.writeStringField('SalesOrder', projRec.SalesOrder__c);
        gen.writeStringField('SfInvoiceRefNum',artfctRecord.Id);
        gen.writeFieldName('ItemToCreateInvoiceSet');
        gen.writeStartObject();
        gen.writeFieldName('results');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('InvoiceNo','');
        gen.writeStringField('SalesOrder',projRec.SalesOrder__c);
        gen.writeStringField('MaterialNumber',artfctRecord.MaterialCodeLine1__c);

        gen.writeStringField('BillTo', artfctRecord.Bill_To__c);
        gen.writeStringField('Price', String.valueOf(artfctRecord.AmountLine1ExGST__c));
        gen.writeEndObject();

        if(String.isNotEmpty(artfctRecord.MaterialCodeLine2__c)){
            gen.writeStartObject();
            gen.writeStringField('InvoiceNo','');
            gen.writeStringField('SalesOrder',projRec.SalesOrder__c);
            gen.writeStringField('MaterialNumber',artfctRecord.MaterialCodeLine2__c);

            gen.writeStringField('BillTo', artfctRecord.Bill_To__c);
            gen.writeStringField('Price', String.valueOf(artfctRecord.AmountLine2ExGST__c));
            gen.writeEndObject();
        }

        if(String.isNotEmpty(artfctRecord.MaterialCodeLine3__c)){
            gen.writeStartObject();
            gen.writeStringField('InvoiceNo','');
            gen.writeStringField('SalesOrder',projRec.SalesOrder__c);
            gen.writeStringField('MaterialNumber',artfctRecord.MaterialCodeLine3__c);

            gen.writeStringField('BillTo', artfctRecord.Bill_To__c);
            gen.writeStringField('Price', String.valueOf(artfctRecord.AmountLine3ExGST__c));
            gen.writeEndObject();
        }

        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        HttpResponse response;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setClientCertificateName('eains');
        request.setBody(jsonData);
        system.debug('requestBody--'+request.getBody());
        request.setEndpoint(apiCallHea.endpoint__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        //request.setHeader('slug','SapObject=/CUM/CONSM,ObjectId=000075002168,ArObject=ZCU_ACCC,Filename=test.txt');
        response = http.send(request);
        system.debug('responseBody++'+response.getBody());
        return response;
    }
}