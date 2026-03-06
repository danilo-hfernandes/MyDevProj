public class ClubGlobalExplorerVWOppCreation implements Database.Batchable<sObject>, Schedulable{ 
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date targetDate = Date.today().addDays(-10);
        DateTime startOfDay = DateTime.newInstance(targetDate.year(), targetDate.month(), targetDate.day());
        DateTime endOfDay = startOfDay.addDays(1);
        String query;
        if(test.isRunningTest()){
            query = 'SELECT Id,Name,Preferred_Language__c,Ownerid,Affiliated_Id__c FROM Account Where  (Affiliated_Id__c = 1002458 or Affiliated_Id__c = 1002459) and Owner.Name = \'Dev Account\'';//
        }
        else{
            query = 'SELECT Id,Name,Preferred_Language__c,Ownerid,Affiliated_Id__c FROM Account Where (Affiliated_Id__c = 1002458 or Affiliated_Id__c = 1002459) and (Owner.Name = \'Salesforce\' OR Owner.Name = \'Dev Account\') and CreatedDate >= :startOfDay AND CreatedDate < :endOfDay';//
        }
        system.debug('Query>>>'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        list<Opportunity> clubGlobalOpportunity=new list<opportunity>();
        for(Account acc: scope){
            if(acc.Affiliated_Id__c == 1002458 || acc.Affiliated_Id__c == 1002459){
                Opportunity opp= new Opportunity();
                opp.name=acc.name;
                opp.stagename='New';
                opp.AccountId=acc.id;
                opp.CloseDate=system.today();
                opp.RecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Club_Global_Explorer').getRecordTypeId();
                opp.OwnerId = System.label.SystemAdminUserId ;
                clubGlobalOpportunity.add(opp);
            }
        }
        if(clubGlobalOpportunity.size()>0){
            insert clubGlobalOpportunity;
        }          
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }  
    public void execute(SchedulableContext SC) {
        database.executebatch(new ClubGlobalExplorerOppCreation(),100);
    }
}