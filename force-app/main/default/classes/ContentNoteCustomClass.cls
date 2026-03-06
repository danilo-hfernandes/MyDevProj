public class ContentNoteCustomClass {
    public static void preventUpdation(map<Id, ContentDocument> mapConDocument){
        set<Id> setConDocIds = new set<Id>();
        for(ContentDocument conVer : mapConDocument.values()){
            setConDocIds.add(conVer.Id);
        }
        Map<Id, ContentDocument> mapContentDocument = new Map<Id, ContentDocument>([Select Id, FileExtension, CreatedDate, LastModifiedDate from ContentDocument where Id in: setConDocIds]);
        for(ContentDocument cd : mapConDocument.values()){
            Long lastModifiedTime = cd.LastModifiedDate.getTime();
            Long createdDateTime = cd.CreatedDate.getTime();
            system.debug('>>>>>>'+lastModifiedTime);
            system.debug('>>>>>>'+createdDateTime);
            Long milliseconds = lastModifiedTime - createdDateTime;
            Long mins = milliseconds / 60000;
            Long hours = mins / 60;
            Long remainingMins = mins - (hours * 60);
			system.debug('>>milliseconds>>'+milliseconds+'>>>mins>>>>'+mins+'>>hours>>>'+hours+'>>remainingMins>>>'+remainingMins);
            String currentUserId = UserInfo.getUserId();
            Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('ContentNoteUpdateBypass');
            if(mapContentDocument.get(cd.Id).FileExtension == 'snote' && remainingMins > Integer.valueOf(System.Label.Note_Timer) && !cs.isEnable__c){
                cd.adderror('You don\'t have permission to update the Note');
            }
        }
    } 
}