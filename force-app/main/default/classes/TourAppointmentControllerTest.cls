@isTest
private class TourAppointmentControllerTest {
    @isTest
    static void testInsertAppointment() {
        // Create a test Opportunity
        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;

        // Initialize controller without existing appointment
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp);
        TourAppointmentController controller = new TourAppointmentController(stdCtrl);
        controller.saveAppointment(); // This will insert the appointment
        Test.stopTest();
    }

    @isTest
    static void testUpdateAppointment() {
        // Create a test Opportunity
        Opportunity opp = new Opportunity(Name = 'Test Opp 2', StageName = 'Prospecting', CloseDate = Date.today());
        insert opp;

        // Create an appointment related to the opportunity
        Tour_appointment__c appt = new Tour_appointment__c(
            Opportunity__c = opp.Id,
            Appointment_Date__c = Date.today(),
            Appointment_Time__c = Time.newInstance(9, 0, 0, 0)
        );
        insert appt;

        // Initialize controller with existing appointment
        Test.startTest();
        ApexPages.StandardController stdCtrl = new ApexPages.StandardController(opp);
        TourAppointmentController controller = new TourAppointmentController(stdCtrl);
        controller.saveAppointment(); // This will update the appointment
        Test.stopTest();
    }
}