global class DeleteRecordBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        date d = date.today().addDays(-2);
        
        String query = 'SELECT Id FROM Deleted_Record__c where Created_Date__c = :d';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Deleted_Record__c> recList) {
        
        delete recList;
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}