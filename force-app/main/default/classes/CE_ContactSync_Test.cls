@isTest
private class CE_ContactSync_Test
{
	private static Integer numCustomers = 5;
	private static Integer numIncidents = 1;


	public static testMethod void test_CEContactSync_1()
	{
		// TODO
		Test.startTest();

		// Create Premise, NMI, Service Account
		Outage_DataFactory.getODF().generatePremises(1, false);
		Outage_DataFactory.getODF().generateNMIs(1);
		Outage_DataFactory.getODF().generateAccs(1);

		Account acc = Outage_DataFactory.getODF().accs[0];

		// Create Primary contact (Market Contact)
		Contact con;
		Set<Id> conIds = new Set<Id>();

		// Create with 0 fields populated
		enableTrigs();
		con = generateContact(acc);
		insert con;
		for (Contact checkCon: getContacts(con.Id))
		{
			System.assert(checkCon.Contact_Point_Phones__r.isEmpty());
			System.assert(checkCon.Contact_Point_Emails__r.isEmpty());
		}

		// Create with 1 field populated
		enableTrigs();
		con = generateContact(acc);
		con.MobilePhone = '04' + Outage_DataFactory.randomNum(8);
		insert con;
		for (Contact checkCon: getContacts(con.Id))
		{
			System.assert(checkCon.Contact_Point_Emails__r.isEmpty());
			System.assertEquals(1, checkCon.Contact_Point_Phones__r.size());

			for (ContactPointPhone CPP: checkCon.Contact_Point_Phones__r)
			{
				System.assert(CPP.IsPrimary);
				System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPP.Data_Type__c);

				String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
				System.assertEquals(key, CPP.PrimaryKey__c);
				System.assertEquals('614' + con.MobilePhone.removeStart('04'), CPP.TelephoneNumber);
				System.assertEquals('Mobile', CPP.PhoneType);
				System.assertEquals(true, CPP.IsSMSCapable);
			}
		}

		// Create with 2 fields populated
		enableTrigs();
		con = generateContact(acc);
		con.MobilePhone = '04' + Outage_DataFactory.randomNum(8);
		con.Email = con.FirstName.toLowerCase() + '@' + con.LastName.toLowerCase() + '.com.invalid';
		insert con;
		for (Contact checkCon: getContacts(con.Id))
		{
			System.assertEquals(1, checkCon.Contact_Point_Emails__r.size());
			System.assertEquals(1, checkCon.Contact_Point_Phones__r.size());

			for (ContactPointPhone CPP: checkCon.Contact_Point_Phones__r)
			{
				System.assert(CPP.IsPrimary);
				System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPP.Data_Type__c);

				String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
				System.assertEquals(key, CPP.PrimaryKey__c);
				System.assertEquals('614' + con.MobilePhone.removeStart('04'), CPP.TelephoneNumber);
				System.assertEquals('Mobile', CPP.PhoneType);
				System.assertEquals(true, CPP.IsSMSCapable);
			}

			for (ContactPointEmail CPE: checkCon.Contact_Point_Emails__r)
			{
				System.assert(CPE.IsPrimary);
				System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPE.Data_Type__c);

				String key = CE_ContactPointSync2.getPrimaryKeyValue(CPE);
				System.assertEquals(key, CPE.PrimaryKey__c);
				System.assertEquals(con.Email, CPE.EmailAddress);
			}
		}

		// Create with 3 fields populated
		enableTrigs();
		con = generateContact(acc);
		con.MobilePhone = '04' + Outage_DataFactory.randomNum(8);
		con.Email = con.FirstName.toLowerCase() + '@' + con.LastName.toLowerCase() + '.com.invalid';
		con.Phone = '039' + Outage_DataFactory.randomNum(7);
		insert con;
		for (Contact checkCon: getContacts(con.Id))
		{
			System.assertEquals(1, checkCon.Contact_Point_Emails__r.size());
			System.assertEquals(2, checkCon.Contact_Point_Phones__r.size());

			for (ContactPointPhone CPP: checkCon.Contact_Point_Phones__r)
			{
				// System.assert(CPP.IsPrimary);
				System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPP.Data_Type__c);
				String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
				System.assertEquals(key, CPP.PrimaryKey__c);

				if (CPP.PhoneType == 'Mobile')
				{
					System.assertEquals('614' + con.MobilePhone.removeStart('04'), CPP.TelephoneNumber);
					System.assertEquals(true, CPP.IsSMSCapable);
				}
				else if (CPP.PhoneType == 'Home')
				{
					System.assertEquals(con.Phone, CPP.TelephoneNumber);
					System.assertEquals(false, CPP.IsSMSCapable);
				}
			}

			for (ContactPointEmail CPE: checkCon.Contact_Point_Emails__r)
			{
				System.assert(CPE.IsPrimary);
				System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPE.Data_Type__c);

				String key = CE_ContactPointSync2.getPrimaryKeyValue(CPE);
				System.assertEquals(key, CPE.PrimaryKey__c);
				System.assertEquals(con.Email, CPE.EmailAddress);
			}
		}

		// Create with 5 fields populated
		enableTrigs();
		con = generateContact(acc);
		con.MobilePhone = '04' + Outage_DataFactory.randomNum(8);
		con.Email = con.FirstName.toLowerCase() + '@' + con.LastName.toLowerCase() + '.com.invalid';
		con.Phone = '039' + Outage_DataFactory.randomNum(7);
		con.CE_Phone_Number__c = '04' + Outage_DataFactory.randomNum(8);
		con.CE_Email_Address__c = con.LastName.toLowerCase() + '@' + con.FirstName.toLowerCase() + '.com.invalid';
		insert con;
		for (Contact checkCon: getContacts(con.Id))
		{
			System.assertEquals(2, checkCon.Contact_Point_Emails__r.size());
			System.assertEquals(3, checkCon.Contact_Point_Phones__r.size());

			for (ContactPointPhone CPP: checkCon.Contact_Point_Phones__r)
			{
				if (CPP.Data_Type__c == Outage_IncidentProcessor.DATATYPE_RETAILER)
				{
					// System.assert(CPP.IsPrimary);
					System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPP.Data_Type__c);
					String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
					System.assertEquals(key, CPP.PrimaryKey__c);

					if (CPP.PhoneType == 'Mobile')
					{
						System.assertEquals('614' + con.MobilePhone.removeStart('04'), CPP.TelephoneNumber);
						System.assertEquals(true, CPP.IsSMSCapable);
					}
					else if (CPP.PhoneType == 'Home')
					{
						System.assertEquals(con.Phone, CPP.TelephoneNumber);
						System.assertEquals(false, CPP.IsSMSCapable);
					}
				}
				else if (CPP.Data_Type__c == Outage_IncidentProcessor.DATATYPE_ENHANCED)
				{
					// System.assert(CPP.IsPrimary);
					System.assertEquals(Outage_IncidentProcessor.DATATYPE_ENHANCED, CPP.Data_Type__c);
					String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
					System.assertEquals(key, CPP.PrimaryKey__c);

					if (CPP.PhoneType == 'Mobile')
					{
						System.assertEquals('614' + con.CE_Phone_Number__c.removeStart('04'), CPP.TelephoneNumber);
						System.assertEquals(true, CPP.IsSMSCapable);
					}
					else if (CPP.PhoneType == 'Home')
					{
						System.assertEquals(con.Phone, CPP.TelephoneNumber);
						System.assertEquals(false, CPP.IsSMSCapable);
					}
				}
			}

			for (ContactPointEmail CPE: checkCon.Contact_Point_Emails__r)
			{
				if (CPE.Data_Type__c == Outage_IncidentProcessor.DATATYPE_RETAILER)
				{
					// System.assert(CPE.IsPrimary);
					System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPE.Data_Type__c);

					String key = CE_ContactPointSync2.getPrimaryKeyValue(CPE);
					System.assertEquals(key, CPE.PrimaryKey__c);
					System.assertEquals(con.Email, CPE.EmailAddress);
				}
				else if (CPE.Data_Type__c == Outage_IncidentProcessor.DATATYPE_ENHANCED)
				{
					// System.assert(CPE.IsPrimary);
					System.assertEquals(Outage_IncidentProcessor.DATATYPE_ENHANCED, CPE.Data_Type__c);

					String key = CE_ContactPointSync2.getPrimaryKeyValue(CPE);
					System.assertEquals(key, CPE.PrimaryKey__c);
					System.assertEquals(con.CE_Email_Address__c, CPE.EmailAddress);
				}
			}
		}


		// Update Primary contact

			// Update Retailer fields -
				// Populated to null
				// null to populated
				// value 1 to value 2
				enableTrigs();
				String oldPhone = con.Phone;
				String oldEmail = con.Email;
				con.Phone = null;
				con.Email = null;
				update con;

				for (Contact checkCon: getContacts(con.Id))
				{
					System.assertEquals(2, checkCon.Contact_Point_Emails__r.size());
					System.assertEquals(3, checkCon.Contact_Point_Phones__r.size());

					for (ContactPointPhone CPP: checkCon.Contact_Point_Phones__r)
					{
						if (CPP.Data_Type__c == Outage_IncidentProcessor.DATATYPE_RETAILER)
						{
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPP.Data_Type__c);
							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
							System.assertEquals(key, CPP.PrimaryKey__c);

							if (CPP.PhoneType == 'Mobile')
							{
								System.assertEquals('614' + con.MobilePhone.removeStart('04'), CPP.TelephoneNumber);
								System.assertEquals(true, CPP.IsSMSCapable);
							}
							else if (CPP.PhoneType == 'Home')
							{
								// this is deleted.
								System.assertEquals(oldPhone, CPP.TelephoneNumber);
								System.assertEquals(Outage_IncidentProcessor.CP_STS_DELETED, CPP.Status__c);
								System.assertEquals(false, CPP.IsPrimary);
							}
						}
						else if (CPP.Data_Type__c == Outage_IncidentProcessor.DATATYPE_ENHANCED)
						{
							// System.assert(CPP.IsPrimary);
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_ENHANCED, CPP.Data_Type__c);
							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
							System.assertEquals(key, CPP.PrimaryKey__c);

							if (CPP.PhoneType == 'Mobile')
							{
								System.assertEquals('614' + con.CE_Phone_Number__c.removeStart('04'), CPP.TelephoneNumber);
								System.assertEquals(true, CPP.IsSMSCapable);
							}
							else if (CPP.PhoneType == 'Home')
							{
								System.assertEquals(con.Phone, CPP.TelephoneNumber);
								System.assertEquals(false, CPP.IsSMSCapable);
							}
						}
					}

					for (ContactPointEmail CPE: checkCon.Contact_Point_Emails__r)
					{
						if (CPE.Data_Type__c == Outage_IncidentProcessor.DATATYPE_RETAILER)
						{
							// this is deleted.
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPE.Data_Type__c);

							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPE);
							System.assertEquals(key, CPE.PrimaryKey__c);

							System.assertEquals(oldEmail, CPE.EmailAddress);
							System.assertEquals(Outage_IncidentProcessor.CP_STS_DELETED, CPE.Status__c);
							System.assertEquals(false, CPE.IsPrimary);
						}
						else if (CPE.Data_Type__c == Outage_IncidentProcessor.DATATYPE_ENHANCED)
						{
							// System.assert(CPE.IsPrimary);
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_ENHANCED, CPE.Data_Type__c);

							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPE);
							System.assertEquals(key, CPE.PrimaryKey__c);
							System.assertEquals(con.CE_Email_Address__c, CPE.EmailAddress);
						}
					}
				}



				enableTrigs();
				con.Phone = '039' + Outage_DataFactory.randomNum(7);
				con.Email = oldEmail + '.abc';
				update con;

				for (Contact checkCon: getContacts(con.Id))
				{
					System.assertEquals(2, checkCon.Contact_Point_Emails__r.size());
					System.assertEquals(3, checkCon.Contact_Point_Phones__r.size());

					for (ContactPointPhone CPP: checkCon.Contact_Point_Phones__r)
					{
						if (CPP.Data_Type__c == Outage_IncidentProcessor.DATATYPE_RETAILER)
						{
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPP.Data_Type__c);
							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
							System.assertEquals(key, CPP.PrimaryKey__c);

							if (CPP.PhoneType == 'Mobile')
							{
								System.assertEquals('614' + con.MobilePhone.removeStart('04'), CPP.TelephoneNumber);
								System.assertEquals(true, CPP.IsSMSCapable);
							}
							else if (CPP.PhoneType == 'Home')
							{
								System.assertEquals(con.Phone, CPP.TelephoneNumber);
								System.assertEquals(Outage_IncidentProcessor.CP_STS_ACTIVE, CPP.Status__c);
								// System.assertEquals(true, CPP.IsPrimary);
							}
						}
						else if (CPP.Data_Type__c == Outage_IncidentProcessor.DATATYPE_ENHANCED)
						{
							// System.assert(CPP.IsPrimary);
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_ENHANCED, CPP.Data_Type__c);
							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
							System.assertEquals(key, CPP.PrimaryKey__c);

							if (CPP.PhoneType == 'Mobile')
							{
								System.assertEquals('614' + con.CE_Phone_Number__c.removeStart('04'), CPP.TelephoneNumber);
								System.assertEquals(true, CPP.IsSMSCapable);
							}
							else if (CPP.PhoneType == 'Home')
							{
								System.assertEquals(con.Phone, CPP.TelephoneNumber);
								System.assertEquals(false, CPP.IsSMSCapable);
							}
						}
					}

					for (ContactPointEmail CPE: checkCon.Contact_Point_Emails__r)
					{
						if (CPE.Data_Type__c == Outage_IncidentProcessor.DATATYPE_RETAILER)
						{
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPE.Data_Type__c);

							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPE);
							System.assertEquals(key, CPE.PrimaryKey__c);

							System.assertEquals(con.Email, CPE.EmailAddress);
							System.assertEquals(Outage_IncidentProcessor.CP_STS_ACTIVE, CPE.Status__c);
							System.assertEquals(true, CPE.IsPrimary);
						}
						else if (CPE.Data_Type__c == Outage_IncidentProcessor.DATATYPE_ENHANCED)
						{
							// System.assert(CPE.IsPrimary);
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_ENHANCED, CPE.Data_Type__c);

							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPE);
							System.assertEquals(key, CPE.PrimaryKey__c);
							System.assertEquals(con.CE_Email_Address__c, CPE.EmailAddress);
						}
					}
				}



			// Update CE fields -
				// Populated to null
				// null to populated
				// value 1 to value 2




				enableTrigs();
				oldEmail = con.CE_Email_Address__c;
				oldPhone = con.CE_Phone_Number__c;
				con.CE_Email_Address__c = null;
				con.CE_Phone_Number__c = null;
				update con;

				for (Contact checkCon: getContacts(con.Id))
				{
					System.assertEquals(2, checkCon.Contact_Point_Emails__r.size());
					System.assertEquals(3, checkCon.Contact_Point_Phones__r.size());

					for (ContactPointPhone CPP: checkCon.Contact_Point_Phones__r)
					{
						if (CPP.Data_Type__c == Outage_IncidentProcessor.DATATYPE_RETAILER)
						{
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPP.Data_Type__c);
							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
							System.assertEquals(key, CPP.PrimaryKey__c);

							if (CPP.PhoneType == 'Mobile')
							{
								System.assertEquals('614' + con.MobilePhone.removeStart('04'), CPP.TelephoneNumber);
								System.assertEquals(true, CPP.IsSMSCapable);
							}
							else if (CPP.PhoneType == 'Home')
							{
								System.assertEquals(con.Phone, CPP.TelephoneNumber);
								System.assertEquals(Outage_IncidentProcessor.CP_STS_ACTIVE, CPP.Status__c);
								// System.assertEquals(true, CPP.IsPrimary);
							}
						}
						else if (CPP.Data_Type__c == Outage_IncidentProcessor.DATATYPE_ENHANCED)
						{
							// System.assert(CPP.IsPrimary);
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_ENHANCED, CPP.Data_Type__c);
							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
							System.assertEquals(key, CPP.PrimaryKey__c);
							System.assertEquals('614' + oldPhone.removeStart('04'), CPP.TelephoneNumber);
							System.assertEquals(Outage_IncidentProcessor.CP_STS_ACTIVE, CPP.Status__c);
							System.assertEquals(false, CPP.IsPrimary);
						}
					}

					for (ContactPointEmail CPE: checkCon.Contact_Point_Emails__r)
					{
						if (CPE.Data_Type__c == Outage_IncidentProcessor.DATATYPE_RETAILER)
						{
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPE.Data_Type__c);

							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPE);
							System.assertEquals(key, CPE.PrimaryKey__c);

							System.assertEquals(con.Email, CPE.EmailAddress);
							System.assertEquals(Outage_IncidentProcessor.CP_STS_ACTIVE, CPE.Status__c);
							System.assertEquals(true, CPE.IsPrimary);
						}
						else if (CPE.Data_Type__c == Outage_IncidentProcessor.DATATYPE_ENHANCED)
						{
							// System.assert(CPE.IsPrimary);
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_ENHANCED, CPE.Data_Type__c);
							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPE);
							System.assertEquals(key, CPE.PrimaryKey__c);

							System.assertEquals(oldEmail, CPE.EmailAddress);
							System.assertEquals(Outage_IncidentProcessor.CP_STS_ACTIVE, CPE.Status__c);
							System.assertEquals(false, CPE.IsPrimary);
						}
					}
				}


				enableTrigs();
				con.CE_Email_Address__c = oldEmail + '.abc';
				con.CE_Phone_Number__c = '04' + Outage_DataFactory.randomNum(8);
				update con;

				for (Contact checkCon: getContacts(con.Id))
				{
					System.assertEquals(3, checkCon.Contact_Point_Emails__r.size());
					System.assertEquals(4, checkCon.Contact_Point_Phones__r.size());

					for (ContactPointPhone CPP: checkCon.Contact_Point_Phones__r)
					{
						if (CPP.Data_Type__c == Outage_IncidentProcessor.DATATYPE_RETAILER)
						{
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPP.Data_Type__c);
							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
							System.assertEquals(key, CPP.PrimaryKey__c);

							if (CPP.PhoneType == 'Mobile')
							{
								System.assertEquals('614' + con.MobilePhone.removeStart('04'), CPP.TelephoneNumber);
								System.assertEquals(true, CPP.IsSMSCapable);
							}
							else if (CPP.PhoneType == 'Home')
							{
								System.assertEquals(con.Phone, CPP.TelephoneNumber);
								System.assertEquals(Outage_IncidentProcessor.CP_STS_ACTIVE, CPP.Status__c);
								// System.assertEquals(true, CPP.IsPrimary);
							}
						}
						else if (CPP.Data_Type__c == Outage_IncidentProcessor.DATATYPE_ENHANCED)
						{
							if (CPP.TelephoneNumber == CE_ContactPointSync2.getMobileFormat(oldPhone))
								continue;

							// System.assert(CPP.IsPrimary);
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_ENHANCED, CPP.Data_Type__c);
							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPP);
							System.assertEquals(key, CPP.PrimaryKey__c);
							System.assertEquals('614' + con.CE_Phone_Number__c.removeStart('04'), CPP.TelephoneNumber);
							System.assertEquals(Outage_IncidentProcessor.CP_STS_ACTIVE, CPP.Status__c);
							System.assertEquals(true, CPP.IsPrimary);

							break; // just look at the first Enhanced rec
						}
					}

					for (ContactPointEmail CPE: checkCon.Contact_Point_Emails__r)
					{
						if (CPE.Data_Type__c == Outage_IncidentProcessor.DATATYPE_RETAILER)
						{
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_RETAILER, CPE.Data_Type__c);

							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPE);
							System.assertEquals(key, CPE.PrimaryKey__c);

							System.assertEquals(con.Email, CPE.EmailAddress);
							System.assertEquals(Outage_IncidentProcessor.CP_STS_ACTIVE, CPE.Status__c);
							System.assertEquals(true, CPE.IsPrimary);
						}
						else if (CPE.Data_Type__c == Outage_IncidentProcessor.DATATYPE_ENHANCED)
						{
							// System.assert(CPE.IsPrimary);
							System.assertEquals(Outage_IncidentProcessor.DATATYPE_ENHANCED, CPE.Data_Type__c);
							String key = CE_ContactPointSync2.getPrimaryKeyValue(CPE);
							System.assertEquals(key, CPE.PrimaryKey__c);

							System.assertEquals(con.CE_Email_Address__c, CPE.EmailAddress);
							System.assertEquals(Outage_IncidentProcessor.CP_STS_ACTIVE, CPE.Status__c);
							System.assertEquals(true, CPE.IsPrimary);

							break; // just look at the first Enhanced rec
						}
					}
				}

		Test.stopTest();
	}

	public static testMethod void test_CEContactSync_2()
	{
		// TODO
		Test.startTest();

		// Create Premise, NMI, Service Account
		Outage_DataFactory.getODF().generatePremises(1, false);
		Outage_DataFactory.getODF().generateNMIs(1);
		Outage_DataFactory.getODF().generateAccs(1);

		Account acc = Outage_DataFactory.getODF().accs[0];

		// Create Primary contact (Market Contact)
		Contact con;
		Set<Id> conIds = new Set<Id>();

		// create contact
		enableTrigs();
		con = generateContact(acc);
		con.CE_Phone_Number__c = '04' + Outage_DataFactory.randomNum(8);
		con.CE_Email_Address__c = con.LastName.toLowerCase() + '@' + con.FirstName.toLowerCase() + '.com.invalid';
		insert con;

		ContactPointEmail CPE;
		ContactPointPhone CPP;

		for (Contact checkCon: getContacts(con.Id))
		{
			System.assertEquals(1, checkCon.Contact_Point_Emails__r.size());
			System.assertEquals(1, checkCon.Contact_Point_Phones__r.size());

			CPE = checkCon.Contact_Point_Emails__r[0];
			CPP = checkCon.Contact_Point_Phones__r[0];
		}

		enableTrigs();
		CPP.TelephoneNumber = '04' + Outage_DataFactory.randomNum(8);
		update CPP;

		enableTrigs();
		CPE.EmailAddress = con.CE_Email_Address__c + '.abc';
		update CPE;

		for (Contact checkCon: getContacts(con.Id))
		{
			System.assertEquals(1, checkCon.Contact_Point_Emails__r.size());
			System.assertEquals(1, checkCon.Contact_Point_Phones__r.size());

			CPE = checkCon.Contact_Point_Emails__r[0];
			CPP = checkCon.Contact_Point_Phones__r[0];

			System.assertEquals(CPE.EmailAddress, checkCon.CE_Email_Address__c);
			System.assertEquals(CE_ContactPointSync2.getMobileFormatPretty(CPP.TelephoneNumber), checkCon.CE_Phone_Number__c);
		}

		Test.stopTest();
	}



	// helper methods
	private static Contact generateContact(Account acc)
	{
		Contact con = new Contact();

		// recordtype
		con.RecordTypeId = UtilDatabase.getRecordTypeNames('Contact').get(Outage_IncidentProcessor.CON_DCP_RT);

		con.FirstName = acc.Name.split(' ').get(0);
		con.LastName  = acc.Name.split(' ').get(1);
		con.AccountId = acc.Id;

		con.MailingStreet     = acc.ShippingStreet;
		con.MailingCity       = acc.ShippingCity;
		con.MailingState      = acc.ShippingState;
		con.MailingPostalCode = acc.ShippingPostalCode;
		con.MC_Contact__c     = true;

		return con;
	}

	private static List<Contact> getContacts(Id conId)
	{
		return getContacts(new Set<Id>{conId});
	}

	private static List<Contact> getContacts(Set<Id> conIds)
	{
		return [SELECT Id, Name, Salutation, FirstName, LastName,
				Email, Phone, MobilePhone,
				CE_Email_Address__c, CE_Phone_Number__c,

				(SELECT Id, Name, Contact__c, ContactPointId, DataUsePurpose.Name, EngagementChannelType.Name,
				Status__c, Authorised_to_Change__c, Privacy_Policy__c,
				CaptureSource, CaptureDate, EffectiveFrom, EffectiveTo,
				TYPEOF ContactPoint WHEN ContactPointPhone THEN Id,IsPrimary,TelephoneNumber,PhoneType,IsSmsCapable END,
				TYPEOF ContactPoint WHEN ContactPointEmail THEN Id,IsPrimary,EmailAddress END
				FROM Contact_Point_Consents__r
				ORDER BY CreatedDate DESC),

				(SELECT Id, Name, Contact__c, Source_Field__c,
				IsPrimary, Data_Type__c, Status__c, PrimaryKey__c,
				TelephoneNumber, PhoneType, IsSMSCapable
				FROM Contact_Point_Phones__r
				ORDER BY CreatedDate DESC),

				(SELECT Id, Name, Contact__c, Source_Field__c,
				IsPrimary, Data_Type__c, Status__c, PrimaryKey__c,
				EmailAddress
				FROM Contact_Point_Emails__r
				ORDER BY CreatedDate DESC)

				FROM Contact
				WHERE Id IN :conIds];
	}

	private static void enableTrigs()
	{
		CE_ContactPointSync2.isRunningContactUpdate = false;
		CE_ContactPointSync2.isRunningCPPCPEUpdate  = false;
	}
}