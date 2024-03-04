trigger AffectedMarketIdentifier on Affected_Market_Identifier__c (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{
	UtilTrigDispatch.Run(new Trig_AffectedNMI(), Trigger.operationType);
}