public class VIPRetravelerLeadsRemovableController implements Database.Batchable<sObject>, Database.Stateful,Schedulable{
    public set<Id> setLeadIds = new set<Id>();
    public void execute(SchedulableContext SC) {
        VIPRetravelerLeadsRemovableController objBatch = new VIPRetravelerLeadsRemovableController(); 
        database.executebatch(objBatch, 1);
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        //DateTime lastModifiedDate = System.date.valueOf('2023-10-02T00:00:00.000+0000');
        String query ='';
        query = 'select id, Status, OwnerId,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,First_Action_Cadence_Id__c from Lead where LeadSource= \'Vacation VIP Retraveler\' and Status != \'New\' and Isconverted = false and VIPRetraveler__c = false Order by CreatedDate DESC limit 1000';  
        system.debug(query);
        return Database.getQueryLocator(query); 
    }
    public void execute(Database.BatchableContext BC, List<Lead> scope){
        List<User> userIdList = [select id from User where  Name = 'Dev Account' limit 1];
        List<Lead> updateLead = new List<Lead>();
        set<Id> targetsToRemove = new set<Id>();
        for(Lead objLead : scope){
            objLead.Status = 'New';
            objLead.OwnerId = userIdList[0].Id;
            //objLead.leadassist__Use_Round_Robin__c = 'FALSE';
            objLead.Assign_to_Sales_Cadence__c=true;
            objLead.First_Action_Cadence_Id__c='null';
            objLead.VIPRetraveler__c = true;
            updateLead.add(objLead);
            setLeadIds.add(objLead.Id);
            targetsToRemove.add(objLead.Id);
        }
        if(updateLead != null && updateLead.size() > 0){
            updateLead = GenericMatchGroupAssignmentHandler.assignMatchGroup(updateLead, 'Assigned');
            update updateLead;
        }
        if(targetsToRemove != null && targetsToRemove.size() > 0)            
            System.enqueueJob(new RemoveTargetFromSalesCadenceQueueable(targetsToRemove)); 
    } 
    public void finish(Database.BatchableContext BC){
        system.debug('>>setLeadIds>>'+setLeadIds);
        VIPRetravelerLeadsAssignmentController objBatch = new VIPRetravelerLeadsAssignmentController(setLeadIds); 
        database.executebatch(objBatch, 1);
    }
}