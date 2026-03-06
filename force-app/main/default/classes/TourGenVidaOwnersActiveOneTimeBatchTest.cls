@isTest
public class TourGenVidaOwnersActiveOneTimeBatchTest {
    
    @testSetup
    static void setupTestData() {
        // Create Accounts with Affiliates
        Account acc1 = new Account(Name = 'Account 1', Affiliated_Id__c = 1002243, Preferred_Language__c= 'ENG', Membership_Status__c = 'Active', Marketing_Email_opt_out__c= false);
        Account acc2 = new Account(Name = 'Account 2', Affiliated_Id__c = 1002311,Preferred_Language__c= 'ENG', Membership_Status__c = 'FailedLogin', Marketing_Email_opt_out__c= false);
        insert new List<Account>{acc1, acc2};
        
        // Create Contacts that meet the batch criteria
        Contact con1 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact1',
            Marketing_Email_opt_out__c = false,
            AccountId = acc1.Id
        );
        
        Contact con2 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact2',
            Marketing_Email_opt_out__c = false,
            AccountId = acc2.Id
        );
        
        Contact con3 = new Contact(
            FirstName = 'Test',
            LastName = 'Contact3',
            Preferred_Language__c = 'SPA', // Should be excluded due to language
            Membership_Status__c = 'Active',
            Marketing_Email_opt_out__c = false,
            AccountId = acc1.Id
        );
        
        insert new List<Contact>{con1, con2, con3};
    }
    
    @isTest
    static void testBatchExecution() {
        Test.setMock(HttpCalloutMock.class, new AssignContactInTourGenCadenceTestMock());  
        Test.startTest();
        
        // Start the batch job
        TourGenVidaOwnersActiveOneTimeBatch batch = new TourGenVidaOwnersActiveOneTimeBatch();
        Database.executeBatch(batch, 100);
        
        // Start the batch job
        TourGenVidaOwnersInActiveOneTimeBatch batch1 = new TourGenVidaOwnersInActiveOneTimeBatch();
        Database.executeBatch(batch1, 100);
        
        Test.stopTest();
    }
}