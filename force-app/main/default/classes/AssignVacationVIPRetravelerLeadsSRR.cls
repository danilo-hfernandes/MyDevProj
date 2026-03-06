public class AssignVacationVIPRetravelerLeadsSRR implements Database.Batchable<sObject>,schedulable{
    //TourGen-Vacation VIP Retraveler
    public List<Id> targetIds = new List<Id>();
    public AssignVacationVIPRetravelerLeadsSRR(){
        targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList('TourGen-Vacation VIP Retraveler');
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {        
        Id leadCFRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Carefree_Destinations').getRecordTypeId();
        //String dt15min = DateTime.now().addMinutes(-15).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String query = '';
        Integer querylimits = Integer.valueOf(label.LimitAssignVacationVIPRetravelerLeadsSRR);
        
        //queryV1 = 'SELECT Id,CreatedDate,Status,RecordType.DeveloperName,leadassist__Use_Round_Robin__c,LeadSource,CreatedBy.Email,Is_Duplicate__c,ActionCadenceAssigneeId,ActionCadenceId,ActionCadenceState,Owner.Name,Sales_Cadence_Assignment_Attempt__c,First_Action_Cadence_Id__c FROM Lead WHERE (First_Action_Cadence_Id__c = \'\' OR First_Action_Cadence_Id__c = null) AND (LeadSource = \'Vacation VIP - Web\' OR LeadSource = \'VI Referral\' OR ((RecordTypeId = \''+leadCFRecTypeId+'\' AND CreatedById = \''+zappierUser.Id+'\' AND Is_Duplicate__c=false) AND (LeadSource != \'TRM Contactable\' AND LeadSource != \'TRM Open\')) ) AND ActionCadenceId = NULL AND IsConverted = FALSE AND (Sales_Cadence_Assignment_Attempt__c = 0 OR Sales_Cadence_Assignment_Attempt__c = 1 OR Sales_Cadence_Assignment_Attempt__c = 2) AND leadassist__Use_Round_Robin__c = \'ASSIGNED\' AND CreatedDate = LAST_N_DAYS:3 ORDER BY CreatedDate ASC';
        if(!Test.isRunningTest()){
            query = 'SELECT Id,CreatedDate,Status,RecordType.DeveloperName,leadassist__Use_Round_Robin__c,LeadSource,CreatedBy.Email,Is_Duplicate__c,ActionCadenceAssigneeId,ActionCadenceId,ActionCadenceState,Owner.Name,Owner.Email,Sales_Cadence_Assignment_Attempt__c,First_Action_Cadence_Id__c FROM Lead WHERE Marketing_Email_opt_out__c= false and LeadSource = \'Vacation VIP Retraveler\' AND Status != \'NI\' AND Status != \'Bad Number\' AND Status != \'Sold Voucher\' AND Status != \'Closed Won\' AND Status != \'DNC\' AND Status != \'Duplicate\' AND Status != \'Test\' AND Status != \'Bogus\' AND Status != \'Bad Email\'  AND RecordTypeId = \''+leadCFRecTypeId+'\' AND  IsConverted = FALSE AND (ActionCadenceId = \'\' OR ActionCadenceId = null)  ORDER BY CreatedDate ASC LIMIT '+querylimits;
        }
        else
        {
            query = 'SELECT Id,CreatedDate,Status,RecordType.DeveloperName,LeadSource,CreatedBy.Email,Is_Duplicate__c,ActionCadenceAssigneeId,ActionCadenceId,ActionCadenceState,Owner.Name,Owner.Email,Sales_Cadence_Assignment_Attempt__c,First_Action_Cadence_Id__c FROM Lead WHERE Id NOT IN : targetIds and Marketing_Email_opt_out__c = false and LeadSource = \'Vacation VIP Retraveler\' AND Status = \'New\' AND Owner.Name = \'Dev Account\' AND RecordTypeId = \''+leadCFRecTypeId+'\' AND (First_Action_Cadence_Id__c = \'\' OR First_Action_Cadence_Id__c = null) AND IsConverted = FALSE AND leadassist__Use_Round_Robin__c = \'FALSE\' ORDER BY CreatedDate ASC LIMIT 20';    
        }
        system.debug('--query--'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        Set<Id> LeadIdSet = new Set<Id>();
        List<Lead> LeadToUpdate = new List<Lead>();
        for(Lead ld : scope){
            if(ld.LeadSource == 'Vacation VIP Retraveler'){      
                LeadIdSet.add(ld.Id);
                LeadToUpdate.add(ld);
                system.debug('--LeadIdSet--'+LeadIdSet.size());
            }
        }
        if(LeadToUpdate != null && LeadToUpdate.size() > 0){
            LeadToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(LeadToUpdate, 'Assigned');
            update LeadToUpdate;
        }
        if(LeadIdSet.size() > 0 ){
            System.enqueueJob(new AssignVacationVIPRetravelerLeadQueueable(LeadIdSet)); 
        } 
    } 
    public void finish(Database.BatchableContext bc) {
        //do something 
    }
    public void execute(SchedulableContext SC) {
        database.executebatch(new AssignVacationVIPRetravelerLeadsSRR(),20); 
    }
}