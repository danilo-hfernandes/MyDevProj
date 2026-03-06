/**
Requirement: 
Please assign records to the follow match group and sales cadence (already created)  TourGen-LG MX Retravelers that meet the following criteria:
LuxGive + LuxGive Guest Affiliates (1002445 and 1002432)
Vidanta and Marival Destinations (Voucher or Unhooked Opportunity Record Type) 
Exclude anyone that has the No Show Flag checked
Initial Load, include all  Check In Date = anything prior to 60 Days from today
Daily drip campaign to include where Check In Date = 60 Days from today**/
public class TourGenLGMXRetravelersBatchController implements Database.Batchable<sObject>,schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query ='';
        Date checkInDate = System.today().addDays(-60);//60 Days from today
        String initialLoad = System.label.TourGenLGMXRetravelersInitialLoad;
        list<String> recordTypeName = new list<String>{'Voucher', 'Unhooked Voucher'};
            list<Decimal> listAffiliateId =new list<Decimal>{1002445, 1002432};
                if(test.isRunningTest()){
                    query = 'SELECT Id,AccountId,name,Match_Group_Name__c,Ownerid,Member_Number__c FROM Opportunity' ;
                }
        else{
            if(initialLoad == 'true'){
                query = 'SELECT Id,AccountId,name,Member_Number__c,Match_Group_Name__c,ownerid,Booking_Agent__c FROM Opportunity Where Account.Affiliated_Id__c IN :listAffiliateId and Record_Type_Name__c IN :recordTypeName and No_Show__c = false and Check_in__c < :checkInDate Order by Check_in__c ASC';
            }
            else{
                query = 'SELECT Id,AccountId,name,Member_Number__c,Match_Group_Name__c,ownerid,Booking_Agent__c FROM Opportunity Where Account.Affiliated_Id__c IN :listAffiliateId and Record_Type_Name__c IN :recordTypeName and No_Show__c = false and Check_in__c = :checkInDate Order by Check_in__c ASC';
            }
        }
        system.debug('9='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope){
        set<Id> accountIds = new set<Id>();
        set<Id> cadenceContactsId = new set<Id>();
        List<Contact> contactToUpdate= new List<Contact>();
        for(Opportunity opp: scope){
            accountIds.add(opp.AccountId);
        }
        List<Contact> listContact = [select id,Match_Group_Name__c from Contact where accountId IN : accountIds];
        for(Contact objcon : listContact){
            objcon.Match_Group_Name__c = 'TourGen-LG MX Retravelers';
			objcon.leadassist__Use_Round_Robin__c = 'True';
            objcon.Assign_to_Sales_Cadence__c=true;
            objcon.Cadence_Flag__c = 1;
            contactToUpdate.add(objcon);
            cadenceContactsId.add(objcon.id);
        }
        if(contactToUpdate.size() > 0 ){
            update contactToUpdate;
        } 
        if(cadenceContactsId.size() > 0){
            System.enqueueJob(new GenericAssignToSalesCadence(cadenceContactsId, 'TourGen-LG MX Retravelers')); 
        }
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    public void execute(SchedulableContext SC) {
        database.executebatch(new TourGenLGMXRetravelersBatchController(),50);
    }
}