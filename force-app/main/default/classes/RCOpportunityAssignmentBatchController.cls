public class RCOpportunityAssignmentBatchController implements Database.Batchable<sObject>,schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String stageName='New';
        Set<Integer> affilateIDSet = new Set<Integer>{1002469, 1002468, 1002467};
        //ID ownerId= [SELECT Id FROM User where name='Dev Account' LIMIT 1].id;
        List<Id> userList = new List<Id>();
        for(User objuser : [SELECT Id,Username, Name FROM User WHERE Name = 'Dev Account' or Name= 'Salesforce' LIMIT 2]){
            userList.add(objuser.Id);
        }
        String recordTypeName='Reserve Collection Membership';
        String query = 'SELECT Id,Name,AccountId,ownerid,Account.Preferred_Language__c, Match_Group_Name__c from Opportunity where Account_Affiliate_Id__c IN :affilateIDSet  AND StageName=\''+stageName+'\' AND  OwnerId IN :userList AND Account_Enrollment_Date__c <= N_DAYS_AGO:15 AND Record_Type_Name__c=\''+recordTypeName+'\'' +(Test.isRunningTest()?' limit 20':'');
        
        system.debug('9='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        List<Opportunity> updateOppList = new List<Opportunity>();
        for(Opportunity opp: scope){
            if(opp.Account.Preferred_Language__c=='SPA'){
                opp.Match_Group_Name__c='Membership Upgrade RC-SPA';
                opp.leadassist__Use_Round_Robin__c = 'TRUE';
                updateOppList.add(opp);
            }
            else if(opp.Account.Preferred_Language__c=='ENG'){
                opp.Match_Group_Name__c='Membership Upgrade RC-ENG';
                opp.leadassist__Use_Round_Robin__c = 'TRUE';
                updateOppList.add(opp);
            }
        }
        if(updateOppList != null && updateOppList.size() > 0){
           // updateOppList =  GenericMatchGroupAssignmentHandler.assignMatchGroup(updateOppList, 'Assigned');
            update updateOppList;
        }
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    public void execute(SchedulableContext SC) {
        database.executebatch(new RCOpportunityAssignmentBatchController(),1);
    }
}