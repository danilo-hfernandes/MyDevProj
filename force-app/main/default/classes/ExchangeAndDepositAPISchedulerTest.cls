@isTest
public class ExchangeAndDepositAPISchedulerTest {
	@isTest
    static void test1() {
        Test.setMock(HttpCalloutMock.class, new MockExchangeAndDepositAPI());
        ExchangeAndDepositAPIScheduler sc = new ExchangeAndDepositAPIScheduler();
        string cronExp = '0 0 22 * * ? *';
        string JobId = system.schedule('Exchange and Deposit API', cronExp, sc);
        ExchangeAndDepositAPI.getSourceList();
    }
}