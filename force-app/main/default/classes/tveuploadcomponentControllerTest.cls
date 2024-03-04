/*
@author  : lakshay.sharma@ausnetservices.com.au
@created : 7th Jan 2020
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
public with sharing class tveuploadcomponentControllerTest {
    
    Private static String strFileName = 'TestImage';
    Private static String base64Data='Testbase64Data';  
    Private static String Classification='Contract';
    Private static Account acc;
    Private static Project__c prj;
    Private static string PROGRESS_BAR_STATUS = 'Allocated for initial assessment';
    Private static string CONTESTATIBILITY_TYPE = 'IDEC';
    @istest static void tveuploadcomponentControllerTestForArtefact(){
        eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
        eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
        insert eSignObj;
		acc=TVE_TestUtility.createBusinessAccount('TestAccount');
        insert acc;
    	prj=TVE_TestUtility.createProject('TestRef1',PROGRESS_BAR_STATUS,CONTESTATIBILITY_TYPE);
        insert prj;
        Artefact__c art=TVE_TestUtility.createOfferArtefact('testArt',prj.id,acc.id);
        insert art;
        Task tsk= TVE_TestUtility.createTask(prj.id,userinfo.getUserId(),'test');
        insert tsk;
        TVE_TestUtility.insertFile(prj.id);
        id docId=[SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument limit 1].id;
        test.startTest();
        tveuploadcomponentController.saveFile(prj.Id,strFileName,art.id,Classification,acc.Id);
        tveuploadcomponentController.getArtefact(prj.id);
        tveuploadcomponentController.deleteArtefact(prj.id,docId);
        tveuploadcomponentController.fetchProject(tsk.id);
        
        test.stopTest();
        }
        
    }