@isTest
private class InventoryAvailabilityUpdateSchedulerTest {
    @isTest
    static void testScheduler() {
        // Create a test Inventory Availability record without setting the read-only field
        Inventory_Availability__c invAvailability = new Inventory_Availability__c(
            program__c = 'Test Program',
            New_Availability__c = 5,
            Check_In_Date__c = Date.today()
        );
        insert invAvailability;

        // Set up test data for Uploaded Inventory Availability
        List<Uploaded_Inventory_Availability__c> testData = new List<Uploaded_Inventory_Availability__c>();
        testData.add(new Uploaded_Inventory_Availability__c(
            Plaza__c = 'RIVIERA MAYA', 
            program__c = 'Test Program',
            Resort_Name__c = 'Test Resort',
            New_Availability__c = 10,
            Unit_Type__c = '1BR',
            Check_In_Date__c = Date.today()
        ));
        insert testData;

        // Schedule the job
        String cronExp = '0 0 * * * ?'; // Runs daily at midnight
        InventoryAvailabilityUpdateScheduler scheduler = new InventoryAvailabilityUpdateScheduler();
        System.schedule('TestInventoryAvailabilityUpdate', cronExp, scheduler);
        
        // Execute the batch manually
        Test.startTest();
        Database.executeBatch(new InventoryAvailablityUpdateBatch(), 100);
        Test.stopTest();

        // Verify if the record was updated
        List<Inventory_Availability__c> invAvaList = [SELECT Id, New_Availability__c FROM Inventory_Availability__c];
        System.assertNotEquals(0, invAvaList.size(), 'Inventory Availability records should exist.');
    }
}