global class OS_FnP_WestPacPaymentGW implements vlocity_cmt.VlocityOpenInterface {
    //    public static String INTEGRATION_LOG_RECORDTYPE = 'Electrical';
        public Boolean invokeMethod(String methodName, Map<String,Object> inputMap, Map<String,Object> outMap, Map<String,Object> options) {
        Boolean result = true;
            try
            {
                if (methodName.equals('postPaymentWestPac')){
                    postPaymentWestPac(inputMap,outMap,options);
                }
                else if(methodName.equals('populateExpiryYears')){
                    populateExpiryYears(inputMap,outMap, options);
                }
                else if(methodName.equals('getFirmOfferForElecForm')){
                    getFirmOfferForElecForm(inputMap,outMap, options);
                }
            }
            catch(Exception excep)
            {
                System.debug('OS_FnP_WestPacPaymentGW:invokeMethod -> exception: '+excep);
                System.debug('linenumber -> exception: '+excep.getLinenumber());
                throw excep;
            }
            return result;
        }
    
        public static void postPaymentWestPac(Map<String, Object> inputMap,Map<String, Object> outMap,Map<String, Object> options) {
            
            String methodname = 'postPaymentWestPac';
            String operation = 'Get';
            System.debug('postPaymentWestPac output:'+JSON.serializePretty(outMap));
            System.debug('postPaymentWestPac input:'+JSON.serializePretty(inputMap));
    
            try {
                HTTP http = new HTTP();
                HttpRequest httpReq = new HttpRequest();
                String reqBody = null;
                String supplierCode = ''; 
                String cardHolderName  = '';
                String cardNumber = '';
                String expiryDateMon = '';
                String expiryDateYr  = '';
                String cvn = '';
                Double paymentAmt = 0.0;
                String singleUseToken = null;
                // Custom settings
                WestPacKey__c wpKey = WestPacKey__c.getOrgDefaults();
                System.debug('wpKey'+wpKey);
    
                if (inputMap.containsKey('payDtls')) {
                    Map<String,Object>paydetails=((Map<String, Object>)inputMap.get('payDtls'));
                    Map<String, Object> mapDtls = ((Map<String, Object>)paydetails.get('Block1'));
                    cardHolderName = (String) mapDtls.get('cardholderName');
                    cardNumber = (String) mapDtls.get('cardNumber');
                    expiryDateMon = (String) mapDtls.get('expiryDateMonth');
                    expiryDateYr = (String) mapDtls.get('expiryDateYear');
                    cvn = (String) mapDtls.get('cvn');
                    String payAmtStr = (String)mapDtls.get('paymentAmt');
                    payAmtStr = payAmtStr != null ? payAmtStr.replace(',' ,'') : null;
                    payAmtStr = payAmtStr != null ? payAmtStr.replace('$', '') : null;
                    System.debug('payAmtStr' + payAmtStr);
                    paymentAmt = Double.valueOf(payAmtStr);
                    System.debug('Pay Amount' + paymentAmt);
                }
    
                reqBody = '{ "supplierBusinessCode" : "' + wpKey.supplierCode__c + '",';
                reqBody = reqBody + '"accountType" : "CREDIT_CARD",' ;
                reqBody = reqBody + '"cardholderName" : "'+ cardHolderName + '",' ;
                reqBody = reqBody + '"cardNumber" : "' + cardNumber + '",' ;
                reqBody = reqBody + '"expiryDateMonth": "' + expiryDateMon + '",';
                reqBody = reqBody + '"expiryDateYear": "' + expiryDateYr + '",';
                reqBody = reqBody + '"cvn": "' + cvn + '"},';
                httpReq.setEndpoint('callout:WestPac/single-use-tokens');
                httpReq.setMethod('POST');
                string username = wpKey.publishableKey__c;
                string password='';
                Blob headerValue = Blob.valueOf(username + ':' + password);
                String authHeader =  'Basic ' + EncodingUtil.base64Encode(headerValue);
                
                httpReq.setHeader('Accept', '*/*');
                httpReq.setHeader('Content-Type', 'application/json');
                httpReq.setHeader('Authorization', authHeader);
                httpReq.setBody(reqBody);
                HttpResponse response = http.send(httpReq);
    
                if (response.getStatusCode() != 200) {
                    System.debug('Single use token status code returned was not expected: ' +
                                 response.getStatusCode() + ' ' + response.getStatus());
                    outMap.put('httpTokenResponseError',JSON.deserializeUntyped(response.getBody()));
                    FnP_ExtUserObjAccessUtility.integrationlog('log\n'+response.getBody(),'ElectricalFormRecordType',methodname,reqBody,operation);
                    
                    return;
                } else {
                    System.debug('Single use token No Error Line 1' + response.getBody());
                    System.debug('Single use token No Error Line 2' + response.getHeaderKeys());
                    outMap.put('httpTokenResponse',JSON.deserializeUntyped(response.getBody()));
                }
    
                singleUseToken = (String)response.getBody();
                Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(singleUseToken);
                singleUseToken = (String)jsonMap.get('singleUseTokenId');
                /* Get ip address */
                HttpRequest request = new HttpRequest();
                request.setEndpoint('https://api.ipify.org');
                request.setMethod('GET');
                Http http1 = new Http();
                HttpResponse response1 = http.send(request);
                String responseBody = response1.getBody();
                System.debug('Your Org current IP Address: ' + responseBody);
                
                /* Form Req body agian */
                httpReq = new HttpRequest();
                response = new HttpResponse();
                reqBody = '{"transactionType": "PAYMENT","singleUseTokenId":"' + singleUseToken + '","supplierBusinessCode":"' +wpKey.supplierCode__c + '","principalAmount": "'+paymentAmt+'","currency" : "AUD","eci": "INTERNET","ipAddress":"'+ responseBody + '"}';
                System.debug('Transaction Req Body'+reqBody);
                username = wpKey.publishableSecret__c;
                password='';
                headerValue = Blob.valueOf(username + ':' + password);
                authHeader =  'Basic ' + EncodingUtil.base64Encode(headerValue);
                httpReq.setEndpoint('callout:WestPac/transactions');    
                httpReq.setMethod('POST');
                httpReq.setHeader('Accept', '*/*');
                httpReq.setHeader('Content-Type', 'application/json');
                httpReq.setHeader('Authorization', authHeader);
                httpReq.setBody(reqBody);
                response = http.send(httpReq);
    
                if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
                    System.debug('Transaction The status code returned was not expected: ' +
                                 response.getStatusCode() + ' ' + response.getStatus());
                    outMap.put('httpTranResponseError',JSON.deserializeUntyped(response.getBody()));
                    FnP_ExtUserObjAccessUtility.integrationlog(response.getStatusCode()+'\n'+response.getBody(),'ElectricalFormRecordType',methodname,reqBody,operation);
                    return;
                } else {
                    System.debug('Transaction No Error Line 1' + response.getBody());
                    System.debug('Transaction No Error Line 2' + response.getHeaderKeys());
                    outMap.put('httpTranResponse',JSON.deserializeUntyped(response.getBody())); 
                }
    
                Map<String, object> httpTranResponseMap = (Map<String, object>)outMap.get('httpTranResponse');
                String reciept;
    
                if (httpTranResponseMap.containsKey('receiptNumber')) {
                    reciept = (String)httpTranResponseMap.get('receiptNumber');
                }
                outMap.put('receiptNumber',reciept);
                if (reciept == null) {
                    FnP_ExtUserObjAccessUtility.integrationlog('Empty Receipt Number: '+reciept,'ElectricalFormRecordType',methodname,reqBody,operation);
                }
                else {
                    FnP_ExtUserObjAccessUtility.integrationLogSuccess(reciept,JSON.serialize(httpTranResponseMap),'ElectricalFormRecordType',methodname,reqBody,operation);   
                }
            }
            catch(Exception ex) {
                
                String exceptionResult = ex.getMessage()+'\n'+ex.getStackTraceString()+'\n'+ex.getLineNumber();
                System.debug(LoggingLevel.ERROR, 'Exception '+methodname+':\n'+exceptionResult);
                FnP_ExtUserObjAccessUtility.integrationlog(exceptionResult,'ElectricalFormRecordType',methodname,JSON.serialize(inputMap),operation);
            }
        }
        
        public void getFirmOfferForElecForm(Map<String, Object> inputMap,Map<String, Object> outMap,Map<String, Object> options){
            string operation = 'GET';
            string methodname ='getFirmOfferForElecForm';
            string mapdetails = JSON.serialize(inputMap);
            WestPacKey__c wpKey = WestPacKey__c.getOrgDefaults();
    
            try{
                HTTP http = new HTTP();
                HttpRequest httpReq = new HttpRequest();
                String reqBody = '';
                if (inputMap.containsKey('GetFirmOfferRequest')) {
                    Map<String,Object>inputDetails=((Map<String, Object>)inputMap.get('GetFirmOfferRequest'));
                    // Populate Req body here... from the inputMap.
                    reqBody = JSON.serialize(inputDetails);
                    System.debug('ReqBody from Omniscript'+JSON.serializePretty(inputDetails));
                }
                // Named Credentials end point
                httpReq.setEndpoint(wpKey.endPoint__c);        
                httpReq.setMethod('POST');
                
                httpReq.setHeader('Accept', '*/*');
                httpReq.setHeader('Content-Type', 'application/json');
                
                httpReq.setBody(reqBody);
                system.debug('reqBody-->'+reqBody);
                httpReq.setTimeout(60000);
                HttpResponse response = http.send(httpReq);
                if (response.getStatusCode() != 200) {
                    System.debug('COST Calculator Response endpoint'+ httpReq.getEndpoint());
                    System.debug('Cost Calculator Response status code returned was not expected: ' +
                                 response.getStatusCode() + ' and status ' + response.getStatus() + ' and body ' + response.getBody());
                    outMap.put('httpTokenResponseErr',JSON.deserializeUntyped(response.getBody())); 
                    FnP_ExtUserObjAccessUtility.integrationlog(response.getBody(),'ElectricalFormRecordType',methodname,reqBody,operation);
                    return;
                } else {
                    System.debug('Cost Calculator No Error Line 1' + response.getBody());
                    System.debug('Cost Calculator No Error Line 2' + response.getHeaderKeys());
                    outMap.put('httpTokenResponse',JSON.deserializeUntyped(response.getBody())); 
                    FnP_ExtUserObjAccessUtility.integrationLogSuccess(null,response.getBody(),'ElectricalFormRecordType',methodname,reqBody,'Get');
                }
            }
            catch (Exception ex) {
                String exceptionResult = ex.getMessage()+'\n'+ex.getStackTraceString()+'\n'+ex.getLineNumber();
                System.debug(LoggingLevel.ERROR, 'Exception '+methodname+':\n'+exceptionResult);
                FnP_ExtUserObjAccessUtility.integrationlog(exceptionResult,'ElectricalFormRecordType',methodname,mapdetails,operation);
            }
        }
        
        public void populateExpiryYears(Map<String, Object> inputMap,Map<String, Object> outMap,Map<String, Object> options) {
    
            Integer year = Date.Today().Year();
            String yearStr = String.valueOf(year);
            List<Map<String,Object>> expiryYears = new List<Map<String,Object>>();
            Map<String,String> expiryYear = new Map<String,String>();
    
            for (integer a=0; a<10; a++) {
    
                expiryYear.put('name',yearStr);
                expiryYear.put('value',yearStr);
                expiryYears.add(expiryYear);
                year = year+1;
                yearStr = String.valueOf(year);
                expiryYear = new Map<String,String>();
            }
    
            outMap.put('options', expiryYears);
        }
    }