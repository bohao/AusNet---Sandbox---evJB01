trigger ServicePointTrigger on vlocity_cmt__ServicePoint__c (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{
	UtilTrigDispatch.Run(new Trig_ServicePoint(), Trigger.operationType);
}