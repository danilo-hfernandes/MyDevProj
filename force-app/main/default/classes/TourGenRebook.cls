Global class TourGenRebook implements Database.Batchable<sObject>,schedulable,Database.Stateful{
    
    Integer size=0;
    Integer size1=0;
    
    Global Database.QueryLocator start(Database.BatchableContext bc) {
        String recordType1='Flex Stays Product Voucher';
        String recordType2='Profit Agility Voucher';
        String stageName1='Closed Won';
        String stageName3='Closed Booked';
        String stageName2='Closed Won-Deposit';
        String status1='Cancel';
        String status2='Confirmed';
        String status3='Pending';
        String name1='test';
        String name2='maali';
        String name3='mitul';
        String name4='jenifer lopez';
        String query='select id,opportunity__r.Accountid,opportunity__r.Name,  opportunity__r.StageName from Reservation_Tracking_Object__c where opportunity__r.Bypass_Cadence__c = false and opportunity__c != null and  opportunity__r.Confirmation_Number__c = null AND (NOT opportunity__r.name LIKE \'%' + name2 + '%\' ) AND opportunity__r.Reservation_Status__c = null AND Reservation_Status__c =\''+status1+'\' AND opportunity__r.StageName IN (\''+stageName1+'\', \''+stageName2+'\', \''+stageName3+'\') AND opportunity__r.Record_Type_Name__c NOT IN (\''+recordType1+'\' ,\''+recordType2+'\' ) AND (NOT opportunity__r.name LIKE \'%' + name1 + '%\') AND  (NOT opportunity__r.name LIKE \'%' + name3 + '%\' ) AND (NOT opportunity__r.name LIKE \'%' + name4 + '%\')';
        //String query='Select opportunity__c.Accountid,id from Reservation_Tracking_Object__c where  Reservation_Status__c=\''+status1+'\' AND (Opportunity.Record_Type_Name__c != \''+recordType1+'\' and Opportunity.Record_Type_Name__c != \''+recordType2+'\' )  AND (Opportunity.StageName=\''+stageName1+'\' OR Opportunity.StageName=\''+stageName2+'\' OR Opportunity.StageName=\''+stageName3+'\')  AND (Opportunity.Reservation_Status__c!=\''+status1+'\' AND Opportunity.Reservation_Status__c!=\''+status2+'\' AND Opportunity.Reservation_Status__c!=\''+status3+'\'  ) AND ((NOT Opportunity.Name LIKE \' %' + name1 + '%\' ) AND (NOT Opportunity.Name LIKE \' %' + name2 + '%\' ) AND (NOT Opportunity.Name LIKE \' %' + name3 + '%\' ) AND (NOT Opportunity.Name LIKE \' %' + name4 + '%\' ) ) AND Opportunity.confirmation_number__c=null  ';
        //String query = 'SELECT Id,AccountId,name,Match_Group_Name__c,ownerid,(select id,Reservation_Status__c from Reservation_Tracking_Object__r where Reservation_Status__c=\''+status1+'\') FROM Opportunity Where (Record_Type_Name__c != \''+recordType1+'\' and Record_Type_Name__c != \''+recordType2+'\' )  AND (StageName=\''+stageName1+'\' OR StageName=\''+stageName2+'\' OR StageName=\''+stageName3+'\')  AND (Reservation_Status__c!=\''+status1+'\' AND Reservation_Status__c!=\''+status2+'\' AND Reservation_Status__c!=\''+status3+'\'  ) AND ((NOT Name LIKE \' %' + name1 + '%\' ) AND (NOT Name LIKE \' %' + name2 + '%\' ) AND (NOT Name LIKE \' %' + name3 + '%\' ) AND (NOT Name LIKE \' %' + name4 + '%\' ) ) AND confirmation_number__c=null ' ;
        system.debug('8='+query);
        return Database.getQueryLocator(query);
    }
    
    Global void execute(Database.BatchableContext bc, List<Reservation_Tracking_Object__c> scope) {
        
        Set<ID> AccountId=new set<Id>();
        list<Contact> cadenceContactList= new list<Contact>();
        Set<ID> cadenceContactsId=new set<Id>();
        List<Contact> contactToUpdate=new List<Contact>();
        try{
            
            System.debug('33='+scope.size());
            System.debug('34='+scope[0].opportunity__r.name);
            /*System.debug('34='+scope[0].Reservation_Tracking_Object__r[0].Reservation_Status__c);

lisT<Reservation_Tracking_Object__c> opp2=new list<Reservation_Tracking_Object__c>();
for(Reservation_Tracking_Object__c opp1:scope){
if(opp1.Reservation_Tracking_Object__r.size()!=0){
size=size+1;
opp2.add(opp1);
}
}

system.debug('42='+opp2.size());
*/
            for(Reservation_Tracking_Object__c rto: scope){
                AccountId.add(rto.Opportunity__r.Accountid);
            }
            cadenceContactList=[SELECT Id,Match_Group_Name__c,Affiliate_Name__c,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,AccountId, OwnerId, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact where accountid IN: AccountId and actioncadenceid=null and Parent_Id_Ext_Db__c = null];        
            Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
            for(Contact con:cadenceContactList){
                size1=size1+1;
                if(!contactIdSetMap.containskey(con.Id)){
                    if(con.Affiliate_Name__c.contains('Holidays Lounge')){
                        system.debug('74='+con);
                    }
                    else{
                        con.Assign_to_Sales_Cadence__c=true;
                        con.Match_Group_Name__c='TourGen-Rebook';
                        //con.leadassist__Use_Round_Robin__c='TRUE';
                        contactToUpdate.add(con);
                        cadenceContactsId.add(con.id);            
                        contactIdSetMap.put(con.id,con.id);
                    }
                }
            }
            if(cadenceContactList.size() > 0 ){
                System.debug('89--'+cadenceContactList);
                contactToUpdate = GenericMatchGroupAssignmentHandler.assignMatchGroup(contactToUpdate, 'Assigned');
                update contactToUpdate;
            } 
            if(cadenceContactsId != null){
                System.enqueueJob(new TourGenRebookQueueable(cadenceContactsId));
            }
        }
        catch(Exception e){
            system.debug('277 Exception='+e.getLineNumber());
            system.debug('278 Exception='+e.getMessage());
        }
    }
    
    Global void finish(Database.BatchableContext bc) {
        system.debug('Final size='+size);
        system.debug('Final size contact ='+size1);
        //do something 
    }   
    
    Global void execute(SchedulableContext SC) {
        database.executebatch(new TourGenRebook(),100);
    }
    
}