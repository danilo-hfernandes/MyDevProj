@isTest
private class RebookTourControllerTest {
    @isTest
    static void testControllerConstructorAndSaveAppointmentInsert() {
        // Create test Opportunity
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;

        // Instantiate controller without existing appointment
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp);
        RebookTourController controller = new RebookTourController(stdCtrl);
        controller.saveAppointment();  // This will insert the new appointment
        Test.stopTest();
    }

    @isTest
    static void testControllerConstructorAndSaveAppointmentUpdate() {
        // Create test Opportunity
        Opportunity opp = new Opportunity(Name = 'Test Opp 2', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;

        // Create related Tour_appointment__c
        Tour_appointment__c appt = new Tour_appointment__c(
            Opportunity__c = opp.Id,
            Appointment_Date__c = Date.today(),
            Appointment_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        insert appt;

        // Instantiate controller with existing appointment
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp);
        RebookTourController controller = new RebookTourController(stdCtrl);
        controller.saveAppointment();  // This will update the existing appointment
        Test.stopTest();
    }

    @isTest
    static void testGetAvailableTours_Valid() {
        // Insert a Tour__c record
        Tour__c tour = new Tour__c(
            Name = 'Test Tour',
            Location__c = 'Test Location',
            Day__c = 'Monday',
            Date__c = Date.today(),
            Tour_Time__c = Time.newInstance(10, 30, 0, 0),
            Wave__c = 'Wave 1',
            Booked_Tours__c = 1
        );
        insert tour;

        Test.startTest();
        List<Tour__c> tours = RebookTourController.getAvailableTours(String.valueOf(tour.Date__c), '10:30');
        Test.stopTest();
    }

    @isTest
    static void testGetAvailableTours_InvalidDateAndTime() {
        Test.startTest();
        RebookTourController.getAvailableTours('invalid-date', 'invalid-time');
        Test.stopTest();
    }

    @isTest
    static void testSaveRebooking() {
        // Create test Opportunity
        Opportunity opp = new Opportunity(Name = 'Test Opp 3', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;

        // Create Tour and Appointment
        Tour__c tour = new Tour__c(
            Name = 'Tour Rebook',
            Location__c = 'HQ',
            Day__c = 'Tuesday',
            Date__c = Date.today().addDays(1),
            Tour_Time__c = Time.newInstance(11, 0, 0, 0),
            Wave__c = 'Wave 2',
            Booked_Tours__c = 2
        );
        insert tour;

        Tour_appointment__c appt = new Tour_appointment__c(
            Opportunity__c = opp.Id,
            Appointment_Date__c = Date.today(),
            Appointment_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        insert appt;

        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp);
        RebookTourController controller = new RebookTourController(stdCtrl);

        // Simulate page parameter
        ApexPages.currentPage().getParameters().put('selectedTour', tour.Id);
        controller.saveRebooking();
        Test.stopTest();
    }
}