@isTest
public class OppLineItemProductSummaryTriggerTest {
    @isTest
    static void testProductSummary() {
        Apex_Trigger_On_Off__c cp = new Apex_Trigger_On_Off__c();
        cp.name = 'OppLineItemProductSummaryTrigger';
        cp.isEnable__c = true;
        insert cp;
        // Create test products
        Product2 product1 = new Product2(Name = 'Test Product 1');
        insert product1;

        Product2 product2 = new Product2(Name = 'Test Product 2');
        insert product2;

        // Create standard price entries
        PricebookEntry standardPbe1 = new PricebookEntry(Product2Id = product1.Id, Pricebook2Id = '01s3t0000009EwQAAU', UnitPrice = 100, IsActive = true);
        insert standardPbe1;

        PricebookEntry standardPbe2 = new PricebookEntry(Product2Id = product2.Id, Pricebook2Id = '01s3t0000009EwQAAU', UnitPrice = 200, IsActive = true);
        insert standardPbe2;


        // Create a test Opportunity
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', StageName = 'New', CloseDate = Date.today());
        insert opp;

        // Create test Opportunity Line Items
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opp.Id, Product2Id = product1.Id, Quantity = 1, UnitPrice = 100, PricebookEntryId = standardPbe1.Id);
        insert oli1;

        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = opp.Id, Product2Id = product2.Id, Quantity = 1, UnitPrice = 200, PricebookEntryId = standardPbe2.Id);
        insert oli2;

        // Verify the Product Summary field
        opp = [SELECT Product_Summary__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('Test Product 1, Test Product 2', opp.Product_Summary__c);

        // Update an Opportunity Line Item
        oli1.UnitPrice = 150;
        update oli1;

    }
}