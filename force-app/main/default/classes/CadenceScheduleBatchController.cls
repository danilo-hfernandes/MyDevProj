public class CadenceScheduleBatchController implements Database.Batchable<SObject>, Schedulable {
    private String query;
    private String objectName;
    private String matchGroupName;
    private String cadenceName;
    
    public CadenceScheduleBatchController() {}
    
    public CadenceScheduleBatchController(String query, String objectName, String matchGroupName, String cadenceName) {
        this.query = query;
        this.objectName = objectName;
        this.matchGroupName = matchGroupName;
        this.cadenceName = cadenceName;
    }
    
    // Batch Start Method
    public Database.QueryLocator start(Database.BatchableContext BC) {
        if (String.isEmpty(query)) {
            System.debug('No valid query found for batch execution.');
            return Database.getQueryLocator('SELECT Id FROM Account WHERE Id = null'); // Empty query as fallback
        }
        return Database.getQueryLocator(query);
    }
    
    // Batch Execute Method
    public void execute(Database.BatchableContext BC, List<SObject> records) {
        List<SObject> recordsToUpdate = new List<SObject>();
        Set<ID> recordIds = new set<Id>();
        for (SObject record : records) {
            System.debug('Processing record: ' + record);
            record.put('leadassist__Use_Round_Robin__c', 'TRUE');
            record.put('Assign_to_Sales_Cadence__c', true);
            record.put('Match_Group_Name__c', matchGroupName);
            record.put('Cadence_Flag__c', 1);
            recordsToUpdate.add(record);
            recordIds.add((ID)record.get('Id'));
        }
        // Update records in bulk
        if (!recordsToUpdate.isEmpty()) {
            try {
                update recordsToUpdate;
                System.enqueueJob(new GenericAssignToSalesCadence(recordIds, cadenceName)); 
                System.debug('Updated ' + recordsToUpdate.size() + ' records successfully.');
            } catch (Exception e) {
                System.debug('Error updating records: ' + e.getMessage());
            }
        }
    }
    
    // Batch Finish Method
    public void finish(Database.BatchableContext BC) {
        System.debug('Batch job completed successfully.');
    }
    
    // Implementing Schedulable to run from a scheduled job
    public void execute(SchedulableContext SC) {
        List<Cadence_Schedule__c> schedules = [SELECT Id,Name, Filter_Declarations__c,Filter_Logic__c,Match_Group_Name__c,Object_Name__c,Cadence_Name__c FROM Cadence_Schedule__c WHERE Active__c = TRUE];
        for (Cadence_Schedule__c schedule : schedules) {
            if (schedule.Filter_Declarations__c != null) {
                String whereClause = CadenceSchedularHandler.buildWhereClause(schedule.Filter_Declarations__c , schedule.Filter_Logic__c); 
                System.debug('>>>whereClause>'+whereClause);
                String query = 'Select id,Match_Group_Name__c,leadassist__Use_Round_Robin__c,Cadence_Flag__c,Assign_to_Sales_Cadence__c from '+schedule.Object_Name__c+ ' Where '+whereClause;
                System.debug('>>>query>>>'+query);
                System.scheduleBatch(new CadenceScheduleBatchController(query,schedule.Object_Name__c, schedule.Match_Group_Name__c, schedule.Cadence_Name__c ), 'Batch_' + schedule.Name, 1);
            }
        }
    }
}