public class VonageCampaignAssignmentQueueable
    implements Queueable, Database.AllowsCallouts {

    private Id configId;

    public VonageCampaignAssignmentQueueable(Id configId) {
        this.configId = configId;
    }

    public void execute(QueueableContext qc) {

        Vonage_Campaigns_Configuration__c cfg = [
            SELECT Id,
                   Campaign__c,
                   Scheduled_Job_Query__c
            FROM Vonage_Campaigns_Configuration__c
            WHERE Id = :configId
            LIMIT 1
        ];

        // 1️⃣ Run stored SOQL
        List<SObject> records =
            Database.query(cfg.Scheduled_Job_Query__c);

        if (records.isEmpty()) {
            updateLastRun(cfg.Id);
            return;
        }

        // 2️⃣ Collect record Ids (Account / Contact / Lead)
        Set<Id> recordIds = new Set<Id>();
        for (SObject s : records) {
            recordIds.add((Id)s.get('Id'));
        }

        // 3️⃣ Find existing CampaignMembers (dedupe)
        Set<Id> alreadyAssigned = new Set<Id>();

        for (CampaignMember cm : [
            SELECT AccountId, ContactId, LeadId
            FROM CampaignMember
            WHERE CampaignId = :cfg.Campaign__c
        ]) {
            if (cm.AccountId != null) alreadyAssigned.add(cm.AccountId);
            if (cm.ContactId != null) alreadyAssigned.add(cm.ContactId);
            if (cm.LeadId != null)    alreadyAssigned.add(cm.LeadId);
        }

        // 4️⃣ Insert missing CampaignMembers
        List<CampaignMember> toInsert = new List<CampaignMember>();

        for (Id rid : recordIds) {
            if (alreadyAssigned.contains(rid)) continue;

            CampaignMember cm = new CampaignMember(
                CampaignId = cfg.Campaign__c
            );

            Schema.SObjectType t = rid.getSObjectType();
            if (t == Account.SObjectType) cm.AccountId = rid;
            else if (t == Contact.SObjectType) cm.ContactId = rid;
            else if (t == Lead.SObjectType) cm.LeadId = rid;
            else continue;

            toInsert.add(cm);
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
        }

        // 5️⃣ Update last run
        updateLastRun(cfg.Id);
    }

    private static void updateLastRun(Id configId) {
        update new Vonage_Campaigns_Configuration__c(
            Id = configId,
            Last_Run__c = System.now()
        );
    }
}