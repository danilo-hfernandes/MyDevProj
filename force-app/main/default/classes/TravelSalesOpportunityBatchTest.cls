@isTest
public class TravelSalesOpportunityBatchTest {

    @isTest static void test() {
        
        Id travelRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();

        Account acc = new Account();
        acc.Name = 'Test Name';
        acc.Member_Number__c = 'test';
        insert acc;
        
		Opportunity opp = new Opportunity();
        opp.Name = 'Travel Sales Opp';
        opp.StageName = 'New';
        opp.CloseDate = Date.today()+1;
        opp.Member_Number__c = 'test';
        opp.RecordTypeId = travelRecordTypeId;
        insert opp;
        
        Test.startTest();
        TravelSalesOpportunityBatchController oppBatch = new TravelSalesOpportunityBatchController();
        Id batchId = Database.executeBatch(oppBatch);
        Test.stopTest();
    }
}