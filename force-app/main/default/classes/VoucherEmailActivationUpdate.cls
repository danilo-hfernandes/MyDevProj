public class VoucherEmailActivationUpdate implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String recordType1='Voucher';
        String stageName1='Closed Won';
        String RoundRobin='Assigned';
        String whereClause = GenericMatchGroupAssignmentHandler.addWhereClause(RoundRobin,'notEquals'); 
        String stageName2='Closed Won-Deposit';
        String matchgroup='Voucher Email';
        String query = 'SELECT Id,AccountId,name,Match_Group_Name__c,ownerid FROM Opportunity Where Record_Type_Name__c = \''+recordType1+'\'  AND (StageName=\''+stageName1+'\' OR StageName=\''+stageName2+'\') AND Check_in__c =null AND Reservation_Status__c=null AND First_Payment_Date__c > N_YEARS_AGO:2 and '+whereClause;
        system.debug('8='+query);
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<Opportunity> scope) {
        system.debug('13='+scope);
        list<Opportunity> SSROpp= new list<Opportunity>();
        /*for(Opportunity opp: scope){
            opp.Match_Group_Name__c='Voucher Email';
            opp.leadassist__Use_Round_Robin__c='TRUE';
            SSROpp.add(opp);
        }*/
        SSROpp =  GenericMatchGroupAssignmentHandler.assignMatchGroup(scope, 'Voucher Email');
        if(SSROpp.size()>0){
            update SSROpp;
        } 
    }
    public void finish(Database.BatchableContext bc) {
                database.executebatch(new VoucherEmailActivation(),1);

        //do something 
    }  
    public void execute(SchedulableContext SC) {
        database.executebatch(new VoucherEmailActivationUpdate(),1);
    }
}