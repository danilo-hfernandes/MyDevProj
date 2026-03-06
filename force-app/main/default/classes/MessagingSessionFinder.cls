public with sharing class MessagingSessionFinder {
    @InvocableMethod(label='Find Messaging Session by PreviewDetails' description='Finds the most recent MessagingSession where PreviewDetails contains the given search string.')
    public static List<String> findMessagingSession(List<String> searchStrings) {
        // Extract the first search string (Flow always sends a List)
        String searchString = searchStrings[0];
        System.debug('Searching for MessagingSession with PreviewDetails containing: ' + searchString);

        If (searchString.substring(0,2) != '+1'){
            searchString = '+1' + searchString;
        }
        
        // Query MessagingSession records
        List<MessagingSession> sessions = [
            SELECT Id, CreatedDate ,  MessagingEndUser.name
            FROM MessagingSession 
            WHERE MessagingEndUser.name = :searchString
            ORDER BY CreatedDate DESC 
            LIMIT 1   
        ];
        System.debug('sessions: ' + sessions);

        // Initialize variable to store the first matching session Id
        String matchedSessionId = null;
           
        if (!sessions.isEmpty()) {
			matchedSessionId = sessions[0].Id;
        	System.debug('sessions[0].Id: ' + sessions[0].Id);
        }
        /*
        // Log the result
        if (matchedSessionId != null) {
            System.debug('Found Matching MessagingSession: ' + matchedSessionId);
        } else {
            System.debug('No Matching MessagingSession found.');
        }
*/
        // Return the result as a List (Flows require InvocableMethod to return a List)
        return matchedSessionId != null ? new List<String>{matchedSessionId} : new List<String>{};
    }
}