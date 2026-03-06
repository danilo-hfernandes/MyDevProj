public class TravelSalesReengagementBatchController implements Database.Batchable<sObject>, Schedulable{
    public set<Id> setAccount = new set<Id>();
    public List<Id> targetIds = new List<Id>();
    public void execute(SchedulableContext SC) {
        TravelSalesReengagementBatchController objBatch = new TravelSalesReengagementBatchController(); 
        database.executebatch(objBatch, 1);
    }
    public TravelSalesReengagementBatchController(){
        targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList('Travel Sales-Reengagement');
    }
    public Database.QueryLocator start(Database.BatchableContext BC){

        system.debug('QueryLocator start');

        String bulkQuery = System.label.TravelSalesReengagement;
        List<User> userIdList = [select id from User where Name = 'Salesforce' or Name = 'Dev Account' or Name = 'Platform Integration User'];
        String travelRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Travel').getRecordTypeId();
        Date past120Days = Date.today().addDays(-120);
        Date past30Days = Date.today().addDays(-30);
        String query ='';
        if(bulkQuery == 'True'){
	        system.debug('bulkQuery True');
//            query = 'select id,AccountId from Opportunity where StageName= \'Closed Lost\' and CreatedById IN :userIdList and RecordTypeId =: travelRecordTypeId and CloseDate <=:past30Days and CloseDate >=: past120Days ' ; // TGR-542
            query = 'select id,AccountId from Opportunity where StageName= \'Closed Lost\' and CreatedById IN :userIdList and RecordTypeId =: travelRecordTypeId and CloseDate <=:past30Days and CloseDate >=: past120Days  and Account_Affiliate_Id__c not in (1002275, 1002277)' ; // TGR-542
        }
        else{
	        system.debug('bulkQuery False');
//            query = 'select id,AccountId from Opportunity where StageName= \'Closed Lost\' and CreatedById IN :userIdList and RecordTypeId =: travelRecordTypeId and CloseDate =:past30Days ';  // TGR-542
            query = 'select id,AccountId from Opportunity where StageName= \'Closed Lost\' and CreatedById IN :userIdList and RecordTypeId =: travelRecordTypeId and CloseDate =:past30Days and Account_Affiliate_Id__c not in (1002275, 1002277)';  // TGR-542
        }
        //for test:
        //query = query + ' and id in (\'0064z000028zQIsAAM\',\'0064z000029DQLGAA4\') ';
        
        system.debug('past30Days '+past30Days);
        system.debug('past120Days '+past120Days);
        system.debug('userIdList '+userIdList);
        system.debug('travelRecordTypeId '+travelRecordTypeId);
        
        system.debug(query);
        return Database.getQueryLocator(query); 
    }
    public void execute(Database.BatchableContext BC, List<Opportunity> scope){
        String travelRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Travel').getRecordTypeId();
        List<Contact> updateContactList = new List<Contact>();
        Map<String, String> mapAccountIdVsOppId = new Map<String, String>();
        Map<String, String> mapAccountIdVsOppIdTobeUpdated = new Map<String, String>();
        set<Id> cadenceContactIds = new set<Id>();
        set<Id> setAccountId = new set<Id>();
        for(Opportunity opp : scope){
            setAccountId.add(opp.AccountId);
            mapAccountIdVsOppIdTobeUpdated.put(opp.AccountId,opp.Id);
        }
        List<Account> accList = [select id, (select id from Opportunities where RecordTypeId =: travelRecordTypeId  order by CreatedDate DESC limit 1) from Account where ID IN : setAccountId and Marketing_Email_opt_out__c= false];
        for(Account acc : accList){
            
            mapAccountIdVsOppId.put(acc.Id, acc.Opportunities[0].Id);            
        }
        System.debug('>>mapAccountIdVsOppIdTobeUpdated>>'+mapAccountIdVsOppIdTobeUpdated);
        System.debug('>>mapAccountIdVsOppId>>'+mapAccountIdVsOppId);
        List<Contact> conlist = [select id,Name,AccountId,Account.Name, Match_Group_Name__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,Cadence_Flag__c from Contact where ID NOT IN : targetIds and AccountId IN : setAccountId and Marketing_Email_opt_out__c = false];
        if(conlist != null && conlist.size() > 0){
            for(Contact objcon : conlist){
                if(mapAccountIdVsOppIdTobeUpdated.get(objcon.AccountId) == mapAccountIdVsOppId.get(objcon.AccountId) && objcon.Name == objcon.Account.Name){
                    //objcon.Match_Group_Name__c = 'Travel Sales-Reengagement';
                    //objcon.leadassist__Use_Round_Robin__c = 'TRUE';
                    objcon.Assign_to_Sales_Cadence__c=true;
                    objcon.Cadence_Flag__c=1;
                    updateContactList.add(objcon);
                    cadenceContactIds.add(objcon.Id);
                }
                
            }
            if(updateContactList != null && updateContactList.size() > 0){
                updateContactList = GenericMatchGroupAssignmentHandler.assignMatchGroup(updateContactList, 'Travel Sales-Reengagement');
                update updateContactList;
            }
			if(cadenceContactIds != null && cadenceContactIds.size() > 0)            
            	System.enqueueJob(new GenericAssignToSalesCadence(cadenceContactIds, 'Travel Sales-Reengagement')); 
        }
    }
    public void finish(Database.BatchableContext BC){
    }
}