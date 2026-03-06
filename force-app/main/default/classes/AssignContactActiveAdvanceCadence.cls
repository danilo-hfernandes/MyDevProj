public class AssignContactActiveAdvanceCadence implements Database.Batchable<sObject>,Database.Stateful,schedulable{
        
        public Database.QueryLocator start(Database.BatchableContext bc) {
            
            list<String> Language=new lisT<String>{'Eng','English',''};
           // String test='test';
            String Status='Active';
            String text='Call';
            String text1='Outbound';
            DateTime  Date1 = date.newinstance(2026, 01, 01);
            DateTime  Date2 = date.newinstance(2028, 12, 31);
            String  dueDate1=Date1.format('yyyy-MM-dd');
            String  dueDate2=Date2.format('yyyy-MM-dd');
            String responsibleParty='Member';
            // this Action Cadence ID belongs to TourGen-Active Advantage Program
            String actionCadenceRecordId = Label.Action_Cadence_RecordId;
            System.debug('actionCadenceRecordId'+actionCadenceRecordId);
            
            // Changes Done By Sifra
            // First query to get ActionCadenceTracker records
            List<ActionCadenceTracker> trackers = [
                SELECT TargetId 
                FROM ActionCadenceTracker 
                WHERE State = 'running' 
                AND ActionCadenceId = :actionCadenceRecordId 
            ];
            
            // Extract the TargetId from ActionCadenceTracker records
            List<Id> limitedTargetIds = new List<Id>();
            for (ActionCadenceTracker tracker : trackers) {
                limitedTargetIds.add(tracker.TargetId);
            }
            system.Debug('limitedTargetIds'+limitedTargetIds);
              
           list<String> AffiliateName1=new list<String>{'Carefree Flights','Carefree Destinations','Carefree Destinations FB','SMTN Checkout','Resort Rentals Checkout','Holiday Systems Demo','Vacation Innovations Employee','Vacation Innovations Referral','FastWeeks.Com','Tryp360.Club','FutureStay','SFX - Diamond','SFX - Gold'}; //TGR-542 added to this list: SFX - Diamond, SFX - Gold          

           String query = 'SELECT Id, Match_Group_Name__c, Name, Assign_to_Sales_Cadence__c, AccountId, Cadence_Flag__c, leadassist__Use_Round_Robin__c, ' +
               'Affiliate_Name__c, Active_Advantage_Match_Group__c, Account.Affiliate_Name__c, ' +
               '(SELECT Id, TaskSubtype, Subject, CreatedDate FROM Tasks WHERE Subject LIKE \'%' + text + '%\' ' +
               'OR Subject LIKE \'%' + text1 + '%\') ' +
               'FROM Contact ' +
               'WHERE Marketing_Email_Opt_Out__c = FALSE ' +
               'AND Account.Affiliate_Name__c NOT IN :AffiliateName1 ' +
               'AND Id NOT IN :limitedTargetIds ' +  // Use the extracted list of Ids
               'AND Parent_Id_Ext_Db__c = NULL ' +
               'AND Account.Preferred_Language__c IN :Language ' +
               'AND Account.Membership_Status__c = \'' + Status + '\' ' +
               'AND Account.Dues_Last_Paid_Until__c > ' + dueDate1 + ' ' +
               'AND Account.Dues_Last_Paid_Until__c < ' + dueDate2 + ' ' +
               'AND Master_Record_Id__c != NULL ' +
               'AND Account.Membership_Product_Configuration__r.Responsible_Party__c = \'' + responsibleParty + '\' ' +
               'AND Account.Enrollment_Date__c < N_DAYS_AGO:15 LIMIT 1200';
                //'LIMIT 1200';
              // 'AND Name like \'%' + test + '%\'';
           
        //for test:
        /*
        query = 'SELECT Id, Match_Group_Name__c, Name, Assign_to_Sales_Cadence__c, AccountId, Cadence_Flag__c, leadassist__Use_Round_Robin__c, ' +
               'Affiliate_Name__c, Active_Advantage_Match_Group__c, Account.Affiliate_Name__c, ' +
               '(SELECT Id, TaskSubtype, Subject, CreatedDate FROM Tasks WHERE Subject LIKE \'%' + text + '%\' ' +
               'OR Subject LIKE \'%' + text1 + '%\') ' +
               'FROM Contact ' +
               'WHERE Account.Id IN (\'0064z000028zQIsAAM\',\'0064z000029DQLGAA4\') ' +
               'LIMIT 120';

               'AND Account.Affiliate_Name__c IN (\'SFX - Diamond\',\'SFX - Gold\') ' +
               'AND Account.Id IN (\'0064z000028zQIsAAM\',\'0064z000029DQLGAA4\') ' +
			*/  
            
            
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
            For(Opportunity opp:[Select id,accountid from opportunity where record_type_name__c='Voucher' and (createddate=THIS_YEAR OR Arrival_Date__c=THIS_YEAR) and accountid IN: accountIds]){
                voucherAccountIds.add(opp.accountid);
                 System.debug('76--'+voucherAccountIds);
            }
			System.debug('761-scope-'+scope);
            for(contact con:scope){
				System.debug('762--voucherAccountIds '+voucherAccountIds);
				System.debug('763--con.AccountId '+con.AccountId);
                if(!voucherAccountIds.contains(con.AccountId)){
                    System.debug('764--con.tasks.size() '+con.tasks.size());
                    if(con.tasks.size()==0){
                        cadenceContacts.add(con);
                    }
                    else{
                        System.debug('765--con.tasks '+con.tasks);
                        for(task t: con.tasks){
                            system.debug('35=='+t.CreatedDate);
                            if(t.createddate>system.today()-14){
                                System.debug('91--'+t.createddate); 
                                System.debug('92--'+system.today()); 
                                check=1;
                                break;
                            }
                        }
                        System.debug('766--check '+check);
                        if(check==0){
                            System.debug('99--'+cadenceContacts);     
                            cadenceContacts.add(con);
                        }
                    }
                    check=0; 
                }  
                
            }

            System.debug('cadenceContacts--'+cadenceContacts);
            
            Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
            for(Contact con : cadenceContacts)
            {
                if(!contactIdSetMap.containskey(con.Id)){
                    System.debug('111--');
                    if(con.Affiliate_Name__c.contains('Holidays Lounge')){
                        system.debug('74='+con);
                    }
                    else{
                        System.debug('116--');
                    //con.leadassist__Use_Round_Robin__c='TRUE';
                    con.Assign_to_Sales_Cadence__c=true;
                    con.Cadence_Flag__c=1;
                    con.Active_Advantage_Match_Group__c='TRUE';
                    //con.Match_Group_Name__c='TourGen-Active Advantage Program';
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

        System.debug('cadenceContactsId--'+cadenceContactsId);
            
        System.enqueueJob(new AssignContactAdvanceQueueable(cadenceContactsId)); 
        }
        public void finish(Database.BatchableContext bc) {
            //do something 
        }   
        
        public void execute(SchedulableContext SC) {
            database.executebatch(new AssignContactActiveAdvanceCadence(),100);
        }
    }