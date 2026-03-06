@isTest
private class ClubGlobalExplorerVWOppCreationTest {

    @testSetup
    static void setupTestData() {
        // Get a user with the expected owner name
        User testOwner = [SELECT Id, Assigned_Contacts__c FROM User WHERE Name = 'Dev Account' LIMIT 1];

        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            testAccounts.add(new Account(
                Name = 'Test Account ' + i,
                Affiliated_Id__c = 1002458,
                OwnerId = testOwner.Id
            ));
        }
        insert testAccounts;
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        ClubGlobalExplorerVWOppCreation batch = new ClubGlobalExplorerVWOppCreation();
        Database.executeBatch(batch, 100);
        Test.stopTest();

        // Verify that opportunities were created
        List<Opportunity> opps = [SELECT Id, Name FROM Opportunity WHERE RecordType.DeveloperName = 'Club_Global_Explorer'];
        System.assert(opps.size() > 0, 'Opportunities should have been created for the test accounts');
    }
}