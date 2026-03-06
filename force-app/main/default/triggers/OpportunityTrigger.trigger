trigger OpportunityTrigger on Opportunity (after insert,after update, before insert, before update, before delete) {
    
     Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('OpportunityTrigger');
    system.debug('---OpportunityTrigger----'+cs);
    if(cs != null && cs.isEnable__c){
        system.debug('--OpportunityTrigger--'+cs);
         if(trigger.isBefore && trigger.isInsert){
            Set<String> actId = new Set<String>();
            Id voucherSalesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
            Id viReferralRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VI_Referral_Date_Request').getRecordTypeId();
            //Id profitAgilityRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Profit_Agility_Voucher').getRecordTypeId();
            
            for(opportunity opp:trigger.new) {
                if(opp.RecordTypeId == voucherSalesRecordTypeId || opp.RecordTypeId == viReferralRecordTypeId/* || opp.RecordTypeId == profitAgilityRecordTypeId*/){
                    actId.add(opp.AccountId);
                }
            }
            
            List<Opportunity> lstOpportunity = [SELECT id, First_Payment_Date__c,Confirmed_Date__c, AccountId  FROM Opportunity WHERE AccountId IN: actId and (Recordtypeid =: voucherSalesRecordTypeId OR Recordtypeid =: viReferralRecordTypeId/* OR Recordtypeid =: profitAgilityRecordTypeId*/)];
            date last180Days = system.today().addDays(-180);
            for(opportunity opp : trigger.new){
                 for(Opportunity queriedOpp : lstOpportunity) {
                     if(opp.AccountId == queriedOpp.AccountId && queriedOpp.First_Payment_Date__c > last180Days){
                        system.debug('----inside if error');
                        opp.adderror('Only one Voucher is allowed per Account every 6 months');
                        
                    }
                }
            }
        }
        
        // After trigger
        if(Trigger.isAfter && trigger.isInsert) {
            Map<String, Id> pricebookMap = new Map<String, Id>();
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            List<PriceBookEntry> priceBookList = [SELECT Id, Name, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE PriceBook2.isStandard=true];
            System.debug('THIS IS THE FIRST LIST ' + priceBookList);
            
            OpportunityTriggerHandler.createReservationTrackingRecord(null, trigger.newMap, trigger.isInsert);
            //OpportunityTriggerHandler.createTaskForNameAssignment(null, trigger.newMap, trigger.isInsert);
            
            for(PriceBookEntry pbe : priceBookList) {
                pricebookMap.put(pbe.Product2.Name, pbe.id);
            }
            for (Opportunity oppty: Trigger.new) {
                
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
                else if(oppty.recordTypeId == System.Label.Opp_Membership_Annual_Dues) {
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.OpportunityId=oppty.Id; 
                    if(oppty.Annual_Dues__c != null) {
                        oli.Retail_Price__c = oppty.Annual_Dues__c;
                    }
                    oli.PricebookEntryId=pricebookMap.get('Membership Annual Dues') ;
                    System.debug('THIS IS THE PRICEBOOK ENTRY ID ' + oli.PricebookEntryId);
                    oli.ServiceDate = system.today();
                    oli.UnitPrice = oppty.Annual_Dues__c;
                    oli.Quantity = 1;
                    oliList.add(oli);
                }
            }
            try{
                insert oliList;
            }catch(exception e){
                system.debug('--e---'+e);
            }
            
            // Case creation logic
            // 
            
            List<Account> accountsForCases = new List<Account>();
            List<Opportunity> upgradeOpps = new List<Opportunity>();
            Set<Id> accountSet = new Set<Id>();
            Set<Id> badAccounts = new Set<Id>();
            
            Id travelOppRecType = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Travel' ].id ;
            Id upgradeRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Membership_Upgrade' ].id ;
            
            // Below CAT related logic commeted and move to list of Id due to 101 soql query limit - Mitul
            // Also update on upgradeOpps query where condition
            /*  
            Id CAT1 = [Select id from RecordType where sObjectType = 'Account' and developerName ='CAT_1_Net_Rate' ].id ;
            Id CAT10 = [Select id from RecordType where sObjectType = 'Account' and developerName ='CAT_10_Internal_HSI_Employee_Accounts' ].id ;
            Id CAT2 = [Select id from RecordType where sObjectType = 'Account' and developerName ='CAT_2_Employee_Benefits_ITA' ].id ;
            Id CAT3 = [Select id from RecordType where sObjectType = 'Account' and developerName ='CAT_3_Monthly_Recurring_Fee_ITA_Travel_Clubs' ].id ;
            Id CAT5 = [Select id from RecordType where sObjectType = 'Account' and developerName ='CAT_5_ProfitAgility' ].id ;
            */
            Set<Id> recrodtypeId = new Set<Id>();
            List<RecordType> rtypeList = [select Id from RecordType where sObjectType = 'Account' and 
                                          (developerName = 'CAT_1_Net_Rate' or
                                           developerName = 'CAT_10_Internal_HSI_Employee_Accounts' or
                                           developerName = 'CAT_2_Employee_Benefits_ITA' or
                                           developerName = 'CAT_3_Monthly_Recurring_Fee_ITA_Travel_Clubs' or
                                           developerName = 'CAT_5_ProfitAgility')];
            
            
            for(RecordType rpct : rtypeList){
                recrodtypeId.add(rpct.Id);
            }
            Id upgradeQueue = System.Label.MembershipUpgradeQueue;
            List<Case> caseList = new List<Case>();
            
            for(Opportunity o : trigger.new) {
                
                if(o.RecordTypeId == travelOppRecType) {
                    accountSet.add(o.AccountId);
                 }   
            }
           
            upgradeOpps = [Select Id, recordTypeId, closeDate, AccountId FROM Opportunity WHERE AccountId IN :accountSet AND RecordTypeId = :upgradeRecordTypeId];
            
            for(Opportunity opp : upgradeOpps) {
                
                badAccounts.add(opp.AccountId);
            }
            
            accountsForCases = [Select Id, Name, RecordTypeId, Affiliated_Id__c,Member_Number__c,
                                (select Id,Name, Membership_Product_Configuration__r.Product_Type__c from contacts),(select Id from cases where type = 'Membership Upgrade') FROM Account WHERE Id NOT IN :badAccounts AND Id IN :accountSet AND Affiliated_Id__c NOT IN(1002226, 1002227, 1002225, 1001467, 1002203, 1002256, 1002258, 1001948, 1001675, 1002122, 1001617,1002249, 1002250, 1002248, 1002254, 1002241, 1002247, 1002246, 1002229)
                               AND RecordTypeId NOT IN :recrodtypeId ];
                                //AND RecordTypeId != :CAT1 AND RecordTypeId != :CAT2 AND RecordTypeId != :CAT3 AND RecordTypeId != :CAT5 and RecordTypeId != :CAT10];
            
            
            Boolean createCase = true;
            
            for(Account a : accountsForCases) { 
                List<Case> existingCaseList = a.Cases;
                if(existingCaseList.isEmpty()){
                    List<Contact> conList = a.Contacts;
                    Id contactId = null;
                    if(conList != null && conList.size() > 0){
                        for(Contact con: conList){
                            if(con.Membership_Product_Configuration__r.Product_Type__c == 'B2B'){
                                createCase = false;
                                break;
                            }
                            
                            if(con.Name == a.Name){
                                contactId = con.Id;
                                //break;
                            }
                        }
                    }
                    if(createCase){
                        Id caseRecordTypeId = [Select id from RecordType where sObjectType = 'Case' and developerName ='Membership_Upgrade' ].id ;
                        Case c = new Case();
                        c.Subject = 'Membership Upgrade for ' + a.Name;
                        c.Description = 'Membership Upgrade for ' + a.Name;
                        c.Origin = 'Phone';
                        c.Status = 'New';
                        c.OwnerId = upgradeQueue;
                        c.AccountId = a.id;
                        c.RecordTypeId = caseRecordTypeId;
                        c.Member_Number__c = a.Member_Number__c;
                        c.type = 'Membership Upgrade';
                        c.ContactId = contactId;
                        
                        caseList.add(c);
                    }
                    
                }
                
                
            }
            try{
               insert caseList;
            }catch(exception e){
               system.debug('--e---'+e);
            }
            
            
        }
        
        // Before Trigger Action
        if(Trigger.isBefore && !trigger.isDelete){
            System.debug('This is the before trigger');
            if(trigger.isUpdate){
                for(Opportunity opp : trigger.new) {
                   
                    system.debug('--opp.Membership_Upgrade_Type__c--'+opp.Membership_Upgrade_Type__c);
                    system.debug('--opp.Upgrade_Type__c--'+opp.Upgrade_Type__c);
                    system.debug('--opp.Net_Amount__c--'+opp.Net_Amount__c);
                    if(opp.Net_Amount__c != null){
                        if(opp.Override_Credits_Received__c != true && opp.Override_File_Fee__c != true){
                            if(opp.Upgrade_Type__c == 'Hawaii Collection Silver-Membership Upgrade'){
                                opp.Credit_Received__c = (opp.Net_Amount__c * .05).round();
                                opp.File_Fees__c = 0;
                            }else if(opp.Upgrade_Type__c == 'Hawaii Collection Gold-Membership Upgrade'){
                                opp.Credit_Received__c = (opp.Net_Amount__c * .10).round();
                                opp.File_Fees__c = 0;
                            }else if(opp.Upgrade_Type__c == 'Hawaii Collection Platinum-Membership Upgrade'){
                                opp.Credit_Received__c = (opp.Net_Amount__c * .15).round();
                                opp.File_Fees__c = 0;
                            }else{
                                opp.Credit_Received__c = (opp.Net_Amount__c * .10).round();
                                opp.File_Fees__c = (opp.Net_Amount__c * .10).round();
                            }
                        }
                    }
                    System.debug('THIS IS THE NET AMOUNT ' + opp.Net_Amount__c);
                    
                }
            }
            
        }
        
       
        // Changes for ticket B-06886. Hitarth Raval
        if(trigger.isBefore && trigger.isDelete) {
            List<Deleted_Record__c> deletedRecList = new List<Deleted_Record__c>();
            Id profileId = userinfo.getProfileId();
            String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
            Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='Membership_Upgrade' ].id ;
            for(Opportunity opp : trigger.old) {
                if(profileName != 'System Administrator' && opp.RecordTypeId == oppRecordTypeId) {
                    if(!Test.isRunningTest()) {
                        opp.addError('Sorry, you can not delete Membership Upgrade Opportunities');
                    }
                }
            }
            
            Id userId = userinfo.getUserId();
                               User userDetails =[SELECT Id, Name, Email, Profile.Name, UserRole.Name FROM User where Id=:userId ];
                               Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
                               system.debug('userDetails.UserRole.Name' + userDetails.UserRole.Name);
            for(Opportunity opp : trigger.old) {
                Deleted_Record__c deletedRec = new Deleted_Record__c();
                deletedRec.Id__c = opp.Id;
                deletedRec.Object_Name__c = 'Opportunity';
                deletedRec.Created_Date__c = date.today();
                deletedRecList.add(deletedRec);
                
                if(userDetails.UserRole.Name == 'Tour Generation Manager' && opp.RecordTypeId == devRecordTypeId){
                    system.debug('opp.RecordTypeId==' + opp.RecordTypeId + ' devRecordTypeId=' + devRecordTypeId + ' opp.First_Payment_Made__c ' + opp.First_Payment_Made__c);
                    if(opp.StageName != 'New' || opp.First_Payment_Made__c == TRUE ) {
                        if(!Test.isRunningTest()) {
                            opp.addError('Sorry, you do not have permission to delete this Opportunity');
                        }
                    }
                }
                
            }
            if(!deletedRecList.isEmpty()){
                insert deletedRecList;
            }
        } 
        
        if(trigger.isBefore && trigger.isUpdate){
            if(checkRecursive.opportunitycreateReservationTrackingRecord){
            List<Id> opportunityIdSet = New List<id>();
            List<OpportunityLineItem> opplinerecord = new List<OpportunityLineItem>();
            Id opprecordtypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Membership Upgrade').getRecordTypeId();
            
            Id voucherSalesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
            Id viReferralRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VI_Referral_Date_Request').getRecordTypeId();
            
            for(Opportunity opp: trigger.new){
                if(opp.RecordTypeId == voucherSalesRecordTypeId || opp.RecordTypeId == viReferralRecordTypeId){
                    if(opp.Reservation_Status__c != trigger.oldMap.get(opp.Id).Reservation_Status__c && opp.Reservation_Status__c == 'Confirmed' && opp.Original_Confirmation__c != true){
                        opp.Original_Confirmation__c = true;
                    }
                }
            }
            
            system.debug('----reservation call----');
            
            OpportunityTriggerHandler.createReservationTrackingRecord(trigger.oldMap, trigger.newMap, trigger.isInsert);
            //OpportunityTriggerHandler.createTaskForNameAssignment(trigger.oldMap, trigger.newMap, trigger.isInsert);
            Set<Id> OppIdSetForPayment = new Set<Id>();
            for(Opportunity opp : trigger.new){
                if(opp.StageName == 'Closed Won' && (opp.RecordTypeId == opprecordtypeid)){
                    opportunityIdSet.add(opp.Id);
                }
                // B-06412 : Block ability to change voucher opportunity status to closed without payment
                if(opp.StageName != trigger.oldMap.get(opp.Id).StageName && opp.StageName == 'Closed Won' && (opp.RecordTypeId == voucherSalesRecordTypeId || opp.RecordTypeId == viReferralRecordTypeId)){
                    OppIdSetForPayment.add(opp.Id);
                }
                
            }
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
                                    Id profileId=userinfo.getProfileId();
                                    system.debug('--profileId---'+profileId);
                                    system.debug('--Label.System_Admin_Profile_Id---'+Label.System_Admin_Profile_Id);
                                    if(!Label.System_Admin_Profile_Id.contains(profileId)){
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
               opplinerecord = [Select Id from OpportunityLineItem  where Product2.Name = 'Equity Value' AND OpportunityId IN :opportunityIdSet]; 
                
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
            
            //Update Booking agent on opp for Flex and Cruise for SFX Membership Hitarth Raval 28-9-22
            for(Opportunity opp : Trigger.new){
                if(opp.Check_in_Flex__c != Null && opp.Check_in_Flex__c != Trigger.oldMap.get(opp.Id).Check_in_Flex__c){
                    opp.Booking_Agent_Flex__c = userinfo.getUserId();
                } 
                if(opp.Cruise_Certificate_Status__c != Null && opp.Cruise_Certificate_Status__c != Trigger.oldMap.get(opp.Id).Cruise_Certificate_Status__c){
                    opp.Booking_Agent_Cruise__c = userinfo.getUserId();
                }
            }
                checkRecursive.opportunitycreateReservationTrackingRecord = false;
        }
        }
        // Added to calculate the Inventory Availability

        
        if(trigger.isAfter && trigger.isUpdate){
             system.debug('---after update-----');
             Set<Id> invAvaiIdSet = new Set<Id>();
             for(Opportunity opp : trigger.new){
                 system.debug('---after update-----'+opp.Rebook_Reservation__c);
                 if((opp.Rebook_Reservation__c != Trigger.oldMap.get(opp.Id).Rebook_Reservation__c && Trigger.oldMap.get(opp.Id).Rebook_Reservation__c ==true) || (opp.Reservation_Status__c != Trigger.oldMap.get(opp.Id).Reservation_Status__c && Trigger.oldMap.get(opp.Id).Reservation_Status__c == 'Cancel')){
                     system.debug('---after update-----'+opp.Reservation_Status__c);
                     invAvaiIdSet.add(opp.Inventory_Availability_Id__c);
                     system.debug('---invAvaiIdSet-----'+invAvaiIdSet);
                 }
             }
             if(invAvaiIdSet.size() > 0){
                 List<Inventory_Availability__c> invAvUpdatedList = new List<Inventory_Availability__c>();
                 List<Inventory_Availability__c> invAvaList = [select id,New_Availability__c from Inventory_Availability__c where id IN:invAvaiIdSet];
                 for(Inventory_Availability__c inv: invAvaList){
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
            
//            //RC-126
//            system.debug('--calling createRedemptionRecordFlyback --');
//            OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
//    		handler.createRedemptionRecordFlyback(Trigger.oldMap, Trigger.newMap);
         }
    }
}