public class FBOutboundLead implements Database.Batchable<sObject>,schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
     
		//2023-04-24 Changes to only include Sources that contain FB, Google, CFD MX Checkout.
        //String source1='TRM Open';
        //String source2='VI Referral';
        String recordTypeId='0123t000000dXngAAE';
        String Owner1='0053t000006rP8lAAE';
        String Owner2='0053t000006rZcSAAU';
        //String query='SELECT Id, RecordTypeId, Name, CreatedDate,FB_Outbound_Group__c, ActionCadenceId, Is_Duplicate__c, leadassist__Use_Round_Robin__c,status,LeadSource FROM Lead where (LeadSource!=\''+source1+'\' AND LeadSource!=\''+source2+'\' ) AND (Ownerid!=\''+Owner2+'\' AND Ownerid!=\''+Owner1+'\' ) AND ActionCadenceId=null AND Status != \'Bogus\' AND Status != \'Bad Number\' AND Is_Duplicate__c=FALSE AND IsConverted=false AND CreatedDate = N_DAYS_AGO:31  AND RecordTypeId=\''+recordTypeId+'\'';
        String query='SELECT Id, RecordTypeId, Name, CreatedDate,FB_Outbound_Group__c, ActionCadenceId, Is_Duplicate__c,status,LeadSource FROM Lead where Marketing_Email_opt_out__c = false and (LeadSource LIKE \'%CFD%\' OR LeadSource LIKE \'%FB%\') AND (Ownerid!=\''+Owner2+'\' AND Ownerid!=\''+Owner1+'\' ) AND ActionCadenceId=null AND Status != \'Bogus\' AND Status != \'Bad Number\' AND Is_Duplicate__c=FALSE AND IsConverted=false AND CreatedDate = N_DAYS_AGO:31  AND RecordTypeId=\''+recordTypeId+'\'';
        system.debug('11='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        
        System.debug('16--'+scope);
        
        Set<ID> cadenceLeadsId=new set<Id>();
        List<Lead> LeadToUpdate=new List<Lead>();
        
        List<Lead> leadList=new list<Lead>();
         Map<Id,Id> LeadIdSetMap = new Map<Id,Id>();
        for(Lead l : scope)
        {
            //Only include FB Leads in the TourGen-FB Outbound Final Attempt match group logic - MAINT-373
            if(!LeadIdSetMap.containskey(l.Id)){
            //if((!LeadIdSetMap.containskey(l.Id)) && (l.LeadSource.contains('CFD') || l.LeadSource.contains('FB'))){
                l.Assign_to_Sales_Cadence__c=true;
                l.FB_Outbound_Group__c='TRUE';
                LeadToUpdate.add(l);
                cadenceLeadsId.add(l.id);
                 LeadIdSetMap.put(l.id,l.id);
             }
        }        
        
        if(LeadToUpdate.size() > 0 ){
            System.debug('32--'+LeadToUpdate);
            LeadToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(LeadToUpdate, 'Assigned');
            update LeadToUpdate;
        } 
        
        System.enqueueJob(new FBOutboundLeadQueueable(cadenceLeadsId)); 
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new FBOutboundLead(),25);
    }
}