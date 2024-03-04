/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 23 Sep 2019
  @Description : Device Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
trigger DERAppTrigger on DER_Application__c (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{
    UtilTrigDispatch.Run(new Trig_DER_Application(), Trigger.operationType);
}