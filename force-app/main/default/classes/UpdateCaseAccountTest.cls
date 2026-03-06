@isTest
public class UpdateCaseAccountTest {

    @isTest
    static void testUpdateCaseAccount() {
        // Create test data: Accounts and Cases
        Account testAccount = new Account(
            Name = 'Test Account',
            SubscriberId__c = '12345', // Sample SubscriberId
            Contact_Id__c = 123 // Sample ContactId
        );
        insert testAccount;

        Case testCase1 = new Case(
            Case_Subscriber_Id__c = '12345', // Sample Case SubscriberId
            Case_Contact_Id__c = 123, // Sample Case ContactId
            Status = 'New'
        );
        insert testCase1;

        Case testCase2 = new Case(
            SuppliedEmail = 'test@example.com', // Sample SuppliedEmail
            RecordTypeId = '0123t000000G91QAAS',
            Status = 'New'
        );
        insert testCase2;

        try {
            Test.startTest();
            // initiate the trigger 
        } catch (Exception e) {
            System.debug('Error message: ' + e.getMessage());
        } finally {
            Test.stopTest();
        }

        // Query the Case 
        testCase1 = [SELECT AccountId FROM Case WHERE Id = :testCase1.Id LIMIT 1];
        testCase2 = [SELECT ContactId FROM Case WHERE Id = :testCase2.Id LIMIT 1];


        // Perform assertions
        System.assertEquals(testAccount.Id, testCase1.AccountId, 'AccountId should be populated with the matching Account Id');
        System.assertNotEquals(null, testCase2.ContactId, 'ContactId should be populated');
    }
}