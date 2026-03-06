@IsTest
private class MatchMessagingSessionsToLeadsBatchTest {

    @IsTest
    static void testBatchProcessing() {
        // Create a Lead with phone in one of the formats
        Lead testLead = new Lead(
            LastName = 'Test Lead',
            Company = 'Test Company',
            Phone = '(407) 992-8511',
            Email = 'test13082025@test.com'
        );
        insert testLead;

        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String MCId = '';
        if(runningInASandbox){
            MCId = '0Mj7d0000008SgSCAU';
        }
        else{
            MCId = '0Mj4z0000008OIPCA2';
        }
        
        // Create a MessagingEndUser with phone in +1XXXXXXXXXX format
        MessagingEndUser endUser = new MessagingEndUser(
            Name = '+14079928511',
            MessagingChannelId = MCId,
            MessageType = 'Text',                   
            MessagingPlatformKey = '+14079928511'
        );
        insert endUser;

        MessagingEndUser endUser2 = new MessagingEndUser(
            Name = '+14079928512',
            MessagingChannelId = MCId,
            MessageType = 'Text',                   
            MessagingPlatformKey = '+14079928512'
        );
        insert endUser2;

        // Create a MessagingSession without LeadId or EndUserAccountId
        MessagingSession session = new MessagingSession(
            MessagingEndUserId = endUser.Id,
            MessagingChannelId = MCId,
            Status = 'Ended'
        );
        insert session;

        MessagingSession session2 = new MessagingSession(
            MessagingEndUserId = endUser2.Id,
            MessagingChannelId = MCId,
            Status = 'Ended'
        );
        insert session2;

        // Run the batch
        Test.startTest();
        Database.executeBatch(new MatchMessagingSessionsToLeadsBatch(), 200);
        Test.stopTest(); 

        // Reload records to verify updates
        MessagingSession updatedSession = [
            SELECT Id, LeadId, MessagingEndUser.LeadId
            FROM MessagingSession
            WHERE Id = :session.Id
            LIMIT 1
        ];

        // Assert LeadId updated
        System.assertEquals(testLead.Id, updatedSession.LeadId, 'LeadId on MessagingSession should match the Lead created');
        System.assertEquals(testLead.Id, updatedSession.MessagingEndUser.LeadId, 'LeadId on MessagingEndUser should match the Lead created');
    }
}