@isTest
private class GenericAssignToSalesCadenceChainedTest {
    @isTest static void testExecute() {
        // Set up sample data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Contact con = new Contact(FirstName = 'Test', LastName = 'User', AccountId = acc.Id);
        insert con;

        // Use fake cadence name
        String fakeCadence = 'Test-Cadence';

        // Run queueable
        Test.startTest();
        System.enqueueJob(new GenericAssignToSalesCadenceChained(new Set<Id>{con.Id}, fakeCadence, 0));
        Test.stopTest();
    }
}