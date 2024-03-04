/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 27 Sep 2019
  @Description : Account Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
trigger AccountTrigger on Account (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{
    UtilTrigDispatch.Run(new Trig_Account(), Trigger.operationType);
}