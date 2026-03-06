trigger certificateTrigger on Certificate__c (after update) {
    CertificateTriggerHandler.sendBalanceLowNotification(trigger.New);
}