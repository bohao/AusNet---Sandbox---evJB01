/*
@author  : pavan.dave@ausnetservices.com.au
@created : 13th Jan 2020
@Description : test class for TVE_Artefact_Util
-----------------------------------------------------------------------------------------
Change log
-----------------------------------------------------------------------------------------
Date                  Name                           Description
-----------------------------------------------------------------------------------------
12 March            Lakshay Sharma
-----------------------------------------------------------------------------------------
*/
@isTest
public with sharing class TVE_Artefact_Util_Test {
    public static final string testUserEmail = 'testuser@TVEArtefactUtilTest.com';
    public static final string PROGRESS_BAR_STATUS = 'Prelim estimate accepted';
    public static final string CON_TYPE = 'IDIC';
    public static final string CLASSIFICATION_INVOICE = 'Invoice';
    public static final string CLASSIFICATION_TECH_SPEC = 'Technical Specs';
    public static ID invoiceRecordType = Schema.SObjectType.Artefact__c.getRecordTypeInfosByName().get('Invoice').getRecordTypeId();

    @TestSetup
    public static void setup() {
        
        //Create User
        User testUser = TVE_TestUtility.createTestUser(testUserEmail);
        insert testUser;
        
        //Create Business Account
        List<Account> lstAcc = new List<Account>();
        lstAcc.add(TVE_TestUtility.createBusinessAccount('John Smith'));
        lstAcc.add(TVE_TestUtility.createBusinessAccount('J Doe'));
        Insert lstAcc;

        eSignSettings__c eSignObj = eSignSettings__c.getInstance(); 
        eSignObj.AES_Key__c = 'K6SufKgGcs6r54OTreZokg==';
        insert eSignObj;
        contact con=TVE_TestUtility.createContact();
        insert con;
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        projObj.OwnerLastName__c = 'testLastName';
        projObj.OwnerCompany__c = 'testOwnerComp';
        projObj.PropertyOwnerContact__c = con.Id;
        projObj.IsPropertyOwner__c = 'Yes';
        //projObj.AuthorisedRepresentative__c = lstAcc[0].Id;
        //projObj.SiteOwner__c = lstAcc[1].Id;
        projObj.ApplicantContact__c=con.id;
        Insert projObj;
        
    }

    // This test method covers both methods 
    // 1. PopulateAccount
    // 2. PopulateRecordTypeId
    public static testMethod void testPopulateAccount_BeforeInsert(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        Test.startTest();
        System.runAs(testUser){
            Account acc1 = [SELECT Id, Name FROM Account WHERE Name =: 'John Smith' LIMIT 1];
            Account acc2 = [SELECT Id, Name FROM Account WHERE Name =: 'J Doe' LIMIT 1];
            Project__c projObj1 = [select id,AuthorisedRepresentative__c from Project__c ];
            Artefact__c artObj1 = new Artefact__c();
            artObj1.Project__c = projObj1.Id;
            artObj1.Classification__c = CLASSIFICATION_INVOICE;
            Insert artObj1;

            Artefact__c updatedArtefact = [SELECT id, Account__c FROM Artefact__c WHERE Id =: artObj1.Id LIMIT 1];
            System.assertEquals(projObj1.AuthorisedRepresentative__c, updatedArtefact.Account__c);
        }
        Test.stopTest();
    }

    // This test method covers both methods 
    // 1. PopulateAccount
    // 2. PopulateRecordTypeId
    public static testMethod void testPopulateRecordTypeId_BeforeUpdate(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
        
        Account acc1 = [SELECT Id, Name FROM Account WHERE Name =: 'John Smith' LIMIT 1];
        Project__c projObj1 = [select id from Project__c ];
        Artefact__c artObj1 = new Artefact__c();
        artObj1.Project__c = projObj1.Id;
        artObj1.Classification__c = CLASSIFICATION_INVOICE;
        Insert artObj1;

        Test.startTest();
        System.runAs(testUser){

            Artefact__c updatedArtefact = [SELECT id, RecordType.Name FROM Artefact__c WHERE Id =: artObj1.Id LIMIT 1];
            // According to mapping TVE_File_Classification_Mapping__mdt
            System.assertEquals('Invoice', updatedArtefact.RecordType.Name);

            artObj1.Classification__c = CLASSIFICATION_TECH_SPEC;
            Update artObj1;

            updatedArtefact = [SELECT id, RecordType.Name FROM Artefact__c WHERE Id =: artObj1.Id LIMIT 1];
            // According to mapping TVE_File_Classification_Mapping__mdt
            System.assertEquals('Other', updatedArtefact.RecordType.Name);
        }
        Test.stopTest();
    }
    // This test method covers both methods 
    // 1. DueDatePopup
    // 2. EPaymentLinkPopup
    public static testMethod void testdueDatePopUp_AfterInsert(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
       
        Account acc1 = [SELECT Id, Name FROM Account WHERE Name =: 'John Smith' LIMIT 1];
        Project__c projObj1 = [select id from Project__c ];
        
        List<Artefact__c> artObjList = new list<Artefact__c>();
        artObjList.add(TVE_TestUtility.createInvoiceArtefact('test',projObj1.Id,acc1.id));
        artObjList.add(TVE_TestUtility.createOfferArtefact('test',projObj1.Id,acc1.id));
        artObjList[0].Status__c='Pending Payment';
        artObjList[0].DueDate__c=system.today();
        artObjList[0].Electronic_Payment_Link__c='www.test.com';
        artObjList[1].DueDate__c=system.today();
        Insert artObjList;

        Test.startTest();
        System.runAs(testUser){

            Project__c updatedProject = [SELECT id, InvoiceDueDate__c,ElectronicPaymentLink__c,FirmOfferDueDate__c   FROM Project__c];
           // According to mapping TVE_File_Classification_Mapping__mdt
            System.assertEquals(updatedProject.InvoiceDueDate__c, artObjList[0].DueDate__c);
            System.assertEquals(updatedProject.ElectronicPaymentLink__c, artObjList[0].Electronic_Payment_Link__c);
            System.assertEquals(updatedProject.FirmOfferDueDate__c, artObjList[1].DueDate__c);
        }
        Test.stopTest();
    }
    public static testMethod void testdeleteArtefact(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
       
        Account acc1 = [SELECT Id, Name FROM Account WHERE Name =: 'John Smith' LIMIT 1];
        Project__c projObj1 = [select id from Project__c ];
        
        List<Artefact__c> artObjList = new list<Artefact__c>();
        artObjList.add(TVE_TestUtility.createInvoiceArtefact('test',projObj1.Id,acc1.id));
        artObjList.add(TVE_TestUtility.createOfferArtefact('test',projObj1.Id,acc1.id));
        artObjList[0].Status__c='Pending Payment';
        artObjList[0].DueDate__c=system.today();
        artObjList[0].Electronic_Payment_Link__c='www.test.com';
        artObjList[1].DueDate__c=system.today();
        Insert artObjList;

        Test.startTest();
        Database.delete(artObjList);
        Test.stopTest();
    }

    //test class for TVE11-2047
    public static testMethod void testRequestInvoiceInteg_AfterInsert(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
       
        Account acc1 = [SELECT Id, Name FROM Account WHERE Name =: 'John Smith' LIMIT 1];
        Project__c projObj1 = [select id from Project__c ];
        
        List<Artefact__c> artObjList = new list<Artefact__c>();

        artObjList.add(TVE_TestUtility.createInvoiceArtefact('test1',projObj1.Id,acc1.id));
        artObjList.add(TVE_TestUtility.createInvoiceArtefact('test2',projObj1.Id,acc1.id));
        artObjList[0].Source__c='Salesforce Cloud';
        artObjList[1].Source__c='Salesforce Cloud';
        artObjList[0].Additional_Invoice__c= true;
        artObjList[1].Additional_Invoice__c= true;        
        System.debug('artefact List before insertion'+artObjList);

        Test.startTest();
        System.runAs(testUser){
            Insert artObjList;
            List<Artefact__c> artfctLst = [SELECT Id FROM Artefact__c WHERE Source__c = 'SiteCore'];
            List<Integration_Task__c> IntgnTsklist = [SELECT Operation__c, SObject__c, ParentId__c, Type__c, Status__c FROM Integration_Task__c
                                                      WHERE ParentId__c =:artObjList[0].Id OR ParentId__c =:artObjList[1].Id];
            System.debug('########@@@@@@@'+IntgnTsklist);

           
            System.assertEquals(2, IntgnTsklist.size(), 'Proper Insertion of Integration Task did not happen');
            System.assertEquals(IntgnTsklist[0].Type__c, 'RequestInvoice','Type mismatch');
            System.assertEquals(IntgnTsklist[0].Status__c, 'Ready','Status mismatch');
            System.assertEquals(IntgnTsklist[0].SObject__c, 'Artefact__c','Sobject mismatch');
            System.assertEquals(IntgnTsklist[1].Type__c, 'RequestInvoice','Type mismatch');
            System.assertEquals(IntgnTsklist[1].Status__c, 'Ready','Status mismatch');
            System.assertEquals(IntgnTsklist[1].SObject__c, 'Artefact__c','Sobject mismatch');

        }
        Test.stopTest();
    }
    
    public static testMethod void testafterUpdateArtefact(){
        User testUser = [SELECT Id FROM User WHERE email=: testUserEmail LIMIT 1];
       
        Account acc1 = [SELECT Id, Name FROM Account WHERE Name =: 'John Smith' LIMIT 1];
        Project__c projObj = TVE_TestUtility.createProject('test',PROGRESS_BAR_STATUS,CON_TYPE);
        projObj.ProjectAssigmentStatus__c='Payment Pending';
        List<Artefact__c> artObjList = new list<Artefact__c>();

        artObjList.add(TVE_TestUtility.createInvoiceArtefact('test',projObj.Id,acc1.id));
        artObjList.add(TVE_TestUtility.createInvoiceArtefact('test',projObj.Id,acc1.id));
        Insert artObjList;
        
        Map<Id,List<Artefact__c>> mapofprojectandart= new Map<Id,List<Artefact__c>>();
        mapofprojectandart.put(projObj.Id,artObjList);
        
    }
}