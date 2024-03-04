/*
    @author  : pavan.dave@ausnetservices.com.au
    @created : 17 Oct 2019
    @Description : Payload response class
    -----------------------------------------------------------------------------------------
    Change log
    -----------------------------------------------------------------------------------------
    Date                  Name                           Description
    -----------------------------------------------------------------------------------------
    NA                    NA                              NA
    05-DEC-2019           PALASH AWASTHI                  Changes for refactoring Payload to 
                                                          include Representative Company node
    -----------------------------------------------------------------------------------------
*/
public with sharing class DER_Payload_Response 
{
    public String error;
    public SuccessResponse success;
    
    public DER_Payload_Response()
    {
        this.success = new SuccessResponse();
    }

    public void setError(String msg)
    {
        this.error = msg;
        this.success = null;
    }

	public String getJSON()
	{
		return JSON.serialize(this);
	}
   
    public class SuccessResponse
    {
        public nmiResponse nmi;        
        public derAppResponse derApp;                 
        public derCaseResponse derCase;
        public List<deviceResponse> devices;
        public customerResponse customer;
        public installerResponse installer;
        public instContResponse installerContact;
        public repResponse representative;
        public repCompResponse representativeCompany;
        
        // ------------------------------------------------ //
        // ---- setter methods for success response-------- //
        // ------------------------------------------------ //
        
        public void setNmiInsert(String sfId)
        {
            this.nmi = new nmiResponse();
            this.nmi.setInsert(sfId);
        }

        public void setNmiUpdate(String sfId, String key)
        {
            this.nmi = new nmiResponse();
            this.nmi.setUpdate(sfId, key);
        }

        public void setDerAppInsert(String sfId)
        {
            this.derApp = new derAppResponse();
            this.derApp.setInsert(sfId);
        }

        public void setDerAppUpdate(String sfId, String key)
        {
            this.derApp = new derAppResponse();
            this.derApp.setUpdate(sfId, key);
        }

        public void setDerCaseInsert(String sfId, String key)
        {
            this.derCase = new derCaseResponse();
            this.derCase.setInsert(sfId, key);
        }

        public void setDerCaseUpdate(String sfId, String key)
        {
            this.derCase = new derCaseResponse();
            this.derCase.setUpdate(sfId, key);
        }

        public void setDeviceInsert(String sfId)
        {
            deviceResponse dev = new deviceResponse();
            dev.setInsert(sfId);

            if(this.devices != null)
            {
                this.devices.add(dev);
            }
            else 
            {
                this.devices = new List<deviceResponse>{dev};
            }            
        }

        public void setDeviceUpdate(String sfId, String key)
        {
            deviceResponse dev = new deviceResponse();
            dev.setUpdate(sfId, key);

            if(this.devices != null)
            {
                this.devices.add(dev);
            }
            else 
            {
                this.devices = new List<deviceResponse>{dev};
            }      
        }

        public void setCustomerInsert(String sfId)
        {
            this.customer = new customerResponse();
            this.customer.setInsert(sfId);
        }

        // ONLY TO BE USED WHILE UPDATING APPLICATION WHERE CASE TYPE IS MANUAL
        public void setCustomerUpdate(String sfId, String key)
        {
            this.customer = new customerResponse();
            this.customer.setUpdate(sfId, key);
        }

        public void setInstallerInsert(String sfId)
        {
            this.installer = new installerResponse();
            this.installer.setInsert(sfId);
        }

        public void setInstallerUpdate(String sfId, String key)
        {
            this.installer = new installerResponse();
            this.installer.setUpdate(sfId, key);
        }

        public void setInstContInsert(String sfId)
        {
            this.installerContact = new instContResponse();
            this.installerContact.setInsert(sfId);
        }

        public void setInstContUpdate(String sfId, String key)
        {
            this.installerContact = new instContResponse();
            this.installerContact.setUpdate(sfId, key);
        }

        public void setRepInsert(String sfId)
        {
            this.representative = new repResponse();
            this.representative.setInsert(sfId);
        }

        public void setRepUpdate(String sfId, String key)
        {
            this.representative = new repResponse();
            this.representative.setUpdate(sfId, key);
        }

        public void setRepCompInsert(String sfId)
        {
            this.representativeCompany = new repCompResponse();
            this.representativeCompany.setInsert(sfId);
        }

        public void setRepCompUpdate(String sfId, String key)
        {
            this.representativeCompany = new repCompResponse();
            this.representativeCompany.setUpdate(sfId, key);
        }       
    }

    // ------------------------------------------------ //
    // ---- inner classes for success response -------- //
    // ------------------------------------------------ //
    
    public class nmiResponse
    {
        public RecordInserted insertDetail;
        public RecordUpdated updateDetail;

        public void setInsert(Id sfId)
        {
            this.insertDetail = new RecordInserted();
            this.insertDetail.Id = sfId;
        }

        public void setUpdate(Id sfId, String key)
        {
            this.updateDetail = new RecordUpdated();
            this.updateDetail.Id = sfId;
            this.updateDetail.key = key;
        }
    }

    public class derCaseResponse
    {
        public RecordInserted insertDetail;
        public RecordUpdated updateDetail;

        public void setInsert(Id sfId)
        {
            this.insertDetail = new RecordInserted();
            this.insertDetail.Id = sfId;
        }

        public void setInsert(Id sfId, String key)
        {
            this.insertDetail = new RecordInserted();
            this.insertDetail.Id = sfId;
            this.insertDetail.key = key;
        }

        public void setUpdate(Id sfId, String key)
        {
            this.updateDetail = new RecordUpdated();
            this.updateDetail.Id = sfId;
            this.updateDetail.key = key;
        }
    }

    public class derAppResponse
    {
        public RecordInserted insertDetail;
        public RecordUpdated updateDetail;

        public void setInsert(Id sfId)
        {
            this.insertDetail = new RecordInserted();
            this.insertDetail.Id = sfId;
        }

        public void setUpdate(Id sfId, String key)
        {
            this.updateDetail = new RecordUpdated();
            this.updateDetail.Id = sfId;
            this.updateDetail.key = key;
        }
    }
    
    public class deviceResponse
    {
        public RecordInserted insertDetail;
        public RecordUpdated updateDetail;

        public deviceResponse()
        {

        }

        public deviceResponse(String sfId)
        {                        
        	this.setInsert(sfId);
        }

        public deviceResponse(String sfId, String key)
        {            
        	this.setUpdate(sfId, key);
        }        

        public deviceResponse setInsert(Id sfId)
        {
            this.insertDetail = new RecordInserted();
            this.insertDetail.Id = sfId;
            return this;
        }

        public deviceResponse setUpdate(Id sfId, String key)
        {
            this.updateDetail = new RecordUpdated();            
            this.updateDetail.Id = sfId;
            this.updateDetail.key = key;
            return this;
        }        
    }

    public class customerResponse
    {
        // As per business rules customer will always inserted
        // public String sfId;        
        public RecordInserted insertDetail;
        public RecordUpdated updateDetail;

        public void setInsert(Id sfId)
        {
            this.insertDetail = new RecordInserted();        
            this.insertDetail.Id = sfId;
        }        
        public void setUpdate(String sfId, String key)
        {
            this.updateDetail = new RecordUpdated();        
            this.updateDetail.Id = sfId;
            this.updateDetail.key = key;
        }        
    }

    public class installerResponse
    {
        public RecordInserted insertDetail;
        public RecordUpdated updateDetail;

        public void setInsert(Id sfId)
        {
            this.insertDetail = new RecordInserted();
            this.insertDetail.Id = sfId;
        }

        public void setUpdate(Id sfId, String key)
        {
            this.updateDetail = new RecordUpdated();
            this.updateDetail.Id = sfId;
            this.updateDetail.key = key;
        }
    }

    public class instContResponse
    {
        public RecordInserted insertDetail;
        public RecordUpdated updateDetail;

        public void setInsert(Id sfId)
        {
            this.insertDetail = new RecordInserted();
            this.insertDetail.Id = sfId;
        }

        public void setUpdate(Id sfId, String key)
        {
            this.updateDetail = new RecordUpdated();
            this.updateDetail.Id = sfId;
            this.updateDetail.key = key;
        }
    }

    public class repResponse
    {
        public RecordInserted insertDetail;
        public RecordUpdated updateDetail;

        public void setInsert(Id sfId)
        {
            this.insertDetail = new RecordInserted();
            this.insertDetail.Id = sfId;
        }

        public void setUpdate(Id sfId, String key)
        {
            this.updateDetail = new RecordUpdated();
            this.updateDetail.Id = sfId;
            this.updateDetail.key = key;
        }
    }

    public class repCompResponse
    {
        public RecordInserted insertDetail;
        public RecordUpdated updateDetail;

        public void setInsert(Id sfId)
        {
            this.insertDetail = new RecordInserted();
            this.insertDetail.Id = sfId;
        }

        public void setUpdate(Id sfId, String key)
        {
            this.updateDetail = new RecordUpdated();
            this.updateDetail.Id = sfId;
            this.updateDetail.key = key;
        }
    }

    public class RecordInserted
    {
        public String Id;
        public String key;
    }

    public class RecordUpdated
    {
        public String Id;
        // mutliple keys can be added using + sign
        // like for installerContact there are two keyes Acceditation_Type__c = CEC & Accreditation_Number__c=3333 
        // so this key will be: CEC+3333
        public String key;    
    }

}