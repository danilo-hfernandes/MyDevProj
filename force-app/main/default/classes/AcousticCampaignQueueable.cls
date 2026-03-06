public class AcousticCampaignQueueable implements Queueable, Database.AllowsCallouts {
 
    
    private List<Id> accountIds;

    public AcousticCampaignQueueable(List<Account> accounts) {
        this.accountIds = new List<Id>();
        for (Account a : accounts) this.accountIds.add(a.Id);
    }

    public void execute(QueueableContext context) {
        List<Account> accs = [SELECT Id, Name, Email__c FROM Account WHERE Id IN :accountIds];
        AcousticCampaignHandler.processAccounts(accs);
    }

}