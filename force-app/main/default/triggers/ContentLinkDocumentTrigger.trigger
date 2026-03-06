trigger ContentLinkDocumentTrigger on ContentDocumentLink (before insert, before Update) {
    if(trigger.isBefore && trigger.IsUpdate){
        system.debug('>>>>>>Update>>>>>>>>>'+Trigger.new);
        system.debug('>>>>>>Update>>>>>>>>>'+Trigger.old);
        //ContentNoteCustomClass.preventUpdation(Trigger.newMap);
    }
}