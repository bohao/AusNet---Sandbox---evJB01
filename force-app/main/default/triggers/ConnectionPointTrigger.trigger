/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 16 Oct 2019
  @Description : Connection_Point__c Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
trigger ConnectionPointTrigger on Connection_Point__c (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{
    UtilTrigDispatch.Run(new Trig_Connection_Point(), Trigger.operationType);
}