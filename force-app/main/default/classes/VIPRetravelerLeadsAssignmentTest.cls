@isTest
public class VIPRetravelerLeadsAssignmentTest {
    static testMethod void testBatchJob() {
        // Create test data
        List<Lead> testLeads = new List<Lead>();
            Lead testLead = new Lead(
                LastName = 'Test Lead ',
                LeadSource = 'Vacation VIP Retraveler',
                Status = 'New',
                Email = 'test@gmail.com',
                Phone = '9874563',
                Company='Test Company',
                OwnerId = UserInfo.getUserId()
            );
            testLeads.add(testLead);
        insert testLeads;

        // Create a set of lead Ids for the batch
        Set<Id> leadIds = new Set<Id>();
        for (Lead testLead1 : testLeads) {
            leadIds.add(testLead1.Id);
        }
		Test.setMock(HttpCalloutMock.class, new AssignContactInOverflowCadenceTestMock()); 
        // Instantiate the batch job
        VIPRetravelerLeadsAssignmentController batchJob = new VIPRetravelerLeadsAssignmentController(leadIds);

        // Execute the batch job
        database.executebatch(batchJob, 1);

        // Query the updated leads and verify changes
        List<Lead> updatedLeads = [SELECT Match_Group_Name__c, Assign_to_Sales_Cadence__c FROM Lead WHERE Id IN :leadIds];
       
    }
}