@isTest
public class MonsterProductsWebserviceTest {
    @isTest
    static void getDataTest(){
    Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412', First_Name__c ='Test' , Last_Name__c = 'Account');
        insert acc;
        
        Id monsterRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Monster').getRecordTypeId();
        Opportunity opp = new Opportunity (Name='Opp2',StageName='New',CloseDate=Date.today(),AccountId = acc.id, RecordTypeId = monsterRecordTypeId);
        insert opp;
        
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );
        update standardPricebook;
        
        Product2 prd1 = new Product2 (Name='M-Domestic 5 Days/4 Nights',isActive = true);//,Product_Type__c = 'Base'
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPricebook.Id,UnitPrice=0, isActive=true);
        insert pbe1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,Product2Id = prd1.Id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=1, retail_price__c = 1);
        insert lineItem1;
        
        Test.setMock(HttpCalloutMock.class, new MonsterProductsWebserviceTest.MonsterProductMockAPI());
        Test.startTest();
        MonsterProductsWebservice.hitSubmissionAPI(opp.Id,'pounjnjnjnjn','4111111111111111', 'Visa', '05/25',true, 'test', 'test', 'test', 'test', 'test', 'test','0025', 'test@gmail.com','98523');
        Test.stopTest();
    }
    public class MonsterProductMockAPI implements HTTpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            //SendToCyberSource.ParamTransaction pt = new SendToCyberSource.ParamTransaction(); 
            
            HttpResponse res = new HttpResponse();
            res.setHeader('content-type','application/json');
            res.setHeader('api-key', 'asfasd2323');
            res.setBody('{"cardResults":[],"paymentStatus":true,"crmStatus":839778}');
            res.setStatusCode(200);
            return res;
        }   
    }

}