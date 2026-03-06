public with sharing class TourServiceController {
    
    @InvocableMethod(label='Create Tour Record' description='Creates a Tour__c record from Flow')
    public static List<Id> createTourRecord(List<TourRequest> requests) {
        List<Id> createdTourIds = new List<Id>();
        List<Tour__c> toursToInsert = new List<Tour__c>();

        try {
            for (TourRequest req : requests) {
                Time tourTime = null;
                
                // Convert String Time (HH:mm) to Time Object
                if (String.isNotBlank(req.tourTime)) {
                    List<String> timeParts = req.tourTime.split(':'); // Splitting "HH:mm"
                    if (timeParts.size() == 2) {
                        Integer hours = Integer.valueOf(timeParts[0]);
                        Integer minutes = Integer.valueOf(timeParts[1]);
                        tourTime = Time.newInstance(hours, minutes, 0, 0); // Create Time object
                    }
                }

                Tour__c newTour = new Tour__c(
                    Date__c = req.tourDate,
                    Tour_Time__c = tourTime
                );
                toursToInsert.add(newTour);
            }

            if (!toursToInsert.isEmpty()) {
                insert toursToInsert;
                for (Tour__c tour : toursToInsert) {
                    createdTourIds.add(tour.Id);
                }
            }
        } catch (Exception e) {
            System.debug('Error Creating Tour: ' + e.getMessage());
            throw new AuraHandledException('Failed to create Tour__c: ' + e.getMessage());
        }

        return createdTourIds;
    }

    // Wrapper Class for Flow Inputs
    public class TourRequest {
        @InvocableVariable(label='Tour Date' description='Date of the Tour' required=true)
        public Date tourDate;

        @InvocableVariable(label='Tour Time (HH:mm format)' description='Time of the Tour in HH:mm format' required=true)
        public String tourTime; // Flow passes this as a String
    }
}