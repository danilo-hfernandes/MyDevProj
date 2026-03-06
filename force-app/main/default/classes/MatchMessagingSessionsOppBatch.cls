global class MatchMessagingSessionsOppBatch implements Database.Batchable<SObject>, Database.Stateful {

    global Integer sessionsUpdatedCount = 0;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, LeadId, EndUserAccountId,
                   MessagingEndUser.Id, MessagingEndUser.LeadId, MessagingEndUser.Name, createddate
            FROM MessagingSession
            WHERE OpportunityId = null
            AND Opportunity_Match_Processed__c = False
//for test:
//and Id = '0MwO1000005loMfKAI'
            ORDER BY CreatedDate DESC 
            LIMIT 100000
        ]);
    }
 
  
    private Opportunity findOppByPhone(String phone, Datetime createdDt) {
        if (String.isBlank(phone)) return null;
        List<Opportunity> Opp = [
            SELECT Id, Name, RecordType.name, createddate
            FROM Opportunity 
            WHERE (RecordType.name = 'Hawaii Collection Membership' OR RecordType.name = 'SFX Membership' OR RecordType.name = 'Club Global Explorer')
            and Account.Phone LIKE :('%' + phone + '%') 
            and createddate < :createdDt
            order by createddate desc
            LIMIT 1
        ];
        System.debug('Opp: ' + Opp);
        return Opp.isEmpty() ? null : Opp[0];
    }

    global void execute(Database.BatchableContext bc, List<MessagingSession> scope) {
        Map<Id, MessagingSession> sessionsToUpdate = new Map<Id, MessagingSession>();

        for (MessagingSession s : scope) {
	        System.debug('s: ' + s);
            String phoneRaw = s.MessagingEndUser != null ? s.MessagingEndUser.Name : null;
            if (String.isBlank(phoneRaw)) continue;

            String phoneDigits = phoneRaw.startsWith('+1') ? phoneRaw.substring(2) : phoneRaw;

            String format1 = '(' + phoneDigits.substring(0, 3) + ') ' + phoneDigits.substring(3, 6) + '-' + phoneDigits.substring(6);
            String format2 = phoneDigits.substring(0, 3) + '-' + phoneDigits.substring(3, 6) + '-' + phoneDigits.substring(6);
            String format3 = phoneDigits;
			String format4 = '(' + phoneDigits.substring(0, 3) + ')' + phoneDigits.substring(3, 6) + '-' + phoneDigits.substring(6);
			String format5 = '(' + phoneDigits.substring(0, 3) + ') ' + phoneDigits.substring(3, 6) + '' + phoneDigits.substring(6);
            
            Opportunity foundOpp = findOppByPhone(format1, s.CreatedDate);
            if (foundOpp == null) foundOpp = findOppByPhone(format2, s.CreatedDate);
            if (foundOpp == null) foundOpp = findOppByPhone(format3, s.CreatedDate);
            if (foundOpp == null) foundOpp = findOppByPhone(format4, s.CreatedDate);
            if (foundOpp == null) foundOpp = findOppByPhone(format5, s.CreatedDate);
            
            if (foundOpp != null) {
                s.OpportunityId = foundOpp.Id;
            }
            s.Opportunity_Match_Processed__c = True;
            sessionsToUpdate.put(s.Id, s);  
                
        }

        if (!sessionsToUpdate.isEmpty()) {
            update sessionsToUpdate.values();
            sessionsUpdatedCount += sessionsToUpdate.size();
        }
        
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch processing complete.');
        System.debug('Total MessagingSessions updated: ' + sessionsUpdatedCount);
    }
}