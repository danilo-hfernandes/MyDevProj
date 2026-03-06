global class MTRCVidaMFPBatchController implements Database.Batchable<sObject>, Schedulable{
    global List<Opportunity> updateOpportunity = new List<Opportunity>();
    global void execute(SchedulableContext SC) {
        MTRCVidaMFPBatchController objBatch = new MTRCVidaMFPBatchController(); 
        database.executebatch(objBatch, 1);
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'select id,leadassist__Use_Round_Robin__c,Match_Group_Name__c from Opportunity where AccountId != null and leadassist__Use_Round_Robin__c = \'false\' and Account.Affiliated_id__c=1002409 and Record_Type_Name__c = \'MTRC Retail\' and StageName = \'New\' and Account.enrollment_date__c = N_DAYS_AGO: 10 and (Owner.Name = \'Salesforce\' or Owner.Name = \'Dev Account\')';
        system.debug(query);
        return Database.getQueryLocator(query); 
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        system.debug('>>>>>Scope>>>>>>'+scope.size());
        system.debug('>>>scope>>>'+scope);
        /*for(Opportunity objOpp : scope){
            objOpp.leadassist__Use_Round_Robin__c = 'TRUE';
            objOpp.Match_Group_Name__c = 'Membership Upgrade-MTRC Vida MFP'; 
            updateOpportunity.add(objOpp);
        }*/
        updateOpportunity = GenericMatchGroupAssignmentHandler.assignMatchGroup(scope, 'Membership Upgrade-MTRC Vida MFP');
        if(updateOpportunity != null && updateOpportunity.size() > 0){
            update updateOpportunity;
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}