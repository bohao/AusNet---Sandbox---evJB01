public without sharing class DER_DataMigration implements Database.Batchable<SObject>, Database.Stateful
{
	// ************************************************************************************
	// *** Members:
	private String  Query;
	public  Integer BatchSize = 1000;
	private Integer Iteration = 0;
	private UtilDebug de;
	public  runMode mode = runMode.LINKER;
	public  enum runMode {LINKER, EXT_DATA}



	// ************************************************************************************
	// *** Static members:
	private static String ClassName = 'DER_DataMigration';
	private static String ClassTag  = 'v1.0';


	// Parameters
	//private static Integer ROW_LIMIT   = 2400;
	@testvisible private static Boolean DML_ENABLED = true;
	@testvisible private static String ASSET_L2 = 'Asset_DER_L2';
	@testvisible private static String ASSET_L3 = 'Asset_DER_L3';
	@testvisible private static String CP_RTNAME = 'Electricity';


	// ************************************************************************************
	// *** Constructor:
	public DER_DataMigration()
	{
		de = new UtilDebug();
		de.bug('*** ' + ClassName + ' - ' + ClassTag);
	}


	// ************************************************************************************
	// *** Calling methods:
	public static void runDataMig(runMode argMode) // DER_DataMigration.runDataMig(DER_DataMigration.runMode.LINKER);
												   // DER_DataMigration.runDataMig(DER_DataMigration.runMode.EXT_DATA);
	{
		UtilDebug de = new UtilDebug();
		de.bug('*** ' + ClassName + ' - ' + ClassTag);

		// Create instance for batch
		DER_DataMigration DataMig = new DER_DataMigration();
		DataMig.mode = runMode.LINKER;

		if (argMode != null)
			DataMig.mode = argMode;

		if (DataMig.mode == runMode.LINKER)
			de.bug('* runDataLegacyLinker');
		else if (DataMig.mode == runMode.EXT_DATA)
			de.bug('* runConnPointExtNMILinked');
		
		de.bug('Executing batch...');
		try
		{
			Database.ExecuteBatch(DataMig, DataMig.BatchSize);
		}
		catch(LimitException e)
		{
			de.bug('\n* Exception!');
			de.bug(e.getMessage());
		}

		de.bug('\nEnd.');
		de.bugSend();
	}


	// ************************************************************************************
	// *** Batch methods:
	public Database.QueryLocator start(Database.BatchableContext BC)
	{
		de.bug('\n** Start');
		de.bug('BatchSize: ' + BatchSize);
		de.bug('Mode: ' + mode);

		if (mode == runMode.LINKER)
		{
			// Get Assets without parents
			String objType = 'Asset';
	
			Query  = 'SELECT Id, Name, Conn_Point__c, RecordTypeId, RecordType.DeveloperName, ParentId, Legacy_Data__c,';
			Query += ' Legacy_Data_Id__c, Legacy_Data_Parent_Id__c, Legacy_L2_Asset__c, AC_Equip_Cap__c';
			Query += ' FROM ' + objType;
			Query += ' WHERE ((Conn_Point__c = null AND RecordType.DeveloperName = :ASSET_L2)';
			Query += ' OR (ParentId = null AND RecordType.DeveloperName = :ASSET_L3))';
			Query += ' AND Legacy_Data__c = true';
			Query += ' AND Legacy_Data_Id__c != null';
			Query += ' AND Legacy_Data_Parent_Id__c != null';
			Query += ' ORDER BY Legacy_L2_Asset__c ASC';
			//Query += ' LIMIT :ROW_LIMIT';
		}

		else if (mode == runMode.EXT_DATA)
		{
			// Get Conn Points with missing Nmi Ext
			String objType = 'Connection_Point__c';
	
			Query  = 'SELECT Id, Name, NMI_Ref__c, NMI__c, RecordType.DeveloperName ';
			Query += ' FROM ' + objType;
			Query += ' WHERE RecordType.DeveloperName = :CP_RTNAME';
			Query += ' AND NMI__c != null';
			Query += ' AND NMI_Ref__c = null';
			Query += ' ORDER BY NMI__c ASC';
			//Query += ' LIMIT :ROW_LIMIT';
		}

		// Test mode
		if (Test.isRunningTest())
			Query += ' LIMIT ' + BatchSize;

		de.bug('Query:\n' + Query);

		return Database.getQueryLocator(Query);
	}

	public void execute(Database.BatchableContext BC, List<SObject> QueryResult)
	{
		Iteration++;
		de.bug('\n** Execute: ' + Iteration);
		de.bug('QueryResult size: ' + QueryResult.size());
		
		if (mode == runMode.LINKER)
		{
			de.bug('runMode.LINKER\n');

			// Determine what Connection points we will need
			Map<String, Asset> Assets = new Map<String, Asset>(); // private
			Map<String, Id> NMIs = new Map<String, Id>(); // priv

			for (SObject o: QueryResult)
			{
				Asset A = (Asset)o;

				String RTName = UtilDatabase.getRecordTypes().get(A.RecordTypeId);

				if (RTName == ASSET_L2)
					NMIs.put(A.Legacy_Data_Parent_Id__c, null);

				Assets.put(A.Legacy_Data_Id__c, A);
			}


			// Get all existing CPs
			Set<String> setNMIs = NMIs.keySet();
			String objType = 'Connection_Point__c';
			String querystr  = UtilDatabase.getAllFields(objType);
			querystr += ' FROM ' + objType;
			querystr += ' WHERE RecordType.DeveloperName = :CP_RTNAME';
			querystr += ' AND NMI__c in :setNMIs';

			for (SObject o: Database.query(querystr))
			{
				Connection_Point__c CP = (Connection_Point__c)o;
				NMIs.put(CP.NMI__c, CP.Id);
			}


			// Create CPs where required
			Id CP_RecTypeId = UtilDatabase.getRecordTypeNames('Connection_Point__c').get(CP_RTNAME);

			List<SObject> insUpdCPs = new List<SObject>();

			for (String NMI: NMIs.keySet())
			{
				if (NMIs.get(NMI) == null)
				{
					// create CP
					Connection_Point__c CP = new Connection_Point__c();
					CP.Name = NMI;
					CP.NMI__c = NMI;
					CP.RecordTypeId = CP_RecTypeId;

					insUpdCPs.add(CP);
				}
			}


			// Disable CP trigger
			Trig_Connection_Point.TrigDisabled = true;

			// Insert new CPs
			if (!insUpdCPs.isEmpty() && DML_ENABLED) insert insUpdCPs;
			Set<Id> newCPIds = new Set<Id>();
			for (Connection_Point__c CP: (List<Connection_Point__c>)insUpdCPs)
			{
				String NMI = CP.NMI__c;
				NMIs.put(NMI, CP.Id);
				newCPIds.add(CP.Id);
			}
			
			insUpdCPs.clear(); // Clear list, as will reuse below.


			// update Assets
			for (Asset A: Assets.values())
			{
				String RTName = UtilDatabase.getRecordTypes().get(A.RecordTypeId);

				if (RTName == ASSET_L2)
				{
					String NMI = A.Legacy_Data_Parent_Id__c;

					if (!NMIs.containsKey(NMI))
					{
						System.debug('Error: Cannot find CP ['+NMI+']');
						continue;
					}

					Id CPId = NMIs.get(NMI);
					A.Conn_Point__c = CPId;

					// Update cap and export
					Connection_Point__c CP = new Connection_Point__c(Id = CPId);
					CP.Ph_Unk_Total_Capacity__c = A.AC_Equip_Cap__c;
					insUpdCPs.add(CP);
				}

				else if (RTName == ASSET_L3)
				{
					String L2_Ext_Id = A.Legacy_Data_Parent_Id__c;

					if (!Assets.containsKey(L2_Ext_Id))
					{
						de.bug('Error: Cannot find L2 Asset Ext Id ['+L2_Ext_Id+']');
						continue;
					}

					Id ParentAssetId = Assets.get(L2_Ext_Id).Id;
					A.ParentId = ParentAssetId;
				}
			}

			if (!Assets.isEmpty() && DML_ENABLED) update Assets.values();
			if (!insUpdCPs.isEmpty() && DML_ENABLED) update insUpdCPs;
		}

		else if (mode == runMode.EXT_DATA)
		{
			de.bug('runMode.EXT_DATA\n');

			Set<Id> CPIds = new Set<Id>();

			for (SObject o: QueryResult)
			{
				Connection_Point__c CP = (Connection_Point__c)o;
				CPIds.add(CP.Id);
			}
			de.bug('num CPIds: ' + CPIds.size());

			Trig_Connection_Point.TrigDisabled = true;
			DER_Connection_Point_Util.runAsFuture = false;
			DER_Connection_Point_Util.updateCase = false;
			DER_Connection_Point_Util.isRunning_PopulateExternalNMIRef = true;
			DER_Connection_Point_Util.PopulateExternalNMIRef(CPIds, null);
		}
	}

	public void finish(Database.BatchableContext BC)
	{
		de.bug('\n** Finish');

		// launch ExtNMI
		if (mode == runMode.LINKER)
		{
			de.bug('Launching EXT Data linker.');
			DER_DataMigration.runDataMig(runMode.EXT_DATA);
		}

		de.bug('\nEnd.');
		de.bugSend();
	}

}