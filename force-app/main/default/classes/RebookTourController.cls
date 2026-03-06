public with sharing class RebookTourController {
    public Opportunity opp { get; set; }
    public Tour_appointment__c appointment { get; set; }

    // Constructor to initialize Opportunity and Appointment
    public RebookTourController(ApexPages.StandardController stdCtrl) {
        this.opp = (Opportunity) stdCtrl.getRecord();
        
        List<Tour_appointment__c> appointmentList = [SELECT Id, Appointment_Date__c, Appointment_Time__c, 
                                                             Appt_Agent__c, Appt_Type__c, Closing_Agent__c, 
                                                             Opp_Status__c, Showed__c
                                                      FROM Tour_appointment__c 
                                                      WHERE Opportunity__c = :opp.Id LIMIT 1];

        if (!appointmentList.isEmpty()) {
            appointment = appointmentList[0];
        } else {
            appointment = new Tour_appointment__c(Opportunity__c = opp.Id);
        }
    }

    // Method to Save or Update Appointment
    public PageReference saveAppointment() {
        try {
            if (appointment.Id == null) {
                insert appointment;
            } else {
                update appointment;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Appointment saved successfully.'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error saving appointment: ' + e.getMessage()));
        }
        return null;
    }

    // Fetch Available Tours based on Selected Date & Time
    @RemoteAction
    public static List<Tour__c> getAvailableTours(String selectedDate, String selectedTime) {
        Date parsedDate;
        Time parsedTime;

        try {
            parsedDate = Date.valueOf(selectedDate);  // Convert String to Date
        } catch (Exception e) {
            System.debug('Invalid date format: ' + selectedDate);
            return new List<Tour__c>();
        }

        try {
            parsedTime = Time.newInstance(Integer.valueOf(selectedTime.split(':')[0]), Integer.valueOf(selectedTime.split(':')[1]), 0, 0);
        } catch (Exception e) {
            System.debug('Invalid time format: ' + selectedTime);
            return new List<Tour__c>();
        }

        return [SELECT Id, Name, Location__c, Day__c, Date__c, Tour_Time__c, 
                         Wave__c
                FROM Tour__c
                WHERE Date__c = :parsedDate AND Tour_Time__c = :parsedTime AND Booked_Tours__c > 0];
    }

    // Save the selected tour as a rebooked appointment
    public PageReference saveRebooking() {
        String selectedTourId = ApexPages.currentPage().getParameters().get('selectedTour');
        
        if (selectedTourId != null) {
            Tour__c selectedTour = [SELECT Id, Date__c, Tour_Time__c FROM Tour__c WHERE Id = :selectedTourId LIMIT 1];
            
            appointment.Appointment_Date__c = selectedTour.Date__c;
            appointment.Appointment_Time__c = selectedTour.Tour_Time__c;
            update appointment;
        }
        return null;
    }
}