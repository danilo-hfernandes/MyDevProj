public class TourGenVidaTravelersOneTimeBatch implements Database.Batchable<sObject>, Database.Stateful{
    public List<Id> targetIds = new List<Id>();
    public set<Id> setContactIds;
    public TourGenVidaTravelersOneTimeBatch(){
        targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList('TourGen-Vida Travelers New');
        setContactIds = new set<Id>();
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        list<String> recordType= new list<String>{'Voucher', 'VI Referral Date Request'};
            //list<String> oppIds = new list<String>{'0064z00002CxEsUAAV', '0063t000013I2cKAAS','0063t000013I2gVAAS','0063t000013I2wMAAS'};
                list<String> affiliateName=new list<String>{'LuxGive Voucher','MAYAN','Mayan International Add-On','Mayan International Exit','Mayan National Add-On','Mayan National Add-On (V.C.)','Mayan National Add-On (V.O.)','Mayan National Exit','Mayan Palace - Sea Garden Mazatlán','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace Acapulco','Mayan Palace Acapulco (Exit)','Mayan Palace Acapulco (Exit)','Mayan Palace Nuevo Vallarta','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Puerto Peñasco','Mayan Palace Puerto Penasco (Exit)','Mayan Palace Puerto Penasco (Exit)','Mayan Palace Riviera Maya','Mayan Palace Riviera Maya (Exit)','Mayan Palace Riviera Maya (Exit)','The Grand Mayan Los Cabos','The Grand Mayan Los Cabos (Exit)','The Grand Mayan Los Cabos (Exit)','Hawaii Collection','Hawaii Collection – Platinum','Hawaii Collection – Gold','Hawaii Collection – Silver','Sharelife','SFX – Gold','SFX - Diamond','SFX - Diamond Preferred','SFX - Diamond Premier','SFX - Diamond Plus','Vida Vacations'};
                    Date checkInStart=Date.newInstance(2021, 1, 1); 
        Date checkInEnd=System.today().addDays(61);
        String query='';
        if(test.isRunningTest()){
            query = 'SELECT Id,AccountId,name,Match_Group_Name__c,ownerid,Member_Number__c FROM Opportunity' ;//Id IN :oppIds and
        }
        else{
            query='SELECT Id,AccountId,name,account.Affiliate_Name__c from Opportunity where Account.Affiliate_Name__c Not IN: affiliateName and Arrived__c=true and Bypass_Cadence__c = false and No_Show__c = false and Check_in__c != null and Check_in__c >= :checkInStart and Check_in__c <= :checkInEnd and Record_Type_Name__c IN :recordType Order by Name ASC';
            
        }return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity> oppList) {
        System.debug('oppList'+oppList.size());
        Set<Id> AccountIdSet = new Set<Id>();
        for(Opportunity opp : oppList){
            AccountIdSet.add(opp.AccountId);
        }
        if(AccountIdSet != null){
            List<Contact> contactList = [select id,Affiliate_Name__c,Assign_to_Sales_Cadence__c,Match_Group_Name__c,Active_Advantage_Match_Group__c,Cadence_Flag__c from Contact where Id NOT IN : targetIds and Id NOT IN : setContactIds and AccountId In: AccountIdSet and Marketing_Email_opt_out__c = false];
            Set<ID> cadenceLeadsId=new set<Id>();
            List<Contact> ContactToUpdate=new List<Contact>();
            
            List<Contact> leadList=new list<Contact>();
            for(Contact con : contactList)
            {
                if(!setContactIds.contains(con.id)){
                    con.Assign_to_Sales_Cadence__c=true;
                    con.Active_Advantage_Match_Group__c='';
                    con.Cadence_Flag__c=1;
                    ContactToUpdate.add(con);
                    cadenceLeadsId.add(con.id);
                    setContactIds.add(con.id);
                }
            }        
            
            if(ContactToUpdate.size() > 0 ){
                System.debug('ContactToUpdate--'+ContactToUpdate);
                contactToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(contactToUpdate, 'Tour Gen Vida');
                update ContactToUpdate;
            } 
            System.enqueueJob(new TourGenVidaTravelersNewQueueable(cadenceLeadsId)); 
        }
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }  
}