//TourGen-LuxGive Sales Cadence
public class LuxGiveOpenVoucherReengagementBatch implements Database.Batchable<sObject>, Schedulable{
   //Affiliate - LuxGive Voucher OR Affiliated_Id__c = 1002432
   //StageName - Closed Won
   //RecordType - Voucher
   //Opportunity Closed Date = 60 Days Ago
   //Reservation_Status__c = null
   public Database.QueryLocator start(Database.BatchableContext bc) {
       String recordType='Voucher';
       String initialLoad = System.label.InitialLoad;
       String query ='';
       if(test.isRunningTest()){
           query = 'SELECT Id,AccountId,name,Match_Group_Name__c,ownerid FROM Opportunity Where Account.Affiliated_Id__c = 1002432 and CloseDate = N_DAYS_AGO: 60 and StageName = \'Closed Won\' and (Reservation_Status__c = null or Reservation_Status__c = \'Cancel\') and Account.LuxGive_Order_Id__c!=null AND Record_Type_Name__c = \''+recordType+'\'' ;
       }
       else{
           if(initialLoad == 'False'){
                query = 'SELECT Id,AccountId,name,Match_Group_Name__c,ownerid FROM Opportunity Where Approved_for_Vidanta_Booking__c = true and Account.Affiliated_Id__c = 1002432 and Opportunity_Closed_Date__c = N_DAYS_AGO: 60 and StageName = \'Closed Won\' and (Reservation_Status__c = null or Reservation_Status__c = \'Cancel\') and Account.LuxGive_Order_Id__c!=null AND Record_Type_Name__c = \''+recordType+'\'' ;
           }
           else{
                query = 'SELECT Id,AccountId,name,Match_Group_Name__c,ownerid FROM Opportunity Where Approved_for_Vidanta_Booking__c = true and Account.Affiliated_Id__c = 1002432 and Opportunity_Closed_Date__c <= N_DAYS_AGO: 61 and StageName = \'Closed Won\' and (Reservation_Status__c = null or Reservation_Status__c = \'Cancel\') and Account.LuxGive_Order_Id__c!=null AND Record_Type_Name__c = \''+recordType+'\''; 
           }
       }
       system.debug('9='+query);
       return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        set<String> setUsersId = new set<String>();
        system.debug('13='+scope);
        map<String,list<Opportunity>> voucherAccountOppMap= new map<String,list<Opportunity>>();
        list<Contact> cadenceContactList= new list<Contact>();
        Set<ID> cadenceContactsId=new set<Id>();
        List<Contact> contactToUpdate=new List<Contact>();
        for(Opportunity opp: scope){
            if(!voucherAccountOppMap.keyset().contains(opp.AccountId)){
                voucherAccountOppMap.put(opp.AccountId,new List<Opportunity>());
            }
            voucherAccountOppMap.get(opp.AccountId).add(opp);
        }
        setUsersId =GenericMatchGroupAssignmentHandler.fetchMatchGroupDetails('TourGen-LuxGive');
        cadenceContactList=[SELECT Id,OwnerId,Match_Group_Name__c,Affiliate_Name__c,Assign_to_Sales_Cadence__c,AccountId, ActionCadenceId,ActionCadence.Name, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact where accountid IN: voucherAccountOppMap.keyset() and Is_Main_Contact__c = true and (Match_Group_Name__c != 'TourGen-LuxGive' OR ActionCadenceId = null OR ActionCadence.Name!= 'TourGen-LuxGive') and Marketing_Email_opt_out__c = false];        
        Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
        for(Contact con:cadenceContactList){   
            if(con.ActionCadenceId == null && con.ActionCadence.Name != 'TourGen-LuxGive') {           
            	con.Assign_to_Sales_Cadence__c=true;
            }
            if( con.Match_Group_Name__c != 'TourGen-LuxGive' || !setUsersId.contains(con.OwnerId)){
                con.Match_Group_Name__c='TourGen-LuxGive';
            }
            contactToUpdate.add(con);
            cadenceContactsId.add(con.id);
        }
        if(cadenceContactList.size() > 0 ){
            System.debug('cadenceContactList--'+cadenceContactList);
            contactToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(contactToUpdate, 'Assigned');
            update contactToUpdate;
        } 
        if(cadenceContactsId.size() > 0){
            System.enqueueJob(new LuxGiveSRRCadenceAssignmentQueueable(cadenceContactsId)); 
        }
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }  
    public void execute(SchedulableContext SC) {
        //system.debug('110');
        database.executebatch(new LuxGiveOpenVoucherReengagementBatch(),100);
    }
}