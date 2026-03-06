global class MatchMessagingSessionsToLeadsBatch implements Database.Batchable<SObject>, Database.Stateful {

    global Integer sessionsUpdatedCount = 0;
    global Integer endUsersUpdatedCount = 0;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, LeadId, EndUserAccountId,
                   MessagingEndUser.Id, MessagingEndUser.LeadId, MessagingEndUser.Name
            FROM MessagingSession
            WHERE LeadId = null
              AND EndUserAccountId = null
              AND MessagingEndUser.LeadId = null
            ORDER BY CreatedDate DESC 
        ]);
    }
 
    
    private Lead findLeadByPhone(String phone) {
        if (String.isBlank(phone)) return null;
        List<Lead> leads = [
            SELECT Id, Phone
            FROM Lead
            WHERE Phone LIKE :('%' + phone + '%') 
            LIMIT 1
        ];
        return leads.isEmpty() ? null : leads[0];
    }
    
    private Account findAccountByPhone(String phone) {
        if (String.isBlank(phone)) return null;
        List<Account> accounts = [
            SELECT Id, Phone
            FROM Account
            WHERE Phone LIKE :('%' + phone + '%') 
            LIMIT 1
        ];
        return accounts.isEmpty() ? null : accounts[0];
    }

    global void execute(Database.BatchableContext bc, List<MessagingSession> scope) {
        Map<Id, MessagingSession> sessionsToUpdate = new Map<Id, MessagingSession>();
        Map<Id, MessagingEndUser> endUsersToUpdate = new Map<Id, MessagingEndUser>();

        for (MessagingSession s : scope) {
            String phoneRaw = s.MessagingEndUser != null ? s.MessagingEndUser.Name : null;
            if (String.isBlank(phoneRaw)) continue;

            String phoneDigits = phoneRaw.startsWith('+1') ? phoneRaw.substring(2) : phoneRaw;
//            if (phoneDigits.length() != 10) continue;

            String format1 = '(' + phoneDigits.substring(0, 3) + ') ' + phoneDigits.substring(3, 6) + '-' + phoneDigits.substring(6);
            String format2 = phoneDigits.substring(0, 3) + '-' + phoneDigits.substring(3, 6) + '-' + phoneDigits.substring(6);
            String format3 = phoneDigits;
			String format4 = '(' + phoneDigits.substring(0, 3) + ')' + phoneDigits.substring(3, 6) + '-' + phoneDigits.substring(6);
			String format5 = '(' + phoneDigits.substring(0, 3) + ') ' + phoneDigits.substring(3, 6) + '' + phoneDigits.substring(6);
            
            Lead foundLead = findLeadByPhone(format1);
            if (foundLead == null) foundLead = findLeadByPhone(format2);
            if (foundLead == null) foundLead = findLeadByPhone(format3);
			if (foundLead == null) foundLead = findLeadByPhone(format4);
			if (foundLead == null) foundLead = findLeadByPhone(format5);

            if (foundLead != null) {
                s.LeadId = foundLead.Id;
                sessionsToUpdate.put(s.Id, s);

                if (s.MessagingEndUser != null) {
                    endUsersToUpdate.put(s.MessagingEndUser.Id, new MessagingEndUser(
                        Id = s.MessagingEndUser.Id,
                        LeadId = foundLead.Id
                    ));
                }
                
                
            } else {
                Account foundAccount = findAccountByPhone(format1);
                if (foundAccount == null) foundAccount = findAccountByPhone(format2);
                if (foundAccount == null) foundAccount = findAccountByPhone(format3);
                if (foundAccount == null) foundAccount = findAccountByPhone(format4);
                if (foundAccount == null) foundAccount = findAccountByPhone(format5);
                
                if (foundAccount != null) {
                    
                    if (s.MessagingEndUser != null) {
                        endUsersToUpdate.put(s.MessagingEndUser.Id, new MessagingEndUser(
                            Id = s.MessagingEndUser.Id,
                            AccountId = foundAccount.Id
                        ));
                    }
                }
                
            }
            
        }

        if (!sessionsToUpdate.isEmpty()) {
            update sessionsToUpdate.values();
            sessionsUpdatedCount += sessionsToUpdate.size();
        }
        if (!endUsersToUpdate.isEmpty()) {
            update endUsersToUpdate.values();
            endUsersUpdatedCount += endUsersToUpdate.size();
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Batch processing complete.');
        System.debug('Total MessagingSessions updated: ' + sessionsUpdatedCount);
        System.debug('Total MessagingEndUsers updated: ' + endUsersUpdatedCount);
    }
}