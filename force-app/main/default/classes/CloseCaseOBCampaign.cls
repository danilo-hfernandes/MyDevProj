global class CloseCaseOBCampaign implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String rec = Label.Case_Activation_RecordTypeId;
        system.debug('recor== ' + rec);
        String query = 'SELECT Id,AccountId,Status FROM Case Where RecordTypeId =:rec AND Status = \'New\' ';
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<Case> scope)
    {
         Set<Id> AccountsId = New Set<Id>();
        List<Opportunity> OppRecord = New List<Opportunity>();
        Set<Id> AccoundIdtoCloseCase = New Set<Id>();
        for(Case cs : scope){
            AccountsId.add(cs.AccountId);
        }
        if(AccountsId.size() > 0 && AccountsId != Null){
            OppRecord = [Select Id,Reservation_Status__c,AccountId from Opportunity where AccountId IN:AccountsId];
            
            for(Opportunity opps : OppRecord){
                if(opps.Reservation_Status__c != Null){
                    AccoundIdtoCloseCase.add(opps.AccountId);
                }
            }
        }
        List<Case> updateCase = New List<Case>();
        if(AccoundIdtoCloseCase.size() > 0 && AccoundIdtoCloseCase != Null){
            for(Case cs : scope){
                if(AccoundIdtoCloseCase.contains(cs.AccountId)){
                    cs.Status = 'Closed';
                    updateCase.add(cs);
                }
            }
        }
        if(updateCase.size() > 0 && updateCase != Null){
            update updateCase;
        }
         
    }  
    global void finish(Database.BatchableContext BC)
    {
    }
}