public class VoucherPaymentsOpp1 implements Database.Batchable<sObject>,schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String recordTypeName='Voucher';
        String Product1='Vacation VIP 5/4-$149';
        String SSR='FALSE';
        String query='SELECT Quantity, UnitPrice, TotalPrice,Opportunity.Accountid, Product2.name,Opportunity.name,Opportunity.Vacation_Match_Group__c,Opportunity.id,Opportunity.Voucher_Expiration_Date__c,Opportunity.Recordtypeid FROM OpportunityLineItem  where Product2.name=\''+Product1+'\' AND Opportunity.Record_Type_Name__c=\''+recordTypeName+'\' AND Opportunity.Voucher_Expiration_Date__c<=TODAY AND Opportunity.Reservation_Status__c=null ';
        system.debug('11='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<OpportunityLineItem> scope) {
        
        System.debug('16--'+scope);
        list<id> OppAccountIdProduct1Expired = new list<id>();
        list<id> OppAccountIdProduct1 = new list<id>();
        list<id> OppAccountIdProduct2 =new list<id>();
        for(OpportunityLineItem OppLineItem: scope){
            OppAccountIdProduct1Expired.add(OppLineItem.Opportunity.Accountid);
        }
        Set<ID> AccountIdList=new set<Id>();
        set<String> HVSUsersId=new set<String>();
        list<Contact> cadenceContactList= new list<Contact>();
        Set<ID> cadenceContactsId=new set<Id>();
        List<Contact> contactToUpdate=new List<Contact>();
        HVSUsersId = GenericMatchGroupAssignmentHandler.fetchMatchGroupDetails('Tour Gen-Vacation VIP 8/7 Expired');
        
        Map<Id, User> HVSUserIdMap = new Map<Id, User>([SELECT Id, name,Assigned_Contacts__c FROM User WHERE Id IN:HVSUsersId AND IsActive = true]);
        List<User> HVSUserList = new List<User>();
        
        System.debug('36--'+HVSUserIdMap);
        cadenceContactList=[SELECT Id,Match_Group_Name__c,Assign_to_Sales_Cadence__c,AccountId, OwnerId, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact where accountid IN: OppAccountIdProduct1Expired AND leadassist__Use_Round_Robin__c='FALSE' AND Assign_to_Sales_Cadence__c=false and Marketing_Email_opt_out__c = false];        
        
        System.debug('53--'+cadenceContactList);
        for(Contact con:cadenceContactList){
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
            con.Match_Group_Name__c='Product1Expired';
            con.OwnerId = leastContactsUserId;
            contactToUpdate.add(con);
            cadenceContactsId.add(con.id);      
        }
        if(cadenceContactList.size() > 0 ){
            System.debug('89--'+cadenceContactList);
            contactToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(contactToUpdate, 'Assigned');
            update contactToUpdate;
        } 
        System.enqueueJob(new VoucherPaymentsOppQueueable(cadenceContactsId)); 
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new VoucherPaymentsOpp1(),1);
    }
}