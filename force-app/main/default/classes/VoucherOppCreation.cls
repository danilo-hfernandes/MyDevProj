public class VoucherOppCreation {
    @AuraEnabled 
    public static boolean isOpportunityCreated(String recordId){  
        Id voucherId = [select Id,Name,DeveloperName from RecordType where sObjectType='Opportunity' and DeveloperName  = 'Voucher'].Id;
        
        system.debug('--recordId--'+recordId);
        List<Account> accList = [SELECT Name, (SELECT Name, Amount FROM Opportunities WHERE recordTypeId =: voucherId AND CloseDate >= LAST_N_DAYS:180)
                                 FROM Account
                                 WHERE Id =:recordId];
        if(accList.size() > 0){
            for(Account acc : accList){
                List<Opportunity> oppList = acc.Opportunities;
                if(oppList.size() >= 1){
                    return false;
                }else{
                    Opportunity opp = new Opportunity();
                    Opp.Name = acc.Name+' Voucher '+system.today();
                    opp.AccountId = recordId;
                    Opp.StageName = 'New';
                    Opp.CloseDate = system.today();
                    opp.RecordTypeId = voucherId;
                    insert opp;
                    return true;
                }
            }
        }
        return true;
    }
}