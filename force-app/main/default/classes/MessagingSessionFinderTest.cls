@IsTest(SeeAllData=true)
public class MessagingSessionFinderTest {
    
    @isTest
    static void testFindMessagingSession_MatchFound() {
        Test.startTest();
        
        // Query an existing MessagingSession (Ensure there is at least one valid record in the org)
        List<MessagingSession> sessions = [
            SELECT Id, PreviewDetails, MessagingEndUser.name 
            FROM MessagingSession 
            ORDER BY CreatedDate DESC 
            LIMIT 1
        ];
        
        // Ensure we found a record to test
        if (sessions.isEmpty()) {
            System.debug('⚠️ No existing MessagingSession found for testing.');
            return; // Exit test if no data available
        }

        // Extract an existing PreviewDetails value to search for
        String searchTerm = sessions[0].MessagingEndUser.name; 
            //sessions[0].PreviewDetails.split(' ')[0]; // Using the first word as search term
        List<String> searchString = new List<String>{ searchTerm };

        // Call the invocable method
        List<String> result = MessagingSessionFinder.findMessagingSession(searchString);

        Test.stopTest();

        // Assert that a session ID is returned
        System.assert(!result.isEmpty(), 'Expected at least one matching MessagingSession');
        System.assertEquals(sessions[0].Id, result[0], 'Returned session ID should match expected session');
    }

    @isTest
    static void testFindMessagingSession_NoMatch() {
        Test.startTest();
        
        // Call with a search string that likely won’t match anything
        List<String> searchString = new List<String>{ 'nonexistingvalue' };
        List<String> result = MessagingSessionFinder.findMessagingSession(searchString);

        Test.stopTest();

        // Assert that no session is returned
        System.assert(result.isEmpty(), 'Expected no matching MessagingSession');
    }
}