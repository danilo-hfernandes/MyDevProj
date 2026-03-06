global with sharing class GetDepositsByDaysAfterTRP {
 
    global class InputWrapper {
        @InvocableVariable(required=true)
        public Integer DaysAfterTRPComplete;
    }
     
/*      
    global class DepositWrapper {
        @AuraEnabled @InvocableVariable(label='Account Id')
        public Id accountId;
        
        @AuraEnabled @InvocableVariable(label='Account Phone')
        public String accountPhone;
        
        @AuraEnabled @InvocableVariable(label='Case Id')
        public Id caseId;
        
        @AuraEnabled @InvocableVariable(label='Deposit Id')
        public Id depositId;
    }
*/
    
    @InvocableMethod(label='Get Deposits by Days After TRP Complete')
    //global static List<DepositWrapper> getDeposits(List<InputWrapper> inputs) {
    global static List<List<DepositWrapper>> getDeposits(List<InputWrapper> inputs) {

        Integer daysAfter = inputs[0].DaysAfterTRPComplete;
        Date today = Date.today();
		Date todayDate = System.today();
		DateTime startOfDayToday = DateTime.newInstance(todayDate, Time.newInstance(0, 0, 0, 0));
        
        List<Deposits__c> allDeposits = [
            SELECT Id,
                   Account_Name__r.Id,
                   Account_Name__r.Formatted_Phone__c,
                   Account_Name__r.Membership_Status__c,
                   Account_Name__r.MFProtection__c,
                   Account_Name__r.Formatted_Phone_Number__c,
                   Deposit_Approved_On__c,
                   Status__c,
                   Case__r.Id,
                   Case__r.Status,
                   Case__r.Case_Type__c,
                   Case__r.Exchange_Type__c,
                   Case__r.Record_Type_Developer_Name__c,
                   Case__r.CreatedDate
            FROM Deposits__c
            WHERE Account_Name__r.Membership_Status__c = 'Active'
              AND Account_Name__r.MFProtection__c = true
              AND Case__r.Record_Type_Developer_Name__c = 'Exchanges_and_Deposits'
              AND Case__r.Exchange_Type__c = 'Maintenance Fee Protection'
              AND Status__c = 'Approved'
              AND Case__r.Status IN ('TRP Completed','Exported to Inventory')
              AND (SMS_Campaign_Last_Sent__c = null
                  OR SMS_Campaign_Last_Sent__c < :startOfDayToday)
        ];

        Map<Id, Deposits__c> caseIdToDeposit = new Map<Id, Deposits__c>();
        Set<Id> caseIds = new Set<Id>();

        for (Deposits__c dep : allDeposits) {
            if (dep.Case__r != null && dep.Account_Name__r != null) {
                caseIds.add(dep.Case__r.Id);
                caseIdToDeposit.put(dep.Case__r.Id, dep);
            }
        }

        Map<Id, Date> caseIdToStatusChangeDate = new Map<Id, Date>();
        List<CaseHistory> histories = [
            SELECT CaseId, OldValue, NewValue, CreatedDate
            FROM CaseHistory
            WHERE CaseId IN :caseIds AND Field = 'Status'
        ];

        for (CaseHistory hist : histories) {
            if ((hist.NewValue == 'TRP Completed' || hist.NewValue == 'Exported to Inventory') &&
                !caseIdToStatusChangeDate.containsKey(hist.CaseId)) {
                caseIdToStatusChangeDate.put(hist.CaseId, hist.CreatedDate.date());
            }
        }

        List<DepositWrapper> results = new List<DepositWrapper>();
		
        Boolean isSaturday = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('u') == '6';
        Boolean isSunday = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('u') == '0';
        Boolean isMonday = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('u') == '1';
        
        for (Deposits__c dep : allDeposits) {
            Id caseId = dep.Case__r.Id;
            Date statusDate = caseIdToStatusChangeDate.containsKey(caseId)
                ? caseIdToStatusChangeDate.get(caseId)
                : dep.Case__r.CreatedDate.date();

            Integer daysElapsed = statusDate.daysBetween(today);
            if (
                (daysElapsed == daysAfter || 
                    isMonday == True && (
                                        daysElapsed == (daysAfter + 1) //take records that would be taken on Sundays
                                        || daysElapsed == (daysAfter + 2) //take records that would be taken on Saturdays
					                    )
                )
                && !isSaturday  //don't add records on Saturdays
                && !isSunday  //don't add records on Sundays
                
               ) {

                DepositWrapper dw = new DepositWrapper();
                dw.depositId = dep.Id;
                dw.accountId = dep.Account_Name__r.Id;
                dw.accountPhone = dep.Account_Name__r.Formatted_Phone__c;
                dw.accountFormattedPhone = dep.Account_Name__r.Formatted_Phone_Number__c;
                dw.caseId = caseId;
                results.add(dw);
            }
        }

        //return results;
		return new List<List<DepositWrapper>> { results };

    
    }
}