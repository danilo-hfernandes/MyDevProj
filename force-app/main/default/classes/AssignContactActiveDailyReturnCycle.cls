public class AssignContactActiveDailyReturnCycle implements Database.Batchable<sObject>,schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {        
        String Status='Active';
        String matchGroup = 'TRUE';
        
        list<String> AffiliateName2=new list<String>{'VacationClix','Vacation VIP','Vacation VIP Plus','Vacation VIP Vida Voucher','My Travel Rewards Club Guest','My Travel Rewards Club Silver','My Travel Rewards Club Gold','My Travel Rewards Club Platinum','SFX - Gold','Hawaii Collection','Hawaii Collection - Gold','Hawaii Collection- Platinum','Hawaii Collection - Platinum','Vida Vacations','Hawaii Collection - Silver','The Grand Mayan Los Cabos (Exit)','The Grand Mayan Los Cabos','Mayan Palace Riviera Maya (Exit)','Sharelife','Mayan Palace Riviera Maya','Mayan Palace Puerto Penasco (Exit)','Mayan Palace Puerto Peñasco','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Nuevo Vallarta','Mayan Palace Acapulco (Exit)','Mayan Palace Acapulco','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace - Sea Garden Mazatlán','Mayan National Exit','Mayan National Add-On (V.O.)','Mayan National Add-On (V.C.)','Mayan National Add-On','Mayan International Exit','Mayan International Add-On','MAYAN'};
        list<String> AffiliateName1=new list<String>{'Carefree Flights','Carefree Destinations','Carefree Destinations FB','SMTN Checkout','Resort Rentals Checkout','Holiday Systems Demo','Vacation Innovations Employee','Vacation Innovations Referral','FastWeeks.Com','Tryp360.Club','FutureStay','Hawaii Collection','Hawaii Collection - Demo','Hawaii Collection - Gold','Hawaii Collection - Guest','Hawaii Collection - Platinum','Hawaii Collection - Silver','Hawaii Collection eGift Card','TEST Hawaii Collection - DO NOT USE','SFX - Diamond','SFX - Diamond Plus','SFX - Diamond Preferred','SFX - Diamond Premier','SFX - Gold','SMTN Loyalty','SMTN Loyalty Gold','SMTN Loyalty Platinum','SMTN Loyalty Plus','SMTN Loyalty Premium','SMTN Loyalty-UBA'};
                
        String query = 'SELECT Id,name,LastActivityDate,Assign_to_Sales_Cadence__c ,AccountId,Cadence_Flag__c,Affiliate_Name__c,Active_Advantage_Match_Group__c,Account.Affiliate_Name__c,Account.LastModifiedDate,Is_Main_Contact__c';
        query = query+' FROM Contact Where ActionCadenceId = NULL AND Account.Affiliate_Name__c Not IN: AffiliateName1 AND Account.Affiliate_Name__c Not IN: AffiliateName2 AND Active_Advantage_Match_Group__c = \''+matchGroup+'\' AND Membership_Status__c = \''+Status+'\' AND (Last_SRR_Assignment_Date_Attempt__c = NULL OR Last_SRR_Assignment_Date_Attempt__c < LAST_N_DAYS:90) AND';
        //query = query+' (AccountId NOT IN (SELECT AccountId FROM Opportunity WHERE LastModifiedDate > LAST_N_DAYS:90))';
        query = query+' (LastActivityDate < LAST_N_DAYS:90 OR LastActivityDate = NULL)';
        query = query+' ORDER BY CreatedDate ASC';
        query = query+' limit 600';
        system.debug('14='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        
        System.debug('13--'+scope.size());
        System.debug('13--'+scope);
        
        Set<ID> cadenceContactsId=new set<Id>();
        List<Contact> contactToUpdate=new List<Contact>();
        list<String> accountIds=new list<String>();
        lisT<String> voucherAccountIds=new lisT<String>();
        lisT<Contact> cadenceContacts=new list<Contact>();
        Integer check=0;
        for(Contact con: scope){
            accountIds.add(con.accountid);            
        }

        for(contact con:scope){
            cadenceContacts.add(con);
        }
        
        Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
        for(Contact con : cadenceContacts)
        {
            if(!contactIdSetMap.containskey(con.Id)){
                if(con.Affiliate_Name__c.contains('Holidays Lounge')){
                    system.debug('74='+con);
                }
                else{
                    con.Last_SRR_Assignment_Date_Attempt__c = System.Today();
                    con.Assign_to_Sales_Cadence__c=true;
                    con.Cadence_Flag__c=1;
                    con.Active_Advantage_Match_Group__c='TRUE';
                    contactToUpdate.add(con);
                    cadenceContactsId.add(con.id);
                    contactIdSetMap.put(con.id,con.id);
                }
            }
        }        
        
        if(contactToUpdate.size() > 0 ){
            System.debug('118--'+contactToUpdate);
            contactToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(contactToUpdate, 'TourGen-Active Advantage Program');
            update contactToUpdate;
        } 
        
        System.enqueueJob(new AssignContactAdvanceQueueable(cadenceContactsId)); 
    }
    
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new AssignContactActiveDailyReturnCycle(),100);
    }
}