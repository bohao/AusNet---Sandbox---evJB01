/*
  @author  : brajesh.tiwary@ausnetservices.com.au
  @created : 17 Sep 2019
  @Description : Case Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
trigger ContentDocumentLink on ContentDocumentLink (before insert, after insert, before update, after update, before delete, after delete, after undelete){
	UtilTrigDispatch.Run(new Trig_ContentDocumentLink(), Trigger.operationType);
}