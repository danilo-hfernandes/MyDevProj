public class VIPRetravelerLeadsAssignmentController implements Database.Batchable<sObject>{
    public set<Id> setLeadIds = new set<Id>();
    public VIPRetravelerLeadsAssignmentController(set<Id> leadIds){
        setLeadIds = leadIds;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('>>setLeadIds>>'+setLeadIds);
        List<User> userIdList = [select id from User where Name = 'Dev Account' limit 1];
        String query ='';
        query = 'select id,Match_Group_Name__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c from Lead where ID IN :setLeadIds and LeadSource= \'Vacation VIP Retraveler\' and Status = \'New\' and leadassist__Use_Round_Robin__c = \'FALSE\' and OwnerId IN :userIdList limit 1000';  
        system.debug(query);
        return Database.getQueryLocator(query); 
    }
    public void execute(Database.BatchableContext BC, List<Lead> scope){
        List<Lead> updateLead = new List<Lead>();
        set<Id> cadenceLeadIds = new set<Id>();
        for(Lead objLead : scope){
            //objLead.Match_Group_Name__c = 'TourGen-Vacation VIP Retraveler';
            //objLead.leadassist__Use_Round_Robin__c = 'TRUE';
            objLead.Assign_to_Sales_Cadence__c=true;
            updateLead.add(objLead);
            cadenceLeadIds.add(objLead.Id);
        }
        if(updateLead != null && updateLead.size() > 0){
            updateLead =  GenericMatchGroupAssignmentHandler.assignMatchGroup(updateLead, 'TourGen-Vacation VIP Retraveler');
            update updateLead;
        }
        if(cadenceLeadIds != null && cadenceLeadIds.size() > 0)            
            System.enqueueJob(new GenericAssignToSalesCadence(cadenceLeadIds, 'TourGen-Vacation VIP Retraveler')); 
    } 
    public void finish(Database.BatchableContext BC){
    }
}