@isTest
private class TourControllerTest {

    static Opportunity createOpportunity() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opp',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        insert opp;
        return opp;
    }

    @isTest
    static void testConstructorWithExistingTour() {
        Opportunity opp = createOpportunity();

        // Create related tour
        Tour__c tour = new Tour__c(
            Opportunity__c = opp.Id,
            Date__c = Date.today(),
            Tour_Time__c = Time.newInstance(10, 0, 0, 0),
            Tour_Status__c = 'Booked',
            Location__c = 'HQ'
        );
        insert tour;

        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        TourController controller = new TourController(sc);
        controller.saveTour(); // triggers update
    }

    @isTest
    static void testConstructorWithoutTour() {
        Opportunity opp = createOpportunity();

        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        TourController controller = new TourController(sc);
        controller.saveTour(); // triggers insert
    }
}