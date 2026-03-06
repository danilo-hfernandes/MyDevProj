global class ExchangeAndDepositAPIScheduler implements Schedulable {
   global void execute(SchedulableContext SC) {
      ExchangeAndDepositAPI.getSourceList(); 
   }
}