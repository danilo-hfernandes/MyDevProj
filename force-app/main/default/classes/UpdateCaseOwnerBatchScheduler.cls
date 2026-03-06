global class UpdateCaseOwnerBatchScheduler implements schedulable{
    global void execute(SchedulableContext sc){
        UpdateCaseOwnerBatch b = new UpdateCaseOwnerBatch();
        database.executebatch(b);
    }
}