/*
  @author  : brajesh.tiwary@ausnetservices.com.au
  @created : 09 Feb 2020
  @Description : User Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
trigger UserTrigger on User (before insert, after insert, before update, after update, before delete, after delete, after undelete){
	UtilTrigDispatch.Run(new Trig_User(), Trigger.operationType);
}