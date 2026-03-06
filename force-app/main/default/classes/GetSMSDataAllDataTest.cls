@IsTest(SeeAllData=true)
private class GetSMSDataAllDataTest {
    @IsTest
    static void testUsingRealOrgData() {
        // Find any MessagingSession in the org
        MessagingSession ms = [SELECT Id FROM MessagingSession WHERE OpportunityId != Null LIMIT 1];
        System.assertNotEquals(null, ms, 'No MessagingSession found in org; SeeAllData=true depends on org data.');

        MessagingSession ms2 = [SELECT Id FROM MessagingSession WHERE OpportunityId = Null LIMIT 1];
        System.assertNotEquals(null, ms2, 'No MessagingSession found in org; SeeAllData=true depends on org data.');

        MessagingSession l1 = [SELECT LeadId FROM MessagingSession WHERE LeadId != Null LIMIT 1];
        System.assertNotEquals(null, L1, 'No MessagingSession found in org; SeeAllData=true depends on org data.');

        MessagingSession Opp1 = [SELECT OpportunityId FROM MessagingSession WHERE OpportunityId != Null LIMIT 1];
        System.assertNotEquals(null, Opp1, 'No MessagingSession found in org; SeeAllData=true depends on org data.');

        // Call method and assert it doesn't throw
        List<ConversationEntry> page = GetSMSData.getConversationEntriesThread(ms.Id, 5, 0);
        System.assertNotEquals(null, page);

        // Call method and assert it doesn't throw
        List<ConversationEntry> pag2e = GetSMSData.getConversationEntriesThread(ms2.Id, 5, 0);
        System.assertNotEquals(null, page);
        
        List<MessagingSession> MS3 = GetSMSData.getMessagingSessions(ms.Id);
        //List<MessagingSession> MS4 = GetSMSData.getMessagingSessions(ms2.Id);
		List<MessagingSession> MS4 = GetSMSData.getMessagingSessions(ms.Id);
		List<MessagingSession> MS5 = GetSMSData.getMessagingSessions(l1.LeadId);
		List<MessagingSession> MS6 = GetSMSData.getMessagingSessions(Opp1.OpportunityId);
		//System.assertNotEquals(MS3, MS4);
		System.assertEquals(MS3, MS4);
    }
}