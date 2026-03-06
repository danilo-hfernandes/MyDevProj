public class TourGenActNewBatchController implements Database.Batchable<sObject>, Schedulable{
    /** Logic Criteria
* recordType= 'Voucher', 'Profit Agility Voucher'
* Approved_for_Vidanta_Booking__c = true,
* IsClosed = true,
* Reservation_Status__c = null
* Affiliate_Name__c Not IN 'MAYAN','Mayan International Add-On','Mayan International Exit','Mayan National Add-On','Mayan National Add-On (V.C.)','Mayan National Add-On (V.O.)','Mayan National Exit','Mayan Palace - Sea Garden Mazatlán','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace Acapulco','Mayan Palace Acapulco (Exit)','Mayan Palace Acapulco (Exit)','Mayan Palace Nuevo Vallarta','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Puerto Peñasco'
,'Mayan Palace Puerto Penasco (Exit)','Mayan Palace Puerto Penasco (Exit)','Mayan Palace Riviera Maya','Mayan Palace Riviera Maya (Exit)',
'Mayan Palace Riviera Maya (Exit)','The Grand Mayan Los Cabos','The Grand Mayan Los Cabos (Exit)','The Grand Mayan Los Cabos (Exit)','Hawaii Collection',
'Hawaii Collection - Platinum','Hawaii Collection - Gold','Hawaii Collection - Silver','Sharelife','SFX - Gold','SFX - Diamond','SFX - Diamond Plus',
'SFX - Diamond Preferred','SFX - Diamond Premier','Vida Vacations'
**/
    public List<Id> targetIds = new List<Id>();
    public TourGenActNewBatchController(){
        //targetIds = GetAssignedTargetDetails.getSingleCadenceNamewithTargetList('TourGen-ACT-*New'); //TGR-413
        
        Set<String> startingCadence = new Set<String>();
        startingCadence.add('TourGen-ACT-*New');
        Set<String> chainedCadences = new Set<String>();
        //get all the cadences chained to 'TourGen-ACT-*New'
        chainedCadences = GetAssignedTargetDetails.getAllChainedCadences(startingCadence); 
        
        //get all the targetIds from above cadences with State = 'running' to avoid setting them again
        list<String> chainedCadencesList = new list<String>(chainedCadences);
        targetIds = GetAssignedTargetDetails.getChainTargetList(chainedCadencesList); 
        system.debug('targetIds='+targetIds);
    
    }
    public Database.QueryLocator start(Database.BatchableContext bc) {
        list<String> recordType= new list<String>{'Voucher'};//, 'Profit Agility Voucher'
        Date startClosedDate = Date.newInstance(2024, 7, 1);
        Date endClosedDate = System.today().addDays(-15);
        
        list<String> listAffiliateNames =new list<String>{'MAYAN','Mayan International Add-On','Mayan International Exit','Mayan National Add-On','Mayan National Add-On (V.C.)','Mayan National Add-On (V.O.)','Mayan National Exit','Mayan Palace - Sea Garden Mazatlán','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace Acapulco','Mayan Palace Acapulco (Exit)','Mayan Palace Acapulco (Exit)','Mayan Palace Nuevo Vallarta','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Puerto Peñasco'
            ,'Mayan Palace Puerto Penasco (Exit)','Mayan Palace Puerto Penasco (Exit)','Mayan Palace Riviera Maya','Mayan Palace Riviera Maya (Exit)',
            'Mayan Palace Riviera Maya (Exit)','The Grand Mayan Los Cabos','The Grand Mayan Los Cabos (Exit)','The Grand Mayan Los Cabos (Exit)','Hawaii Collection',
            'Hawaii Collection - Platinum','Hawaii Collection - Gold','Hawaii Collection - Silver','Sharelife','SFX - Gold','SFX - Diamond','SFX - Diamond Plus',
            'SFX - Diamond Preferred','SFX - Diamond Premier','Vida Vacations', 'Raise Away Voucher'};
                String query ='';
        String UseRoundRobin='FALSE';
        String matchGroupName = 'TourGen-Activations New';
        if(test.isRunningTest()){
            query = 'SELECT Id,AccountId,name,Match_Group_Name__c,ownerid,Member_Number__c FROM Opportunity' ;
        }
        else{
            query = 'SELECT Id,AccountId,name,Member_Number__c,Match_Group_Name__c,ownerid,Booking_Agent__c FROM Opportunity Where Account.Affiliate_Name__c NOT IN :listAffiliateNames and IsClosed = true and Reservation_Status__c = null and Record_Type_Name__c IN :recordType and CloseDate >= :startClosedDate AND CloseDate < :endClosedDate'; //Approved_for_Vidanta_Booking__c = true and

			// for test only: // TRG-413
			// query = query + ' and Id = \'006O100000HLpsAIAT\' ';
			//
        }
        system.debug('9='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        set<Id> setUsersId = new set<Id>();
        system.debug('13='+scope);
        map<String, String> accountOwnersIds = new map<String, String>();
        list<Contact> cadenceContactList= new list<Contact>();
        Set<ID> cadenceContactsId=new set<Id>();
        Set<ID> setOppIds = new set<Id>();
        Set<ID> setMonsterOppIds = new set<Id>();
        List<Contact> contactToUpdate=new List<Contact>();
        List<Opportunity> listOppUpdate = new List<Opportunity>();
        for(Opportunity opp: scope){
            //opp.Match_Group_Name__c = 'TourGen-Activations New';
            //opp.leadassist__Use_Round_Robin__c = 'TRUE';
            //listOppUpdate.add(opp);
            if(opp.Member_Number__c != null && opp.Member_Number__c == '142519-support@monsterrg.com'){
                setMonsterOppIds.add(opp.Id);
            }
            else{
                setOppIds.add(opp.Id);
            }
        }
        listOppUpdate = GenericMatchGroupAssignmentHandler.assignMatchGroup(scope, 'TourGen-Activations New');
        system.debug('>>>>+setMonsterOppIds'+setMonsterOppIds);
        if(listOppUpdate != null && listOppUpdate.size() > 0){
            update listOppUpdate;
            if(setOppIds != null && setOppIds.size() > 0){
                for(Opportunity opp: [select id,Booking_Agent__c,OwnerId,AccountId from Opportunity where Id IN :setOppIds]){
                    if(opp.Booking_Agent__c != null)
                        accountOwnersIds.put(opp.AccountId,opp.Booking_Agent__c);
                    else
                        accountOwnersIds.put(opp.AccountId,opp.OwnerId);
                }
            }
            cadenceContactList=[SELECT Id,Opportunity__c, Opportunity__r.Booking_Agent__c,Opportunity__r.OwnerId,OwnerId,Account.Member_Number__c,Match_Group_Name__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,AccountId,Account.OwnerId, AffiliatedId__c FROM Contact where ID NOT IN : targetIds and ((accountid IN: accountOwnersIds.keyset() and Is_Main_Contact__c = true) or Opportunity__c IN :setMonsterOppIds) and Parent_Id_Ext_Db__c = null and Marketing_Email_opt_out__c = false and ActionCadence.Name != 'TourGen-ACT-*New'];        
            Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
            for(Contact con:cadenceContactList){
                if(con.Opportunity__c != null && con.Opportunity__r.Booking_Agent__c != null && con.Account.Member_Number__c != null && con.Account.Member_Number__c == '142519-support@monsterrg.com'){
                    con.OwnerId = con.Opportunity__r.Booking_Agent__c;
                }
                else if (con.Opportunity__c != null && con.Account.Member_Number__c != null && con.Account.Member_Number__c == '142519-support@monsterrg.com'){
                    con.OwnerId = con.Opportunity__r.OwnerId;
                }
                else if(con.Account.Member_Number__c != '142519-support@monsterrg.com'){
                    con.OwnerId = accountOwnersIds.get(con.AccountId);
                }
                con.Assign_to_Sales_Cadence__c=true;
                contactToUpdate.add(con);
                cadenceContactsId.add(con.id);
            }
            if(cadenceContactList.size() > 0 ){
                System.debug('cadenceContactList--'+cadenceContactList);
                update contactToUpdate;
            } 
            if(cadenceContactsId.size() > 0){
                System.enqueueJob(new GenericAssignToSalesCadence(cadenceContactsId, 'TourGen-ACT-*New')); 
            }
        }
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }  
    public void execute(SchedulableContext SC) {
        database.executebatch(new TourGenActNewBatchController(),25);
    }
}