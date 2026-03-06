public class TourGenVacationVIPDBTranBatchController implements Database.Batchable<sObject>, Database.Stateful,Schedulable{
    public void execute(SchedulableContext SC) {
        TourGenVacationVIPDBTranBatchController objBatch = new TourGenVacationVIPDBTranBatchController(); 
        database.executebatch(objBatch, 1);
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<Id> targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList('TourGen-Vacation VIP DB Transition');
        Id devAccountId = [select id from User where Name = 'Dev Account' and isActive = true limit 1].Id;
        String query ='';
        if(Test.isRunningTest()){
            query = 'select id,Match_Group_Name__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,VIP_Offer_Date__c from Lead where Status = \'New\' and LeadSource= \'Vacation VIP DB Transition\' and VIP_Offer_Date__c != null and ActionCadenceId = null Order by VIP_Offer_Date__c DESC limit 1500';  
        }
        else{
        	query = 'select id,Match_Group_Name__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,VIP_Offer_Date__c from Lead where Id NOT IN : targetIds and Marketing_Email_opt_out__c = false and OwnerId =\''+devAccountId+'\' and Status = \'New\' and LeadSource= \'Vacation VIP DB Transition\' and VIP_Offer_Date__c != null Order by VIP_Offer_Date__c DESC limit 1500';  
        }
        system.debug(query);
        return Database.getQueryLocator(query); 
    }
    public void execute(Database.BatchableContext BC, List<Lead> scope){
        List<Lead> updateLead = new List<Lead>();
        set<Id> cadenceLeadIds = new set<Id>();
        for(Lead objLead : scope){
            //objLead.Match_Group_Name__c = 'TourGen-Vacation VIP DB Transition'; 
            //objLead.leadassist__Use_Round_Robin__c = 'TRUE';
            objLead.Assign_to_Sales_Cadence__c=true;
            updateLead.add(objLead);
            cadenceLeadIds.add(objLead.Id);
        }
        if(updateLead != null && updateLead.size() > 0){
            updateLead =  GenericMatchGroupAssignmentHandler.assignMatchGroup(updateLead, 'TourGen-Vacation VIP DB Transition');
            update updateLead;
        } 
        if(cadenceLeadIds != null && cadenceLeadIds.size() > 0){        
            System.enqueueJob(new GenericAssignToSalesCadence(cadenceLeadIds, 'TourGen-Vacation VIP DB Transition'));
        }
    } 
    public void finish(Database.BatchableContext BC){
    }
}