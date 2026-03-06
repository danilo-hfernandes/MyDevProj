public class AssigningContactInCadence implements Database.Batchable<sObject>,schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String MatchRule='Rebook';
        String query = 'select id,name,match_group_name__c,Active_Advantage_Match_Group__c,actioncadenceid from contact where  match_group_name__c=\''+MatchRule+'\' ' +(Test.isRunningTest()?' limit 20':'');
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        Set<ID> cadenceContactsId=new set<Id>();
        List<Contact> contactToUpdate=new List<Contact>();
        for(Contact con:scope){
            con.Assign_to_Sales_Cadence__c=true;
            //con.Match_Group_Name__c='TourGen-Rebook';
            //con.leadassist__Use_Round_Robin__c='TRUE';
            contactToUpdate.add(con);
            cadenceContactsId.add(con.id);     
        }
        if(contactToUpdate.size() > 0 ){
            contactToUpdate = GenericMatchGroupAssignmentHandler.assignMatchGroup(contactToUpdate, 'TourGen-Rebook');
            System.debug('89--'+contactToUpdate);
            update contactToUpdate;
        } 
        if(cadenceContactsId != null){
            System.enqueueJob(new TourGenRebookQueueable(cadenceContactsId));
        }
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new AssigningContactInCadence(),1);
    }
}