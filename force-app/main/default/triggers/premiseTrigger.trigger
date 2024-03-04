trigger premiseTrigger on vlocity_cmt__Premises__c (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{
	UtilTrigDispatch.Run(new Trig_Premises(), Trigger.operationType);
}