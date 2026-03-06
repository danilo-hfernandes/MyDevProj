@isTest
private class PostPaymentControllerTest {

    @isTest
    static void testGetProductId() {
        Id standardPbId = Test.getStandardPricebookId();

        Product2 prod = new Product2(Name = 'Club Venture Premium', ProductCode = 'CVP', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = standardPbId, UnitPrice = 100, IsActive = true);
        insert pbe;

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.Id, Pricebook2Id = standardPbId);
        insert opp;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = 100,
            Retail_Price__c = 100
        );
        insert oli;

        Test.startTest();
        String result = PostPaymentController.getProductId(opp.Id);
        Test.stopTest();
    }

    @isTest
    static void testGetRecordTypeId() {
        Test.startTest();
        Id recTypeId = PostPaymentController.getRecordTypeId();
        Test.stopTest();
    }

    @isTest
    static void testMembershipUpgradeAPICallout() {
        
        Id rtId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Membership_Upgrade').getRecordTypeId();
        
        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockSuccessResponse());

        Id standardPbId = Test.getStandardPricebookId();

        Account acc = new Account(Name = 'Test Account', Contact_Id__c = 123, Affiliate_Name__c = 'ClubVenture', Affiliated_Id__c = 123, Member_Number__c = 'M001');
        insert acc;

        Opportunity opp = new Opportunity(Name = 'Test Opp', StageName = 'Prospecting', CloseDate = Date.today(), AccountId = acc.Id, Pricebook2Id = standardPbId);
        insert opp;

        Product2 prod = new Product2(Name = 'ClubVenture', ProductCode = 'CV001', IsActive = true);
        insert prod;

        PricebookEntry pbe = new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = standardPbId, UnitPrice = 10, IsActive = true);
        insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Product2Id = prod.Id,
            Quantity = 1,
            UnitPrice = 10,
            PricebookEntryId = pbe.Id,
            Retail_Price__c = 10
        );
        insert oli;
        
        Test.startTest();

        Affiliate_Id__c aff = new Affiliate_Id__c(Affiliate_Name__c = 'ClubVenture', Affiliate_Id__c = '123');
        insert aff;

        Payment__c payment = new Payment__c(
            Opportunity__c = opp.Id,
            Product_Id__c = 'Prod001',
            Payment_Date__c = Date.today(),
            RecordTypeId = rtId,
            Opportunity_Product__c = oli.Id
        );
        //insert payment;

        
        PostPaymentController.savePayment(payment);
        Test.stopTest();
    }

    // Simple mock class for callout success
    class MockSuccessResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{ "status": "success" }');
            res.setStatusCode(404);
            return res;
        }
    }
}