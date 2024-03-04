trigger DataUsePurposeTrigger on DataUsePurpose (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    UtilTrigDispatch.Run(new Trig_DataUsePurpose(), Trigger.operationType);
}