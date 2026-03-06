public with sharing class AcousticCampaignHandler {
    public static void processAccounts(List<Account> accounts) {
        
        if (accounts.isEmpty()) return;

        // 2. Get recipient IDs
        //Map<String,String> emailToRecipient = AcousticCampaignService.getRecipientIds(accounts);
		Map<String, AcousticCampaignService.RecipientInfo> emailInfo = AcousticCampaignService.getRecipientIds(accounts);
        
        // 3. Add to program
        //if (!emailToRecipient.isEmpty()) {
        if (!emailInfo.isEmpty()) {
            //AcousticCampaignService.addContactsToProgram(emailToRecipient);
            AcousticCampaignService.addContactsToProgram(emailInfo);
            
            // Mark accounts as sent
            List<Account> toUpdate = new List<Account>();
            for (Account acc : accounts) {
                //if (emailToRecipient.containsKey(acc.Email__c)) {
                if (emailInfo.containsKey(acc.Email__c)) {
                    //acc.Acoustic_Welcome_Email_Sent_Date__c = Date.today();
                    acc.Acoustic_Welcome_Email_Sent_Date__c = System.now();
                    toUpdate.add(acc);
                }
            }
            if (!toUpdate.isEmpty()) update toUpdate;
        }

    }
}