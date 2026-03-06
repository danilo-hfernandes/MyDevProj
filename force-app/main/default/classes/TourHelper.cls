public class TourHelper {
    public static void updateTourDetails(List<Tour__c> tourRecords) {
        Set<Id> leadIds = new Set<Id>();

        // Collect Lead IDs from incoming Tour records
        for (Tour__c tour : tourRecords) {
            if (tour.Lead_ID__c != null) {
                leadIds.add(tour.Lead_ID__c);
            }
        }

        if (!leadIds.isEmpty()) {
            // Query Lead records to fetch the Time field
            Map<Id, Lead> leadMap = new Map<Id, Lead>(
                [SELECT Id, Tour_Time__c FROM Lead WHERE Id IN :leadIds]
            );

            // Assign the Time from Lead to Tour
            for (Tour__c tour : tourRecords) {
                if (tour.Lead_ID__c != null && leadMap.containsKey(tour.Lead_ID__c)) {
                    tour.Tour_Time__c = leadMap.get(tour.Lead_ID__c).Tour_Time__c;
                }
            }
        }
    }
}