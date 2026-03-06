trigger RedemptionTrigger on Redemption__c (before Insert, after insert, after update) {
    
    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('RedemptionTrigger');
    if(cs != null && cs.isEnable__c){
        // Before trigger
        if(trigger.isBefore && trigger.isInsert ){
            Set<Id> parentIdSet = new Set<Id>();
            for (Redemption__c redObj : Trigger.new) {
                if(redObj.Parent_Redemption__c != null){ 
                system.debug('redObj.Parent_Redemption__c---1>'+ redObj.Parent_Redemption__c);
                parentIdSet.add(redObj.Parent_Redemption__c);
                }
            }
            system.debug('parentIdSet---1>'+ parentIdSet);
            if(parentIdSet != null && parentIdSet.size() > 0){
                Map<Id, Redemption__c> parentNameList = new Map<Id, Redemption__c>([SELECT Id, Name FROM Redemption__c WHERE Id IN :parentIdSet]);
                system.debug('parentNameList---1>'+ parentNameList);
                
                Map<String, List<Redemption__c>> parentChild = new Map<String, List<Redemption__c>>();
                for (Redemption__c redObj : Trigger.new) {
                    List<Redemption__c> redchildList = parentChild.get(redObj.Parent_Redemption__c);
                    if (redchildList == null) {
                        redchildList = new List<Redemption__c>();
                    }
                    redchildList.add(redObj);
                    parentChild.put(redObj.Parent_Redemption__c, redchildList);
                }
                system.debug('parentChild---1>'+ parentChild);
                
                List<AggregateResult> ars = [SELECT Parent_Redemption__c, count(Id) FROM Redemption__c WHERE Parent_Redemption__c IN :parentIdSet group by Parent_Redemption__c];
                Map<String, Integer> parentChildCount = new Map<String, Integer>();
                for (AggregateResult ar : ars) {
                    parentChildCount.put(String.valueOf(ar.get('Parent_Redemption__c')), Integer.valueOf(ar.get('expr0')));
                }
                
                for (Redemption__c childObj : Trigger.new) {
                    if (parentChildCount.get(childObj.Parent_Redemption__c) == null) {
                        parentChildCount.put(childObj.Parent_Redemption__c, 0);
                    }
                }
                
                for (List<Redemption__c> childObjList : parentChild.values()) {
                    for (Integer s = 1; s < childObjList.size() + 1; s++) {
                        Redemption__c childObj = childObjList.get(s-1);
                        integer index = Trigger.new.indexOf(childObj);
                        system.debug(parentNameList+'parentNameList');
                        system.debug(parentChildCount+'parentChildCount');
                        Trigger.new.get(index).Redemption_Name__c = parentNameList.get(childObj.Parent_Redemption__c).Name + '.' + (parentChildCount.get(childObj.Parent_Redemption__c) + s);
                    }
                }
            }
        }
        // After trigger
        if(trigger.isAfter){
            List<Redemption__c> lstRedemption = new List<Redemption__c>();
            if(Trigger.IsAfter && Trigger.IsInsert){
                for(Redemption__c objredem : Trigger.new){
                    if(objredem.Property__c != null){
                        lstRedemption.add(objredem);
                    }
                }
            }
            else if(Trigger.IsAfter && Trigger.IsUpdate){
                for(Redemption__c objredem : Trigger.new){
                    if(objredem.Property__c != null && (objredem.Property__c != Trigger.oldMap.get(objredem.Id).Property__c || objredem.Usage_Fee__c != Trigger.oldMap.get(objredem.Id).Usage_Fee__c)){
                        lstRedemption.add(objredem);
                    }
                }
                RedemptionTriggerHandler.createReservationTrackingRecord(trigger.oldMap, trigger.newMap);
            }
            if(lstRedemption != null && lstRedemption.size() > 0){
                RedemptionTriggerHandler.updateRelatedTimeshare(lstRedemption);
            }
        }
    }
}