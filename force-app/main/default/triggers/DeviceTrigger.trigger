/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 20 Sep 2019
  @Description : Device Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
trigger DeviceTrigger on Device__c (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{
    UtilTrigDispatch.Run(new Trig_Device(), Trigger.operationType);
}