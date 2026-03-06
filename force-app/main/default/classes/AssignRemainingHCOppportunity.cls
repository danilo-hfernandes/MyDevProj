public class AssignRemainingHCOppportunity  implements Database.Batchable<sObject>{
	public Database.QueryLocator start(Database.BatchableContext bc) {
        String stageName='New';
        String UseRoundRobin='NOMATCH';
        ID ownerId= [SELECT Id FROM User where name='Dev Account' LIMIT 1].id;
        ID ownerId1 = [SELECT Id FROM User where name='Salesforce' LIMIT 1].id;
        String recordTypeName='Hawaii Collection Membership';
        String query = 'SELECT Id,Name,AccountId,ownerid,Account.Preferred_Language__c from opportunity where StageName=\''+stageName+'\' AND leadassist__Use_Round_Robin__c=\''+UseRoundRobin+'\' AND (OwnerId = \''+ownerId+'\' OR OwnerId = \''+ownerId1+'\') AND Record_Type_Name__c=\''+recordTypeName+'\'' +(Test.isRunningTest()?' limit 20':'');
        system.debug('9='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope){
        system.debug('13='+scope);
        list<Opportunity> upgradeGroupList= new list<Opportunity>();
        list<Opportunity> upgradeGroupGradeABList= new list<Opportunity>();
        set<Id> setOppTask = new set<Id>();
        list<Task> tasklist = new list<Task>();
        
        for(Opportunity opp: scope){
            if(opp.Account.Preferred_Language__c == 'SPA'){
                opp.Membership_Upgrade_Group__c='SPA';
            }
            else{
            	opp.Membership_Upgrade_Group__c='NULL';
            }
            upgradeGroupList.add(opp); 
            setOppTask.add(opp.Id);
        }
        if(upgradeGroupList.size()!=0){
            System.debug('262='+upgradeGroupList);
            upgradeGroupList = GenericMatchGroupAssignmentHandler.assignMatchGroup(upgradeGroupList, 'Assigned');
            update upgradeGroupList; 
        }
        for(Opportunity opp : [select id,OwnerId, (select Id from Tasks where Subject= 'Membership Upgrade-Call 1' limit 1) from Opportunity where ID IN : setOppTask]){
            Task objtask = new Task();
            objtask.Subject = 'Membership Upgrade-Call 1';
            objtask.ActivityDate = System.today();
            objtask.WhatId = opp.Id;
            objtask.OwnerId = opp.OwnerId;
            if(opp.Tasks.size() > 0){
                objtask.Id = opp.Tasks[0].Id;
            }
            
            tasklist.add(objtask);
        }
        if(tasklist != null && tasklist.size() > 0)
            upsert tasklist;   
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }    
}