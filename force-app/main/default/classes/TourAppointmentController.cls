public with sharing class TourAppointmentController {
    public Opportunity opp { get; set; }
    public Tour_appointment__c appointment { get; set; }

    public TourAppointmentController(ApexPages.StandardController stdCtrl) {
        // Get the Opportunity record
        this.opp = (Opportunity) stdCtrl.getRecord();
        
        // Fetch the related Tour Appointment record (assuming there is a lookup relationship)
        List<Tour_appointment__c> appointmentList = [SELECT Id, Tee_Up_Agent__c, Appointment_Date__c, Appointment_Time__c, 
                                                             Appt_Agent__c, Appt_Type__c, Closing_Agent__c, 
                                                             Opp_Status__c, Showed__c 
                                                      FROM Tour_appointment__c 
                                                      WHERE Opportunity__c = :opp.Id
                                                      LIMIT 1];
        
        if (!appointmentList.isEmpty()) {
            appointment = appointmentList[0];  // Assign the first record if found
        } else {
            appointment = new Tour_appointment__c(Opportunity__c = opp.Id);  // Initialize a new Tour Appointment record
        }
    }

    public PageReference saveAppointment() {
        if (appointment.Id == null) {
            insert appointment;
        } else {
            update appointment;
        }
        return null;
    }
}