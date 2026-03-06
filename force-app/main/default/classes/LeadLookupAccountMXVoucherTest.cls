@isTest
private class LeadLookupAccountMXVoucherTest {
    static testMethod void testTrigger() {
        
        // Enable trigger
        Apex_Trigger_On_Off__c setting = new Apex_Trigger_On_Off__c(
            Name = 'Lead-Trigger',
            isEnable__c = true
        );
        insert setting;
        
        // Create a test Account
        Account testAccount = new Account(
            Name = 'Test Account',
            Email__c = 'test@example.com',
            Phone = '123-456-7890',
            Original_Source__c = 'Test Source',
            Affiliated_Id__c = 1002421
        );
        insert testAccount;

        // Create a test Lead that should match the test Account
        Lead testLead = new Lead(
            FirstName = 'Test 2',
            LastName = 'Test Lead',
            Email = 'test@example.com',
            Phone = '123-456-7890',
            Lead_Original_Source__c = 'Test Source',
			LeadSource = 'Offsite MX Voucher',
            Company = 'nerdsoft'
        );

        // Insert the test Lead to trigger the LeadLookupAccountMXVoucher trigger
        Test.startTest();
        insert testLead;
        Test.stopTest();

        // Query 
        Lead updatedLead = [SELECT Accountid_Dup_Lead__c FROM Lead WHERE Id = :testLead.Id LIMIT 1];

        // trigger populated the Accountid_Dup_Lead__c field
        System.assertEquals(testAccount.Id, updatedLead.Accountid_Dup_Lead__c, 'Lead Account Lookup failed.');
    }
}