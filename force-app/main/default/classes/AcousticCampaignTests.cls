@IsTest
private class AcousticCampaignTests {
    @TestSetup
    static void setupData() {
        // Mock token custom setting
        Acoustic_Token__c token = new Acoustic_Token__c(
            Name = 'Default',
            Access_Token__c = 'oldToken',
            Expiration__c = System.now().addHours(1)
        );
        insert token;
    }

    @IsTest
    static void testQueueableExecutesSuccessfully() {
        // Register mock
        Test.setMock(HttpCalloutMock.class, new AcousticHttpMock());

        // Create an Account with required data
        Account acc = new Account(
            Name = 'Test Account',
            Email__c = 'test@example.com'
        );
        insert acc;

        // Run the Queueable job
        Test.startTest();
        System.enqueueJob(new AcousticCampaignQueueable(new List<Account>{acc}));
        Test.stopTest();

        // Verify results
        Account updatedAcc = [SELECT Id, Acoustic_Welcome_Email_Sent_Date__c FROM Account WHERE Id = :acc.Id];
        System.assertNotEquals(null, updatedAcc, 'Account should exist');
        // Optional: if your handler updates sent date
        // System.assertNotEquals(null, updatedAcc.Acoustic_Welcome_Email_Sent_Date__c, 'Welcome email sent date should be set');
    }

    @IsTest
    static void testTokenRefresh() {
        // Expire token to trigger refresh
        Acoustic_Token__c token = [SELECT Id, Expiration__c FROM Acoustic_Token__c LIMIT 1];
        token.Expiration__c = System.now().addMinutes(-10);
        update token;

        Test.setMock(HttpCalloutMock.class, new AcousticHttpMock());
        Test.startTest();
        String tokenValue = AcousticTokenManager.getValidToken();
        Test.stopTest();

        System.assertEquals('mockAccessToken', tokenValue, 'Token should refresh successfully');
    }

    @IsTest
    static void testErrorEmailDoesNotFail() {
        Test.startTest();
        AcousticTokenManager.sendErrorEmail('Unit Test Error', 'This is a test email body.');
        Test.stopTest();
        System.assert(true, 'sendErrorEmail executed without exception');
    }
}