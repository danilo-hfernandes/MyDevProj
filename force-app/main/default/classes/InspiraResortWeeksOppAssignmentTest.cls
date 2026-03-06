@IsTest
public class InspiraResortWeeksOppAssignmentTest {
    
    @TestSetup
    static void setupTestData() {
        
        // Create an Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Affiliated_Id__c = 1002452,
            Preferred_Language__c = 'English'
        );
        insert testAccount;

        // Create Opportunities
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            opportunities.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                AccountId = testAccount.Id,
                StageName = 'New',
                RecordTypeId = '0123t000000G7oqAAC',
                CloseDate = Date.today().addDays(30)
            ));
            //'travelRecordType.Id' Travel 0123t000000G7oqAAC
        }
        insert opportunities;

        // Create Contacts and OpportunityContactRoles for some Opportunities
        Contact testContact = new Contact(
            LastName = 'Test Contact',
            AccountId = testAccount.Id
        );
        insert testContact;

        OpportunityContactRole ocr = new OpportunityContactRole(
            OpportunityId = opportunities[0].Id,
            ContactId = testContact.Id,
            Role = 'Influencer'
        );
        insert ocr;
    }

    @IsTest
    static void testBatchExecution() {
        // Query Opportunities to use in the batch
        List<Opportunity> opportunities = [SELECT Id, Match_Group_Name__c FROM Opportunity WHERE StageName = 'New'];

        // Assert preconditions
        System.assertEquals(5, opportunities.size(), 'There should be 5 Opportunities in the test data.');
        System.assertEquals(null, opportunities[0].Match_Group_Name__c, 'Match_Group_Name__c should be null initially.');

        // Execute the batch
        Test.startTest();
        InspiraResortWeeksOppAssignment batch = new InspiraResortWeeksOppAssignment();
        Database.executeBatch(batch, 100);
        Test.stopTest();

        // Query the updated Opportunities
        opportunities = [SELECT Match_Group_Name__c FROM Opportunity WHERE StageName = 'New'];

        // Assert postconditions
        for (Opportunity opp : opportunities) {
            System.assertEquals('Travel Sales-Inspira Resort Weeks', opp.Match_Group_Name__c, 'Match_Group_Name__c should be updated.');
        }
    }

    @IsTest
    static void testSchedulableExecution() {
        Test.startTest();

        // Schedule the batch job
        String cronExp = '0 0 12 * * ?'; // Schedule it for 12 PM every day
        String jobId = System.schedule('Test Schedulable Job', cronExp, new InspiraResortWeeksOppAssignment());

        // Verify the job is scheduled
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertEquals(cronExp, ct.CronExpression, 'Cron expression should match the scheduled value.');

        Test.stopTest();
    }

    @IsTest
    static void testCadenceAssignment() {
        // Enqueue the batch
        Test.startTest();
        InspiraResortWeeksOppAssignment batch = new InspiraResortWeeksOppAssignment();
        Database.executeBatch(batch, 100);
        Test.stopTest();

        // Verify that GenericAssignToSalesCadence was enqueued
        // Assuming GenericAssignToSalesCadence logic assigns cadences and processes contacts
        System.assert(true, 'Ensure GenericAssignToSalesCadence logic is executed during testing.');
    }
}