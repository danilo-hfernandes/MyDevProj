global class PastDueMUOpportunitiesDowngradeBatch implements Database.Batchable<sObject>, Schedulable {
    
    global Date next25Days;
    
    global PastDueMUOpportunitiesDowngradeBatch(){
        //future60Days = Date.today().addDays(60);
        next25Days = Date.today().addDays(25);
    }
    
    global void execute(SchedulableContext SC) {
        PastDueMUOpportunitiesDowngradeBatch objBatch = new PastDueMUOpportunitiesDowngradeBatch(); 
        database.executebatch(objBatch, 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        //list<String> oppIds = System.Label.PastDueMUOpportunitiesDowngradeBatch.split(',');   
		//list<String> oppIds = new list<String>{'006O1000007twYnIAI','0063t00000yzWSUAA2'};      
        String query = 'SELECT Id,AccountId,Account.Contact_Id__c,CreatedDate,Down_Deposit__c,Number_of_Payments__c,Monthly_Payment__c,Total_Amount__c,Total_Amount_Paid__c,Total_Refund__c, (SELECT Id,CreatedDate,Payment_Amount__c FROM Payments__r WHERE Payment_Amount__c > 0 ORDER BY CreatedDate ASC) '; 
        query = query + 'FROM Opportunity WHERE (Payment_Type__c = \'Single Credit Card - With PP\' OR Payment_Type__c = \'30% Down - PP\') AND StageName = \'Closed Won\' AND Down_Deposit__c > 0 ';
        query = query + 'AND RecordType.DeveloperName IN (\'SFX_Membership\',\'Hawaii_Collection_Membership\',\'Membership_Upgrade\',\'MTRC_Retail\')';
        
        /*if(Test.IsRunningTest())
        {
            query = query + ' LIMIT 1';
        }
        else{
            query = query + ' AND Id IN :oppIds';
        }*/
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    //update Opportunity Stage to Closed Lost-Balance (new stage)
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        List<String> errorLog = new List<String>();
        Map<Id,Opportunity> allOpps = new Map<Id,Opportunity>();
		Map<Id,Integer> oppAccountContactId = new Map<Id,Integer>();
        Map<Id,Boolean> validPaymentPostedInTheLast30Days = new Map<Id,Boolean>();
        List<Opportunity> opportunitiesToDowngrade = new List<Opportunity>();
		Map<Id, String> oppStageChangedMap = new Map<Id, String>();
        // Step 1: Build a Set<Id> from the List<Opportunity>
        Set<Id> oppIdSet = new Set<Id>();
        for (Opportunity opp : scope) {
            oppIdSet.add(opp.Id);
            oppStageChangedMap.put(opp.Id, null);
        }
        System.debug('>>>>oppIdSet>>>>'+oppIdSet);
        System.debug('>>>>oppStageChangedMap>>>>'+oppStageChangedMap);
        // Step 2: Query OpportunityFieldHistory for StageName changes (no filtering on NewValue here)
        List<OpportunityFieldHistory> oppHistoryList = [
            SELECT OpportunityId, OldValue, NewValue 
            FROM OpportunityFieldHistory 
            WHERE Field = 'StageName'
            AND OpportunityId IN :oppIdSet
        ];
        System.debug('>>>>oppHistoryList>>>>'+oppHistoryList);
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        
        // Step 3: Create a Map<Id, String> to track the opps where StageName was changed to 'Closed Lost-Balance'
        
        for (OpportunityFieldHistory history : oppHistoryList) {
            // Filter in Apex to check if NewValue is 'Closed Lost-Balance'
            if (String.valueOf(history.NewValue) == 'Closed Lost-Balance') {// && !runningInASandbox
                oppStageChangedMap.put(history.OpportunityId, String.valueOf(history.NewValue));
            }
        }
        system.debug('>>>>oppStageChangedMap>>>>'+oppStageChangedMap);
        Date firstDayLastMonth = Date.today().addMonths(-1).toStartOfMonth();
		System.debug('>>>>firstDayLastMonth>>>'+firstDayLastMonth);
        for(Opportunity objOpp : scope){
            System.debug('>>objOpp.Payments__r.size()>>'+objOpp.Payments__r.size());
            //Date.valueOf(String.valueOf(objOpp.CreatedDate).substring(0, 10))
            if(objOpp.Payments__r != null || objOpp.Payments__r.size() != 0){
                for(Payment__c py : objOpp.Payments__r) {
                    System.debug('>>>>Date.valueOf(String.valueOf(py.CreatedDate).substring(0, 10)).>>'+Date.valueOf(String.valueOf(py.CreatedDate).substring(0, 10)));
                    if(Date.valueOf(String.valueOf(py.CreatedDate).substring(0, 10)) >= firstDayLastMonth && py.Payment_Amount__c > 1.00)
                    {
                        validPaymentPostedInTheLast30Days.put(objOpp.Id,true);
                    }
                }
            }            
        }
        system.debug('>>>>>validPaymentPostedInTheLast30Days>>>'+validPaymentPostedInTheLast30Days);
        system.debug('>>>scope>>>'+scope);
        for(Opportunity objOpp : scope){
            //BalanceCheck = (Total Amount - (Paid - Refund))
            Decimal BalanceCheck = objOpp.Total_Amount__c - (objOpp.Total_Amount_Paid__c - objOpp.Total_Refund__c);
			System.debug('>>>>BalanceCheck>>>>'+BalanceCheck);
            if(BalanceCheck > 100.00 && oppStageChangedMap.get(objOpp.Id) == null && !validPaymentPostedInTheLast30Days.containsKey(objOpp.Id)){
                
                allOpps.put(objOpp.Id,objOpp);
                Date downDepositPaymentDate = null;
                Date lastPartialPaymentDate = null;            
                Id downDepositPaymentId;
                Map<Id,Payment__c> partialPayments = new Map<Id,Payment__c>();
                if(objOpp.Payments__r == null || objOpp.Payments__r.size() == 0)
                {            
                    if(Date.valueOf(String.valueOf(objOpp.CreatedDate).substring(0, 10)).addDays(24) < System.Today())
                    {
                        System.debug('>>Date.valueOf(String.valueOf(objOpp.CreatedDate).substring(0, 10)).addDays(24)>>>'+Date.valueOf(String.valueOf(objOpp.CreatedDate).substring(0, 10)).addDays(24));
                        //no payment posted 24 days after (Payment Due Date = 24 days after opportunity creation)
                        opportunitiesToDowngrade.add(objOpp);
                    }
                }
                else{
                    for(Payment__c pay : objOpp.Payments__r)
                    {                    
                        if(pay.Payment_Amount__c == objOpp.Down_Deposit__c && downDepositPaymentDate == null)
                        {
                            downDepositPaymentDate = Date.valueOf(String.valueOf(pay.CreatedDate).substring(0, 10));
                            downDepositPaymentId = pay.Id;
                        }
                        System.debug('>>>>downDepositPaymentDate>>>'+downDepositPaymentDate);
                        System.debug('>>>>downDepositPaymentId>>>'+downDepositPaymentId);
                        if(downDepositPaymentDate != null)
                        {
                            if(pay.Id != downDepositPaymentId && pay.Payment_Amount__c == objOpp.Monthly_Payment__c)
                            {
                                partialPayments.put(pay.Id,pay);
                                lastPartialPaymentDate = Date.valueOf(String.valueOf(pay.CreatedDate).substring(0, 10));
                            }
                            System.debug('>>>>partialPayments>>>'+partialPayments);
                       		System.debug('>>>>lastPartialPaymentDate>>>'+lastPartialPaymentDate);
                        }
                    }
                    
                    if(downDepositPaymentDate != null && (partialPayments == null || partialPayments.size() == 0))
                    {
                        if(downDepositPaymentDate.addMonths(1).addDays(24) < System.Today())
                        {
                            //no payment posted 24 days after (Payment Due Date = 1 month + 24 days after Down Deposit Payment Date)
                            opportunitiesToDowngrade.add(objOpp);
                        }
                    }
                    if(downDepositPaymentDate != null && partialPayments != null && partialPayments.size() > 0)
                    {
                        List<Date> expectedPartialPaymentDates = new List<Date>();
                        Date paymentDueDate = null;
                        for (Integer i = 1 ; i <= (Integer.valueOf(objOpp.Number_of_Payments__c)-1) ; i++)
                        {
                            if(downDepositPaymentDate.addMonths(i) < System.today()){
                                expectedPartialPaymentDates.add(downDepositPaymentDate.addMonths(i));
                            }
                            if(paymentDueDate == null && ((downDepositPaymentDate.addMonths(i) >= System.today()) || i == (Integer.valueOf(objOpp.Number_of_Payments__c)-1)))
                            {
                                paymentDueDate = downDepositPaymentDate.addMonths(i);
                            }
                        }                        
                        
                        Decimal currentExpectedTotalAmountPaid = objOpp.Down_Deposit__c+(expectedPartialPaymentDates.size()*objOpp.Monthly_Payment__c);
                        System.debug('currentExpectedTotalAmountPaid = '+currentExpectedTotalAmountPaid);
                        System.debug('objOpp.Total_Amount_Paid__c = '+objOpp.Total_Amount_Paid__c);
                        
                        if(expectedPartialPaymentDates.size() > partialPayments.size() && (currentExpectedTotalAmountPaid - objOpp.Total_Amount_Paid__c > 100) && paymentDueDate.addDays(24) < System.Today())
                        {
                            //no payment posted 24 days after Payment Due Date + 24 days
                            opportunitiesToDowngrade.add(objOpp);
                        }
                        //2025-03-21 - lastPartialPaymentDate.addMonths(1).addDays(24) < System.Today() added to fix edge cases
                        else if(expectedPartialPaymentDates.size() > partialPayments.size() && (currentExpectedTotalAmountPaid - objOpp.Total_Amount_Paid__c > 100) && lastPartialPaymentDate != null)
                        {
                            if(lastPartialPaymentDate.addMonths(1).addDays(24) < System.Today())
                            {
                                //no payment posted 24 days after Last Payment Due Date + 24 days
                                opportunitiesToDowngrade.add(objOpp);
                            }
                        }
                    }
                } 
            }
        }       
		System.debug('>>>>opportunitiesToDowngrade>>>>'+opportunitiesToDowngrade);
        if(opportunitiesToDowngrade != null && opportunitiesToDowngrade.size()>0)
        {            
            for(Opportunity opp: opportunitiesToDowngrade)
            {
                opp.StageName = 'Closed Lost-Balance';
            }
            Database.SaveResult[] srList = Database.update(opportunitiesToDowngrade, false);            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    System.debug('Successfully updated opportunity. Opportunity ID: ' + sr.getId());
                    if(allOpps.get(sr.getId()).AccountId != null)
                    {
                        if(allOpps.get(sr.getId()).Account.Contact_Id__c != null)
                        {
                            
                            oppAccountContactId.put(allOpps.get(sr.getId()).AccountId,Integer.valueOf(allOpps.get(sr.getId()).Account.Contact_Id__c));
                        }
                    }
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {                        
                        errorLog.add('PastDueMUOpportunitiesDowngradeBatch error: '+err.getStatusCode()+': '+err.getMessage()+', fields that affected this error: ' + err.getFields()+';;;');
                    }
                }
            }
        }
        System.debug('>>>>oppAccountContactId>>>>'+oppAccountContactId);
        if(oppAccountContactId != null && oppAccountContactId.size()>0)
        {
            System.debug('>>>>oppAccountContactId.>>'+oppAccountContactId);
            try{
                System.enqueueJob(new PastDueMUOpportunitiesDowngradeQueueable(oppAccountContactId));
            }
            catch(Exception e)
            {                                   
                errorLog.add('PastDueMUOpportunitiesDowngradeBatch error: '+e.getMessage()+';;;');                
            }
        }
        
        if( (errorLog.size()>0 && errorLog != null) || Test.isRunningTest() )
        {
            try {
                runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                if(!runningInASandbox || Test.isRunningTest()){
                    String message = String.valueOf(errorLog);
                    system.debug('--message-'+message);
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    String[] sendingTo = new String[]{'victor.goncalves@nerdsoft.com','danilo.fernandes@nerdsoft.com','raphael.fogaca@nerdsoft.com'};
                    semail.setToAddresses(sendingTo);
                    semail.setSubject('[DOWNGRADE FAILED] PastDueOppsDowngradeDebugBatch is failed');
                    semail.setPlainTextBody(message);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                }
            } 
            catch( System.Exception e){
                System.debug('ERROR: '+ e);
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        
    }

}