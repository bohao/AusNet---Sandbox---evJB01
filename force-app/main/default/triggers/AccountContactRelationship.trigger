trigger AccountContactRelationship on AccountContactRelation (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    UtilTrigDispatch.Run(new Trig_AccountContactRelationship(), Trigger.operationType);
}