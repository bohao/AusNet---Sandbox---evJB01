trigger AffectedCustomer on Affected_Customer__c (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{
	UtilTrigDispatch.Run(new Trig_AffectedCustomer(), Trigger.operationType);
}