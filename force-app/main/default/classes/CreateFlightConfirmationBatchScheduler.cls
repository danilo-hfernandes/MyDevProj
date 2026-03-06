global class CreateFlightConfirmationBatchScheduler implements schedulable{
    global void execute(SchedulableContext sc){
        CreateFlightConfirmationCaseBatch b = new CreateFlightConfirmationCaseBatch();
        if(!Test.isRunningTest()){
            database.executebatch(b, 1);
        }
        else{
            database.executebatch(b);
        }
    }
}