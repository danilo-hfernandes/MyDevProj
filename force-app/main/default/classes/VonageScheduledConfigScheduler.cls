global class VonageScheduledConfigScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {

        List<Vonage_Campaigns_Configuration__c> configs = [
            SELECT Id,
                   Campaign__c,
                   Run_Frequency__c,
                   Last_Run__c,
                   Scheduled_Job_Query__c
            FROM Vonage_Campaigns_Configuration__c
            WHERE Active__c = TRUE
              AND Configuration_Type__c = 'Scheduled Job'
        ];

        for (Vonage_Campaigns_Configuration__c cfg : configs) {
            if (shouldRunNow(cfg)) {
                System.enqueueJob(
                    new VonageCampaignAssignmentQueueable(cfg.Id)
                );
            }
        }
    }

    private static Boolean shouldRunNow(Vonage_Campaigns_Configuration__c cfg) {
        if (cfg.Last_Run__c == null) return true;

        Long minutesSinceLastRun =
            (System.now().getTime() - cfg.Last_Run__c.getTime()) / (1000 * 60);

        switch on cfg.Run_Frequency__c {
            when 'Every 30 Minutes' { return minutesSinceLastRun >= 30; }
            when 'Every Hour'       { return minutesSinceLastRun >= 60; }
            when 'Every 2 Hours'    { return minutesSinceLastRun >= 120; }
            when 'Every 4 Hours'    { return minutesSinceLastRun >= 240; }
            when 'Every 6 Hours'    { return minutesSinceLastRun >= 360; }
            when 'Every 12 Hours'   { return minutesSinceLastRun >= 720; }
            when 'Daily'            { return minutesSinceLastRun >= 1440; }
            when else               { return false; }
        }
    }
}