public class TVE_SAP_Int_APICalls {
    @TestVisible public static UpdateCMResponse ucmp;
    @TestVisible public static TVE_CreateCMArtResponse CAW;
    public static NotiResponse callCreateNotireq(Project__c projRecord,Opportunity oppRecord,String SoldTo,
                                                 TVE_Integration_Constants__c intConstant,API_Callout_Headers__mdt apiCallHea,
                                                 boolean isUpdate,String qnum)
    {
        
        Date d;
        Datetime myDT;
        String endDate;
        if(projRecord.Applicationtype__c!='Public Lighting'){
            d= projRecord.EstimatedCompletionDate__c;
        } else if(projRecord.applicationtype__c=='Public Lighting'){
            d= projRecord.ProposedTargetDate__c;
        }
        if(d!=null){
            myDT = datetime.newInstance(d.year(), d.month(),d.day());
            endDate = myDT.format('yyyy-MM-dd\'T\'HH:mm:ss');
        }
        NotiResponse NR = new NotiResponse();
        try{
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('request');
            gen.writeStartObject();
            gen.writeStringField('key', apiCallHea.key__c);
            gen.writeStringField('msgId', TVE_Utility.getUniqueId(projRecord.Id));
            gen.writeStringField('sourceSystem',apiCallHea.sourceSystem__c);
            gen.writeStringField('targetSystem', apiCallHea.targetSystem__c);
            gen.writeStringField('objectName',apiCallHea.objectName__c);
            gen.writeFieldName('payload');
            gen.writeStartObject();
            gen.writeFieldName('d');
            gen.writeStartObject();
            if(isUpdate){
                gen.writeStringField('NotificationNumber',qnum);
            }
            
            gen.writeStringField('NotificationType',TVE_IntegUtility.checkString(oppRecord.Notification_Type__c));
            gen.writeStringField('ShortText',TVE_IntegUtility.checkString(projRecord.ProjectName__c).toUpperCase());

            if(String.isNotBlank(projRecord.PropertyAccessInstructions__c) && String.isNotBlank(projRecord.HazardDetails__c)){
                gen.writeStringField('LongText',TVE_IntegUtility.checkString(projRecord.PropertyAccessInstructions__c) + '\n' + TVE_IntegUtility.checkString(projRecord.HazardDetails__c));
            } else {
                gen.writeStringField('LongText',TVE_IntegUtility.checkString(projRecord.PropertyAccessInstructions__c) + TVE_IntegUtility.checkString(projRecord.HazardDetails__c));
            }
            
            gen.writeStringField('FunctionalLocation',TVE_IntegUtility.checkString(projRecord.FunctionalLocation__c));
            gen.writeStringField('Assembly',intConstant.Assembly__c);
            if(endDate!=null){
                gen.writeStringField('RequiredEndDate',endDate);
            } else {
                gen.writeNullField('RequiredEndDate');
            }
            gen.writeStringField('ReportedBy',TVE_IntegUtility.checkString(projRecord.ProjectAssignee__r.SAP_ID__c));
            gen.writeStringField('SystemStatus',TVE_IntegUtility.checkString(oppRecord.System_Status__c));
            
            if(!isUpdate){
                gen.writeFieldName('PMNotificationPartnerSet');
                gen.writeStartObject();
                gen.writeFieldName('results');
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeStringField('PartnRole',intConstant.Partner_Role_1__c);
                gen.writeStringField('Partner',TVE_IntegUtility.checkString(SoldTo));
                gen.writeEndObject();
                gen.writeStartObject();
                gen.writeStringField('PartnRole',intConstant.Partner_Role_2__c);
                gen.writeStringField('Partner',
                                      TVE_IntegUtility.checkString(projRecord.ProjectAssignee__r.Employee_ID__c)
                                    );
                gen.writeEndObject();
                gen.writeEndArray();
                gen.writeEndObject();
            }
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
            request.setEndpoint(apiCallHea.endpoint__c);
            if(isUpdate)      		 
                request.setMethod('PUT');
            else                                             
                request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            if(isUpdate)
                request.setHeader('erpKeys',qnum); 
            if(!Test.isRunningTest())
                response = http.send(request);
            if(response!=null){
                if(response.getstatusCode() == 200 && response.getbody() != null){
                    CreateNotiResponse cnp=(CreateNotiResponse)JSON.deserialize(response.getBody(),CreateNotiResponse.class);
                    NR.isSuccess=true;
                    if(!isUpdate)
                        NR.notiNumber=cnp.payload.d.NotificationNumber;
                    else
                        NR.notiNumber=qnum;
                    return NR;
                }
                else
                {
                    CreateNotiResponse cnperror=(CreateNotiResponse)JSON.deserialize(response.getBody(),CreateNotiResponse.class);
                    //Updated by JTan on 21/04/2020 for TV-2907
                    NR.isSuccess=false;
                    NR.errorMessage=response.getBody();
                    return NR;
                }
            }
            else 
                return NR;
        }
        catch(Exception e){
            NR.isSuccess=false;
            NR.errorMessage=e.getMessage() + '\r\n' + e.getStackTraceString();
            return NR;
        }
    
    }
    
    public class CreateNotiResponse {
        public String status;
        public String statusMessage;
        public Payload payload;
    }
    class d {
        public String NotificationNumber;
    }
    class Payload {
        public d d;
    }
    
    public class NotiResponse {
        public Boolean isSuccess;
        public String notiNumber;
        public String errorMessage;
    }   
    
    
    //method for CreateWork
    
    public static String callcreateWorkreq(Project__c projRecord,Opportunity oppRecord, Map<String,String> billToSoldToInfo,
                                           TVE_Integration_Constants__c intConstant,API_Callout_Headers__mdt apiCallHea,
                                           Map<String,String> WOprojMap)
    {
        HttpResponse response;
        String message;
        try{
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('request');
            gen.writeStartObject();
            gen.writeStringField('key', apiCallHea.key__c);
            gen.writeStringField('msgId', TVE_Utility.getUniqueId(projRecord.Id));
            gen.writeStringField('sourceSystem',apiCallHea.sourceSystem__c);
            gen.writeStringField('targetSystem', apiCallHea.targetSystem__c);
            gen.writeStringField('objectName',apiCallHea.objectName__c);
            gen.writeFieldName('payload');
            gen.writeStartObject();
            gen.writeFieldName('d');
            gen.writeStartObject();
            gen.writeStringField('StcCustno', billToSoldToInfo.get('SoldTo'));
            gen.writeStringField('StcName1',billToSoldToInfo.get('soldtoStcName1'));
            gen.writeStringField('StcName2',billToSoldToInfo.get('soldtoStcName2'));
            gen.writeStringField('StcAddr1',billToSoldToInfo.get('soldtoAdd1'));
            if(String.isNotBlank(billToSoldToInfo.get('soldtoAdd2'))) {
                gen.writeStringField('StcAddr2',billToSoldToInfo.get('soldtoAdd2'));
            }
            gen.writeStringField('BtcCustno',billToSoldToInfo.get('BillTo'));
            gen.writeStringField('BtcName1',billToSoldToInfo.get('billtoStcName1'));
            gen.writeStringField('BtcName2',billToSoldToInfo.get('billtoStcName2'));
            gen.writeStringField('BtcAddr1',billToSoldToInfo.get('billtoAdd1'));
            if(String.isNotBlank(billToSoldToInfo.get('billtoAdd2'))) {
                gen.writeStringField('BtcAddr2',billToSoldToInfo.get('billtoAdd2'));
            }
            gen.writeStringField('NotifNum',TVE_IntegUtility.checkString(oppRecord.Notification_Number__c));
            gen.writeStringField('SfReferenceNum',projRecord.id);
            gen.writeStringField('Cmtype',TVE_IntegUtility.checkString(projRecord.CMType__c));
            gen.writeStringField('Cmnum',TVE_IntegUtility.checkString(projRecord.CMNumber__c));
            gen.writeStringField('ProjOfficer',TVE_IntegUtility.checkString(projRecord.ProjectAssignee__r.SAP_ID__c));
            gen.writeStringField('Contestability',TVE_IntegUtility.getContesabilityOutbound(projRecord.ContestabilityType__c));
            if(projRecord.Subdivision__c=='Yes')
                gen.writeStringField('SubDiv','Y');
            else
                gen.writeStringField('SubDiv','N');
            gen.writeStringField('TownPermit',TVE_IntegUtility.checkString(projRecord.PlaningPermitNumber__c));
            gen.writeStringField('SpearNum',TVE_IntegUtility.checkString(projRecord.SpearReferenceNumber__c));
            gen.writeStringField('SubDivNum',TVE_IntegUtility.checkString(projRecord.SubdivisionPlanNumber__c));
            gen.writeStringField('OfferType',TVE_IntegUtility.checkString(projRecord.OfferType__c));
            gen.writeStringField('WorkCode',TVE_IntegUtility.checkString(projRecord.WorkCode__c));
            gen.writeStringField('WoType',TVE_IntegUtility.checkString(WOprojMap.get(ProjRecord.id)));
            gen.writeStringField('PaynowMerref',TVE_IntegUtility.checkString(projRecord.PaymentReferenceNumber__c));
            gen.writeStringField('CuDestemp',TVE_IntegUtility.checkString(projRecord.CUDesignTemplate__c));
            gen.writeStringField('MatBcode1',TVE_IntegUtility.checkString(projRecord.MaterialBillingCode1__c));
            gen.writeStringField('MatBcode2',TVE_IntegUtility.checkString(projRecord.MaterialBillingCode2__c));
            if(projRecord.PaymentAmountExGST__c!=null)
                gen.writeStringField('TotFeepay',String.valueOf(projRecord.PaymentAmountExGST__c));//TVE_IntegUtility.checkString(projRecord.PaymentAmount__c));
            else
                gen.writeStringField('TotFeepay','0');
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            String jsonData = gen.getAsString();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setClientCertificateName('eains');
            request.setBody(jsonData);
            request.setEndpoint(apiCallHea.endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            if(!Test.isRunningTest())
                response = http.send(request);
            if(response!=null){
                if(response.getstatusCode() == 200 && response.getbody() != null){
                    CreateWorkResponse cwp=(CreateWorkResponse)JSON.deserialize(response.getBody(),CreateWorkResponse.class);
                    return cwp.statusMessage;
                }
                else
                {
                    CreateWorkResponse cwp=(CreateWorkResponse)JSON.deserialize(response.getBody(),CreateWorkResponse.class);
                    return cwp.statusMessage;
                }
            }
            return message;
        }
        catch(Exception e){
            return e.getMessage() + '\r\n' + e.getStackTraceString();
        }           
    }
    
    public class CreateWorkResponse {
        
        public String status;
        public String statusMessage;
        
        
        public  CreateWorkResponse parse(String json) {
            return (CreateWorkResponse) System.JSON.deserialize(json, CreateWorkResponse.class);
        }
    }
    /* Method Name:callCMUpdateReq */
    public static UpdateCMResponse callCMUpdateReq(Project__c projRecord,API_Callout_Headers__mdt apiCallHea)
    {
        ucmp = new UpdateCMResponse();
        HttpResponse response;
        try{
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('request');
            gen.writeStartObject();
            gen.writeStringField('key', apiCallHea.key__c);
            gen.writeStringField('msgId',TVE_Utility.getUniqueId(projRecord.Id));
            gen.writeStringField('sourceSystem',apiCallHea.sourceSystem__c);
            gen.writeStringField('targetSystem', apiCallHea.targetSystem__c);
            gen.writeStringField('objectName',apiCallHea.objectName__c);
            gen.writeFieldName('payload');
            gen.writeStartObject();
            gen.writeFieldName('d');
            gen.writeStartObject();
            gen.writeStringField('Cmnum', TVE_IntegUtility.checkString(projRecord.CMNumber__c));
            gen.writeStringField('Cmtxt',TVE_IntegUtility.checkString(projRecord.ProjectName__c));
            //Added by JTan on 21/04/2020 for TV-2898
            if(TVE_Constants.ALLOWED_STATUS.contains(projRecord.SAPStatus__c)) {
                gen.writeStringField('UserStatus',projRecord.SAPStatus__c);
            }
            
            gen.writeStringField('ZzContestability', TVE_IntegUtility.getContesabilityOutbound(projRecord.ContestabilityType__c));
            gen.writeStringField('ZzPrjOfficer',TVE_IntegUtility.checkString(projRecord.ProjectAssignee__r.SAP_ID__c));
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            
            String jsonData = gen.getAsString();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setClientCertificateName('eains');
            request.setBody(jsonData);
            request.setEndpoint(apiCallHea.endpoint__c);
            request.setMethod('PUT');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('erpKeys', TVE_IntegUtility.checkString(projRecord.CMNumber__c));
            if(!Test.isRunningTest())
                response = http.send(request);
            if(response!=null){
                if(response.getstatusCode() == 200 && response.getbody() != null){
                    ucmp=(UpdateCMResponse)JSON.deserialize(response.getBody(),UpdateCMResponse.class);
                }
                else
                    ucmp=(UpdateCMResponse)JSON.deserialize(response.getBody(),UpdateCMResponse.class); 
            }
            return ucmp;
        }
        catch(Exception e){
            ucmp.status='500';
            ucmp.statusMessage=e.getMessage() + '\r\n' + e.getStackTraceString();
            return ucmp;
        }
    }
    
    public class UpdateCMResponse {
        
        public String status;
        public String statusMessage;
        public PayloadCM payloadUpCM;
    }
    public class PayloadCM {
        public String responsePayload;
    }
    public UpdateCMResponse parse(String json) {
        return (UpdateCMResponse) System.JSON.deserialize(json, UpdateCMResponse.class);
        
    }
   
    public static TVE_CreateCMArtResponse callCreateAttachment(Artefact__c art,ContentVersion contentV,
                                                               API_Callout_Headers__mdt apiCallHea,String classification,
                                                               Map<String,String> FileExtMap)
    {
        Boolean isSuccess;
        HttpResponse response ;
        
        DateTime d;
        Datetime myDT;
        String cDate;
        if(art.CreatedDate!=null){
            d= art.CreatedDate;
            myDT= datetime.newInstance(d.year(), d.month(),d.day());
            cDate= myDT.format('yyyy-MM-dd\'T\'HH:mm:ss');
        }
        try{
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('request');
            gen.writeStartObject();
            gen.writeStringField('key', apiCallHea.key__c);
            gen.writeStringField('msgId', TVE_Utility.getUniqueId(art.Id));
            gen.writeStringField('sourceSystem',apiCallHea.sourceSystem__c);
            gen.writeStringField('targetSystem', apiCallHea.targetSystem__c);
            gen.writeStringField('objectName',apiCallHea.objectName__c);
            gen.writeFieldName('payload');
            gen.writeStartObject();
            gen.writeFieldName('d');
            gen.writeStartObject();
            gen.writeStringField('SapObject','/CUM/CONSM');
            gen.writeStringField('ObjectId',art.Project__r.CMNumber__c);
            gen.writeStringField('ArcDocId','');
            gen.writeStringField('ArObject',classification);
            
            //Updated by JTan on 20/04/2020 for TV-2923
            String filename = art.name;
            if(String.isNotBlank(contentV.FileExtension) && !filename.endsWithIgnoreCase('.' + contentV.FileExtension)) {
                filename += '.' + contentV.FileExtension;
            }
            gen.writeStringField('Filename',filename);

            gen.writeStringField('FileContent',contentV.Id);
            gen.writeStringField('FileSize',String.valueOf(contentV.ContentSize));
            gen.writeStringField('MimeType',TVE_IntegUtility.checkString(FileExtMap.get(contentV.FileExtension)));
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            
            String jsonData = gen.getAsString();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setClientCertificateName('eains');
            request.setBody(jsonData);
            request.setEndpoint(apiCallHea.endpoint__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setTimeout(120000);
            if(!Test.isRunningTest())
                response = http.send(request);
            if(response!=null){
                if(response.getstatusCode()==200){
                    CAW=(TVE_CreateCMArtResponse)JSON.deserialize(response.getBody(),TVE_CreateCMArtResponse.class);
                  } 
                  else{
                    CAW=(TVE_CreateCMArtResponse)JSON.deserialize(response.getBody(),TVE_CreateCMArtResponse.class);
                }
            }
            return CAW;
        }
        catch(Exception e){
            CAW=new TVE_CreateCMArtResponse();
            CAW.status='500';
            CAW.statusMessage=e.getMessage() + '\r\n' + e.getStackTraceString();
            return CAW;            
        }
    }
    
    public class CreateArteWrapper {
        
        public String status;
        public String statusMessage;
        public PayloadCAW payloadAW;
    }
    public class PayloadCAW {
        public String responsePayload;
    }
    
    
    public static PartnerResponse callPartnerAG_VW(API_Callout_Headers__mdt apiCallHea,String NotifNumber,String msgID,String soldTo,
                                                   String PartnerRole)
    {
        PartnerResponse PR = new PartnerResponse();
        try{
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('request');
            gen.writeStartObject();
            gen.writeStringField('key', apiCallHea.key__c);
            gen.writeStringField('msgId', TVE_Utility.getUniqueId(msgID));
            gen.writeStringField('sourceSystem',apiCallHea.sourceSystem__c);
            gen.writeStringField('targetSystem', apiCallHea.targetSystem__c);
            gen.writeStringField('objectName',apiCallHea.objectName__c);
            gen.writeFieldName('payload');
            gen.writeStartObject();
            gen.writeFieldName('d');
            gen.writeStartObject();
            gen.writeStringField('NotificationNumber',TVE_IntegUtility.checkString(NotifNumber));
            gen.writeStringField('PartnRole',PartnerRole);
            gen.writeStringField('Partner',TVE_IntegUtility.checkString(soldTo));
            
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
            request.setEndpoint(apiCallHea.endpoint__c);
            request.setMethod('PUT');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('erpKeys',TVE_IntegUtility.checkString(NotifNumber)); 
            if(!Test.isRunningTest())
                response = http.send(request);
            if(response.getstatusCode() == 200 && response.getbody() != null){
                PR=(PartnerResponse)JSON.deserialize(response.getBody(),PartnerResponse.class);
            }
            else
            {
                PR=(PartnerResponse)JSON.deserialize(response.getBody(),PartnerResponse.class);
            }
            return PR;
        }
        catch(Exception e){
            PR.status='500';
            PR.statusMessage=e.getMessage() + '\r\n' + e.getStackTraceString();
            return PR;
        }
        
    }
    
    public class PartnerResponse {
        
        public String status;
        public String statusMessage;
        
        
        public  PartnerResponse parse(String json) {
            return (PartnerResponse) System.JSON.deserialize(json, PartnerResponse.class);
        }
    }
    
}