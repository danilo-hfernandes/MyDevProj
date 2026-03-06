public class LuxGiveSRRCadenceAssignment implements Database.Batchable<sObject>, Schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> recordTypeNames= new List<String>{'Voucher', 'Unhooked Voucher'}; 
        /*String stageName1='Closed Won';
String stageName2='Closed Won-Deposit';*/
        //2023-10-26 LuxGive filter added
        //2025-09-23 TGR-822 Add Raise Away and Engage Goods to Sales Cadence
        String query = 'SELECT Id,AccountId,name,Match_Group_Name__c,ownerid FROM Opportunity Where (Account.LuxGive_Order_Id__c!=null AND Reservation_Status__c = NULL AND Record_Type_Name__c IN :recordTypeNames)' ;
        query = query + 'OR ((account.affiliated_id__c = 1002464 OR account.affiliated_id__c = 1002465) AND StageName = \'Closed Won\' AND Reservation_Status__c = NULL AND Record_Type_Name__c IN :recordTypeNames)';
        system.debug('9='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        system.debug('13='+scope);
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
        //2025-09-23 TGR-822 Add Raise Away and Engage Goods to Sales Cadence
        //String salesCadenceName='TourGen-LuxGive';
        String salesCadenceName='TourGen-Charity';
        List<Id> targetIds = new List<Id>();
        targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList(salesCadenceName);
        system.debug('targetIds>>>>>'+targetIds);
        cadenceContactList=[SELECT Id,Match_Group_Name__c,Affiliate_Name__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,AccountId, OwnerId, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact where accountid IN: voucherAccountOppMap.keyset() and actioncadenceid=null and Is_Main_Contact__c = true /*AND leadassist__Use_Round_Robin__c != 'ASSIGNED'*/ and Marketing_Email_opt_out__c = false and Id NOT IN :targetIds];
        
		Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
        List<Id> targetIds2 = new List<Id>();
        
        for(Contact con:cadenceContactList){
            if(con.leadassist__Use_Round_Robin__c != 'ASSIGNED'){
                con.Assign_to_Sales_Cadence__c=true;
                //2025-09-23 TGR-822 Add Raise Away and Engage Goods to Sales Cadence
                //con.Match_Group_Name__c='TourGen-LuxGive';
                con.Match_Group_Name__c='TourGen-Charity';
                con.leadassist__Use_Round_Robin__c='TRUE';
                contactToUpdate.add(con);
                cadenceContactsId.add(con.id);
            }
            else
            {
                targetIds2.add(con.id);
            }
        }
        
        cadenceContactList2 = [SELECT Id,Match_Group_Name__c,Affiliate_Name__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,AccountId, OwnerId, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact where Id IN : targetIds2 AND Id NOT IN (SELECT TargetId FROM ActionCadenceTracker WHERE ActionCadence.Name='TourGen-Charity')];
        
        for(Contact con:cadenceContactList2){
            
            con.Assign_to_Sales_Cadence__c=true;
            //2025-09-23 TGR-822 Add Raise Away and Engage Goods to Sales Cadence
            //con.Match_Group_Name__c='TourGen-LuxGive';
            con.Match_Group_Name__c='TourGen-Charity';
            contactToUpdate.add(con);
            cadenceContactsId.add(con.id);
        }
        
        if(cadenceContactList.size() > 0 ){
            System.debug('cadenceContactList--'+cadenceContactList);
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
        database.executebatch(new LuxGiveSRRCadenceAssignment(),100);
    }
}