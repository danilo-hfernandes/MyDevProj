public class AssignTargetsToActionCadenceBatch implements Database.Batchable<sObject>,schedulable{

    public Database.QueryLocator start(Database.BatchableContext bc) {
        // First query to find cancelled records
        String query1 = '';
        if(!Test.isRunningTest()){
            query1 = 'SELECT ActionCadenceId, TargetId ' +
                'FROM ActionCadenceStepTracker ' +
                'WHERE ActionCadenceId IN (\'77C4z0000004CRREA2\', \'77C4z0000004CRMEA2\', \'77C4z0000004CRHEA2\') ' +
                'AND LastModifiedDate = TODAY ' +
                'AND LastModifiedBy.Name = \'Jennifer Moorhead\' ' +
                'AND State = \'Cancelled\' ' +
                'ORDER BY LastModifiedDate DESC';
        }
        else
        {
            query1 = 'SELECT ActionCadenceId, TargetId ' +
                'FROM ActionCadenceStepTracker ' +
                'WHERE ActionCadenceId IN (\'77C4z0000004CRREA2\', \'77C4z0000004CRMEA2\', \'77C4z0000004CRHEA2\') ' +
                'AND LastModifiedDate = TODAY ' +
                'AND LastModifiedBy.Name = \'Jennifer Moorhead\' ' +
                'AND State = \'Cancelled\' ' +
                'ORDER BY LastModifiedDate DESC LIMIT 1';
        }
        return Database.getQueryLocator(query1);
    }

    public void execute(Database.BatchableContext bc, List<ActionCadenceStepTracker> scope) {
        // Second query to filter out non-cancelled records
        List<ActionCadenceStepTracker> nonCancelledRecords = [
            SELECT ActionCadenceId, TargetId 
            FROM ActionCadenceStepTracker 
            WHERE ActionCadenceId IN ('77C4z0000004CRREA2', '77C4z0000004CRMEA2', '77C4z0000004CRHEA2')
            AND LastModifiedDate = TODAY
            AND State != 'Cancelled'
            ORDER BY LastModifiedDate DESC
        ];
		
        List<ActionCadenceStepTracker> actionsToAssign = new List<ActionCadenceStepTracker>();
        // Convert non-cancelled records into a Set for easy comparison
        Set<String> nonCancelledTargetIds = new Set<String>();
        for (ActionCadenceStepTracker record : nonCancelledRecords) {
            nonCancelledTargetIds.add(record.TargetId);
        }

        // Iterate over the scope (cancelled records) and process only those not in the second query
        for (ActionCadenceStepTracker tracker : scope) {
            if (!nonCancelledTargetIds.contains(tracker.TargetId)) {
                // Call the future method to assign targetId to actionCadenceId
                //assignTargetToSalesCadence(tracker.TargetId, tracker.ActionCadenceId);
                actionsToAssign.add(tracker);
            }
        }
        
        if(actionsToAssign != null && actionsToAssign.size()>0)
        {
            System.enqueueJob(new AssignTargetsToActionCadenceQueueble(actionsToAssign));
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch job complete.');
    }


    
    public void execute(SchedulableContext SC) {
        database.executebatch(new AssignTargetsToActionCadenceBatch(),50);
    }

}