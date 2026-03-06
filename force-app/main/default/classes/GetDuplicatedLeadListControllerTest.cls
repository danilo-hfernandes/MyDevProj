@IsTest
private class GetDuplicatedLeadListControllerTest {

    private static Id getAdSalesRecordTypeId() {
        return [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Lead'
            AND Name = 'Ad Sales'
            LIMIT 1
        ].Id;
    }

    private static Id getAnyOtherRecordTypeId() {
        return [
            SELECT Id
            FROM RecordType
            WHERE SObjectType = 'Lead'
            AND Name != 'Ad Sales'
            LIMIT 1
        ].Id;
    }

    @IsTest
    static void testCoverageOnly() {

        Id adSalesRtId = getAdSalesRecordTypeId();
        Id otherRtId   = getAnyOtherRecordTypeId();

        // Main Lead (valid - following your sample)
        Lead mainLead = new Lead();
        mainLead.LastName = 'test';
        mainLead.Company = 'test';
        mainLead.LeadSource = 'CFD FB';
        mainLead.Phone = '1234567891';
        mainLead.Email = 'dup@test.com';
        mainLead.RecordTypeId = adSalesRtId;
        insert mainLead;

        // Duplicate Lead (same phone/email)
        Lead duplicateLead = new Lead();
        duplicateLead.LastName = 'test2';
        duplicateLead.Company = 'test';
        duplicateLead.LeadSource = 'CFD FB';
        duplicateLead.Phone = '1234567891';
        duplicateLead.Email = 'dup@test.com';
        duplicateLead.RecordTypeId = adSalesRtId;
        insert duplicateLead;

        // Lead with different RecordType
        Lead wrongRTLead = new Lead();
        wrongRTLead.LastName = 'WrongRT';
        wrongRTLead.Company = 'test';
        wrongRTLead.LeadSource = 'CFD FB';
        wrongRTLead.Phone = '1111111111';
        wrongRTLead.Email = 'wrong@test.com';
        wrongRTLead.RecordTypeId = otherRtId;
        insert wrongRTLead;

        Test.startTest();

        // Path 1 – Blank Id
        GetDuplicatedLeadListController.GetLeads(null);

        // Path 2 – Wrong RecordType
        GetDuplicatedLeadListController.GetLeads(wrongRTLead.Id);

        // Path 3 – Duplicate search path
        GetDuplicatedLeadListController.GetLeads(mainLead.Id);

        Test.stopTest();
    }
}