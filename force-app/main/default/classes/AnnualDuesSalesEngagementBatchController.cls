/** 
Annual Dues-Past Due SMTN
Annual Dues-Past Due SFX
Annual Dues-Past Due Hawaii Collection
Annual Dues-Past Due Advantage Program/HSI

Annual Dues-Pre Due SMTN
Annual Dues-Pre Due SFX
Annual Dues-Pre Due Hawaii Collection
Annual Dues-Pre Due Advantage Program/HSI

2023-10-17 - HSIMU2-341 - Annual Dues SPA added:
2024-12-26 - TGR-400 - Remove SFX Gold - 1002275 from advantage Program


Annual Dues-Pre Due SFX SPA
Annual Dues-Pre Due Hawaii Collection SPA
Annual Dues-Pre Due Advantage Program/HSI SPA
Annual Dues-Past Due SFX SPA
Annual Dues-Past Due Hawaii Collection SPA
Annual Dues-Past Due Advantage Program/HSI SPA

*/
public class AnnualDuesSalesEngagementBatchController implements Database.Batchable<sObject>, Schedulable{
    public void execute(SchedulableContext SC) {
        AnnualDuesSalesEngagementBatchController objBatch = new AnnualDuesSalesEngagementBatchController(); 
        database.executebatch(objBatch, 1);
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        Set<Integer> SMTNaffilateIDSet = new Set<Integer>{1002222,1002347,1002343,1002223,1002224,1002327};
            set<Integer> SFXAffilateIdSet = new set<Integer>{1002276,1002319,1002320};  //1002277 
                set<Integer> HCAffilateIdSet = new set<Integer>{1002243,1002310,1002311,1002312};
                    set<Integer> CFDAffilateIdSet = new set<Integer>{1002266,1002256};
                        set<Integer> APHSIAffilateIdSet = new set<Integer>{1002222,1002347,1002343,1002223,1002224,1002327,1002243,1002311,1002312,1002310,1002257,1002277,1002276,1002319,1002320,1002336,1002274,1002241,1002409,1002275}; 
                            set<String> membershipstatus = new set<String>{'Active','FrozenByHSI'};
                                set<String> languagePrefered = new set<String>{'SPA'};
                                    
                                    boolean CheckMFProtection = true; 
        //String strName = '_test';  Name LIKE \'%' + strName + '%\' and
        //set<String> setOfIds = new set<String>{'0013t00002NJ3HJAA1', '0013t00002KZZZ9AAP','0013t00002FgnZUAAZ','0013t00002PyC8TAAV','0013t00002Qmd63AAB','0013t00002NJ3HJAA1', '0013t00001bIfgpAAC','0013t00001bIfgoAAC', '0013t00002RDqNcAAL'};ID IN : setOfIds and
        //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
        String query = '';
        if (Test.isRunningTest()) {
	        query = query + 'SELECT Id,Name,Affiliated_Id__c,Enrollment_Date__c,Preferred_Language__c from Account ';
            query = query + '    where (Affiliated_Id__c IN :CFDAffilateIdSet ';
            query = query + '           or (Affiliated_Id__c IN :SMTNaffilateIDSet and Preferred_Language__c NOT IN :languagePrefered) ';
            query = query + '           or Affiliated_Id__c IN :SFXAffilateIdSet ';
            query = query + '           or Affiliated_Id__c IN : HCAffilateIdSet ';
            query = query + '           or Affiliated_Id__c NOT IN :APHSIAffilateIdSet';
            query = query + '             or Affiliated_Id__c IN :APHSIAffilateIdSet) ';
            query = query + '    AND Membership_Product_Configuration__r.Responsible_Party__c = \'Member\' ';
            query = query + '    AND Membership_Status__c IN :membershipstatus AND (NOT(MFProtection__c =: CheckMFProtection))';
        } else {
            query = query + 'SELECT Id,Name,Affiliated_Id__c,Enrollment_Date__c,Preferred_Language__c from Account where (Affiliated_Id__c IN :CFDAffilateIdSet or (Affiliated_Id__c IN :SMTNaffilateIDSet and Preferred_Language__c NOT IN :languagePrefered) or Affiliated_Id__c IN :SFXAffilateIdSet or Affiliated_Id__c IN : HCAffilateIdSet or Affiliated_Id__c NOT IN :APHSIAffilateIdSet) AND Membership_Product_Configuration__r.Responsible_Party__c = \'Member\' AND Membership_Status__c IN :membershipstatus AND (Dues_Last_Paid_Until__c = LAST_MONTH OR Dues_Last_Paid_Until__c = NEXT_MONTH) AND (NOT(MFProtection__c =: CheckMFProtection))';
        }

        //for test:
        //query = query + ' and Id in ( \'0014z00001zG4PTAA0\' , \'0013t00002Qmu2RAAR\' ) ';
        //query = query + ' and Id in ( \'0013t00002Qmupg\' , \'0013t00002QoIk7\' , \'0013t00002QmuS5\' , \'0014z00001tYlYe\' ) ';
 
            
        system.debug(query);
        return Database.getQueryLocator(query); 
    }
    public void execute(Database.BatchableContext BC, List<Account> scope){
        //annualDuesBatchLogs
        List<Annual_Dues_Log__c> logsToUpsert = new List<Annual_Dues_Log__c>();
        Map<Id, String> accountIdToSkipReason = new Map<Id, String>();
        Map<Id, String> accountIdToMatchGroup = new Map<Id, String>();
        Set<Id> updatedAccountIds = new Set<Id>();
        String currentMonthStr = System.today().month() + '-' + System.today().year();
        Map<Id, Contact> accountIdToParentContact = new Map<Id, Contact>();
        
        // Pre-fetch parent contacts for accounts
        for (Contact con : [SELECT id,AccountId,Match_Group_Name__c,Account.name,name,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,Cadence_Flag__c,Account.Dues_Last_Paid_Until__c, Account.Affiliated_Id__c, Account.Preferred_Language__c, Account.Membership_SubType__c FROM Contact WHERE AccountId IN :scope]) {
            if (con.Account.Name != null && con.Account.Name.equalsIgnoreCase(con.Name)){
                accountIdToParentContact.put(con.AccountId, con);
            }
        }
        
        //annualDuesBatchLogs
        
        
        Boolean flag = true;
        map<String ,decimal> mapAccountIdToPaymentId = new map<String, decimal>();
        Set<Decimal> SMTNaffilateIDSet = new Set<Decimal>{1002222,1002347,1002343,1002223,1002224,1002327};
            set<Decimal> SFXAffilateIdSet = new set<Decimal>{1002276,1002319,1002320};   //1002277
                set<Decimal> HCAffilateIdSet = new set<Decimal>{1002243,1002310,1002311,1002312};
                    set<Decimal> CFDAffilateIdSet = new set<Decimal>{1002266,1002256};
                        set<Decimal> APHSIAffilateIdSet = new set<Decimal>{1002222,1002347,1002343,1002223,1002224,1002327,1002243,1002311,1002312,1002310,1002257,1002277,1002276,1002319,1002320,1002336,1002274,1002241,1002409,1002275};
                            set<String> SFXMembershipSubType = new set<String>{'renew-1yr-99','Annual Renew 149','Annual Renew 19','Annual Renew 29', 'Annual Renew 39','Annual Renew 59','Annual Renew 69','Annual Renew 79','Annual Renew 99','Annual Renew 249', 'ICE Upgrade', 'ICE Renewal'};                
                                set<Decimal> AffilateIdToCheckTransactingSet = new set<Decimal>{1002266,1002256,1002421,1002440,1002243}; //1002277
                                    Integer currentMonth = System.today().month();
        
        //HSIMU2-489 Annual Dues Pre Due did not get added to Sales Cadence
        Integer nextMonthValue;
        Integer lastMonthValue;
        
        // Calculate next month
        if (currentMonth == 12) {
            nextMonthValue = 1; // If the current month is December, next month is January of the next year
        } else {
            nextMonthValue = currentMonth + 1;
        }
        
        // Calculate last month
        if (currentMonth == 1) {
            lastMonthValue = 12; // If the current month is January, last month is December of the previous year
        } else {
            lastMonthValue = currentMonth - 1;
        }
        
        List<Contact> updateContactList = new List<Contact>();
        set<Id> cadenceContactIds = new set<Id>();
        set<Id> setAccountId = new set<Id>();
        List<Contact> parentContacts = new List<Contact>();
        
        Map<String, set<Id>> MapCadenceNameVsContactIds = new Map<String,set<Id>>();
        for(Account acc : scope){
            if(CFDAffilateIdSet.contains(acc.Affiliated_Id__c) && acc.Enrollment_Date__c<Datetime.newInstanceGmt(2023, 8, 30, 0, 0, 0)){
                system.debug('CFD Affiliates before 30 AUG');
            }
            else{
                setAccountId.add(acc.Id);
            }
        }
        //HSIMU2-489 Annual Dues Pre Due did not get added to Sales Cadence
        set<String> matchGroupNames = new set<String>{'Annual Dues-Pre Due SMTN','Annual Dues-Pre Due SFX','Annual Dues-Pre Due SFX SPA','Annual Dues-Pre Due Hawaii Collection','Annual Dues-Pre Due Hawaii Collection SPA','Annual Dues-Pre Due Advantage Program/HSI','Annual Dues-Pre Due Advantage Program/HSI SPA','Annual Dues-Past Due SMTN','Annual Dues-Past Due SFX','Annual Dues-Past Due SFX SPA','Annual Dues-Past Due Hawaii Collection','Annual Dues-Past Due Hawaii Collection SPA','Annual Dues-Past Due Advantage Program/HSI','Annual Dues-Past Due Advantage Program/HSI SPA'};
            
            //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
            List<Contact> conlist = [select id,Match_Group_Name__c,Account.name,name,leadassist__Use_Round_Robin__c,Assign_to_Sales_Cadence__c,Cadence_Flag__c,Account.Dues_Last_Paid_Until__c, Account.Affiliated_Id__c, Account.Preferred_Language__c, Account.Membership_SubType__c from Contact where AccountId IN : setAccountId];
        List<ActionCadenceTracker> actionCadenceTrackerRunning = new List<ActionCadenceTracker>();
        Set<Id> contactsToCheck = new Set<Id>();
        Map<Id,String> contactCurrentMatchGroupRunning = new Map<Id,String>();
        if(conlist != null && conlist.size() > 0){
            for (Contact contact : conlist) {
                if (contact.Account.Name != null &&
                    contact.Account.Name.equalsIgnoreCase(contact.Name)) {
                        parentContacts.add(contact);
                        contactsToCheck.add(contact.Id);
                    }
            }
            actionCadenceTrackerRunning = [select id, TargetId, SystemModstamp, ActionCadence.name, Target.Name, State, CompletionReason, LastCompletedStep.CompletedBy.Name from ActionCadenceTracker WHERE ActionCadence.name IN : matchGroupNames AND State = 'Running' AND TargetId IN : contactsToCheck];
            if(actionCadenceTrackerRunning != null && actionCadenceTrackerRunning.size()>0)
            {
                for(ActionCadenceTracker act : actionCadenceTrackerRunning)
                {
                    contactCurrentMatchGroupRunning.put(act.TargetId,act.ActionCadence.name);
                }
            }
            //Fetch Payment Records
            List<Payment__c> paymentlist = [select id,Opportunity__r.AccountId,Payment_Amount__c from Payment__c where Opportunity__c != null and Opportunity__r.AccountId IN : setAccountId and Opportunity__r.Account.Affiliated_Id__c IN : AffilateIdToCheckTransactingSet and Payment_Amount__c != null];
            if(paymentlist.size() > 0){
                for(Payment__c objpay : paymentlist){
                    mapAccountIdToPaymentId.put(objpay.Opportunity__r.AccountId, objpay.Payment_Amount__c);
                }
            }
            for(Contact objcon : parentContacts){
                //annualDuesBatchLogs
                String skipReason = null;
                
                flag = true;
                String currentCadenceRunning = '';
                if(contactCurrentMatchGroupRunning.get(objcon.Id) != null)
                {
                    currentCadenceRunning = contactCurrentMatchGroupRunning.get(objcon.Id);
                }                
                //Past Month
                if(objcon.Account.Dues_Last_Paid_Until__c.month() == (lastMonthValue)){
                    if(AffilateIdToCheckTransactingSet.contains(objcon.Account.Affiliated_Id__c)){
                        if(mapAccountIdToPaymentId.containsKey(objcon.AccountId) && mapAccountIdToPaymentId.get(objcon.AccountId) != null && mapAccountIdToPaymentId.get(objcon.AccountId) > 1){
                            flag = true;
                        }
                        else{
                            flag = false;
                            //annualDuesBatchLogs
                            skipReason = 'Payment amount <=1 for transacting affiliate';
                        }
                    }
                    if(flag){
                        //Annual Dues-Past Due SMTN
                        if(SMTNaffilateIDSet.contains(objcon.Account.Affiliated_Id__c)){
                            objcon.Match_Group_Name__c = 'Annual Dues-Past Due SMTN';
                            if(currentCadenceRunning != objcon.Match_Group_Name__c){
                                if(!MapCadenceNameVsContactIds.containsKey('Annual Dues-Past Due SMTN')){
                                    MapCadenceNameVsContactIds.put('Annual Dues-Past Due SMTN',new set<Id>{objcon.Id});
                                }
                                else{    
                                    MapCadenceNameVsContactIds.get('Annual Dues-Past Due SMTN').add(objcon.Id);
                                }
                            }
                            else
                            {
                                skipReason = 'Already in cadence: ' + currentCadenceRunning;
                            }
                        }
                        //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                        //Annual Dues-Past Due SFX
                        else if(SFXAffilateIdSet.contains(objcon.Account.Affiliated_Id__c)){
                            if(objcon.Account.Membership_SubType__c == null || (objcon.Account.Membership_SubType__c != null && !SFXMembershipSubType.contains(objcon.Account.Membership_SubType__c) && !objcon.Account.Membership_SubType__c.startsWithIgnoreCase('Annual Renew') && !objcon.Account.Membership_SubType__c.startsWithIgnoreCase('Renew-'))){//objcon.Account.Affiliated_Id__c == 1002277 && 
                                String matchGroupName1 = 'Annual Dues-Past Due SFX';
                                if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                                {
                                    if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                                    {
                                        matchGroupName1 = 'Annual Dues-Past Due SFX SPA'; 
                                    }
                                }
                                objcon.Match_Group_Name__c = matchGroupName1;
                                if(currentCadenceRunning != matchGroupName1){
                                    if(!MapCadenceNameVsContactIds.containsKey(matchGroupName1)){
                                        MapCadenceNameVsContactIds.put(matchGroupName1,new set<Id>{objcon.Id});
                                    }
                                    else{    
                                        MapCadenceNameVsContactIds.get(matchGroupName1).add(objcon.Id);
                                    }
                                }
                                else
                                {
                                    skipReason = 'Already in cadence: ' + currentCadenceRunning;
                                }
                            }
                        }
                        //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                        //Annual Dues-Past Due Hawaii Collection
                        else if(HCAffilateIdSet.contains(objcon.Account.Affiliated_Id__c)){
                            String matchGroupName2 = 'Annual Dues-Past Due Hawaii Collection';
                            if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                            {
                                if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                                {
                                    matchGroupName2 = 'Annual Dues-Past Due Hawaii Collection SPA'; 
                                }
                            }                        
                            objcon.Match_Group_Name__c = matchGroupName2;
                            if(currentCadenceRunning != matchGroupName2){
                                if(!MapCadenceNameVsContactIds.containsKey(matchGroupName2)){
                                    MapCadenceNameVsContactIds.put(matchGroupName2,new set<Id>{objcon.Id});
                                }
                                else{    
                                    MapCadenceNameVsContactIds.get(matchGroupName2).add(objcon.Id);
                                }
                            }
                            else
                            {
                                skipReason = 'Already in cadence: ' + currentCadenceRunning;
                            }
                        }
                        //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                        //Annual Dues-Past Due Advantage Program/HSI
                        else if(!APHSIAffilateIdSet.contains(objcon.Account.Affiliated_Id__c)){                        
                            String matchGroupName3 = 'Annual Dues-Past Due Advantage Program/HSI';
                            if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                            {
                                if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                                {
                                    matchGroupName3 = 'Annual Dues-Past Due Advantage Program/HSI SPA'; 
                                }
                            }      
                            objcon.Match_Group_Name__c = matchGroupName3;
                            if(currentCadenceRunning != matchGroupName3){
                                if(!MapCadenceNameVsContactIds.containsKey(matchGroupName3)){
                                    MapCadenceNameVsContactIds.put(matchGroupName3,new set<Id>{objcon.Id});
                                }
                                else{    
                                    MapCadenceNameVsContactIds.get(matchGroupName3).add(objcon.Id);
                                }
                            }
                            else
                            {
                                skipReason = 'Already in cadence: ' + currentCadenceRunning;
                            }
                        }
                    }
                }
                
                //Pre Month
                else if(objcon.Account.Dues_Last_Paid_Until__c.month() == (nextMonthValue)){
                    if(AffilateIdToCheckTransactingSet.contains(objcon.Account.Affiliated_Id__c)){
                        if(mapAccountIdToPaymentId.containsKey(objcon.AccountId) && mapAccountIdToPaymentId.get(objcon.AccountId) != null && mapAccountIdToPaymentId.get(objcon.AccountId) > 1){
                            flag = true;
                        }
                        else{
                            flag = false;
                            //annualDuesBatchLogs
                            skipReason = 'Payment amount <=1 for transacting affiliate';
                        }
                    }
                    if(flag){
                        
                        //Annual Dues-Pre Due SMTN
                        if(SMTNaffilateIDSet.contains(objcon.Account.Affiliated_Id__c)){
                            objcon.Match_Group_Name__c = 'Annual Dues-Pre Due SMTN';
                            if(currentCadenceRunning != objcon.Match_Group_Name__c){
                                if(!MapCadenceNameVsContactIds.containsKey('Annual Dues-Pre Due SMTN')){
                                    MapCadenceNameVsContactIds.put('Annual Dues-Pre Due SMTN',new set<Id>{objcon.Id});
                                }
                                else{    
                                    MapCadenceNameVsContactIds.get('Annual Dues-Pre Due SMTN').add(objcon.Id);
                                }
                            }
                            else
                            {
                                skipReason = 'Already in cadence: ' + currentCadenceRunning;
                            }
                        }
                        //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                        //Annual Dues-Pre Due SFX
                        else if(SFXAffilateIdSet.contains(objcon.Account.Affiliated_Id__c)){  
                            if(objcon.Account.Membership_SubType__c == null || (objcon.Account.Membership_SubType__c != null && !SFXMembershipSubType.contains(objcon.Account.Membership_SubType__c) && !objcon.Account.Membership_SubType__c.startsWithIgnoreCase('Annual Renew') && !objcon.Account.Membership_SubType__c.startsWithIgnoreCase('Renew-'))){//objcon.Account.Affiliated_Id__c == 1002277 && 
                                String matchGroupName4 = 'Annual Dues-Pre Due SFX';
                                if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                                {
                                    if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                                    {
                                        matchGroupName4 = 'Annual Dues-Pre Due SFX SPA'; 
                                    }
                                }      
                                objcon.Match_Group_Name__c = matchGroupName4;
                                if(currentCadenceRunning != matchGroupName4){
                                    if(!MapCadenceNameVsContactIds.containsKey(matchGroupName4)){
                                        MapCadenceNameVsContactIds.put(matchGroupName4,new set<Id>{objcon.Id});
                                    }
                                    else{    
                                        MapCadenceNameVsContactIds.get(matchGroupName4).add(objcon.Id);
                                    }
                                }
                                else
                                {
                                    skipReason = 'Already in cadence: ' + currentCadenceRunning;
                                }
                            }
                        }
                        //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                        //Annual Dues-Pre Due Hawaii Collection
                        else if(HCAffilateIdSet.contains(objcon.Account.Affiliated_Id__c)){                        
                            String matchGroupName5 = 'Annual Dues-Pre Due Hawaii Collection';
                            if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                            {
                                if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                                {
                                    matchGroupName5 = 'Annual Dues-Pre Due Hawaii Collection SPA'; 
                                }
                            }                        
                            objcon.Match_Group_Name__c = matchGroupName5;
                            if(currentCadenceRunning != matchGroupName5){
                                if(!MapCadenceNameVsContactIds.containsKey(matchGroupName5)){
                                    MapCadenceNameVsContactIds.put(matchGroupName5,new set<Id>{objcon.Id});
                                }
                                else{    
                                    MapCadenceNameVsContactIds.get(matchGroupName5).add(objcon.Id);
                                }
                            }
                            else
                            {
                                skipReason = 'Already in cadence: ' + currentCadenceRunning;
                            }
                        }
                        //2023-10-17 - HSIMU2-341 - Annual Dues SPA added - Preferred_Language__c
                        //Annual Dues-Pre Due Advantage Program/HSI
                        else if(!APHSIAffilateIdSet.contains(objcon.Account.Affiliated_Id__c)){
                            
                            String matchGroupName6 = 'Annual Dues-Pre Due Advantage Program/HSI';
                            if(objcon.Account.Preferred_Language__c != '' && objcon.Account.Preferred_Language__c != null)
                            {
                                if(objcon.Account.Preferred_Language__c.startsWithIgnoreCase('SPA'))
                                {
                                    matchGroupName6 = 'Annual Dues-Pre Due Advantage Program/HSI SPA'; 
                                }
                            }                        
                            
                            objcon.Match_Group_Name__c = matchGroupName6;
                            if(currentCadenceRunning != matchGroupName6){
                                if(!MapCadenceNameVsContactIds.containsKey(matchGroupName6)){
                                    MapCadenceNameVsContactIds.put(matchGroupName6,new set<Id>{objcon.Id});
                                }
                                else{    
                                    MapCadenceNameVsContactIds.get(matchGroupName6).add(objcon.Id);
                                }
                            }
                            else
                            {
                                skipReason = 'Already in cadence: ' + currentCadenceRunning;
                            }
                        }
                    }
                }
                //objcon.leadassist__Use_Round_Robin__c = 'TRUE';
                objcon.Assign_to_Sales_Cadence__c=true;
                objcon.Cadence_Flag__c=1;
                //HSIMU2-489 Annual Dues Pre Due did not get added to Sales Cadence
                if(matchGroupNames.contains(objcon.Match_Group_Name__c) && currentCadenceRunning != objcon.Match_Group_Name__c){
                    updateContactList.add(objcon);
                }
                else{
                    if(skipReason == null){
                        skipReason = 'Record not assigned to any match group : ' + matchGroupNames;
                    }
                }
                if (skipReason != null) {
                    accountIdToSkipReason.put(objcon.AccountId, skipReason);
                }
            }
            system.debug('>>updateContactList>'+updateContactList);
            
            //annualDuesBatchLogs
            for (Contact con : updateContactList) {
                updatedAccountIds.add(con.AccountId);
                accountIdToMatchGroup.put(con.AccountId, con.Match_Group_Name__c);
            }
            
            // Build logs for all accounts in scope
            for (Account acc : scope) {
                Annual_Dues_Log__c log = new Annual_Dues_Log__c();
                log.Account__c = acc.Id;
                Contact parentContact = accountIdToParentContact.get(acc.Id);
                String contactIdStr = '';                    
                if (parentContact != null) {
                    contactIdStr = parentContact.Id;  // Id is never null for queried contacts
                    log.Contact__c = parentContact.Id;  // Set lookup field
                } else {
                    log.Contact__c = null;  // Explicitly set to null
                }                
                String matchGroupName = accountIdToMatchGroup.get(acc.Id) != null ? accountIdToMatchGroup.get(acc.Id) : '';
                
                // Build unique key
                log.Key__c = '{"CurrentMonth":"' + currentMonthStr + '","AccountId":"' + acc.Id + '","ContactId":"' + contactIdStr + '","MatchGroupName":"' + matchGroupName + '"}';
                
                // Determine log reason
                if (CFDAffilateIdSet.contains(acc.Affiliated_Id__c) && 
                    acc.Enrollment_Date__c < Datetime.newInstanceGmt(2023, 8, 30, 0, 0, 0)) {
                        log.Log__c = 'Skipped: CFD affiliate enrolled before 2023-08-30';
                    } 
                else if (parentContact == null) {
                    log.Log__c = 'Skipped: No parent contact (Account.Name = Contact.Name)';
                } 
                else if (updatedAccountIds.contains(acc.Id)) {
                    log.Contact__c = parentContact.Id;
                    log.Contact_Updated__c = true;
                    log.Log__c = 'Contact Updated: Assigned to ' + matchGroupName;
                } 
                else if (accountIdToSkipReason.containsKey(acc.Id)) {
                    log.Contact__c = parentContact.Id;
                    log.Log__c = 'Skipped: ' + accountIdToSkipReason.get(acc.Id);
                } 
                else {
                    log.Contact__c = parentContact.Id;
                    log.Log__c = 'Skipped: Unknown reason';
                }
                logsToUpsert.add(log);
                
            }
            
            if(logsToUpsert.size()>0 && logsToUpsert != null)
            {
                try{
                    // Upsert logs using Key__c as external ID
                    Schema.SObjectField keyField = Annual_Dues_Log__c.Fields.Key__c;
                    Database.upsert(logsToUpsert, keyField, false);
                }
                Catch(Exception e){
                    System.debug('Annual_Dues_Log__c upsert failed ==> '+e.getMessage());                    
                }
            }
            
            //annualDuesBatchLogs
            updateContactList =  GenericMatchGroupAssignmentHandler.assignMatchGroup(updateContactList, 'Assigned');
            update updateContactList;
            if(!test.isRunningTest()){
                for(String key : MapCadenceNameVsContactIds.keyset()){
                    System.enqueueJob(new GenericAssignToSalesCadence(MapCadenceNameVsContactIds.get(key), key)); 
                }
            }
            
        }
    }
    public void finish(Database.BatchableContext BC){
    }    
    
}