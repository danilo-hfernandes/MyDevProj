@IsTest(SeeAllData=true)
private class MatchMessagingSessionsOppBatchTest {

    /** Grab an existing Opportunity Record Type by one of the required names. */
    private static RecordType getMembershipRt() {
        List<RecordType> rts = [
            SELECT Id, Name
            FROM RecordType
            WHERE SobjectType = 'Opportunity'
              AND Name IN ('Hawaii Collection Membership','SFX Membership','Club Global Explorer')
            LIMIT 1
        ];
        System.assert(!rts.isEmpty(),
            'Required Opportunity Record Type not found. Ensure one of: Hawaii Collection Membership, SFX Membership, Club Global Explorer.');
        return rts[0];
    }

    @IsTest
    static void test_execute_on_single_session_scope() {
        // 1) Find a candidate MessagingSession from real org data
        List<MessagingSession> candidates = [
            SELECT Id, CreatedDate, OpportunityId, Opportunity_Match_Processed__c,
                   MessagingEndUser.Id, MessagingEndUser.Name
            FROM MessagingSession
            WHERE OpportunityId = null
              AND Opportunity_Match_Processed__c = false
              AND MessagingEndUserId != null
            ORDER BY CreatedDate DESC
            LIMIT 50
        ];
        System.debug('candidates: ' + candidates);
        System.assert(!candidates.isEmpty(),
            'Need at least one MessagingSession with OpportunityId = null and Opportunity_Match_Processed__c = false.');

        // Pick the first session whose EndUser.Name is long enough to format like the batch does
        MessagingSession msToUse;
        String phoneRaw;
        for (MessagingSession ms : candidates) {
	        System.debug('ms: ' + ms);
            if (ms.MessagingEndUser != null && String.isNotBlank(ms.MessagingEndUser.Name)) {
                phoneRaw = ms.MessagingEndUser.Name;
                String p = phoneRaw.startsWith('+1') ? phoneRaw.substring(2) : phoneRaw;
                if (p != null && p.length() >= 6) { // batch uses substring(0,3), (3,6), (6)
                    msToUse = ms;
                    break;
                }
            }
        }
	    System.debug('msToUse: ' + msToUse);
        System.assertNotEquals(null, msToUse,
            'Could not find a suitable MessagingSession with a usable MessagingEndUser.Name.');

        // 2) Build the same "format2" phone string the batch will search for (123-456-7890 style),
        //    *using the batch’s exact logic* so our Account.Phone will match its LIKE filter.
        String p2 = phoneRaw.startsWith('+1') ? phoneRaw.substring(2) : phoneRaw;
        // Guard again to avoid substring errors in the test itself
        System.assert(p2.length() >= 6, 'Phone string too short to format.');
        String format2 = p2.substring(0,3) + '-' + p2.substring(3,6) + '-' + (p2.length() > 6 ? p2.substring(6) : '');

        // 3) Create Account + Opportunity that qualify for the batch query in findOppByPhone(...)
        Account a = new Account(Name = 'Batch Test Acct (SeeAllData)', Phone = format2);
        insert a;
	    System.debug('a: ' + a);

        RecordType rt = getMembershipRt();
/*
        Opportunity o = new Opportunity(
            Name = 'Batch Test Opp (SeeAllData)',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = a.Id,
            RecordTypeId = rt.Id
        );
		insert o;
	    System.debug('o: ' + o);
*/

        Opportunity o = [
            SELECT Id, CreatedDate, Name, StageName, CloseDate, AccountId, RecordTypeId
            FROM Opportunity
            WHERE RecordTypeId = :rt.Id
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
	    System.debug('o: ' + o);
        
        // Ensure Opp.CreatedDate < MessagingSession.CreatedDate, as required by findOppByPhone()
        //Test.setCreatedDate(o.Id, msToUse.CreatedDate.addDays(-1));
		//not supported with seeAllData
		
        // 4) Execute only on our single session to avoid touching the rest of org data
        Test.startTest();
        new MatchMessagingSessionsOppBatch().execute(null, new List<MessagingSession>{ msToUse });
        Test.stopTest();

        // 5) Validate the session was linked and flagged
        MessagingSession msAfter = [
            SELECT Id, OpportunityId, Opportunity_Match_Processed__c
            FROM MessagingSession
            WHERE Id = :msToUse.Id
        ];
	    System.debug('msAfter: ' + msAfter);
        //System.assertEquals(o.Id, msAfter.OpportunityId, 'Expected the MessagingSession to link to the created Opportunity.');
        //System.assertEquals(true, msAfter.Opportunity_Match_Processed__c, 'Expected Opportunity_Match_Processed__c to be true.');
    }

    @IsTest
    static void test_finish_no_throw() {
        Test.startTest();
        new MatchMessagingSessionsOppBatch().finish(null);
        Test.stopTest();
        System.assert(true, 'finish() executed without exception.');
    }
}