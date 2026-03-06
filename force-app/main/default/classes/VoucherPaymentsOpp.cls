public class VoucherPaymentsOpp implements Database.Batchable<sObject>,schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        String recordTypeName='Voucher';
        String Product2='Vacation VIP 5/4-$149';
        String Product1='Vacation VIP 7/6-$249';
        String Product3='Vacation VIP 8/7-$499';
        String Product4='Vacation VIP 8/7-$99 Down-$499';
        String query='SELECT Quantity, UnitPrice, TotalPrice,Opportunity.Accountid, Product2.name,Opportunity.name,Opportunity.Vacation_Match_Group__c,Opportunity.id,Opportunity.Voucher_Expiration_Date__c,Opportunity.Recordtypeid FROM OpportunityLineItem  where (Product2.name=\''+Product1+'\' OR Product2.name=\''+Product2+'\' OR Product2.name=\''+Product3+'\' OR Product2.name=\''+Product4+'\') AND Opportunity.Record_Type_Name__c=\''+recordTypeName+'\' and (Opportunity.Check_in__c=null OR Opportunity.Confirmation_Number__c=null)  ';
        system.debug('11='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<OpportunityLineItem> scope) {
        
        System.debug('16--'+scope);
        list<id> OppAccountIdProduct1 = new list<id>();
        list<id> OppAccountIdProduct2 =new list<id>();
        for(OpportunityLineItem OppLineItem: scope){
            OppAccountIdProduct1.add(OppLineItem.Opportunity.Accountid);           
        } 
        Set<ID> AccountIdList=new set<Id>();
        List<String> HVSUsersId=new List<String>();
        list<Contact> cadenceContactList= new list<Contact>();
        Set<ID> cadenceContactsId=new set<Id>();
        List<Contact> contactToUpdate=new List<Contact>();
        
        cadenceContactList=[SELECT Id,Match_Group_Name__c,Assign_to_Sales_Cadence__c,AccountId, OwnerId, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact where accountid IN: OppAccountIdProduct1 AND ActioncadenceId=null and Marketing_Email_opt_out__c = false];        
        
        System.debug('53--'+cadenceContactList);
        
        for(Contact con:cadenceContactList){
            con.Assign_to_Sales_Cadence__c=true;
            contactToUpdate.add(con);
            cadenceContactsId.add(con.id);       
        }
        if(cadenceContactList.size() > 0 ){
            System.debug('89--'+cadenceContactList);
            contactToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(contactToUpdate, 'Product1');
            update contactToUpdate;
        } 
        
        System.enqueueJob(new VoucherPaymentsOppQueueable(cadenceContactsId)); 
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new VoucherPaymentsOpp(),1);
    }
}