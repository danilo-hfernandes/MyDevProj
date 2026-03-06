/**
 * Class Name      : LuxuryExcursionsController
 * Description     : Handles Luxury Excursion records
 */

public with sharing class LuxuryExcursionsController {

    @AuraEnabled(cacheable=true)
    public static List<Luxury_Excursion__c> getExcursions(Id parentId) {
        return [
            SELECT Id, Name, Excursion_Yacht_Name__c, Location__c, Date_Time__c, 
                   HSI_Cost__c, Confirmation__c,
                   Opportunity_Product__r.Product2.Name 
            FROM Luxury_Excursion__c
            WHERE Opportunity__c = :parentId
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled
    public static Id createExcursion(Id parentId, Id sourceExcursionId) {
        Luxury_Excursion__c le = new Luxury_Excursion__c();
        
        if (sourceExcursionId != null) {
            Luxury_Excursion__c source = [
                SELECT Opportunity__c, Opportunity_Product__c 
                FROM Luxury_Excursion__c 
                WHERE Id = :sourceExcursionId 
                LIMIT 1
            ];
            le.Opportunity__c = source.Opportunity__c;
            le.Opportunity_Product__c = source.Opportunity_Product__c;
        } else {
            le.Opportunity__c = parentId;
        }

        insert le;
        return le.Id;
    }
}

/*
public with sharing class LuxuryExcursionsController {

    @AuraEnabled(cacheable=true)
    public static List<Luxury_Excursion__c> getExcursions(Id parentId) {
        return [
            SELECT Id, Name, Excursion_Yacht_Name__c, Location__c, Date_Time__c, 
                   Adults__c, Children__c, Hours__c, HSI_Cost__c, Confirmation__c
            FROM Luxury_Excursion__c
            WHERE Opportunity_Product__c = :parentId 
               OR Opportunity__c = :parentId
            ORDER BY CreatedDate DESC
        ];
    }

    @AuraEnabled
    public static Id createExcursion(Id parentId, Id sourceExcursionId) {
        Luxury_Excursion__c le = new Luxury_Excursion__c();
        
        // Scenario 1: User clicked ADD on a specific row (Cloning the link)
        if (sourceExcursionId != null) {
            Luxury_Excursion__c source = [
                SELECT Opportunity__c, Opportunity_Product__c 
                FROM Luxury_Excursion__c 
                WHERE Id = :sourceExcursionId 
                LIMIT 1
            ];
            le.Opportunity__c = source.Opportunity__c;
            le.Opportunity_Product__c = source.Opportunity_Product__c;
        } 
        // Scenario 2: User clicked ADD from the header or a blank state
        else {
            le.Opportunity__c = parentId;
            
            // Note: Opportunity Product remains blank for the user to select in the Edit screen
        }

        insert le;
        return le.Id;
    }
}
*/