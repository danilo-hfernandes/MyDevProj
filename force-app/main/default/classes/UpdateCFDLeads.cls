public class UpdateCFDLeads implements Database.Batchable<sObject>,schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('3===');
        String source='Vacation VIP - Web';
        String RId='0123t000000dXngAAE';
        String query='select id,name,leadsource,Is_Duplicate__c from lead where leadsource=\''+source+'\' and recordtypeid=\''+RId+'\' and Is_Duplicate__c=false and actioncadenceid=null'+(Test.isRunningTest()?' limit 20':'');
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        List<Lead> contactToUpdate=new List<Lead>();
        Set<Id> LeadIdSet = new Set<Id>();
        for(Lead con: scope){
            contactToUpdate.add(con);
            LeadIdSet.add(con.id);  
        }
        // update contactToUpdate;
        if(LeadIdSet != null && LeadIdSet.size() > 0){
            system.debug('2222='+LeadIdSet);
            System.enqueueJob(new leadTriggerOMHandler(LeadIdSet)); 
        }
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    public void execute(SchedulableContext SC) {
        database.executebatch(new UpdateCFDLeads(),50);
    } 
}