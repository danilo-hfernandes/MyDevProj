trigger CouponToCreateAccoAndOpp on Coupon__c (after update) {
    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('CouponToCreateAccoAndOpp');
    if(cs != null && cs.isEnable__c){
        if(trigger.isAfter && trigger.isUpdate){
            Set<Id> couponIdSet = new Set<Id>();
            for(Coupon__c cup : trigger.new){
                if(cup.Name__c != null && cup.Email__c != null && cup.Phone_Number__c != null && cup.Is_Redeem__c == true && cup.Is_Redeem__c != trigger.oldmap.get(cup.id).Is_Redeem__c){
                    // create Account,Opp,Payment
                    couponIdSet.add(cup.Id);
                }
            }
            if(couponIdSet != null && couponIdSet.size() > 0){
               CouponTriggerHandler.createAccountOppAndRelatedRecords(couponIdSet);
            }
        }
    }
}