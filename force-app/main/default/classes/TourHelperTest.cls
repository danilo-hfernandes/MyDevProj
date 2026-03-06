@isTest
private class TourHelperTest {

    @isTest
    static void testUpdateTourDetails() {
        // Create test Lead with Tour_Time__c
        Lead lead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Co',
            Email = 'testlead@example.com',
            Phone = '1234567890',
            Tour_Time__c = Time.newInstance(9, 30, 0, 0)
        );
        insert lead;

        // Create Tour__c record referencing the Lead
        Tour__c tour = new Tour__c(
            Lead_ID__c = lead.Id,
            Date__c = Date.today()
        );
        insert tour;

        // Load and call helper
        List<Tour__c> tourList = [SELECT Id, Lead_ID__c FROM Tour__c WHERE Id = :tour.Id];
        TourHelper.updateTourDetails(tourList);

        // Simulate update
        update tourList;
    }
}