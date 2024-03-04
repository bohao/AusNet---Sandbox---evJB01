/*
  @author  : vaughan.crole@au1.ibm.com
  @created : 30 April 2020
  @Description : Task Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
trigger TaskTrigger on Task (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{
    UtilTrigDispatch.Run(new Trig_Task(), Trigger.operationType);
}