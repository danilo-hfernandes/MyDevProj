trigger OpportunityTrigger_New on Opportunity (before insert, before update, before delete,after insert,after update) {
    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('OpportunityTrigger_New');
    system.debug('--OpportunityTrigger_New--'+cs);
    if(cs != null && cs.isEnable__c){
        if(trigger.isBefore){ 
            if(trigger.isBefore && trigger.isInsert){
                String clubVentureOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Club_Venture_Membership').getRecordTypeId() != null ? Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Club_Venture_Membership').getRecordTypeId() : '';
                String travelOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId() != null ? Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId() : '';
                
                Set<Id> setAccountId = new Set<Id>();
                Map<String, String> mapAccIdToEmailId = new Map<String, String>();
                Map<String, String> mapAccIdToPreferredLanguage = new Map<String, String>();
                
                for(Opportunity opp : trigger.new) {
                    if(opp.AccountId != null){
                        setAccountId.add(opp.AccountId);
                    }
                }
                List<Account> listAccount = [select id,Email__c,Preferred_Language__c from Account where Id IN : setAccountId];
//                List<Account> listAccount = [select id,Email__c from Account where Id IN : setAccountId];
                for(Account objacc : listAccount){
                    mapAccIdToEmailId.put(objacc.Id, objacc.Email__c);
                    mapAccIdToPreferredLanguage.put(objacc.Id, objacc.Preferred_Language__c);
                }
                for(Opportunity opp : trigger.new) {
                    opp.Account_Email__c = mapAccIdToEmailId.get(opp.AccountId);
                    //2024-04-25 - [HMR-50] Affiliate Marketing-Advantage Services Email / TGR-709 #2 - SF Add Products Engaged Good and Send email
                    if(opp.Opp_Original_Source__c == 'Marival Affiliate Marketing' || opp.Account_Affiliate_Id__c == 1002465)
                    {
                        if(opp.Account_Affiliate_Id__c == 1002465 && opp.RecordTypeId != travelOppRecTypeId)
                        {
                            //2025-09-23 TGR-822 Add Raise Away and Engage Goods to Sales Cadence
                            //opp.Match_Group_Name__c = 'TourGen-LuxGive';
                            opp.Match_Group_Name__c = 'TourGen-Charity';
                        }
                        //block vidanta generic e-mail templates
                        opp.Vidanta_Voucher_Email_Sent__c = true;
                        opp.Voucher_18_Months_Email_Sent__c = true;
                        opp.Vidanta_SFX_Voucher_Email_Sent__c = true;                        
                    }
                    else if(opp.Opp_Original_Source__c == 'Day Drive' && opp.RecordTypeId != clubVentureOppRecTypeId && clubVentureOppRecTypeId != ''){
                        opp.RecordTypeId = clubVentureOppRecTypeId;
                    }
                    if(opp.RC_Duplicate__c){
                        if(mapAccIdToPreferredLanguage.get(opp.AccountId) == 'SPA'){
                            opp.Match_Group_Name__c='Membership Upgrade RC-SPA';
                            opp.leadassist__Use_Round_Robin__c = 'TRUE';
                        }
                        else if(mapAccIdToPreferredLanguage.get(opp.AccountId) == 'ENG'){
                            opp.Match_Group_Name__c='Membership Upgrade RC-ENG';
                            opp.leadassist__Use_Round_Robin__c = 'TRUE';
                        }
                    }
                }
            }
            // Check Member Number and contact Id is null or not then throw error
            if(trigger.isInsert || trigger.isUpdate) {
                List<Opportunity> opportunitiesToOverrideOwner = new List<Opportunity>();
                Set<Id> setAccountId = new Set<Id>();
                List<Account> acclist = new List<Account>();
                Map<String, String> accIdvsMemberNumberorContactId = new Map<String, String>();
                try {
                    Id membershipAnnualDuesId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Annual_Dues').getRecordTypeId();
                    
                    system.debug('membershipAnnualDuesId----'+membershipAnnualDuesId);
                    Set<String> lockedRecordTypes = new Set<String>{'Hawaii Collection Membership', 'MTRC Membership Upgrade', 'SFX Membership'};
                        for(Opportunity opp : trigger.new) {
                            if(!trigger.isInsert){
                                if((!Label.System_Admin_Profile_Id.contains(userinfo.getProfileId()))){
                                    // Static variable inside the trigger scope
                                    System.debug('>>hasRun>>'+Recursive.hasRun);
                                    if (Recursive.hasRun) return;
                                    Recursive.hasRun = true;
                                    Opportunity oldOpp = Trigger.oldMap.get(opp.Id);
                                    System.debug('>>>>oldOpp.StageName>>>'+oldOpp.StageName);
                                    System.debug('>>>>opp.StageName>>>'+opp.StageName);
                                    // If the old stage was 'Unable to Reach', and the new one is also 'Unable to Reach'
                                    if ((lockedRecordTypes.contains(opp.Record_Type_Name__c) && oldOpp.StageName == 'Unable to Reach') || ((lockedRecordTypes.contains(opp.Record_Type_Name__c) || opp.Record_Type_Name__c == 'Club Global Explorer' || opp.Record_Type_Name__c == 'Club Venture Membership' || opp.Record_Type_Name__c == 'MTRC Retail') && oldOpp.StageName == 'Duplicate')) {
                                        // Serialize both records for comparison (excluding Id to avoid false diff)
                                        String newJSON = JSON.serialize(opp);
                                        String oldJSON = JSON.serialize(oldOpp); 
                                        
                                        if (newJSON != oldJSON) {
                                            opp.addError('This Opportunity is locked from changes because it is in stage '+oldOpp.StageName);
                                        }
                                    }
                                }
                            }
                            if(opp.AccountId != null && opp.RecordTypeId == membershipAnnualDuesId) {
                                
                                system.debug('opp.accountid---'+opp.AccountId);
                                system.debug('opp.RecordTypeId------'+opp.RecordTypeId);
                                setAccountId.add(opp.AccountId);
                            }
                            if(opp.AccountId != null){
                                if(opp.GCLID__c != opp.Account_GCLID__c)
                                {
                                    opp.GCLID__c = opp.Account_GCLID__c;
                                }
                                //2023-12-01 - WPO-124 - Facebook Click Id created and synced from Lead to Opp and Account
                                if(opp.FBCLID__c != opp.Account_FBCLID__c)
                                {
                                    opp.FBCLID__c = opp.Account_FBCLID__c;
                                }
                            }
                            if((opp.Name.contains('_test') || opp.Name.contains('_Test')) && opp.CreatedById != opp.OwnerId)
                            {
                                opportunitiesToOverrideOwner.add(opp);
                            }
                        }
                    if(setAccountId != null && setAccountId.size()>0){
                        acclist = [SELECT Id, Account.Member_Number__c, Account.Contact_Id__c,GCLID__c FROM Account WHERE Id IN :setAccountId];
                        if(acclist != null && acclist.size() > 0){
                            for(Account acc : acclist){                                
                                if(acc.Member_Number__c == null && acc.Contact_Id__c == null){
                                    accIdvsMemberNumberorContactId.put(acc.Id, 'Member Number and Contact Id');
                                }
                                else if(acc.Member_Number__c == null) {
                                    accIdvsMemberNumberorContactId.put(acc.Id, 'Member Number');
                                    
                                } 
                                else if (acc.Contact_Id__c == null){
                                    accIdvsMemberNumberorContactId.put(acc.Id, 'Contact Id');
                                } 
                            }
                        }
                        for(Opportunity opp : trigger.new){
                            if(opp.AccountId != null && accIdvsMemberNumberorContactId != null && accIdvsMemberNumberorContactId.containsKey(opp.AccountId)) {
                                opp.addError(accIdvsMemberNumberorContactId.get(opp.AccountId)+' cannot be empty in the account.');
                            }
                        } 
                    }
                    
                    //logic to not assign any test records to agents in Prod
                    MU_Jobs_test_Record_Filter__c testRecordsFilterSettings = MU_Jobs_test_Record_Filter__c.getValues('Filters Enabled');
                    if(testRecordsFilterSettings != null)
                    {
                        if(testRecordsFilterSettings.Any_Test_Record__c && opportunitiesToOverrideOwner != null && opportunitiesToOverrideOwner.size()>0)
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
                                    for(Opportunity oppty : opportunitiesToOverrideOwner)
                                    {
                                        if(m.get(oppty.CreatedById) != null)
                                        {
                                            oppty.OwnerId = oppty.CreatedById;
                                        }
                                        else if(m.get(oppty.OwnerId) == null)
                                        {
                                            oppty.OwnerId = devAccountUser[0].Id;
                                        }
                                    }                    
                                }
                            }
                        }
                    }
                    
                } 
                catch(DmlException e) {
                    System.debug('The following exception has occurred: ' + e.getMessage());
                }
            }
            
            if(trigger.isInsert && !trigger.isDelete){
                Set<String> actId = new Set<String>();
                set<String> setMemberNumber = new set<String>();
                
                Id membershipUpgradeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Vacation_VIP_Membership_Upgrade').getRecordTypeId();
                Id voucherSalesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
                Id viReferralRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VI_Referral_Date_Request').getRecordTypeId();
                Id travelRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
                for(opportunity opp:trigger.new) {
                    //added 2022-10-11
                    if(opp.Opportunity_Record_Type_Id_From_Lead__c != null && opp.Opportunity_Record_Type_Id_From_Lead__c != '' )
                    {
                        if(opp.LeadSource == 'Vacation VIP - Web'){
                            opp.RecordTypeId = membershipUpgradeRecordTypeId;
                            
                        }
                        else{
                            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(opp.Opportunity_Record_Type_Id_From_Lead__c).getRecordTypeId();
                        }
                    }
                    
                    system.debug('>>>travelRecordTypeId>>>>'+travelRecordTypeId);
                    system.debug('>>>opp.RecordTypeId>>>>'+opp.RecordTypeId);
                    if((opp.RecordTypeId == voucherSalesRecordTypeId || opp.RecordTypeId == viReferralRecordTypeId) && opp.LeadSource != 'CFD MX Checkout' && opp.LeadSource != 'CFD Google Mexico'){
                        actId.add(opp.AccountId);
                    }
                    else if(opp.RecordTypeId == travelRecordTypeId && opp.AccountId == null && opp.Member_Number__c != null){
                        setMemberNumber.add(opp.Member_Number__c); 
                        setMemberNumber.add(opp.Member_Number__c.toUpperCase()); 
                    }
                }
                system.debug('setMemberNumber>>>>'+setMemberNumber);
                if(actId != null && actId.size() > 0){
                    List<Opportunity> lstOpportunity = [SELECT id, First_Payment_Date__c,Confirmed_Date__c, AccountId, Affiliated_Id__c FROM Opportunity WHERE AccountId IN: actId and ProfitAgility_Agency_MX_Voucher_Code__c = null and (Recordtypeid =: voucherSalesRecordTypeId OR Recordtypeid =: viReferralRecordTypeId/* OR Recordtypeid =: profitAgilityRecordTypeId*/)];
                    system.debug('--lstOpportunity--'+lstOpportunity);
                    date last30Days = system.today().addDays(-30);
                    for(opportunity opp : trigger.new){
                        for(Opportunity queriedOpp : lstOpportunity) {
                            if((opp.ProfitAgility_Agency_MX_Voucher_Code__c == '' || opp.ProfitAgility_Agency_MX_Voucher_Code__c == null) && opp.AccountId == queriedOpp.AccountId && queriedOpp.First_Payment_Date__c > last30Days && queriedOpp.Affiliated_Id__c != '1002464'){
                                opp.adderror('Only one Voucher is allowed per Account per month'); //Only one Voucher is allowed per Account every 6 months
                            }
                        }
                    }
                }
                else if(setMemberNumber != null && setMemberNumber.size() > 0){
                    Map<String, String> mapMemberNumberToAccountId = new map<String,String>();
                    //2024-01-03 - HSIMU2-520 Ghost Travel Opportunities
                    for(Contact objcon : [select id,Member_Number__c,AccountId from Contact where AccountId != null AND Member_Number__c IN: setMemberNumber]){
                        mapMemberNumberToAccountId.put(objcon.Member_Number__c, objcon.AccountId);
                        mapMemberNumberToAccountId.put(objcon.Member_Number__c.toUpperCase(), objcon.AccountId);
                        Boolean result1 = setMemberNumber.remove(objcon.Member_Number__c);
                        Boolean result2 = setMemberNumber.remove(objcon.Member_Number__c.toUpperCase());
                    }
                    //2024-01-03 - HSIMU2-520 Ghost Travel Opportunities
                    if(setMemberNumber != null && setMemberNumber.size() > 0 && !setMemberNumber.isEmpty()){
                        for(Account objacc : [select id,Member_Number__c from Account where Member_Number__c IN: setMemberNumber]){
                            mapMemberNumberToAccountId.put(objacc.Member_Number__c, objacc.Id);
                            mapMemberNumberToAccountId.put(objacc.Member_Number__c.toUpperCase(), objacc.Id);
                        }
                    }
                    for(opportunity opp : trigger.new){
                        //2024-01-03 - HSIMU2-520 Ghost Travel Opportunities
                        if(mapMemberNumberToAccountId.get(opp.Member_Number__c.toUpperCase()) != null){
                            opp.AccountId = mapMemberNumberToAccountId.get(opp.Member_Number__c.toUpperCase());
                        }
                        opp.Match_Group_Name__c = 'Travel Sales-Web Form Inquiry';
                        opp.leadassist__Use_Round_Robin__c = 'TRUE';
                    }
                }
            }
            if(trigger.isUpdate && !trigger.isDelete){
                Date targetDate = Date.newInstance(2022, 8, 8);
                Id rcRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Reserve_Collection_Membership').getRecordTypeId();
                Id hcmRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hawaii_Collection_Membership').getRecordTypeId();
                Id sfxRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SFX_Membership').getRecordTypeId();
                Id muRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
                Id memAddonRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Add_On').getRecordTypeId();
                Id oppMTRCRetailRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MTRC_Retail').getRecordTypeId();
                Id voucherSalesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
                Id viReferralRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VI_Referral_Date_Request').getRecordTypeId();
                Id miniVacationRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Mini_Vacation').getRecordTypeId();
                //Ticket CGE-90 - Add 25% Club Global and Club Venture Approved by Diana on RC
                Id clubVentureOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Club_Venture_Membership').getRecordTypeId();
                Id ClubGlobalExplorerOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Club_Global_Explorer').getRecordTypeId();
                //SAS-2 Ad Sales
                Id adSalesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Social_Ad_Sales').getRecordTypeId();
               for(Opportunity opp : trigger.new) {
                    if(opp.Record_Type_Name__c == 'Flex Stays Product Voucher' && opp.First_Payment_Date__c != null && opp.Flex_Stays_Activation_Date_Template__c != null && opp.Flex_Stays_Activation_Date_Template__c < System.today()){
                        opp.addError('You can\'t book as the time has exceeded the Date of Purchase of Flex-Stay Product');
                    }
                    String MUManagerProfileId = '00e3t000000wOnBAAU';//[select id from Profile where Name = 'Membership Upgrade Manager' limit 1].Id;
                    if((opp.RecordTypeId == rcRecordTypeId || opp.RecordTypeId == hcmRecordTypeId || opp.RecordTypeId == sfxRecordTypeId || opp.RecordTypeId == muRecordTypeId || opp.RecordTypeId == clubVentureOppRecTypeId || opp.RecordTypeId == ClubGlobalExplorerOppRecTypeId) && opp.IsClosed == true && Trigger.oldmap.get(opp.Id).Credits__c != null && Trigger.oldmap.get(opp.Id).Credits__c != '' && opp.Credits__c != Trigger.oldmap.get(opp.Id).Credits__c ){
                        opp.addError('You can\'t change the credits once the Opportunty is closed');
                    }
                    if(opp.Net_Amount__c != null){  
                        Decimal credits = opp.Credits__c != null ? Decimal.valueOf(opp.Credits__c.replace('%', '')) : 0;
                        if(opp.Override_Credits_Received__c != true && opp.Override_File_Fee__c != true && (opp.First_Payment_Date__c >= targetDate || opp.First_Payment_Date__c == null)){
                            //changed 2022-08-02 - adding a 25% file fee of the gross on ALL membership upgrades products
                            //Boolean otherMUType = true;
                            if(opp.RecordTypeId == hcmRecordTypeId || opp.RecordTypeId == sfxRecordTypeId || opp.RecordTypeId == rcRecordTypeId ||
                               opp.RecordTypeId == muRecordTypeId || opp.RecordTypeId == oppMTRCRetailRecordTypeId || opp.RecordTypeId == memAddonRecordTypeId ||
                               opp.RecordTypeId == clubVentureOppRecTypeId || opp.RecordTypeId == ClubGlobalExplorerOppRecTypeId || opp.RecordTypeId == adSalesRecordTypeId ){
                                  // opp.Credit_Received__c = (opp.Total_Amount__c * (credits/100)).round();          
                                   
                                   //RC-179 use net amount for RC
                                       if (opp.RecordTypeId == rcRecordTypeId) {
                                            // For RC Record Type — use Net Amount
                                            opp.Credit_Received__c = (opp.Net_Amount__c * (credits/100)).round();
                                        } else {
                                            // All other record types — use Total Amount
                                            opp.Credit_Received__c = (opp.Total_Amount__c * (credits/100)).round();
                                        }
                                   
                                   //TGR-770 - File fee change for MTRC Membership Upgrade - 2025-08-15
                                   //Decimal netAmount25Percent = (opp.Net_Amount__c * .25).round();
                                   Decimal feePercent = 0.25; // default 25%
                                   
                    			   //MSR10 - rollback 15% to 25% for Membership add-on
                    			   //if(opp.RecordTypeId == muRecordTypeId || opp.RecordTypeId == memAddonRecordTypeId || opp.RecordTypeId == oppMTRCRetailRecordTypeId){
                    			   
                                   if(opp.RecordTypeId == muRecordTypeId || opp.RecordTypeId == oppMTRCRetailRecordTypeId){
                        				feePercent = 0.15; // 15% for Membership Upgrade
                    			   }
                                   
                                   //SAS-2 Ad Sales 
                                   if(opp.RecordTypeId == adSalesRecordTypeId ){
                        				feePercent = 0.2; // 20%
                    			   }
                                   
                                   Decimal netAmount25Percent = (opp.Net_Amount__c * feePercent).round();
                                   
                                   //No changes below
                                   if((opp.File_Fees__c != null && opp.File_Fees__c > netAmount25Percent && opp.RecordTypeId == oppMTRCRetailRecordTypeId && UserInfo.getProfileId() == MUManagerProfileId)){
                                       opp.addError('You can\'t edit the file fee amount to no more than 25% of the total amount' );
                                   }
                                   else if(!(opp.File_Fees__c != null && opp.RecordTypeId == oppMTRCRetailRecordTypeId && UserInfo.getProfileId() == MUManagerProfileId)){
                                       opp.File_Fees__c = netAmount25Percent; //(opp.Net_Amount__c * .25).round();
                                   }
                               }
                            else{
                                opp.Credit_Received__c = (opp.Net_Amount__c * .10).round();
                                opp.File_Fees__c = (opp.Net_Amount__c * .10).round();
                            }
                        }
                        else if(opp.Override_Credits_Received__c != true && opp.Override_File_Fee__c != true && (opp.First_Payment_Date__c < targetDate && opp.First_Payment_Date__c != null)){
                            if(opp.RecordTypeId == hcmRecordTypeId || opp.RecordTypeId == sfxRecordTypeId || opp.RecordTypeId == muRecordTypeId || opp.RecordTypeId == memAddonRecordTypeId){
                                opp.Credit_Received__c = (opp.Total_Amount__c * (credits/100)).round();
                                opp.File_Fees__c =0;
                            }
                            else{
                                opp.Credit_Received__c = (opp.Net_Amount__c * .10).round();
                                opp.File_Fees__c = (opp.Net_Amount__c * .10).round();
                            }
                        }
                        //Update Booking agent on opp for Flex and Cruise for SFX Membership Hitarth Raval 28-9-22
                        if(opp.Check_in_Flex__c != Null && opp.Check_in_Flex__c != Trigger.oldMap.get(opp.Id).Check_in_Flex__c){
                            opp.Booking_Agent_Flex__c = userinfo.getUserId();
                        } 
                        if(opp.Cruise_Certificate_Status__c != Null && opp.Cruise_Certificate_Status__c != Trigger.oldMap.get(opp.Id).Cruise_Certificate_Status__c){
                            opp.Booking_Agent_Cruise__c = userinfo.getUserId();
                        }
                        
                    }
                    if(!opp.Vacation_VIP_EZCheckout_Sent__c && opp.isClosed && opp.isWon && opp.Payments_Count__c != Trigger.oldMap.get(opp.Id).Payments_Count__c && opp.Payments_Count__c == 1 && (opp.LeadSource == 'VVIP Westgate Orlando' || opp.LeadSource == 'VVIP Westgate Las Vegas'))
                    {
                        System.debug('Vacation_VIP_EZCheckout_Sent__c set to true ');
                        opp.Vacation_VIP_EZCheckout_Sent__c = true;                        
                    }
                }
                if(checkRecursive.opportunitycreateReservationTrackingRecord){
                    List<Id> opportunityIdSet = New List<id>();
                    List<OpportunityLineItem> opplinerecord = new List<OpportunityLineItem>();
                    
                    Set<Id> OppIdSetForPayment = new Set<Id>();
                    for(Opportunity opp: trigger.new){
                        System.debug('MSR-302 oppopp.RecordTypeId:'+opp.RecordTypeId);
		                System.debug('MSR-302 voucherSalesRecordTypeId:'+voucherSalesRecordTypeId);
		                System.debug('MSR-302 viReferralRecordTypeId:'+viReferralRecordTypeId);
		                System.debug('MSR-302 opp.Reservation_Status__c:'+opp.Reservation_Status__c);
		                if(opp.RecordTypeId == voucherSalesRecordTypeId || opp.RecordTypeId == viReferralRecordTypeId){
                            if(opp.Reservation_Status__c != trigger.oldMap.get(opp.Id).Reservation_Status__c && opp.Reservation_Status__c == 'Confirmed' && opp.Original_Confirmation__c != true){
                                opp.Original_Confirmation__c = true;
                            }
                        }
		                if(opp.RecordTypeId == voucherSalesRecordTypeId ){
                            if(opp.Reservation_Status__c != trigger.oldMap.get(opp.Id).Reservation_Status__c && opp.Reservation_Status__c == 'Confirmed'){
                                //MSR-302
		                        System.debug('MSR-302 opp.Booking_Agent__c = userinfo.getUserId()');
		                        if(opp.Supplier__c == 'Marival' || opp.Supplier__c == 'The Fives' || opp.Supplier__c == 'Lifestyle' ){
                                    opp.Booking_Agent__c = userinfo.getUserId();
                                }                        
                            }
                        }
                        if(opp.StageName == 'Closed Won' && (opp.RecordTypeId == muRecordTypeId)){
                            opportunityIdSet.add(opp.Id);
                            system.debug('opportunityIdSet---'+opportunityIdSet);
                        }
                        // B-06412 : Block ability to change voucher opportunity status to closed without payment
                        system.debug('opp.StageName--'+opp.StageName+'>>>>>'+trigger.oldMap.get(opp.Id).StageName);
                        system.debug('opp.RecordTypeId'+opp.RecordTypeId);
                        system.debug('operation---'+trigger.operationtype );
                        if(opp.StageName != trigger.oldMap.get(opp.Id).StageName && opp.StageName == 'Closed Won' && (opp.RecordTypeId == voucherSalesRecordTypeId || opp.RecordTypeId == viReferralRecordTypeId)){
                            
                            OppIdSetForPayment.add(opp.Id);
                        }
                        
                        
                    }
                    OpportunityTriggerHandler.createReservationTrackingRecord(trigger.oldMap, trigger.newMap, trigger.isInsert);
                    
                    
                    // B-06412 : Block ability to change voucher opportunity status to closed without payment
                    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('OppcloseWonErrorFromTrigger');
                    
                    if(cs != null && cs.isEnable__c){
                        system.debug('insid--');                
                        if(OppIdSetForPayment != null && OppIdSetForPayment.size() > 0){
                            List<Opportunity> oppListWithPayment = [select id,(select id from payments__r) from Opportunity where Id IN : OppIdSetForPayment];
                            Map<Id,Integer> oppIdwithNumberOfPayment = new Map<Id,Integer>();
                            if(oppListWithPayment != null && oppListWithPayment.size() > 0){
                                for(Opportunity oppObj : oppListWithPayment){
                                    Integer paymentRecordsize = oppObj.Payments__r.size();
                                    oppIdwithNumberOfPayment.put(oppObj.Id,paymentRecordsize);
                                }
                            }
                            for(Opportunity opp : trigger.new){
                                if(opp.StageName != trigger.oldMap.get(opp.Id).StageName && opp.StageName == 'Closed Won' && (opp.RecordTypeId == voucherSalesRecordTypeId || opp.RecordTypeId == viReferralRecordTypeId)){
                                    if(oppIdwithNumberOfPayment.containskey(opp.Id)){
                                        if(oppIdwithNumberOfPayment.get(opp.Id) == 0){
                                            system.debug('--Label.System_Admin_Profile_Id---'+Label.System_Admin_Profile_Id);
                                            if(!Label.System_Admin_Profile_Id.contains(userinfo.getProfileId())){
                                                opp.addError('Without payment you cannot closed the opportunity');        
                                            }
                                        }
                                    }  
                                }
                            }
                        }
                    }
                    // END B-06412 : Block ability to change voucher opportunity status to closed without payment
                    
                    if(opportunityIdSet.size() > 0 && opportunityIdSet != Null){
                        
                        opplinerecord = [Select Id,OpportunityId,Product2.Name from OpportunityLineItem  where Product2.Name = 'Equity Value' AND OpportunityId IN :opportunityIdSet]; 
                        system.debug('--opplinerecord--'+ opplinerecord);
                        
                    }
                    if(opplinerecord.size() > 0 && opplinerecord != Null){
                        Task newTask = New Task();
                        newTask.ActivityDate = Date.today() + 1;
                        newTask.Subject = 'Membership upgrade opportunity closed won';
                        newTask.WhatId = opportunityIdSet[0];
                        newTask.WhoId = Label.TRM_Admin_User_Id;
                        newTask.Status = 'Completed';
                        newTask.Priority = 'Normal';
                    }
                    checkRecursive.opportunitycreateReservationTrackingRecord = false;
                }
            }
            
            if(trigger.isBefore && trigger.isDelete) {
                User userDetails =[SELECT Id, Name, Email, Profile.Name, UserRole.Name FROM User where Id=:userinfo.getUserId()];               
                Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();//[Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Membership_Upgrade' ].id ;
                Id VoucherRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
                List<Deleted_Record__c> deletedRecList = new List<Deleted_Record__c>();
                
                for(Opportunity opp : trigger.old) {
                    if(userDetails.Profile.Name != 'System Administrator' && opp.RecordTypeId == oppRecordTypeId) {
                        if(!Test.isRunningTest()) {
                            opp.addError('Sorry, you can not delete Membership Upgrade Opportunities');
                        }
                    }
                    // && opp.RecordTypeId == VoucherRecordTypeId - removed this condition from below
                    if(userDetails.UserRole.Name == 'Tour Generation Manager'){
                        system.debug('opp.RecordTypeId==' + opp.RecordTypeId + ' VoucherRecordTypeId =' + VoucherRecordTypeId + ' opp.First_Payment_Made__c ' + opp.First_Payment_Made__c);
                        if(opp.StageName == 'Closed Won' || opp.StageName == 'Closed Won-Deposit' || opp.StageName == 'Closed Booked' || opp.First_Payment_Made__c == true) {
                            if(!Test.isRunningTest()) {
                                opp.addError('Sorry, you do not have permission to delete this Opportunity');
                            }
                        }
                    }else{
                        Deleted_Record__c deletedRec = new Deleted_Record__c();
                        deletedRec.Id__c = opp.Id;
                        deletedRec.Object_Name__c = 'Opportunity';
                        deletedRec.Created_Date__c = date.today();
                        deletedRecList.add(deletedRec);
                    }
                }
                if(!deletedRecList.isEmpty()){
                    insert deletedRecList;
                }
            }
        }
        // After trigger 
        if(trigger.isAfter){
            // Call future method after insert or update.
            //Process builder :  Create Inventory Case for Pending Status
            if(trigger.isInsert){
                Set<Id> engagedGoodAccounts = new Set<Id>();
                List<ContentNote> noteList = new List<ContentNote>();
                List<ContentDocumentLink> lnk = new List<ContentDocumentLink>();
//                OpportunityTrigger_NewHandler.hawaaiEmailOverflow(trigger.new);
                OpportunityTriggerHandler.createReservationTrackingRecord(null, trigger.newMap, trigger.isInsert);
                //OpportunityTriggerHandler.createTaskForNameAssignment(null, trigger.newMap, trigger.isInsert);
                Map<String, Id> pricebookMap = new Map<String, Id>();
                Set<Id> accountsToRemoveProfitAgility_Agency_MX_Voucher_Code = new Set<Id>();
                List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                List<PriceBookEntry> priceBookList = [SELECT Id, Name, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE PriceBook2.isStandard=true];
                system.debug('>>priceBookList>>'+priceBookList);
                for(PriceBookEntry pbe : priceBookList) {
                    pricebookMap.put(pbe.Product2.Name, pbe.id);
                }
                ID salesforceUserId=[Select id from user where name='Salesforce'].id;
                Id travelOppRecType = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Travel' ].id ;
                Id oppVoucherRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
                List<OpportunityLineItem> listLineItems = new List<OpportunityLineItem>();
                set<Id> invIds = new set<Id>();
                set<Id> oppIds = new set<Id>();
                for (Opportunity oppty: Trigger.new) {
                    if(oppty.Inventory_Availability_Id__c != null && oppty.Property_Address__c == null){
                        oppIds.add(oppty.Id);
                        invIds.add(oppty.Inventory_Availability_Id__c);
                    }
                    if(oppty.RecordTypeId == oppVoucherRecTypeId && oppty.Account_Affiliate_Id__c == 1002421 && oppty.Opp_Original_Source__c != 'Diamonds International Mayan' && oppty.VI_Referral_Comments__c != 'sunset-pass2!' && oppty.VI_Referral_Comments__c != 'hough-pass' && oppty.VI_Referral_Comments__c != 'gunn-pass!' && oppty.VI_Referral_Comments__c != 'sunset-pass3!' && oppty.VI_Referral_Comments__c != 'gunnc-tte!' && oppty.VI_Referral_Comments__c != 'tsnation-pass!' && oppty.Opp_Original_Source__c != 'Timeshare Nation File' && oppty.LeadSource != 'My Park Tickets Affiliate Marketing' && oppty.LeadSource != 'Go For Less' &&  oppty.LeadSource != 'GoForLess Voucher Sales' &&  oppty.LeadSource != 'Sharelife Voucher' ){ //1966    && oppty.Opp_Original_Source__c != 'Sunset'
                        
                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.Quantity = 1;
                        oli.TotalPrice = 0;
                        oli.OpportunityId = oppty.Id;
                        oli.PriceBookEntryID = pricebookMap.get('Affiliate Marketing MX Voucher');
                        listLineItems.add(oli);
                    }
                    //2023-09-12 - PA-31 - ProfitAgility Agency MX Vouchers - SF
                    if(oppty.ProfitAgility_Agency_MX_Voucher_Code__c != null && oppty.ProfitAgility_Agency_MX_Voucher_Code__c != '')
                    {
                        accountsToRemoveProfitAgility_Agency_MX_Voucher_Code.add(oppty.AccountId);
                    }                    
                    //Id OpportunityIDforTimeShare = oppty.id;
                    //OpportunityTriggerHandler.UpdateTimeSharetoOpp(OpportunityIDforTimeShare);
                    //added 2022-10-11
                    if(oppty.Opportunity_Record_Type_Id_From_Lead__c != null && oppty.Opportunity_Record_Type_Id_From_Lead__c != '' && oppty.LeadSource == 'VI Referral')
                    {
                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.Quantity = 1;
                        oli.OpportunityId = oppty.Id;
                        oli.PriceBookEntryID = pricebookMap.get('Vida Voucher-Flex Date Request');
                        insert oli;
                    }
                    //added 2022-11-01
                    if(oppty.Opportunity_Record_Type_Id_From_Lead__c != null && oppty.Opportunity_Record_Type_Id_From_Lead__c != '' && oppty.LeadSource == 'Vacation VIP - Web')
                    {
                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.Quantity = 1;
                        oli.OpportunityId = oppty.Id;
                        oli.PriceBookEntryID = pricebookMap.get('Vacation VIP Membership Upgrade');
                        insert oli;
                    }
                    //added 2023-03-20
                    if(oppty.Opportunity_Record_Type_Id_From_Lead__c != null && oppty.Opportunity_Record_Type_Id_From_Lead__c != '' && (oppty.LeadSource == 'VVIP Westgate Orlando' || oppty.LeadSource == 'VVIP Westgate Las Vegas'))
                    {
                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.Quantity = 1;
                        oli.OpportunityId = oppty.Id;
                        if(oppty.Qualified_Offer__c == 'Westgate Orlando')
                        {
                            oli.PriceBookEntryID = pricebookMap.get('Westgate Orlando 4 Day/3 Night');
                        }
                        else if(oppty.Qualified_Offer__c == 'Westgate Las Vegas')
                        {
                            oli.PriceBookEntryID = pricebookMap.get('Westgate Las Vegas 4 Day/3 Night');
                        }
                        else if(oppty.Qualified_Offer__c == 'Exploria Orlando')
                        {
                            oli.PriceBookEntryID = pricebookMap.get('Exploria Orlando 4 Day/3 Night');
                        }
                        else if(oppty.Qualified_Offer__c == 'Exploria Las Vegas')
                        {
                            oli.PriceBookEntryID = pricebookMap.get('Exploria Las Vegas 4 Day/3 Night');
                        }                        
                        insert oli;
                    }
                    //2025-09-23 TGR-822 Add Raise Away and Engage Goods to Sales Cadence
                    if(oppty.RecordTypeId != travelOppRecType && (oppty.Match_Group_Name__c == 'TourGen-LuxGive' || oppty.Match_Group_Name__c == 'TourGen-Charity')){                        
                        engagedGoodAccounts.add(oppty.accountId);
                    }
                    if(oppty.RecordTypeId == travelOppRecType && oppty.Match_Group_Name__c == 'Travel Sales-Web Form Inquiry'){
                        String notesDescription = 'Name of the Guest:'+oppty.Traveler_Name__c+', Email:'+oppty.Traveler_Email__c+', Phone Number:'+oppty.Traveler_Phone__c+', Check-in Date:'+oppty.Check_in__c+', Check-out Date:'+oppty.Check_Out__c+', Region/Area:'+oppty.Traveler_Address__c+', Adults:'+oppty.Adults__c;
                        notesDescription += oppty.Are_any_travelers_Senior_Citizen__c != null ? ', Are any travelers Senior Citizen:'+ oppty.Are_any_travelers_Senior_Citizen__c: '';
                        notesDescription += oppty.Children_0_17__c != null ? ', Children:'+ oppty.Children_0_17__c : '';
                        notesDescription += oppty.Room_Type__c != null ? ', Type of Hotel Room Desired:'+ oppty.Room_Type__c : '';
                        notesDescription += oppty.Child_Age__c != null ? ', Child Age:'+ oppty.Child_Age__c : '';
                        ContentNote cnt = new ContentNote();
                        cnt.Content = Blob.valueof(notesDescription);
                        cnt.Title = 'Travel Sales-Web Form Inquiry';
                        noteList.add(cnt);
                    }
                    if(oppty.recordTypeId == System.Label.Opp_Membership_Enrollment_Fee_Id) {
                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.OpportunityId=oppty.Id; 
                        if(oppty.Enrollment_Fee__c != null) {
                            oli.Retail_Price__c = oppty.Enrollment_Fee__c;  
                        }
                        oli.PricebookEntryId=pricebookMap.get('Membership Enrollment Fee') ;
                        oli.ServiceDate = system.today();
                        oli.UnitPrice = oppty.Enrollment_Fee__c;
                        oli.Quantity = 1;
                        oliList.add(oli);
                    }
                    //2023-08-08 - oppty.BE_Payment_Id__c filter added, the skyvia job will create the product
                    else if(oppty.recordTypeId == System.Label.Opp_Membership_Annual_Dues && (oppty.Membership_AnnualDues_GiftProduct__c == null || oppty.Membership_AnnualDues_GiftProduct__c == '') && oppty.Annual_Dues_Match_Group__c == null && (oppty.BE_Payment_Id__c == '' || oppty.BE_Payment_Id__c == null)){
                        OpportunityLineItem oli = new OpportunityLineItem();
                        oli.OpportunityId=oppty.Id; 
                        Id currentUserId=UserInfo.getUserId();
                        
                        if(oppty.Annual_Dues__c != null) {
                            oli.Retail_Price__c = oppty.Annual_Dues__c;
                        }
                        //2023-06-21 - ADCR-13 QA - Meridian 5. Salesforce - Membership_AnnualDues_GiftProduct__c check added
                        if(currentUserId==salesforceUserId){
                            oli.PricebookEntryId=pricebookMap.get('Membership Annual Dues') ;
                            System.debug('THIS IS THE PRICEBOOK ENTRY ID ' + oli.PricebookEntryId);
                            oli.ServiceDate = system.today();
                            oli.UnitPrice = oppty.Annual_Dues__c;
                            oli.Quantity = 1;
                            oliList.add(oli);
                        }
                    }
                }
                if (engagedGoodAccounts != null && !engagedGoodAccounts.isEmpty()) {
                    Set<Id> primaryEGContactIds = new Set<Id>();
                    
                    // Query Contacts related to the accounts
                    List<Contact> engagedGoodContacts = [
                        SELECT Id, Name, AccountId, Account.Name, Account.Parent_Child_Contact_Id__c
                        FROM Contact 
                        WHERE AccountId IN :engagedGoodAccounts
                        ORDER BY CreatedDate DESC
                    ];
                    
                    // Group contacts by AccountId for easier lookup
                    Map<Id, List<Contact>> contactsByAccount = new Map<Id, List<Contact>>();
                    for (Contact con : engagedGoodContacts) {
                        if (!contactsByAccount.containsKey(con.AccountId)) {
                            contactsByAccount.put(con.AccountId, new List<Contact>());
                        }
                        contactsByAccount.get(con.AccountId).add(con);
                    }
                    
                    // Iterate through each Account
                    for (Id accId : engagedGoodAccounts) {
                        List<Contact> contacts = contactsByAccount.get(accId);
                        
                        if (contacts != null && !contacts.isEmpty()) {
                            // Check if Account has Parent_Child_Contact_Id__c populated
                            Id parentContactId = contacts[0].Account.Parent_Child_Contact_Id__c;
                            
                            // 1st priority: Match Parent_Child_Contact_Id__c
                            if (parentContactId != null) {
                                for (Contact con : contacts) {
                                    if (con.Id == parentContactId) {
                                        primaryEGContactIds.add(con.Id);
                                        break;
                                    }
                                }
                            }
                            // 2nd priority: Match Contact name to Account name (if parent field is null)
                            else {
                                for (Contact con : contacts) {
                                    if (con.Name == con.Account.Name) {
                                        primaryEGContactIds.add(con.Id);
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    
                    System.debug('Primary EG Contact Ids: ' + primaryEGContactIds);
                    
                    if(primaryEGContactIds.size() > 0 && primaryEGContactIds != null){
                        contactTriggerHandler.assignRaiseAwayContactstoTourGen(primaryEGContactIds);
                    }
                }
                if(accountsToRemoveProfitAgility_Agency_MX_Voucher_Code.size() > 0 && accountsToRemoveProfitAgility_Agency_MX_Voucher_Code != null)
                {
                    OpportunityTrigger_NewHandler.cleanUsedProfitAgilityAgencyMXVoucherCode(accountsToRemoveProfitAgility_Agency_MX_Voucher_Code);
                }
                if(invIds != null && invIds.size() > 0){
                    OpportunityTriggerHandler.updateOppWithPropertyDetails(oppIds,invIds);
                }
                if(listLineItems != null && listLineItems.size() > 0){
                    insert listLineItems;
                }
                try{
                    if(noteList != null && noteList.size()>0){
                        insert noteList;
                    }
                    insert oliList;
                }catch(exception e){
                    system.debug('--e---'+e);
                }
                
                Id upgradeQueue = System.Label.MembershipUpgradeQueue;
                
                for(Opportunity o : trigger.new) {
                    if(o.RecordTypeId == travelOppRecType && o.Match_Group_Name__c == 'Travel Sales-Web Form Inquiry'){
                        ContentDocumentLink clnk = new ContentDocumentLink();
                        clnk.LinkedEntityId = o.Id;
                        clnk.ContentDocumentId = noteList[0].Id;
                        clnk.ShareType = 'I';
                        lnk.add(clnk);
                    }
                }
                if(lnk != null && lnk.size() > 0){
                    insert lnk;
                }
            }
            if(trigger.isUpdate){
                system.debug('---after update-----');
                Set<Id> invAvaiIdSet = new Set<Id>();
                //oppListToSalesCadence added by Victor
                List<Opportunity> oppListToSalesCadence = new List<Opportunity>();
                //GuestVoucher Update
                map<Id, Id> mapOpportunityIdToAccountId = new map<Id, Id>();
                map<Id, Id> mapOppIdToOwnerId = new map<Id, Id>();
                Map<Id, Set<String>> oppIdToAddedGifts = new Map<Id, Set<String>>();
                Set<Id> oppIdSet = new Set<Id>();
                List<Task> tasklist = new List<Task>();
                set<Id> invIds = new set<Id>();
                set<Id> oppIds = new set<Id>();                
                //HSIMU2-882 Not cancelling - already implemented in OpportunityTriggerHandler.createReservationTrackingRecord
                /*set<Id> oppIdsToCleanReservationFields = new set<Id>();*/
                ID devAccountUserId= Label.Dev_Account_User_Id ;//[Select id from user where name='Dev Account'].id;
                for(Opportunity opp : trigger.new){
                    if (opp.Gift__c != Trigger.oldMap.get(opp.Id).Gift__c) {
                        Id clubVentureRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Club_Venture_Membership').getRecordTypeId();
                        if(opp.RecordTypeId == clubVentureRecordTypeId){
                            Set<String> oldGifts = new Set<String>();
                            Set<String> newGifts = new Set<String>();
                            
                            if (Trigger.oldMap.get(opp.Id).Gift__c != null)
                                oldGifts.addAll(Trigger.oldMap.get(opp.Id).Gift__c.split(';'));
                            if (opp.Gift__c != null)
                                newGifts.addAll(opp.Gift__c.split(';'));
                            
                            newGifts.removeAll(oldGifts); // retain only newly added values
                            
                            if (!newGifts.isEmpty()) {
                                oppIdToAddedGifts.put(opp.Id, newGifts);
                            }
                        }
                    }                    
                    if(opp.Inventory_Availability_Id__c != Trigger.oldMap.get(opp.Id).Inventory_Availability_Id__c && opp.Inventory_Availability_Id__c != null && opp.Property_Address__c == null){
                        oppIds.add(opp.Id);
                        invIds.add(opp.Inventory_Availability_Id__c);
                    }
                    if(opp.StageName == 'Closed Won' && opp.StageName != Trigger.oldMap.get(opp.Id).StageName){
                        system.debug('Store Opportunity Ids==== ');
                        oppIdSet.add(opp.Id);
                    }                    
                    if(opp.Match_Group_Name__c == 'Travel Sales-Web Form Inquiry' && opp.OwnerId != Trigger.oldMap.get(opp.Id).OwnerId && Trigger.oldMap.get(opp.Id).OwnerId == devAccountUserId){
                        mapOppIdToOwnerId.put(opp.Id, opp.OwnerId);
                    }
                    
                    if((opp.Rebook_Reservation__c != Trigger.oldMap.get(opp.Id).Rebook_Reservation__c && Trigger.oldMap.get(opp.Id).Rebook_Reservation__c ==true) || (opp.Reservation_Status__c != Trigger.oldMap.get(opp.Id).Reservation_Status__c && Trigger.oldMap.get(opp.Id).Reservation_Status__c == 'Cancel')){
                        system.debug('--Trigger.oldMap.get(opp.Id).Reservation_Status__c-'+Trigger.oldMap.get(opp.Id).Reservation_Status__c);
                        //system.debug('--Trigger.oldMap.get(opp.Id).Inventory_Availability_Id__c-'+Trigger.oldMap.get(opp.Id).Inventory_Availability_Id__c);
                        system.debug('--opp.Rebook_Reservation__c--'+opp.Rebook_Reservation__c);
                        if(Trigger.oldMap.get(opp.Id).Inventory_Availability_Id__c != null && Trigger.oldMap.get(opp.Id).Inventory_Availability_Id__c != '' && opp.Inventory_Availability_Id__c != null && opp.Inventory_Availability_Id__c != '')
                        {
                            //rebook - restore old inventory
                            invAvaiIdSet.add(Trigger.oldMap.get(opp.Id).Inventory_Availability_Id__c);
                        }
                        else
                        {
                            invAvaiIdSet.add(opp.Inventory_Availability_Id__c);
                        }                        
                    }
                    
                    if(invAvaiIdSet.size() > 0){
                        List<Inventory_Availability__c> invAvUpdatedList = new List<Inventory_Availability__c>();
                        List<Inventory_Availability__c> invAvaList = [select id,New_Availability__c from Inventory_Availability__c where id IN:invAvaiIdSet];
                        for(Inventory_Availability__c inv: invAvaList){
                            system.debug('--Trigger.oldMap.get(opp.Id).Inventory_Availability_Id__c-'+Trigger.oldMap.get(opp.Id).Inventory_Availability_Id__c);
                            system.debug('---inv.New_Availability__c-----'+inv.New_Availability__c);
                            inv.New_Availability__c = inv.New_Availability__c + 1;
                            system.debug('---inv.New_Availability__c-----'+inv.New_Availability__c);
                            invAvUpdatedList.add(inv);
                        }
                        if(invAvUpdatedList.size() > 0){
                            update invAvUpdatedList;
                            system.debug('--invAvUpdatedList--'+invAvUpdatedList);
                        }
                    }
                    if (!oppIdToAddedGifts.isEmpty()) {
                        OpportunityTrigger_NewHandler.handleGiftChanges(Trigger.newMap, oppIdToAddedGifts);
                    }                    
                    //added 2022-12-13 - MTRC Membership Upgrade Child Voucher Opportunity
                    Id oppMTRCMembership_UpgradeRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
                    Id oppSFXRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('SFX_Membership').getRecordTypeId();
                    Id oppHCRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Hawaii_Collection_Membership').getRecordTypeId();
                    Id oppAnnualDuesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Annual_Dues').getRecordTypeId();
                    
                    //MTRC_Retail added 2023-03-06
                    Id oppMTRCRetailRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MTRC_Retail').getRecordTypeId();
                    
                    // Added "Membership Add-On" 2024-09-25 TGR-215
                    Id oppMembAddOnRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Add_On').getRecordTypeId();
                    
                    if(oppMTRCMembership_UpgradeRecordTypeId != null){
                        //MTRC_Retail added 2023-03-06
                        // Added "Membership Add-On" 2024-09-25 TGR-215
                        // if((opp.RecordTypeId == oppMTRCMembership_UpgradeRecordTypeId || opp.RecordTypeId == oppMTRCRetailRecordTypeId || opp.RecordTypeId == oppSFXRecordTypeId || opp.RecordTypeId == oppHCRecordTypeId) && ((opp.IsWon != Trigger.oldMap.get(opp.Id).IsWon) || (opp.Payments_Count__c > 0 && Trigger.oldMap.get(opp.Id).Payments_Count__c == 0)) && opp.Payments_Count__c > 0 && opp.IsClosed && opp.IsWon)
                        //opp.RecordTypeId == oppMTRCMembership_UpgradeRecordTypeId || TGR-295
                        
                        if((opp.RecordTypeId == oppMTRCRetailRecordTypeId || opp.RecordTypeId == oppSFXRecordTypeId || opp.RecordTypeId == oppHCRecordTypeId || opp.RecordTypeId == oppMembAddOnRecordTypeId) && ((opp.IsWon != Trigger.oldMap.get(opp.Id).IsWon) || (opp.Payments_Count__c > 0 && Trigger.oldMap.get(opp.Id).Payments_Count__c == 0)) && opp.Payments_Count__c > 0 && opp.IsClosed && opp.IsWon)
                        {
                            AddChildVidaWeekVoucherOppController.tryToAddChildVidaWeekVoucherOppFuture(opp.Id);
                        }
                        //MTRC_Retail added 2023-03-06
                        if(!System.isFuture() && !System.isBatch() && (opp.RecordTypeId == oppMTRCMembership_UpgradeRecordTypeId || opp.RecordTypeId == oppSFXRecordTypeId || opp.RecordTypeId == oppHCRecordTypeId || opp.RecordTypeId == oppAnnualDuesRecordTypeId || opp.RecordTypeId == oppMTRCRetailRecordTypeId) && ((opp.IsClosed != Trigger.oldMap.get(opp.Id).IsClosed) || (opp.IsWon != Trigger.oldMap.get(opp.Id).IsWon)) && opp.IsClosed && !opp.IsWon)
                        {
                            AddChildVidaWeekVoucherOppController.searchAndMoveChildOppToClosedLost(opp.Id);                            
                        }
                    }
                    if(opp.RecordTypeId == oppAnnualDuesRecordTypeId && ((opp.IsWon != Trigger.oldMap.get(opp.Id).IsWon) || (opp.Payments_Count__c > 0 && Trigger.oldMap.get(opp.Id).Payments_Count__c == 0)) && opp.IsClosed && opp.IsWon && opp.Payments_Count__c > 0)
                    {
                        System.debug('AddChildVidaWeekVoucherOppController.tryToAddChildVidantaComplimentaryVoucherOppFuture(opp.Id); == ENTERED ');                       
                        AddChildVidaWeekVoucherOppController.tryToAddChildVidantaComplimentaryVoucherOppFuture(opp.Id);
                    }
                }
                
                if(oppIdSet != null && oppIdSet.size() > 0){
                    if(Recursive.flag){
                        OpportunityTrigger_NewHandler.MFAmmountUpdate(oppIdSet);
                        OpportunityTrigger_NewHandler.createRedemptionRecord(oppIdSet);

                        //RC-126
                        system.debug('--calling createRedemptionRecordFlyback --');
                        OpportunityTrigger_NewHandler handler = new OpportunityTrigger_NewHandler();
                        handler.createRedemptionRecordFlyback(Trigger.oldMap, Trigger.newMap);

                        Recursive.flag = false;
                    }
                }
                if(invIds != null && invIds.size() > 0){
                    OpportunityTriggerHandler.updateOppWithPropertyDetails(oppIds,invIds);
                }
                for(Id oppId : mapOppIdToOwnerId.keyset()){
                    Task objtask = new Task();
                    objtask.Subject = 'New Web Form Inquiry';
                    objtask.ActivityDate = System.today();
                    objtask.WhatId = oppId;
                    objtask.OwnerId = mapOppIdToOwnerId.get(oppId);
                    tasklist.add(objtask);
                }
                try{
                    if(tasklist != null && tasklist.size() > 0)
                        insert tasklist;
                }catch(exception e){
                    system.debug('--e---'+e);
                }
            }
        }
    }
}