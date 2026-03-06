trigger TourAppointmentTrigger on Tour_appointment__c (before insert, before update, after insert, after update) {
    if (Trigger.isBefore && Trigger.isInsert) {
        System.debug('Insert Trigger TA');
        TourAppointmentHelper.updateTourDetails(Trigger.new);
     }
        
    if (Trigger.isAfter && Trigger.isInsert) {
        if (Recursive.flag) {
            try {
                Recursive.flag = false;
                TourAppointmentHelper.processAfterEvents(Trigger.new);
            } finally {
                Recursive.flag = true;
            }
        } else {
            System.debug('Skipping processAfterEvents due to recursion prevention.');
        }
    }
    
    if (Trigger.isAfter && Trigger.isupdate) {
        
        Set<Id> changedAppointmentIds = new Set<Id>();
		Set<Id> changedStatusAppointmentIds = new Set<Id>();
        
        
        for (Tour_appointment__c newRecord : Trigger.new) {
            Tour_appointment__c oldRecord = Trigger.oldMap.get(newRecord.Id);
            
            if (oldRecord.Appointment_Date__c != newRecord.Appointment_Date__c || 
                oldRecord.Appointment_Time__c != newRecord.Appointment_Time__c) {
                changedAppointmentIds.add(newRecord.Id);
             }
            if (oldRecord.Opp_Status__c == 'Booked' && oldRecord.Opp_Status__c != newRecord.Opp_Status__c &&  (newRecord.Opp_Status__c == 'Cancelled' || newRecord.Opp_Status__c == 'Rescheduled')) {
                changedStatusAppointmentIds.add(newRecord.Id);
                System.debug('Appointment Cancelled: ' + newRecord.Id);
       		 }
        }
        
        // Call @future method to avoid self-reference error
        if (!changedAppointmentIds.isEmpty()) {
           // TourAppointmentHelper.processUpdatedAppointments(changedAppointmentIds);
        }
        if (!changedStatusAppointmentIds.isEmpty()) {
            TourAppointmentHelper.processCancelledAppointments(changedStatusAppointmentIds);
        }
    
   }
    
}