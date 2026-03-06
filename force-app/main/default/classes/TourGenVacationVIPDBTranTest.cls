@isTest
public class TourGenVacationVIPDBTranTest {
    static testMethod void testBatchJob() {
        // Create test data
        List<Lead> testLeads = new List<Lead>();
            Lead testLead = new Lead(
                LastName = 'Test Lead',
                LeadSource = 'Vacation VIP DB Transition',
                Status = 'New',
                Email = 'test@gmail.com',
                Phone = '9874563',
                Company='Test Company',
                VIP_Offer_Date__c = System.today(),
                Marketing_Email_opt_out__c = false
            );
            testLeads.add(testLead);
        insert testLeads;

        // Instantiate the Schedulable class
        TourGenVacationVIPDBTranBatchController schedulableJob = new TourGenVacationVIPDBTranBatchController();

        // Execute the scheduled job
        Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock()); 
        Test.startTest();
        schedulableJob.execute(null);
        Test.stopTest();

    }
}