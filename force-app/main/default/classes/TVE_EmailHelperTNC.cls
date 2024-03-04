/*
@author  : arti.fogla@ausnetservices.com.au
@created : 20 March 2019
@Description : Helper class for sending email from Process builder with Invoice
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
global class TVE_EmailHelperTNC {
	@InvocableMethod(label='Send Email With TNC')
	global static List<EmailActionResult> sendEmailWithTNC(List<EmailActionRequest> requests) {

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
		mail.setTargetObjectId(request.primaryRecipientContactRequired ); // Only User, Contact, Lead, or Person objects are allowed for targetObjectId
		mail.setWhatId(request.recordId);
		mail.setSaveAsActivity(request.saveAsActivity);

		// Verify/set Org wide email addr
		TVE_EmailHelper.setOrgWideEmailAddr(mail, request.orgWideEmailAddress); // Email address is actually DisplayName field from Org Wide Address.

		//getting static resource from custom metadata
		TVE_TermAndCond__mdt obj=[Select label,developername,Resource_Name__c from TVE_TermAndCond__mdt where label='TVE 11 Terms And Conditions'limit 1];
		String resourceName=obj.Resource_Name__c;
		system.debug('resourceName:'+resourceName);
		StaticResource sr = [SELECT Id,body,Name FROM StaticResource WHERE Name =:resourceName LIMIT 1];

		//inserting contentversion
		Contentversion cv=new ContentVersion();
		cv.title='Terms and Conditions';
		cv.VersionData=sr.body;
		cv.PathOnClient='Terms and Conditions.pdf';
		insert cv;
		system.debug('cv:'+cv);

		//inserting artefact
		Artefact__c art=new Artefact__c();
		art.Classification__c='Contract';
		art.Project__c=request.recordId;
		art.Name='Terms and Conditions';
		insert art;
		system.debug('art:'+art);

		//Linking Document to Artefact
		id documentID=[select Id,contentDocumentId from contentversion where Id=:cv.Id].contentDocumentId;
		system.debug('documentID:'+documentID);
		ContentDocumentLink cdl= new ContentDocumentLink();
		cdl.LinkedEntityId = art.id;
		cdl.ContentDocumentId = documentID;
		cdl.shareType = 'V';
		insert cdl;
		system.debug('ContentDocumentLink:'+cdl);

		//sending Email with attachment
		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		efa.setFileName('Terms and Conditions.pdf');
		efa.setBody(sr.body);
		mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

		Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
		messages.add(mail);
		Contact con=[select id ,email from contact where id=:request.primaryRecipientContactRequired];
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
		return emailActionResult;
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