trigger InvoiceTrigger on Invoice__c (after insert,after update, before delete) {
    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('InvoiceTrigger');
    system.debug('--OpportunityTrigger_New--'+cs);
    if(cs != null && cs.isEnable__c){
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
            Set<Id> invoiceIDSet = new Set<Id>();
            for(Invoice__c inc: trigger.new){
                invoiceIDSet.add(inc.Id);
            }
            if(invoiceIDSet != null){
                if(InvoiceTriggerHandler.executeMethod()){
                    InvoiceTriggerHandler.updateInvoiceOpportunity(invoiceIDSet);
                }
                
            }
            
        }    
        
        
        
        
        if(trigger.isBefore && trigger.isDelete){
            Map<Id,Decimal> oppIdMap = new Map<Id,Decimal>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<Opportunity> oppListToUpdate = new List<Opportunity>();
            
            for(Invoice__c rec: trigger.old){
                if(rec.Opportunity__c != null){
                    if(!oppIdMap.containsKey(rec.Opportunity__c)){
                        if(rec.Invoice_Amount__c != null){
                            oppIdMap.put(rec.Opportunity__c,rec.Invoice_Amount__c);
                        }
                    }else{
                        if(rec.Invoice_Amount__c != null){
                            Decimal tempAmount = oppIdMap.get(rec.Opportunity__c);
                            Decimal newAmount = tempAmount + rec.Invoice_Amount__c;
                            oppIdMap.put(rec.Opportunity__c,newAmount);
                        }
                    }
                }
            }
            if(oppIdMap != null){
                oppList = [Select Id,Total_Invoiced_Amount__c From Opportunity where Id IN: oppIdMap.keyset()];
                
                for(Opportunity opp: oppList){
                    if(oppIdMap.containsKey(opp.Id)){
                        if(opp.Total_Invoiced_Amount__c != null){
                            opp.Total_Invoiced_Amount__c = opp.Total_Invoiced_Amount__c - oppIdMap.get(opp.Id);
                            oppListToUpdate.add(opp);
                        }
                    }
                }
                if(!oppListToUpdate.isEmpty()){
                    update oppListToUpdate;
                }
            }
        }
    }
}