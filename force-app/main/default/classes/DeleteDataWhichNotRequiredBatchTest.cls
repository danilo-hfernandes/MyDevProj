@isTest
private class DeleteDataWhichNotRequiredBatchTest {
    
    @isTest
    static void testBatch() {

        // Insert test records for the custom object you are deleting
        Commission_Profile__c testRecord1 = new Commission_Profile__c(Name = 'Test Record 1');
        Commission_Profile__c testRecord2 = new Commission_Profile__c(Name = 'Test Record 2');
        List<Commission_Profile__c> testrecord = new List<Commission_Profile__c> ();
        testrecord.add(testRecord1);
        testrecord.add(testRecord2);
        insert testrecord;
        
        
        // Set up the custom label
        String customLabelValue = 'Delete_sObject_records';
        
        
        
        Test.startTest();
        
        // Create an instance of the batch class
        DeleteDataWhichNotRequiredBatch batchInstance = new DeleteDataWhichNotRequiredBatch();
        Database.QueryLocator ql = batchInstance.start(null);
        batchInstance.execute(null,testrecord);
        batchInstance.Finish(null);
        // Start the batch job
        Database.executeBatch(batchInstance);
        Test.stopTest();
        
        
        // Verify that the records have been deleted
        List<Commission_Profile__c> recordsAfterBatch = [SELECT Id,name FROM Commission_Profile__c  WHERE Name IN ('Test Record 1', 'Test Record 2')];
        System.assertEquals(0, recordsAfterBatch.size(), 'Records should be deleted by the batch job');
        //System.assert(recordsAfterBatch[0].Name.Contains('Test Record'));
        
    }
}