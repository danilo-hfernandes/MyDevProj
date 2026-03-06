trigger EmailMessageTrigger on EmailMessage (before update, before insert,after insert, after update){
    
    System.debug('EmailMessageTrigger STARTED');
    
    for(EmailMessage em : (List<EmailMessage>)Trigger.New)
    {
        System.debug('EmailMessageTrigger em json = '+JSON.serialize(em));
    }

}