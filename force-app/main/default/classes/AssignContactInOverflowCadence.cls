public class AssignContactInOverflowCadence implements Database.Batchable<sObject>,schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String AffilatedId = Label.Affiliated_Id;
        String Language='ENG';
        String memberShipStatus='Active';
        ID ownerId= [SELECT Id FROM User where name='Salesforce' LIMIT 1].id;
        ID ownerId1= [SELECT Id FROM User where name='Dev Account' LIMIT 1].id;
        Integer querylimits = Integer.valueOf(label.LimitOfAssignContactInOverflowCadence);
        String query = '';
        if(test.isRunningTest()){
            query = 'SELECT Id,Assign_to_Sales_Cadence__c,AccountId, OwnerId,Cadence_Flag__c, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact Where ActionCadenceAssigneeId=null AND AffiliatedId__c = '+AffilatedId+' AND Assign_to_Sales_Cadence__c=FALSE AND Parent_Id_Ext_Db__c = null AND Account.Enrollment_Date__c < N_DAYS_AGO:50 AND (OwnerId=\''+ownerId+'\' OR OwnerId=\''+ownerId1+'\') AND  Membership_Status__c = \''+memberShipStatus+'\' AND Preferred_Language__c = \''+Language+'\''+(Test.isRunningTest()?' limit 3':'');
        }else{
            query = 'SELECT Id,Assign_to_Sales_Cadence__c,AccountId, OwnerId,Cadence_Flag__c, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact Where Marketing_Email_opt_out__c = false and ActionCadenceAssigneeId=null AND AffiliatedId__c = '+AffilatedId+' AND Assign_to_Sales_Cadence__c=FALSE AND Parent_Id_Ext_Db__c = null AND Account.Enrollment_Date__c < N_DAYS_AGO:50 AND (OwnerId=\''+ownerId+'\' OR OwnerId=\''+ownerId1+'\') AND  Membership_Status__c = \''+memberShipStatus+'\' AND Preferred_Language__c = \''+Language+'\' limit  '+querylimits;
            //query = 'SELECT Id,Assign_to_Sales_Cadence__c,AccountId, OwnerId,Cadence_Flag__c, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact Where ActionCadenceAssigneeId=null AND AffiliatedId__c = '+AffilatedId+' AND Assign_to_Sales_Cadence__c=FALSE AND Account.Enrollment_Date__c < N_DAYS_AGO:50 AND  Membership_Status__c = \''+memberShipStatus+'\' AND Preferred_Language__c = \''+Language+'\' limit  '+querylimits;
            
        }
        //String query = 'SELECT Id,Assign_to_Sales_Cadence__c,AccountId, OwnerId,Cadence_Flag__c, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact Where ActionCadenceAssigneeId=null AND AffiliatedId__c = '+AffilatedId+' AND Assign_to_Sales_Cadence__c=FALSE AND Account.Enrollment_Date__c < N_DAYS_AGO:50 AND (OwnerId=\''+ownerId+'\' OR OwnerId=\''+ownerId1+'\') AND  Membership_Status__c = \''+memberShipStatus+'\' AND Preferred_Language__c = \''+Language+'\''+(Test.isRunningTest()?' limit 3':'');
        system.debug('---SELECT Id,Assign_to_Sal--'+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        
        System.debug('13--'+scope.size());
        
        Set<ID> cadenceContactsId=new set<Id>();
        List<Contact> contactToUpdate=new List<Contact>();
        Map<Id,Id> contactIdMapToBypassDuplicate = new Map<Id,Id>();
        List<User> HVSUserList = new List<User>();
        Map<id, List<Contact>> hawaiiRelatedAccountIds= new Map<id, List<Contact>>();
        List<Contact> conList=new list<contact>();
        for(Contact con : scope){
            if(!hawaiiRelatedAccountIds.keyset().contains(con.AccountId)){
                hawaiiRelatedAccountIds.put(con.AccountId,new List<Contact>());
            }
            hawaiiRelatedAccountIds.get(con.AccountId).add(con);
        }
        list<Opportunity> opportunityStageUpdate= new list<opportunity>();
        Set<Id> OpportunityIdSet = new Set<Id>();
        Map<Id,List<Opportunity>> hawaiiRelatedOpportunity=new Map<Id,List<Opportunity>>();
        // B-08601 - Mitul - Added StageName = 'Refused appointment'
        Integer querylimits = Integer.valueOf(label.LimitOfAssignContactInOverflowCadence);
        system.debug('--querylimits--'+querylimits);
        List<Opportunity> oppList = [SELECT id,Name,Account.Enrollment_Date__c,Overflow_Cadence__c,AccountId,ownerid FROM Opportunity where AccountId IN : hawaiiRelatedAccountIds.keySet()  for Update];
        For(Opportunity opp :oppList){ 
            opp.stagename='Unable to Reach';
            // One time run
            /* if(opp.Account.Enrollment_Date__c > system.today() -150  && opp.Account.Enrollment_Date__c < system.today() -50){
opp.Overflow_Cadence__c='Booking1';
system.debug('--opp.Overflow_Cadence__c-'+opp.Overflow_Cadence__c);

}
else if(opp.Account.Enrollment_Date__c > system.today() -300  && opp.Account.Enrollment_Date__c < system.today() -151){
opp.Overflow_Cadence__c='Booking2';
} */
            // B-08601 - Mitul - Added run time
            if(opp.Account.Enrollment_Date__c == system.today()-51){
                opp.Overflow_Cadence__c='Booking1';
            }
            else if(opp.Account.Enrollment_Date__c == system.today()-90){
                opp.Overflow_Cadence__c='Booking2';
            }
            
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
        
        for(Id accId: hawaiiRelatedAccountIds.keySet()) {
            if(hawaiiRelatedOpportunity.containsKey(accId)){
                for(Contact con : hawaiiRelatedAccountIds.get(accId)){
                    // one time run
                    /*if(con.Account.Enrollment_Date__c > system.today() -150  && con.Account.Enrollment_Date__c < system.today() -50){
contactForCadenceBooking1.add(con);   
}
else if(con.Account.Enrollment_Date__c > system.today() -300  && con.Account.Enrollment_Date__c < system.today() -151){
contactForCadenceBooking2.add(con);
}*/
                    // Activate as run time
                    
                    if(con.Account.Enrollment_Date__c == system.today()-51){
                        contactForCadenceBooking1.add(con);     
                    }
                    else if(con.Account.Enrollment_Date__c == system.today()-90){
                        contactForCadenceBooking2.add(con);
                    }
                    
                    /*  else if(con.Account.Enrollment_Date__c < system.today()-64){
contactForCadenceOverflow.add(con); 
}*/
                }
            }
            
        }
        
        System.debug('81--'+contactForCadenceOverflow);
        // For overFlow Booking 1
        System.debug('81--'+contactForCadenceBooking1);
        for(Contact con:contactForCadenceBooking1){
            Id leastContactsUserId;
            Decimal noOfHVSContacts;
            for(Opportunity opp:hawaiiRelatedOpportunity.get(con.Accountid) ){
                
                if(!contactIdMapToBypassDuplicate.containskey(con.Id)){
                    con.Assign_to_Sales_Cadence__c=true;
                    //con.OwnerId = opp.ownerid;
                    con.Cadence_Flag__c=1;
                    contactToUpdate.add(con);
                    cadenceContactsId.add(con.id);  
                    contactIdMapToBypassDuplicate.put(con.Id,con.Id);
                }
            } 
        }
        
        
        // For Booking 2
        System.debug('81--'+contactForCadenceBooking2);
        for(Contact con:contactForCadenceBooking2){
            Id leastContactsUserId;
            Decimal noOfHVSContacts;
            for(Opportunity opp:hawaiiRelatedOpportunity.get(con.Accountid) ){
                if(!contactIdMapToBypassDuplicate.containskey(con.Id)){
                    con.Assign_to_Sales_Cadence__c=true;
                    con.OwnerId = opp.ownerid;
                    con.Cadence_Flag__c=1;
                    contactToUpdate.add(con);
                    cadenceContactsId.add(con.id);     
                    contactIdMapToBypassDuplicate.put(con.Id,con.Id);
                }
            }
        }
        
        if(opportunityStageUpdate.size() > 0 ){
            System.debug('118--'+contactToUpdate);
            System.debug('119--'+opportunityStageUpdate);
            opportunityStageUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(opportunityStageUpdate, 'Assigned');
            update opportunityStageUpdate;
            system.debug('--opportunityStageUpdate--'+opportunityStageUpdate);
        } 
        
        List<Opportunity> opplistnew = [select id,OwnerId,AccountId from Opportunity where Id IN:OpportunityIdSet];
        system.debug('--opplistnew--'+opplistnew);
        system.debug('--opplistnew--'+opplistnew.size());
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
        
        System.enqueueJob(new AssignContactInOverflowCadenceQueueable(cadenceContactsId)); 
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new AssignContactInOverflowCadence(),100); 
    }
}