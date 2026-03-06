public class tourVida implements Database.Batchable<sObject>,schedulable{
    public List<Id> targetIds = new List<Id>();
    public tourVida(){
        targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList('TourGen-Vida Owners-Active');
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String val='TRUE';
        list<String> AffiliateName2=new list<String>{'VacationClix','Vacation VIP','Vacation VIP Plus','Vacation VIP Vida Voucher','My Travel Rewards Club Guest','My Travel Rewards Club Silver','My Travel Rewards Club Gold','My Travel Rewards Club Platinum','SFX - Gold','Hawaii Collection','Hawaii Collection - Gold','Hawaii Collection- Platinum','Hawaii Collection - Platinum','Vida Vacations','Hawaii Collection - Silver','The Grand Mayan Los Cabos (Exit)','The Grand Mayan Los Cabos','Mayan Palace Riviera Maya (Exit)','Sharelife','Mayan Palace Riviera Maya','Mayan Palace Puerto Penasco (Exit)','Mayan Palace Puerto Peñasco','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Nuevo Vallarta','Mayan Palace Acapulco (Exit)','Mayan Palace Acapulco','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace - Sea Garden Mazatlán','Mayan National Exit','Mayan National Add-On (V.O.)','Mayan National Add-On (V.C.)','Mayan National Add-On','Mayan International Exit','Mayan International Add-On','MAYAN'};
            list<String> AffiliateName1=new list<String>{'Carefree Flights','Carefree Destinations','Carefree Destinations FB','SMTN Checkout','Resort Rentals Checkout','Holiday Systems Demo','Vacation Innovations Employee','Vacation Innovations Referral','FastWeeks.Com','Tryp360.Club','FutureStay','Hawaii Collection','Hawaii Collection - Demo','Hawaii Collection - Gold','Hawaii Collection - Guest','Hawaii Collection - Platinum','Hawaii Collection - Silver','Hawaii Collection eGift Card','TEST Hawaii Collection - DO NOT USE','SFX - Diamond','SFX - Diamond Plus','SFX - Diamond Preferred','SFX - Diamond Premier','SFX - Gold','SMTN Loyalty','SMTN Loyalty Gold','SMTN Loyalty Platinum','SMTN Loyalty Plus','SMTN Loyalty Premium','SMTN Loyalty-UBA'};
                //String query = 'Select id,name,accountid,Cadence_Flag__c,Assign_to_Sales_Cadence_Name__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c ,Tour_Vida_Active_SSR_Match_Group__c,Tour_Vida_Inactive_SSR_Match_Group__c,ActionCadenceId from contact where Account.Affiliate_Name__c Not IN: AffiliateName2 AND (Tour_Vida_Active_SSR_Match_Group__c =\''+val+'\' OR Tour_Vida_Inactive_SSR_Match_Group__c = \''+val+'\') AND Assign_to_Sales_Cadence__c=false AND ActionCadenceId = NULL  AND Master_Record_Id__c!=null  limit 360';
                String query = 'Select id,name,accountid,Cadence_Flag__c,Assign_to_Sales_Cadence_Name__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c ,Tour_Vida_Active_SSR_Match_Group__c,Tour_Vida_Inactive_SSR_Match_Group__c,ActionCadenceId from contact where ID NOT IN : targetIds and Marketing_Email_opt_out__c = false and Account.Affiliate_Name__c Not IN: AffiliateName1 AND Account.Affiliate_Name__c Not IN: AffiliateName2 AND Parent_Id_Ext_Db__c = null AND Master_Record_Id__c!=null limit 360';
        system.debug('Query'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        Set<ID> cadenceContactsId=new set<Id>();
        system.debug('13='+scope);
        List<Contact> cadenceContacts= new list<Contact>(); 
        list<contact> updateContacts=new list<contact>();
        Map<String,list<contact>> accConMap= new Map<String,list<Contact>>();
        for(Contact con: scope){
            if(!accConMap.keyset().contains(con.accountid)){
                accConMap.put(con.accountid,new List<Contact>());
            }
            accConMap.get(con.accountid).add(con);
        }
        
        list<String> accSelected= new list<String>();
        
        For(Account acc: [Select id , (select id from Opportunities where Record_Type_Name__c='Voucher' AND CloseDate > N_days_ago:30) from account where id IN: accConMap.keyset()]){
            
            if(acc.Opportunities.size()==0){
                system.debug('52='+acc.id);
                accSelected.add(acc.id);
            }
        }
        for(String acc: accSelected){
            cadenceContacts.addall(accConMap.get(acc));
        }
        Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
        for(contact con:cadenceContacts){
            if(!contactIdSetMap.containskey(con.Id)){
                con.Assign_to_Sales_Cadence__c=true;
                //con.leadassist__Use_Round_Robin__c='TRUE';
                con.Cadence_Flag__c=1;
                updateContacts.add(con);
                cadenceContactsId.add(con.Id);
                contactIdSetMap.put(con.id,con.id);
            }
        }
        if(updateContacts.size()>0){
            updateContacts =  GenericMatchGroupAssignmentHandler.assignMatchGroup(updateContacts, 'Assigned');
            update updateContacts;
        }
        
        system.debug('62='+cadenceContacts);
        System.enqueueJob(new tourVidaQueueable(cadenceContactsId)); 
        
    }
    
    public void finish(Database.BatchableContext bc) {
        //do something 
    }  
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new tourVida(),100);
    }
    
    
}