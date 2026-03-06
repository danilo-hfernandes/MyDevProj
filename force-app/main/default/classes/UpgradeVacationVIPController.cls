public class UpgradeVacationVIPController {
    
    @AuraEnabled 
    public static Map<String,String> tryToUpgradeVacationVIP(String recordId){        
        
        String returnState = 'sucess';
        String returnErroMsg = '';
        Map<String,String> stateAndLog = new Map<String,String>();
        
        try{
            Id voucherId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
            Contact con = [SELECT Id,AccountId,Account.Affiliated_Id__c FROM Contact WHERE Id =: recordId];
            List<Account> accList = [SELECT Name, (SELECT Name, Amount FROM Opportunities WHERE recordTypeId =: voucherId AND CloseDate >= LAST_N_DAYS:180)
                                     FROM Account
                                     WHERE Id =: con.AccountId LIMIT 1];
            if(con.Account.Affiliated_Id__c == 1002336){
                if(accList.size() > 0 && accList != null){
                    for(Account acc : accList){
                        List<Opportunity> oppList = acc.Opportunities;
                        if(oppList.size() >= 1){
                            returnState = 'error';
                            returnErroMsg = 'Voucher Opportunity exist';
                        }else{
                            
                            Opportunity opp = new Opportunity();
                            Opp.Name = acc.Name+' Voucher '+system.today();
                            opp.AccountId = con.AccountId;
                            Opp.StageName = 'New';
                            Opp.CloseDate = system.today();
                            opp.RecordTypeId = voucherId;
                            opp.Voucher_18_Months__c = true;
                            insert opp;
                            
                            OpportunityLineItem oli = new OpportunityLineItem();
                            oli.Quantity = 1;
                            oli.OpportunityId = opp.Id;
                            oli.Product2Id = [SELECT Id FROM Product2 WHERE Name = 'Vacation VIP Membership Upgrade' LIMIT 1].Id;
                            oli.PriceBookEntryID = [SELECT Id FROM PricebookEntry WHERE Name = 'Vacation VIP Membership Upgrade' LIMIT 1].Id;
                            insert oli;
                            
                            OpportunityLineItem oli2 = new OpportunityLineItem();
                            oli2.Quantity = 1;
                            oli2.OpportunityId = opp.Id;
                            oli2.Product2Id = [SELECT Id FROM Product2 WHERE Name = 'Cruise Certificate Add-On' LIMIT 1].Id;
                            oli2.PriceBookEntryID = [SELECT Id FROM PricebookEntry WHERE Name = 'Cruise Certificate Add-On' LIMIT 1].Id;
                            insert oli2;
                            
                        }
                    }
                }
            }
            else
            {
                returnState = 'error';
                returnErroMsg = 'Affiliate Id is not 1002336';
            }
        }
        Catch(Exception e)
        {
            returnState = 'error';
            returnErroMsg = e.getMessage();
        }
        stateAndLog.put(returnState,returnErroMsg);        
        return stateAndLog;
    }
    
}