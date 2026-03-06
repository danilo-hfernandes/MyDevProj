trigger AccountTrigger on Account (before update,after insert, before insert,after Update,before delete) {
    Apex_Trigger_On_Off__c updateTimeZone = Apex_Trigger_On_Off__c.getValues('UpdateTimeZoneAccount');
    Apex_Trigger_On_Off__c accountTrigger = Apex_Trigger_On_Off__c.getValues('AccountTrigger');
     
        
    if(accountTrigger != null && accountTrigger.isEnable__c){
        if(trigger.isInsert && trigger.isBefore){
            system.debug('6');
            GenericDuplicatesCheckController.updateHCFlag(trigger.new, true);//Trigger.new, HCFlag
        }
        if(trigger.isInsert && trigger.isAfter){
            AccountFlags.hasInsertRun = true;
            AccountTriggerHelper.sfxOpportunity(trigger.new);
            AccountTriggerHelper.MTRCMUOpportunity(trigger.new);
            AccountTriggerHelper.vidaBookWithUsOpp(trigger.new);
            AccountTriggerHelper.membershipUpgradeVidaWeekOpp(trigger.new); //it was uncommented and added due to SCO-15
            AccountTriggerHelper.updateTimeshareOwnerFlag(trigger.new, 'Insert');
            //AccountTriggerHelper.ClubGlobalOpportunity(trigger.new);
            //AccountTriggerHelper.RCOpportunityValidation(trigger.new);
        }
        if(trigger.isDelete && trigger.isBefore){
            //block users to merge account records - deleting one of them
            Id userProfileId = userinfo.getProfileId();
            String userProfileName = [SELECT ID, Name from Profile Where Id = : userProfileId].Name;
            
            if(userProfileName != 'System Administrator'){
                for(Account delAcc : trigger.old){
                    delAcc.adderror('You are not allowed to delete accounts');
                }
            }
        }
        
        
        //VVA-156 DNC AI Dialler
        if (trigger.isAfter && trigger.isUpdate) {
            for (Account newAccount : Trigger.new) {
                Account oldAccount = Trigger.oldMap.get(newAccount.Id);
        
                // Check if DoNotCall changed to TRUE
                if (newAccount.Do_Not_Call__c == true && oldAccount.Do_Not_Call__c != true) {
                    System.debug('DoNotCall changed to TRUE for Account Id: ' + newAccount.Id);
        
                    // Call API Controller (async)
                    if(!Test.isRunningTest()){
                        System.debug('Calling DNC API for Account Id: ' + newAccount.Id);
                        DNCAPICallController.sendDNCRequest(newAccount.Id);
                    }
                }
            }
}
        
        //SF Account Member Sync to SQL and BE
        if(checkRecursive.accountTriggerAPI && trigger.isafter && trigger.isUpdate) {
            //2024-04-29 [ACI-7] Sync real time email between Account and Primary Contact
            Map<Id,String> syncPrimaryContactEmail = new Map<Id,String>();
            Map<Id,String> syncPrimaryContactFirstName = new Map<Id,String>();
            Map<Id,String> syncPrimaryContactLastName = new Map<Id,String>();
            Map<Id,Boolean> syncPrimaryContactDNC = new Map<Id,Boolean>();
            set<Id> syncEmailToOpportunity = new set<Id>();
            
            if(updateTimeZone!= null && updateTimeZone.isEnable__c){
                UpdateTimeZoneBasedOnAreaCodeController.updateAccountTimeZone(trigger.new, trigger.oldmap);
            }
            //AccountTriggerHelper.updateTimeshareOwnerFlag(trigger.new,'Update');
            Set<Id> AccountIdSet = new Set<Id>();
            set<Id> accUpdateDuesPaid = new set<Id>();
            for(Account acc : trigger.new){
                if(acc.Email__c != null && acc.Email__c != Trigger.oldMap.get(acc.Id).Email__c){
                    syncEmailToOpportunity.add(acc.Id);
                }
                if(!System.isFuture() && acc.Parent_Child_Contact_Id__c != null && acc.Email__c != null && acc.Email__c != Trigger.oldMap.get(acc.Id).Email__c){
                    syncPrimaryContactEmail.put(acc.Parent_Child_Contact_Id__c,acc.Email__c);
                }
                if(!System.isFuture() && acc.Parent_Child_Contact_Id__c != null && ((acc.First_Name__c != null && acc.First_Name__c != Trigger.oldMap.get(acc.Id).First_Name__c) ||(acc.Last_Name__c != null && acc.Last_Name__c != Trigger.oldMap.get(acc.Id).Last_Name__c))) {
                    syncPrimaryContactFirstName.put(acc.Id,acc.First_Name__c);
                    syncPrimaryContactLastName.put(acc.Id,acc.Last_Name__c);
                }
                if(!System.isFuture() && acc.Parent_Child_Contact_Id__c != null && acc.Do_Not_Call__c != null && acc.Do_Not_Call__c != Trigger.oldMap.get(acc.Id).Do_Not_Call__c){
                    syncPrimaryContactDNC.put(acc.Id,acc.Do_Not_Call__c); 
                }  
                //2022-07-25 - added acc.Affiliated_Id__c != 1002335 criteria to don't send Vacation VIP Vida Voucher account to BE
                if(acc.Bypass_Sync_to_SQL__c == false && acc.Affiliated_Id__c != 1002335 && acc.Affiliated_Id__c != 1002418 && acc.Affiliated_Id__c != 1002477){
                    if((acc.Dues_Last_Paid_Until__c != Trigger.oldMap.get(acc.Id).Dues_Last_Paid_Until__c)){
                        accUpdateDuesPaid.add(acc.Id);
                    }
                    system.debug('>>>>>'+acc);
                    system.debug('>>>>>'+Trigger.oldMap.get(acc.Id));
                    system.debug('>>>>>>'+(acc.Name != Trigger.oldMap.get(acc.Id).Name));
                    system.debug('>>>>>>'+(acc.Phone != Trigger.oldMap.get(acc.Id).Phone));
                    system.debug('>>>>>>'+(acc.Email__c != Trigger.oldMap.get(acc.Id).Email__c));
                    system.debug('>>>>>>'+(acc.BillingCity != Trigger.oldMap.get(acc.Id).BillingCity));
                    system.debug('>>>>>>'+(acc.BillingCountry != Trigger.oldMap.get(acc.Id).BillingCountry));
                    system.debug('>>>>>>'+(acc.BillingState != Trigger.oldMap.get(acc.Id).BillingState));
                    system.debug('>>>>>>'+(acc.BillingStreet != Trigger.oldMap.get(acc.Id).BillingStreet));
                    system.debug('>>>>>>'+(acc.BillingPostalCode != Trigger.oldMap.get(acc.Id).BillingPostalCode));
                    if(
                        ((acc.Name != Trigger.oldMap.get(acc.Id).Name) && ((acc.First_Name__c != Trigger.oldMap.get(acc.Id).First_Name__c) || (acc.Last_Name__c != Trigger.oldMap.get(acc.Id).Last_Name__c)))|| 
                        (acc.Phone != Trigger.oldMap.get(acc.Id).Phone) || 
                        (acc.Email__c != Trigger.oldMap.get(acc.Id).Email__c) || 
                        (acc.BillingCity != Trigger.oldMap.get(acc.Id).BillingCity) || 
                        (acc.BillingCountry != Trigger.oldMap.get(acc.Id).BillingCountry) || 
                        (acc.BillingState != Trigger.oldMap.get(acc.Id).BillingState) ||
                        (acc.BillingStreet != Trigger.oldMap.get(acc.Id).BillingStreet) || 
                        (acc.BillingPostalCode != Trigger.oldMap.get(acc.Id).BillingPostalCode) ||
                        (acc.Alternate_Phone__c != Trigger.oldMap.get(acc.Id).Alternate_Phone__c) ||
                        (acc.Alternate_Phone_1__c != Trigger.oldMap.get(acc.Id).Alternate_Phone_1__c)
                    ){
                        if((acc.Master_Record_Id__c == null || acc.Master_Record_Id__c == '') && acc.Affiliated_Id__c != 1002455 && acc.Affiliated_Id__c != 1002478){
                            acc.addError('Please Enroll Member before making updates on the account');
                        }
                        else if(acc.First_Name__c == null || acc.First_Name__c == ''){
                            acc.addError('First Name is Required');
                        }
                        else if(acc.Last_Name__c == null || acc.Last_Name__c == ''){
                            acc.addError('Last Name is Required');
                        }
                        else{
                            AccountIdSet.add(acc.Id);
                        }
                    }else{
                        // Send email to agent for the MRI - // Diana
                    }
                }
            }
            if(accUpdateDuesPaid != null && accUpdateDuesPaid.size() > 0){
                if(!system.isBatch()){
                    DataSyncToSQL.accountDuesPaidSync(accUpdateDuesPaid);
                } 
            }
            if(AccountIdSet != null && AccountIdSet.size() > 0){
                system.debug('AccountIdSet---'+AccountIdSet);
                if(!system.isBatch() && !System.isFuture()){
                    DataSyncToSQL.AccountContactDataSync(AccountIdSet,'Account');
                }
            }
            if(syncEmailToOpportunity != null && syncEmailToOpportunity.size() > 0){
                AccountTriggerHelper.syncEmailToOpportunity(syncEmailToOpportunity);
            }
            if(syncPrimaryContactEmail != null && syncPrimaryContactEmail.size() > 0)
            {
                //sync from parent account to main contact
                AccountTriggerHelper.syncEmail(syncPrimaryContactEmail,'Contact');
            }

            //Sync FirstName & LastName
            if(syncPrimaryContactFirstName != null && syncPrimaryContactFirstName.size() > 0)
            {
                //sync from parent account to main contact
                AccountTriggerHelper.syncNameAccountANDContact(syncPrimaryContactFirstName,syncPrimaryContactLastName,'Account');
            }
            //Sync Do Not Call
            if(syncPrimaryContactDNC != null && syncPrimaryContactDNC.size() > 0)
            {
            //sync from parent account to main contact
                AccountTriggerHelper.syncDNC(syncPrimaryContactDNC,'Account');
            }
    		Boolean hasAdminPermission = FeatureManagement.checkPermission('IsSystemAdmin');
            Map<String,String> AccsToSendToBE = new Map<String,String>();
            Set<Id> accIdsToSyncToBE = new Set<Id>();

            if(!hasAdminPermission || hasAdminPermission){                
                Id currentUserId = UserInfo.getUserId();
                List<User> userList = [SELECT Id, Name, UserRole.Name,Profile.Name FROM User WHERE Id =: currentUserId AND UserRoleId != null AND ProfileId != null AND UserRole.Name != NULL and Profile.Name != NULL and Name not in ('ManagementUser')];
                if(userList != null && userList.size()>0){
                    User u = userList[0];
                    if(u.Name != 'Dev Account' && u.Name != 'Salesforce' && u.Name != 'Integration New Systems' && u.Name != 'Zappier'){                 
                        Map<Id,Account> AccsToSync = new Map<Id,Account>();                        
                        for(Account Acc:(List<Account>)Trigger.New){
                            Account oldAcc = (Account)Trigger.oldMap.get(Acc.Id);
                            if(Acc.Membership_Status__c != oldAcc.Membership_Status__c)
                            {
                                AccsToSendToBE.put(Acc.Member_Number__c,Acc.Membership_Status__c);
                                accIdsToSyncToBE.add(Acc.Id);
                                if(Acc.Membership_Status__c == 'CancelByMember' || Acc.Membership_Status__c == 'Active'){
                                    AccsToSync.put(Acc.Id,Acc);
                                }
                            }
                        }
                        if(AccsToSync != null && AccsToSync.size()>0)
                        {
                            List<Contact> allRelatedContacts = new List<Contact>();
                            allRelatedContacts = [SELECT Id,AccountId,Membership_Status__c FROM Contact WHERE AccountId IN : AccsToSync.keySet()];
                            List<Contact> allContactsToUpdate = new List<Contact>();
                            if(allRelatedContacts != null && allRelatedContacts.size()>0){
                                for(Contact con : allRelatedContacts)
                                {
                                    if(AccsToSync.get(con.AccountId).Membership_Status__c != con.Membership_Status__c && AccsToSync.get(con.AccountId).Membership_Status__c == 'CancelByMember')
                                    {
                                        con.Membership_Status__c = AccsToSync.get(con.AccountId).Membership_Status__c;
                                        allContactsToUpdate.add(con);
                                    }
                                    else if(AccsToSync.get(con.AccountId).Membership_Status__c != con.Membership_Status__c && AccsToSync.get(con.AccountId).Membership_Status__c == 'Active' && con.Id == AccsToSync.get(con.AccountId).Parent_Child_Contact_Id__c)
                                    {
                                        con.Membership_Status__c = AccsToSync.get(con.AccountId).Membership_Status__c;
                                        allContactsToUpdate.add(con);
                                    }
                                }
                                if(allContactsToUpdate != null && allContactsToUpdate.size()>0)
                                {
                                    update allContactsToUpdate;
                                }
                            }
                        }
                    }
                }                
            }
            if(AccsToSendToBE != null && AccsToSendToBE.size() > 0){
                system.debug('AccsToSendToBE---'+AccsToSendToBE);
                MembershipDataSyncToBE.MembershipDataSync(AccsToSendToBE,accIdsToSyncToBE);
            }
        } 
        if(checkRecursive.accountTrigger) {
            if(trigger.isBefore && trigger.isUpdate){
                List<Decimal> listOfAffiliate = new List<Decimal>{1002277, 1002447, 1002449,1002450};//Include the affiliates for which the HC Flag is applicable
                List<Decimal> HCAffiliates = new List<Decimal>{1002243,1002311,1002312,1002310};//HC Affilates
				List<Decimal> CGEAffiliates = new List<Decimal>{1002447, 1002449,1002450, 1002458, 1002459};//CGE Affilates
                List<Decimal> ClubVentureAffiliates = new List<Decimal>{1002453, 1002454,1002456, 1002455};//Club Venture Affilates
                List<Decimal> CFDAffiliates = new List<Decimal>{1002257, 1002266,1002256, 1002258};//CFD Affilates
				List<Account> hcFlagAffiliateList = new List<Account>();
                for(Account objacc : trigger.new){
                    if(objacc.Name != null && objacc.Name != Trigger.oldMap.get(objacc.Id).Name){
                        String firstName = objacc.Name.contains(' ') ? objacc.Name.SubStringBefore(' ') : objacc.Name;
                        String lastName = objacc.Name.contains(' ') ? objacc.Name.SubStringAfter(' ') : '';
                        if(objacc.First_Name__c == null || objacc.First_Name__c != firstName){
                            objacc.First_Name__c = firstName;
                        }
                        if(objacc.Last_Name__c == null || objacc.Last_Name__c != lastName){
                            objacc.Last_Name__c = lastName;
                        }
                    }
                    if(objacc.Co_owner_First_Name__c != null && objacc.Co_owner_First_Name__c != Trigger.oldMap.get(objacc.Id).Co_owner_First_Name__c){
                         objacc.Co_owner_First_Name__c =  objacc.Co_owner_First_Name__c.substring(0, 1).toUpperCase() + objacc.Co_owner_First_Name__c.substring(1).toLowerCase();
                    }
                    if(objacc.Co_owner_Last_Name__c != null && objacc.Co_owner_Last_Name__c != Trigger.oldMap.get(objacc.Id).Co_owner_Last_Name__c){
                         objacc.Co_owner_Last_Name__c =  objacc.Co_owner_Last_Name__c.substring(0, 1).toUpperCase() + objacc.Co_owner_Last_Name__c.substring(1).toLowerCase();
                    }
                    if(objacc.MFP_Type__c != null && objacc.MFP_Type__c != Trigger.oldMap.get(objacc.Id).MFP_Type__c){  
                        objacc.MFP_Date_Time__c = System.Now();
                        objacc.MFP_User__c = UserInfo.getUserId();
                    }
                    if(objacc.Affiliated_Id__c != null && objacc.Affiliated_Id__c != Trigger.oldMap.get(objacc.Id).Affiliated_Id__c && (listOfAffiliate.contains(objacc.Affiliated_Id__c) || HCAffiliates.contains(objacc.Affiliated_Id__c) || CGEAffiliates.contains(objacc.Affiliated_Id__c) || ClubVentureAffiliates.contains(objacc.Affiliated_Id__c) || CFDAffiliates.contains(objacc.Affiliated_Id__c))){
                         hcFlagAffiliateList.add(objacc);
                    }
                }
                if(hcFlagAffiliateList != null && hcFlagAffiliateList.size() > 0){
                	GenericDuplicatesCheckController.updateHCFlag(hcFlagAffiliateList, true);//Trigger.new, HCFlag
                }
            }
            if(trigger.isUpdate) {
                system.debug('60');
                Set<Id> AccountIds = new Set<Id>();
                List<Opportunity> oppListUpdate = new List<Opportunity>();
                for (Account acc1: Trigger.new) {
                    if(acc1.Tee_Up_Agent__c != null) {
                        AccountIds.add(acc1.Id);
                    }
                    System.debug('This is the AccountIds ' + AccountIds);
                }
                if(AccountIds.size() > 0) {
                    List<Opportunity> oppList = new List<Opportunity>();
                    Date d = system.today().addDays(-15);
                    Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Membership_Upgrade' ].id ;
                    oppList = [Select Id, Closed_Lost_Date__c, StageName, Name, AccountId, (Select Id FROM OpportunityLineItems), IsClosed, RecordTypeId FROM Opportunity WHERE AccountId IN :AccountIds AND RecordTypeId = :oppRecordTypeId];
                    
                    if(oppList != null && oppList.size() > 0) {
                        for(Account a : Trigger.New) {
                            
                            for(Opportunity o : oppList) {
                                if(!Test.isRunningTest()) {
                                    if(a.id == o.AccountId && (o.StageName == 'Closed Refunded' || o.StageName == 'Pitched - Did Not Close/Lost') && o.Closed_Lost_Date__c > d) { 
                                        a.addError('There is a Membership Upgrade Opportunity related to this account that is Closed Lost less than 15 days ago.  Navigate to following link:  https://holidaysystems.lightning.force.com/'+o.id);
                                    }
                                    else if(a.Id == o.AccountId && o.IsClosed == false) {
                                        a.AddError('There is already an open Membership Upgrade Opportunity for this Contact.  Navigate to following link:  https://holidaysystems.lightning.force.com/'+o.id);
                                        
                                    }
                                }
                            }
                            
                        }
                    }
                    checkRecursive.accountTrigger = false;
                }
            }
            //1002336 SRR Assignment added 2022-09-18
            if(trigger.isUpdate && trigger.isAfter){
                //2025-04-10 HMR-632 - move sfx opps to Auto Open
                Set<Id> membersInactiveBySFX = new Set<Id>();
                List<Account> listAccount = new List<Account>();
                map<Id,Boolean> mapAccountIdvsOptOut = new map<Id,Boolean>();
                Set<Id> contactIdsToAssignToSRR = new Set<Id>();
                for(Account acc : trigger.new){
                    if(acc.Affiliated_Id__c == 1002336 && acc.Enrollment_Date__c != null && (Trigger.oldMap.get(acc.Id).Parent_Child_Contact_Id__c == null || Trigger.oldMap.get(acc.Id).Parent_Child_Contact_Id__c == '') && (acc.Parent_Child_Contact_Id__c != Trigger.oldMap.get(acc.Id).Parent_Child_Contact_Id__c)){
                        contactIdsToAssignToSRR.add(acc.Parent_Child_Contact_Id__c); 
                    }
                    if(trigger.oldMap.get(acc.Id).Marketing_Email_opt_out__c != acc.Marketing_Email_opt_out__c){//acc.Marketing_Email_opt_out__c && !trigger.oldMap.get(acc.Id).Marketing_Email_opt_out__c && 
                        listAccount.add(acc);
                        mapAccountIdvsOptOut.put(acc.Id,acc.Marketing_Email_opt_out__c);
                    }
                    //2025-04-10 HMR-632 - move sfx opps to Auto Open
                    if(Trigger.oldMap.get(acc.Id).Membership_Status__c != acc.Membership_Status__c && acc.Membership_Status__c == 'InactiveBySFX')
                    {
                        membersInactiveBySFX.add(acc.Id);
                    }
                }
                if(listAccount != null && listAccount.size() > 0){
                    List<Contact> updateConList = new List<Contact>();
                    List<Contact> listCon =[select id,Marketing_Email_opt_out__c,Account.Marketing_Email_opt_out__c from Contact where AccountId IN : mapAccountIdvsOptOut.keyset() and Is_Main_Contact__c = true];
                    for(Contact objcon : listCon){
                        System.debug('>>>objcon.Marketing_Email_opt_out__c>>'+objcon.Marketing_Email_opt_out__c);
                        System.debug('>>>mapAccountIdvsOptOut.get(objcon.AccountId)>>'+mapAccountIdvsOptOut.get(objcon.AccountId));
                        if(objcon.Marketing_Email_opt_out__c != mapAccountIdvsOptOut.get(objcon.AccountId)){
                            objcon.Marketing_Email_opt_out__c = mapAccountIdvsOptOut.get(objcon.AccountId);
                            updateConList.add(objcon);
                        }
                    }
                    UnsubscribeRecordsHandler.unsubscribe(listAccount,'Account');
                    if(updateConList != null && updateConList.size() > 0){
                        update updateConList;
                    }
                }
                if(contactIdsToAssignToSRR != null && contactIdsToAssignToSRR.size()>0)
                {
                    List<Contact> contactsToAssignToSRR = [SELECT Id,leadassist__Use_Round_Robin__c,Cadence_Flag__c,Assign_to_Sales_Cadence_Name__c,Assign_to_Sales_Cadence__c FROM Contact WHERE Id IN : contactIdsToAssignToSRR];
                    if(contactsToAssignToSRR != null && contactsToAssignToSRR.size()>0)
                    {
                        for(Contact c : contactsToAssignToSRR)
                        {
                            if(c.Cadence_Flag__c==0){
                                c.leadassist__Use_Round_Robin__c = 'TRUE';
                                c.Assign_to_Sales_Cadence_Name__c = 'TourGen-Vacation VIP Members';
                                c.Assign_to_Sales_Cadence__c = true;
                                c.Cadence_Flag__c=1;
                            }
                            else{
                                c.Cadence_Flag__c=2;
                            }
                        }
                        update contactsToAssignToSRR;
                    }
                }
                if(membersInactiveBySFX != null && membersInactiveBySFX.size() > 0){
                    AccountTriggerHelper.sfxMemberTransfer(membersInactiveBySFX);
                }
            }
            if(trigger.isInsert && trigger.isAfter){
                if(updateTimeZone != null && updateTimeZone.isEnable__c){
                    UpdateTimeZoneBasedOnAreaCodeController.updateAccountTimeZone(trigger.new, null);
                }
                AccountTriggerHelper acc = New AccountTriggerHelper();
                acc.CreateHSIEnrollment(trigger.new); 
            }
            if(trigger.isInsert && trigger.isBefore){
                
                Set<String> affiliateIdString = new Set<String>();
                Set<String> queriedAffiliateIdString = new Set<String>();
                List<Affiliate_Id__c> affiliateIdList = new List<Affiliate_Id__c>();
                
                for(Account acc : trigger.new){
                    if(acc.Affiliated_Id__c != null && acc.Preferred_Language__c != null){
                        affiliateIdString.add(string.valueOf(acc.Affiliated_Id__c));
                    }
                    if (acc.Email_1__c != null && acc.Email_1__c != '') {
                        acc.Email_2__c = acc.Email_1__c;
                    }
                    /*if(acc.Co_owner_First_Name__c != null ){
                         acc.Co_owner_First_Name__c = acc.Co_owner_First_Name__c.substring(0, 1).toUpperCase() + acc.Co_owner_First_Name__c.substring(1).toLowerCase();
                    }
                    if(acc.Co_owner_Last_Name__c != null ){
                         acc.Co_owner_Last_Name__c =  acc.Co_owner_Last_Name__c.substring(0, 1).toUpperCase() + acc.Co_owner_Last_Name__c.substring(1).toLowerCase();
                    }*/
                }
                
                if(!affiliateIdString.isEmpty()){
                    affiliateIdList = [Select Id, Affiliate_Id__c, Send_Email__c 
                                       From Affiliate_Id__c 
                                       Where Affiliate_Id__c IN: affiliateIdString
                                       And Send_Email__c = true];
                }
                
                for(Affiliate_Id__c rec : affiliateIdList){
                    queriedAffiliateIdString.add(rec.Affiliate_Id__c);
                }
                
                for(Account acc : trigger.new){
                    
                    if(acc.Affiliated_Id__c != null && acc.Preferred_Language__c != null && queriedAffiliateIdString.contains(string.valueOf(acc.Affiliated_Id__c))){
                        if(acc.Preferred_Language__c == 'ENG'){
                            acc.Send_English_Enrollment_Email__c = true;
                        }else if(acc.Preferred_Language__c == 'SPA'){
                            acc.Send_Spanish_Enrollment_Email__c = true;
                        }
                    }
                }
            }
            if(trigger.isBefore && !trigger.isDelete){
                List<Account> accountsToOverrideOwner = new List<Account>();
                for(Account acc : trigger.new){
                    if(acc.Affiliated_Id__c == 1002241 && acc.Preferred_Language__c == null){
                        acc.Preferred_Language__c = 'ENG';
                    }
                    if(acc.Name.contains('_test') || acc.Name.contains('_Test'))
                    {
                        accountsToOverrideOwner.add(acc);
                    }
                }
                //logic to not assign any test records to agents in Prod
                MU_Jobs_test_Record_Filter__c testRecordsFilterSettings = MU_Jobs_test_Record_Filter__c.getValues('Filters Enabled');
                if(testRecordsFilterSettings != null){
                    if(testRecordsFilterSettings.Any_Test_Record__c && accountsToOverrideOwner != null && accountsToOverrideOwner.size()>0)
                    {
                        //original admin owner map
                        Map<Id, User> m = new Map<Id, User>([SELECT Id,Username FROM User WHERE Username = 'dev@nerdsoft.com.hsi' OR Username = 'dev@nerdsoft.com.hsi.full' OR Username = 'dev@nerdsoft.com.hsi.1' OR Username = 'dev@nerdsoft.com.hsi.1.full' OR Username = 'zappier@nerdsoft.com' OR Username = 'zappier@nerdsoft.com.full']);
                        
                        List<User> devAccountUser = new List<User>();
                        for(Id userid : m.keySet())
                        {
                            if(m.get(userid).Username == 'dev@nerdsoft.com.hsi' || m.get(userid).Username == 'dev@nerdsoft.com.hsi.full')
                            {
                                devAccountUser.add(m.get(userid));
                            }
                        }     
                        if(m != null && m.size()>0){
                            if(devAccountUser != null && devAccountUser.size()>0){
                                for(Account act : accountsToOverrideOwner)
                                {
                                    if(m.get(act.CreatedById) != null)
                                    {
                                        act.OwnerId = act.CreatedById;
                                    }
                                    else if(m.get(act.OwnerId) == null)
                                    {
                                        act.OwnerId = devAccountUser[0].Id;
                                    }
                                }                    
                            }
                        }
                    }
                }
            }
        }
        
        if(trigger.isBefore && trigger.isUpdate){
            //Membership Status Validations
            Boolean hasAdminPermission = FeatureManagement.checkPermission('IsSystemAdmin');
            if(!hasAdminPermission){
                Boolean changesAllowed = true;
                Id currentUserId = UserInfo.getUserId();
                List<User> userList = [SELECT Id,UserRole.Name,Profile.Name FROM User WHERE Id =: currentUserId AND UserRoleId != null AND ProfileId != null AND UserRole.Name != NULL and Profile.Name != NULL];
                if(userList != null && userList.size()>0){
                    User u = userList[0];
                    if(u.Profile.Name != 'System Administrator' && (u.UserRole.Name.contains('TourGen'))){
                        for(Account Acc:(List<Account>)Trigger.New){
                            Account oldAcc = (Account)Trigger.oldMap.get(Acc.Id);
                            if(Acc.Membership_Status__c != oldAcc.Membership_Status__c && Acc.Membership_Status__c != 'CancelByMember')
                            {
                                Acc.addError('You are not allowed to make this change.');
                                changesAllowed = false;
                            }
                            if(Acc.Membership_Status__c != oldAcc.Membership_Status__c && Acc.Membership_Status__c == 'CancelByMember')
                            {
                                //Acc.addError('Please use the cancel button in page top-right to cancel de member.');
                                changesAllowed = false;
                            }
                        }
                    }
                    else if(u.Profile.Name != 'System Administrator' && (u.UserRole.Name.contains('Customer Care Agent') || u.UserRole.Name.contains('Customer Service'))){
                        for(Account Acc:(List<Account>)Trigger.New){
                            Account oldAcc = (Account)Trigger.oldMap.get(Acc.Id);
                            if(Acc.Membership_Status__c != oldAcc.Membership_Status__c && Acc.Membership_Status__c != 'CancelByMember' && Acc.Membership_Status__c != 'Active')
                            {
                                Acc.addError('You are not allowed to make this change.');
                                changesAllowed = false;
                            }
                            if(Acc.Membership_Status__c != oldAcc.Membership_Status__c && Acc.Membership_Status__c == 'CancelByMember')
                            {
                                //Acc.addError('Please use the cancel button in page top-right to cancel the member.');
                                changesAllowed = false;
                            }
                        }
                    }
                }                
            }
            //Membership Status Last Modified Date MCFU-18 / MCFU-25
            for(Account newAccountRecord:(List<Account>)Trigger.New){
               // newAccountRecord.Test_Amadeu__c = 'This is a test from the system';
                Account oldAccountRecord = (Account)Trigger.oldMap.get(newAccountRecord.Id);
                if (newAccountRecord.Membership_Status__c != oldAccountRecord.Membership_Status__c){
                    newAccountRecord.Membership_Status_Last_Modified_Date__c = System.Now();
                    
                }
            }
        }
         
/*        
        if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
            //call Acoustic Welcome Email API - CVC-222
            List<Account> qualifiedAccounts = new List<Account>();
            
            for (Account acc : Trigger.new) {
                if (
                    acc.Marketing_Email_opt_out__c == true &&
                    acc.Email_Opt_Out__c == false &&
                    acc.Membership_Status__c == 'Active' &&
                    acc.Preferred_Language__c != 'SPA' &&
                    acc.Enrollment_Date__c == Date.today() &&
                    acc.Membership_Product_Config_Ext_Db__c != null &&
                    new Set<String>{'A1002455','A1002454','A1002456'}.contains(acc.Membership_Product_Config_Ext_Db__c) &&
                    acc.Acoustic_Welcome_Email_Sent_Date__c == null
                ) {
                    qualifiedAccounts.add(acc);
                }
            }
            
            if (!qualifiedAccounts.isEmpty()) {
                System.enqueueJob(new AcousticCampaignQueueable(qualifiedAccounts));
            }
            
        }
*/        
    }
}