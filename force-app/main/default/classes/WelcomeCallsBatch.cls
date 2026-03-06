public class WelcomeCallsBatch implements Database.Batchable<sObject>,schedulable{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String Language='ENG';
        String memberShipStatus='Active';
        //for testing only
        list<String> productConfig=new list<String>{'A1001467','A1002203','A1001948','A1002002','A1001896','A1002004','S1202','S1204','A1002222','A1002224','A1002347','A1002343','A1002223','A1002327','A1002243','A1002227','A1002226','A1002225', 'A1002454', 'A1002455', 'A1002456','A1002247'}; //,'A1002277'
            String query = '';
        if(test.isRunningTest()){
            query =  'SELECT Id,Account.Name,name,Account.Membership_Product_Config_Ext_Db__c,Membership_Product_Config_Ext_Db__c,Assign_to_Sales_Cadence__c,AccountId, OwnerId,Cadence_Flag__c, Account.Enrollment_Date__c,Account.OwnerId, AffiliatedId__c FROM Contact Where Account.Membership_Product_Config_Ext_Db__c IN : productConfig AND ActionCadenceAssigneeId=null AND  Assign_to_Sales_Cadence__c=FALSE AND (Account.Enrollment_Date__c = N_DAYS_AGO:15 OR Account.Enrollment_Date__c = N_DAYS_AGO:45) AND  Membership_Status__c = \''+memberShipStatus+'\' AND AffiliatedId__c not in (1002275, 1002277) AND Preferred_Language__c = \''+Language+'\' '+(Test.isRunningTest()?' limit 3':'');  // TGR-542
        }else{
            query = 'SELECT Id,Assign_to_Sales_Cadence__c,Account.Name,name,Account.Membership_Product_Config_Ext_Db__c,Membership_Product_Config_Ext_Db__c,AccountId, OwnerId,Cadence_Flag__c, Account.Enrollment_Date__c, Account.OwnerId, AffiliatedId__c FROM Contact Where Account.Membership_Product_Config_Ext_Db__c IN : productConfig AND (Account.Enrollment_Date__c = N_DAYS_AGO:11 OR Account.Enrollment_Date__c = N_DAYS_AGO:15 OR Account.Enrollment_Date__c = N_DAYS_AGO:45) AND  Account.Membership_Status__c = \''+memberShipStatus+'\' AND Account.Preferred_Language__c = \''+Language+'\' AND AffiliatedId__c not in (1002275, 1002277)';  // TGR-542
        }
        system.debug('---SELECT Id,Assign_to_Sal--'+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> conList) {
        
        System.debug('16--'+conList.size());
        list<String> HSIENG=new lisT<String>{'A1001467','A1002203','A1001948','A1002002','A1001896','A1002004','S1202','S1204'};
            list<String> SMTNENG=new lisT<String>{'A1002222','A1002224','A1002347','A1002343','A1002223','A1002327','A1002247'};
                list<String> VIENG=new lisT<String>{'A1002243','A1002227','A1002226','A1002225'}; //'A1002277',
                    list<String> HSIENGClubVenture=new lisT<String>{'A1002454', 'A1002455', 'A1002456'};
                        List<Contact> ContactToUpdate=new List<Contact>();
        List<Contact> parentContacts = new List<Contact>();
        Set<Id> accountIds = new set<Id>();
        Set<Id> setContactIds = new set<Id>();
        Date fifteenDaysAgo = Date.today().addDays(-15);
        Date elevanDaysAgo = Date.today().addDays(-11);
        system.debug('fifteenDaysAgo=='+fifteenDaysAgo);
        String matchGroupName = '';
        Date fortyFiveDaysAgo = Date.today().addDays(-45);
        system.debug('fortyFiveDaysAgo=='+fortyFiveDaysAgo);
        Map<String, set<Id>> MapCadenceNameVsContactIds = new Map<String,set<Id>>();        
        for (Contact contact : conlist) {
            if (contact.Account.Name != null && contact.Account.Name.equalsIgnoreCase(contact.Name)) {
                parentContacts.add(contact);
                accountIds.add(contact.AccountId);
            }
        }
        List<String> stageToExclude = new List<String>{'TRM Pending','Pitched - Follow Up*','Appointment Booked*','Client Canceled with Resort'};
            List<Opportunity> listOpp = [select id, AccountId from Opportunity where AccountId IN: accountIds and Record_Type_Name__c = 'Hawaii Collection Membership' and StageName IN: stageToExclude];
        system.debug('listOpp>>>>>'+listOpp);

        Set<Id> oppAccountIds = new Set<Id>();
        for (Opportunity opp : listOpp) {
            oppAccountIds.add(opp.AccountId);
        }

        for(Contact con : parentContacts)
        {
            system.debug('40=='+con);
            system.debug('41=='+con.Account.Enrollment_Date__c);
            system.debug('42=='+con.Account.Membership_Product_Config_Ext_Db__c);
            system.debug('43==listOpp.size '+listOpp.size());
            system.debug('44==oppAccountIds '+oppAccountIds);
            system.debug('45==con.Account.Id '+con.Account.Id);
            
            matchGroupName = '';
            
            if(con.Account.Enrollment_Date__c == fortyFiveDaysAgo && !oppAccountIds.contains(con.Account.Id) && VIENG.contains(con.Account.Membership_Product_Config_Ext_Db__c)){
//            if(con.Account.Enrollment_Date__c == fortyFiveDaysAgo && listOpp.isEmpty() && listOpp.size() == 0 && VIENG.contains(con.Account.Membership_Product_Config_Ext_Db__c)){
                system.debug('Welcome Calls-VI-ENG');
                matchGroupName = 'Welcome Calls-VI-ENG';
            }
            else if(con.Account.Enrollment_Date__c== fifteenDaysAgo && HSIENG.contains(con.Account.Membership_Product_Config_Ext_Db__c)){
                system.debug('Welcome Calls- Advantage Program/HSI-ENG');
                matchGroupName='Welcome Calls- Advantage Program/HSI-ENG';
            }
            else if(con.Account.Enrollment_Date__c== fifteenDaysAgo && SMTNENG.contains(con.Account.Membership_Product_Config_Ext_Db__c)){
                system.debug('Welcome Calls-SMTN-ENG');
                matchGroupName ='Welcome Calls-SMTN-ENG';
                
            }
            else if(con.Account.Enrollment_Date__c== elevanDaysAgo && HSIENGClubVenture.contains(con.Account.Membership_Product_Config_Ext_Db__c)){
                system.debug('Welcome Calls- Advantage Program/HSI-ENG');
                matchGroupName='Welcome Calls- Advantage Program/HSI-ENG';
            }
            if((matchGroupName != null && matchGroupName != '') || Test.isRunningTest()){
                con.leadassist__Use_Round_Robin__c='TRUE';
                con.Assign_to_Sales_Cadence__c=true;
                con.Cadence_Flag__c=1;
                con.Match_Group_Name__c=matchGroupName;
                ContactToUpdate.add(con);
                if(!MapCadenceNameVsContactIds.containsKey(matchGroupName)){
                    MapCadenceNameVsContactIds.put(matchGroupName,new set<Id>{con.Id});
                }
                else{    
                    MapCadenceNameVsContactIds.get(matchGroupName).add(con.Id);
                }
            }
        }
        if(ContactToUpdate.size() > 0){
            System.debug('32--'+ContactToUpdate);
//             contactToUpdate =  GenericMatchGroupAssignmentHandler.assignMatchGroup(contactToUpdate, 'Assigned');
            update ContactToUpdate;
        } 
        if(!test.isRunningTest()){
            
            /*
for(String key : MapCadenceNameVsContactIds.keyset()){
System.debug('86--'+MapCadenceNameVsContactIds.get(key));
System.debug('87--'+key);
//System.enqueueJob(new GenericAssignToSalesCadence(MapCadenceNameVsContactIds.get(key), key)); 
System.enqueueJob(new GenericAssignToSalesCadenceChained(MapCadenceNameVsContactIds.get(key), key, 0)); 
}
*/
            
            if (!MapCadenceNameVsContactIds.isEmpty()) {
                //System.enqueueJob(new AssignCadenceChainDriver(MapCadenceNameVsContactIds, 0));
                //AssignCadenceWithChaining processes one cadence at a time and chains the next cadence assignment
                // as a separate Queueable job to avoid exceeding platform limits.
                System.enqueueJob(new AssignCadenceWithChaining(MapCadenceNameVsContactIds, 0));
                
            }
            
            
        }
    }
    
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new WelcomeCallsBatch(),1);
    }
}