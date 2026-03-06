public class accountHawaaiOpp implements Database.Batchable<sObject>,Database.Stateful{
    
    public  Integer recordCount=0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        system.debug('5');
        String recordType='0123t000000mliUAAQ';
        String query = 'Select id ,Phone,name,(Select id from Opportunities where RecordTypeId=\''+recordType+'\') from account where Affiliated_Id__c = 1002243 AND Membership_Status__c != \'FrozenByResort\' AND Membership_Status__c != \'FrozenByHSI\' AND  Membership_Status__c != \'FrozenForEADiscrepancy\'';
        system.debug('8='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Account> scope) {
        
        Map<String, Id> idPhoneMap = new Map<String, Id>();
        Set<Account> selectedAccount= new set<Account>();
        list<opportunity> newOpp= new list<Opportunity>();
        MU_Jobs_test_Record_Filter__c testRecordsFilterSettings = MU_Jobs_test_Record_Filter__c.getValues('Filters Enabled');
        
        system.debug('13='+scope.size());
        system.debug('17='+scope);
        system.debug('testRecordsFilterSettings='+testRecordsFilterSettings);
        
        for(Account acc: scope){
            //if the custom settings is not checked, this job will run for _test accounts
            if(((!acc.Name.contains('_test')) && (!acc.Name.contains('_Test'))) || !(testRecordsFilterSettings != null && testRecordsFilterSettings.Hawaii_Collection__c)){
                if(idPhoneMap.get(acc.Phone) == null && acc.Opportunities.size()==0){
                    idPhoneMap.put(acc.Phone,acc.Id);
                    selectedAccount.add(acc);
                    
                }
            }
        }  
        
        String CraigOwnerId=[Select id from user where name='Craig Becker' limit 1].id;
        String MyaraownerId=[Select id from user where name='Myara Patterson' limit 1].id;
        String MembershipOwnerId=[Select id from user where name='Membership Upgrade Manager' limit 1].id;
        
        
        
        
        
        system.debug('21='+selectedAccount.size());
        system.debug('22='+selectedAccount);
        
        for(Account acc:selectedAccount){
            
            // Owner is Craig
            if(recordCount<50){
                
                
                
                Opportunity opp=new opportunity();
                opp.name=acc.name;
                opp.StageName='New';
                opp.ownerId=CraigOwnerId;
                opp.AccountId=acc.id;
                opp.RecordTypeId='0123t000000mliUAAQ';
                opp.CloseDate=system.today()-71;
                newOpp.add(opp);
                
            }
            // Owner is Myara
            else if(recordCount>49 && recordCount<100){
                
                
                Opportunity opp=new opportunity();
                opp.name=acc.name;
                opp.StageName='New';
                opp.ownerid=MyaraownerId;
                opp.AccountId=acc.id;
                opp.RecordTypeId='0123t000000mliUAAQ';
                opp.CloseDate=system.today()-71;
                newOpp.add(opp);
            }
            // Owner is Charlie
            else if(recordCount>99 && recordCount<150){
                
                
                Opportunity opp=new opportunity();
                opp.name=acc.name;
                opp.AccountId=acc.id;
                opp.StageName='New';
               // opp.ownerId=CharlieOwnerId;
                opp.RecordTypeId='0123t000000mliUAAQ';
                opp.CloseDate=system.today()-71;
                newOpp.add(opp);
            }
            // Owner is Chiena
            else if(recordCount>149 && recordCount<200){
                
                
                Opportunity opp=new opportunity();
                opp.name=acc.name;
                opp.StageName='New';
               // opp.ownerId=ChienaOwnerId;
                opp.AccountId=acc.id;
                opp.RecordTypeId='0123t000000mliUAAQ';
                opp.CloseDate=system.today()-71;
                newOpp.add(opp);
            }
            // Owner is Marlon
            else if(recordCount>199 && recordCount<250){
                
                
                Opportunity opp=new opportunity();
                opp.name=acc.name;
                opp.StageName='New';
               // opp.ownerId=MarlonOwnerId;
               opp.AccountId=acc.id;
                opp.RecordTypeId='0123t000000mliUAAQ';
                opp.CloseDate=system.today()-71;
                newOpp.add(opp);
            }
            else{
                
                
                Opportunity opp=new opportunity();
                opp.name=acc.name;
                opp.StageName='New';
                opp.ownerId=MembershipOwnerId;
                opp.AccountId=acc.id;
                opp.RecordTypeId='0123t000000mliUAAQ';
                opp.CloseDate=system.today()-71;
                newOpp.add(opp);
                
            }
            recordCount++;
        }
        
        system.debug('33='+newOpp.size());
        system.debug('36='+newOpp);
        insert newOpp;
        system.debug('125='+newOpp[0].id);
        
        
        
        
    }
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    
}