public with sharing class GetSMSData {
    
    @AuraEnabled(cacheable=true)
    public static List<MessagingSession> getMessagingSessions(Id recordId) {
        if (String.valueOf(recordId).startsWith('00Q')) { // Only for Leads
            return [
                SELECT Id, CreatedDate, OpportunityId, PreviewDetails, Name
                FROM MessagingSession
                WHERE LeadId = :recordId
                ORDER BY CreatedDate DESC
                LIMIT 50
            ];
        }
        else if (String.valueOf(recordId).startsWith('006')) { // Only for Opportunities
            return [
                SELECT Id, CreatedDate, OpportunityId, PreviewDetails, Name
                FROM MessagingSession
                WHERE OpportunityId = :recordId
                ORDER BY CreatedDate DESC
                LIMIT 50
            ];
        }
        return new List<MessagingSession>();
    }
 
    
    // NEW: pull a full “thread” like the Messaging Session UI
    @AuraEnabled(cacheable=true)
    public static List<ConversationEntry> getConversationEntriesThread(
    	Id sessionId,
    	Integer pageSize,
    	Integer pageNumber) {
                

        if (sessionId == null) return new List<ConversationEntry>();
        if (pageSize == null || pageSize <= 0) pageSize = 10;
        if (pageNumber == null || pageNumber < 0) pageNumber = 0;
            
        // 1) Get the anchor session’s ChannelEndUserFormula 
        MessagingSession anchor = [
            SELECT Id, PreviewDetails, ChannelEndUserFormula 
            FROM MessagingSession
            WHERE Id = :sessionId
            LIMIT 1
        ];

        if (String.isBlank(anchor.ChannelEndUserFormula)) {
            // Fallback: just return entries for this one session
            return [
                SELECT Id, CreatedDate, ConversationId, Message, ActorType
                FROM ConversationEntry
                WHERE ConversationId = :sessionId
                ORDER BY CreatedDate ASC
                LIMIT 5000
            ];
        }

        // 2) All sibling sessions sharing the same PreviewDetails
        List<MessagingSession> siblings = [
            SELECT Id
            FROM MessagingSession
            WHERE ChannelEndUserFormula = :anchor.ChannelEndUserFormula 
            ORDER BY CreatedDate ASC
            LIMIT 1000
        ];
        Set<Id> sessionIds = new Set<Id>();
        for (MessagingSession ms : siblings) sessionIds.add(ms.Id);

        System.debug('>>> pageSize=' + pageSize + ', pageNumber=' + pageNumber);
        System.debug('>>> OFFSET = ' + (pageNumber * pageSize));
        System.debug('>>> sessionId=' + sessionId);
        System.debug('>>> sibling sessions=' + siblings.size());
        System.debug('>>> conversationEntries result count=' + [SELECT COUNT() FROM ConversationEntry WHERE ConversationId IN :sessionIds]);

        if (sessionIds.isEmpty()) return new List<ConversationEntry>();

        Integer offsetRows = pageNumber * pageSize;
            
        // 3) All conversation entries across those sessions
        return [
            SELECT Id, CreatedDate, ConversationId, Message, ActorType
            FROM ConversationEntry
            WHERE ConversationId IN :sessionIds
            ORDER BY CreatedDate ASC
            LIMIT :pageSize
            OFFSET :offsetRows
        ];
        
        
    }
}