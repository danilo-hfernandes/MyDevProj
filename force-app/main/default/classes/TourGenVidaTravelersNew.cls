public class TourGenVidaTravelersNew implements Database.Batchable<sObject>,schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String ReservationStatus='Confirmed';
        date checkInStart=Date.newInstance(2021, 7, 1); 
        date checkInEnd=Date.newInstance(2022, 12, 31);
        
        String query='SELECT Id,AccountId from Opportunity where Check_in__c != null and Check_in__c >= :checkInStart and Check_in__c <= :checkInEnd and Reservation_Status__c = \''+ReservationStatus+'\'';
        //String query='SELECT Id,Name,Assign_to_Sales_Cadence__c,Match_Group_Name__c FROM Contact where Account.Affiliated_id__c=1002275 and Account.enrollment_date__C>=:dt1 and Account.enrollment_date__C<=:dt2 AND  leadassist__Use_Round_Robin__c=\''+UseRoundRobin+'\' AND  Original_Source__c=\''+originalSource+'\' AND Assign_to_Sales_Cadence__c=FALSE ';
        // Query updated by Mitul - Added Preferred Language option  - 08/09/2022 - B-08576
        //String query='SELECT Id,Name,Assign_to_Sales_Cadence__c,Match_Group_Name__c FROM Contact where Account.Affiliated_id__c=1002275 and Account.enrollment_date__C>=:dt1 and Account.enrollment_date__C<=:dt2 AND  leadassist__Use_Round_Robin__c=\''+UseRoundRobin+'\' AND  Original_Source__c=\''+originalSource+'\' AND  Preferred_Language__c=\''+PreferredLanguage+'\' AND Assign_to_Sales_Cadence__c=FALSE ';
        system.debug('11='+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> oppList) {
        
        System.debug('16--'+oppList.size());
        Set<Id> AccountIdSet = new Set<Id>();
        for(Opportunity opp : oppList){
            AccountIdSet.add(opp.AccountId);
        }
        list<String> AffiliateName2=new list<String>{'SFX - Diamond','SFX - Diamond Plus','SFX - Diamond Preferred','SFX - Diamond Premier','SFX - Gold','Hawaii Collection','Hawaii Collection - Gold','Hawaii Collection- Platinum','Hawaii Collection - Platinum','Vida Vacations','Hawaii Collection - Silver','The Grand Mayan Los Cabos (Exit)','The Grand Mayan Los Cabos','Mayan Palace Riviera Maya (Exit)','Sharelife','Mayan Palace Riviera Maya','Mayan Palace Puerto Penasco (Exit)','Mayan Palace Puerto Peñasco','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Nuevo Vallarta','Mayan Palace Acapulco (Exit)','Mayan Palace Acapulco','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace - Sea Garden Mazatlán','Mayan National Exit','Mayan National Add-On (V.O.)','Mayan National Add-On (V.C.)','Mayan National Add-On','Mayan International Exit','Mayan International Add-On','MAYAN'};

        if(AccountIdSet != null){
            List<Contact> contactList = [select id,Affiliate_Name__c,Assign_to_Sales_Cadence__c,Match_Group_Name__c,Active_Advantage_Match_Group__c,Cadence_Flag__c from contact where AccountId In: AccountIdSet and Assign_to_Sales_Cadence__c=false and Account.Affiliate_Name__c Not IN: AffiliateName2 AND leadassist__Use_Round_Robin__c!='Assigned' and Marketing_Email_opt_out__c = false];
            Set<ID> cadenceLeadsId=new set<Id>();
            List<Contact> ContactToUpdate=new List<Contact>();
            
            List<Contact> leadList=new list<Contact>();
            for(Contact con : contactList)
            {
                if(con.Affiliate_Name__c.contains('Holidays Lounge')){
                    system.debug('74='+con);
                }
                else{
                con.Assign_to_Sales_Cadence__c=true;
                con.Active_Advantage_Match_Group__c='';
                con.Cadence_Flag__c=1;
                ContactToUpdate.add(con);
                cadenceLeadsId.add(con.id);
                }  
            }        
            if(ContactToUpdate.size() > 0 ){
                System.debug('32--'+ContactToUpdate);
                ContactToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(ContactToUpdate, 'Tour Gen Vida');
                update ContactToUpdate;
            } 
            System.enqueueJob(new TourGenVidaTravelersNewQueueable(cadenceLeadsId)); 
        }
    }
    

    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new TourGenVidaTravelersNew(),1);
    }
}