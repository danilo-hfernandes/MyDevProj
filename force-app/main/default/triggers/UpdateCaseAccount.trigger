trigger UpdateCaseAccount on Case (before insert) {
    for (Case c : Trigger.new) {
        if (c.Case_Subscriber_Id__c != null && c.Case_Contact_Id__c != null) {
            // Query the Account based on SubscriberId and ContactId
            List<Account> matchingAccounts = [SELECT Id FROM Account WHERE SubscriberId__c = :c.Case_Subscriber_Id__c AND Contact_Id__c = :c.Case_Contact_Id__c LIMIT 1];
            
            if (!matchingAccounts.isEmpty()) {
                // If a matching Account is found, populate the lookup field
                c.AccountId = matchingAccounts[0].Id;
            }
        }
        else if (c.SuppliedEmail != null && c.ContactId == null && c.RecordTypeId == '0123t000000G91QAAS') {
            List<Contact> matchingContact = [SELECT Id FROM Contact WHERE Email = :c.SuppliedEmail LIMIT 1];
                
            if (!matchingContact.isEmpty()) {
                // If a matching Contact is found, populate the lookup field
                c.ContactId = matchingContact[0].Id;
            }
        }
    }
}