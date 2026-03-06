global class TravelSalesOpportunityBatchController implements Database.Batchable<sObject>, Schedulable {
	
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id travelRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
        String query = 'SELECT Id, AccountId, Member_Number__c FROM Opportunity WHERE RecordTypeId=\''+ travelRecordTypeId + '\' and Name=\''+ 'Travel Sales Opp' + '\' ORDER BY Member_Number__c DESC';
     	system.debug('query -->>' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope) {
        try {
            Set<String> setMemberNumber = new Set<String>();
            Map<String, String> mapMemberNumberToAccountId = new map<String,String>();
            List<Opportunity> oppList = new List<Opportunity>();

            for(Opportunity opp : scope)
            {
                if(opp.AccountId == null && opp.Member_Number__c != null){
                    setMemberNumber.add(opp.Member_Number__c); 
                    setMemberNumber.add(opp.Member_Number__c.toUpperCase()); 
                }
            }
            
            system.debug('setMemberNumber -->>' + setMemberNumber);
            
            if(setMemberNumber != null && setMemberNumber.size() > 0){
                //2024-01-03 - HSIMU2-520 Ghost Travel Opportunities
                for(Contact objcon : [select id,Member_Number__c,AccountId from Contact where AccountId != null AND Member_Number__c IN: setMemberNumber]){
                    mapMemberNumberToAccountId.put(objcon.Member_Number__c, objcon.AccountId);
                    mapMemberNumberToAccountId.put(objcon.Member_Number__c.toUpperCase(), objcon.AccountId);
                    Boolean result1 = setMemberNumber.remove(objcon.Member_Number__c);
                    Boolean result2 = setMemberNumber.remove(objcon.Member_Number__c.toUpperCase());
                }
                //2024-01-03 - HSIMU2-520 Ghost Travel Opportunities
                if(setMemberNumber != null && setMemberNumber.size() > 0 && !setMemberNumber.isEmpty()){
                    for(Account objacc : [select id,Member_Number__c from Account where Member_Number__c IN: setMemberNumber]){
                        mapMemberNumberToAccountId.put(objacc.Member_Number__c, objacc.Id);
                        mapMemberNumberToAccountId.put(objacc.Member_Number__c.toUpperCase(), objacc.Id);
                    }
                }
                for(Opportunity opp : scope){
                    //2024-01-03 - HSIMU2-520 Ghost Travel Opportunities
                    if(mapMemberNumberToAccountId.get(opp.Member_Number__c.toUpperCase()) != null){
                        opp.AccountId = mapMemberNumberToAccountId.get(opp.Member_Number__c.toUpperCase());
                        oppList.add(opp);
                    }
                }
            }
                   
            system.debug('oppList -->>' + oppList);
            if(oppList.size()>0) {
                update oppList;
            }
             
        } catch(Exception e) {
            system.debug('Exception ----> ' + e);
        }
    }
    
	global void execute(SchedulableContext sc) {
        TravelSalesOpportunityBatchController batch = new TravelSalesOpportunityBatchController(); 
        Database.executebatch(batch,1);
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('*************Opportunity Linked with Account*************');
    }
}