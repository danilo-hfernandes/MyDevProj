trigger LinkedCaseTrigger on Linked_Case__c (after insert, after update) {
LinkedCaseTriggerHandler handler = new LinkedCaseTriggerHandler();
    switch on Trigger.operationType {
        when AFTER_INSERT {
             handler.afterInsert(Trigger.new);
        }
        when AFTER_UPDATE {
             handler.afterUpdate(Trigger.new);
        }
    }
}