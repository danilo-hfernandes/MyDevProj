trigger TimeshareTrigger on Timeshare__c (before insert,after insert, before update,before delete) {
    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('TimeshareTrigger');
    if(cs != null && cs.isEnable__c){
        if(trigger.isbefore && trigger.isDelete){
            Set<Id> timeshIdSet = new Set<Id>();
            for(Timeshare__c timesh : trigger.old) {
                timeshIdSet.add(timesh.Id);
            }
            
            List<OpportunityLineItem> OppLineItemList = [Select id FROM OpportunityLineItem WHERE Timeshare__c IN :timeshIdSet];
            
            for(Timeshare__c tim : trigger.old) {
                System.debug('THIS IS THE SECOND FOR LOOP!!!!!!!!!!!!!!!!');
                //&& u.ProfileId != '00e6g000001jHp5'
                if(!OppLineItemList.isEmpty() ) {
                    tim.addError('You can not delete a timeshare that already has a associated with Opportunity product');
                    System.debug('You can not delete a timeshare that already has a associated with Opportunity product');
                }
            }
        }
        iF(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){ 
            
            // HSIMU-53 - Assign resort based on SMTN Resort Id - 04/17/2023
            Set<String> smtnResortIdSet = new Set<String>();
            Map<String,Timeshare__c> timeshareResortMap = new Map<String,Timeshare__c>();
            for(Timeshare__c timeshr : trigger.new){
                 if(trigger.isInsert){
                    if(timeshr.SMTN_Resort_Id__c != null){
                        smtnResortIdSet.add(timeshr.SMTN_Resort_Id__c);
                        timeshareResortMap.put(timeshr.SMTN_Resort_Id__c,timeshr);
                    }
                 }
                 if(trigger.isUpdate){
                      if( (timeshr.SMTN_Resort_Id__c != null && timeshr.Resort__c == null ) || (timeshr.SMTN_Resort_Id__c != null && timeshr.SMTN_Resort_Id__c != Trigger.oldMap.get(timeshr.id).SMTN_Resort_Id__c)){
                        smtnResortIdSet.add(timeshr.SMTN_Resort_Id__c);
                        timeshareResortMap.put(timeshr.SMTN_Resort_Id__c,timeshr);
                    } 
                }
            }
            Map<String,Resort__c> resortIDSMTNId = new Map<String,Resort__c>();
            if(smtnResortIdSet != null && smtnResortIdSet.size() > 0){
                List<Resort__c> resortList = [Select id,Name,SMTN_Resort_Id__c from Resort__c where SMTN_Resort_Id__c In :smtnResortIdSet];
                if(resortList != null && resortList.size() > 0){
                    for(Resort__c rp : resortList){
                        resortIDSMTNId.put(rp.SMTN_Resort_Id__c,rp);
                    }
                }
            }
            
            if(resortIDSMTNId != null && resortIDSMTNId.size() > 0)
            for(Timeshare__c tm : trigger.new){
                if(resortIDSMTNId.containskey(tm.SMTN_Resort_Id__c)){
                    Resort__c rp = resortIDSMTNId.get(tm.SMTN_Resort_Id__c);
                    tm.Resort__c = rp.Id;
                    tm.Name = rp.Name;
                }
            }
            // HSIMU-53 - Assign resort based on SMTN Resort Id - 04/17/2023 - End
            
            // Resort name mapping for timeshare if SMTN Resort Id was not there // Existing logic
            
            List<Resort__c> rList = new List<Resort__c>();
            set<Id> resortId = new set<Id>();
            for(Timeshare__c t : Trigger.New) {
                if(trigger.isInsert){
                    if(t.resort__c != null && t.SMTN_Resort_Id__c == null) {
                        system.debug('---ab---inside second loop-'+t.SMTN_Resort_Id__c);
                        resortId.add(t.Resort__c);
                    }
                }
                if(trigger.isUpdate){
                    if(t.resort__c != null && t.Resort__c != Trigger.oldMap.get(t.id).Resort__c && t.SMTN_Resort_Id__c == null) {
                        resortId.add(t.Resort__c);
                    }
                }
            }  
            if(resortId.size() > 0){
                Map<Id,String> resortIdNameMap = new Map<Id,String>();
                rList = [SELECT id, name from Resort__c where id in :resortId];
                for(Resort__c rs : rList){
                    resortIdNameMap.put(rs.Id,rs.Name);
                }
                if(resortIdNameMap != null && resortIdNameMap.size() > 0){
                    for(Timeshare__c ti : Trigger.New) {
                        if(resortIdNameMap.containskey(ti.Resort__c)) {
                            ti.Name = resortIdNameMap.get(ti.Resort__c);
                        }
                    }
                }
            }
            // Resort name mapping for timeshare if SMTN Resort Id was not there // Existing logic
        }
        if(trigger.isAfter && trigger.isInsert){
            TimeshareTriggerHandler.CreateOpportunityBasedOnDuplicates(Trigger.new);
            TimeshareTriggerHandler.CreateOppoForHCAffiliateReturn(Trigger.new);
        } 
    }
}