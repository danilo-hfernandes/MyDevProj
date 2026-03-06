public class AssignContactInTourGenVidaCadence implements Database.Batchable<sObject>,Database.Stateful,Schedulable{
    public List<User> HVSUserList = new List<User>();
    public List<Id> targetIds = new List<Id>();
    public AssignContactInTourGenVidaCadence(){
        targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList('TourGen-Vida Travelers New');
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String recordType1='Voucher';
        String recordType2='VI Referral Date Request';  
        //DateTime Date1 = date.newinstance(2022, 1, 1);
        //DateTime  Date2 = date.newinstance(2022, 12, 31);
        Cadence_Batch_Contol__c assignContactInTourGenVidaCadenceControl = Cadence_Batch_Contol__c.getValues('AssignContactInTourGenVidaCadence');
        Set<Decimal> excludedAffiliateId = new Set<Decimal>{1002432};
            Date Date1 = date.newinstance(2023, 1, 1);
        Date Date2 = system.today().addDays(-60);
        String  checkInDate1=String.ValueOf(Date1);//Date1.format('yyyy-MM-dd');
        String  checkInDate2=String.ValueOf(system.today().addDays(-60));//Date2.format('yyyy-MM-dd');
        Integer queryLimit = Integer.valueOf(assignContactInTourGenVidaCadenceControl.Query_Limit__c);
        String query= '';
        system.debug('>>>Date1>>>'+Date1);
        system.debug('>>>Date2>>>'+Date2);
        /*   ***************************  This affiliateNames are not part of the ticket - 06-11-2023 *********************************** 

list<String> AffiliateName2=new list<String>{'VacationClix','Vacation VIP','Vacation VIP Plus','Vacation VIP Vida Voucher','My Travel Rewards Club Guest','My Travel Rewards Club Silver','My Travel Rewards Club Gold','My Travel Rewards Club Platinum','SFX - Gold','Hawaii Collection','Hawaii Collection - Gold','Hawaii Collection- Platinum','Hawaii Collection - Platinum','Vida Vacations','Hawaii Collection - Silver','The Grand Mayan Los Cabos (Exit)','The Grand Mayan Los Cabos','Mayan Palace Riviera Maya (Exit)','Sharelife','Mayan Palace Riviera Maya','Mayan Palace Puerto Penasco (Exit)','Mayan Palace Puerto Peñasco','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Nuevo Vallarta','Mayan Palace Acapulco (Exit)','Mayan Palace Acapulco','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace - Sea Garden Mazatlán','Mayan National Exit','Mayan National Add-On (V.O.)','Mayan National Add-On (V.C.)','Mayan National Add-On','Mayan International Exit','Mayan International Add-On','MAYAN'};
list<String> AffiliateName1=new list<String>{'Carefree Flights','Carefree Destinations','Carefree Destinations FB','SMTN Checkout','Resort Rentals Checkout','Holiday Systems Demo','Vacation Innovations Employee','Vacation Innovations Referral','FastWeeks.Com','Tryp360.Club','FutureStay','Hawaii Collection','Hawaii Collection - Demo','Hawaii Collection - Gold','Hawaii Collection - Guest','Hawaii Collection - Platinum','Hawaii Collection - Silver','Hawaii Collection eGift Card','TEST Hawaii Collection - DO NOT USE','SFX - Diamond','SFX - Diamond Plus','SFX - Diamond Preferred','SFX - Diamond Premier','SFX - Gold','SMTN Loyalty','SMTN Loyalty Gold','SMTN Loyalty Platinum','SMTN Loyalty Plus','SMTN Loyalty Premium','SMTN Loyalty-UBA'};

cadenceContactList=[SELECT Id,Match_Group_Name__c,Affiliate_Name__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,AccountId, OwnerId, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact where Account.Affiliate_Name__c Not IN: AffiliateName1 AND Account.Affiliate_Name__c Not IN: AffiliateName2 AND accountid IN: AccountIdList AND Master_Record_Id__c!=null];        
*****************************************************************************
*/
        list<String> AffiliateName3=new list<String>{'LuxGive Voucher','MAYAN','Mayan International Add-On','Mayan International Exit','Mayan National Add-On','Mayan National Add-On (V.C.)','Mayan National Add-On (V.O.)','Mayan National Exit','Mayan Palace - Sea Garden Mazatlán','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace Acapulco','Mayan Palace Acapulco (Exit)','Mayan Palace Acapulco (Exit)','Mayan Palace Nuevo Vallarta','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Puerto Peñasco','Mayan Palace Puerto Penasco (Exit)','Mayan Palace Puerto Penasco (Exit)','Mayan Palace Riviera Maya','Mayan Palace Riviera Maya (Exit)','Mayan Palace Riviera Maya (Exit)','The Grand Mayan Los Cabos','The Grand Mayan Los Cabos (Exit)','The Grand Mayan Los Cabos (Exit)','Hawaii Collection','Hawaii Collection – Platinum','Hawaii Collection – Gold','Hawaii Collection – Silver','Sharelife','SFX – Gold','SFX - Diamond','SFX - Diamond Preferred','SFX - Diamond Premier','Vida Vacations'};
            if(assignContactInTourGenVidaCadenceControl != null && assignContactInTourGenVidaCadenceControl.isInitialLoad__c){
                query = 'SELECT Id,AccountId,name,account.Affiliate_Name__c FROM Opportunity Where account.Affiliated_Id__c NOT IN: excludedAffiliateId AND Arrived__c=true AND account.Affiliate_Name__c Not IN: AffiliateName3 AND (Record_Type_Name__c = \''+recordType1+'\' OR Record_Type_Name__c = \''+recordType2+'\') AND Bypass_Cadence__c = false AND (Check_in__c > '+checkInDate1+' AND Check_in__c <= '+checkInDate2+') Limit '+queryLimit+'' ;
            }else if(assignContactInTourGenVidaCadenceControl != null && assignContactInTourGenVidaCadenceControl.isDailyRun__c){
                query = 'SELECT Id,AccountId,name,account.Affiliate_Name__c, account.Affiliated_Id__c FROM Opportunity Where account.Affiliated_Id__c NOT IN: excludedAffiliateId AND Arrived__c=true AND account.Affiliate_Name__c Not IN: AffiliateName3 AND (Record_Type_Name__c = \''+recordType1+'\' OR Record_Type_Name__c = \''+recordType2+'\') AND Bypass_Cadence__c = false AND (Check_in__c = '+checkInDate2+')  Limit '+queryLimit+'' ;
            }
        
        system.debug('8='+query);
        system.debug('Data=== '+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        
        System.debug('Opportunity records--'+scope);
        System.debug('Opportunity records count--'+scope.size());
        
        Set<ID> AccountIdList=new set<Id>();
        set<String> HVSUsersId=new set<String>();
        list<Contact> cadenceContactList= new list<Contact>();
        Set<ID> cadenceContactsId = new set<Id>();
        List<Contact> contactToUpdate=new List<Contact>();
        
        HVSUsersId = GenericMatchGroupAssignmentHandler.fetchMatchGroupDetails('TourGen-Vida Travelers');
        Map<Id, User> HVSUserIdMap = new Map<Id, User>([SELECT Id, name,Assigned_Contacts__c FROM User WHERE Id IN:HVSUsersId AND IsActive = true]);
        
        
        System.debug('36--'+HVSUserIdMap);
        System.debug('HVSUserSize--'+HVSUserIdMap.keySet().size());
        system.debug('scope='+scope);
        for(Opportunity opp : scope) {
            AccountIdList.add(opp.accountId);           
        }
        system.debug('AccountIdList='+AccountIdList);
        
        /*   ***************************  This affiliateNames are not part of the ticket - 06-11-2023 *********************************** 

list<String> AffiliateName2=new list<String>{'VacationClix','Vacation VIP','Vacation VIP Plus','Vacation VIP Vida Voucher','My Travel Rewards Club Guest','My Travel Rewards Club Silver','My Travel Rewards Club Gold','My Travel Rewards Club Platinum','SFX - Gold','Hawaii Collection','Hawaii Collection - Gold','Hawaii Collection- Platinum','Hawaii Collection - Platinum','Vida Vacations','Hawaii Collection - Silver','The Grand Mayan Los Cabos (Exit)','The Grand Mayan Los Cabos','Mayan Palace Riviera Maya (Exit)','Sharelife','Mayan Palace Riviera Maya','Mayan Palace Puerto Penasco (Exit)','Mayan Palace Puerto Peñasco','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Nuevo Vallarta','Mayan Palace Acapulco (Exit)','Mayan Palace Acapulco','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace - Sea Garden Mazatlán','Mayan National Exit','Mayan National Add-On (V.O.)','Mayan National Add-On (V.C.)','Mayan National Add-On','Mayan International Exit','Mayan International Add-On','MAYAN'};
list<String> AffiliateName1=new list<String>{'Carefree Flights','Carefree Destinations','Carefree Destinations FB','SMTN Checkout','Resort Rentals Checkout','Holiday Systems Demo','Vacation Innovations Employee','Vacation Innovations Referral','FastWeeks.Com','Tryp360.Club','FutureStay','Hawaii Collection','Hawaii Collection - Demo','Hawaii Collection - Gold','Hawaii Collection - Guest','Hawaii Collection - Platinum','Hawaii Collection - Silver','Hawaii Collection eGift Card','TEST Hawaii Collection - DO NOT USE','SFX - Diamond','SFX - Diamond Plus','SFX - Diamond Preferred','SFX - Diamond Premier','SFX - Gold','SMTN Loyalty','SMTN Loyalty Gold','SMTN Loyalty Platinum','SMTN Loyalty Plus','SMTN Loyalty Premium','SMTN Loyalty-UBA'};

cadenceContactList=[SELECT Id,Match_Group_Name__c,Affiliate_Name__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,AccountId, OwnerId, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact where Account.Affiliate_Name__c Not IN: AffiliateName1 AND Account.Affiliate_Name__c Not IN: AffiliateName2 AND accountid IN: AccountIdList AND Master_Record_Id__c!=null];        
*****************************************************************************
*/
        cadenceContactList=[SELECT Id,Match_Group_Name__c,Affiliate_Name__c,Assign_to_Sales_Cadence__c,AccountId, OwnerId, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact where Id NOT IN : targetIds and accountid IN: AccountIdList AND Master_Record_Id__c!=null and Marketing_Email_opt_out__c = false]; 
        System.debug('53--'+cadenceContactList);
        System.debug('53 s--'+cadenceContactList.size());
        
        for(Contact con:cadenceContactList){
            Id leastContactsUserId;
            Decimal noOfHVSContacts;
            if(HVSUserIdMap != null && HVSUserIdMap.size() > 0){
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
            }
            if(con.Affiliate_Name__c != null && con.Affiliate_Name__c.contains('Holidays Lounge')){
                system.debug('74='+con);
            }
            else{
                con.Assign_to_Sales_Cadence__c=true;
                con.Match_Group_Name__c='Tour Gen Vida';
                //con.OwnerId = leastContactsUserId;
                contactToUpdate.add(con);
                cadenceContactsId.add(con.id); 
            }
        }
        system.debug('>>>>cadenceContactsId>>>>'+cadenceContactsId);
        for(Id uId :HVSUserIdMap.keySet()){
            HVSUserList.add(HVSUserIdMap.get(uId));
        }
        /*if(HVSUserList.size() > 0){
System.debug('84--'+HVSUserList);
System.debug('HVSUserList count--'+HVSUserList.size());
System.enqueueJob(new AssignContactInUserQueueable(HVSUserList));
//update HVSUserList;
}    */
        if(cadenceContactList.size() > 0 ){
            System.debug('89--'+cadenceContactList);
            System.debug('cadenceContactList count--'+cadenceContactList.size());
            contactToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(contactToUpdate, 'Assigned');
            update contactToUpdate;
        } 
        system.debug('>>>>cadenceContactsId>>>>'+cadenceContactsId);
        System.enqueueJob(new AssignContactInTourGenVidaQueueable(cadenceContactsId)); 
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
        if(HVSUserList.size() > 0){
            System.debug('84--'+HVSUserList);
            System.debug('HVSUserList count--'+HVSUserList.size());
            System.enqueueJob(new AssignContactInUserQueueable(HVSUserList));
        } 
    }   
    public void execute(SchedulableContext SC) {
        AssignContactInTourGenVidaCadence objBatch = new AssignContactInTourGenVidaCadence(); 
        database.executebatch(objBatch, 25);
    } 
}