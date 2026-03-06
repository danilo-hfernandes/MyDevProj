trigger MessagingEndUserChangeEventTrigger on MessagingEndUserChangeEvent (after insert) {
    System.debug('=== MessagingEndUserChangeEventTrigger fired ===');
    System.debug(JSON.serializePretty(Trigger.new));
}