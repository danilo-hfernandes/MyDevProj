trigger LeadLookupAccountMXVoucher on Lead (before insert) {
    //  Retrieve trigger control setting
    Apex_Trigger_On_Off__c leadTrigger = Apex_Trigger_On_Off__c.getValues('Lead-Trigger');

    //  If trigger is OFF, exit immediately
    if (leadTrigger == null || leadTrigger.isEnable__c == false) {
        return;
    }
    
    for (Lead l : Trigger.new) {
        if (l.Phone != null && l.Email != null && l.Lead_Original_Source__c != null) {
            
            //  Search for Account with affiliate 1002421 (strict match on Email, Phone, and Original Source)
            List<Account> matchingAccounts = [
                SELECT Id 
                FROM Account 
                WHERE Email__c = :l.Email 
                AND Phone = :l.Phone 
                AND Original_Source__c = :l.Lead_Original_Source__c 
                AND Affiliated_Id__c = 1002421 
                LIMIT 1
            ];
            
            if (!matchingAccounts.isEmpty()) {
                l.Accountid_Dup_Lead__c = matchingAccounts[0].Id;
            }

            //  Search for Account with affiliate 1002464 (match on Email OR Phone)
            List<Account> affiliateAccounts = [
                SELECT Id 
                FROM Account 
                WHERE Affiliated_Id__c = 1002464 
                AND (Email__c = :l.Email OR Phone = :l.Phone)
                LIMIT 1
            ];

            if (!affiliateAccounts.isEmpty()) {
                l.Accountid_Dup_Raise_Lead__c = affiliateAccounts[0].Id;
            }
        }
    }
}

/*

trigger LeadLookupAccountMXVoucher on Lead (before insert) {
    // Retrieve trigger control setting
    Apex_Trigger_On_Off__c leadTrigger = Apex_Trigger_On_Off__c.getValues('Lead-Trigger');

    // If trigger is OFF, exit immediately
    if (leadTrigger == null || leadTrigger.isEnable__c == false) {
        return;
    }

    // Collect values for bulk queries
    Set<String> emails = new Set<String>();
    Set<String> phones = new Set<String>();
    Set<String> sources = new Set<String>();

    for (Lead l : Trigger.new) {
        if (l.Email != null) emails.add(l.Email);
        if (l.Phone != null) phones.add(l.Phone);
        if (l.Lead_Original_Source__c != null) sources.add(l.Lead_Original_Source__c);
    }

    //️ Query for strict match (affiliate 1002421)
    Map<String, Account> strictMatchMap = new Map<String, Account>();

    for (Account acc : [
        SELECT Id, Email__c, Phone, Original_Source__c
        FROM Account
        WHERE Affiliated_Id__c = 1002421
        AND Email__c IN :emails
        AND Phone IN :phones
        AND Original_Source__c IN :sources
    ]) {
        strictMatchMap.put(
            acc.Email__c + '|' + acc.Phone + '|' + acc.Original_Source__c,
            acc
        );
    }

    // Query for OR match (affiliate 1002464)

    Map<String, Account> affiliateMatchByEmail = new Map<String, Account>();
    Map<String, Account> affiliateMatchByPhone = new Map<String, Account>();

    for (Account acc : [
        SELECT Id, Email__c, Phone
        FROM Account
        WHERE Affiliated_Id__c = 1002464
        AND (Email__c IN :emails OR Phone IN :phones)
    ]) {
        if (acc.Email__c != null)
            affiliateMatchByEmail.put(acc.Email__c, acc);

        if (acc.Phone != null)
            affiliateMatchByPhone.put(acc.Phone, acc);
    }

    // Update Leads

    for (Lead l : Trigger.new) {

        // Strict match (Affiliate 1002421)
        String strictKey = l.Email + '|' + l.Phone + '|' + l.Lead_Original_Source__c;
        if (strictMatchMap.containsKey(strictKey)) {
            l.Accountid_Dup_Lead__c = strictMatchMap.get(strictKey).Id;
        }

        // OR match (Affiliate 1002464)
        Account match2 = affiliateMatchByEmail.get(l.Email);
        if (match2 == null) match2 = affiliateMatchByPhone.get(l.Phone);

        if (match2 != null) {
            l.Accountid_Dup_Raise_Lead__c = match2.Id;
        }
    }
}
*/