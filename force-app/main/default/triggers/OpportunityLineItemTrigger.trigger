trigger OpportunityLineItemTrigger on OpportunityLineItem (before update, before insert, after insert, before delete, after delete, after update) {
    system.debug('OpportunityLineItemTrigger starts');
    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('OpportunityLineItemTrigger');
    system.debug('OpportunityLineItemTrigger cs:' + cs);
    system.debug('OpportunityLineItemTrigger Trigger.isUpdate:' + Trigger.isUpdate);
    system.debug('OpportunityLineItemTrigger Trigger.isAfter:' + Trigger.isAfter);
    if(cs != null && cs.isEnable__c){ 
        /* Before Insert */
        if(Trigger.isInsert && Trigger.isBefore){
            OpportunityLineItemTriggerHandler.getInstance().beforeInsert();
        }
        /* After Insert */
        else if(Trigger.isInsert && Trigger.isAfter){
            OpportunityLineItemTriggerHandler.getInstance().afterInsert();
        }    
        /* Before Delete */
        else if(Trigger.isDelete && Trigger.isBefore){
            OpportunityLineItemTriggerHandler.getInstance().beforeDelete();
        }
        /* After Delete */
        else if(Trigger.isDelete && Trigger.isAfter){
            OpportunityLineItemTriggerHandler.getInstance().afterDelete();
        }    
        /* After Undelete */
        else if(Trigger.isUnDelete){
            //OpportunityLineItemTriggerHandler.MethodE();
        }
        /* Before Update */
        else if(Trigger.isUpdate && Trigger.isBefore){
            OpportunityLineItemTriggerHandler.getInstance().beforeUpdate();
        }
        /* After Update */
        else if(Trigger.isUpdate && Trigger.isAfter){
            //OpportunityLineItemTriggerHandler.MethodG();
            system.debug('OpportunityLineItemTrigger calls OpportunityLineItemTriggerHandler.afterUpdate()');
            OpportunityLineItemTriggerHandler.getInstance().afterUpdate();
        }
    }
}