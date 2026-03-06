public class VoucherEmailActivation implements Database.Batchable<sObject>, Schedulable{
    public List<Id> targetIds = new List<Id>();
    public VoucherEmailActivation(){
        targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList('TourGen-Activation Email Offer');
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String recordType1='Voucher';
        String stageName1='Closed Won';
        String RoundRobin='Assigned';
        String stageName2='Closed Won-Deposit';
        Set<Decimal> excludedAffiliateId = new Set<Decimal>{1002432,1002421,1002432,1002440,1002464};
            String excludeMemberNumber = '142519-support@monsterrg.com';
            //2023-10-26 LuxGive filter added
            String query = 'SELECT Id,AccountId,name,Match_Group_Name__c,ownerid FROM Opportunity Where Account.Marketing_Email_opt_out__c = false and Member_Number__c !=: excludeMemberNumber and Bypass_Cadence__c = false and Account.Affiliated_Id__c NOT IN: excludedAffiliateId AND (NOT Account.Affiliate_Name__c LIKE \'%Profit%\') AND Account.LuxGive_Order_Id__c=null AND Record_Type_Name__c = \''+recordType1+'\'  AND (StageName=\''+stageName1+'\' OR StageName=\''+stageName2+'\') AND Check_in__c =null AND Reservation_Status__c=null AND First_Payment_Date__c > N_YEARS_AGO:2' ;
        system.debug('8='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        system.debug('13='+scope);
        map<String,list<Opportunity>> voucherAccountOppMap= new map<String,list<Opportunity>>();
        map<String,list<Contact>> voucherAccountConMap= new map<String,list<Contact>>();
        list<Opportunity> SSROpp= new list<Opportunity>();
        list<Contact> cadenceContactList= new list<Contact>();
        Set<ID> cadenceContactsId=new set<Id>();
        List<Contact> contactToUpdate=new List<Contact>();
        List<String> HVSUsersId=new List<String>();
        
        /*
list<leadassist__MatchGroup__c> matchGroupId= new list<leadassist__MatchGroup__c>();
matchGroupId= [SELECT Name, Id FROM leadassist__MatchGroup__c where name='TourGen-Activation Email Offer'];



list<leadassist__Assignee__c> ssrUsers= new list<leadassist__Assignee__c>();
ssrUsers=[SELECT Id, leadassist__MatchGroup__c,leadassist__User__c  FROM leadassist__Assignee__c where leadassist__MatchGroup__c=:matchGroupId[0].id AND leadassist__Active__c=true];

for(leadassist__Assignee__c AssignedUsers: ssrUsers)
{
HVSUsersId.add(AssignedUsers.leadassist__User__c);
}

Map<Id, User> HVSUserIdMap = new Map<Id, User>([SELECT Id, name,Assigned_Contacts__c FROM User WHERE Id IN:HVSUsersId AND IsActive = true]);
List<User> HVSUserList = new List<User>();

System.debug('36--'+HVSUserIdMap);
*/
        for(Opportunity opp: scope){
            if(!voucherAccountOppMap.keyset().contains(opp.AccountId)){
                voucherAccountOppMap.put(opp.AccountId,new List<Opportunity>());
            }
            voucherAccountOppMap.get(opp.AccountId).add(opp);
        }
        
        list<String> AffiliateName2=new list<String>{'Advantage Services Affiliate Marketing','Carefree Destinations Affiliate Marketing MX Vouch','LuxGive Voucher','ProfitAgility - Monster Reservations Group','LuxGive Voucher','VacationClix','Vacation VIP','Vacation VIP Plus','Vacation VIP Vida Voucher','My Travel Rewards Club Guest','My Travel Rewards Club Silver','My Travel Rewards Club Gold','My Travel Rewards Club Platinum','SFX - Gold','Hawaii Collection','Hawaii Collection - Gold','Hawaii Collection- Platinum','Hawaii Collection - Platinum','Vida Vacations','Hawaii Collection - Silver','The Grand Mayan Los Cabos (Exit)','The Grand Mayan Los Cabos','Mayan Palace Riviera Maya (Exit)','Sharelife','Mayan Palace Riviera Maya','Mayan Palace Puerto Penasco (Exit)','Mayan Palace Puerto Peñasco','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Nuevo Vallarta','Mayan Palace Acapulco (Exit)','Mayan Palace Acapulco','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace - Sea Garden Mazatlán','Mayan National Exit','Mayan National Add-On (V.O.)','Mayan National Add-On (V.C.)','Mayan National Add-On','Mayan International Exit','Mayan International Add-On','MAYAN'};
        list<String> AffiliateName1=new list<String>{'Carefree Flights','Carefree Destinations','Carefree Destinations FB','SMTN Checkout','Resort Rentals Checkout','Holiday Systems Demo','Vacation Innovations Employee','Vacation Innovations Referral','FastWeeks.Com','Tryp360.Club','FutureStay','Hawaii Collection','Hawaii Collection - Demo','Hawaii Collection - Gold','Hawaii Collection - Guest','Hawaii Collection - Platinum','Hawaii Collection - Silver','Hawaii Collection eGift Card','TEST Hawaii Collection - DO NOT USE','SFX - Diamond','SFX - Diamond Plus','SFX - Diamond Preferred','SFX - Diamond Premier','SFX - Gold','SMTN Loyalty','SMTN Loyalty Gold','SMTN Loyalty Platinum','SMTN Loyalty Plus','SMTN Loyalty Premium','SMTN Loyalty-UBA'};
        cadenceContactList=[SELECT Id,Match_Group_Name__c,Affiliate_Name__c,Assign_to_Sales_Cadence__c,AccountId, OwnerId, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact where ID NOT IN : targetIds and accountid IN: voucherAccountOppMap.keyset() and Parent_Id_Ext_Db__c = null AND Account.Affiliate_Name__c Not IN: AffiliateName1 AND Account.Affiliate_Name__c Not IN: AffiliateName2 and Marketing_Email_opt_out__c = false];   
        
        Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
        for(Contact con:cadenceContactList){
            if(con.Affiliate_Name__c != null && con.Affiliate_Name__c.contains('Holidays Lounge')){
                system.debug('74='+con);
            }
            else{
                con.Assign_to_Sales_Cadence__c=true;
                contactToUpdate.add(con);
                cadenceContactsId.add(con.id);   
            } 
        }
        if(cadenceContactList.size() > 0 ){
            System.debug('89--'+cadenceContactList);
            contactToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(contactToUpdate, 'Voucher Email');
            update contactToUpdate;
        } 
        System.enqueueJob(new VoucherEmailActivationQueueable(cadenceContactsId));
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    public void execute(SchedulableContext SC) {
        system.debug('110');
        database.executebatch(new VoucherEmailActivation(),100);
    }
}