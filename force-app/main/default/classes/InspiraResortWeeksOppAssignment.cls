public class InspiraResortWeeksOppAssignment implements Database.Batchable<sObject>, Schedulable{ 

    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> recordTypeNames= new List<String>{'Travel'}; 
        Date enrollment15DaysAgo = System.today().addDays(-15);
        
        String query = 'SELECT Id,AccountId,Account.Preferred_Language__c,name,Match_Group_Name__c,leadassist__Use_Round_Robin__c,ownerid FROM Opportunity Where Account.Affiliated_Id__c = 1002452 and StageName = \'New\' AND Record_Type_Name__c IN :recordTypeNames and Match_Group_Name__c = null';
		//filter for test:
		//query = query + ' and Id = \'006O100000GUmQzIAL\' ' ;
		//query = 'SELECT Id,AccountId,Account.Preferred_Language__c,name,Match_Group_Name__c,leadassist__Use_Round_Robin__c,ownerid FROM Opportunity Where ';
		//query = query + ' Id = \'006O100000GXUR8IAP\' ' ;
		
		//        String query = 'SELECT Id,AccountId,Account.Preferred_Language__c,name,Match_Group_Name__c,leadassist__Use_Round_Robin__c,ownerid FROM Opportunity Where Account.Affiliated_Id__c = 1002452 and Owner.Name = \'Dev Account\' and StageName = \'New\' AND Record_Type_Name__c IN :recordTypeNames and Account.Enrollment_Date__c = :enrollment15DaysAgo';
        system.debug('Query>>>'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        system.debug('Data >>>>'+scope);
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        set<Id> setOppIds = new set<Id>();
        map<Id, Id> mapOppIdToContactId = new map<Id, Id>(); 
        
        for(Opportunity opp: scope){
            //opp.Match_Group_Name__c = 'Travel Sales-Inspira Resort Weeks';
            //opp.leadassist__Use_Round_Robin__c = 'TRUE';
            //oppToUpdate.add(opp);
            setOppIds.add(opp.Id);
        }
        oppToUpdate = GenericMatchGroupAssignmentHandler.assignMatchGroup(scope, 'Travel Sales-Inspira Resort Weeks');
        if(oppToUpdate.size() > 0 ){
            System.debug('oppToUpdate--'+oppToUpdate);
            update oppToUpdate;
        } 
        
        //Cadence
  		Set<Id> contactsToAssignCadence = new Set<Id>{[SELECT ContactId FROM OpportunityContactRole WHERE OpportunityId IN :setOppIds].ContactId};
        System.debug('contactsToAssignCadence--'+contactsToAssignCadence);
        if(!Test.isRunningTest()){
        	System.enqueueJob(new GenericAssignToSalesCadence(contactsToAssignCadence, 'Travel Sales-Inspira Resort Weeks')); 
		}  
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }  
    public void execute(SchedulableContext SC) {
        database.executebatch(new InspiraResortWeeksOppAssignment(),100);
    }


}