public class CleanEmailHTMLBodyBatch implements Database.Batchable<SObject> {

    public Date targetDate;

    // Constructor to initialize the target date
    public CleanEmailHTMLBodyBatch() {
        // Calculate the date 15 days ago
        targetDate = Date.today().addDays(-15);
    }

    // Start method to fetch records
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Construct the SOQL query to fetch records with non-null HTMLBody
        String query = 'SELECT Id, HTMLBody, CreatedDate FROM EmailMessage WHERE CreatedDate < :targetDate LIMIT 100';
        
        // Debug the SOQL query
        System.debug('Starting batch job...');
        System.debug('SOQL Query: ' + query);
        
        // Execute the query to see if we are getting records
        List<EmailMessage> testResults = Database.query(query);
        System.debug('Number of records returned by query: ' + testResults.size());

        // Return the query locator for batch processing
        return Database.getQueryLocator(query);
    }

    // Execute method to process each batch of EmailMessage records
    public void execute(Database.BatchableContext bc, List<EmailMessage> emailMessages) {
    System.debug('Processing batch of ' + emailMessages.size() + ' record(s)...');

    if (emailMessages.isEmpty()) {
        System.debug('No records found to process.');
        return;
    }

    System.debug('Number of records to process: ' + emailMessages.size());

    for (EmailMessage em : emailMessages) {
        System.debug('Processing EmailMessage Id: ' + em.Id);

        if (String.isEmpty(em.HTMLBody)) {
            System.debug('HTMLBody is empty for EmailMessage Id: ' + em.Id);
            continue; // Skip processing if HTMLBody is empty
        }

        // Clean HTMLBody
        em.HTMLBody = cleanHTML(em.HTMLBody);
        System.debug('Cleaned HTMLBody: ' + em.HTMLBody);

        try {
            // Attempt to update the EmailMessage record
            update em;
            System.debug('Successfully updated EmailMessage Id: ' + em.Id);
        } catch (Exception e) {
            // Log error message if update fails
            System.debug('Error updating EmailMessage Id: ' + em.Id + ' - ' + e.getMessage());
        }
    }
}
    // Finish method (optional)
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch job finished.');
    }

    // Method to clean HTML (you can adjust this logic as needed)
    private String cleanHTML(String htmlContent) {
        // Simple clean: removing all HTML tags (use more complex regex if needed)
        return htmlContent.replaceAll('<[^>]+>', '');
    }
}


//CleanEmailHTMLBodyBatch batch = new CleanEmailHTMLBodyBatch();
//Database.executeBatch(batch);