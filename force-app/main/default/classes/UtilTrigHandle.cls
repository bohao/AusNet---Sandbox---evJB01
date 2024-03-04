/*
  @author  : vaughan.crole@ausnetservices.com.au
  @created : 17 Sep 2019
  @Description : Interface class for Trigger frameworks
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
public interface UtilTrigHandle
{
	void BeforeInsert(List<SObject> newSObjs);

	void BeforeUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs);

	void BeforeDelete(Map<Id, SObject> oldSObjs);

	void AfterInsert(Map<Id, SObject> newSObjs);

	void AfterUpdate(Map<Id, SObject> newSObjs, Map<Id, SObject> oldSObjs);

	void AfterDelete(Map<Id, SObject> oldSObjs);

	void AfterUndelete(Map<Id, SObject> oldSObjs);

	Boolean IsDisabled();
}