/*
@description: Apex Test Class For Trig_DataUsePurpose 
*/
@isTest
public with sharing class Trig_DataUsePurposeTest {
    @testSetup
    static void setup() {
        DataUsePurpose dup = new DataUsePurpose(Name = 'Outage Notifications');
        insert dup;
    }

    @isTest
    static void beforeInsertHandleDuplicateNameCheckTest() {
        Boolean exceptionThrown = false;

        Test.startTest();

        try {
            // Create DataUsePurpose with unique name
            DataUsePurpose dup = new DataUsePurpose(Name = 'News');
            insert dup;

            // Validate a DataUsePurpose with unique Name was inserted
            List<DataUsePurpose> newsDups = [SELECT Name FROM DataUsePurpose WHERE Name = 'News'];
            Assert.isTrue(newsDups.size() == 1, 'Invalid number of DataUsePurposes returned');

            // Create DataUsePurpose with non unique name (Trigger logic Case-insensitive)
            DataUsePurpose dupDuplicateName = new DataUsePurpose(Name = 'outage notifications');
            insert dupDuplicateName;

        } catch (Exception e) {
            exceptionThrown = true;

            // Validate expected error message is returned
            Assert.isTrue(e.getMessage().contains('A Data Use Purpose with this Name already exists.'), e.getMessage()); 
        } 

        // Validate exception was thrown
        Assert.isTrue(exceptionThrown, 'No exception was thrown');

        Test.stopTest();
	}

    @isTest
    static void beforeUpdateHandleDuplicateNameCheckTest() {
        Boolean exceptionThrown = false;

        DataUsePurpose dup = new DataUsePurpose(Name = 'News', CanDataSubjectOptOut = false);
        insert dup;

        dup = [SELECT Id, Name, CanDataSubjectOptOut FROM DataUsePurpose WHERE Name = 'News'];

        Test.startTest();
        dup.CanDataSubjectOptOut = true;
        update dup;

        // Validate DataUsePurpose can be updated freely
        dup = [SELECT Id, Name, CanDataSubjectOptOut FROM DataUsePurpose WHERE Id = :dup.Id];
        Assert.isTrue(dup.CanDataSubjectOptOut, 'Data Use Purpose was not updated');

        dup.Name = 'news';
        update dup;

        // Validate DataUsePurpose Name can be changed to a different Case (Trigger logic Case-insensitive)
        dup = [SELECT Name, CanDataSubjectOptOut FROM DataUsePurpose WHERE Id = :dup.Id];
        Assert.areEqual('news', dup.Name);


        try {
            // Update DataUsePurpose to a non unique name (Trigger logic Case-insensitive)
            dup.Name = 'outage Notifications';
            update dup;

        } catch (Exception e) {
            exceptionThrown = true;

            // Validate expected error message is returned
            Assert.isTrue(e.getMessage().contains('A Data Use Purpose with this Name already exists.'), e.getMessage()); 
        } 

        // Validate exception was thrown
        Assert.isTrue(exceptionThrown, 'No exception was thrown');

        Test.stopTest();
	}
}