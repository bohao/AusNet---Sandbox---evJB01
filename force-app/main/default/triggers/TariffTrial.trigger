trigger TariffTrial on Tariff_Trial__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {

    UtilTrigDispatch.Run(new Trig_TariffTrial(), Trigger.operationType);
    
}