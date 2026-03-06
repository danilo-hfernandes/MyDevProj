public class TimeshareTriggerHandler {
    public static void CreateOpportunityBasedOnDuplicates(List<Timeshare__c> lstTimeshare){
        try{
            List<Id> userList = new List<Id>();
            String devAccountId = '';
            for(User objuser : [SELECT Id,Username, Name FROM User WHERE Name = 'Dev Account' or Name= 'Salesforce' LIMIT 2]){
                userList.add(objuser.Id);
                if(objuser.Name == 'Dev Account'){
                    devAccountId = objuser.Id;
                }
            }
            DateTime past45Days = system.now().addDays(-45); 
            
            Set<Id> setAccountIds = new Set<Id>();
            Set<Id> setTimeshareIds = new Set<Id>();
            Set<Integer> PTPAffiliateId = new Set<Integer>{1002248,1002249,1002250};
                for(Timeshare__c objtimeshare : lstTimeshare){
                    if(objtimeshare.Timeshare_Owner__c != null && userList.contains(objtimeshare.CreatedById)){
                        setAccountIds.add(objtimeshare.Timeshare_Owner__c);
                        setTimeshareIds.add(objtimeshare.Id);
                    }
                }
            System.debug('>>>>setTimeshareIds>>>>'+setTimeshareIds);
            if(setAccountIds != null && setAccountIds.size() > 0){
                List<Opportunity> lstOpportunity = new List<Opportunity>();
                List<Account> lstAccount = [select id, Affiliated_Id__c,(select id, CreatedDate from Timeshares__r where ID NOT IN: setTimeshareIds order by CreatedDate Desc limit 1) from Account where Id IN : setAccountIds ];//and Affiliated_Id__c != 1002460
                system.debug('>>>>>>>>lstAccount>>>>>'+lstAccount);
                if(lstAccount != null && lstAccount.size() > 0){
                    
                    List<Affiliated_Id_and_Name__c> affCustomSetting = [select Affiliated_Id__c,Affiliate_Name__c,Opportunity_Record_Type__c from Affiliated_Id_and_Name__c];
                    Map<String,String> idNameMapping = new Map<String,String>();
                    for(Affiliated_Id_and_Name__c aff : affCustomSetting){
                        idNameMapping.put(aff.Affiliated_Id__c,aff.Opportunity_Record_Type__c);
                    }
                    
                    for(Account objacc : lstAccount){
                        Integer affId = Integer.valueOf(objacc.Affiliated_Id__c);
                        if(objacc.Timeshares__r.size() > 0 && !PTPAffiliateId.contains(affId)){
                           // if(!(objacc.Timeshares__r.size() >= 2 && objacc.Timeshares__r[0].CreatedDate.date() == objacc.Timeshares__r[1].CreatedDate.date())){
                                SYSTEM.DEBUG(objacc.Timeshares__r[0].CreatedDate);
                                if(objacc.Timeshares__r[0].CreatedDate <= past45Days){
                                    String oppRecordTypeId = '';
                                    system.debug('idNameMapping'+idNameMapping.get(string.valueof(objacc.Affiliated_Id__c)));
                                    if(idNameMapping.containskey(string.valueof(objacc.Affiliated_Id__c))){
                                        system.debug('idNameMapping'+idNameMapping.get(string.valueof(objacc.Affiliated_Id__c)));
                                        oppRecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(idNameMapping.get(string.valueof(objacc.Affiliated_Id__c))).getRecordTypeId();
                                    }else{
                                        oppRecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('MTRC Membership Upgrade').getRecordTypeId();
                                        system.debug('idNameMapping'+idNameMapping.get(string.valueof(objacc.Affiliated_Id__c)));
                                    }
                                    system.debug('--oppRecordTypeId--'+oppRecordTypeId);
                                    Opportunity opp = new Opportunity();
                                    opp.Name = 'Hawaii Collection Membership';
                                    opp.StageName = 'New';
                                    opp.CloseDate = System.today();
                                    opp.RecordTypeId = oppRecordTypeId;
                                    opp.AccountId = objacc.Id;
                                    opp.Timeshare_1__c = objacc.Timeshares__r[0].Id;
                                    opp.OwnerId = devAccountId;
                                    lstOpportunity.add(opp);
                                }
                           // }
                        }
                    }
                    system.debug('>>>>>>lstOpportunity>>>>>>>>'+lstOpportunity);
                    if(lstOpportunity != null && lstOpportunity.size() > 0){
                        insert lstOpportunity;
                    }
                }
            }
        }catch(Exception e){
            system.debug('>>>>>Exception>>>'+e.getMessage());
        }
    }
    public static void CreateOppoForHCAffiliateReturn(List<Timeshare__c> lsttimeshare){
        Set<Id> setAccountIds = new Set<Id>();
        Set<Id> setTimeshareIds = new Set<Id>();
        for(Timeshare__c objtimeshare : lstTimeshare){
            if(objtimeshare.Timeshare_Owner__c != null){
                setAccountIds.add(objtimeshare.Timeshare_Owner__c);
                setTimeshareIds.add(objtimeshare.Id);
            }
        }
        system.debug('>>>>>>>>setAccountIds>>>>>'+setAccountIds);
        system.debug('>>>>>>>>setTimeshareIds>>>>'+setTimeshareIds);
        if(setAccountIds != null && setAccountIds.size() > 0){
            List<Timeshare__c> timeshareList = [select id from Timeshare__c where Timeshare_Owner__c IN: setAccountIds and Id NOT IN: setTimeshareIds];
            system.debug('>>>>>>>>timeshareList>>>>>'+timeshareList);
            if(timeshareList != null && timeshareList.size() > 0){
                List<Opportunity> lstOpportunity = new List<Opportunity>();
                String oppRecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Hawaii Collection Membership').getRecordTypeId();
                List<Account> lstAccount = [select id, Affiliated_Id__c,CreatedDate,LastModifiedDate,LastModifiedById,Affiliate_Name__c,Affiliate_Name_F__c,Preferred_Language__c,(select id, CreatedDate,CreatedById from Timeshares__r where ID IN: setTimeshareIds limit 1), (select id from Opportunities where IsClosed = false and RecordTypeId = : oppRecordTypeId and CreatedDate = LAST_N_DAYS : 365 Order by CreatedDate DESC limit 1) from Account where Id IN : setAccountIds];
                system.debug('>>>>>>>>lstAccount>>>>>'+lstAccount);
                if(lstAccount != null && lstAccount.size() > 0){
                    
                    String devAccountId =  [SELECT Id FROM User WHERE Name = 'Dev Account' LIMIT 1].Id;
                    
                    for(Account objacc : lstAccount){
                        if(!(objacc.Opportunities.size() > 0)){
                            if(objacc.Timeshares__r.size() > 0){
                                system.debug('>>>>>>>>objacc.Timeshares__r[0]>>>>>'+objacc.Timeshares__r[0]);
                                system.debug('>>>>>>>>objacc>>>>'+objacc);
                                SYSTEM.DEBUG(objacc.Timeshares__r[0].CreatedDate.date());
                                SYSTEM.DEBUG(objacc.LastModifiedDate.date());
                                if(objacc.Preferred_Language__c == 'SPA' && objacc.Timeshares__r[0].CreatedDate.date() != objacc.CreatedDate.date() && objacc.Timeshares__r[0].CreatedDate.date() == objacc.LastModifiedDate.date() && objacc.Timeshares__r[0].CreatedById == objacc.LastModifiedById && objacc.Affiliate_Name_F__c == 'Hawaii Collection' && objacc.Affiliated_Id__c == 1002243){
                                    Opportunity opp = new Opportunity();
                                    opp.Name = 'Hawaii Collection Membership';
                                    opp.StageName = 'New';
                                    opp.CloseDate = System.today();
                                    opp.RecordTypeId = oppRecordTypeId;
                                    opp.AccountId = objacc.Id;
                                    opp.Timeshare_1__c = objacc.Timeshares__r[0].Id;
                                    opp.OwnerId = devAccountId;
                                    lstOpportunity.add(opp);	
                                }
                            }
                        }
                    }
                }
                system.debug('>>>>>>lstOpportunity>>>>>>>>'+lstOpportunity);
                if(lstOpportunity != null && lstOpportunity.size() > 0){
                    insert lstOpportunity;
                }
            }
        }
        
    }
}