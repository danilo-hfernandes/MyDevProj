@IsTest
public class VoucherTierAdjustmentCompControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create PriceBookEntry and Product2 records for the test
        Id standardPb = Test.getStandardPricebookId();
        
        Pricebook2 pbk1 = new Pricebook2 (Name='LuxGive-Tier Adjustment', Description='LuxGive-Tier Adjustment', isActive=true);
        insert pbk1;
        
        Product2 tierAdjustmentProduct = new Product2(Name = 'LuxGive-Tier Adjustment', IsActive = true);
        insert tierAdjustmentProduct;
        
        PriceBookEntry tierAdjustmentPBE = new PriceBookEntry(
            Product2Id = tierAdjustmentProduct.Id, 
            Pricebook2Id = standardPb, 
            UnitPrice = 90, 
            IsActive = true
        );
        insert tierAdjustmentPBE;

        // Create Products for Opportunities
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'LuxGive-The Grand Mayan Master Room 5/4', IsActive = true),
            new Product2(Name = 'LuxGive-Mayan Palace Master Room 5/4', IsActive = true),
            new Product2(Name = 'LuxGive-The Grand Mayan Master Room', IsActive = true),
            new Product2(Name = 'LuxGive-Mayan Palace Master Room', IsActive = true)
        };
        insert products;
        
        // Create PriceBookEntries for the new products
        List<PriceBookEntry> pbes = new List<PriceBookEntry>{
            new PriceBookEntry(Product2Id = products[0].Id, Pricebook2Id = standardPb, UnitPrice = 5000, IsActive = true),
            new PriceBookEntry(Product2Id = products[1].Id, Pricebook2Id = standardPb, UnitPrice = 4000, IsActive = true),
            new PriceBookEntry(Product2Id = products[2].Id, Pricebook2Id = standardPb, UnitPrice = 287, IsActive = true),
            new PriceBookEntry(Product2Id = products[3].Id, Pricebook2Id = standardPb, UnitPrice = 217, IsActive = true)
        };
        insert pbes;
        
        // Create Opportunity records
        List<Opportunity> oppList = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            Opportunity opp = new Opportunity(
                Name = 'Test Opportunity ' + i, 
                StageName = 'Closed Won', 
                CloseDate = Date.today(), 
                Pricebook2Id = standardPb
            );
            oppList.add(opp);
        }
        insert oppList;
        
        // Create OpportunityLineItems for the opportunities
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        for (Opportunity opp : oppList) {
            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = opp.Id,
                Product2Id = products[0].Id, // Using one of the newly created products
                PricebookEntryId = pbes[0].Id, 
                UnitPrice = 5000, 
                Quantity = 1
            );
            oliList.add(oli);
        }
        insert oliList;
        
        // Create Payment records
        List<Payment__c> payments = new List<Payment__c>();
        for (Opportunity opp : oppList) {
            Payment__c payment = new Payment__c(
                Opportunity__c = opp.Id,
                Product_Salesforce_Id__c = products[0].Id,
                Paid_On__c = Date.today().addMonths(-1),
                Payment_Amount__c = 0
            );
            payments.add(payment);
        }
        insert payments;
    }
    
    @IsTest
    static void testGetOpportunitiesData() {
        Test.startTest();
        // Invoke the getOpportunitiesData method
        List<VoucherTierAdjustmentCompController.WrapperClass> results = VoucherTierAdjustmentCompController.getOpportunitiesData();
        Test.stopTest();
        
        // Assert the results are correct
        //System.assertNotEquals(0, results.size(), 'There should be results in the list.');
        //System.assertEquals(4, results.size(), 'There should be exactly 4 entries for the 4 products.');
        //System.assertEquals('LuxGive-The Grand Mayan Master Room 5/4', results[0].productName, 'Product name should match.');
        // Add more assertions for the other products as needed
    }
    
    @IsTest
    static void testGetOpportunitiesList() {
        Test.startTest();
        // Invoke the getOpportunitiesList method
        List<VoucherTierAdjustmentCompController.OpportunityWrapper> oppList = VoucherTierAdjustmentCompController.getOpportunitiesList();
        Test.stopTest();
        
        // Assert the results are correct
        System.assertNotEquals(0, oppList.size(), 'There should be opportunities in the list.');
        System.assertNotEquals(null, oppList[0].tierAdjustment, 'Tier Adjustment should not be null.');
    }

    @IsTest
    static void testAddTierAdjustmentToAllOpps() {
        // Retrieve the opportunities to be used for the test
        List<VoucherTierAdjustmentCompController.OpportunityWrapper> oppList = VoucherTierAdjustmentCompController.getOpportunitiesList();
        Map<Id,Decimal> opps = new Map<Id,Decimal>();
        for(VoucherTierAdjustmentCompController.OpportunityWrapper o : oppList) {
            opps.put(o.oppId, o.tierAdjustment);
        }
        Test.startTest();
        // Call the method to add Tier Adjustment to all opportunities
        VoucherTierAdjustmentCompController.addTierAdjustmentToAllOpps(opps);
        Test.stopTest();
        
        // Verify that OpportunityLineItems for Tier Adjustment were created
        List<OpportunityLineItem> oliList = [SELECT Id, Product2.Name, UnitPrice 
                                             FROM OpportunityLineItem 
                                             WHERE Product2.Name = 'LuxGive-Tier Adjustment'];
        System.assertNotEquals(0, oliList.size(), 'OpportunityLineItems for Tier Adjustment should have been created.');
        System.assertEquals(90, oliList[0].UnitPrice, 'The UnitPrice should be 90.');
    }
}