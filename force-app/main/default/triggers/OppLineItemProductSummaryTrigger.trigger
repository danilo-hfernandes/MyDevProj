trigger OppLineItemProductSummaryTrigger on OpportunityLineItem (after insert, after update) {
    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('OppLineItemProductSummaryTrigger');
    if(cs != null && cs.isEnable__c){ 
        // HSIMU2-1061
        Map<Id, Set<String>> oppIdToProductNamesMap = new Map<Id, Set<String>>();
        Map<Id, Set<String>> oppIdToProductNumberIdMap = new Map<Id, Set<String>>();
        
        for (OpportunityLineItem oli : Trigger.new) {
            if (oli.OpportunityId != null) {
                if (!oppIdToProductNamesMap.containsKey(oli.OpportunityId)) {
                    oppIdToProductNamesMap.put(oli.OpportunityId, new Set<String>());
                    oppIdToProductNumberIdMap.put(oli.OpportunityId, new Set<String>());
                }
                oppIdToProductNamesMap.get(oli.OpportunityId).add(oli.Product2.Name);
                oppIdToProductNumberIdMap.get(oli.OpportunityId).add(oli.Product2.Product_Number_Id__c);
            }
        }
        
        List<OpportunityLineItem> allOLIs = [SELECT OpportunityId, Product2.Name, Product2.Product_Number_Id__c FROM OpportunityLineItem WHERE OpportunityId IN :oppIdToProductNamesMap.keySet()];
        
        
        oppIdToProductNamesMap.clear();
        oppIdToProductNumberIdMap.clear();
        for (OpportunityLineItem oli : allOLIs) {
            if (oli.OpportunityId != null) {
                if (!oppIdToProductNamesMap.containsKey(oli.OpportunityId)) {
                    oppIdToProductNamesMap.put(oli.OpportunityId, new Set<String>());
                    oppIdToProductNumberIdMap.put(oli.OpportunityId, new Set<String>());
                }
                oppIdToProductNamesMap.get(oli.OpportunityId).add(oli.Product2.Name);
                oppIdToProductNumberIdMap.get(oli.OpportunityId).add(oli.Product2.Product_Number_Id__c);
            }
        }
        
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Id oppId : oppIdToProductNamesMap.keySet()) {
            Opportunity opp = new Opportunity(Id = oppId);
            opp.Product_Summary__c = String.join(new List<String>(oppIdToProductNamesMap.get(oppId)), ', ');
            opp.Product_Summary_Text__c = String.join(new List<String>(oppIdToProductNumberIdMap.get(oppId)), ', ');
            //Product_Number_Id__c
            opportunitiesToUpdate.add(opp);
        }
        
        if (!opportunitiesToUpdate.isEmpty()) {
            update opportunitiesToUpdate;
        }
    }
}