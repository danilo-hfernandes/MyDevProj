public class AssignContactProfitAgilityCadence implements Database.Batchable<sObject>,schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String query = '';
        
        query = 'select Id FROM Contact WHERE Marketing_Email_opt_out__c = false and Is_Main_Contact__c = true AND Account.Marketing_Brand__c = \'ProfitAgility\' AND Owner.FirstName = \'Jackie\' AND ActionCadenceId = NULL AND Owner.LastName = \'Summers\' LIMIT 2000';
            
        system.debug('14='+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        
        Set<Id> resultIds = (new Map<Id,SObject>(scope)).keySet();
        System.enqueueJob(new AssignContactProfitAgilityQueueable(resultIds));
        
    }
    
        public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new AssignContactProfitAgilityCadence(),20);
    }

}