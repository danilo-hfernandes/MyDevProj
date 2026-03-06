@isTest
private class UpdateClubVentureOpportunitiesBatchTest {

    @isTest
    static void testBatchExecution() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User devUser = new User(
            FirstName = 'Dev',
            LastName = 'Account',
            Alias = 'devacct',
            Email = 'dev@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York',
            UserName = 'dev.account.' + DateTime.now().getTime() + '@test.com'
        );
        insert devUser;
   Date enrollmentDate = Date.today().addDays(-15);
        Account acc = new Account(
            Name = 'Test Account',
            Affiliated_Id__c = 1002453,
            Preferred_Language__c = 'ENG',
            Enrollment_Date__c = enrollmentDate
        );
        insert acc;

        RecordType rt = [
            SELECT Id FROM RecordType 
            WHERE SObjectType = 'Opportunity' AND Name = 'Club Venture Membership' 
            LIMIT 1
        ];

     

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'New',
            CloseDate = Date.today().addDays(30),
            RecordTypeId = rt.Id,            
            OwnerId = devUser.Id,
            AccountId = acc.Id
        );
        insert opp;

        Test.startTest();
        Database.executeBatch(new UpdateClubVentureOpportunitiesBatch(), 1);
        Test.stopTest();

    }
}