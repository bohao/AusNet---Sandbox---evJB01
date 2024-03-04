/*
  @author  : lakshay.sharma@ausnetservices.com.au
  @created : 28 Feb 2020
  @Description : Test class for WorkOrder Trigger and respective trigger logics
  -----------------------------------------------------------------------------------------
  Change log
  -----------------------------------------------------------------------------------------
  Date                  Name                           Description
  -----------------------------------------------------------------------------------------
  NA                    NA                              NA
  -----------------------------------------------------------------------------------------
*/
@isTest
public class Trig_WorkOrderTest {
    Private static Account acc;
    Private static Project__c prj;
    Private static string PROGRESS_BAR_STATUS = 'Allocated for initial assessment';
    Private static string CONTESTATIBILITY_TYPE = 'IDEC';
    Private static string aspManualText='Test01';
    Private static string extId='abc123456789012';
    @testSetup static void setup(){
        acc=TVE_TestUtility.createBusinessAccount('TestAccount');
        acc.ASPAccreditaionId__c='12345xyz12';
        insert acc;
    	prj=TVE_TestUtility.createProject('TestRef1',PROGRESS_BAR_STATUS,CONTESTATIBILITY_TYPE);
        prj.ASP__c=acc.Id;
        insert prj;
        WorkOrder workord = new WorkOrder(Type__c='Construction',StartDate=DateTime.NOW().AddDays(-1),EndDate=DateTime.NOW(),Project__c=prj.Id);
        insert workord;
    }
    @isTest public static void testAfterUpdateProjUpdate(){
		List<WorkOrder> workord=[SELECT Id,Type__c,EndDate,Project__c FROM WorkOrder WHERE Type__c='Construction'];
      workord[0].StartDate =  DateTime.NOW();
      workord[0].EndDate=DateTime.NOW().AddDays(1);
            
        
        Test.startTest();
        update workord[0];
		Test.stopTest();        
    }

}