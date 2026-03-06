public class PastDueMUDowngradeViewerCtrl {
    @AuraEnabled(cacheable=true)
    public static List<Opportunity> getOpportunitiesToDowngrade() {
        String query = 'SELECT Id,AccountId,StageName, Account.Affiliated_Id__c,Account.Affiliate_Name__c,Account.Contact_Id__c,Member_Number__c, CreatedDate, Name, Down_Deposit__c, Number_of_Payments__c, Total_Amount__c,Total_Amount_Paid__c, Monthly_Payment__c,Total_Refund__c,Payment_Type__c, ' +
            '(SELECT Id, CreatedDate, Payment_Amount__c FROM Payments__r WHERE Payment_Amount__c > 0 ORDER BY CreatedDate ASC) ' +
            'FROM Opportunity WHERE (Payment_Type__c = \'Single Credit Card - With PP\' OR Payment_Type__c = \'30% Down - PP\') ' +
            'AND StageName = \'Closed Won\' AND Down_Deposit__c > 0 ';
        query = query + 'AND RecordType.DeveloperName IN (\'SFX_Membership\',\'Hawaii_Collection_Membership\',\'Membership_Upgrade\',\'MTRC_Retail\')';
        List<Opportunity> opportunities = Database.query(query);
        List<Opportunity> opportunitiesToDowngrade = new List<Opportunity>();
        Map<Id,Boolean> validPaymentPostedInTheLast30Days = new Map<Id,Boolean>();

        // Step 1: Build a Set<Id> from the List<Opportunity>
        Set<Id> oppIdSet = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : opportunities) {
            oppIdSet.add(opp.Id);
            accountIds.add(opp.AccountId);
        }
        
         // Maps to hold the penultimate change and current value for each field
        Map<Id, String> penultimateAffiliateNameMap = new Map<Id, String>();
        Map<Id, String> penultimateAffiliatedIdMap = new Map<Id, String>();
        Map<Id, String> currentAffiliateNameMap = new Map<Id, String>();
        Map<Id, String> currentAffiliatedIdMap = new Map<Id, String>();
        Map<Id, String> currentOldAffiliateNameMap = new Map<Id, String>();
        Map<Id, String> currentOldAffiliatedIdMap = new Map<Id, String>();

        // Query AccountHistory for the specified fields and account IDs
        List<AccountHistory> accountHistories = [
            SELECT AccountId, Field, NewValue, OldValue
            FROM AccountHistory
            WHERE AccountId IN :accountIds
            AND (Field = 'Affiliate_Name__c' OR Field = 'Affiliated_Id__c')
            ORDER BY CreatedDate DESC
        ];

        // Process the history records
        Map<Id, List<AccountHistory>> historyMap = new Map<Id, List<AccountHistory>>();
        for (AccountHistory history : accountHistories) {
            if (!historyMap.containsKey(history.AccountId)) {
                historyMap.put(history.AccountId, new List<AccountHistory>());
            }
            historyMap.get(history.AccountId).add(history);
        }

        // Iterate through each account to determine the penultimate changes and current values
        for (Id accountId : accountIds) {
            if (historyMap.containsKey(accountId)) {
                List<AccountHistory> histories = historyMap.get(accountId);

                // Determine the current value and penultimate change for Affiliate_Name__c
                String affiliateNameCurrent = null;
                String affiliateNameCurrentOld = null;
                String affiliateNamePenultimate = null;
                Integer affiliateNameCount = 0;

                // Determine the current value and penultimate change for Affiliated_Id__c
                String affiliatedIdCurrent = null;
                String affiliatedIdCurrentOld = null;
                String affiliatedIdPenultimate = null;
                Integer affiliatedIdCount = 0;

                for (AccountHistory history : histories) {
                    if (history.Field == 'Affiliate_Name__c') {
                        affiliateNameCount++;
                        if (affiliateNameCount == 1) {
                            affiliateNameCurrent = String.valueOf(history.NewValue);
                            affiliateNameCurrentOld = String.valueOf(history.OldValue);
                        } else if (affiliateNameCount == 2) {
                            affiliateNamePenultimate = String.valueOf(history.NewValue);
                        }
                    } else if (history.Field == 'Affiliated_Id__c') {
                        affiliatedIdCount++;
                        if (affiliatedIdCount == 1) {
                            affiliatedIdCurrent = String.valueOf(history.NewValue);
                            affiliatedIdCurrentOld = String.valueOf(history.OldValue);
                        } else if (affiliatedIdCount == 2) {
                            affiliatedIdPenultimate = String.valueOf(history.NewValue);
                        }
                    }
                }

                // Save the results in the corresponding maps
                if (affiliateNamePenultimate != null) {
                    penultimateAffiliateNameMap.put(accountId, affiliateNamePenultimate);
                }
                if (affiliatedIdPenultimate != null) {
                    penultimateAffiliatedIdMap.put(accountId, affiliatedIdPenultimate);
                }
                if (affiliateNameCurrent != null) {
                    currentAffiliateNameMap.put(accountId, affiliateNameCurrent);
                }
                if (affiliatedIdCurrent != null) {
                    currentAffiliatedIdMap.put(accountId, affiliatedIdCurrent);
                }
                if (affiliateNameCurrentOld != null) {
                    currentOldAffiliateNameMap.put(accountId, affiliateNameCurrentOld);
                }
                if (affiliatedIdCurrentOld != null) {
                    currentOldAffiliatedIdMap.put(accountId, affiliatedIdCurrentOld);
                }
            }
        }

        // At this point, you have your maps filled with penultimate changes and current values
        // You can now use these maps as needed in your application logic
        
        // Step 2: Query OpportunityFieldHistory for StageName changes (no filtering on NewValue here)
        List<OpportunityFieldHistory> oppHistoryList = [
            SELECT OpportunityId, OldValue, NewValue 
            FROM OpportunityFieldHistory 
            WHERE Field = 'StageName'
            AND OpportunityId IN :oppIdSet
        ];
        
         Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        
        // Step 3: Create a Map<Id, String> to track the opps where StageName was changed to 'Closed Lost-Balance'
        Map<Id, String> oppStageChangedMap = new Map<Id, String>();
        for (OpportunityFieldHistory history : oppHistoryList) {
            // Filter in Apex to check if NewValue is 'Closed Lost-Balance'
            if (String.valueOf(history.NewValue) == 'Closed Lost-Balance' && !runningInASandbox) {
                oppStageChangedMap.put(history.OpportunityId, String.valueOf(history.NewValue));
            }
        }
        
        Date firstDayLastMonth = Date.today().addMonths(-1).toStartOfMonth();
        for(Opportunity objOpp : opportunities){
            //Date.valueOf(String.valueOf(objOpp.CreatedDate).substring(0, 10))
            if(objOpp.Payments__r != null || objOpp.Payments__r.size() != 0){
                for(Payment__c py : objOpp.Payments__r) {
                    if(Date.valueOf(String.valueOf(py.CreatedDate).substring(0, 10)) >= firstDayLastMonth && py.Payment_Amount__c > 1.00)
                    {
                        validPaymentPostedInTheLast30Days.put(objOpp.Id,true);
                    }
                }
            }            
        }
        for(Opportunity objOpp : opportunities){
            objOpp.Base_Price__c = objOpp.Total_Amount__c - (objOpp.Total_Amount_Paid__c - objOpp.Total_Refund__c);
            objOpp.X2nd_Owner__c = String.valueOf(objOpp.Account.Affiliated_Id__c);
            objOpp.Access_Code__c = objOpp.Account.Affiliate_Name__c;
            objOpp.Affiliate_Name__c = penultimateAffiliateNameMap.get(objOpp.AccountId) != null ? penultimateAffiliateNameMap.get(objOpp.AccountId) : currentOldAffiliateNameMap.get(objOpp.AccountId);
            objOpp.Affiliated_Id__c = penultimateAffiliatedIdMap.get(objOpp.AccountId) != null ? penultimateAffiliatedIdMap.get(objOpp.AccountId) : currentOldAffiliatedIdMap.get(objOpp.AccountId);
            
            if(objOpp.Base_Price__c > 100.00 && oppStageChangedMap.get(objOpp.Id) == null && !validPaymentPostedInTheLast30Days.containsKey(objOpp.Id)){
                Date downDepositPaymentDate = null;
                Date lastPartialPaymentDate = null;
                DateTime lastPaymentDate = null;
                Id downDepositPaymentId;
                Map<Id,Payment__c> partialPayments = new Map<Id,Payment__c>();
                
                if(objOpp.Payments__r == null || objOpp.Payments__r.size() == 0) {            
                    if(Date.valueOf(String.valueOf(objOpp.CreatedDate).substring(0, 10)).addDays(24) < System.Today()) {
                        objOpp.Product_Summary__c = 'no payments';
                        opportunitiesToDowngrade.add(objOpp);
                    }
                } else {
                    for(Payment__c pay : objOpp.Payments__r) {
                        lastPaymentDate = pay.CreatedDate;
                        if(pay.Payment_Amount__c == objOpp.Down_Deposit__c && downDepositPaymentDate == null) {
                            downDepositPaymentDate = Date.valueOf(String.valueOf(pay.CreatedDate).substring(0, 10));
                            downDepositPaymentId = pay.Id;
                        }
                        if(downDepositPaymentDate != null) {
                            if(pay.Id != downDepositPaymentId && pay.Payment_Amount__c == objOpp.Monthly_Payment__c) {
                                partialPayments.put(pay.Id, pay);
                                lastPartialPaymentDate = Date.valueOf(String.valueOf(pay.CreatedDate).substring(0, 10));
                            }
                        }
                    }
                    objOpp.Opportunity_Closed_Date__c = lastPaymentDate;
                    if(downDepositPaymentDate != null && (partialPayments == null || partialPayments.size() == 0)) {
                        if(downDepositPaymentDate.addMonths(1).addDays(24) < System.Today()) {
                            objOpp.Product_Summary__c = 'no partial payments - only down deposit';
                            opportunitiesToDowngrade.add(objOpp);
                        }
                    }
                    
                    if(downDepositPaymentDate != null && partialPayments != null && partialPayments.size() > 0) {
                        List<Date> expectedPartialPaymentDates = new List<Date>();
                        Date paymentDueDate = null;
                        for (Integer i = 1 ; i <= (Integer.valueOf(objOpp.Number_of_Payments__c)-1) ; i++) {
                            System.debug('i = '+i);
                            System.debug('Integer.valueOf(objOpp.Number_of_Payments__c) = '+Integer.valueOf(objOpp.Number_of_Payments__c));
                            if(downDepositPaymentDate.addMonths(i) < System.today()){
                                System.debug('downDepositPaymentDate.addMonths(i) = '+downDepositPaymentDate.addMonths(i));
                                expectedPartialPaymentDates.add(downDepositPaymentDate.addMonths(i));
                            } 
                            if(paymentDueDate == null && ((downDepositPaymentDate.addMonths(i) >= System.today()) || i == (Integer.valueOf(objOpp.Number_of_Payments__c)-1))){
                                System.debug('else if entered = '+i);
                                paymentDueDate = downDepositPaymentDate.addMonths(i);
                            }
                        }
                        System.debug('expectedPartialPaymentDates = '+expectedPartialPaymentDates);
                        System.debug('partialPayments = '+partialPayments);
                        System.debug('paymentDueDate = '+paymentDueDate);
                        
                        Decimal currentExpectedTotalAmountPaid = objOpp.Down_Deposit__c+(expectedPartialPaymentDates.size()*objOpp.Monthly_Payment__c);
                        System.debug('currentExpectedTotalAmountPaid = '+currentExpectedTotalAmountPaid);
                        System.debug('objOpp.Total_Amount_Paid__c = '+objOpp.Total_Amount_Paid__c);                        
                        
                        if(expectedPartialPaymentDates.size() > partialPayments.size() && (currentExpectedTotalAmountPaid - objOpp.Total_Amount_Paid__c > 100) && paymentDueDate.addDays(24) < System.Today()) {
                            objOpp.Product_Summary__c = '['+partialPayments.size()+' partial payments] - '+String.valueOf(partialPayments);
                            opportunitiesToDowngrade.add(objOpp);
                        }
                        //2025-03-21 - lastPartialPaymentDate.addMonths(1).addDays(24) < System.Today() added to fix edge cases
                        else if(expectedPartialPaymentDates.size() > partialPayments.size() && lastPartialPaymentDate != null)
                        {
                            if(lastPartialPaymentDate.addMonths(1).addDays(24) < System.Today() && (currentExpectedTotalAmountPaid - objOpp.Total_Amount_Paid__c > 100))
                            {
                                //no payment posted 24 days after Last Payment Due Date + 24 days
                                opportunitiesToDowngrade.add(objOpp);
                            }
                        }
                        
                    }
                }
            }            
        }
        system.debug('opportunitiesToDowngrade = '+opportunitiesToDowngrade);
        String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
        for(Opportunity opp : opportunitiesToDowngrade)
        {            
            opp.Program__c = baseUrl + '/' + opp.Id;            
        }
        return opportunitiesToDowngrade;
    }
}