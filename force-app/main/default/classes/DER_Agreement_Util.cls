/*
	@author  : Brajesh Tiwary
	@created : 21 Oct 2019
	@Description : To populate custom setting data
	-----------------------------------------------------------------------------------------
	Change log
	-----------------------------------------------------------------------------------------
	Date                  Name                           Description
	-----------------------------------------------------------------------------------------
	23-OCT-19           brajesh.tiwary@ausnetservices.com.au   Added method getEsignData
	24-FEB-20           brajesh.tiwary@ausnetservices.com.au   modified method getEsignData for story TV-1213
	02-APR-20           dave.pavan@in.ibm.com                  This class is common utility class for addeing data
																to eSignSettings__c and has improved version of
																adding eSignSettings__c record.
	-----------------------------------------------------------------------------------------
*/
public class DER_Agreement_Util
{
	public static void getEsignData()
	{
		Blob key = Crypto.generateAesKey(128);
		List<eSignSettings__c> eSignObj = [select id,SetupOwnerId,AES_Key__c from eSignSettings__c];
		//-------------------------------------------------------//
		//--- if custom setting has no record then create one ---//
		//-------------------------------------------------------//
		if (eSignObj.isEmpty())
		{
			eSignSettings__c eSignNew = new eSignSettings__c();
			eSignNew.SetupOwnerId=UserInfo.getOrganizationId();
			eSignNew.AES_Key__c = EncodingUtil.base64Encode(key);
			eSignNew = TVE_Utility.updateTVEeSignURL(eSignNew);
			insert eSignNew;
		}

		//-------------------------------------------------------//
		// if custom setting field AES_Key__c is empty then populate it
		//-------------------------------------------------------//
		else if (eSignObj.size()==1 && ((string.valueOf(eSignObj[0].SetupOwnerId)).startsWith('00D')))
		{
			if (String.isBlank(eSignObj[0].AES_Key__c)){
				eSignObj[0].AES_Key__c = EncodingUtil.base64Encode(key);
			}

			//-------------------------------------------------------//
			// Call TVE utility class to update eSignSettings__c fields
			//-------------------------------------------------------//

			eSignObj[0] = TVE_Utility.updateTVEeSignURL(eSignObj[0]);
			update eSignObj[0];
		}

		//-------------------------------------------------------//
		// if custom setting has more than 1 record then throw error
		//-------------------------------------------------------//
		else if (eSignObj.size()>1)
		{
			throw new TVE_ConfigurationException('More than one records found for custom setting API named eSignSettings__c');
		}

		//-------------------------------------------------------//
		// if custom setting has no record then throw error
		//-------------------------------------------------------//
		else
		{
			throw new TVE_ConfigurationException('No valid records found for custom setting API named eSignSettings__c');
		}
	}
}