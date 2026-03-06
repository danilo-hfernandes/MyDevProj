@isTest
public class VIPRetravelerLeadsRemovableTest {
    static testMethod void testScheduledJob() {
        // Create test data
        List<Lead> testLeads = new List<Lead>();
            Lead testLead = new Lead(
                LastName = 'Test Lead ',
                LeadSource = 'Vacation VIP Retraveler',
                Status = 'Not New', // Status other than 'New'
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
        VIPRetravelerLeadsRemovableController schedulableJob = new VIPRetravelerLeadsRemovableController();

        // Execute the scheduled job
        Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock()); 
        Test.startTest();
        schedulableJob.execute(null);
        Test.stopTest();

        // Query the updated leads and verify changes
        List<Lead> updatedLeads = [SELECT Status, OwnerId, Assign_to_Sales_Cadence__c, First_Action_Cadence_Id__c FROM Lead WHERE Id IN :testLeads];

    }
}