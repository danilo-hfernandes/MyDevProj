global class DeleteRecordBatchScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      DeleteRecordBatch b = new DeleteRecordBatch(); 
      Database.executeBatch(b);
   }
}