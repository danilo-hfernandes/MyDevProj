trigger PaymentTrigger_New on Payment__c (before insert,after update, after insert, before update, before delete, after delete) {
    Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('PaymentTrigger_New');
    if(cs != null && cs.isEnable__c){
        String paymentRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Membership Annual Dues').getRecordTypeId();
        // All before insert or before update logic will go here
        if(trigger.isBefore){
            //Before Insert
            if(trigger.isInsert){
                //HSIMU2-628 2024-01-26 Product_Salesforce_Id__c populated first
                Set<Id> oppIds = new Set<Id>();
                List<Payment__c> paymentList = new List<Payment__c>();
                for(payment__c pay: trigger.new){
                    if(pay.Product_Salesforce_Id__c != null && pay.Product_Id__c == null && pay.Product_Salesforce_Id__c == '01t3t000006O7LLAA0'){
                        oppIds.add(pay.Opportunity__c);
                        paymentList.add(pay);
                    }
                }
                if(oppIds != null && oppIds.size()>0){
                    system.debug('----before updateProductIdBasedOnSFProduct2Id');
                    PaymentTriggerHandler.updateProductIdBasedOnSFProduct2Id(oppIds,paymentList);
                }
            }
            // Before delete logic will go here
            if(trigger.isDelete && trigger.isBefore){
                List<Deleted_Record__c> deletedRecList = new List<Deleted_Record__c>();
                for(Payment__c rec: trigger.old){
                    Deleted_Record__c deletedRec = new Deleted_Record__c();
                    deletedRec.Id__c = rec.Id;
                    deletedRec.Object_Name__c = 'Payment';
                    deletedRec.Created_Date__c = date.today();
                    deletedRec.RecId__c = rec.RecId__c;
                    deletedRecList.add(deletedRec);
                }
                
                if(!deletedRecList.isEmpty()){
                    insert deletedRecList;
                }
            }
            
            if(trigger.isUpdate){
                if(checkRecursive.paymentTrigger){
                    checkRecursive.paymentTrigger = false;
                    Set<String> oppIdSet = new Set<String>();
                    
                    for(Payment__c py : trigger.new){
                        if(py.Product_Id__c != null && py.Product_Salesforce_Id__c == null){
                            oppIdSet.add(py.Opportunity__c);
                        }
                    }
                    if(oppIdSet != null){
                        List<OpportunityLineItem> opplineList = New List<OpportunityLineItem>();
                        opplineList = [select id,Product_Id__c,Product2Id from OpportunityLineItem where OpportunityId IN : oppIdSet];
                        Map<String,Id> mapOfProductIdandPSId = new Map<String,Id>();
                        Map<String,Id> mapOfProductIdandOppLineItemId = new Map<String,Id>();
                        for(OpportunityLineItem oppLin : opplineList){
                            mapOfProductIdandPSId.put(oppLin.Product_Id__c,oppLin.Product2Id);
                            mapOfProductIdandOppLineItemId.put(oppLin.Product_Id__c,oppLin.id);
                        }
                        system.debug('----mapOfProductIdandPSId'+mapOfProductIdandPSId);
                        if(mapOfProductIdandPSId != null && mapOfProductIdandPSId.size() > 0){
                            for(Payment__c py : trigger.new){
                                if(py.Product_Id__c != null && py.Product_Salesforce_Id__c == null){
                                    if(mapOfProductIdandPSId.containsKey(py.Product_Id__c)){
                                        system.debug('py.Product_Id__c'+py.Product_Id__c);
                                        py.Product_Salesforce_Id__c = mapOfProductIdandPSId.get(py.Product_Id__c);
                                        py.Opportunity_Product__c = mapOfProductIdandOppLineItemId.get(py.Product_Id__c);
                                    }
                                }
                            }
                        }  
                    }
                }
            }
        }
        if(trigger.isAfter){
            // After delete logic will go here
            if(trigger.isDelete){
                Set<Id> deletedPaymentsIds = new Set<Id>();
                for(Payment__c rec: trigger.old){
                    System.debug('deletedPayment = '+rec);
                    if(rec.Product_Name__c == 'Annual Dues-Renewal' || rec.Product_Name__c == 'Annual Dues Voucher Bundle' || rec.Product_Name__c == 'Annual Dues Exit' || rec.Product_Name__c == 'Membership Reinstatement-Voucher Bundle'){
                        deletedPaymentsIds.add(rec.Id);
                    }
                }
                
                if(deletedPaymentsIds.size()>0 && deletedPaymentsIds != null){
                    System.debug('deletedPaymentsIds = '+deletedPaymentsIds);
                    PaymentTriggerHandler.annualDuesDeletedPaymentAPI(deletedPaymentsIds);
                }
            }
            
            // All after insert or after update logic will go here
            if(!trigger.IsDelete){
                // All after insert logic will go here
                if(trigger.isInsert){
                    if(checkRecursive.paymentTrigger){
                        checkRecursive.paymentTrigger = false;
                        Set<String> oppIdSet = new Set<String>();
                        Set<Id> paymentId = new Set<Id>();
                        Set<Id> paymentIdSet = new Set<Id>();
                        List<Payment__c> paymentIdList = new List<Payment__c>();
                        Set<Id> setPaymentIdForCreditUpdate = new Set<Id>();
                        set<Id> setPaymentIdAnnualDue = new set<Id>();
                        set<Id> setPaymentIdSFXGoldMembers = new set<Id>();
                        set<Id> VacationVIPVoucherUpgradeSet = new set<Id>();
                        set<Id> setPaymentIdAnnualDueWaiver = new set<Id>();
                        set<Id> setPaymentIdMembershipReinstatementVoucher = new set<Id>();
                        set<Id> setPaymentIdCFDMembersite = new set<Id>();
                        set<Id> setPaymentIdProfitAgilityAgencyMXVouchers = new set<Id>();
                        set<Id> setOpportunityLemonJuice = new set<Id>();
                        set<Id> setMonsterPaymentIds = new set<Id>();
                        
                        //MSR-76 - get opportunity as related items are not loaded in the trigger.new
                        Set<Id> oppIds = new Set<Id>();
                        for (Payment__c py : Trigger.new) {
                            if (py.Opportunity__c != null) oppIds.add(py.Opportunity__c);
                        }
                        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>(
                            [SELECT Id, Product_Name__c, Product_Summary__c
                             FROM Opportunity
                             WHERE Id IN :oppIds]
                        );

                        for(Payment__c py : trigger.new){
                            Boolean notMembershipUpgradeVidaWeekProduct = true;
                            Boolean setPaymentIdForCreditUpdateAdded = false;
                            //MSR-76
                            system.debug('>>>MSR-76>>>>');
                            system.debug('Opportunity__r.Product_Name__c'+oppMap.get(py.Opportunity__c).Product_Name__c);
                            system.debug('Opportunity__r.Product_Summary__c'+oppMap.get(py.Opportunity__c).Product_Summary__c);
                            
                            //if(!System.isFuture() && !System.isBatch() && py.Opportunity__c != null && (py.Product_Id__c != null || (py.Product_Salesforce_Id__c != null && py.Product_Name__c == 'Travel Credits'))){
                            //if(!System.isFuture() && !System.isBatch() && py.Opportunity__c != null && oppMap.get(py.Opportunity__c).Product_Summary__c.contains('Travel Credits')){
                            if (!System.isFuture() &&
                                !System.isBatch() &&
                                py.Opportunity__c != null &&
                                oppMap.containsKey(py.Opportunity__c) &&
                                oppMap.get(py.Opportunity__c).Product_Summary__c != null &&
                                oppMap.get(py.Opportunity__c).Product_Summary__c.contains('Travel Credits')) {
                                    system.debug('>>>Travel>>>>'+py.Product_Name__c);
                                    setPaymentIdForCreditUpdate.add(py.Id);
                                    setPaymentIdForCreditUpdateAdded = true;
                                }
/*                            //MSR-76
                            if(oppMap.get(py.Opportunity__c).Product_Name__c.contains('Travel Credits') && !setPaymentIdForCreditUpdateAdded){
                                system.debug('>>>System.isFuture()>>>>'+System.isFuture());
                                system.debug('>>>System.isBatch()>>>>'+System.isBatch());
                                system.debug('>>>py.Opportunity__c>>>>'+py.Opportunity__c);
                                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                                String[] sendingTo = new String[]{'danilo.fernandes@nerdsoft.com','cicero.schoeps@nerdsoft.com'}; 
                                String message = '>>>System.isFuture()>'+System.isFuture()+' ';
                                Message = message + '>>>System.isBatch()>'+System.isBatch()+' ';
                                Message = message + '>>>py.Opportunity__c>'+py.Opportunity__c+' ';
                                Message = message + '>>>py.Product_Id__c>'+py.Product_Id__c+' ';
                                Message = message + '>>>py.Product_Salesforce_Id__c>'+py.Product_Salesforce_Id__c+' ';
                                Message = message + '>>>py.Product_Name__c>'+py.Product_Name__c+' ';
                                Message = message + '>>>py.Opportunity__r.Product_Name__c>'+py.Opportunity__r.Product_Name__c+' ';
                                Message = message + '>>>py.Id>'+py.Id+' ';
                                semail.setToAddresses(sendingTo);
                                semail.setSubject('MSR-76 setPaymentIdForCreditUpdate not called');
                                semail.setPlainTextBody(message);
                                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
                            }
  */                          
                            if(py.Product_Salesforce_Id__c != null){
                                //dont call for child opps
                                if((System.isFuture() && (py.Product_Name__c == 'Marival Armony-4 Nights (2A) Studio' || py.Product_Name__c == 'Marival Armony MX National-3 Nights (2A) Studio')) || py.Product_Name__c == 'Membership Upgrade Vida Week' || py.Product_Name__c == 'Voucher-Vidanta Complimentary' || py.Product_Name__c == 'FlexStay-Add On')
                                {
                                    notMembershipUpgradeVidaWeekProduct = false;
                                }
                            }
                            //2023-04-03 - flyBack filter based on record type and opp stage added
                            if(py.Opportunity__c != null && py.Opportunity_Record_Type_Developer_Name__c == 'Membership_Add_On' && py.Opportunity_Stage__c != 'Closed Won'){
                                system.debug('>>>>>>Inside Membership Add on');
                                PaymentTriggerHandler.flyBackPaymentCreation(py.Opportunity__c, py.Id); 
                            }
                            if(py.Product_Id__c != null && py.Product_Salesforce_Id__c == null){
                                system.debug('-py.Product_Id__c-'+py.Product_Id__c);
                                //paymentIdList.add(py);
                                paymentIdSet.add(py.Id);
                                oppIdSet.add(py.Opportunity__c);
                            }
                            //2023-04-03 - hawaiiCollectionApi filter based on record type added
                            if( py.Product_Salesforce_Id__c != null && notMembershipUpgradeVidaWeekProduct && py.Opportunity_Record_Type_Developer_Name__c == 'Hawaii_Collection_Membership'){
                                paymentId.add(py.Id);
                            }
                            if(py.Opportunity__c != null && py.RecordTypeId == paymentRecordTypeId){
                                setPaymentIdAnnualDue.add(py.Id);
                            }
                            if(!System.isFuture() && !System.isBatch() && py.Opportunity__c != null && notMembershipUpgradeVidaWeekProduct){
                                setPaymentIdAnnualDueWaiver.add(py.Id);
                            }
                            // This api is for SFX Gold Members
                            //2023-04-03 - SFX Gold Members filter based on account affiliate id added
                            if(py.Opportunity__c != null && notMembershipUpgradeVidaWeekProduct && py.Account_Affiliate_Id__c == 1002275){
                                setPaymentIdSFXGoldMembers.add(py.Id);
                            }
                            // This api is for Vacation VIP Voucher Upgrade
                            //2023-04-03 - Vacation VIP Voucher Upgrade Members filter based on account affiliate id and account master record id added
                            if(py.Opportunity__c != null && notMembershipUpgradeVidaWeekProduct && (py.Account_Affiliate_Id__c == 1002336 || (py.Payment_Amount__c > 0 && py.Account_Affiliate_Id__c == 1002348 && (py.Account_Master_Record_Id__c == '' || py.Account_Master_Record_Id__c == null)))){
                                VacationVIPVoucherUpgradeSet.add(py.Id);
                            }
                            if(!System.isFuture() && !System.isBatch() && py.Opportunity__c != null && notMembershipUpgradeVidaWeekProduct){
                                setPaymentIdMembershipReinstatementVoucher.add(py.Id);
                            }
                            // This api is for CFD Membersite
                            //2023-08-15 - Update DLPU + 1 Year for CFD Membersite
                            if(py.Opportunity__c != null && notMembershipUpgradeVidaWeekProduct && (py.Account_Affiliate_Id__c == 1002256 || py.Account_Affiliate_Id__c == 1002266)){
                                setPaymentIdCFDMembersite.add(py.Id);
                            }                        
                            //2023-09-12 - PA-31 - ProfitAgility Agency MX Vouchers - SF
                            if(py.Opportunity__c != null && notMembershipUpgradeVidaWeekProduct && (py.Product_Name__c == 'Vida Voucher-ProfitAgility Agency')){
                                setPaymentIdProfitAgilityAgencyMXVouchers.add(py.Opportunity__c);
                            }
                            if(py.Opportunity__c != null && py.Account_Affiliate_Id__c == 1002436){
                                setOpportunityLemonJuice.add(py.Opportunity__c);
                            }
                        }
                        if(oppIdSet != null && paymentIdSet != null){
                            PaymentTriggerHandler.updateProductId(oppIdSet,paymentIdSet);
                        }
                        if(setPaymentIdAnnualDue != null && setPaymentIdAnnualDue.size() > 0){
                            PaymentTriggerHandler.annualDuePaymentAPI(setPaymentIdAnnualDue);
                        }
                        if(setPaymentIdAnnualDueWaiver != null && setPaymentIdAnnualDueWaiver.size() > 0){
                            PaymentTriggerHandler.annualDuePaymentWaiverAPI(setPaymentIdAnnualDueWaiver);
                        }
                        // This api is for SFX Gold Members
                        if(setPaymentIdSFXGoldMembers != null && setPaymentIdSFXGoldMembers.size() > 0){
                            system.debug('---setPaymentIdSFXGoldMembers---'+setPaymentIdSFXGoldMembers);
                            PaymentTriggerHandler.SFXGoldMembersAPI(setPaymentIdSFXGoldMembers);
                        }
                        // This api is for Vacation VIP Voucher Upgrade
                        if(VacationVIPVoucherUpgradeSet != null && VacationVIPVoucherUpgradeSet.size() > 0){
                            system.debug('---VacationVIPVoucherUpgradeSet---'+VacationVIPVoucherUpgradeSet);
                            PaymentTriggerHandler.VacationVIPVoucherUpgrade(VacationVIPVoucherUpgradeSet);
                        }                    
                        if(setPaymentIdMembershipReinstatementVoucher != null && setPaymentIdMembershipReinstatementVoucher.size() > 0){
                            system.debug('---setPaymentIdMembershipReinstatementVoucher---'+setPaymentIdMembershipReinstatementVoucher);
                            PaymentTriggerHandler.membershipReinstatementVoucherPaymentAPI(setPaymentIdMembershipReinstatementVoucher);
                        }
                        // This api is for CFD Membersite
                        //2023-08-15 - Update DLPU + 1 Year for CFD Membersite
                        if(setPaymentIdCFDMembersite != null && setPaymentIdCFDMembersite.size() > 0){
                            PaymentTriggerHandler.CFDMembersiteAPI(setPaymentIdCFDMembersite);
                        }
                        
                        //2023-09-12 - PA-31 - ProfitAgility Agency MX Vouchers - SF
                        if(setPaymentIdProfitAgilityAgencyMXVouchers != null && setPaymentIdProfitAgilityAgencyMXVouchers.size() > 0){
                            PaymentTriggerHandler.sendProfitAgilityAgencyMXVoucherContactsToSRRAndCadence(setPaymentIdProfitAgilityAgencyMXVouchers);
                        }
                        //2024-05-28 Enroll automatically after the payment is posted
                        if(setOpportunityLemonJuice != null && setOpportunityLemonJuice.size() > 0){
                            List<Opportunity> listOpp = [select id,AccountId from Opportunity where Id IN : setOpportunityLemonJuice and Account.Member_Number__c = null];
                            set<Id> setAccIds = new set<Id>();
                            List<Account> listAcc = new List<Account>(); 
                            if(listOpp != null && listOpp.size() > 0){
                                for(Opportunity opp : listOpp){
                                    setAccIds.add(opp.AccountId);
                                }
                                listAcc = [select id,Master_Record_Id__c,Affiliated_Id__c,BillingStreet,BillingCity,BillingState,BillingCountry,Email__c,BillingPostalCode,First_Name__c,Last_Name__c,Phone  from Account where Id IN : setAccIds];
                                if(listAcc != null && listAcc.size() > 0){
                                    AccountTriggerHelper acc = New AccountTriggerHelper();
                                    acc.CreateHSIEnrollment(listAcc);
                                }
                            }
                        }
                        if(setPaymentIdForCreditUpdate != null && setPaymentIdForCreditUpdate.size() > 0){
                            PaymentTriggerHandler.updateMemberCreditAPI(setPaymentIdForCreditUpdate);
                        }
                        Apex_Trigger_On_Off__c cs = Apex_Trigger_On_Off__c.getValues('hawaiiCollectionAPI');
                        if(cs != null && cs.isEnable__c){
                            if(paymentId != null && paymentId.size()>0){
                                PaymentTriggerHandler.hawaiiCollectionApi(paymentId);
                            }
                        } 
                    }
                }  
            }
        }
    }
}