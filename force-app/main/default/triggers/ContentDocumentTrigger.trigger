trigger ContentDocumentTrigger on ContentDocument (before update, before delete) {
    if(trigger.isBefore && trigger.IsUpdate){
        system.debug('>>>>>>Update>>>>>>>>>'+Trigger.new);
        system.debug('>>>>>>Update>>>>>>>>>'+Trigger.old);
        ContentNoteCustomClass.preventUpdation(Trigger.newMap);
    }
    if(trigger.isBefore && trigger.isDelete){
        Map<Id, ContentDocument> mapContentDocument = new Map<Id, ContentDocument>([Select Id, FileExtension from ContentDocument where Id in: trigger.oldMap.keyset()]);
        for(ContentDocument cd : Trigger.Old){
            if(mapContentDocument.containsKey(cd.Id) && mapContentDocument.get(cd.Id).FileExtension == 'snote' ){
                cd.adderror('You don\'t have permission to delete the Note');
            }
        }
    }
}