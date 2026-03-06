/**
* @File Name : opportunityQualificationTabController.cls
* @Description :
* @Author :           Sifra 
* @Last Modified By :
* @Last Modified On : September 24, 2024
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | September 24, 2024 |   | Initial Version
**/


public with sharing class opportunityQualificationTabController {
      @AuraEnabled(cacheable=true)
    public static List<General_Data__c> getSupplierData() {
        List<General_Data__c> data = [SELECT Name, Age__c, Marital_Status__c, Income__c, Credit_Card__c, Employment_Status__c, Additional_Info__c FROM General_Data__c];
        System.debug('Supplier Data: ' + data);
        return data;
    }
  
     @AuraEnabled(cacheable=true)
    public static Boolean hasEditPermission() {
        return FeatureManagement.checkPermission('Edit_LWC_Qualification_Tab'); // Custom Permission API name
    }
    
 @AuraEnabled
public static void updateSupplierData(List<General_Data__c> data) {
    try {
       
        System.debug('Data received: ' + data);
        
        if(data != null && data.size() > 0) {
            update data; // Update the records
        }
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
}
    
  /*
    @AuraEnabled
    public static void updateSupplierData(List<General_Data__c> data) {
        try {
            // Check if the user has the custom permission
            if (!FeatureManagement.checkPermission('Edit_LWC_Qualification_Tab')) {
                throw new AuraHandledException('You do not have permission to update Qualification data.');
            }
            
            // Debug to ensure correct data is received
            System.debug('Data received: ' + data);

            if (data != null && data.size() > 0) {
                update data; // Update the records
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }*/  
   

    
}