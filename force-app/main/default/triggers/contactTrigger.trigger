trigger contactTrigger on Contact (after insert, before update ,after update,before insert) { 
    Apex_Trigger_On_Off__c contactTrigger = Apex_Trigger_On_Off__c.getValues('Contact-Trigger');
    if(contactTrigger != null && contactTrigger.isEnable__c){
        if(trigger.isInsert && trigger.isAfter){
            ContactFlags.hasInsertRun = true;
        }
        /* 
        if(trigger.isBefore && (trigger.isupdate || trigger.isinsert) ){
        system.debug('9 Trigger');
        AssignContactTourGenLoyalty.AssignContactTourGenLoyalty(trigger.new);
        
        }
        
        if(trigger.isAfter && trigger.isUpdate){
        
        set<contact> removedContactList= new set<contact>();
        set<id> removedContactListId= new set<Id>();
        map<id,contact> removedContactMap = new map<id,contact>();
        
        for(contact con: trigger.new){
        
        system.debug('11===='+con);
        if(con.ActionCadenceId==null && con.ActionCadenceId != Trigger.oldMap.get(con.Id).ActionCadenceId && con.ActionCadenceState==null && con.ActionCadenceState != Trigger.oldMap.get(con.Id).ActionCadenceState){
        
        system.debug('14--'+con);
        removedContactMap.put(con.id,con);
        
        }
        
        }
        
        for(ActionCadenceStepTracker act: [select id,CompletionDate,targetId from ActionCadenceStepTracker where targetId IN: removedContactMap.keyset()]){
        
        if(act.completiondate==null){
        
        system.debug('233==='+removedContactMap.get(act.TargetId).ownerId);
        system.debug('233==='+removedContactMap.get(act.TargetId).name);
        
        }
        }
        
        }*/
        // SF Contact Member Sync to SQL and BE
        //System.debug('47= '+ Trigger.new);
        if(trigger.isafter && trigger.isUpdate){
            //2024-04-29 [ACI-7] Sync real time email between Account and Primary Contact
            Map<Id,String> syncPrimaryContactEmail = new Map<Id,String>();
            Map<Id,String> syncPrimaryContactFirstName = new Map<Id,String>();
            Map<Id,String> syncPrimaryContactLastName = new Map<Id,String>();
            Map<Id,Boolean> syncPrimaryContactDNC = new Map<Id,Boolean>();
            
            Set<Id> ContactIdSet = new Set<Id>();
            Set<Id> removeContactID= new Set<Id>();
            List<Contact> removeContacts= new list<Contact>();
            for(Contact con : Trigger.new){
                removeContactID.add(con.id);
                if(!System.isFuture() && con.Is_Main_Contact__c && con.AccountId != null && con.Email != null && con.Email != Trigger.oldMap.get(con.Id).Email)
                {
                    syncPrimaryContactEmail.put(con.AccountId,con.Email);
                }   
                if(!System.isFuture() && con.Is_Main_Contact__c && con.AccountId != null && ((con.FirstName != null && con.FirstName != Trigger.oldMap.get(con.Id).FirstName) ||(con.LastName != null && con.LastName != Trigger.oldMap.get(con.Id).LastName))) {
                    syncPrimaryContactFirstName.put(con.AccountId,con.FirstName);
                    syncPrimaryContactLastName.put(con.AccountId,con.LastName);
                }   
                if(!System.isFuture() && con.Is_Main_Contact__c && con.AccountId != null && con.DoNotCall != null && con.DoNotCall != Trigger.oldMap.get(con.Id).DoNotCall ) {
                    syncPrimaryContactDNC.put(con.AccountId,con.DoNotCall);
                }
                /*               
if(con.Membership_Status__c !='Active' && con.ActionCadenceId=='77C3t000000XwNgEAK' && con.ActionCadenceId != null){
system.debug('53='+con.Name);
removeContactID.add(con.id);
}*/
                if(con.Bypass_Sync_to_SQL__c == false){
                    if( 
                        (con.FirstName != Trigger.oldMap.get(con.Id).FirstName) || 
                        (con.LastName != Trigger.oldMap.get(con.Id).LastName) || 
                        (con.Email != Trigger.oldMap.get(con.Id).Email) || 
                        (con.Phone != Trigger.oldMap.get(con.Id).Phone) || 
                        
                        (con.MailingStreet != Trigger.oldMap.get(con.Id).MailingStreet) || 
                        (con.MailingCity != Trigger.oldMap.get(con.Id).MailingCity) || 
                        (con.MailingState != Trigger.oldMap.get(con.Id).MailingState) ||
                        (con.MailingCountry != Trigger.oldMap.get(con.Id).MailingCountry) || 
                        (con.MailingPostalCode != Trigger.oldMap.get(con.Id).MailingPostalCode) ||
                        (con.Alternate_Phone__c != Trigger.oldMap.get(con.Id).Alternate_Phone__c) ||
                        (con.Alternate_Phone_1__c != Trigger.oldMap.get(con.Id).Alternate_Phone_1__c)
                        
                    ){
                        if(con.Master_Record_Id__c == null || con.Master_Record_Id__c == ''){
                            con.addError('Please Enroll Member before making updates on the contact');
                        }
                        else if(con.FirstName == null || con.FirstName == ''){
                            con.addError('First Name is Required');
                        }
                        else{
                            ContactIdSet.add(con.Id);
                        }
                    }
                }
            }
            
            removeContacts=[Select id,name,ActionCadenceId,Membership_Status__c from contact where Membership_Status__c!='Active' and ActionCadenceId='77C3t000000XwNgEAK' and id IN: removeContactID];
            
            system.debug('89=='+removeContacts);
            Set<Id> removeContactIDSet2= new Set<Id>();
            for(contact con:removeContacts){
                system.debug('93='+removeContacts);
                
                removeContactIDSet2.add(con.id);
            }
            if(removeContactIDSet2 != null && removeContactIDSet2.size()!=0){
                system.debug('98==');
                
                System.enqueueJob(new RemoveTargetFromSalesCadenceQueueable(removeContactIDSet2)); 
                
            }
            if(ContactIdSet != null && ContactIdSet.size() > 0){
                System.debug('ContactIdSet = '+ContactIdSet);
                if(!System.isFuture()){
                    DataSyncToSQL.AccountContactDataSync(ContactIdSet,'Contact');
                }
            }
            Boolean hasAdminPermission = FeatureManagement.checkPermission('IsSystemAdmin');
            Map<String,String> ConsToSendToBE = new Map<String,String>();
            Set<Id> conIdsToSyncToBE = new Set<Id>();
            if(!hasAdminPermission){                
                Id currentUserId = UserInfo.getUserId();
                List<User> userList = [SELECT Id,UserRole.Name,Profile.Name FROM User WHERE Id =: currentUserId AND UserRoleId != null AND ProfileId != null AND UserRole.Name != NULL and Profile.Name != NULL];
                if(userList != null && userList.size()>0){
                    User u = userList[0];
                    if(u.Profile.Name != 'System Administrator' ){                 
                        Map<Id,Account> AccsToSync = new Map<Id,Account>();
                        Map<Id,Contact> ConsToSync = new Map<Id,Contact>();
                        Set<Id> accIds = new Set<Id>();
                        for(Contact Con:(List<Contact>)Trigger.New){
                            Contact oldCon = (Contact)Trigger.oldMap.get(Con.Id);
                            if(Con.Membership_Status__c != oldCon.Membership_Status__c)
                            {
                                ConsToSendToBE.put(Con.Member_Number__c,Con.Membership_Status__c);
                                conIdsToSyncToBE.add(Con.Id);
                                if((Con.Membership_Status__c == 'CancelByMember' || Con.Membership_Status__c == 'Active') && con.Is_Main_Contact__c){
                                    ConsToSync.put(Con.Id,Con);
                                    accIds.add(con.AccountId);
                                }
                            }
                        }
                        if(ConsToSync != null && ConsToSync.size()>0)
                        {
                            List<Account> allRelatedAccounts = new List<Account>();
                            allRelatedAccounts = [SELECT Id,Membership_Status__c,Parent_Child_Contact_Id__c FROM Account WHERE Parent_Child_Contact_Id__c IN : ConsToSync.keySet() AND Id IN : accIds];
                            List<Account> allAccountsToUpdate = new List<Account>();
                            if(allRelatedAccounts != null && allRelatedAccounts.size()>0){
                                for(Account acc : allRelatedAccounts)
                                {
                                    if(ConsToSync.get(acc.Parent_Child_Contact_Id__c).Membership_Status__c != acc.Membership_Status__c && ((ConsToSync.get(acc.Parent_Child_Contact_Id__c).Membership_Status__c == 'CancelByMember') || ConsToSync.get(acc.Parent_Child_Contact_Id__c).Membership_Status__c == 'Active'))
                                    {
                                        acc.Membership_Status__c = ConsToSync.get(acc.Parent_Child_Contact_Id__c).Membership_Status__c;
                                        allAccountsToUpdate.add(acc);
                                    }
                                }
                                if(allAccountsToUpdate != null && allAccountsToUpdate.size()>0)
                                {
                                    update allAccountsToUpdate;
                                }
                            }
                        }
                    }
                }                
            }
            if(ConsToSendToBE != null && ConsToSendToBE.size() > 0){
                system.debug('ConsToSendToBE---'+ConsToSendToBE);
                MembershipDataSyncToBE.MembershipDataSync(ConsToSendToBE,conIdsToSyncToBE);
            }
            if(syncPrimaryContactEmail != null && syncPrimaryContactEmail.size()>0)
            {
                //sync from main contact to parent account
                AccountTriggerHelper.syncEmail(syncPrimaryContactEmail,'Account');
            }  
            //Sync FirstName & LastName
            if(syncPrimaryContactFirstName != null && syncPrimaryContactFirstName.size() > 0){
				//sync from Main Contact to Parent Account
                AccountTriggerHelper.syncNameAccountANDContact(syncPrimaryContactFirstName,syncPrimaryContactLastName,'Contact');
            }  
            //Sync Do Not Call
            if(syncPrimaryContactDNC != null && syncPrimaryContactDNC.size() > 0){
				//sync from Main Contact to Parent Account
                AccountTriggerHelper.syncDNC(syncPrimaryContactDNC,'Contact');
            }
        }
        if(trigger.isAfter){
            Set<Id> conSet = new Set<Id>();
            Set<Id> setContactIds = new Set<Id>();
            List<Account> accList = new List<Account>();
            List<Contact> conList = new List<Contact>();
            MAP<String,String> accMap = new MAP<String,String>();
            List<Account> aUpdate = new List<Account>();
            set<String> accId = new Set<String>();
            for(Contact con : trigger.new) {
                conSet.add(con.Id);
                if(trigger.isAfter && trigger.isInsert && con.AccountId != null && con.AffiliatedId__c == 1002464){
                    setContactIds.add(con.Id);
                }
                System.debug('conset ' + conSet);
            }
            conList = [Select Id, AccountId, Parent_Id_Ext_Db__c FROM Contact WHERE Parent_Id_Ext_Db__c = null AND Id IN :conSet];
            System.debug('conList ' + conList);
            
            for(Contact con : conList) {
                accId.add(con.AccountId);
                accMap.put(con.Accountid, con.id);
                System.debug('accMap ' + accMap);
            }
            
            accList = [Select Id, Parent_Child_Contact_Id__c FROM Account WHERE Id IN :accId];
            System.debug('accList ' + accList);
            
            for(Account acc : accList) {
                if(acc.Parent_Child_Contact_Id__c == null || acc.Parent_Child_Contact_Id__c == '') {
                    acc.Parent_Child_Contact_Id__c = accMap.get(acc.id);
                    aUpdate.add(acc);
                }
            }
            update aUpdate;    
            if(trigger.isAfter && trigger.isInsert && setContactIds != null && setContactIds.size() > 0) { 
            	contactTriggerHandler.assignRaiseAwayContactstoTourGen(setContactIds);
            }
        }
        
        // SF Contact to Sales Cadences
        if(trigger.isafter && trigger.isUpdate){
            Set<Id> contactsToAssignCadence = new Set<Id>();
            //Set<ID> contactsToAssignCadence30Days = New Set<ID>();
            //Set<ID> contactsToAssignCadence31Days = New Set<ID>();
            
            
            list<String> AffiliateName2=new list<String>{'SFX - Diamond','SFX - Diamond Plus','SFX - Diamond Preferred','SFX - Diamond Premier','SFX - Gold','Hawaii Collection','Hawaii Collection - Gold','Hawaii Collection- Platinum','Hawaii Collection - Platinum','Vida Vacations','Hawaii Collection - Silver','The Grand Mayan Los Cabos (Exit)','The Grand Mayan Los Cabos','Mayan Palace Riviera Maya (Exit)','Sharelife','Mayan Palace Riviera Maya','Mayan Palace Puerto Penasco (Exit)','Mayan Palace Puerto Peñasco','Mayan Palace Nuevo Vallarta (Exit)','Mayan Palace Nuevo Vallarta','Mayan Palace Acapulco (Exit)','Mayan Palace Acapulco','Mayan Palace - Sea Garden Mazatlan (Exit)','Mayan Palace - Sea Garden Mazatlán','Mayan National Exit','Mayan National Add-On (V.O.)','Mayan National Add-On (V.C.)','Mayan National Add-On','Mayan International Exit','Mayan International Add-On','MAYAN'};
                list<String> newContactId= new list<String>();
            
            Map<String, set<Id>> MapCadenceNameVsContactIds = new Map<String,set<Id>>();
            List<Contact> listContact = new List<Contact>();
            Map<String, Boolean> UpdateAccountEmailOptOut = new Map<String,Boolean>();
            for(Contact con : trigger.new){
                system.debug('151='+con);
                system.debug('151='+Trigger.oldMap.get(con.Id).ActionCadenceId);
                system.debug('151='+Trigger.newMap.get(con.Id).ActionCadenceId);
                
                system.debug('153='+con.Assign_to_Sales_Cadence_Name__c);
                system.debug('153='+con.name);
                
                newContactId.add(con.id);
                if(trigger.oldMap.get(con.Id).Marketing_Email_opt_out__c != con.Marketing_Email_opt_out__c){//con.Marketing_Email_opt_out__c && !trigger.oldMap.get(con.Id).Marketing_Email_opt_out__c && 
                    listContact.add(con);
                    if(con.Is_Main_Contact__c){
                        UpdateAccountEmailOptOut.put(con.AccountId,con.Marketing_Email_opt_out__c);
                    }
                }
            }
            if(listContact != null && listContact.size() > 0){
                UnsubscribeRecordsHandler.unsubscribe(listContact,'Contact');
            }
            List<Account> listAcc = new List<Account>();
            if(UpdateAccountEmailOptOut != null && UpdateAccountEmailOptOut.size() > 0){
                for(Account objacc : [select id,Marketing_Email_opt_out__c from Account where Id IN : UpdateAccountEmailOptOut.keyset()]){
                    //Account objacc = new Account();
                    System.debug('>>objacc.Marketing_Email_opt_out__c>>>'+objacc.Marketing_Email_opt_out__c);
                    System.debug('>>UpdateAccountEmailOptOut.get(objacc.Id)>>>'+UpdateAccountEmailOptOut.get(objacc.Id));
                    if(objacc.Marketing_Email_opt_out__c != UpdateAccountEmailOptOut.get(objacc.Id)){
                        objacc.Marketing_Email_opt_out__c = UpdateAccountEmailOptOut.get(objacc.Id);
                        listAcc.add(objacc);
                    }
                }
            }
            if(listAcc != null && listAcc.size() > 0){
                update listAcc;
            }
            list<contact> newContact =new list<contact>();
            //con.AffiliatedId__c == 1002336 added 2022-09-18
            //newContact=[Select id,Tour_Vida_Active_SSR_Match_Group__c,Tour_Vida_Inactive_SSR_Match_Group__c,Assign_to_Sales_Cadence_Name__c,Assign_to_Sales_Cadence__c,ActionCadenceId,Account.Affiliate_Name__c,Cadence_Flag__c,AffiliatedId__c from contact where id IN:newContactId];
            newContact=[Select id,Tour_Vida_Active_SSR_Match_Group__c,Tour_Vida_Inactive_SSR_Match_Group__c,Assign_to_Sales_Cadence_Name__c,Assign_to_Sales_Cadence__c,ActionCadenceId,Account.Affiliate_Name__c,Cadence_Flag__c,AffiliatedId__c,Parent_Id_Ext_Db__c from contact where id IN:newContactId];
            for(Contact con : newContact){  
                system.debug('213='+Trigger.oldMap.get(con.Id).Cadence_Flag__c);
                
                if((con.Tour_Vida_Active_SSR_Match_Group__c == 'TRUE' || con.Tour_Vida_Inactive_SSR_Match_Group__c == 'TRUE' || con.AffiliatedId__c == 1002336) &&
                   con.Assign_to_Sales_Cadence__c && con.Parent_Id_Ext_Db__c == null && con.Assign_to_Sales_Cadence_Name__c != null && con.ActionCadenceId == NULL && !AffiliateName2.contains(con.Account.Affiliate_Name__c)
                  ){
                      if(con.Cadence_Flag__c!=1 && con.Assign_to_Sales_Cadence_Name__c!='TourGen-Vacation VIP Members'){
                          contactsToAssignCadence.add(con.Id);
                          system.debug('120='+contactsToAssignCadence);
                      }
                      if(con.Cadence_Flag__c==1 && con.Assign_to_Sales_Cadence_Name__c=='TourGen-Vacation VIP Members' && Trigger.oldMap.get(con.Id).Cadence_Flag__c==0){
                          contactsToAssignCadence.add(con.Id);
                      }
                  }            
                //2023-09-12 - PA-31 - ProfitAgility Agency MX Vouchers - SF
                /*else if(con.Assign_to_Sales_Cadence_Name__c != Trigger.oldMap.get(con.Id).Assign_to_Sales_Cadence_Name__c && con.Assign_to_Sales_Cadence_Name__c == 'TourGen-ProfitAgility Agency')
                {
                    contactsToAssignCadence.add(con.Id);
                }*/
                
            }
            if(contactsToAssignCadence != null && contactsToAssignCadence.size() > 0){
                
                OpportunityTrigger_NewHandler.sendSalesCadenceRequest(contactsToAssignCadence,null);
                /*for(Contact conRec : contactsToAssignCadence){         
system.debug('125='+conRec);
if(conRec.Cadence_Flag__c!=1){
OpportunityTrigger_NewHandler.sendSalesCadenceRequest(conRec.Id, conRec.Assign_to_Sales_Cadence_Name__c);
}
}*/
            }
        }
        //SF Contact Sales Cadences Count
        if(trigger.isBefore && trigger.isUpdate){
            
            for(Contact con : trigger.new){
                if(con.ActionCadenceId != null && con.ActionCadenceId != '' && con.AffiliatedId__c == 1002336 && con.Cadence_Flag__c !=1)
                {
                    con.Cadence_Flag__c = 1;
                }
                //2023-09-12 - PA-31 - ProfitAgility Agency MX Vouchers - SF
                if(con.Match_Group_Name__c == 'TourGen-ProfitAgility Agency' && con.leadassist__Use_Round_Robin__c != Trigger.oldMap.get(con.Id).leadassist__Use_Round_Robin__c && con.leadassist__Use_Round_Robin__c == 'ASSIGNED')
                {
                    con.Assign_to_Sales_Cadence_Name__c = 'TourGen-ProfitAgility Agency';
                }
                
            }
            
            //Membership Status Validations
            Boolean hasAdminPermission = FeatureManagement.checkPermission('IsSystemAdmin');
            if(!hasAdminPermission){
                Id currentUserId = UserInfo.getUserId();
                List<User> userList = [SELECT Id,UserRole.Name,Profile.Name FROM User WHERE Id =: currentUserId AND UserRoleId != null AND ProfileId != null AND UserRole.Name != NULL and Profile.Name != NULL];
                if(userList != null && userList.size()>0){
                    User u = userList[0];
                    if(u.Profile.Name != 'System Administrator')
                    {
                        Map<Id,Contact> contactsToCheckAccount = new Map<Id,Contact>();
                        Set<Id> relatedAccsIds = new Set<Id>();
                        for(Contact Con:(List<Contact>)Trigger.New){
                            Contact oldCon = (Contact)Trigger.oldMap.get(Con.Id);
                            if(Con.Membership_Status__c != oldCon.Membership_Status__c){
                                if(Con.Is_Main_Contact__c){
                                    if(u.UserRole.Name.contains('TourGen')){
                                        if(Con.Membership_Status__c != 'CancelByMember')
                                        {
                                            Con.addError('You are not allowed to make this change.');
                                        }
                                        if(Con.Membership_Status__c == 'CancelByMember')
                                        {
                                            //Con.addError('Please use the cancel button in page top-right to cancel de member.');
                                        }
                                    }
                                    else if(u.UserRole.Name.contains('Customer Care Agent') || u.UserRole.Name.contains('Customer Service')){                                    
                                        if(Con.Membership_Status__c != 'CancelByMember' && Con.Membership_Status__c != 'Active')
                                        {
                                            Con.addError('You are not allowed to make this change.');
                                        }
                                        if(Con.Membership_Status__c == 'CancelByMember')
                                        {
                                            //Con.addError('Please use the cancel button in page top-right to cancel de member.');
                                        }
                                    }
                                }
                                else
                                {
                                    contactsToCheckAccount.put(Con.Id,Con);
                                    relatedAccsIds.add(Con.AccountId);
                                    //Con.addError('Membership Status changes are only allowed in the main contact.');
                                }
                            }
                        }
                        if(contactsToCheckAccount != null && contactsToCheckAccount.size()>0){
                            Map<Id,Account> relatedAccs = new Map<Id,Account>([SELECT Id,Membership_Status__c FROM Account WHERE Id IN : relatedAccsIds]);
                            for (Id conId : contactsToCheckAccount.keySet())
                            {
                                //bypass when user is trying to cancel the member, to update all related records (all contacts)
                                if(!(contactsToCheckAccount.get(conId).Membership_Status__c == relatedAccs.get(contactsToCheckAccount.get(conId).AccountId).Membership_Status__c && relatedAccs.get(contactsToCheckAccount.get(conId).AccountId).Membership_Status__c == 'CancelByMember'))
                                {
                                    contactsToCheckAccount.get(conId).addError('Membership Status changes are only allowed in the main contact.');
                                }
                            }
                        }
                    }
                }                
            }
        }
        if(Trigger.isBefore)
        {
            List<Contact> contactsToOverrideOwner = new List<Contact>();
            for(Contact con : trigger.new){
                String conFullName = con.FirstName+' '+con.LastName;
                if(conFullName.contains('_test') || conFullName.contains('_Test'))
                {
                    contactsToOverrideOwner.add(con);
                }
            }
            //logic to not assign any test records to agents in Prod
            MU_Jobs_test_Record_Filter__c testRecordsFilterSettings = MU_Jobs_test_Record_Filter__c.getValues('Filters Enabled');
            if(testRecordsFilterSettings != null)
            {
                if(testRecordsFilterSettings.Any_Test_Record__c && contactsToOverrideOwner != null && contactsToOverrideOwner.size()>0)
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
                    
                    if(m != null && m.size()>0)
                    {
                        if(devAccountUser != null && devAccountUser.size()>0){
                            for(Contact contct : contactsToOverrideOwner)
                            {
                                if(m.get(contct.CreatedById) != null)
                                {
                                    contct.OwnerId = contct.CreatedById;
                                }
                                else if(m.get(contct.OwnerId) == null)
                                {
                                    contct.OwnerId = devAccountUser[0].Id;
                                }
                            }                    
                        }
                    }
                }
            }
        }
    }
}