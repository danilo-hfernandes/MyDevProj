@isTest
public class FiletrackerReservationsTest {
    static testMethod void testBatchJob() {
        String recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Filetracker Reservations').getRecordTypeId();
        // Create test data
        List<Lead> testLeads = new List<Lead>();
            Lead testLead = new Lead(
                LastName = 'Test Lead ',
                LeadSource = 'Filetracker Daily Load',
                Status = 'New',
                Email = 'test@gmail.com',
                Phone = '9874563',
                Company='Test Company',
                OwnerId = UserInfo.getUserId(),
                RecordTypeId = recordTypeId
            );
            testLeads.add(testLead);
        insert testLeads;

         // Instantiate the batch job
        FiletrackerReservationsBatchController batchJob = new FiletrackerReservationsBatchController();

        // Execute the batch job
        database.executebatch(batchJob, 1);
       
    }
}