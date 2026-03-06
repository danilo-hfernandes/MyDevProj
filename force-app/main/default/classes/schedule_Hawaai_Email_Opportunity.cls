public class schedule_Hawaai_Email_Opportunity implements Database.Batchable<sObject>,schedulable{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('4');
        String AffilatedId = Label.Affiliated_Id;
        Set<Integer> affilateIDSet = new Set<Integer>{ 1002243,1002310,1002311,1002312};
            String stageName='New';
        String UseRoundRobin='FALSE';
        ID ownerId= [SELECT Id FROM User where name='Dev Account' LIMIT 1].id;
        String recordTypeName='Hawaii Collection Membership';
        //String query = 'SELECT Id,Name,AccountId,Account.First_Name__c,Account.email__c,Account_Enrollment_Date__c,ownerid,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Automated_Hawaii_Opportunity__c,Membership_Upgrade_Group__c from opportunity where Account_Affiliate_Id__c='+AffilatedId+' AND StageName=\''+stageName+'\' AND leadassist__Use_Round_Robin__c=\''+UseRoundRobin+'\' AND Automated_Hawaii_Opportunity__c= true AND OwnerId = \''+ownerId+'\' AND Account_Enrollment_Date__c <= N_DAYS_AGO:10 AND Record_Type_Name__c=\''+recordTypeName+'\'' +(Test.isRunningTest()?' limit 20':'');
        String query = 'SELECT Id,Name,AccountId,Account.First_Name__c,Account.email__c,Account_Enrollment_Date__c,ownerid,leadassist__Use_Round_Robin__c,Account.TRM_Owner_Flag__c,Account.Preferred_Language__c,Automated_Hawaii_Opportunity__c,Membership_Upgrade_Group__c from opportunity where Account_Affiliate_Id__c IN :affilateIDSet  AND StageName=\''+stageName+'\' AND leadassist__Use_Round_Robin__c=\''+UseRoundRobin+'\' AND  OwnerId = \''+ownerId+'\' AND Account_Enrollment_Date__c <= N_DAYS_AGO:15 AND Record_Type_Name__c=\''+recordTypeName+'\'' +(Test.isRunningTest()?' limit 20':'');
        
        system.debug('9='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        
        system.debug('13='+scope);
        list<String> oppAccountId=new list<String>();
        list<Account> oppAccountList= new list<Account>();
        map<String,list<String>> accountWithTimeShareMap =new map<String,list<String>>();
        list<Opportunity> upgradeGroupSPAList= new list<Opportunity>();
        
        list<Opportunity> upgradeGroupTRMList= new list<Opportunity>();
        list<Opportunity> upgradeGroupGradeAList= new list<Opportunity>();
        list<Opportunity> upgradeGroupGradeBList= new list<Opportunity>();
        list<Opportunity> upgradeGroupGradeCList= new list<Opportunity>();
        list<Opportunity> upgradeGroupList= new list<Opportunity>();
        list<Opportunity> upgradeGroupGradeABList= new list<Opportunity>();
        set<Id> setOppTask = new set<Id>();
        list<Task> tasklist = new list<Task>();
        list<String> gradeAList=new list<String>{'The Estates East Cape','The Estates Puerto Vallarta','Grand Luxxe Nuevo Vallarta', 'Emperors Private Reserve Puerto Vallarta','Legacy Park Resort Nuevo Vallarta'};
            list<String> gradeBList=new list<String>{'Imperial Gardens Nuevo Vallarta','Deluxxe at the Grand Mayan Nuevo Vallarta','Deluxxe at the Grand Mayan Riviera Maya'};
                list<String> gradeCList=new list<String>{'Kingdom Of The Sun III','Imperial Jungle Aqua'};
                    //list<String> gradeABList=new  list<String>{'The Estates East Cape','The Estates Puerto Vallarta','Grand Luxxe Nuevo Vallarta','Imperial Gardens Nuevo Vallarta','Deluxxe at the Grand Mayan Nuevo Vallarta'};
                    //Update List
                    list<String> gradeASPAList=new  list<String>{'The Estates East Cape','The Estates Puerto Vallarta','Emperors Private Reserve Puerto Vallarta','Legacy Park Resort Nuevo Vallarta'};
                        list<String> gradeBSPAList=new list<String>{'Grand Luxxe Nuevo Vallarta', 'Deluxxe at the Grand Mayan Nuevo Vallarta','Deluxxe at the Grand Mayan Riviera Maya'};
                            list<String> gradeCSPAList=new list<String>{'Kingdom Of The Sun III','Imperial Jungle Aqua', 'Imperial Gardens Nuevo Vallarta'}; 
                                //Fetching Opportunitu Account Ids 
                                for(Opportunity opp:scope){
                                    oppAccountId.add(opp.AccountId);
                                }
        System.debug('31='+oppAccountId);
        
        oppAccountList=[Select id,name,(select id,name,CreatedDate from Timeshares__r order by CreatedDate Desc) from account where id IN: oppAccountId];
        DateTime past45Days = system.now().addDays(-45); 
        map<String, String> mapAccIdToMembershipUpgrade = new map<String, String>();
        System.debug('35='+oppAccountList);
        // Creating map of AccountId with their timeShare unit_type__c
        for(Account acc: OppAccountList){
            if(acc.Timeshares__r.size()!=0){
                // For Single Timeshare
                if(acc.Timeshares__r.size() == 1){
                    if(!accountWithTimeShareMap.keyset().contains(acc.id)){
                        accountWithTimeShareMap.put(acc.id,new List<String>());
                    }
                    accountWithTimeShareMap.get(acc.id).add(acc.Timeshares__r[0].name);
                }
                // For Duplicate Timeshares
                else{
                    for(Timeshare__c tm: acc.Timeshares__r){
                        if(tm.CreatedDate <= past45Days && !mapAccIdToMembershipUpgrade.containsKey(acc.id)){
                            mapAccIdToMembershipUpgrade.put(acc.id, 'Membership Upgrade');
                        }
                    }
                }
                /* for(Timeshare__c tm: acc.Timeshares__r ){
if(!accountWithTimeShareMap.keyset().contains(acc.id)){
accountWithTimeShareMap.put(acc.id,new List<String>());
}
accountWithTimeShareMap.get(acc.id).add(tm.name);
}*/
            }
        }
        System.debug('48='+accountWithTimeShareMap);        
        for(Opportunity opp: scope){
            System.debug('52='+opp);
            Boolean gradeA=false;
            Boolean gradeB=false;
            Boolean gradeC=false;
            Boolean gradeAB=false;
            if(mapAccIdToMembershipUpgrade!= null && mapAccIdToMembershipUpgrade.containsKey(opp.accountId)){
                opp.leadassist__Use_Round_Robin__c='TRUE';
                //HSIMU2-559 If duplicate more than 45 days, assign to below default matchgroups based on language
                if(opp.Account.Preferred_Language__c=='SPA')
                {
                    opp.Membership_Upgrade_Group__c='SPA';
                    upgradeGroupSPAList.add(opp);
                }
                else{
                    opp.Membership_Upgrade_Group__c='NULL';
                    upgradeGroupList.add(opp);
                }
                setOppTask.add(opp.Id);
            }
            // Determining if opp is in gradeA, gradeB or gradeC
            else if(accountWithTimeShareMap.containsKey(opp.accountId) && accountWithTimeShareMap.get(opp.accountId)!=null){
                for(String unitType: accountWithTimeShareMap.get(opp.accountId)){
                    if(opp.Account.Preferred_Language__c=='ENG'){
                        if(gradeAList.contains(unitType)){
                            gradeA=true;
                            break;
                        }
                        else if(gradeBList.contains(unitType)){
                            gradeB=true;
                            //gradeAB=true;
                        }
                        else if(gradeCList.contains(unitType)){
                            gradeC=true;
                        }
                    }
                    else if(opp.Account.Preferred_Language__c=='SPA'){
                        if(gradeASPAList.contains(unitType)){
                            gradeA=true;
                            break;
                        }
                        else if(gradeBSPAList.contains(unitType)){
                            gradeB=true;
                            //gradeAB=true;
                        }
                        else if(gradeCSPAList.contains(unitType)){
                            gradeC=true;
                        }
                    }
                }
                
                System.debug('74='+gradeA+'-'+gradeB+'-'+gradeC+'-'+gradeAB);
                
                // Filtering out the opp in different list accodring to the criteria
                if(opp.Account.TRM_Owner_Flag__c=='Yes'){// && opp.Account_Enrollment_Date__c <= Date.Today().addDays(-25)
                    if(opp.Account.Preferred_Language__c=='SPA' && opp.Account_Enrollment_Date__c <= Date.Today().addDays(-10)){
                        if(gradeC==false && gradeB==false && gradeA==false){
                            opp.leadassist__Use_Round_Robin__c='TRUE';
                            opp.Membership_Upgrade_Group__c='SPA';
                            upgradeGroupSPAList.add(opp);
                            setOppTask.add(opp.Id);
                        }
                        if(gradeA==true && gradeB==false && gradeC==false){
                            opp.leadassist__Use_Round_Robin__c='TRUE';
                            opp.Membership_Upgrade_Group__c='gradeA-SPA';
                            upgradeGroupGradeAList.add(opp);
                            setOppTask.add(opp.Id);                    
                        }
                        else if(gradeB==true && gradeA==false && gradeC==false ){
                            opp.leadassist__Use_Round_Robin__c='TRUE';
                            opp.Membership_Upgrade_Group__c='gradeB-SPA';
                            upgradeGroupGradeBList.add(opp);   
                            setOppTask.add(opp.Id);
                        }
                        else if(gradeC==true && gradeB==false && gradeA==false ){
                            opp.leadassist__Use_Round_Robin__c='TRUE';
                            opp.Membership_Upgrade_Group__c='gradeC-SPA';
                            upgradeGroupGradeCList.add(opp); 
                            setOppTask.add(opp.Id);
                        }
                    }
                    else if(opp.Account_Enrollment_Date__c <= Date.Today().addDays(-15)){
                        if(opp.Account.Preferred_Language__c=='ENG' && gradeA==true && gradeB==false && gradeC==false){
                            opp.leadassist__Use_Round_Robin__c='TRUE';
                            opp.Membership_Upgrade_Group__c='gradeA';
                            upgradeGroupGradeAList.add(opp);
                            setOppTask.add(opp.Id);                    
                        }
                        else if(opp.Account.Preferred_Language__c=='ENG' && gradeB==true && gradeA==false && gradeC==false ){
                            opp.leadassist__Use_Round_Robin__c='TRUE';
                            opp.Membership_Upgrade_Group__c='gradeB';
                            upgradeGroupGradeBList.add(opp);   
                            setOppTask.add(opp.Id);
                        }
                        else if(opp.Account.Preferred_Language__c=='ENG' && gradeC==true && gradeB==false && gradeA==false ){
                            opp.leadassist__Use_Round_Robin__c='TRUE';
                            opp.Membership_Upgrade_Group__c='gradeC';
                            upgradeGroupGradeCList.add(opp); 
                            setOppTask.add(opp.Id);
                        }
                        else if(opp.Account.Preferred_Language__c=='ENG' && gradeC==false && gradeB==false && gradeA==false && gradeAB==false){                    
                            opp.leadassist__Use_Round_Robin__c='TRUE';
                            opp.Membership_Upgrade_Group__c='NULL';
                            upgradeGroupList.add(opp); 
                            setOppTask.add(opp.Id);
                        }
                    }
                }
                //HSIMU2-559 - Remove the trm flag= no or null for the Membership Upgrade HC_Spa matchgroup/sales cadence
                else if(/*(opp.Account.TRM_Owner_Flag__c=='No' || opp.Account.TRM_Owner_Flag__c==null) &&*/opp.Account_Enrollment_Date__c <= Date.Today().addDays(-10)){                    
                    if(opp.Account.Preferred_Language__c=='SPA' && gradeC==false && gradeB==false && gradeA==false && opp.Account_Enrollment_Date__c <= Date.Today().addDays(-10)){
                        opp.leadassist__Use_Round_Robin__c='TRUE';
                        opp.Membership_Upgrade_Group__c='SPA';
                        upgradeGroupSPAList.add(opp);
                        setOppTask.add(opp.Id);
                    }
                    else if(opp.Account.Preferred_Language__c=='ENG' && gradeA==true && gradeB==false && gradeC==false  ){
                        opp.leadassist__Use_Round_Robin__c='TRUE';
                        opp.Membership_Upgrade_Group__c='gradeA';
                        upgradeGroupGradeAList.add(opp);
                        setOppTask.add(opp.Id);                    
                    }
                    else if(opp.Account.Preferred_Language__c=='ENG' && gradeB==true && gradeA==false && gradeC==false ){
                        opp.leadassist__Use_Round_Robin__c='TRUE';
                        opp.Membership_Upgrade_Group__c='gradeB';
                        upgradeGroupGradeBList.add(opp);   
                        setOppTask.add(opp.Id);
                    }
                    else if(opp.Account.Preferred_Language__c=='ENG' && gradeC==true && gradeB==false && gradeA==false ){
                        opp.leadassist__Use_Round_Robin__c='TRUE';
                        opp.Membership_Upgrade_Group__c='gradeC';
                        upgradeGroupGradeCList.add(opp); 
                        setOppTask.add(opp.Id);
                    }
                    if(opp.Account.Preferred_Language__c=='SPA'){
                        if(gradeA==true && gradeB==false && gradeC==false && opp.Account_Enrollment_Date__c <= Date.Today().addDays(-10)){
                            opp.leadassist__Use_Round_Robin__c='TRUE';
                            opp.Membership_Upgrade_Group__c='gradeA-SPA';
                            upgradeGroupGradeAList.add(opp);
                            setOppTask.add(opp.Id);                    
                        }
                        
                        else if(gradeB==true && gradeA==false && gradeC==false ){
                            opp.leadassist__Use_Round_Robin__c='TRUE';
                            opp.Membership_Upgrade_Group__c='gradeB-SPA';
                            upgradeGroupGradeBList.add(opp);   
                            setOppTask.add(opp.Id);
                        }
                        
                        else if(gradeC==true && gradeB==false && gradeA==false ){
                            opp.leadassist__Use_Round_Robin__c='TRUE';
                            opp.Membership_Upgrade_Group__c='gradeC-SPA';
                            upgradeGroupGradeCList.add(opp); 
                            setOppTask.add(opp.Id);
                        }
                    }
                    else if(opp.Account.Preferred_Language__c=='ENG' && gradeC==false && gradeB==false && gradeA==false && gradeAB==false){
                        opp.leadassist__Use_Round_Robin__c='TRUE';
                        opp.Membership_Upgrade_Group__c='NULL';
                        upgradeGroupList.add(opp); 
                        setOppTask.add(opp.Id);
                    }
                }
            }
        }
        // Updating SPA opp list and sending emails  
        // CHECK EMAIL TEMPLATE
        if(upgradeGroupSPAList.size()!=0){
            System.debug('130='+upgradeGroupSPAList);
            update upgradeGroupSPAList;
            
        }
        // Updating TRM opp list and sending emails
        if(upgradeGroupTRMList.size()!=0){
            System.debug('130='+upgradeGroupTRMList);
            update upgradeGroupTRMList;
            
        }
        // Updating GradeA opp list and sending emails
        if(upgradeGroupGradeAList.size()!=0){
            System.debug('162='+upgradeGroupGradeAList);
            update upgradeGroupGradeAList;
        }
        // Updating GradeB opp list and sending emails
        if(upgradeGroupGradeBList.size()!=0){
            System.debug('195='+upgradeGroupGradeBList);
            update upgradeGroupGradeBList;
        }
        // Updating GradeC opp list and sending emails
        if(upgradeGroupGradeCList.size()!=0){
            System.debug('195='+upgradeGroupGradeCList);
            update upgradeGroupGradeCList;            
        }
        // Updating GradeAB opp list and sending emails
        if(upgradeGroupGradeABList.size()!=0){
            System.debug('195='+upgradeGroupGradeABList);
            update upgradeGroupGradeABList;
        }
        // Updating upgradeGroupList opp list and sending emails
        if(upgradeGroupList.size()!=0){
            System.debug('262='+upgradeGroupList);
            update upgradeGroupList; 
        }
        // Add Task to MU, MU - Grade A, Grade B, Grade C , SPA- Grade AB, SPA
        for(Opportunity opp : [select id,OwnerId from Opportunity where ID IN : setOppTask]){
            Task objtask = new Task();
            objtask.Subject = 'Membership Upgrade-Call 1';
            objtask.ActivityDate = System.today();
            objtask.WhatId = opp.Id;
            objtask.OwnerId = opp.OwnerId;
            tasklist.add(objtask);
        }
        if(tasklist != null && tasklist.size() > 0)
            insert tasklist;   
    }
    
    public void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    public void execute(SchedulableContext SC) {
        database.executebatch(new schedule_Hawaai_Email_Opportunity(),1);
    }
    
}