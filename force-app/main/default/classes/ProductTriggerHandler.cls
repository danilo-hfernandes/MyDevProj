public class ProductTriggerHandler {
    public static void updateFlagOnOpportunity(List<OpportunityLineItem> oppLineItemList, Boolean isDelete){
        Map<Id,Id> productIdWithOpportunityMap = new Map<Id,Id>();
        Map<Id,OpportunityLineItem> oppIdWithOppLineItem = new Map<Id,OpportunityLineItem>();
        List<Product2> productList = new List<Product2>();
        //Map<Id,OpportunityLineItem> productMap = new Map<Id,OpportunityLineItem>();
        Set<Id> oppIdSetFor3Nights = new Set<Id>();
        Set<Id> oppIdSetFor7Nights = new Set<Id>(); 
        Set<Id> oppIdForVidantaRebate = new Set<Id>();
        List<Opportunity> oppList3Nights = new List<Opportunity>();
        List<Opportunity> oppList7Nights = new List<Opportunity>();
        List<Opportunity> oppListForVidantaRebate = new List<Opportunity>();
        List<Opportunity> oppListToUpdate = new List<Opportunity>();
        //List<Payment__c> paymentList = new List<Payment__c>();
        set<Id> setOpportunityIds = new set<Id>();
        for(OpportunityLineItem lineItem : oppLineItemList){
            if(lineItem.Product2Id != null && lineItem.OpportunityId != null){
                productIdWithOpportunityMap.put(lineItem.Product2Id, lineItem.OpportunityId);
                oppIdWithOppLineItem.put(lineItem.OpportunityId, lineItem);
            }
        }
        
        system.debug('productIdWithOpportunityMap--'+productIdWithOpportunityMap);
        if(productIdWithOpportunityMap != null){
            productList = [Select Id,Name from Product2 where Id IN: productIdWithOpportunityMap.keySet()];
        }
         
        system.debug('productList--'+productList);
        for(Product2 prod : productList){
            if((prod.Name == 'Voucher-Flex Stays 4/3' || prod.Name == 'Flex Stays Vacation VIP Membership Upgrade 4/3') && productIdWithOpportunityMap.containsKey(prod.Id)){
                oppIdSetFor3Nights.add(productIdWithOpportunityMap.get(prod.Id));
            }else if((prod.Name == 'Voucher-Flex Stays' || prod.Name == 'FlexStay-Add On' || prod.Name == 'Voucher-Flex Stays 8/7' || prod.Name == 'Flex Stays Vacation VIP Membership Upgrade 8/7') && productIdWithOpportunityMap.containsKey(prod.Id)){
                oppIdSetFor7Nights.add(productIdWithOpportunityMap.get(prod.Id));
                if(prod.Name == 'FlexStay-Add On'){
                    setOpportunityIds.add(productIdWithOpportunityMap.get(prod.Id));
                }
            }
            if(prod.Name == 'Vidanta Rebate $200' && productIdWithOpportunityMap.containsKey(prod.Id)){
                oppIdForVidantaRebate.add(productIdWithOpportunityMap.get(prod.Id));
            } 
        }

        if(!oppIdSetFor3Nights.isEmpty()){
            oppList3Nights = [Select Id, Flex_Stays_Nights__c 
                              from Opportunity where Id IN: oppIdSetFor3Nights and RecordType.DeveloperName = 'Flex_Stays_Product_Voucher'];
        }
        
        if(!oppIdSetFor7Nights.isEmpty()){
            oppList7Nights = [Select Id, Flex_Stays_Nights__c,Account.Preferred_Language__c 
                              from Opportunity where Id IN: oppIdSetFor7Nights and RecordType.DeveloperName = 'Flex_Stays_Product_Voucher'];
        }
        
        if(!oppIdForVidantaRebate.isEmpty()){
            oppListForVidantaRebate = [Select Id, Flex_Stays_Nights__c, AccountId, Account.Name  
                                       from Opportunity where Id IN: oppIdForVidantaRebate];
        }
        
        for(Opportunity opp: oppList3Nights){
            opp.Flex_Stays_Nights__c = 3;
            oppListToUpdate.add(opp);
        }
        
        for(Opportunity opp: oppList7Nights){
            if(!setOpportunityIds.contains(opp.Id) || (setOpportunityIds.contains(opp.Id) && opp.Account.Preferred_Language__c == 'ENG')){
                opp.Flex_Stays_Nights__c = 7;
            }            
            oppListToUpdate.add(opp);
        }
        
        for(Opportunity opp: oppListForVidantaRebate){
            if(isDelete){
                opp.Vidanta_Rebate_Product_Added__c = false;
            }else{
                //OpportunityLineItem oppLineItem = oppIdWithOppLineItem.get(opp.Id);
                
                opp.Vidanta_Rebate_Product_Added__c = true;
                
                /*Id recordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Profit_Agility_Voucher').getRecordTypeId();
                Payment__c paymentRec = new Payment__c();
                paymentRec.Name = opp.Account.Name;
                paymentRec.Paid_On__c = system.today();
                paymentRec.Payment_Type__c = 'Payment';
                paymentRec.Opportunity__c = opp.Id;
                paymentRec.Payment_Amount__c = 0;
                paymentRec.RecordTypeId = recordTypeId;
                paymentRec.Transaction_Type__c = 'Voucher';
                paymentRec.Product_Id__c = oppLineItem.Product_Id__c;
                paymentRec.Rebate_Payment__c = true;
                paymentList.add(paymentRec);*/
            }
             
            oppListToUpdate.add(opp);
        }
        
        /*if(!paymentList.isEmpty()){
            insert paymentList;
        }*/
        
        if(!oppListToUpdate.isEmpty()){
            update oppListToUpdate;
        }
    }
    
    /*public static void createZeroPaymentInChildVoucherOpp(List<OpportunityLineItem> oppLineItemList){
        Map<Id,Id> productIdWithOpportunityMap = new Map<Id,Id>();        
        for(OpportunityLineItem lineItem : oppLineItemList){
            if(lineItem.Product2Id != null && lineItem.OpportunityId != null){
                productIdWithOpportunityMap.put(lineItem.Id, lineItem.Product2Id);                
            }
        }
        system.debug('productIdWithOpportunityMap--'+productIdWithOpportunityMap);
        if(productIdWithOpportunityMap != null && productIdWithOpportunityMap.size()>0){
            Map<Id,Product2> productList = new Map<Id,Product2>([Select Id from Product2 where Id IN: productIdWithOpportunityMap.values() AND Name = 'Membership Upgrade Vida Week']);
            if(productList != null && productList.size()>0){
                List<Payment__c> paymentsToInsert = new List<Payment__c>();
                for(Id oliId : productIdWithOpportunityMap.keySet())
                {
                    if(productList.get(productIdWithOpportunityMap.get(oliId)) != null)
                    {
                        
                    }
                }            
            }
        }        
    }*/
}