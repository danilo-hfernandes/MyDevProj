public class TravelOBMemberBatchController implements Database.Batchable<sObject>, Schedulable{
    public void execute(SchedulableContext SC) {
        TravelOBMemberBatchController objBatch = new TravelOBMemberBatchController(); 
        database.executebatch(objBatch, 1);
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        Date oppAssignedDate = date.today().addDays(-30);
        String accountPreferredLanguage = 'ENG';
        String query = 'SELECT Id,Name,accountId,Opp_Assign_Date__c from Opportunity where Account_Affiliate_Id__c = 1002243 AND Record_Type_Name__c = \'Hawaii Collection Membership\' AND (StageName =\'Unable to Reach\' OR StageName = \'Pitched Not Closed\'OR StageName = \'Disconnected Number\'OR StageName = \'Auto Open\') AND Opp_Assign_Date__c =: oppAssignedDate AND CreatedBy.name IN (\'Salesforce\', \'Dev Account\') AND Account.Preferred_Language__c =: accountPreferredLanguage';
        system.debug(query);
        return Database.getQueryLocator(query); 
    }
    public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        system.debug('scope :: '+scope);
        Set<Id> setAccountId = new Set<Id>();
        If(scope.size()>0){
            for(Opportunity opp : scope){
                setAccountId.add(opp.AccountId);
            } 
        }
        set<String> salesCadenceNames = new set<String>{'Travel-OB Member'};
        List<Contact> conlist = [select id,Match_Group_Name__c,Account.name,name,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,Cadence_Flag__c,Account.Dues_Last_Paid_Until__c, Account.Affiliated_Id__c, Account.Preferred_Language__c, Account.Membership_SubType__c from Contact where AccountId IN : setAccountId  AND Is_Main_Contact__c = TRUE];
        List<ActionCadenceTracker> actionCadenceTrackerRunning = new List<ActionCadenceTracker>();
        Map<String, set<Id>> MapCadenceNameVsContactIds = new Map<String,set<Id>>();
        Set<Id> contactsToCheck = new Set<Id>();
        Map<Id,String> contactCurrentMatchGroupRunning = new Map<Id,String>();
        List<Contact> updateContactList = new List<Contact>();
        if(conlist != null && conlist.size() > 0){
            Map<Id,Contact> contactIdMap = new Map<Id,Contact>(conlist);
            actionCadenceTrackerRunning = [select id, TargetId, SystemModstamp, ActionCadence.name, Target.Name, State, CompletionReason, LastCompletedStep.CompletedBy.Name from ActionCadenceTracker WHERE ActionCadence.name IN : salesCadenceNames AND State = 'Running' AND TargetId IN : contactIdMap.keyset() AND ActionCadence.name = 'Travel-OB Member'];
            if(actionCadenceTrackerRunning != null && actionCadenceTrackerRunning.size()>0)
            {
                for(ActionCadenceTracker act : actionCadenceTrackerRunning)
                {
                    contactCurrentMatchGroupRunning.put(act.TargetId,act.ActionCadence.name);
                }
            }
            for(Contact objcon : conlist){
                String salesCadencename = 'Travel-OB Member';
                If(!contactCurrentMatchGroupRunning.containsKey(objcon.Id)){
                    if(!MapCadenceNameVsContactIds.containsKey(salesCadencename)){
                        MapCadenceNameVsContactIds.put(salesCadencename,new set<Id>{objcon.Id});
                    }
                    else{    
                        MapCadenceNameVsContactIds.get(salesCadencename).add(objcon.Id);
                    }
                    //objcon.Match_Group_Name__c = 'Travel-OB Member';
                    //objcon.leadassist__Use_Round_Robin__c = 'TRUE';
                    objcon.Assign_to_Sales_Cadence__c=true;
                    objcon.Cadence_Flag__c=1;
                    updateContactList.add(objcon);
                }
            }
            If(updateContactList.size()>0){
                updateContactList = GenericMatchGroupAssignmentHandler.assignMatchGroup(updateContactList, 'Travel-OB Member');
                update updateContactList;
            }
            if(!test.isRunningTest()){
                for(String key : MapCadenceNameVsContactIds.keyset()){
                   System.enqueueJob(new GenericAssignToSalesCadence(MapCadenceNameVsContactIds.get(key), key)); 
                }
            }
            
        }
    }
    public void finish(Database.BatchableContext BC){
    }   

}