trigger MessagingSessionTrigger on MessagingSession (before insert) {
    System.debug('=== MessagingSessionTrigger fired ===');
    System.debug(JSON.serializePretty(Trigger.new));
}