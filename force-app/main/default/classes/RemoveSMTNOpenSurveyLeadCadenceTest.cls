@isTest
public class RemoveSMTNOpenSurveyLeadCadenceTest {
    static testMethod void testScheduledJob() {
        // Create test data
        List<Lead> testLeads = new List<Lead>();
            Lead testLead = new Lead(
                LastName = 'Test Lead ',
                LeadSource = 'SMTN Open Survey',
                Status = 'Closed Won', // Status other than 'New'
                Email = 'test@gmail.com',
                Phone = '9874563',
                Company='Test Company',
                OwnerId = UserInfo.getUserId(),
                Assign_to_Sales_Cadence__c = true, // Set to true for testing
                First_Action_Cadence_Id__c = 'Test Id' // Set to a value for testing
            );
            testLeads.add(testLead);
        insert testLeads;

        // Instantiate the Schedulable class
        RemoveSMTNOpenSurveyLeadCadenceBatch schedulableJob = new RemoveSMTNOpenSurveyLeadCadenceBatch();

        // Execute the scheduled job
        Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock()); 
        Test.startTest();
        schedulableJob.execute(null);
        Test.stopTest();

    }
}