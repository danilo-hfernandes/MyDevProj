@isTest
public class TravelSalesReengagementBatchTest {
    @isTest
    static void testBatchController() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Travel');
        insert testAccount;

        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Closed Lost',
            CloseDate = Date.today().addDays(-30),
            RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'Travel'].Id,
            AccountId = testAccount.Id
        );
        insert testOpportunity;

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Travel',
            AccountId = testAccount.Id,
            Match_Group_Name__c = 'Old Value',
            Assign_to_Sales_Cadence__c = false,
            Cadence_Flag__c = 0
        );
        insert testContact;

        // Start the batch job
        Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock());  
        Test.startTest();
        TravelSalesReengagementBatchController batchController = new TravelSalesReengagementBatchController();
        Database.executeBatch(batchController, 1);
        Test.stopTest();
    }
}