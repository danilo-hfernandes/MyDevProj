public class VoucherTierAdjustmentCompController {
    
    @AuraEnabled
    public static List<WrapperClass> getOpportunitiesData() {
        List<WrapperClass> results = new List<WrapperClass>();
        
        // List of products to query
        List<String> products = new List<String>{
            'LuxGive-The Grand Mayan Master Room 5/4',
            'LuxGive-The Grand Mayan Master Room',
            'LuxGive-Mayan Palace Master Room'
        };//'LuxGive-Mayan Palace Master Room 5/4',

        // Loop through the products and get their sold counts and tier adjustments
        for (String productName : products) {
            Integer productCount = (Integer) [SELECT COUNT(Id) cnt FROM Opportunity 
                                              WHERE IsClosed = true and IsWon = true and Id IN (SELECT Opportunity__c FROM Payment__c 
                                                           WHERE Product_Name__c = :productName 
                                                           AND Paid_On__c = LAST_MONTH)
                                              /*AND Id NOT IN (SELECT OpportunityId FROM OpportunityLineItem 
                                                             WHERE Product2.Name = 'LuxGive-Tier Adjustment')*/][0].get('cnt');
            results.add(new WrapperClass(productName, productCount, calculateTierAdjustment(productName, productCount)));
        }     
        
        return results;
    }
    
    @AuraEnabled
    public static List<OpportunityWrapper> getOpportunitiesList() {
        List<OpportunityWrapper> opps = new List<OpportunityWrapper>();
        List<WrapperClass> totalResults = getOpportunitiesData();
        
        
        List<Opportunity> opportunities = [SELECT Id, (SELECT Product2.Name FROM OpportunityLineItems), 
                                           (SELECT Product_Name__c, Paid_On__c FROM Payments__r)
                                           FROM Opportunity
                                           WHERE IsClosed = true and IsWon = true and Id IN (SELECT Opportunity__c FROM Payment__c 
                                                        WHERE Product_Name__c IN ('LuxGive-The Grand Mayan Master Room 5/4',
                                                                                   'LuxGive-The Grand Mayan Master Room',
                                                                                   'LuxGive-Mayan Palace Master Room')
                                                        AND Paid_On__c = LAST_MONTH)
                                           AND Id NOT IN (SELECT OpportunityId FROM OpportunityLineItem 
                                                          WHERE Product2.Name = 'LuxGive-Tier Adjustment')];// 'LuxGive-Mayan Palace Master Room 5/4',
        
        for (Opportunity opp : opportunities) {
            OpportunityWrapper oppWrapper = new OpportunityWrapper();
            oppWrapper.oppId = opp.Id;
            oppWrapper.productNames = new List<String>();
            oppWrapper.payments = new List<PaymentWrapper>();
            
            // Calculate the number of products for this opportunity
            oppWrapper.productCount = opp.OpportunityLineItems.size();
            
            // List of products
            List<String> products = new List<String>{
                'LuxGive-The Grand Mayan Master Room 5/4',
                    'LuxGive-The Grand Mayan Master Room',
                    'LuxGive-Mayan Palace Master Room'
                    };//'LuxGive-Mayan Palace Master Room 5/4',
            
            //Calculate the tier adjustment based on the product count and the valid product name
            if (!opp.OpportunityLineItems.isEmpty()) {
                Boolean validProductFound = false;
                for(OpportunityLineItem item : opp.OpportunityLineItems)
                {
                    if(!validProductFound && products.contains(item.Product2.Name)){
                        String firstProductName = item.Product2.Name;
                        Boolean validProductFound2 = false;
                        Integer tierProductCount = 0;
                        for(WrapperClass w : totalResults)
                        {
                            if(w.productName == item.Product2.Name && !validProductFound2)
                            {
                                tierProductCount = w.soldCount;
                                validProductFound2 = true;
                            }                               
                        }
                        oppWrapper.tierAdjustment = calculateTierAdjustment(firstProductName, tierProductCount);
                        validProductFound = true;
                    }
                }
            }
            
            for (OpportunityLineItem oli : opp.OpportunityLineItems) {
                oppWrapper.productNames.add(oli.Product2.Name);
            }
            
            for (Payment__c payment : opp.Payments__r) {
                PaymentWrapper paymentWrapper = new PaymentWrapper();
                paymentWrapper.productName = payment.Product_Name__c;
                paymentWrapper.paidOn = payment.Paid_On__c;
                oppWrapper.payments.add(paymentWrapper);
            }
            
            
            opps.add(oppWrapper);
        }
        
        return opps;
    }
    
   @AuraEnabled
    public static void addTierAdjustmentToAllOpps(Map<Id, Decimal> oppMap) {

        
        System.debug('Triggering VoucherTierAdjustmentQueueable with Opportunity Map: ' + oppMap);

        if (oppMap == null || oppMap.isEmpty()) {
            System.debug('oppMap is null or empty');
            return;
        }
    
        // Enqueue the queueable job
        System.enqueueJob(new VoucherTierAdjustmentQueueable(oppMap));
        
        
    }
    
    // Method to calculate tier adjustment based on product name and count
    private static Decimal calculateTierAdjustment(String productName, Integer productCount) {
        if (productName.contains('LuxGive-The Grand Mayan Master Room 5/4')) {
            if (productCount <= 150) return 90;
            else if (productCount <= 250) return 70;
            else if (productCount <= 350) return 40;
        } /*else if (productName.contains('LuxGive-Mayan Palace Master Room 5/4')) {
            if (productCount <= 150) return 90;
            else if (productCount <= 250) return 70;
            else if (productCount <= 350) return 40;
        }*/ else if (productName.contains('LuxGive-The Grand Mayan Master Room')) {
            if (productCount <= 150) return 287;
            else if (productCount <= 250) return 252;
            else if (productCount <= 350) return 140;
        } else if (productName.contains('LuxGive-Mayan Palace Master Room')) {
            if (productCount <= 150) return 217;
            else if (productCount <= 250) return 112;
            else if (productCount <= 350) return 70;
        }
        return 0; // Default return value if none matched
    }
    
    public class WrapperClass {
        @AuraEnabled public String productName;
        @AuraEnabled public Integer soldCount;
        @AuraEnabled public Decimal tierAdjustment;
        
        public WrapperClass(String productName, Integer soldCount, Decimal tierAdjustment) {
            this.productName = productName;
            this.soldCount = soldCount;
            this.tierAdjustment = tierAdjustment;
        }
    }
     
    // Wrapper class to handle Opportunity data
    public class OpportunityWrapper {
        @AuraEnabled public String oppId;
        @AuraEnabled public List<String> productNames;
        @AuraEnabled public List<PaymentWrapper> payments;
        @AuraEnabled public Decimal tierAdjustment;
        @AuraEnabled public Integer productCount; // Add productCount to the wrapper to store the count of products
    }
    
    // Wrapper class for Payment information
    public class PaymentWrapper {
        @AuraEnabled public String productName;
        @AuraEnabled public Date paidOn;
    }
}