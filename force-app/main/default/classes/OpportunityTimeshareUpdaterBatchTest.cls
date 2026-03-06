@isTest
private class OpportunityTimeshareUpdaterBatchTest {

    @isTest
    static void testOpportunityTimeshareUpdaterBatch() {
        Test.startTest();

        Resort__c r = new Resort__c();
        r.name = 'test';
        insert r;
        
        Timeshare__c Ts = new Timeshare__c();
        Ts.Resort__c = r.Id;
        Ts.Mortgage_Balance__c = 100;
        Ts.Mortgage_Monthly_Payment__c = '5';
        Ts.Master_Record_Id__c = 'Mitul1234';
        insert Ts;
        
        // Create Products
        Product2 product1 = new Product2(Name = 'HC Collection Weeks', IsActive = true);
        Product2 product2 = new Product2(Name = 'Other Product', IsActive = true);
        insert new List<Product2>{product1, product2};

        // Create PricebookEntries
        PricebookEntry pbe1 = new PricebookEntry(Product2Id = product1.Id, Pricebook2Id = '01s3t0000009EwQAAU', UnitPrice = 3000, IsActive = true);
        PricebookEntry pbe2 = new PricebookEntry(Product2Id = product2.Id, Pricebook2Id = '01s3t0000009EwQAAU', UnitPrice = 3000, IsActive = true);
        insert new List<PricebookEntry>{pbe1, pbe2};

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opp BatchTest',
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Pricebook2Id = '01s3t0000009EwQAAU',
            Timeshare_1__c = Ts.Id
        );
        insert opp;

        //,            Timeshare_2__c = 'TS2'
                
        // Create OpportunityLineItems
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opp.Id, Quantity = 1, UnitPrice = 3000, PricebookEntryId = pbe1.Id, Timeshare__c = Ts.Id);
//        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = opp.Id, Quantity = 1, UnitPrice = 3000, PricebookEntryId = pbe2.Id, Timeshare__c = Ts.Id);
//        insert new List<OpportunityLineItem>{oli1, oli2};
        insert new List<OpportunityLineItem>{oli1};

        // Run the batch
        //Test.startTest();
        Database.executeBatch(new OpportunityTimeshareUpdaterBatch(), 1);
        Test.stopTest();

        // Verify updates
        Opportunity updatedOpp = [SELECT Timeshare_1_OppProd_Id__c, Timeshare_2_OppProd_Id__c, Count_HC_Vida_Coll_Weeks_Usage_Fee_TC_Re__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(oli1.Id, updatedOpp.Timeshare_1_OppProd_Id__c);
        //System.assertEquals(oli2.Id, updatedOpp.Timeshare_2_OppProd_Id__c);
        System.assertEquals(2, updatedOpp.Count_HC_Vida_Coll_Weeks_Usage_Fee_TC_Re__c);
    }
}