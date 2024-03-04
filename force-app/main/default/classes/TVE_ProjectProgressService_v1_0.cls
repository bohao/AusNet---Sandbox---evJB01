/*
@author  : pavan.dave@ausnetservices.com.au
@created : 16 Dec 2019
@Description : REST based webservice for accessing/updating the Project record
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
17-Mar-2020     dave.pavan@in.ibm.com               TV-2094
-----------------------------------------------------------------------------------------
*/
@RestResource(urlMapping='/v1.0/tve/projectprogressbar/*')
global with sharing class TVE_ProjectProgressService_v1_0 {
    
    @HttpGet
	global static void doGet() {
		String resBody = '';
		String errBody = '';
        Integer resStatuCode = 403;

		JSONGenerator gen = JSON.createGenerator(false);
		
		System.debug('TVE_REST_ProjectService_v1_0----------------->doGet');

		String projId = RestContext.request.params.get('id');		
        System.debug('Id----------------->'+projId);

        //Call resuable method to get progress JSON
		TVE_ProgressServiceResponse resp = getProgress(projId);
		
        resBody = JSON.serialize(resp);
        
        if(resp.success != null)
            resStatuCode = 200;

        RestContext.response.statusCode = resStatuCode;                  
		RestContext.response.addHeader('Content-Type', 'application/json;');
		RestContext.response.responseBody = Blob.valueOf(resBody);
	}
    
    public static TVE_ProgressServiceResponse getProgress(String prjId)
    {
        TVE_ProgressServiceResponse response = new TVE_ProgressServiceResponse();
        
        String resBody = '';
		String errBody = '';
        Boolean isParamMissing = false;
		
        //isBlank validates null, blank and white space values
		if(String.isBlank(prjId)){
			errBody = 'Id, ';
			isParamMissing = true;
		}

		if(isParamMissing)
        {
            response.setError('Required Parameter(s) missing - ' + errBody.substringBeforeLast(','));
		}
        else
        {
            List<TVE_Project_Progress__mdt> projProgressList = [SELECT Order__c, Status__c, Type__c, 
                                                                            Display_Date__c, Days__c, DateField__c,
                                                                            OfferType__c, PaymentMethod__c 
                                                                    FROM TVE_Project_Progress__mdt                                                                    
                                                                    ORDER BY Order__c];


            Set<String> lstDateFields = new Set<String>();                                                                    
            for(TVE_Project_Progress__mdt item: projProgressList)
            {
                if(item.DateField__c != null)
                {
                    lstDateFields.add(item.DateField__c);
                }
            }

            String projQuery = 'SELECT Id, CMNumber__c, CreatedDate, CMProgressBar__c, Name, '+
                                'ContestabilityType__c, OfferType__c, ApplicationPaymentMethod_fx__c, ';
            
            for(String item: lstDateFields)
            {
                projQuery = projQuery + item + ', ';
            }

            if(!lstDateFields.isEmpty())
            {
                projQuery = projQuery.removeEnd(', ');
            }

            projQuery = projQuery + ' FROM Project__c WHERE Id = \'' + prjId + '\'';
            
            System.debug('projQuery--->'+projQuery);

            List<Project__c> lstProj;

            try 
            {
                lstProj = Database.query(projQuery);
            } 
            catch(QueryException e)
            {
                String queryExcepMsg = e.getMessage();                
                
                if(queryExcepMsg.contains('No such column '))
                {
                    errBody  = queryExcepMsg + ' SUGGESTION: Wrong API Name might has been setup in Custom Metadata Type -> TVE_Project_Progress__mdt, '+
                                'Field -> DateField__c.';                
                }
                else 
                {
                    errBody = queryExcepMsg;    
                }

                System.debug(errBody);                                    

                response.setError(errBody);                                     
            }
            
            if(String.isBlank(errBody))
            {
                if(lstProj.isEmpty())
                {
                    response.setError('No Record(s) Found');
                }
                else 
                {
                    Project__c proj;
                    proj = lstProj[0];
                    if(String.isBlank(proj.CMProgressBar__c) || 
                    String.isBlank(proj.ContestabilityType__c) || 
                    String.isBlank(proj.OfferType__c) ||
                    String.isBlank(proj.ApplicationPaymentMethod_fx__c))
                    {
                        response.setError('Required Project field(s) are missing!!');    
                    }
                    else 
                    {
                        List<TVE_Project_Progress__mdt> matchedProjProgressLst  = new List<TVE_Project_Progress__mdt>();
    
                        for(TVE_Project_Progress__mdt item: projProgressList)
                        {
                            if(item.Type__c == proj.ContestabilityType__c &&
                                    item.OfferType__c == proj.OfferType__c &&
                                    item.PaymentMethod__c == proj.ApplicationPaymentMethod_fx__c)
                            {
                                matchedProjProgressLst.add(item);
                            }
                        }
    
                        if(matchedProjProgressLst.isEmpty())
                        {
                            response.setError('No TVE Project Progress records found!!');
                        }
                        else 
                        {
                            List<TVE_ProgressServiceResponse.ProgressBarItem> wrapList = new List<TVE_ProgressServiceResponse.ProgressBarItem>();        
                            TVE_ProgressServiceResponse.ProgressBarItem newItem;
                            Boolean hasCurrentStatusFound = false;                                                
                            integer i = 0;
                            DateTime final_eta;
    
                            for(TVE_Project_Progress__mdt item: matchedProjProgressLst)
                            {
                                newItem = new TVE_ProgressServiceResponse.ProgressBarItem();
                                newItem.stepNumber = Integer.valueof(item.Order__c);                            
                                
                                final_eta = calcETA(item, proj);             
                                                                
                                if(item.Order__c == 1)
                                    newItem.isFirst = true;
                                else
                                    newItem.isFirst = false;
                                
                                newItem.statusTitle = item.Status__c;
                                                            
                                if(item.Status__c == proj.CMProgressBar__c && matchedProjProgressLst.size()==(i+1))
                                {
                                    newItem.isCurrentStatus = false;
                                    hasCurrentStatusFound = true;
                                    newItem.estimatedCompletionDate = final_eta;
                                    newItem.isCompleteStatus = true;
                                    newItem.isFutureStatus = false; 
                                }
                                else if(item.Status__c == proj.CMProgressBar__c)
                                {
                                    newItem.isCurrentStatus = true;
                                    hasCurrentStatusFound = true;
                                    newItem.estimatedCompletionDate = final_eta;
                                    newItem.isCompleteStatus = false;
                                    newItem.isFutureStatus = false;                                                                                        
                                }
                                else 
                                {
                                    newItem.isCurrentStatus = false;    
                                    if(hasCurrentStatusFound){
                                        newItem.isCompleteStatus = false;
                                        newItem.isFutureStatus = true;
                                    }else{
                                        newItem.isCompleteStatus = true;
                                        newItem.isFutureStatus = false;
                                    }
                                }
                                wrapList.add(newItem);
                                i++;                                                   
                            }
    
                            if(String.isNotEmpty(errBody))
                            {
                                response.setError(errBody);                                                        
                            }
                            else 
                            {
                                if(hasCurrentStatusFound)
                                {
                                    //all good             
                                    response.success.referenceNumber = proj.Name;
                                    response.success.submittedDate = proj.CreatedDate;                           
                                    response.success.statusList = wrapList;
                                }
                                else
                                {
                                    response.setError('Invalid combination of CMProgressBar__c & ContestabilityType__c');                            
                                }
                            }                        
                        }    
                    }                                               
                }		   
            }           	
		}
        return response;
    }

    //TV-2094
    public static DateTime calcETA(TVE_Project_Progress__mdt progRecord, Project__c prj)
    {
        DateTime eta;
        if(progRecord.Display_Date__c && progRecord.Days__c != null && progRecord.DateField__c != null) 
        {                            
            if(prj.get(progRecord.DateField__c) != null)
            {
                eta = (DateTime)prj.get(progRecord.DateField__c);
                eta = eta.addDays(progRecord.Days__c.intValue());                                                   
            }
            else
            {
                System.debug('TVE_ProjectProgressService_v1_0 ------> calcETA() ----> ETA not calculated');
            }       
        }
        else
        {
            System.debug('TVE_ProjectProgressService_v1_0 ------> calcETA() ----> ETA not calculated');
        }
        return eta;
    }
}