/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 13 Jan 2020
  @Description : Class for Artefact__c Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
 11 March             Lakshay Sharma                            NA
  -----------------------------------------------------------------------------------------
*/
public with sharing class Trig_Artefact implements UtilTrigHandle{
    // *********************************************************************
	// *** Disable logic
    public static ID invoiceRecordType = Schema.SObjectType.Artefact__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();
	public static Boolean TrigDisabled = false;
	
	public Boolean IsDisabled()
	{
		if (TrigSettings__c.getInstance().Artefact_Trigger_Disabled__c)
			return true;
		else
			return TrigDisabled;
	}

	// *********************************************************************
	// *** Trigger contexts

	public void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs) 
    {
        Qualify_PopulateRecordTypeId(newSObjs.values(), oldSObjs.values());       
        Qualify_PopulateAccount(newSObjs.values(), oldSObjs.values());
    }

    public void BeforeInsert(List<SObject> newSObjs)
    {
        Qualify_PopulateRecordTypeId(newSObjs, null);
        Qualify_PopulateAccount(newSObjs, null);
    }

	// if context is not implemented, condense into one-liners
	public void AfterDelete(Map<Id, SObject> oldSObjs) {}
	public void AfterUndelete(Map<Id, SObject> newSObjs) {}
    public void AfterInsert(Map<Id, SObject> newSObjs) 
    {
        Qualify_UpdateOwnerStatus(newSObjs.values(),null);
        Qualify_DueDatePopup(newSObjs.values());
        Qualify_EPaymentLinkPopup(newSObjs.values(),null);
        //added by Neha for TV-1200
        Qualify_SendArteToSap(newSObjs.values(), null);
        //added by Palash for TV - 2017
        Qualify_RequestInvoiceInteg(newSObjs.values());
    }
	public void BeforeDelete(Map<Id, SObject> oldSObjs) {
         Qualify_DeleteRelatedFile(null,oldSObjs);
    }
	public void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs){
        Qualify_UpdateOwnerStatus(newSObjs.values(),oldSObjs);
        Qualify_EPaymentLinkPopup(newSObjs.values(),oldSObjs);
        Qualify_SendArteToSap(newSObjs.values(), oldSObjs);
    }
    
	// *********************************************************************
	// *** Trigger methods

    //---------------------------------------------------------------------------------//
    //----- Validate Artefact__c reocrds for Populating Record Type on Artefact__c ----//
    //---------------------------------------------------------------------------------//
    
    private static void Qualify_DueDatePopup(List<Sobject> newSobjs)
    {
        List <Artefact__c>validArtefacts=new List<Artefact__c>();
        Artefact__c newArtfct;
        switch on Trigger.operationType {
            when AFTER_INSERT {
              for(sObject sObjItem: newSObjs)
             {
               newArtfct = (Artefact__c)sObjItem;
               if(newArtfct.DueDate__c !=null && newArtfct.Recordtypeid!=null)
               validArtefacts.add(newArtfct);
             }
            }
        }
        if(!validArtefacts.isEmpty())
        {
            TVE_Artefact_Util.DueDatePopup(validArtefacts);
        }
    

    }
    private static void Qualify_EPaymentLinkPopup(List<SObject> newSobjs, Map<Id,SObject> oldSObjs)
    {
        List<Artefact__c> validArtefacts = new List<Artefact__c>();
        
        switch on Trigger.operationType {
            when AFTER_INSERT {
                for(SObject sObjItem: newSObjs) {
                    Artefact__c newArtfct = (Artefact__c)sObjItem;
                    if(newArtfct.RecordTypeId == invoiceRecordType && newArtfct.Electronic_Payment_Link__c != null) {
                        validArtefacts.add(newArtfct);
                    }
                }
            }
            when AFTER_UPDATE {
                for(SObject sObjItem: newSObjs) {
					Artefact__c newArtfct = (Artefact__c)sObjItem;
                    Artefact__c oldArtfct = (Artefact__c)oldSObjs.get(newArtfct.Id);

                    if(newArtfct.RecordTypeId == invoiceRecordType && isPopulated('Electronic_Payment_Link__c', newArtfct, oldArtfct)) {
                        validArtefacts.add(newArtfct);
                    }
                }
            }
        }
        if(!validArtefacts.isEmpty())
        {
            TVE_Artefact_Util.EPaymentLinkPopup(validArtefacts);
        }
    }
		
	private static void  Qualify_PopulateRecordTypeId(List<SObject> newSObjs, List<SObject> oldSObjs)
    {
        System.debug('*** Trig_Artefact.Qualify_PopulateRecordTypeId()');

		Map<Id, Artefact__c> validArtefacts = new Map<Id, Artefact__c>();
        Map<Id, SObject> mapOldSObjs = new Map<Id, SObject>();
        Artefact__c newArtfct;

        switch on Trigger.operationType {
            when BEFORE_INSERT {
                for(sObject sObjItem: newSObjs)
                {
					newArtfct = (Artefact__c)sObjItem;
                    validArtefacts.put(newArtfct.Id, newArtfct);                                                            
                }
            }
            when BEFORE_UPDATE {
                for(SObject sObjItem: oldSObjs)
                {
                    mapOldSObjs.put(sObjItem.Id, sObjItem);
                }

                for(sObject sObjItem: newSObjs)
                {
					newArtfct = (Artefact__c)sObjItem;
                    Artefact__c oldArtfct = (Artefact__c)mapOldSObjs.get(newArtfct.Id);

                    if(isPopulated('Classification__c', newArtfct, oldArtfct) )
                    {
                        validArtefacts.put(newArtfct.Id, newArtfct);                                                            
                    }
                }
            }
        }
        if(!validArtefacts.isEmpty())
            TVE_Artefact_Util.PopulateRecordTypeId(validArtefacts);

    }	
    
    //----------------------------------------------------------------------------//
    //----- Validate Artefact__c reocrds for Populating Account on Artefact ------//
    //----------------------------------------------------------------------------//
		
	private static void Qualify_PopulateAccount(List<SObject> newSObjs, List<SObject> oldSObjs)
    {
		Map<Id, Artefact__c> validArtefacts = new Map<Id, Artefact__c>();
        Artefact__c newArtfct;

        switch on Trigger.operationType {
            when BEFORE_INSERT {
                for(sObject sObjItem: newSObjs)
                {
					newArtfct = (Artefact__c)sObjItem;
                    if(newArtfct.Project__c != null)
                    {
                        validArtefacts.put(newArtfct.Id, newArtfct);                                                            
                    }                    
                }
            }
            when BEFORE_UPDATE {
                for(sObject sObjItem: newSObjs)
                {
					newArtfct = (Artefact__c)sObjItem;
                    if(newArtfct.Account__c == null || newArtfct.Payer__c == null)
                    {
                        validArtefacts.put(newArtfct.Id, newArtfct);
                    }
                }
            }
        }
        if(!validArtefacts.isEmpty())
            TVE_Artefact_Util.PopulateAccount(validArtefacts);

    }

    //------------------------------------------------------------------------------------//
    //----- Validate Artefact__c reocrds of Invoice Record type for SAP Integration ------//
    //------------------------------------------------------------------------------------//
    private static void Qualify_RequestInvoiceInteg(List<Sobject> newSobjs){

        System.debug('@#@#@#@#@#@#Inside Qualify_RequestInvoiceInteg'+newSobjs);
        List<Artefact__c> validArtefacts=new List<Artefact__c>();
        Artefact__c newArtfct;
        switch on Trigger.operationType {
            when AFTER_INSERT {
                for(sObject sObjItem: newSObjs){
                    newArtfct = (Artefact__c)sObjItem;
                    if(newArtfct.Source__c != 'SAP' && newArtfct.RecordtypeId == invoiceRecordType && newArtfct.Additional_Invoice__c == true){
                        validArtefacts.add(newArtfct);
                    }
                }
            }
        }
        System.debug('----Valid Artfct list is---------'+validArtefacts);
        if(!validArtefacts.isEmpty())
        {System.debug('Artfct list is not empty#######'+validArtefacts);
            TVE_Artefact_Util.RequestInvoiceInteg(validArtefacts);
        }

    }
    
    // ---------------------------------------------------//
	//------- Artefact__c Trigger utility methods ---------------//
	// ---------------------------------------------------//

	private static Boolean isCleared(String f, Artefact__c newArtfct, Artefact__c oldArtfct)
	{
		return String.isBlank((String)newArtfct.get(f)) && ((String)newArtfct.get(f)) != ((String)oldArtfct.get(f));					
	}

	private static Boolean isPopulated(String f, Artefact__c newArtfct, Artefact__c oldArtfct)
	{
		return String.isNotBlank((String)newArtfct.get(f)) && ((String)newArtfct.get(f)) != ((String)oldArtfct.get(f));
	}
    
     private static void Qualify_DeleteRelatedFile(Map<Id, SObject> newSObj, Map<Id, SObject> oldSObj)
    {
        string recordTypeContract = Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get('Contract').getRecordTypeId();
        List <id>validArtefacts=new List<id>();
        Artefact__c newArtfct;
        switch on Trigger.operationType {
            when BEFORE_DELETE {
                for(Id sObjItem: oldSObj.keySet())
                {
                    newArtfct = (Artefact__c)oldSObj.get(sObjItem);
                    system.debug('newArtfct'+newArtfct);
                    if(newArtfct.recordTypeId != recordTypeContract ){
                        validArtefacts.add(newArtfct.Id);
                    }
                }
            }
        }
        system.debug('validArtefacts'+validArtefacts);
        if(!validArtefacts.isEmpty())
        {
            TVE_Artefact_Util.DeleteRelatedFile(validArtefacts);
        }


    }

    //Method to send Artefact to SAP
     private static void Qualify_SendArteToSap(List<Sobject> newSobjs, Map<Id,SObject> oldSObjs)
     {
         Id artefactRTId =Schema.SObjectType.Artefact__c.getRecordTypeInfosByDeveloperName().get('Invoice').getRecordTypeId();
         List<Artefact__c> qualifiedArtefact = new List<Artefact__c>(); 
         Artefact__c newArtfct= new Artefact__c();
         
          
          switch on Trigger.operationType {
            when AFTER_INSERT {
                for(sObject sObjItem: newSObjs) {
                    newArtfct = (Artefact__c)sObjItem;
                    if(newArtfct.Source__c != 'SAP' && newArtfct.Recordtypeid != artefactRTId && newArtfct.Name != 'Dummy')
               		    qualifiedArtefact.add(newArtfct);
                }
            }
            when AFTER_UPDATE {
                for(sObject sObjItem: newSObjs) {
					newArtfct = (Artefact__c)sObjItem;
                    Artefact__c oldArtfct = (Artefact__c)oldSObjs.get(newArtfct.Id);

                    if(newArtfct.Name != 'Dummy' && oldArtfct.Name == 'Dummy') {
                        qualifiedArtefact.add(newArtfct);
                    }
                }
            }
        }
         if(qualifiedArtefact.size()>0)
         {
         	TVE_Artefact_Util.SendArteToSap_NonInvoice(qualifiedArtefact);
         }
     }

     private static void Qualify_UpdateOwnerStatus(List<Sobject> newSobjs,Map<Id,SObject> oldSObjs){
        List <Artefact__c>validArtefacts=new List<Artefact__c>();
        List<Id> ParentId=new List<Id>();
        Artefact__c newArtfct;
        Artefact__c oldArtfct;
         
        switch on Trigger.operationType {
            when AFTER_UPDATE {
              for(sObject sObjItem: newSObjs)
             {
               newArtfct = (Artefact__c)sObjItem;
               oldArtfct = (Artefact__c)oldSObjs.get(newArtfct.Id);
               if(newArtfct.InvoicePaidDate__c !=null && (oldArtfct.InvoicePaidDate__c != newArtfct.InvoicePaidDate__c) && newArtfct.Recordtypeid==invoiceRecordType /*&& newArtfct.Project__r.ProjectAssigmentStatus__c  == 'Payment Pending'*/)
               validArtefacts.add(newArtfct);
               ParentId.add(newArtfct.Project__c);

             }
             
            }
            when AFTER_INSERT{
                for(sObject sObjItem: newSObjs)
             {
               newArtfct = (Artefact__c)sObjItem;
               if(newArtfct.InvoicePaidDate__c != null && newArtfct.Recordtypeid==invoiceRecordType/* && newArtfct.Project__r.ProjectAssigmentStatus__c  == 'Payment Pending'*/)
               validArtefacts.add(newArtfct);
               ParentId.add(newArtfct.Project__c);
        
             }
            
            }
            
        }
        if(!validArtefacts.isEmpty())
        {
            TVE_Artefact_Util.UpdateOwner(ParentId);
        }
       
     }

     
}