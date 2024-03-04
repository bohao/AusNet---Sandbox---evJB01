/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 04 Oct 2019
  @Description : DER Agreement Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
trigger DERAgreementTrigger on DER_Agreement__c (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{
    UtilTrigDispatch.Run(new Trig_DER_Agreement(), Trigger.operationType);
}