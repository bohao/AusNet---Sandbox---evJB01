trigger WorkOrderTrigger on WorkOrder (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    UtilTrigDispatch.Run(new Trig_WorkOrder(), Trigger.operationType);
}