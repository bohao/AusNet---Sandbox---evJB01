/*
@author  : lakshay.sharma@ausnetservices.com.au
@created : 21st Jan 2020
@Description : Test class for tveuploadcomponentController
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
NA                    NA                              NA
-----------------------------------------------------------------------------------------
*/
@isTest
public class tvegetpicklistvaluesTest {
   
    Private static Account acc;
    Private static Project__c prj;
    Private static Artefact__c art;
    Private static string PROGRESS_BAR_STATUS = 'Allocated for initial assessment';
    Private static string CONTESTATIBILITY_TYPE = 'IDEC';
    
    @isTest static void getpicklistvaluestest(){
        eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
        eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
        insert eSignObj;
        acc=TVE_TestUtility.createBusinessAccount('TestAccount');
        insert acc;
    	prj=TVE_TestUtility.createProject('TestRef1',PROGRESS_BAR_STATUS,CONTESTATIBILITY_TYPE);
        insert prj;
        art=TVE_TestUtility.createOfferArtefact('TestArtefact',prj.Id,acc.Id);
        insert art;
        
		Test.startTest();
        tvegetpicklistvalues.getPickListValue(art,'Classification__c');
        Test.stopTest();
    }
   

}