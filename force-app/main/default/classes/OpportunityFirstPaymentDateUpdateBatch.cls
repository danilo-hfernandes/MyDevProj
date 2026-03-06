global class OpportunityFirstPaymentDateUpdateBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //string oppId = '0063t000013I2WjAAK';
        //String query = 'SELECT Id,Paid_On__c,Opportunity__c,Opportunity__r.Id,Opportunity__r.First_Payment_Date__c,Name FROM Payment__c where Opportunity__r.First_Payment_Date__c == null order by Paid_On__c desc';
        //String query = 'SELECT Id,First_Payment_Date__c,Name FROM Opportunity where First_Payment_Date__c = null and Id = \''+oppId+'\'   limit 500';
        String query = 'SELECT Id,First_Payment_Date__c,Name FROM Opportunity where First_Payment_Date__c = null ';
        
        system.debug('--query--'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> oppList) {
        Set<Id> oppListSet = new Set<Id>();
        for(Opportunity opp : oppList){
            oppListSet.add(opp.Id);
        }
        List<Opportunity> oppListNew = [select id,First_Payment_Date__c, (select id,Paid_On__c from Payments__r order by Paid_On__c desc limit 1) from Opportunity where Id In :oppListSet];
        List<Opportunity> oppListUpdate = new List<Opportunity>();
        for(Opportunity opp : oppListNew){
            List<Payment__c> paymentList = opp.Payments__r;
            if(paymentList != null && paymentList.size() > 0){
                opp.First_Payment_Date__c = paymentList[0].Paid_On__c;
                system.debug('--opp---'+opp.First_Payment_Date__c);
                oppListUpdate.add(opp);
            }
        }
        
      	 try{
             if(oppListUpdate != null && oppListUpdate.size() > 0){
                system.debug('--oppListUpdate---'+oppListUpdate.size());
                update oppListUpdate;
         }
        }catch(exception e){
            system.debug('--e---'+e);
        } 
        
        
         
        
    }   
    
    global void finish(Database.BatchableContext BC) {
          
    }
}