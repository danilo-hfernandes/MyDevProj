//TourGen-Charity Reengagement
public class TourGenCharityReengagementBatch implements Database.Batchable<sObject>, Schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> recordTypeNames= new List<String>{'Voucher', 'Unhooked Voucher'};
            Date startDate = System.today().addDays(-45);
        Date endDate = System.today().addDays(-540); //18 months
        String query = 'SELECT Id,AccountId,name,Match_Group_Name__c,ownerid FROM Opportunity Where CloseDate <= : startDate AND CloseDate >= : endDate AND (Account.affiliated_id__c = 1002432 ' ;
        query = query + 'OR account.affiliated_id__c = 1002464 OR account.affiliated_id__c = 1002465) AND StageName = \'Closed Won\' AND Reservation_Status__c = NULL AND Record_Type_Name__c IN :recordTypeNames';//and Id = \'006O100000NjpacIAB\'
        system.debug('9='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        system.debug('scope'+scope);
        map<String,list<Opportunity>> voucherAccountOppMap= new map<String,list<Opportunity>>();
        map<String,list<Contact>> voucherAccountConMap= new map<String,list<Contact>>();
        list<Opportunity> SSROpp= new list<Opportunity>();
        list<Contact> cadenceContactList= new list<Contact>();
        list<Contact> cadenceContactList2 = new list<Contact>();
        Set<ID> cadenceContactsId=new set<Id>();
        List<Contact> contactToUpdate=new List<Contact>();
        List<String> HVSUsersId=new List<String>();
        for(Opportunity opp: scope){
            if(!voucherAccountOppMap.keyset().contains(opp.AccountId)){
                voucherAccountOppMap.put(opp.AccountId,new List<Opportunity>());
            }
            voucherAccountOppMap.get(opp.AccountId).add(opp);
        }
        System.debug('>>>voucherAccountOppMap>>'+voucherAccountOppMap);
        String salesCadenceName='TourGen-Charity Reengagement';
        List<Id> targetIds = new List<Id>();
        //targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList(salesCadenceName);
        List<ActionCadenceTracker> cadenceTrackersList = [SELECT TargetId,ActionCadence.Name, CreatedDate FROM ActionCadenceTracker WHERE (State = 'running' OR (State = 'complete' AND LastModifiedDate = LAST_N_DAYS:30)) AND ActionCadence.Name =: salesCadenceName];
        Date thirtyDaysAgo = System.today().addDays(-30);
        for (ActionCadenceTracker objTracker : cadenceTrackersList) {
            if(objTracker.createdDate >= thirtyDaysAgo)
                targetIds.add(objTracker.TargetId);
        }
        system.debug('targetIds>>>>>'+targetIds);
        cadenceContactList=[SELECT Id,Match_Group_Name__c,Affiliate_Name__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,AccountId, OwnerId, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact where accountid IN: voucherAccountOppMap.keyset() and Is_Main_Contact__c = true and Marketing_Email_opt_out__c = false and Id NOT IN :targetIds];
        Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
        List<Id> targetIds2 = new List<Id>();
        System.debug('>>>cadenceContactList>>'+cadenceContactList);
        for(Contact con:cadenceContactList){
            con.Assign_to_Sales_Cadence__c=true;
            con.Match_Group_Name__c='TourGen-Charity Reengagement';
            con.leadassist__Use_Round_Robin__c='TRUE';
            contactToUpdate.add(con);
            cadenceContactsId.add(con.id);
        }
        if(contactToUpdate.size() > 0 ){
            System.debug('contactToUpdate--'+contactToUpdate);
            update contactToUpdate;
        } 
        if(cadenceContactsId.size() > 0){
            System.enqueueJob(new GenericAssignToSalesCadence(cadenceContactsId, 'TourGen-Charity Reengagement')); 
        }
        
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }  
    public void execute(SchedulableContext SC) {
        //system.debug('110');
        database.executebatch(new TourGenCharityReengagementBatch(),25);
    }
}