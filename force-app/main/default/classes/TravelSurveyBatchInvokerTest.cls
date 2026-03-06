@isTest
public class TravelSurveyBatchInvokerTest {
    
    @isTest
    static void testRunBatchJob() {
        Test.startTest();
        
        // Call the invocable method
        List<String> input = new List<String>{ 'Test' }; // Input is required but not used in the method
        TravelSurveyBatchInvoker.runBatchJob(input);
        
        Test.stopTest();

        // Verify that the batch job was enqueued
        List<AsyncApexJob> jobs = [SELECT Id, Status, JobType FROM AsyncApexJob WHERE JobType = 'BatchApex' ORDER BY CreatedDate DESC LIMIT 1];
        
        // Assert that a batch job was actually queued
        System.assert(!jobs.isEmpty(), 'Expected at least one batch job to be enqueued.');
        System.assertEquals('BatchApex', jobs[0].JobType, 'Expected JobType to be BatchApex.');
    }
}