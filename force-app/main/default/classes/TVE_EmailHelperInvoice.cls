/*
@author  : arti.fogla@ausnetservices.com.au
@created : 20 feb 2019
@Description : Helper class for sending email from Process builder with Invoice
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
global class TVE_EmailHelperInvoice {

	@InvocableMethod(label='Send Email With Invoice')
	global static List<EmailActionResult> sendEmailWithInvoice(List<EmailActionRequest> requests) {

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




		List<ContentDocumentLink> contentDocumentLinkRec= [Select Id,ContentDocumentid, ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE LinkedEntityId = :request.recordId];
		if(!contentDocumentLinkRec.IsEmpty()){
			Contentversion contentVersionRec =[SELECT Title, VersionData, ContentDocumentId,FileExtension,  
			ContentLocation, FileType  
			FROM ContentVersion 
			WHERE ContentDocumentId = :contentDocumentLinkRec[0].ContentDocumentid
			AND IsLatest = true limit 1];

           Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
           String fileName=contentVersionRec.Title+'.'+contentVersionRec.FileExtension;
           system.debug('fileName:'+fileName);
           efa.setFileName(fileName);
           efa.setBody(contentVersionRec.VersionData);
           mail.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
		}
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