public without sharing class UtilDebug
{
	/*
		*** Debug machine
		
		Usage:

			UtilDebug de = new UtilDebug();
			de.bug('*** SomeClass.someMethod(arg1, arg2)');
			de.bug('some debug comments');

			// Always need to send the debug before the
			// instance is deconstructed (aka: the method/context is completed.)
			de.bugSend();
	*/


	// ************************************************************************************
	// *** Members:
	private String  debug;
	private String  debugSubject;
	private Boolean debugMode; // = true; // TODO: set to null for prod/deploy


	// ************************************************************************************
	// *** Constructors:
	public UtilDebug()
	{
		
	}

	public UtilDebug(Boolean forceDebug)
	{
		if (forceDebug != null)
			debugMode = forceDebug;
	}


	// ************************************************************************************
	// *** Methods:
	private Boolean getDebugMode()
	{
		if (Test.isRunningTest()) debugMode = true;

		if (debugMode == null)
		{
			debugMode = false;
			debugMode = DER_System__c.getInstance().DER_API_Debug_Enabled__c;
		}

		return debugMode;
	}

	public void bug(String s) { debug(s); }
	public void debug(String s) { debug(s, null); }

	public void bug(String s, Boolean sysDebug) { debug(s, sysDebug); }
	public void debug(String s, Boolean sysDebug)
	{
		if (!getDebugMode()) return;

		if (sysDebug == null)
			sysDebug = false;

		if (debug == null)
			debug = '';

		if (s != null)
			debug += s + '\n';
		
		if (sysDebug) System.debug(logginglevel.DEBUG, s);
	}

	public void bugSubject(String s)
	{
		if (s == null) return;
		debugSubject = s;
	}

	public void bugSend() { sendDebug(); }
	public void sendDebug()
	{
		if (!getDebugMode()) return;

		if (debug == null)
			debug('Error: No debug.');

		debug = 'UtilDebug\n---------\n\n' + debug;

		QuickEmail(debug, debugSubject);
		debug = null;
		debugSubject = null;
	}

	public  static void QuickEmail(String msg) { QuickEmail(msg, null); }
	public  static void QuickEmail(String msg, String debugSubject)
	{
		String  sender       = 'AusNet CIM System';
		String  subject      = 'Debug info';
		if (debugSubject != null) subject += ': ' + debugSubject;

		User    debuguser    = getDebugUser();
		if (debuguser == null) return;

		Id      userId       = getDebugUser().Id;
		Boolean isProduction = (UserInfo.getOrganizationId() == UtilFieldCalcs.PROD_ORG_ID);

		if (msg != null && msg != '')
		{
			String orgHeader  = 'Org      : '+ UserInfo.getOrganizationName() + ' ['+ UserInfo.getOrganizationId() + ']\n';
				   orgHeader += 'Instance : '+ Url.getOrgDomainUrl().getHost() + '\n';
				   orgHeader += 'User     : '+ UserInfo.getUserName() + ' ['+ UserInfo.getUserId() + ']\n\n';

			String instance = Url.getOrgDomainUrl().getHost().split('\\.').get(0);
			if (instance.contains('--')) instance = instance.split('--').get(1);
			if (isProduction) instance = '** Prod **';
			subject += ' (' + instance + ')';

			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setSaveAsActivity(false);
			mail.setTargetObjectId(userId);
			mail.setReplyTo('noreply@salesforce.com');
			mail.setSenderDisplayName(sender);
			mail.setSubject(subject);
			mail.setPlainTextBody(orgHeader + msg);

			if (!ccAddresses.isEmpty()) mail.setCcAddresses(ccAddresses);

			try
			{
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			}
			catch(Exception e)
			{
				System.debug('Error sending QuickEmail: ' + e);
			}
		}
	}

	private static User DebugUser;
	private static List<String> ccAddresses = new List<String>();
	public  static User getDebugUser()
	{
		if (DebugUser == null)
		{
			String DELIMITER = ',';
			String FirstName = 'Vaughan';

			if (DER_System__c.getInstance().DER_API_Debug_User_Id__c != null)
			{
				String strUserIds = DER_System__c.getInstance().DER_API_Debug_User_Id__c;

				// Check for multi users
				if (strUserIds.contains(DELIMITER))
				{
					for (String s: strUserIds.split(DELIMITER))
					{
						Id userId = s.trim();

						if (DebugUser == null)
							DebugUser = (User)UtilDatabase.getRecord(userId);
						else
							ccAddresses.add((String)UtilDatabase.getRecord(userId).get('Email'));
					}
				}
				else
				{
					DebugUser = (User)UtilDatabase.getRecord(strUserIds);
				}
			}
			else
			{
				// Failsafe.
				for (User u: [SELECT Id FROM User WHERE FirstName=:FirstName LIMIT 1])
					DebugUser = u;

				if (DebugUser == null)
					DebugUser = (User)UtilDatabase.getRecord(UserInfo.getUserId());
			}
		}

		return DebugUser;
	}

}