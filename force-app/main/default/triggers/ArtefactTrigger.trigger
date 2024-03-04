/*
  @author  : pavan.dave@ausnetservices.com.au
  @created : 13 Jan 2020
  @Description : Artefact Trigger
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
trigger ArtefactTrigger on Artefact__C (before insert, after insert, before update, after update, before delete, after delete, after undelete){
	UtilTrigDispatch.Run(new Trig_Artefact(), Trigger.operationType);
}