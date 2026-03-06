@isTest
public class TravelInsuranceControllerTest {
@isTest
    static void getDataTest(){
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412', First_Name__c ='Test' , Last_Name__c = 'Account');
        insert acc;
        
        Id cruiseRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Cruise').getRecordTypeId();
        Opportunity opp = new Opportunity (Name='Opp2',StageName='New',CloseDate=Date.today(),AccountId = acc.id, RecordTypeId = cruiseRecordTypeId);
        insert opp;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Product2 prd1 = new Product2 (Name='HSI Travel Insurance',isActive = true, Product_Type__c = 'Base');
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPricebook.Id,UnitPrice=0, isActive=true);
        insert pbe1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,Quote_Id__c= 'QuoteId',Product2Id = prd1.Id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=1, retail_price__c = 1);
        insert lineItem1;
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Product_Id__c = lineItem1.product_Id__c;
        p.Opportunity__c = opp.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 0.96;
        p.Paid_On__c = System.today();
        insert p; 
        
        TravelInsuranceController.validateRecord(opp.Id);
        TravelInsuranceController.hitProductCreation(opp.Id, 0.98, 'QuoteId');
        Map<String, String> travelerMap = new Map<String, String>();
        travelerMap.put('FirstName', 'FirstName');
        travelerMap.put('LastName', 'LastName');
        List<Map<String, String>> listOfTravelers = new List<Map<String, String>>();
        listOfTravelers.add(travelerMap);
        Test.setMock(HttpCalloutMock.class, new TravelInsuranceControllerTest.TravelInsuranceMockAPI());
        Test.startTest();
        TravelInsuranceController.hitQuoteAPI(opp.Id, 'test', 'test', 'test', 'test', 'test', 'test', 'test@gmail.com', System.today(), System.today(), 'test',listOfTravelers);
        
        Test.setMock(HttpCalloutMock.class, new TravelInsuranceControllerTest.TravelInsurancePurchaseMockAPI());
        
        //TravelInsuranceController.hitPurchaseAPI(opp.Id,'QuoteId',lineItem1.Product_Id__c);
        
        Test.setMock(HttpCalloutMock.class, new TravelInsuranceControllerTest.TravelInsurancePurchaseMockAPI());
        OpportunityLineItem lineItem2 = new OpportunityLineItem (OpportunityID=opp.id,Quote_Id__c= 'QuoteId',Product2Id = prd1.Id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=1, retail_price__c = 1);
        insert lineItem2;
        //TravelInsuranceController.hitPurchaseAPI(opp.Id,'QuoteId',lineItem2.Product_Id__c);
        Test.stopTest();
    }
    
    public class TravelInsuranceMockAPI implements HTTpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            //SendToCyberSource.ParamTransaction pt = new SendToCyberSource.ParamTransaction(); 
            
            HttpResponse res = new HttpResponse();
            res.setHeader('content-type','application/json');
            res.setHeader('api-key', 'asfasd2323');
            res.setBody('{"quote_available" : true, "quote_id": "2aa27517-0879-4492-a032-36f636bc7b13", "policy_link":"https://webservices.travelguard.com/Product/FileRetrieval.aspx?CountryCode=US&StateCode=NW&ProductCode=941801&PlanCode=NW21&FileType=PROD_PLAN_GM", "net_price":0.96}');
            	
            res.setStatusCode(200);
            return res;
        }   
    }
    public class TravelInsurancePurchaseMockAPI implements HTTpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            //SendToCyberSource.ParamTransaction pt = new SendToCyberSource.ParamTransaction(); 
            
            HttpResponse res = new HttpResponse();
            res.setHeader('content-type','application/json');
            res.setHeader('api-key', 'asfasd2323');
            res.setBody('{"itinerary_number" : "test", "policy_number": 874596, "insurance_cost":73.07,"insurance_sale_price" : 23,"insured_amount": 23,"insurance_provider": "AIG", "purchase_date":"6/21/2024"}');
            	
            res.setStatusCode(200);
            return res;
        }   
    }
    
    
    
    
    
    
    
    
    @testSetup
    static void setupData() {
        Account acc = new Account(Name='Test Account');
        insert acc;

        Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Cruise').getRecordTypeId();
        Opportunity opp = new Opportunity(Name='Test Opp', StageName='Prospecting', CloseDate=Date.today(), AccountId=acc.Id, RecordTypeId=recordTypeId, Amount=1000);
        insert opp;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 stdPb = new Pricebook2(Id = pricebookId, IsActive = true);
        update stdPb;

        Product2 product = new Product2(Name='HSI Travel Insurance', IsActive=true);
        insert product;

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id=stdPb.Id, Product2Id=product.Id, UnitPrice=100, IsActive=true);
        insert pbe;

        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId=opp.Id,
            Product2Id=product.Id,
            PricebookEntryId=pbe.Id,
            Quantity=1,
            UnitPrice=100,
            Quote_Id__c='QUOTE123',
            Check_In_Date__c=Date.today().addDays(1),
            Check_Out_Date__c=Date.today().addDays(7),
            Destination__c='USA'
        );
        insert oli;

        oli = [SELECT Id, Product_Id__c FROM OpportunityLineItem WHERE Id = :oli.Id LIMIT 1];

        Payment__c pay = new Payment__c(
            Name='Pay',
            Product_Id__c = oli.Product_Id__c,
            Opportunity__c = opp.Id,
            Transaction_Type__c='Payment',
            Payment_Amount__c=99.99,
            Paid_On__c=Date.today()
        );
        insert pay;
    }

    @isTest
    static void test_validateRecord() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        TravelInsuranceController.WrapperClassDetails result = TravelInsuranceController.validateRecord(opp.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.paymentFlag);
    }

    @isTest
    static void test_hitProductCreation() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        TravelInsuranceController.WrapperClassDetails result = TravelInsuranceController.hitProductCreation(opp.Id, 88.88, 'NEWQUOTE');
        Test.stopTest();
        System.assertNotEquals(null, result.productId);
    }

    @isTest
    static void test_hitQuoteAPI() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        List<Map<String, String>> travelers = new List<Map<String, String>>();
        Map<String, String> traveler = new Map<String, String>{
            'firstName' => 'John',
            'lastName' => 'Doe'
        };
        travelers.add(traveler);

        Test.setMock(HttpCalloutMock.class, new QuoteMock());
        Test.startTest();
        TravelInsuranceController.WrapperClassDetails result = TravelInsuranceController.hitQuoteAPI(
            opp.Id,
            'John',
            'Doe',
            'Street',
            'City',
            'State',
            'US',
            'john@example.com',
            DateTime.now(),
            DateTime.now().addDays(3),
            'USA',
            travelers
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
        System.assertEquals('QUOTE_TEST', result.quote_id);
        System.assert(result.net_price > 0);
    }

    @isTest
    static void test_hitPurchaseAPI() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        OpportunityLineItem oli = [SELECT Id, Product_Id__c FROM OpportunityLineItem WHERE OpportunityId = :opp.Id LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new PurchaseMock());
        Test.startTest();
        TravelInsuranceController.WrapperClassDetails result = TravelInsuranceController.hitPurchaseAPI(
            opp.Id,
            'QUOTE_TEST',
            oli.Product_Id__c
        );
        Test.stopTest();

        System.assertNotEquals(null, result);
        //System.assertEquals(null, result.errorMessage);
    }

    @isTest
    static void test_deleteTravelInsuranceProduct() {
        OpportunityLineItem oli = [SELECT Id, Product_Id__c FROM OpportunityLineItem LIMIT 1];

        delete [SELECT Id FROM Payment__c WHERE Product_Id__c = :oli.Product_Id__c];

        Test.startTest();
        Boolean result = TravelInsuranceController.deleteTravelInsuranceProduct(oli.Product_Id__c);
        Test.stopTest();

        System.assertEquals(false, result);
    }

    // Mocks
    public class QuoteMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"quote_id":"QUOTE_TEST","net_price":89.99}');
            res.setStatusCode(200);
            return res;
        }
    }

    public class PurchaseMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"itinerary_number":"test","policy_number":123456,"insurance_cost":50.00,"insurance_sale_price":60.00,"insurance_provider":"AIG","insured_amount":1000,"purchase_date":"03/31/2025"}');
            res.setStatusCode(200);
            return res;
        }
    }
}