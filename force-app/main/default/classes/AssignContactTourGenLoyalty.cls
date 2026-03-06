public class AssignContactTourGenLoyalty implements Database.Batchable<sObject>,schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id,Assign_to_Sales_Cadence__c ,Match_Group_Name__c ,Cadence_Flag__c FROM Contact Where ActionCadenceId=null  AND Parent_Id_Ext_Db__c = null AND Assign_to_Sales_Cadence__c=FALSE and Account.Enrollment_Date__c = N_DAYS_AGO:9 and Master_Record_Id__c!=null  AND (Account.Affiliated_Id__c = 1002222 OR Account.Affiliated_Id__c = 1002223 OR Account.Affiliated_Id__c = 1002224) ';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        System.debug('13--'+scope);
        Set<ID> cadenceContactsId=new set<Id>();
        List<Contact> contactToUpdate=new List<Contact>();
        List<Contact> conList=new list<contact>();
        Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
        for(Contact con : scope)
        {
            if(!contactIdSetMap.containskey(con.Id)){
                con.Assign_to_Sales_Cadence__c=true;
                con.Cadence_Flag__c=1;
                contactToUpdate.add(con);
                cadenceContactsId.add(con.id);
                contactIdSetMap.put(con.id,con.id);
            }
        }        
        
        if(contactToUpdate.size() > 0 ){
            System.debug('118--'+contactToUpdate);
            contactToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(contactToUpdate, 'Tour Gen Loyalty Survey');
            update contactToUpdate;
        } 
        
        System.enqueueJob(new AssignContactTourGenLoyaltyQueueable(cadenceContactsId)); 
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new AssignContactTourGenLoyalty(),100);
    }
}