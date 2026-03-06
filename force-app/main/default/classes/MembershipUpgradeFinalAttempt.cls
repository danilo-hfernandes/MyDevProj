public class MembershipUpgradeFinalAttempt implements Database.Batchable<sObject>,schedulable{
	
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> oppStageList = new List<String>{'Attempting to Contact 1', 'Attempting to Contact 2', 'Attempting to Contact 3', 'Attempting to Contact 4', 'Unable to Reach'};
		List<RecordType> oppRecordTypeList = [select id from RecordType where SobjectType = 'Opportunity' and (Name= 'MTRC Membership Upgrade' or  Name = 'MTRC Retail') limit 4];// or Name = 'Hawaii Collection Membership' or Name = 'SFX Membership'
		set<Id> recordTypeIds = new set<Id>();
        List<String> oppIds = System.Label.MembershipUpgradeFinalAttempt.split(',');
		for(RecordType objrecordType : oppRecordTypeList){
			recordTypeIds.add(objrecordType.Id);
		}
        //String query = 'SELECT id,AccountId,Record_Type_Name__c from Opportunity where StageName IN : oppStageList and Opp_Assign_Date__c <= N_DAYS_AGO :40 and Opp_Assign_Date__c >= N_DAYS_AGO: 50 and RecordTypeId IN: recordTypeIds and AccountId != null and Account.Preferred_Language__c = \'ENG\' and Account.Membership_Status__c = \'Active\' and LastActivityDate <= N_DAYS_AGO:10';
        String query = 'SELECT id,AccountId,Record_Type_Name__c, StageName from Opportunity where StageName = \'Auto Open\' and RecordTypeId IN: recordTypeIds and AccountId != null and Account.Preferred_Language__c = \'ENG\' and Account.Membership_Status__c = \'Active\'';
        if(!Test.isRunningTest() && oppIds != null && oppIds.size() > 1) {
            query += ' and Id IN: oppIds';
        }
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope){
        System.debug('13--'+scope);
		set<Id> mtrcMembershipAccountIds = new set<Id>();
		set<Id> hawaiiCollectionAccountIds = new set<Id>();
		set<Id> sfxmembershipAccountIds = new set<Id>();
		set<Id> mtrcRetailAccountIds = new set<Id>();
        List<Id> targetIds = new List<Id>();
        List<Opportunity> updateOppList = new List<Opportunity>();
		for(Opportunity opp : scope){
			if(opp.Record_Type_Name__c == 'MTRC Membership Upgrade'){
				mtrcMembershipAccountIds.add(opp.AccountId);
			}
			else if(opp.Record_Type_Name__c == 'Hawaii Collection Membership'){
				hawaiiCollectionAccountIds.add(opp.AccountId);
			}
			else if(opp.Record_Type_Name__c == 'MTRC Retail'){
				mtrcRetailAccountIds.add(opp.AccountId);
			}
			else if(opp.Record_Type_Name__c == 'SFX Membership'){
				sfxmembershipAccountIds.add(opp.AccountId);
			}
            if(opp.StageName != 'Auto Open'){
				opp.StageName = 'Auto Open';
                updateOppList.add(opp);                
            } 
		}
		if(mtrcMembershipAccountIds != null && mtrcMembershipAccountIds.size() > 0){
            targetIds = new List<Id>();
            String cadenceName = 'Membership Upgrade-Final Attempt MTRC';
            targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList(cadenceName);
			List<Contact> listContact = [select id,Assign_to_Sales_Cadence__c,Cadence_Flag__c,Match_Group_Name__c,AccountId from Contact where ID NOT IN : targetIds and AccountId IN : mtrcMembershipAccountIds and Marketing_Email_opt_out__c = false order by CreatedDate DESC];
			system.debug('>>>>>listContact>>>>'+listContact);
			if(listContact != null && listContact.size() > 0){
				Set<ID> cadenceContactsId=new set<Id>();
				List<Contact> contactToUpdate=new List<Contact>();
				List<Contact> conList=new list<contact>();
				Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
				for(Contact con : listContact)
				{
					if(!contactIdSetMap.containskey(con.Id)){
						con.Assign_to_Sales_Cadence__c=true;
						con.Cadence_Flag__c=1;
						//con.Match_Group_Name__c ='Membership Upgrade-Final Attempt MTRC';
						contactToUpdate.add(con);
						cadenceContactsId.add(con.id);
						contactIdSetMap.put(con.id,con.id);
					}
				}        
				if(contactToUpdate.size() > 0 ){
					System.debug('118--'+contactToUpdate);
                    contactToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(contactToUpdate, 'Membership Upgrade-Final Attempt MTRC');
					update contactToUpdate;
				} 
				System.enqueueJob(new MembershipUpgradeSalesCadenceQueueable(cadenceContactsId, cadenceName)); 
			}
		}
		/*if(hawaiiCollectionAccountIds != null && hawaiiCollectionAccountIds.size() > 0){
			List<Contact> listContact = [select id,Assign_to_Sales_Cadence__c,Cadence_Flag__c,Match_Group_Name__c,AccountId from Contact where AccountId IN : hawaiiCollectionAccountIds and Assign_to_Sales_Cadence__c=false order by CreatedDate DESC];
			system.debug('>>>>>listContact>>>>'+listContact);
			if(listContact != null && listContact.size() > 0){
				Set<ID> cadenceContactsId=new set<Id>();
				String cadenceName = 'Membership Upgrade-Final Attempt HC';
				List<Contact> contactToUpdate=new List<Contact>();
				List<Contact> conList=new list<contact>();
				Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
				for(Contact con : listContact)
				{
					if(!contactIdSetMap.containskey(con.Id)){
						con.leadassist__Use_Round_Robin__c='TRUE';
						con.Assign_to_Sales_Cadence__c=true;
						con.Cadence_Flag__c=1;
						con.Match_Group_Name__c ='Membership Upgrade-Final Attempt HC';
						contactToUpdate.add(con);
						cadenceContactsId.add(con.id);
						contactIdSetMap.put(con.id,con.id);
					}
				}        
				if(contactToUpdate.size() > 0 ){
					System.debug('118--'+contactToUpdate);
					update contactToUpdate;
				} 
				System.enqueueJob(new MembershipUpgradeSalesCadenceQueueable(cadenceContactsId, cadenceName)); 
			}
		}*/
		if(mtrcRetailAccountIds != null && mtrcRetailAccountIds.size() > 0){
            targetIds = new List<Id>();
            String cadenceName = 'Membership Upgrade-Final Attempt MTRC Retail';
            targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList(cadenceName);
			List<Contact> listContact = [select id,Assign_to_Sales_Cadence__c,Cadence_Flag__c,Match_Group_Name__c,AccountId from Contact where ID NOT IN : targetIds and AccountId IN : mtrcRetailAccountIds and Marketing_Email_opt_out__c = false order by CreatedDate DESC];
			system.debug('>>>>>listContact>>>>'+listContact);
			if(listContact != null && listContact.size() > 0){
				Set<ID> cadenceContactsId=new set<Id>();
				List<Contact> contactToUpdate=new List<Contact>();
				List<Contact> conList=new list<contact>();
				Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
				for(Contact con : listContact)
				{
					if(!contactIdSetMap.containskey(con.Id)){
						con.Assign_to_Sales_Cadence__c=true;
						con.Cadence_Flag__c=1;
						//con.Match_Group_Name__c ='Membership Upgrade-Final Attempt MTRC Retail';
						contactToUpdate.add(con);
						cadenceContactsId.add(con.id);
						contactIdSetMap.put(con.id,con.id);
					}
				}        
				if(contactToUpdate.size() > 0 ){
					System.debug('118--'+contactToUpdate);
                    contactToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(contactToUpdate, 'Membership Upgrade-Final Attempt MTRC Retail');
					update contactToUpdate;
				} 
				System.enqueueJob(new MembershipUpgradeSalesCadenceQueueable(cadenceContactsId, cadenceName)); 
			}
		}
		/*if(sfxmembershipAccountIds != null && sfxmembershipAccountIds.size() > 0){
			List<Contact> listContact = [select id,Assign_to_Sales_Cadence__c,Cadence_Flag__c,Match_Group_Name__c,AccountId from Contact where AccountId IN : sfxmembershipAccountIds and Assign_to_Sales_Cadence__c=false order by CreatedDate DESC];
			system.debug('>>>>>listContact>>>>'+listContact);
			if(listContact != null && listContact.size() > 0){
				Set<ID> cadenceContactsId=new set<Id>();
				String cadenceName = 'Membership Upgrade-Final Attempt SFX';
				List<Contact> contactToUpdate=new List<Contact>();
				List<Contact> conList=new list<contact>();
				Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
				for(Contact con : listContact)
				{
					if(!contactIdSetMap.containskey(con.Id)){
						con.Assign_to_Sales_Cadence__c=true;
						con.Cadence_Flag__c=1;
						con.Match_Group_Name__c ='Membership Upgrade-Final Attempt SFX';
						contactToUpdate.add(con);
						cadenceContactsId.add(con.id);
						contactIdSetMap.put(con.id,con.id);
					}
				}        
				if(contactToUpdate.size() > 0 ){
					System.debug('118--'+contactToUpdate);
					update contactToUpdate;
				} 
				System.enqueueJob(new MembershipUpgradeSalesCadenceQueueable(cadenceContactsId, cadenceName)); 
			}
		}*/
        if(updateOppList != null && updateOppList.size() > 0){
            update updateOppList;
        }
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new MembershipUpgradeFinalAttempt(),1);
    }
}