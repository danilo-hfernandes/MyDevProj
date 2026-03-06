public class RemoveSMTNOpenSurveyLeadCadenceBatch implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query='';
        String whereClause = GenericMatchGroupAssignmentHandler.addWhereClause('False','notEquals'); 
        query = 'select id, Status, OwnerId,Assign_to_Sales_Cadence__c,First_Action_Cadence_Id__c from Lead where LeadSource= \'SMTN Open Survey\' and (Status = \'Closed Won\' or Status = \'Closed Lost\') and '+whereClause;  
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        List<Lead> updateLead = new List<Lead>();
        set<Id> targetsToRemove = new set<Id>();
        for(Lead objLead : scope){
            objLead.Assign_to_Sales_Cadence__c= true;
            objLead.First_Action_Cadence_Id__c='null';
            updateLead.add(objLead);
            targetsToRemove.add(objLead.Id);
        }
        if(updateLead != null && updateLead.size() > 0){
            updateLead =  GenericMatchGroupAssignmentHandler.removeMatchGroup(updateLead);
            update updateLead;
        }
        if(targetsToRemove != null && targetsToRemove.size() > 0)             
            System.enqueueJob(new RemoveTargetFromSalesCadenceQueueable(targetsToRemove)); 
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    public void execute(SchedulableContext SC) {
        RemoveSMTNOpenSurveyLeadCadenceBatch objBatch = new RemoveSMTNOpenSurveyLeadCadenceBatch(); 
        database.executebatch(objBatch, 25);
    }
}