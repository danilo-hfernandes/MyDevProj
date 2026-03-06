global class DeleteDataBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
                String query = 'SELECT Id FROM Uploaded_Inventory_Availability__c';
        system.debug('query--'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Uploaded_Inventory_Availability__c> caseList) {
        delete caseList;
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}