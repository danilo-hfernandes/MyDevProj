public class TourAppointmentHelper {
    private static Boolean isRecursive = true;
    private static Boolean isRecursive2 = true;           
    public static void updateTourDetails(List<Tour_appointment__c> tourRecords) {
        Set<Id> leadIds = new Set<Id>();
        
        for (Tour_appointment__c tour : tourRecords) {
            if (tour.Lead_ID__c != null) {
                leadIds.add(tour.Lead_ID__c);
            }
        }
        
        if (!leadIds.isEmpty()) {
            Map<Id, Lead> leadMap = new Map<Id, Lead>(
                [SELECT Id, Tour_Time__c FROM Lead WHERE Id IN :leadIds]
            );
            
            for (Tour_appointment__c tour : tourRecords) {
                if (tour.Lead_ID__c != null  && tour.TA_Rebooked_From_Comp__c == False && leadMap.containsKey(tour.Lead_ID__c)) {
                    tour.Appointment_Time__c = leadMap.get(tour.Lead_ID__c).Tour_Time__c;
                }
            }
        }
    }

    public static void processAfterEvents(List<Tour_appointment__c> tourRecords) {
        if (!isRecursive) {
            System.debug('Skipping processAfterEvents due to recursion.');
            return;
        }
        isRecursive = false; // Prevent recursion
        
        Set<Date> tourDates = new Set<Date>();
        Map<String, Tour__c> tourMap = new Map<String, Tour__c>();
        
        for (Tour_appointment__c appointment : tourRecords) {
            if (appointment.Appointment_Date__c != null && appointment.Appointment_Time__c != null) {
                tourDates.add(appointment.Appointment_Date__c);
                String key = appointment.Appointment_Date__c + '-' + formatTime(appointment.Appointment_Time__c);
                tourMap.put(key, null);
            }
        }
        
        if (!tourDates.isEmpty()) {
            List<Tour__c> matchingTours = [
                SELECT Id, Date__c, Tour_Time__c, Tour_Allotment__c, Booked_Tours__c
                FROM Tour__c
                WHERE Date__c IN :tourDates
            ];
            
            for (Tour__c tour : matchingTours) {
                String key = tour.Date__c + '-' + formatTime(tour.Tour_Time__c);
                tourMap.put(key, tour);
            }
            
            List<Tour__c> toursToUpdate = new List<Tour__c>();
            List<Tour_appointment__c> appointmentsToUpdate = new List<Tour_appointment__c>();
            
            for (Tour_appointment__c appointment : tourRecords) {
                String key = appointment.Appointment_Date__c + '-' + formatTime(appointment.Appointment_Time__c);
                
                if (tourMap.containsKey(key) && tourMap.get(key) != null) {
                    Tour__c matchedTour = tourMap.get(key);
                    // Ensure Booked_Tours__c is not null
                if (matchedTour.Booked_Tours__c == null) {
                    matchedTour.Booked_Tours__c = 0;
                }
                    
                    if (matchedTour.Booked_Tours__c == 0 || matchedTour.Booked_Tours__c > 0) {
                    matchedTour.Booked_Tours__c += 1;
                        toursToUpdate.add(matchedTour);
                        
                        Tour_appointment__c updatedAppointment = new Tour_appointment__c(
                            Id = appointment.Id,
                            Tour__c = matchedTour.Id
                        );
                        appointmentsToUpdate.add(updatedAppointment);
                    }
                }
            }
            
            if (!toursToUpdate.isEmpty()) {
                update toursToUpdate;
            }
            if (!appointmentsToUpdate.isEmpty()) {
                update appointmentsToUpdate;
            }
        }
        
        isRecursive = true; // Reset flag after execution
    }

    public static String formatTime(Time timeValue) {
        if (timeValue == null) {
            return null;
        }
        return String.format('{0}:{1}:{2}', new String[]{String.valueOf(timeValue.hour()), 
            String.valueOf(timeValue.minute()), 
            String.valueOf(timeValue.second())});
    }
    
    public static void processCancelledAppointments(Set<Id> cancelledTourAppointmentIds) {
        System.debug('Processing cancelled appointments: ' + cancelledTourAppointmentIds);
        
        // Fetch related Tour__c IDs from the cancelled Tour_appointment__c records
        List<Tour_appointment__c> cancelledAppointments = [
            SELECT Id, Tour__c
            FROM Tour_appointment__c
            WHERE Id IN :cancelledTourAppointmentIds
            AND Tour__c != null
        ];
        
        if (cancelledAppointments.isEmpty()) {
            System.debug('### No appointments found with associated Tours, exiting early.');
            return;
        }
        
        // Extract the Tour__c IDs from the appointments
        Set<Id> tourIds = new Set<Id>();
        for (Tour_appointment__c appointment : cancelledAppointments) {
            tourIds.add(appointment.Tour__c);
        }
        
        System.debug('### Related Tour IDs: ' + tourIds);
        
        // Fetch the corresponding Tour__c records
        List<Tour__c> toursToUpdate = [
            SELECT Id, Booked_Tours__c
            FROM Tour__c
            WHERE Id IN :tourIds
        ];
        
        System.debug('### Retrieved Tours: ' + toursToUpdate);
        
        List<Tour__c> updatedTours = new List<Tour__c>();
        
        for (Tour__c tour : toursToUpdate) {
            if (tour.Booked_Tours__c == null) {
                tour.Booked_Tours__c = 0;
            }
            
            if (tour.Booked_Tours__c > 0) {
                tour.Booked_Tours__c -= 1; // Decrement booked tours count
                updatedTours.add(tour);
            }
        }
        
        if (!updatedTours.isEmpty()) {
            update updatedTours;
            System.debug('### Updated Tours After Cancellation: ' + updatedTours);
        }
    }
    
   /* @future
    public static void processUpdatedAppointments(Set<Id> appointmentIds) {
        if (!isRecursive2) {
            System.debug('Skipping processUpdatedAppointments due to recursion.');
            return;
        }
        isRecursive2 = false; // Prevent recursion
        
        System.debug('### processUpdatedAppointments STARTED');
        System.debug('### Input appointmentIds: ' + appointmentIds);
        
        List<Tour_appointment__c> appointmentsToUpdate = [
            SELECT Id, Appointment_Date__c, Appointment_Time__c, Opp_Status__c, Opportunity__c, Tour__c
            FROM Tour_appointment__c
            WHERE Id IN :appointmentIds
        ];
        
        if (appointmentsToUpdate.isEmpty()) {
            System.debug('### No records to process, exiting early.');
            return;
        }
        
        System.debug('### Retrieved appointments: ' + appointmentsToUpdate);
        
        Set<Id> opportunityIds = new Set<Id>();
        Set<Date> appointmentDates = new Set<Date>();
        Set<Time> appointmentTimes = new Set<Time>();

        
        for (Tour_appointment__c appointment : appointmentsToUpdate) {
            opportunityIds.add(appointment.Opportunity__c);
            appointmentDates.add(appointment.Appointment_Date__c);
            appointmentTimes.add(appointment.Appointment_Time__c);
            
        }
        
        System.debug('### Opportunity IDs: ' + opportunityIds);
        System.debug('### Appointment Dates: ' + appointmentDates);
        System.debug('### Appointment Times: ' + appointmentTimes);

        Map<String, Id> existingAppointments = new Map<String, Id>();
        
        List<Tour_appointment__c> existingRecords = [
            SELECT Id, Opportunity__c, Appointment_Date__c, Appointment_Time__c, Tour__c
            FROM Tour_appointment__c
            WHERE Opportunity__c IN :opportunityIds
            AND Appointment_Date__c IN :appointmentDates
            AND Appointment_Time__c IN :appointmentTimes
        ];
        
        for (Tour_appointment__c existing : existingRecords) {
            String key = existing.Opportunity__c + '-' + existing.Appointment_Date__c + '-' + existing.Appointment_Time__c;
            existingAppointments.put(key, existing.Id);
        }
        
        System.debug('### Existing Appointments: ' + existingAppointments);
        
        Set<Date> tourDates = new Set<Date>();
        
        for (Tour_appointment__c appointment : appointmentsToUpdate) {
            if (appointment.Appointment_Date__c != null) {
                tourDates.add(appointment.Appointment_Date__c);
            }
        }
        
        System.debug('### Tour Dates: ' + tourDates);
        
        Map<String, Tour__c> tourMap = new Map<String, Tour__c>();
        
        if (!tourDates.isEmpty()) {
            List<Tour__c> matchingTours = [
                SELECT Id, Date__c, Tour_Time__c
                FROM Tour__c
                WHERE Date__c IN :tourDates
            ];
            system.debug('tour time'+matchingTours);
            for (Tour__c tour : matchingTours) {
                system.debug('tour time'+tour.Tour_Time__c);
                String key = tour.Date__c + '-' + tour.Tour_Time__c;
                tourMap.put(key, tour);
            }
        }
        
        System.debug('### Tour Map: ' + tourMap);
        
        List<Tour_appointment__c> newAppointments = new List<Tour_appointment__c>();
        List<Tour__c> toursToUpdate = new List<Tour__c>();
    // Set<String> uniqueKeys = new Set<String>();
        
        for (Tour_appointment__c oldAppointment : appointmentsToUpdate) {
            oldAppointment.Opp_Status__c = 'Cancelled';
            
            //String uniqueKey = oldAppointment.Opportunity__c + '-' + oldAppointment.Appointment_Date__c + '-' + oldAppointment.Appointment_Time__c;
            String tourKey = oldAppointment.Appointment_Date__c + '-' + oldAppointment.Appointment_Time__c;
            Id newTourId = (tourMap.containsKey(tourKey)) ? tourMap.get(tourKey).Id : null;
            
        //  if (!existingAppointments.containsKey(uniqueKey) && !uniqueKeys.contains(uniqueKey)) {
                Tour_appointment__c newAppointment = new Tour_appointment__c(
                    Name = 'Rebooked Tour ' + oldAppointment.Id,
                    Opportunity__c = oldAppointment.Opportunity__c,
                    Appointment_Date__c = oldAppointment.Appointment_Date__c,
                    Appointment_Time__c = oldAppointment.Appointment_Time__c,
                    Opp_Status__c = 'Open',
                    Tour__c = (oldAppointment.Tour__c != null) ? oldAppointment.Tour__c : newTourId
                );
                
                newAppointments.add(newAppointment);
            //    uniqueKeys.add(uniqueKey);
                System.debug('### Created new appointment: ' + newAppointment);
            }
    //  }
        Set<Id> cancelledTourIds = new Set<Id>();
        for (Tour_appointment__c appointment : appointmentsToUpdate) {
                if (appointment.Opp_Status__c == 'Cancelled' && appointment.Tour__c != null) {
                    cancelledTourIds.add(appointment.Tour__c);
                }
            }
        
            System.debug('### Cancelled Tour IDs: ' + cancelledTourIds);
        
            // **Fetch and Decrease Booked Tours**
        // List<Tour__c> toursToUpdate = new List<Tour__c>();
        
            if (!cancelledTourIds.isEmpty()) {
                List<Tour__c> cancelledTours = [
                    SELECT Id, Booked_Tours__c
                    FROM Tour__c
                    WHERE Id IN :cancelledTourIds
                ];
        
                for (Tour__c cancelledTour : cancelledTours) {
                    if (cancelledTour.Booked_Tours__c == null) {
                        cancelledTour.Booked_Tours__c = 0;
                    }
        
                    if (cancelledTour.Booked_Tours__c > 0) {
                        cancelledTour.Booked_Tours__c -= 1; // Decrement when a tour is cancelled
                        toursToUpdate.add(cancelledTour);
                    }
                }
            }
                        
                    
        if (!appointmentsToUpdate.isEmpty()) {
            System.debug('### Updating old appointments: ' + appointmentsToUpdate);
            update appointmentsToUpdate;
        }
        
        if (!newAppointments.isEmpty()) {
            System.debug('### Inserting new appointments: ' + newAppointments);
            insert newAppointments;
        }
        if (!toursToUpdate.isEmpty()) {
            System.debug('### Updating tour records: ' + toursToUpdate);
            update toursToUpdate;
        }

        
        isRecursive2 = true; // Reset flag after execution
    }*/
}