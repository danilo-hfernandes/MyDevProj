global class DeleteDataWhichNotRequiredBatch implements Database.Batchable<sObject> {
    
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String objectApi = Label.Delete_sObject_records;
        String query = 'SELECT Id FROM '+objectApi+'';
        system.debug('query--'+query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> objList) {
        system.debug('objList=== '+objList);
        system.debug('objList size=== '+objList.size());
        delete objList;
    }   
    
    
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations like sending email
    }
}