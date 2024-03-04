/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 23 Sep 2019
  @Description : Contact Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
trigger ContactTrigger on Contact (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{
    UtilTrigDispatch.Run(new Trig_Contact(), Trigger.operationType);
}