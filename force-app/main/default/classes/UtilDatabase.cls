/*
@author  : vaughan.crole@ausnetservices.com.au, pavan.dave@ausnetservices.com.au
@created : 04 Sep 2019
@Description : Utility class
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
17/09/2019            Vaughan Crole                  added getRecordTypes()
-----------------------------------------------------------------------------------------
*/

public class UtilDatabase
{
	// ************************************************************************************
	// *** Static methods:
	public  static String  debugQuery;
	private static Map<Id, String> RTMap;
	private static Map<String, Id> RTNameMap;
	private static String RTNameMapObj;
	public static Set<String> excludedFields = new Set<String>{'MasterRecordId', 'ServiceContractId'};
	private static Map<Schema.SObjectType, String> SObjNames;

	private static final String DML_INSERT = 'Insert';
	private static final String DML_UPDATE = 'Update';
	private static final String DML_DELETE = 'Delete';

	// *** Instance methods:
	private Map<String, List<SObject>> updateObjs;
	private Map<String, List<SObject>> deleteObjs;


	// ************************************************************************************
	// *** Constructor
	public UtilDatabase()
	{
		updateObjs = new Map<String, List<SObject>>();
	}


	// ************************************************************************************
	// *** Methods:
	//
	public static Map<Id, SObject> getMapOfRecords(Set<Id> objIdList)
	{
		Map<Id,SObject> output = new Map<Id,SObject>();

		if (objIdList.isEmpty())
			return output;

		String objType = getObjectNameFromId(getFirst(objIdList));

		// Run query.
		String querystr = getAllFields(objType);

		if (objType != null)
		{
			querystr += ' FROM ' + objType;
			querystr += ' WHERE Id in :objIdList';
			//System.debug('querystr '+querystr);

			// Run query.
			for (SObject o: Database.query(querystr))
				output.put(o.Id,o);
		}

		return output;
	}

	public static SObject getRecord(Id objId)
	{
		SObject output;

		if (objId == null)
			return output;

		String objType = getObjectNameFromId(objId);

		// Run query.
		String querystr = getAllFields(objType);
		querystr += ' FROM ' + objType;
		querystr += ' WHERE Id=\''+objId+'\'';

		debugQuery = querystr;

		// Run query.
		for (SObject o: Database.query(querystr))
			output = o;

		return output;
	}

	public static Map<Id, String> getRecordTypes()
	{
		if (RTMap == null)
		{
			RTMap = new Map<Id, String>();
			String objType = 'RecordType';

			// Run query.
			String querystr = getAllFields(objType);
			querystr += ' FROM ' + objType;

			for (SObject o: Database.query(querystr))
			{
				RecordType rt = (RecordType)o;
				RTMap.put(rt.Id, rt.DeveloperName);
			}
		}

		return RTMap;
	}

	public static Map<String, Id> getRecordTypeNames(String targetObjType)
	{
		if (RTNameMap == null || RTNameMapObj == null || targetObjType != RTNameMapObj)
		{
			RTNameMapObj = targetObjType;

			RTNameMap = new Map<String, Id>();
			String objType = 'RecordType';

			// Run query.
			String querystr = getAllFields(objType);
			querystr += ' FROM ' + objType;
			querystr += ' WHERE SObjectType=\'' +targetObjType+ '\'';

			for (SObject o: Database.query(querystr))
			{
				RecordType rt = (RecordType)o;
				RTNameMap.put(rt.DeveloperName, rt.Id);
			}
		}

		return RTNameMap;
	}


	// ************************************************************************************
	// *** DML Methods (instance methods)
	public void upsertObjs()
	{
		if (updateObjs == null || updateObjs.isEmpty()) return;

		for (String ObjType: updateObjs.keySet())
		{
			// clunky.
			Boolean isInsert = false;
			if (ObjType.endsWith(DML_INSERT))
				isInsert = true;

			if (isInsert)
				insert updateObjs.get(ObjType);
			else
				update updateObjs.get(ObjType);

			updateObjs.remove(ObjType);
		}
	}

	public void addObjForUpsert(SObject sobj)
	{
		if (sobj == null) return;
		if (updateObjs == null) updateObjs = new Map<String, List<SObject>>();

		String ObjType = getObjectName(sobj);
		Boolean isInsert = (sobj.Id == null);
		ObjType += isInsert ? DML_INSERT:DML_UPDATE;

		if (!updateObjs.containsKey(ObjType))
			updateObjs.put(ObjType, new List<SObject>());

		updateObjs.get(ObjType).add(sobj);
	}

	public Integer getUpsertSize()
	{
		if (updateObjs == null) return 0;
		return updateObjs.size();
	}

	// deletes
	public void deleteObjs()
	{
		if (deleteObjs == null || deleteObjs.isEmpty()) return;

		for (String ObjType: deleteObjs.keySet())
		{
			// clunky.
			delete deleteObjs.get(ObjType);
			deleteObjs.remove(ObjType);
		}
	}

	public void addObjForDelete(SObject sobj)
	{
		if (sobj == null) return;
		if (deleteObjs == null) deleteObjs = new Map<String, List<SObject>>();

		String ObjType = getObjectName(sobj);

		if (!deleteObjs.containsKey(ObjType))
		deleteObjs.put(ObjType, new List<SObject>());

		deleteObjs.get(ObjType).add(sobj);
	}

	public Integer getDeleteSize()
	{
		if (deleteObjs == null) return 0;
		return deleteObjs.size();
	}


	// ************************************************************************************
	// *** Helper methods:
	public  static String getAllFields(String objType)
	{
		if (objType == null) return null;

		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objType);
		if (targetType == null)
		{
			System.debug('** Error targetType is null');

			String d = '\n';
			for (String key: Schema.getGlobalDescribe().keySet())
				d += key + '\n';
			System.debug(d);

			return null;
		}

		Map<String, Schema.SObjectField> fldObjMap = targetType.getDescribe().fields.getMap();
		List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

		String querystr = 'SELECT ';
		for (Schema.SObjectField s : fldObjMapValues)
		{
			// Check FLS on field, omit if not readable
			if (!s.getDescribe().isAccessible())
				continue;

			if(!excludedFields.contains(s.getDescribe().getName()))
				querystr += s.getDescribe().getName() + ', ';
		}

		querystr = querystr.subString(0, querystr.length() - 2);

		return querystr;
	}

	public  static Set<String> getFieldSet(String objType)
	{
		if (objType == null) return null;

		Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objType);
		if (targetType == null)
		{
			System.debug('** Error targetType is null');

			String d = '\n';
			for (String key: Schema.getGlobalDescribe().keySet())
				d += key + '\n';
			System.debug(d);

			return null;
		}

		Map<String, Schema.SObjectField> fldObjMap = targetType.getDescribe().fields.getMap();
		List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();

		Set<String> output = new Set<String>();
		for (Schema.SObjectField s : fldObjMapValues)
		{
			if(!excludedFields.contains(s.getDescribe().getName()))
				output.add(s.getDescribe().getName());
		}

		return output;
	}

	public static String getObjectNameFromId(Id objId)
	{
		String output;

		if (objId != null)
		{
			Schema.SObjectType sobjtype = objId.getSObjectType();

			if (sobjtype != null)
				output = sobjtype.getDescribe().getName();
		}

		return output;
	}

	public static String getObjectName(SObject sobj)
	{
		if (sobj == null) return null;

		Schema.SObjectType sobjtype = sobj.getSObjectType();
		if (sobjtype == null) return null;

		if (SObjNames == null)
			SObjNames = new Map<Schema.SObjectType, String>();

		if (!SObjNames.containsKey(sobjtype))
			SObjNames.put(sobjtype, sobjtype.getDescribe().getName());

		return SObjNames.get(sobjtype);
	}

	public static SObject explicitNulls(SObject sobj)
	{
		if (sobj == null)
			return null;

		// get object type
		Schema.DescribeSObjectResult ObjDesc = sobj.getSObjectType().getDescribe();
		String ObjType = ObjDesc.getName();

		// get fields
		Map<String, Schema.SObjectField> FieldMap = ObjDesc.fields.getMap();

		// for each field where null, set null.
		for (String f: getFieldSet(ObjType))
		{
			try { if (sobj.get(f) == null) sobj.put(f, null); } catch(exception e) { }
		}

		return sobj;
	}

	private static Id getFirst(Set<Id> Ids)
	{
		if (Ids == null) return null;

		Id output;
		for (Id i: Ids)
		{
			output = i;
			break;
		}
		return output;
	}
}