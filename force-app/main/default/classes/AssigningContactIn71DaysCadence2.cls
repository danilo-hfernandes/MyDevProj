public class AssigningContactIn71DaysCadence2 implements Database.Batchable<sObject>,schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('3===');
        String AffilatedId = Label.Affiliated_Id;
        String Language='ENG';
        String memberShipStatus='Active';
        ID ownerId= [SELECT Id FROM User where name='Salesforce' LIMIT 1].id;
        String query = 'SELECT Id,Assign_to_Sales_Cadence__c,AccountId, OwnerId, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact Where Marketing_Email_opt_out__c = false and ActionCadenceAssigneeId=null AND AffiliatedId__c = '+AffilatedId+' AND Assign_to_Sales_Cadence__c=FALSE AND Account.Enrollment_Date__c < N_DAYS_AGO:70 AND OwnerId = \''+ownerId+'\'AND Account.ownerId = \''+ownerId+'\'AND Membership_Status__c = \''+memberShipStatus+'\' AND Preferred_Language__c = \''+Language+'\'';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        
        system.debug('13==='+scope);
        Set<ID> cadenceContactsId=new set<Id>();
        List<String> HVSUsersId=new List<String>();
        List<Contact> contactToUpdate=new List<Contact>();
        
        //Fetching Permission set id
        List<PermissionSet> outlookPermissionSet= new List<PermissionSet>();
        outlookPermissionSet=[Select id from PermissionSet where name='Membership_Upgrade_Booker_with_Office_365_Setup' limit 1];
        
        Id outlookPermissionSetId= outlookPermissionSet[0].id;
        List<PermissionSetAssignment> HVSUsers= new List<PermissionSetAssignment>();
        
        // Fetching HVS users
        HVSUsers=[SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId=:outlookPermissionSetId];
        for(PermissionSetAssignment AssignedUsers: HVSUsers)
        {
            HVSUsersId.add(AssignedUsers.AssigneeId);
        }
        
        Map<Id, User> HVSUserIdMap = new Map<Id, User>([SELECT Id, Assigned_Contacts__c FROM User WHERE Id IN:HVSUsersId AND IsActive = true]);
        List<User> HVSUserList = new List<User>();
        
        Map<id, List<Contact>> hawaiiRelatedAccountIds= new Map<id, List<Contact>>();
        List<Contact> conList=new list<contact>();
        for(Contact con : scope)
        {
            
            if(!hawaiiRelatedAccountIds.keyset().contains(con.AccountId)){
                hawaiiRelatedAccountIds.put(con.AccountId,new List<Contact>());
            }
            hawaiiRelatedAccountIds.get(con.AccountId).add(con);
            
            
        }
        system.debug('48=='+hawaiiRelatedAccountIds);
        
        Map<Id,List<Opportunity>> hawaiiRelatedOpportunity=new Map<Id,List<Opportunity>>();
        For(Account acc :[SELECT id,(SELECT id,Name FROM Opportunities where StageName = 'Closed Won' AND Record_Type_Name__c='Hawaii Collection Membership') FROM Account where Id IN : hawaiiRelatedAccountIds.keySet()]){
            List<Opportunity> oppList = acc.Opportunities.size()>0 ? acc.Opportunities : null;
            if(oppList != null) {
                system.debug('49=='+opplist);
                hawaiiRelatedOpportunity.put(acc.Id,oppList);
            }
        }
        
        list<contact> contactForCadence =new list<contact>();
        
        for(Id accId: hawaiiRelatedAccountIds.keySet()) {
            if(hawaiiRelatedOpportunity.containsKey(accId)){
                //don't do anything
            }
            else{
                for(Contact con : hawaiiRelatedAccountIds.get(accId)){
                    
                    contactForCadence.add(con);
                    
                }
                
            }
        }
        
        system.debug('71=='+contactForCadence);
        
        
        for(Contact con:contactForCadence){
            
            system.debug('79=='+con);
            Id leastContactsUserId;
            Decimal noOfHVSContacts;
            
            
            for(Id HVSUserId: HVSUserIdMap.keySet()){
                if(leastContactsUserId == null){
                    leastContactsUserId = HVSUserId;
                }
                noOfHVSContacts = HVSUserIdMap.get(leastContactsUserId).Assigned_Contacts__c;
                if(noOfHVSContacts > HVSUserIdMap.get(HVSUserId).Assigned_Contacts__c){
                    noOfHVSContacts = HVSUserIdMap.get(HVSUserId).Assigned_Contacts__c;
                    leastContactsUserId = HVSUserId;
                }
            }
            
            HVSUserIdMap.get(leastContactsUserId).Assigned_Contacts__c +=1;
            con.Assign_to_Sales_Cadence__c=true;
            con.OwnerId = leastContactsUserId;
            contactToUpdate.add(con);
            cadenceContactsId.add(con.id);            
            
            
        }
        
        for(Id uId :HVSUserIdMap.keySet()){
            HVSUserList.add(HVSUserIdMap.get(uId));
        }
        if(HVSUserList.size() > 0){
            update HVSUserList;
        }    
        if(contactToUpdate.size() > 0 ){
            system.debug('62='+contactToUpdate.size());
            update contactToUpdate;
        } 
        System.enqueueJob(new AssignContactIn71DaysCadenceQueueable2(cadenceContactsId)); 
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new AssigningContactIn71DaysCadence2(),1);
    }
}