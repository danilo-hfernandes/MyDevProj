public class SFXGold implements Database.Batchable<sObject>,schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String SFX='SFX Gold';
        //String query='SELECT Id,Name,Assign_to_Sales_Cadence__c,Cadence_Flag__c FROM Contact where Match_Group_Name__c=\''+SFX+'\' AND Parent_Id_Ext_Db__c = null AND Assign_to_Sales_Cadence__c=FALSE  AND Master_Record_Id__c!=null limit 300';
        String query='SELECT Id,Name,Assign_to_Sales_Cadence__c,Cadence_Flag__c FROM Contact where Marketing_Email_opt_out__c = false and Parent_Id_Ext_Db__c = null limit 300';
        
        system.debug('11='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        
        System.debug('16--'+scope);
        
        Set<ID> cadenceLeadsId=new set<Id>();
        List<Contact> ContactToUpdate=new List<Contact>();
        
        List<Contact> leadList=new list<Contact>();
        Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
        for(Contact con : scope)
        {
            if(!contactIdSetMap.containskey(con.Id)){
               	con.Assign_to_Sales_Cadence__c=true;
                con.Cadence_Flag__c=1;
                ContactToUpdate.add(con);
                cadenceLeadsId.add(con.id);
                contactIdSetMap.put(con.id,con.id);
            }
        }        
        if(ContactToUpdate.size() > 0 ){
            System.debug('32--'+ContactToUpdate);
            ContactToUpdate = GenericMatchGroupAssignmentHandler.assignMatchGroup(ContactToUpdate, 'Assigned');
            update ContactToUpdate;
        } 
        
        System.enqueueJob(new SFXGoldQueueable(cadenceLeadsId)); 
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new SFXGold(),100);
    }
}