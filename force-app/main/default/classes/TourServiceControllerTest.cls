@isTest
private class TourServiceControllerTest {

    @isTest
    static void testCreateTourRecord() {
        // Setup: Create sample TourRequest data for Flow
        List<TourServiceController.TourRequest> requests = new List<TourServiceController.TourRequest>();

        TourServiceController.TourRequest req = new TourServiceController.TourRequest();
        req.tourDate = Date.today();  // Set today's date
        req.tourTime = '09:30';       // Set time in HH:mm format
        
        requests.add(req);  // Add to list

        Test.startTest();
        
        // Call the method in TourServiceController using Flow (Invocable)
        List<Id> createdTourIds = TourServiceController.createTourRecord(requests);
        
        Test.stopTest();

        // Check if the Tour records were created successfully
        // Retrieve the created tours based on returned Ids
        List<Tour__c> createdTours = [SELECT Id, Date__c, Tour_Time__c FROM Tour__c WHERE Id IN :createdTourIds];

        // Simulate successful creation (no asserts as per your request)
        System.debug('Created Tour IDs: ' + createdTourIds);
    }
}