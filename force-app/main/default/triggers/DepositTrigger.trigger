//DepositTrigger
trigger DepositTrigger on Deposits__c (before insert, after insert, before update, after update, before delete) {
    DepositTriggerHandler handler = new DepositTriggerHandler();
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            system.debug('DepositTrigger handler.beforeInsert(Trigger.new) entered <<');
             handler.beforeInsert(Trigger.new);
        }
        when AFTER_INSERT {
            system.debug('DepositTrigger handler.afterInsert(Trigger.new) entered <<');
             handler.afterInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
             handler.beforeUpdate(Trigger.new, Trigger.oldMap);
        }
        when BEFORE_DELETE {
             handler.beforeDelete(Trigger.old);
        }
        when AFTER_UPDATE {
             handler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}