global class PastDueOppsDowngradeDebugBatch implements Database.Batchable<sObject>, Schedulable {
    
    global Date next25Days;
    
    global PastDueOppsDowngradeDebugBatch(){
        //future60Days = Date.today().addDays(60);
        next25Days = Date.today().addDays(25);
    }
    
    global void execute(SchedulableContext SC) {
        PastDueOppsDowngradeDebugBatch objBatch = new PastDueOppsDowngradeDebugBatch(); 
        database.executebatch(objBatch, 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        //list<String> oppIds = System.Label.PastDueOppsDowngradeDebugBatch.split(',');   
		//list<String> oppIds = new list<String>{'006O1000007twYnIAI','0063t00000yzWSUAA2'};      
        String query = 'SELECT Id,AccountId,Account.Contact_Id__c,CreatedDate,Down_Deposit__c,Number_of_Payments__c,Monthly_Payment__c,Total_Amount__c,Total_Amount_Paid__c,Total_Refund__c, (SELECT Id,CreatedDate,Payment_Amount__c FROM Payments__r WHERE Payment_Amount__c > 0 ORDER BY CreatedDate ASC) '; 
        query = query + 'FROM Opportunity WHERE (Payment_Type__c = \'Single Credit Card - With PP\' OR Payment_Type__c = \'30% Down - PP\') AND (StageName = \'Closed Lost-Balance\' OR StageName = \'Closed Won\') AND Down_Deposit__c > 0 ';
        query = query + 'AND RecordType.DeveloperName IN (\'SFX_Membership\',\'Hawaii_Collection_Membership\',\'Membership_Upgrade\',\'MTRC_Retail\')';
        
        Set<Id> oppIdsToVerify;
        
        if(!Test.IsRunningTest())
        {
            query = query + ' AND Account.Member_Number__c IN (\'AP-HIC-ICT23047\')';
        }
        else
        {
            //query = query + ' AND Member_Number__c IN (\'AP-HIC-INT30008\',\'AP-HIC-ICT21815\',\'AP-HIC-INTP1630\',\'AP-HIC-INT30386\')';
        }
        
        
        /*if(Test.IsRunningTest())
        {
            query = query + ' LIMIT 1';
        }
        else{
            query = query + ' AND Id IN :oppIds';
        }*/
        //system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    //update Opportunity Stage to Closed Lost-Balance (new stage)
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        List<String> errors = new List<String>();
        Map<Id,Opportunity> allOpps = new Map<Id,Opportunity>();
		Map<Id,Integer> oppAccountContactId = new Map<Id,Integer>();
        Map<Id,Boolean> validPaymentPostedInTheLast30Days = new Map<Id,Boolean>();
        List<Opportunity> opportunitiesToDowngrade = new List<Opportunity>();
		Map<Id, String> oppStageChangedMap = new Map<Id, String>();
        // Step 1: Build a Set<Id> from the List<Opportunity>
        Set<Id> oppIdSet = new Set<Id>();
        try{
        for (Opportunity opp : scope) {
            oppIdSet.add(opp.Id);
            oppStageChangedMap.put(opp.Id, null);
        }
        //System.debug('>>>>oppIdSet>>>>'+oppIdSet);
        //System.debug('>>>>oppStageChangedMap>>>>'+oppStageChangedMap);
        // Step 2: Query OpportunityFieldHistory for StageName changes (no filtering on NewValue here)
        List<OpportunityFieldHistory> oppHistoryList = [
            SELECT OpportunityId, OldValue, NewValue 
            FROM OpportunityFieldHistory 
            WHERE Field = 'StageName'
            AND OpportunityId IN :oppIdSet
        ];

        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        
        // Step 3: Create a Map<Id, String> to track the opps where StageName was changed to 'Closed Lost-Balance'
        
        for (OpportunityFieldHistory history : oppHistoryList) {
            // Filter in Apex to check if NewValue is 'Closed Lost-Balance'
            if (String.valueOf(history.NewValue) == 'Closed Lost-Balance') {// && !runningInASandbox
                oppStageChangedMap.put(history.OpportunityId, String.valueOf(history.NewValue));
            }
        }
        //system.debug('>>>>oppStageChangedMap disabled>>>>'+oppStageChangedMap);
        oppStageChangedMap = new Map<Id, String>();
        //system.debug('>>>>oppStageChangedMap cleaned>>>>'+oppStageChangedMap);
        
        Date firstDayLastMonth = Date.today().addMonths(-1).toStartOfMonth();
		//System.debug('>>>>firstDayLastMonth>>>'+firstDayLastMonth);
        for(Opportunity objOpp : scope){
            //System.debug('>>objOpp.Payments__r.size()>>'+objOpp.Payments__r.size());
            //Date.valueOf(String.valueOf(objOpp.CreatedDate).substring(0, 10))
            if(objOpp.Payments__r != null || objOpp.Payments__r.size() != 0){
                for(Payment__c py : objOpp.Payments__r) {
                    //System.debug('>>>>Date.valueOf(String.valueOf(py.CreatedDate).substring(0, 10)).>>'+Date.valueOf(String.valueOf(py.CreatedDate).substring(0, 10)));
                    if(Date.valueOf(String.valueOf(py.CreatedDate).substring(0, 10)) >= firstDayLastMonth && py.Payment_Amount__c > 1.00)
                    {
                        validPaymentPostedInTheLast30Days.put(objOpp.Id,true);
                    }
                }
            }            
        }        
        //system.debug('>>>scope>>>'+scope);
        //system.debug('>>>>>validPaymentPostedInTheLast30Days>>>'+validPaymentPostedInTheLast30Days);
        for(Opportunity objOpp : scope){
            //BalanceCheck = (Total Amount - (Paid - Refund))
            Decimal BalanceCheck = objOpp.Total_Amount__c - (objOpp.Total_Amount_Paid__c - objOpp.Total_Refund__c);			
            //System.debug('>>>>BalanceCheck>>>>'+objOpp.Id+' = '+BalanceCheck);
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
                        //System.debug('>>Date.valueOf(String.valueOf(objOpp.CreatedDate).substring(0, 10)).addDays(24)>>>'+Date.valueOf(String.valueOf(objOpp.CreatedDate).substring(0, 10)).addDays(24));
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
                        //System.debug('>>>>downDepositPaymentDate>>>'+downDepositPaymentDate);
                        //System.debug('>>>>downDepositPaymentId>>>'+downDepositPaymentId);
                        if(downDepositPaymentDate != null)
                        {
                            if(pay.Id != downDepositPaymentId && pay.Payment_Amount__c == objOpp.Monthly_Payment__c)
                            {
                                partialPayments.put(pay.Id,pay);
                                lastPartialPaymentDate = Date.valueOf(String.valueOf(pay.CreatedDate).substring(0, 10));
                            }
                            //System.debug('>>>>partialPayments>>>'+partialPayments);
                       		//System.debug('>>>>lastPartialPaymentDate>>>'+lastPartialPaymentDate);
                        }
                    }
                    
                    if(downDepositPaymentDate != null && (partialPayments == null || partialPayments.size() == 0))
                    {
                        if(downDepositPaymentDate.addMonths(1).addDays(24) < System.Today())
                        {
                            //no payment posted 24 days after (Payment Due Date = 1 month + 24 days after Down Deposit Payment Date)
                            //System.debug('>>>>no payment posted 24 days after (Payment Due Date = 1 month + 24 days after Down Deposit Payment Date)>>>>'+objOpp.Id+' = '+downDepositPaymentDate.addMonths(1).addDays(24));
                            opportunitiesToDowngrade.add(objOpp);
                        }
                    }
                    if(downDepositPaymentDate != null && partialPayments != null && partialPayments.size() > 0)
                    {
                        List<Date> expectedPartialPaymentDates = new List<Date>();
                        Date paymentDueDate = null;
						
						// Convert once for clarity
Integer totalPayments = Integer.valueOf(objOpp.Number_of_Payments__c);
Date baseDate = downDepositPaymentDate;

//System.debug('--- CALCULATION START FOR OPP: ' + objOpp.Id + ' ---');
//System.debug('Total Payments     : ' + totalPayments);
//System.debug('Base Deposit Date  : ' + baseDate);
//System.debug('Today              : ' + System.today());

for (Integer i = 1; i <= (totalPayments - 1); i++) {

    Date candidateDate = baseDate.addMonths(i);

    /*System.debug(
        'Iteration ' + i + 
        ' | candidateDate = ' + candidateDate + 
        ' | IsPast? ' + (candidateDate < System.today())
    );*/

    // === 1. BUILD LIST OF EXPECTED PARTIAL PAYMENTS (PAST DATES) ===
    if (candidateDate < System.today()) {
        expectedPartialPaymentDates.add(candidateDate);
        //System.debug('  -> Added to expectedPartialPaymentDates');
    } else {
        //System.debug('  -> NOT added (not past)');
    }

    // === 2. CALCULATE THE UPCOMING PAYMENT DUE DATE ===
    if (paymentDueDate == null &&
        (
            candidateDate >= System.today() || 
            i == (totalPayments - 1)
        )
    ) {
        paymentDueDate = candidateDate;

        /*System.debug(
            '  *** paymentDueDate SET at iteration ' + i + 
            ' | Reason: ' + 
            (candidateDate >= System.today() ?
                'next future/ today date reached' :
                'final payment iteration fallback'
            ) +
            ' | paymentDueDate = ' + paymentDueDate
        );*/
    }
}
                        //System.debug('>>>>expectedPartialPaymentDates.size()>>>>'+objOpp.Id+' = '+expectedPartialPaymentDates.size());
                        //System.debug('>>>>partialPayments.size()>>>>'+objOpp.Id+' = '+partialPayments.size());
                        //System.debug('>>>> paymentDueDate.addDays(24))>>>>'+objOpp.Id+' = '+ paymentDueDate.addDays(24));
                        if(expectedPartialPaymentDates.size() > partialPayments.size() && paymentDueDate.addDays(24) < System.Today())
                        {
                            //System.debug('>>>> no payment posted 24 days after Payment Due Date + 24 days)>>>>'+objOpp.Id);
                            //no payment posted 24 days after Payment Due Date + 24 days
                            opportunitiesToDowngrade.add(objOpp);
                        }
                    }
                } 
            }
        }       
		//System.debug('>>>>opportunitiesToDowngrade>>>>'+opportunitiesToDowngrade);
        if(opportunitiesToDowngrade != null && opportunitiesToDowngrade.size()>0)
        {     
            //System.debug('opportunitiesToDowngrade size = '+opportunitiesToDowngrade.size());
            for(Opportunity opp: opportunitiesToDowngrade)
            {
                //System.debug('opportunityToDowngrade = '+opp);
            }            
        }
        }
        Catch(Exception e){
            String errorMsg =
                'PastDueOppsDowngradeDebugBatch FAILED\n' +
                'Exception Type: ' + e.getTypeName() + '\n' +
                'Message       : ' + e.getMessage() + '\n' +
                'StackTrace    : ' + e.getStackTraceString() + '\n' +
                'Scope Size    : ' + scope.size() + '\n' +
                'Opp Ids       : ' + new List<Id>(oppIdSet);
            
            System.debug(LoggingLevel.ERROR, errorMsg);
            errors.add(errorMsg);
            
            try {
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                if(!runningInASandbox){
                    String message = String.valueOf(errorMsg);
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    String[] sendingTo = new String[]{'victor.goncalves@nerdsoft.com','danilo.fernandes@nerdsoft.com','raphael.fogaca@nerdsoft.com'};
                    semail.setToAddresses(sendingTo);
                    semail.setSubject('[DOWNGRADE FAILED] PastDueOppsDowngradeDebugBatch is failed');
                    semail.setPlainTextBody(message);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                }
            } 
            catch( System.Exception e2){
                System.debug('ERROR: '+ e2);
            }
            
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }

}