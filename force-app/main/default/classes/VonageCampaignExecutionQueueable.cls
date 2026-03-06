public class VonageCampaignExecutionQueueable implements Queueable {

    private Id configId;

    public VonageCampaignExecutionQueueable(Id configId) {
        this.configId = configId;
    }

    public void execute(QueueableContext qc) {

        Vonage_Campaigns_Configuration__c cfg =
            [SELECT Id,
                    Campaign__c,
                    Scheduled_Job_Query__c
             FROM Vonage_Campaigns_Configuration__c
             WHERE Id = :configId
             LIMIT 1];

        if (cfg.Campaign__c == null || cfg.Scheduled_Job_Query__c == null) {
            return;
        }

        // 1️⃣ Execute dynamic query
        List<SObject> targets =
            Database.query(cfg.Scheduled_Job_Query__c);

        if (targets.isEmpty()) {
            updateLastRun(cfg);
            return;
        }

        // 2️⃣ Collect record Ids
        Set<Id> recordIds = new Set<Id>();
        for (SObject s : targets) {
            recordIds.add(s.Id);
        }

        // 3️⃣ Remove already-existing CampaignMembers
        Set<Id> alreadyMembers = new Set<Id>();

        for (CampaignMember cm : [
            SELECT ContactId, LeadId
            FROM CampaignMember
            WHERE CampaignId = :cfg.Campaign__c
              AND (ContactId IN :recordIds OR LeadId IN :recordIds)
        ]) {
            if (cm.ContactId != null) alreadyMembers.add(cm.ContactId);
            if (cm.LeadId != null) alreadyMembers.add(cm.LeadId);
        }

        // 4️⃣ Build new CampaignMembers
        List<CampaignMember> toInsert = new List<CampaignMember>();

        for (Id rid : recordIds) {
            if (alreadyMembers.contains(rid)) continue;

            CampaignMember cm = new CampaignMember(
                CampaignId = cfg.Campaign__c
            );

            if (String.valueOf(rid).startsWith('003')) {
                cm.ContactId = rid;
            } else if (String.valueOf(rid).startsWith('00Q')) {
                cm.LeadId = rid;
            } else {
                continue;
            }

            toInsert.add(cm);
        }

        if (!toInsert.isEmpty()) {
            insert toInsert;
        }

        // 5️⃣ Update Last_Run__c
        updateLastRun(cfg);
    }

    private static void updateLastRun(Vonage_Campaigns_Configuration__c cfg) {
        cfg.Last_Run__c = System.now();
        update cfg;
    }
}