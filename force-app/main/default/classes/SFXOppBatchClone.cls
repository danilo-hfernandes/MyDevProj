// Class for sending emails and assigning SFX Opportunities

Global class SFXOppBatchClone implements Database.Batchable<sObject>,schedulable{
    
    Global String ownerId;
    Global String ownerId1;
    Global List<OrgWideEmailAddress> orgList = new List<OrgWideEmailAddress>();
    Global set<String> HVSUsersId=new set<String>();
    List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
    List<EmailTemplate> emailTemplateList1 = new List<EmailTemplate>();
    List<EmailTemplate> emailTemplateList3 = new List<EmailTemplate>();
    
    global SFXOppBatchClone(){
        ownerId=[select id from user where name='Dev Account'].id;
        ownerId1=[select id from user where name='Salesforce'].id;
        orgList = [select Id from OrgWideEmailAddress where Address = 'welcome@myadvantageservices.com'];
        emailTemplateList = [SELECT Id, Body,developername, Subject, HtmlValue, Name
                             FROM EmailTemplate
                             WHERE developername = 'SFX_Welcome_Email'];
        
        emailTemplateList1 = [SELECT Id, Body,developername, Subject, HtmlValue, Name
                              FROM EmailTemplate
                              WHERE developername = 'SFX_Registration_Vida_Owner'];
        
        emailTemplateList3 = [SELECT Id, Body,developername, Subject, HtmlValue, Name
                              FROM EmailTemplate
                              WHERE developername = 'SFX_Diamond_Registration_Non_Vida'];
        
HVSUsersId=GenericMatchGroupAssignmentHandler.fetchMatchGroupDetails('Membership Upgrade-SFX Overflow');
    }
    
    Global Database.QueryLocator start(Database.BatchableContext bc) {
        system.debug('4');
        String UseRoundRobin='FALSE';
        String whereClause = GenericMatchGroupAssignmentHandler.addWhereClause(UseRoundRobin, 'equals');
        String stagename='New';
        String Ownerid=[select id from user where name='Salesforce'].id;
        String recordtype='SFX Membership';
        //String query='SELECT Id,Name,Stagename,ownerId,Accountid,Account.HC_Flag__c,Account.Preferred_Language__c,Account.Original_Source__c,SFX_Welcome_Email__c,Account.Enrollment_Date__c,Account.TRM_Owner_Flag__c,Account.email__c,Account.First_name__c from opportunity where record_type_name__c=\''+recordtype+'\'  and ownerid=\''+Ownerid+'\'  and Account.Enrollment_Date__c> 2022-05-01  and CreatedDate >2022-06-08T00:00:00.000+0000 and Account_Affiliate_Id__c=1002277'+(Test.isRunningTest()?' LIMIT 10':'');
        String query = 'SELECT Id,Name,Stagename,ownerId,Accountid,Account.HC_Flag__c,Account.Preferred_Language__c,Account.Original_Source__c,SFX_Welcome_Email__c,Account.Enrollment_Date__c,Account.TRM_Owner_Flag__c,Account.email__c,Account.First_name__c, Account.Returning_Vidanta_Costumer__c from opportunity where Account_Affiliate_Id__c=1002277 AND '+whereClause+' AND Account.Enrollment_Date__c < N_DAYS_AGO:9 AND Account.Enrollment_Date__c > N_DAYS_AGO:119 AND CreatedDate >2022-06-08T00:00:00.000+0000'+(Test.isRunningTest()?' LIMIT 10':'');
        system.debug('9='+query);
        system.debug('size='+Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    Global void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        DateTime returnVidanta51days = System.today().addDays(-45);
        list<Opportunity> opp10DaysOld= new list<Opportunity>();
        list<Opportunity> updateOpp10DaysOld= new list<Opportunity>();
        list<Opportunity> opp15DaysOld1= new list<Opportunity>();
        list<Opportunity> updateOpp15DaysOld1= new list<Opportunity>();
        list<Opportunity> opp15DaysOld1TRM= new list<Opportunity>();
        list<Opportunity> updateOpp15DaysOld1TRM= new list<Opportunity>();
        list<Opportunity> opp15DaysOld1SPA= new list<Opportunity>();
        list<Opportunity> updateOpp15DaysOld1SPA= new list<Opportunity>();
        list<Opportunity> opp15DaysOld2= new list<Opportunity>();
        list<Opportunity> updateOpp15DaysOld2= new list<Opportunity>();
        list<Opportunity> opp31DaysOld= new list<Opportunity>();
        list<Opportunity> updateOpp31DaysOld= new list<Opportunity>();
        list<String> opp31DaysOldAccountIds= new list<String>();
        list<Contact> opp31DaysOldContacts= new list<Contact>();
        Set<ID> cadenceContactsId=new set<Id>();
        set<Id> setAccountIds = new set<Id>(); 
        List<Contact> contactToUpdate=new List<Contact>();
        set<Id> setOppTask = new set<Id>();
        list<Task> tasklist = new list<Task>();
        List<Opportunity> createNewOpportunity = new List<Opportunity>();
        set<Id> setAccSPANonVida = new set<Id>();
        set<Id> setAccENGNonVida = new set<Id>();
        List<Opportunity> updatedOppList = new List<Opportunity>();
        try{
            for(Opportunity opp: scope){
                if((opp.ownerid==ownerId || opp.ownerid==ownerId1) && opp.stagename=='New' && opp.Account.HC_Flag__c==FALSE  && opp.SFX_Welcome_Email__c==FALSE  && opp.Account.Enrollment_Date__c <=System.today()-10){
                    opp10DaysOld.add(opp);
                }
                else if((opp.ownerid==ownerId || opp.ownerid==ownerId1) && opp.stagename=='New'  && opp.Account.Enrollment_Date__c <=System.today()-15 && opp.account.Original_Source__c != null && (opp.Account.HC_Flag__c == FALSE || (opp.account.Original_Source__c != 'EXN' && opp.account.Original_Source__c != 'Web' && opp.account.Original_Source__c != 'Web-Homepage')) && !opp.account.Original_Source__c.containsIgnoreCase('vidanta')){
                    //Membership Upgrade-SPA SFX Non Vida
                    if(opp.Account.Preferred_Language__c=='SPA'){
                        setAccSPANonVida.add(opp.Id);
                    }
                    //Membership Upgrade-SFX Non Vida
                    else if(opp.Account.Preferred_Language__c=='ENG'){
                        setAccENGNonVida.add(opp.Id);
                    }
                }
                else if((opp.ownerid==ownerId || opp.ownerid==ownerId1) && opp.stagename=='New'  && opp.Account.Enrollment_Date__c <=System.today()-15 && opp.Account.HC_Flag__c==FALSE){
                    if(opp.Account.Preferred_Language__c=='SPA'){
                        opp15DaysOld1SPA.add(opp);
                    }
                    else{
                        if(opp.Account.TRM_Owner_Flag__c=='NO' || opp.Account.TRM_Owner_Flag__c==null){
                            opp15DaysOld1.add(opp);
                        }
                        else if(opp.Account.TRM_Owner_Flag__c=='YES'){
                            opp15DaysOld1TRM.add(opp);
                        }
                    }
                }
                else if((opp.ownerid==ownerId || opp.ownerid==ownerId1)&& opp.stagename=='New' && opp.Account.HC_Flag__c==TRUE && opp.Account.Enrollment_Date__c <= System.today()-20){
                    opp15DaysOld2.add(opp);
                }
                else if((opp.StageName=='Attempting to Contact 1' || opp.StageName=='Attempting to Contact 2' || opp.StageName=='Attempting to Contact 3' || opp.StageName=='Attempting to Contact 4' ) && opp.Account.Enrollment_Date__c <= System.today()-31){
                    opp31DaysOld.add(opp);
                    system.debug('91'+opp31DaysOld.size());
                    
                }
                else if(opp.AccountId != null && opp.Account.Returning_Vidanta_Costumer__c == returnVidanta51days){
                    setAccountIds.add(opp.AccountId);
                }
                
            }
            // Sending email for SFX Opportunities 10 days older AND updating SFX_Welcome_Email__c field
            if(opp10DaysOld.size()!=0){
                System.debug('54='+opp10DaysOld);
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
                for(Opportunity opp:opp10DaysOld){
                    opp.SFX_Welcome_Email__c=TRUE;
                    updatedOppList.add(opp);
                    system.debug('64='+opp.account.First_name__c);
                    string whoid=opp.Id;
                    string whatid=opp.AccountId;
                    List<String> emailAddress=new list<string>();
                    emailAddress.add(opp.Account.email__c);
                    String templateBody;
                    Messaging.SingleEmailMessage newEmail; 
                    Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
                    
                    if(!emailTemplateList.isEmpty()) {
                        newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].id,whoId,whatId);
                    }
                    if(!emailAddress.isEmpty()) {
                        if(newEmail != null) {
                            if ( orgList.size() > 0 ) {
                                mailToBeSent.setOrgWideEmailAddressId(orgList[0].Id);
                            }
                            mailToBeSent.setSubject(newEmail.subject);
                            mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                            mailToBeSent.setToAddresses(emailAddress);
                            emailList.add(mailToBeSent);
                        }
                    }
                }
                if(!emailList.isEmpty()){
                    system.debug('92');
                    Messaging.sendEmail(emailList); 
                }
            }
            
            // Assiging 15 days older SFX Opportunities to Membership Upgrade-SFX Match Group
            if(opp15DaysOld1.size()!=0){
                for(Opportunity opp:opp15DaysOld1){
                    system.debug('102='+opp);
                    opp.Membership_Upgrade_SFX__c='TRUE';
                    updatedOppList.add(opp);
                    setOppTask.add(opp.Id);
                }
            }
            
            if(opp15DaysOld1TRM.size()!=0){
                for(Opportunity opp:opp15DaysOld1TRM){
                    system.debug('102='+opp);
                    opp.Membership_Upgrade_SFX__c='TRM';
                    updatedOppList.add(opp);
                }
            }
            if(opp15DaysOld1SPA.size()!=0){
                for(Opportunity opp:opp15DaysOld1SPA){
                    system.debug('102='+opp);
                    opp.Membership_Upgrade_SFX__c='SPA';
                    updatedOppList.add(opp);
                    setOppTask.add(opp.Id);
                }
            }
            
            // Sending email for 15 days older SFX opportunities and updating their stagename
            if(opp15DaysOld2.size()!=0){
                
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
                for(Opportunity opp:opp15DaysOld2){
                    system.debug('64='+opp.account.First_name__c);
                    string whoid=opp.Id;
                    string whatid=opp.AccountId;
                    List<String> emailAddress=new list<string>();
                    emailAddress.add(opp.Account.email__c);
                    String templateBody;
                    Messaging.SingleEmailMessage newEmail; 
                    Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
                    
                    if(!emailTemplateList.isEmpty()) {
                        newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList[0].id,whoId,whatId);
                    }
                    if(!emailAddress.isEmpty()) {
                        if(newEmail != null) {
                            if ( orgList.size() > 0 ) {
                                mailToBeSent.setOrgWideEmailAddressId(orgList[0].Id);
                            }
                            mailToBeSent.setSubject(newEmail.subject);
                            mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                            mailToBeSent.setToAddresses(emailAddress);
                            emailList.add(mailToBeSent);
                        }
                    }
                    
                }
                if(!emailList.isEmpty()){
                    system.debug('92');
                    Messaging.sendEmail(emailList); 
                }
                System.debug('115='+opp15DaysOld2);
                
            }
            system.debug('243');
            
            system.debug('244'+opp31DaysOld.size());
            //Assigning 31 days older Opportunities to Membership Upgrade-SFX Overflow And assigning contacts to Membership Upgrade-SFX Overflow Sales Cadence
            if(opp31DaysOld.size()!=0){
                
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>(); 
                
                for(Opportunity opp:opp31DaysOld){
                    system.debug('124='+opp.account.First_name__c);
                    string whoid=opp.Id;
                    string whatid=opp.AccountId;
                    List<String> emailAddress=new list<string>();
                    emailAddress.add(opp.Account.email__c);
                    String templateBody;
                    Messaging.SingleEmailMessage newEmail; 
                    Messaging.SingleEmailMessage mailToBeSent = new Messaging.SingleEmailMessage(); 
                    
                    
                    if(!emailTemplateList1.isEmpty() && opp.account.Original_Source__c=='Vidanta') {
                        newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList1[0].id,whoId,whatId);
                    }
                    else  if(!emailTemplateList1.isEmpty() && opp.account.Original_Source__c!='Vidanta') {
                        newEmail = Messaging.renderStoredEmailTemplate(emailTemplateList3[0].id,whoId,whatId);
                    }
                    
                    if(!emailAddress.isEmpty()) {
                        if(newEmail != null) {
                            if ( orgList.size() > 0 ) {
                                mailToBeSent.setOrgWideEmailAddressId(orgList[0].Id);
                            }
                            mailToBeSent.setSubject(newEmail.subject);
                            mailToBeSent.setHtmlBody(newEmail.HTMLBody);
                            mailToBeSent.setToAddresses(emailAddress);
                            emailList.add(mailToBeSent);
                        }
                        
                    }
                    system.debug('166='+opp);
                    opp.Membership_Upgrade_SFX__c='OVERFLOW';
                    opp.StageName='Unable to Reach';
                    opp31DaysOldAccountIds.add(opp.AccountId);
                    updatedOppList.add(opp);
                    setOppTask.add(opp.Id);
                }            
                if(!emailList.isEmpty()){
                    system.debug('155');
                    Messaging.sendEmail(emailList); 
                }
                
                opp31DaysOldContacts=[Select id,Assign_to_Sales_Cadence__c,Cadence_Flag__c from contact where accountid IN: opp31DaysOldAccountIds AND Assign_to_Sales_Cadence__c=FALSE AND Parent_Id_Ext_Db__c = null AND Master_Record_Id__c!=null];
                Map<Id, User> HVSUserIdMap = new Map<Id, User>([SELECT Id, name,Assigned_Contacts__c FROM User WHERE Id IN:HVSUsersId AND IsActive = true]);
                
                Set<Id> contactIdSet = new Set<Id>();
                Map<Id,Id> contactIdSetMap = new Map<Id,Id>();
                for(Contact con:opp31DaysOldContacts){
                    if(!contactIdSetMap.containskey(con.Id)){
                        system.debug('192='+con);
                        Id leastContactsUserId;
                        Decimal noOfHVSContacts;
                        for(Id HVSUserId: HVSUserIdMap.keySet()){
                            if(leastContactsUserId == null){
                                leastContactsUserId = HVSUserId;
                            }
                            noOfHVSContacts = HVSUserIdMap.get(leastContactsUserId).Assigned_Contacts__c;
                            if(noOfHVSContacts > HVSUserIdMap.get(HVSUserId).Assigned_Contacts__c){
                                noOfHVSContacts = HVSUserIdMap.get(HVSUserId).Assigned_Contacts__c;
                                leastContactsUserId = HVSUserId;
                            }
                        }
                        
                        HVSUserIdMap.get(leastContactsUserId).Assigned_Contacts__c +=1;
                        con.Assign_to_Sales_Cadence__c=true;
                        con.OwnerId = leastContactsUserId;
                        con.Cadence_Flag__c=1;
                        contactToUpdate.add(con);
                        cadenceContactsId.add(con.id);    
                        contactIdSetMap.put(con.id,con.id);
                    }
                }
                if(contactToUpdate.size() > 0 ){
                    system.debug('128='+contactToUpdate.size());
                    update contactToUpdate;
                } 
                if(cadenceContactsId != null){
                    System.enqueueJob(new SFXOppBatchQueueable(cadenceContactsId));
                }
            }
            if(setAccountIds != null && setAccountIds.size() > 0){
                for(Id accId : setAccountIds){
                    Opportunity opp = new Opportunity();
                    opp.Name = 'SFX Opportunity';
                    opp.AccountId = accId;
                    opp.StageName = 'New';
                    opp.CloseDate = System.today();
                    opp.Membership_Upgrade_SFX__c='TRUE';
                    opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SFX_Membership').getRecordTypeId();
                    createNewOpportunity.add(opp);
                }
                if(createNewOpportunity != null && createNewOpportunity.size() > 0){
                    createNewOpportunity =  GenericMatchGroupAssignmentHandler.assignMatchGroup(createNewOpportunity, 'Assigned');
                    insert createNewOpportunity;
                }
                
            }
            if(setAccSPANonVida != null && setAccSPANonVida.size() > 0){
                List<Opportunity> listOpps = [select id,Match_Group_Name__c from Opportunity where Id IN : setAccSPANonVida and (leadassist__Use_Round_Robin__c = 'FALSE' or leadassist__Use_Round_Robin__c = '')];
                for(Opportunity objopp : listOpps){
                    objopp.Match_Group_Name__c = 'Membership Upgrade-SPA SFX Non Vida';
                    updatedOppList.add(objopp);
                }  
            }
            if(setAccENGNonVida != null && setAccENGNonVida.size() > 0){
                List<Opportunity> listOpps =[select id,Match_Group_Name__c from Opportunity where Id IN : setAccENGNonVida and (leadassist__Use_Round_Robin__c = 'FALSE' or leadassist__Use_Round_Robin__c = '')];
                for(Opportunity objopp : listOpps){
                    objopp.Match_Group_Name__c = 'Membership Upgrade-SFX Non Vida';
                    updatedOppList.add(objopp);
                } 
            }
            if(updatedOppList != null && updatedOppList.size() > 0){
                updatedOppList =  GenericMatchGroupAssignmentHandler.assignMatchGroup(updatedOppList, 'Assigned');
                update updatedOppList;
            }
            if(setOppTask != null && setOppTask.size() > 0){
                // Add Task to SPA, SFX, SFX Overflow
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
        }catch(Exception e){
            system.debug('277 Exception='+e.getLineNumber());
            system.debug('278 Exception='+e.getMessage());
        }
    }
    
    Global void finish(Database.BatchableContext bc) {
        //do something 
    }   
    
    Global void execute(SchedulableContext SC) {
        database.executebatch(new SFXOppBatchClone(),100);
    }  
}