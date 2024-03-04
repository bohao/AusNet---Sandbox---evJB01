/*
	@author  : pavan.dave@ausnetservices.com.au
	@created : 30 Aug 2019
	@Description : Payload Class for parsing JSON Request Body
	-----------------------------------------------------------------------------------------
	Change log
	-----------------------------------------------------------------------------------------
	Date                  Name                           Description
	-----------------------------------------------------------------------------------------
	NA                    NA                              NA
	-----------------------------------------------------------------------------------------
*/
public with sharing class DER_Payload {
	public Case derCase;
	public DER_Application__c derApp;
	public Connection_Point__c nmi;
	public List<Device__c> devices;
	public Account customer;
	public Account installer;
	public Contact installerContact;
	public Contact representative;
	public Account representativeCompany;
	public DER_Agreement__c derAgreement;

	public String getJSON()
	{
		return JSON.serialize(this);
	}
}