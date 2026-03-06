public class FiletrackerReservationsBatchController implements Database.Batchable<sObject>, Database.Stateful,Schedulable{
    public void execute(SchedulableContext SC) {
        FiletrackerReservationsBatchController objBatch = new FiletrackerReservationsBatchController(); 
        database.executebatch(objBatch, 1);
    }
	public Database.QueryLocator start(Database.BatchableContext BC){
        String recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Filetracker Reservations').getRecordTypeId();
        String query ='';
        query = 'select id,Match_Group_Name__c,Assign_to_Sales_Cadence__c,TRP_Eligible__c from Lead where RecordTypeId = :recordTypeId and (LeadSource= \'Filetracker Daily Load\' or LeadSource= \'Filetracker 2024 Bulk\') and Match_Group_Name__c = null limit 1';  
        system.debug(query);
        return Database.getQueryLocator(query); 
    }
    public void execute(Database.BatchableContext BC, List<Lead> scope){
        List<Lead> updateLead = new List<Lead>();
        set<Id> cadenceLeadIds = new set<Id>();
        for(Lead objLead : scope){
            if(objLead.TRP_Eligible__c == 'Yes'){
                objLead.Match_Group_Name__c = 'Inventory-TRP Eligible';
            }
            else if(objLead.TRP_Eligible__c == 'No'){
                objLead.Match_Group_Name__c = 'Inventory-TRP Not Eligible';
            }
            updateLead.add(objLead);
        }
        if(updateLead != null && updateLead.size() > 0){
            updateLead = GenericMatchGroupAssignmentHandler.assignMatchGroup(updateLead, 'Assigned');
            update updateLead;
        } 
    } 
    public void finish(Database.BatchableContext BC){
    }
}