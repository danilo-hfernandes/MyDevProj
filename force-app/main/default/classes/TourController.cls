public with sharing class TourController {
    public Opportunity opp { get; set; }
    public Tour__c tour { get; set; }

    public TourController(ApexPages.StandardController stdCtrl) {
        // Get the Opportunity record
        this.opp = (Opportunity) stdCtrl.getRecord();
        
        // Fetch the related Tour record (assuming there is a lookup relationship)
        List<Tour__c> tourList = [SELECT Id, Transportation__c, Location__c, Date__c, Tour_Time__c, Tour_Status__c,
                                           Transportation_Check_in__c, Transportation_Pickup__c, Pickup_Date_Time__c, No_Show__c 
                                    FROM Tour__c 
                                    WHERE Opportunity__c = :opp.Id
                                    LIMIT 1];
        
        if (!tourList.isEmpty()) {
            tour = tourList[0];  // Assign the first record if found
        } else {
            tour = new Tour__c(Opportunity__c = opp.Id);  // Initialize a new Tour record
        }
    }

    public PageReference saveTour() {
        if (tour.Id == null) {
            insert tour;
        } else {
            update tour;
        }
        return null;
    }
}