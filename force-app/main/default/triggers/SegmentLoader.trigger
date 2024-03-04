trigger SegmentLoader on Segment_Loader__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    UtilTrigDispatch.Run(new Trig_SegmentLoader(), Trigger.operationType);
    
}