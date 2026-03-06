trigger PaymentTrigger on Payment__c (before insert, after insert, before delete) {
    // This before event have business logic to update the salesforce product Id based on product Id auto field from OpportunityLine Item object
    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('PaymentTrigger');
    system.debug('---cs----'+cs);
    if(cs != null && cs.isEnable__c){
        if(trigger.isAfter && trigger.isInsert){
            if(checkRecursive.paymentTrigger){
                checkRecursive.paymentTrigger = false;
                Set<String> productIdset = new Set<String>();
                Set<String> oppIdSet = new Set<String>();
                Set<Id> paymentId = new Set<Id>();
                Set<Id> paymentIdSet = new Set<Id>();
                for(Payment__c py : trigger.new){
                    paymentIdSet.add(py.Id);
                    oppIdSet.add(py.Opportunity__c);
                    if(py.Product_Id__c != null && py.Product_Salesforce_Id__c == null){
                        system.debug('-py.Product_Id__c-'+py.Product_Id__c);
                        productIdset.add(py.Product_Id__c);
                        paymentId.add(py.Id);
                    }
                }
                if(oppIdSet != null && paymentId != null){
                    PaymentTriggerHandler.updateProductId(oppIdSet,paymentId);
                }
                Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('hawaiiCollectionAPI');
                if(cs != null && cs.isEnable__c){
                    PaymentTriggerHandler.hawaiiCollectionApi(paymentIdSet);
                } 
            }
        }
        
        if(trigger.isBefore && trigger.isDelete){
            List<Deleted_Record__c> deletedRecList = new List<Deleted_Record__c>();
            
            for(Payment__c rec: trigger.old){
                Deleted_Record__c deletedRec = new Deleted_Record__c();
                deletedRec.Id__c = rec.Id;
                deletedRec.Object_Name__c = 'Payment';
                deletedRec.Created_Date__c = date.today();
                deletedRec.RecId__c = rec.RecId__c;
                deletedRecList.add(deletedRec);
            }
            
            if(!deletedRecList.isEmpty()){
                insert deletedRecList;
            }
        }
    }
}