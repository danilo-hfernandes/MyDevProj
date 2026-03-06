global class ClearEmailMessageBodyBatch implements Database.Batchable<SObject>, Schedulable {
    
    // Query to select EmailMessages older than 30 days
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, HTMLBody 
            FROM EmailMessage 
            WHERE CreatedDate < LAST_N_DAYS:30
 and Id = '02s3t000016ua7vAAA' 
        ]);
    }

    // Execute batch processing for chunks of EmailMessages
    global void execute(Database.BatchableContext BC, List<EmailMessage> emailMessages) {
        for (EmailMessage email : emailMessages) {
            email.HTMLBody = ''; // Clear the email body
        }
        update emailMessages; // Perform bulk update
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch Job Completed: Cleared HTMLBody for old emails.');
    }

    // **Scheduler Execution**
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new ClearEmailMessageBodyBatch(), 200);
    }
}