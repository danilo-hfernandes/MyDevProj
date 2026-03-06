public with sharing class TravelSurveyBatchInvoker {
    
    @InvocableMethod(label='Run Travel Survey Batch Job' description='Executes the TravelSurveyBatchJob batch process.')
    public static void runBatchJob(List<String> input) {
        // Run the batch job with default batch size
        Database.executeBatch(new TravelSurveyBatchJob(), 200);
    }
}