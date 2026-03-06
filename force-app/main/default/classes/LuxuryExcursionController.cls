public with sharing class LuxuryExcursionController {

    @AuraEnabled
    public static List<Luxury_Excursion__c> getExcursions(String recordId){
        return [
            SELECT Id,
                   Name,
                   Adults__c,
                   Children__c,
                   Hours__c,
                   Date_Time__c,
                   Location__c,
                   HSI_Cost__c,
                   Confirmation__c,
                   Opportunity_Product__c
            FROM Luxury_Excursion__c
            WHERE Opportunity__c = :recordId
            ORDER BY Date_Time__c DESC
        ];
    }

    @AuraEnabled
    public static void cloneExcursion(String recordId){

        Luxury_Excursion__c oldRec =
            [SELECT Id,
                    Adults__c,
                    Children__c,
                    Hours__c,
                    Date_Time__c,
                    Location__c,
                    HSI_Cost__c,
                    Confirmation__c,
                    Opportunity__c,
                    Opportunity_Product__c
             FROM Luxury_Excursion__c
             WHERE Id = :recordId
             LIMIT 1];

        Luxury_Excursion__c newRec = oldRec.clone(false, true, false, false);
        //newRec.Parent_Excursion__c = oldRec.Id; // Optional if you want tracking
        insert newRec;
    }
}