trigger AuthorizationUserTrigger on Authorize_Users__c (after insert, after update) {
    /*switch on Trigger.operationType{
        when AFTER_INSERT{
            system.debug('AFTER_INSERT');
            AuthorizationUserTriggerHandler.afterInsert(trigger.new);
        }
        when AFTER_UPDATE{
            system.debug('AFTER_UPDATE');
            AuthorizationUserTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
        }
    }*/
}