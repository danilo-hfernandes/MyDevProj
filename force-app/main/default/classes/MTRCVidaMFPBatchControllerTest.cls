@isTest
private class MTRCVidaMFPBatchControllerTest {
    
    @isTest static void testExecute() {
        
        // Create test data
        Account testAccount = new Account(
            Name = 'Test Account',
            Affiliated_id__c = 1002409,
            enrollment_date__c = Date.today().addDays(-10)
        );
        insert testAccount;
        Id oppRecordTypeId = [Select id from RecordType where sObjectType = 'Opportunity' and developerName ='MTRC_Retail'].id ;
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'New',
            CloseDate = System.today(),
            AccountId = testAccount.Id,
            OwnerId = UserInfo.getUserId(),
            Match_Group_Name__c = 'Other Value',
			RecordTypeId = oppRecordTypeId
        );
        insert testOpportunity;
        
        // Create instance of batchable class
        MTRCVidaMFPBatchController batch = new MTRCVidaMFPBatchController();
		        
        // Execute batch job
        Test.startTest();
        Id batchJobId = Database.executeBatch(batch);
        MTRCVidaMFPBatchController m = new MTRCVidaMFPBatchController();
        String sch = '20 30 8 10 2 ?';
        String jobID = System.schedule('Test job', sch, m);
        Test.stopTest();
        
        // Retrieve updated Opportunity record
        Opportunity updatedOpp = [SELECT Id, Match_Group_Name__c FROM Opportunity WHERE Id = :testOpportunity.Id];
     }
    
}