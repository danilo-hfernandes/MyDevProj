@IsTest
public class VonageCampaignAssignmentQueueableTest {

    @IsTest
    static void cover_all_paths() {

        // Account (ORG PATTERN)
        Account acc = new Account(
            Name = 'Test Account',
            Affiliated_Id__c = 1002421,
            Member_Number__c = '13523412',
            Contact_Id__c = 5420.0
        );
        insert acc;

        // Contact (ORG PATTERN)
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Account',
            AccountId = acc.Id,
            Affiliate_Name__c = 'test',
            Member_Number__c = '13523413'
        );
        insert con;

        // Case (ORG PATTERN)
        Case cs = new Case(
            Status = 'New',
            Type = 'Membership Upgrade'
        );
        insert cs;

        // Opportunity (ORG PATTERN)
        Id oppRtId =
            Schema.SObjectType.Opportunity
                .getRecordTypeInfosByDeveloperName()
                .get('Membership_Annual_Dues')
                .getRecordTypeId();

        Opportunity opp = new Opportunity(
            Name = 'Opp1',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            AccountId = acc.Id,
            RecordTypeId = oppRtId
        );
        insert opp;

        // Campaign
        Campaign camp = new Campaign(
            Name = 'Test Campaign',
            Status = 'In Progress',
            IsActive = true
        );
        insert camp;

        // Existing CampaignMember (dedupe path)
        insert new CampaignMember(
            CampaignId = camp.Id,
            AccountId = acc.Id
        );

        // Config with results
        Vonage_Campaigns_Configuration__c cfgWithResults =
            new Vonage_Campaigns_Configuration__c(
                Name = 'CFG With Results',
                Active__c = true,
                Configuration_Type__c = 'Scheduled Job',
                Campaign__c = camp.Id,
                Scheduled_Job_Query__c =
                    'SELECT Id FROM Account WHERE Id = \'' + acc.Id + '\''
            );

        // Config with empty result
        Vonage_Campaigns_Configuration__c cfgEmpty =
            new Vonage_Campaigns_Configuration__c(
                Name = 'CFG Empty',
                Active__c = true,
                Configuration_Type__c = 'Scheduled Job',
                Campaign__c = camp.Id,
                Scheduled_Job_Query__c =
                    'SELECT Id FROM Account WHERE Name = \'___NO_MATCH___\''
            );

        insert new List<Vonage_Campaigns_Configuration__c>{
            cfgWithResults,
            cfgEmpty
        };

        Test.startTest();
            System.enqueueJob(
                new VonageCampaignAssignmentQueueable(cfgWithResults.Id)
            );
            System.enqueueJob(
                new VonageCampaignAssignmentQueueable(cfgEmpty.Id)
            );
        Test.stopTest();
    }
}