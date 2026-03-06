public class TRMCadenceBatch implements Database.Batchable<sObject>,schedulable{
    public List<Id> targetIds = new List<Id>();
    public TRMCadenceBatch(){
        targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList('TourGen-TRM');
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String source='TRM Open';
        String country1='United Stated';
        String country2='Mexico';
        String query = 'SELECT Id,Assign_to_Sales_Cadence__c ,Match_Group_Name__c FROM Lead Where ID NOT IN : targetIds and Marketing_Email_opt_out__c = false and LeadSource= \''+source+'\' AND (country= \''+country1+'\' OR country!= \''+Country2+'\') limit 600 ';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        
        System.debug('13--'+scope);
        
        Set<ID> cadenceLeadsId=new set<Id>();
        List<Lead> leadToUpdate=new List<Lead>();
        
        List<Lead> conList=new list<Lead>();
        for(Lead l : scope)
        {
            l.Assign_to_Sales_Cadence__c=true;
            leadToUpdate.add(l);
            cadenceLeadsId.add(l.id);
        }        
        
        if(leadToUpdate.size() > 0 ){
            System.debug('118--'+leadToUpdate);
            leadToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(leadToUpdate, 'TRM');
            update leadToUpdate;
        } 
        
        System.enqueueJob(new TRMCadenceBatchQueueable(cadenceLeadsId)); 
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new TRMCadenceBatch(),1);
    }
}