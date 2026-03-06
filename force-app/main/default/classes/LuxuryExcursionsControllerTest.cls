@IsTest
private class LuxuryExcursionsControllerTest {

    @IsTest
    static void testGetExcursions() {
        // Create Account
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // Create Opportunity
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        // Create Product
        Product2 prod = new Product2(
            Name = 'Luxury Yacht Package',
            IsActive = true
        );
        insert prod;

        // Create PricebookEntry (required for OpportunityLineItem)
        //Pricebook2 stdPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        Id stdPricebookId = Test.getStandardPricebookId();

        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPricebookId,
            Product2Id = prod.Id,
            UnitPrice = 1000,
            IsActive = true
        );
        insert pbe;

        // Create OpportunityLineItem
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 1,
            PricebookEntryId = pbe.Id,
            UnitPrice = 1000
        );
        insert oli;

        // Create Luxury Excursion
        Luxury_Excursion__c excursion = new Luxury_Excursion__c(
            //Name = 'Test Excursion',
            Opportunity__c = opp.Id,
            Opportunity_Product__c = oli.Id,
            Excursion_Yacht_Name__c = 'Yacht A',
            Location__c = 'Bahamas',
            Date_Time__c = System.now(),
            HSI_Cost__c = 500//,
            //Confirmation__c = true
        );
        insert excursion;

        Test.startTest();
        List<Luxury_Excursion__c> results = 
            LuxuryExcursionsController.getExcursions(opp.Id);
        Test.stopTest();

        System.assertEquals(1, results.size());
       // System.assertEquals('Test Excursion', results[0].Name);
        System.assertEquals('Luxury Yacht Package',
            results[0].Opportunity_Product__r.Product2.Name);
    }

    @IsTest
    static void testCreateExcursion_WithSource() {

        // Setup minimal data
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        Product2 prod = new Product2(Name = 'Luxury Yacht', IsActive = true);
        insert prod;

        //Pricebook2 stdPricebook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
        
        Id stdPricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = stdPricebookId,
            Product2Id = prod.Id,
            UnitPrice = 1000,
            IsActive = true
        );
        insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 1,
            PricebookEntryId = pbe.Id,
            UnitPrice = 1000
        );
        insert oli;

        Luxury_Excursion__c sourceExcursion = new Luxury_Excursion__c(
            //Name = 'Source Excursion',
            Opportunity__c = opp.Id,
            Opportunity_Product__c = oli.Id
        );
        insert sourceExcursion;

        Test.startTest();
        Id newId = LuxuryExcursionsController.createExcursion(
            opp.Id,
            sourceExcursion.Id
        );
        Test.stopTest();

        Luxury_Excursion__c created = [
            SELECT Opportunity__c, Opportunity_Product__c
            FROM Luxury_Excursion__c
            WHERE Id = :newId
        ];

        System.assertEquals(opp.Id, created.Opportunity__c);
        System.assertEquals(oli.Id, created.Opportunity_Product__c);
    }

    @IsTest
    static void testCreateExcursion_WithoutSource() {

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        Test.startTest();
        Id newId = LuxuryExcursionsController.createExcursion(
            opp.Id,
            null
        );
        Test.stopTest();

        Luxury_Excursion__c created = [
            SELECT Opportunity__c, Opportunity_Product__c
            FROM Luxury_Excursion__c
            WHERE Id = :newId
        ];

        System.assertEquals(opp.Id, created.Opportunity__c);
        System.assertEquals(null, created.Opportunity_Product__c);
    }
}