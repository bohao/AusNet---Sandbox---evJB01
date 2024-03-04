/*
@author  : arti.fogla@ausnetservices.com.au
@created : 20 feb 2019
@Description : Helper class for sending email from Process builder
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
global without sharing class TVE_EmailHelper {

	@InvocableMethod(label='Send Email')
	global static List<EmailActionResult> sendEmails(List<EmailActionRequest> requests) {

		List<EmailActionResult> results = new List<EmailActionResult>();

		for(EmailActionRequest request : requests){
			results.add(sendEmail(request));
		}

		return results;
	}

	public static EmailActionResult sendEmail(EmailActionRequest request) {
		EmailActionResult emailActionResult;
		list<EmailTemplate> template =[select id from emailTemplate where developerName =:request.emailTemplateDevName limit 1];
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		if(request.toEmailsSemiColonSeperatedOptional.toLowerCase()!='null'){
			String[] toAddresses = request.toEmailsSemiColonSeperatedOptional.split(';');
			mail.setToAddresses(toAddresses);
		}
		mail.setTemplateId(template[0].id);
		list<Task> taskList;
		ID targetObjId;
		String recId = (String)request.recordId;
		String textIdEmailAdd = (String)request.orgWideEmailAddress;


		if(recId.startsWith('00T'))
		{
			taskList = [SELECT id,WhatId FROM Task WHERE Id=: recId limit 1];
			recId=taskList[0].WhatId;
			list<Project__c> prj = [SELECT Id, ApplicantContact__c FROM Project__c WHERE Id =: recId];
			if(!prj.IsEmpty() && prj[0].ApplicantContact__c != null)
				targetObjId = prj[0].ApplicantContact__c;

		}
		else
		{
			targetObjId = request.primaryRecipientContactRequired;
		}



		if (targetObjId!= null)
		{
			mail.setTargetObjectId(targetObjId ); // Only User, Contact, Lead, or Person objects are allowed for targetObjectId
			mail.setWhatId(recId);

			// Verify/set Org wide email addr
			setOrgWideEmailAddr(mail, request.orgWideEmailAddress); // Email address is actually DisplayName field from Org Wide Address.

			mail.setSaveAsActivity(request.saveAsActivity);

			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
			messages.add(mail);
			Contact con=[select id ,email from contact where id=:targetObjId];
			if(con.email!=null && !Test.isRunningTest())
			{
				Messaging.SendEmailResult[] results = Messaging.sendEmail(messages,false);
				emailActionResult = new EmailActionResult();

				for(Messaging.SendEmailResult result :results) {

					if(result.IsSuccess()) {emailActionResult.isSuccess = true;
					   } else {emailActionResult.isSuccess = false;
						Messaging.SendEmailError[] errors = result.getErrors();
					   if (errors.size() > 0 ){emailActionResult.errorMessage = errors[0].getMessage();
							System.debug('EmailAction error: ' + errors[0].getMessage());
						}
					}
				}
			}
			else{
				System.debug( 'Email Not send .Applicant Contact does not have Email Address');
			}
		}
		else
		{
			System.debug('targetObjId not found');
		}
		return emailActionResult;
	}

	public static void setOrgWideEmailAddr(Messaging.SingleEmailMessage mail, String emailAddrDisplayName)
	{
		if (emailAddrDisplayName != null && mail != null)
		{
			// Verify Id exists
			Id oweId;
			for (OrgWideEmailAddress owe: [SELECT Id, DisplayName 
											FROM OrgWideEmailAddress 
											WHERE DisplayName = :emailAddrDisplayName])
											//AND Verified = true
			{
				oweId = owe.Id;
				break; // Just get the first.
			}

			if (oweId == null)
			{
				// Error
				System.debug('Error: Org Wide Email Address specified not found ['+emailAddrDisplayName+']');

				// TODO: Throw or continue?
			}
			else
			{
				mail.setOrgWideEmailAddressId(oweId);
			}
		}
	}

	global class EmailActionResult {

		@InvocableVariable
		global Boolean isSuccess;

		@InvocableVariable
		global String errorMessage;

	}

	global class EmailActionRequest
	{
		@InvocableVariable(required=true)
		global string emailTemplateDevName;

		@InvocableVariable(required=true)
		global Id primaryRecipientContactRequired ;

		@InvocableVariable(required=true)
		global Id recordId;

		@InvocableVariable(required=true)
		global String toEmailsSemiColonSeperatedOptional;

		@InvocableVariable(required=false)
		global Boolean saveAsActivity = false;

		@InvocableVariable(required=false)
		global String orgWideEmailAddress;
	}
}