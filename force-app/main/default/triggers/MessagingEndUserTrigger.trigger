trigger MessagingEndUserTrigger on MessagingEndUser (before insert) {
    System.debug('=== MessagingEndUserTrigger fired ===');
    System.debug(JSON.serializePretty(Trigger.new));
}