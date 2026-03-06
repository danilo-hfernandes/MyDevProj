public class ClubGlobalExplorerVWOppAssignment implements Database.Batchable<sObject>, Schedulable{ 
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> recordTypeNames= new List<String>{'Club Global Explorer'}; 
            Date targetDate = Date.today().addDays(-16);
        DateTime startOfDay = DateTime.newInstance(targetDate.year(), targetDate.month(), targetDate.day());
        DateTime endOfDay = startOfDay.addDays(1);
        Date enrollment15DaysAgo = System.today().addDays(-15);
        //String CreatedByUser = 'netdev@nerdsoft.com';
        
        // Check if running in a sandbox environment
        String query = '';
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        if(runningInASandbox){
            // Custom logic for sandbox testing, add to query if needed
            query = 'SELECT Id, AccountId, Account.Preferred_Language__c, Name, Match_Group_Name__c, leadassist__Use_Round_Robin__c, ownerid, Account.Affiliated_Id__c, Owner.Name, LeadSource, LeadSource_Formula__c, Account.Enrollment_Date__c ' + 
                'FROM Opportunity WHERE (Account.Affiliated_Id__c = 1002458 OR Account.Affiliated_Id__c = 1002459) ' + 
                'AND (Owner.Name = \'Dev Account\' OR Owner.Name = \'Integration Systems\') '+                    
                'AND StageName = \'New\' ' + 
                'AND Record_Type_Name__c IN :recordTypeNames ' +
                'AND Account.Enrollment_Date__c = :enrollment15DaysAgo';
        } else {
            // Default query for production or other environments
            //String
            query = 'SELECT Id, AccountId, Account.Preferred_Language__c, Name, Match_Group_Name__c, leadassist__Use_Round_Robin__c, ownerid, Account.Affiliated_Id__c, Owner.Name, LeadSource, LeadSource_Formula__c, Account.Enrollment_Date__c ' + 
                'FROM Opportunity WHERE (Account.Affiliated_Id__c = 1002458 OR Account.Affiliated_Id__c = 1002459) ' + 
                'AND (Owner.Name = \'Dev Account\' OR Owner.Name = \'Integration Systems\') ' +
                'AND StageName = \'New\' ' + 
                'AND Record_Type_Name__c IN :recordTypeNames ' + 
                //'AND CreatedDate >= :startOfDay AND CreatedDate < :endOfDay'
                'AND Account.Enrollment_Date__c = :enrollment15DaysAgo';
        }
        
        system.debug('Query>>>' + query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        system.debug('Data >>>>'+scope);
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        for(Opportunity opp: scope){
            If((opp.LeadSource_Formula__c != null || opp.LeadSource != null)) {
                if(opp.Account.Affiliated_Id__c == 1002458){
                    opp.Match_Group_Name__c = 'Membership Upgrade-Club Global Tour No Buy';
                    system.debug('MatchGroup No Buy >>>>'+opp.Match_Group_Name__c);
                }
                else{
                    opp.Match_Group_Name__c = 'Membership Upgrade- Club Global VW';
                    system.debug('MatchGroup >>>>'+opp.Match_Group_Name__c);
                }
                opp.leadassist__Use_Round_Robin__c = 'true'; 
                oppToUpdate.add(opp);
            }
        }
        if(oppToUpdate.size() > 0 ){
            System.debug('oppToUpdate--'+oppToUpdate);
            update oppToUpdate;
        } 
        
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }  
    public void execute(SchedulableContext SC) {
        database.executebatch(new ClubGlobalExplorerVWOppAssignment(),100);
    }
}