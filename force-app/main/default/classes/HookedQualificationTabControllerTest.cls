@isTest
public class HookedQualificationTabControllerTest {

    @isTest
    static void testGetRecordTypeName() {
        // Create test opportunity
        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today(),
            // Set the record type to 'Hooked Voucher' for testing
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Hooked Voucher').getRecordTypeId()
        );
        insert testOpp;

        // Call the method under test
        String recordTypeName = HookedQualificationTabController.getRecordTypeName(testOpp.Id);

        // Verify that the returned record type name matches the expected value
        System.assertEquals('Hooked Voucher', recordTypeName, 'Record type name should be "Hooked Voucher"');
    }
}