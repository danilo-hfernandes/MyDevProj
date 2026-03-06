public class ClubGlobalExplorerOppAssignment implements Database.Batchable<sObject>, Schedulable{ 
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> recordTypeNames= new List<String>{'Club Global Explorer'}; 
            Date enrollment15DaysAgo = System.today().addDays(-15);
        String query = 'SELECT Id,AccountId,Account.Preferred_Language__c,name,Match_Group_Name__c,ownerid FROM Opportunity Where Account.Affiliated_Id__c = 1002447 and Owner.Name = \'Dev Account\' and StageName = \'New\' AND Record_Type_Name__c IN :recordTypeNames and Account.Enrollment_Date__c = :enrollment15DaysAgo';
        system.debug('Query>>>'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        system.debug('Data >>>>'+scope);
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        for(Opportunity opp: scope){
            if(opp.Account.Preferred_Language__c == 'SPA'){
                opp.Match_Group_Name__c = 'Membership Upgrade-Club Global Explorer SPA';
            }
            else{
                opp.Match_Group_Name__c = 'Membership Upgrade-Club Global Explorer';
            }
            oppToUpdate.add(opp);
        }
        if(oppToUpdate.size() > 0 ){
            System.debug('oppToUpdate--'+oppToUpdate);
            oppToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(oppToUpdate, 'Assigned');
            update oppToUpdate;
        } 
        
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }  
    public void execute(SchedulableContext SC) {
        database.executebatch(new ClubGlobalExplorerOppAssignment(),100);
    }
}