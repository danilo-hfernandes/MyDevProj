public class UnsubscribeRecordsHandler {
    public UnsubscribeRecordsHandler(){
    }
    public static void unsubscribe(List<SObject> listSObject, String ObjectName){
        List<ContentNote> noteList = new List<ContentNote>();
        List<ContentDocumentLink> conDoclnk = new List<ContentDocumentLink>();
        set<Id> targetsToRemove = new set<Id>();
        List<SObject> listSObjectUpdate = new List<SObject>();
        for(SObject obj : listSObject){
            String notesDescription = 'User : '+UserInfo.getName()+' Timestamp : '+System.Now().format();
            ContentNote cnt = new ContentNote();
            cnt.Content = Blob.valueof(notesDescription);
            if((Boolean)obj.get('Marketing_Email_opt_out__c')){
            	cnt.Title = 'Unsubscribed';
            }
            else{
               cnt.Title = 'Subscribed'; 
            }
            noteList.add(cnt);
        }
        if(noteList != null && noteList.size() > 0){
            insert noteList;
            Integer i = 0;
            for(SObject obj : listSObject){
                String Id = (String)obj.get('Id');
                ContentDocumentLink clnk = new ContentDocumentLink();
                clnk.LinkedEntityId = Id;
                clnk.ContentDocumentId = noteList[i].Id;
                clnk.ShareType = 'I';
                i++;
                conDoclnk.add(clnk);
            }
            if(conDoclnk != null && conDoclnk.size() > 0){
                insert conDoclnk;
            }
        }
    }
}