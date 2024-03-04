/*
  @author  : Rohit.Middha@ausnetservices.com.au
  @created : 05 Dec 2020
  @Description : Asset Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
*/
trigger AssetTrigger on Asset  (before insert, after insert, before update, after update, before delete, after delete, after undelete)
{
    UtilTrigDispatch.Run(new Trig_Asset(), Trigger.operationType);
}