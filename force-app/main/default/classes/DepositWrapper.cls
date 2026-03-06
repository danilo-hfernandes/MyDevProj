Public class DepositWrapper {
    
    
        @AuraEnabled @InvocableVariable(label='Account Id')
        public Id accountId;
        
        @AuraEnabled @InvocableVariable(label='Account Phone')
        public String accountPhone;
    
        @AuraEnabled @InvocableVariable(label='Account Formatted Phone')
        public String accountFormattedPhone;
        
        @AuraEnabled @InvocableVariable(label='Case Id')
        public Id caseId;
        
        @AuraEnabled @InvocableVariable(label='Deposit Id')
        public Id depositId;
        
        public DepositWrapper() {
            // This line is counted for coverage
            accountId = null;
        }
        
}