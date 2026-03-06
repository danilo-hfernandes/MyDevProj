@IsTest
global class VonageScheduledConfigSchedulerTest {

    @IsTest
    static void cover_all_frequencies_with_campaign() {

        // ✅ Create a real Campaign
        Campaign c = new Campaign(
            Name = 'Test Campaign',
            Status = 'In Progress',
            IsActive = true
        );
        insert c;

        List<Vonage_Campaigns_Configuration__c> cfgs =
            new List<Vonage_Campaigns_Configuration__c>();

        List<String> freqs = new List<String>{
            'Every 30 Minutes',
            'Every Hour',
            'Every 2 Hours',
            'Every 4 Hours',
            'Every 6 Hours',
            'Every 12 Hours'
        };

        // Last_Run__c = null
        for (String f : freqs) {
            cfgs.add(new Vonage_Campaigns_Configuration__c(
                Name = 'CFG ' + f,
                Active__c = true,
                Configuration_Type__c = 'Scheduled Job',
                Run_Frequency__c = f,
                Campaign__c = c.Id,
                Scheduled_Job_Query__c = 'SELECT Id FROM Account'
            ));
        }

        // Last_Run__c populated
        for (String f : freqs) {
            cfgs.add(new Vonage_Campaigns_Configuration__c(
                Name = 'CFG OLD ' + f,
                Active__c = true,
                Configuration_Type__c = 'Scheduled Job',
                Run_Frequency__c = f,
                Campaign__c = c.Id,
                Last_Run__c = System.now().addHours(-48),
                Scheduled_Job_Query__c = 'SELECT Id FROM Account'
            ));
        }

        insert cfgs;

        Test.startTest();
            new VonageScheduledConfigScheduler().execute(null);
        Test.stopTest();
    }
}