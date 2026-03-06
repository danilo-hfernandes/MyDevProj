public class AssignContactInOverflowCadenceTry implements Database.Batchable<sObject>,schedulable{

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String AffilatedId = Label.Affiliated_Id;
        String Language='ENG';
        String memberShipStatus='Active';
        ID ownerId= [SELECT Id FROM User where name='Salesforce' LIMIT 1].id;
        ID ownerId1= [SELECT Id FROM User where name='Dev Account' LIMIT 1].id;
        Integer querylimits = Integer.valueOf(label.LimitOfAssignContactInOverflowCadence);
        String query = '';
        if(test.isRunningTest()){
            query = 'SELECT Id,Assign_to_Sales_Cadence__c,AccountId, OwnerId,Cadence_Flag__c, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact Where ActionCadenceAssigneeId=null AND AffiliatedId__c = '+AffilatedId+' AND Assign_to_Sales_Cadence__c=FALSE AND Account.Enrollment_Date__c < N_DAYS_AGO:50 AND (OwnerId=\''+ownerId+'\' OR OwnerId=\''+ownerId1+'\') AND  Membership_Status__c = \''+memberShipStatus+'\' AND Preferred_Language__c = \''+Language+'\''+(Test.isRunningTest()?' limit 3':'');
        }else{
            query = 'SELECT Id,Assign_to_Sales_Cadence__c,AccountId, OwnerId,Cadence_Flag__c, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact Where ActionCadenceAssigneeId=null AND AffiliatedId__c = '+AffilatedId+' AND Assign_to_Sales_Cadence__c=FALSE AND Account.Enrollment_Date__c < N_DAYS_AGO:5 AND  Membership_Status__c = \''+memberShipStatus+'\' AND Preferred_Language__c = \''+Language+'\' limit  '+querylimits;
            
        }
        system.debug('---SELECT Id,Assign_to_Sal--'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
    	 
        System.debug('13--'+scope.size());
        Set<ID> cadenceContactsId=new set<Id>();
        List<Contact> contactToUpdate=new List<Contact>();
        List<User> HVSUserList = new List<User>();
        
        Map<id, List<Contact>> hawaiiRelatedAccountIds= new Map<id, List<Contact>>();
        List<Contact> conList=new list<contact>();
        for(Contact con : scope){
            system.debug('---con---33'+con);
            if(!hawaiiRelatedAccountIds.keyset().contains(con.AccountId)){
                hawaiiRelatedAccountIds.put(con.AccountId,new List<Contact>());
            }
            hawaiiRelatedAccountIds.get(con.AccountId).add(con);
             system.debug('---hawaiiRelatedAccountIds---39'+hawaiiRelatedAccountIds);
        }
        
        list<Opportunity> opportunityStageUpdate= new list<opportunity>();
        Set<Id> OpportunityIdSet = new Set<Id>();
        
        Map<Id,List<Opportunity>> hawaiiRelatedOpportunity=new Map<Id,List<Opportunity>>();
         Integer querylimits = Integer.valueOf(label.LimitOfAssignContactInOverflowCadence);
        system.debug('--querylimits--'+querylimits);
        List<Opportunity> oppList = [SELECT id,Name,Overflow_Cadence__c,AccountId,ownerid FROM Opportunity where AccountId IN : hawaiiRelatedAccountIds.keySet()  for Update];
        For(Opportunity opp :oppList){
            opp.stagename='Unable to Reach';
            opp.leadassist__Use_Round_Robin__c='TRUE';
            opp.Overflow_Cadence__c='Booking1';
            system.debug('--opp.Overflow_Cadence__c-'+opp.Overflow_Cadence__c);
            opportunityStageUpdate.add(opp);
            OpportunityIdSet.add(opp.Id);
            if(!hawaiiRelatedOpportunity.keyset().contains(opp.AccountId)){
                hawaiiRelatedOpportunity.put(opp.AccountId,new List<Opportunity>());
            }
             hawaiiRelatedOpportunity.get(opp.AccountId).add(opp);
            
        }
        
        list<contact> contactForCadenceOverflow =new list<contact>();
        list<contact> contactForCadenceBooking1 =new list<contact>();
        list<contact> contactForCadenceBooking2 =new list<contact>();
        system.debug('--hawaiiRelatedOpportunity--'+hawaiiRelatedOpportunity);
        system.debug('--hawaiiRelatedOpportunity--'+hawaiiRelatedOpportunity.size());
        for(Id accId: hawaiiRelatedAccountIds.keySet()) {
            if(hawaiiRelatedOpportunity.containsKey(accId)){
                for(Contact con : hawaiiRelatedAccountIds.get(accId)){
                    contactForCadenceBooking1.add(con);    
                }
            }
        }
        System.debug('75--'+contactForCadenceOverflow);
        list<leadassist__MatchGroup__c> matchGroupIdBooking1= new list<leadassist__MatchGroup__c>();
        matchGroupIdBooking1= [SELECT Name, Id FROM leadassist__MatchGroup__c where name='HCMU-High Velocity 51 Days'];
        List<String> HVSUsersIdBooking1 =new List<String>();
        
        list<leadassist__Assignee__c> ssrUsersBooking1= new list<leadassist__Assignee__c>();
        ssrUsersBooking1=[SELECT Id, leadassist__MatchGroup__c,leadassist__User__c  FROM leadassist__Assignee__c where leadassist__MatchGroup__c=:matchGroupIdBooking1[0].id AND leadassist__Active__c=true];
        
        for(leadassist__Assignee__c AssignedUsers: ssrUsersBooking1)
        {
            HVSUsersIdBooking1.add(AssignedUsers.leadassist__User__c);
        }
        
        Map<Id, User> HVSUserIdMapBooking1 = new Map<Id, User>([SELECT Id, name,Assigned_Contacts__c FROM User WHERE Id IN:HVSUsersIdBooking1 AND IsActive = true]);
        List<User> HVSUserListBooking1 = new List<User>();
        System.debug('36--'+HVSUserIdMapBooking1);
        System.debug('81--'+contactForCadenceBooking1);
        Map<Id,Id> contactIdMap = new Map<Id,Id>();
        for(Contact con:contactForCadenceBooking1){
            Id leastContactsUserId;
            Decimal noOfHVSContacts;
            for(Opportunity opp:hawaiiRelatedOpportunity.get(con.Accountid) ){
                system.debug('--opp--99'+opp);
                system.debug('--contactIdMap--99'+contactIdMap);
                if(!contactIdMap.containskey(con.Id)){
                    system.debug('--opp--99'+opp);
                    con.Assign_to_Sales_Cadence__c=true;
                    con.Cadence_Flag__c=1;
                    contactToUpdate.add(con);
                    cadenceContactsId.add(con.id);  
                    contactIdMap.put(con.id,con.id);
                }
            }
        }
        // For Booking 2
        list<leadassist__MatchGroup__c> matchGroupIdBooking2= new list<leadassist__MatchGroup__c>();
        matchGroupIdBooking2= [SELECT Name, Id FROM leadassist__MatchGroup__c where name='HCMU-High Velocity 90 Days'];
        List<String> HVSUsersIdBooking2 =new List<String>();
        list<leadassist__Assignee__c> ssrUsersBooking2= new list<leadassist__Assignee__c>();
        ssrUsersBooking2=[SELECT Id, leadassist__MatchGroup__c,leadassist__User__c  FROM leadassist__Assignee__c where leadassist__MatchGroup__c=:matchGroupIdBooking2[0].id AND leadassist__Active__c=true];
        for(leadassist__Assignee__c AssignedUsers: ssrUsersBooking2)
        {
            HVSUsersIdBooking2.add(AssignedUsers.leadassist__User__c);
        }
        
        Map<Id, User> HVSUserIdMapBooking2 = new Map<Id, User>([SELECT Id, name,Assigned_Contacts__c FROM User WHERE Id IN:HVSUsersIdBooking2 AND IsActive = true]);
        List<User> HVSUserListBooking2 = new List<User>();
        System.debug('36--'+HVSUserIdMapBooking2);
        System.debug('81--'+contactForCadenceBooking2);
        Map<Id,Id> contactIdMap1 = new Map<Id,Id>();
        for(Contact con:contactForCadenceBooking2){
            Id leastContactsUserId;
            Decimal noOfHVSContacts;
            for(Opportunity opp:hawaiiRelatedOpportunity.get(con.Accountid) ){
                system.debug('--opp--99'+opp);
                system.debug('--contactIdMap--99'+contactIdMap);
                if(!contactIdMap1.containskey(con.Id)){
                    con.Assign_to_Sales_Cadence__c=true;
                    //con.Custom_Owner__c = con.Owner;
                    // Create custom field under Contact to assign Old owner value.
                    con.OwnerId = opp.ownerid;
                     con.Cadence_Flag__c=1;
                    contactToUpdate.add(con);
                    cadenceContactsId.add(con.id);  
                    contactIdMap1.put(con.id,con.id);
                    system.debug('--contactIdMap--99'+contactIdMap);
                }
            }
        }
        
        if(opportunityStageUpdate.size() > 0 ){
            System.debug('118--'+contactToUpdate);
            System.debug('119--'+opportunityStageUpdate);
            //update contactToUpdate;
            update opportunityStageUpdate;
            system.debug('--opportunityStageUpdate--'+opportunityStageUpdate);
        } 
        
        List<Opportunity> opplistnew = [select id,OwnerId,AccountId from Opportunity where Id IN:OpportunityIdSet];
        Map<Id,Id> mapofAccountIdOwnerId = new Map<Id,Id>();
        for(Opportunity opp : opplistnew){
            mapofAccountIdOwnerId.put(opp.AccountId,opp.OwnerId);
        }
        List<Contact> contactupdate = new List<Contact>();
        for(Contact con : contactToUpdate){
            if(mapofAccountIdOwnerId.containskey(con.AccountId)){
                con.OwnerId = mapofAccountIdOwnerId.get(con.AccountId);
                system.debug('----con---'+con);
                contactupdate.add(con);
            }
        }
        update contactupdate;
        System.enqueueJob(new AssignContactInOverflowCadenceQueueaTRY(contactToUpdate)); 
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new AssignContactInOverflowCadence(),1);
    }
}