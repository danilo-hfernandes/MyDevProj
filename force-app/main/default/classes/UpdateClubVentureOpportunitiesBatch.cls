global class UpdateClubVentureOpportunitiesBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Date fifteenDaysAgo = Date.today().addDays(-15);
        return Database.getQueryLocator([
            SELECT Id, Match_Group_Name__c, leadassist__Use_Round_Robin__c
            FROM Opportunity
            WHERE Account.Affiliated_Id__c = 1002453
            AND RecordType.Name = 'Club Venture Membership'
            AND StageName = 'New'
            AND Account.Enrollment_Date__c = :fifteenDaysAgo
            AND Owner.Name IN ('Dev Account', 'Integration System')
            AND Account.Preferred_Language__c != 'SPA'
            AND (Match_Group_Name__c = NULL OR Match_Group_Name__c != 'Membership Upgrade-Club Venture')
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
       /* for (Opportunity opp : scope) {
            opp.Match_Group_Name__c = 'Membership Upgrade-Club Venture';
            opp.leadassist__Use_Round_Robin__c = 'true'; // 
        }*/
        scope = GenericMatchGroupAssignmentHandler.assignMatchGroup(scope, 'Membership Upgrade-Club Venture');
        update scope;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Batch Job Completed Successfully');
    }
}