@IsTest
public class ApplyCreditsControllerTest {

    static testMethod void Test1() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412', Membership_Annual_Due__c = 149, First_Name__c ='Test' , Last_Name__c = 'Account');
        insert acc;
        
        Id mAnnualDuesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Annual_Dues').getRecordTypeId();
        Opportunity opp2 = new Opportunity (Name='Opp2',StageName='New',CloseDate=Date.today(),AccountId = acc.id, RecordTypeId = mAnnualDuesRecordTypeId);
        insert opp2;
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Annual Dues-Renewal',isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
        insert pbe1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp2.id,Product2Id = prd1.Id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=149, retail_price__c = 149);
        insert lineItem1;
             
        ApplyCreditsController.oliCreditsData creditsData = new ApplyCreditsController.oliCreditsData();
        creditsData.Credits_Balance_c = 149;
        creditsData.Membership_Annual_Due_c = 1;
        creditsData.Number_Of_Years_To_Pay_c = 1;
        creditsData.Total_Due_c = creditsData.Number_Of_Years_To_Pay_c*creditsData.Membership_Annual_Due_c;
        creditsData.Apply_Credits_c = 100;
        creditsData.Balance_To_Pay_c = 49;
        
        Test.setMock(HttpCalloutMock.class, new ApplyCreditsControllerTest.MockGetMemberCreditsHttpResponseGenerator());
        Test.startTest();
        
        Map<String,Map<String,Decimal>> getCreditsResult = ApplyCreditsController.tryToGetCreditsData(opp2.Id);
        Map<String,String> results = ApplyCreditsController.tryToUseCredits(creditsData,opp2.Id);
        Map<String,String> results2 = ApplyCreditsController.tryToUseCredits(creditsData,opp2.Id);
        
        Test.stopTest();
    }
    
    static testMethod void Test2() {
        
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412', Membership_Annual_Due__c = 149);
        insert acc;
        
        Id mAnnualDuesRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Membership_Annual_Dues').getRecordTypeId();
        Opportunity opp2 = new Opportunity (Name='Opp2',StageName='New',CloseDate=Date.today(),AccountId = acc.id, RecordTypeId = mAnnualDuesRecordTypeId);
        insert opp2;
        
        Id standardPbId = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Annual Dues-Renewal',isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=0, isActive=true);
        insert pbe1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp2.id,Product2Id = prd1.Id,PriceBookEntryID=pbe1.id, quantity=1, totalprice=149, retail_price__c = 149);
        insert lineItem1;
        
        ApplyCreditsController.oliCreditsData creditsData = new ApplyCreditsController.oliCreditsData();
        creditsData.Credits_Balance_c = 149;
        creditsData.Membership_Annual_Due_c = 149;
        creditsData.Number_Of_Years_To_Pay_c = 1;
        creditsData.Total_Due_c = creditsData.Number_Of_Years_To_Pay_c*creditsData.Membership_Annual_Due_c;
        creditsData.Apply_Credits_c = 149;
        creditsData.Balance_To_Pay_c = 0;
        
        Test.setMock(HttpCalloutMock.class, new ApplyCreditsControllerTest.MockGetMemberCreditsHttpResponseFailed());
        Test.startTest();
        
        Map<String,Map<String,Decimal>> getCreditsResult = ApplyCreditsController.tryToGetCreditsData(opp2.Id);
        Map<String,String> results = ApplyCreditsController.tryToUseCredits(creditsData,opp2.Id);
        Map<String,Map<String,Decimal>> getCreditsResult2 = ApplyCreditsController.tryToGetCreditsData(opp2.Id);
        
        Test.stopTest();
    }
    
    public class MockGetMemberCreditsHttpResponseGenerator implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String str = '{"Redeemable":149.00}';
            //str = str + ',"phoneNumber": "1234567890","address": "1252 Some Random Street","city": "Orlando","postalCode": "32555","stateCode": "FL","countryCode": "United States","RenewableYears": 1,"AdvantageWeeksAllocated": 1,"languagePreferred": {"code": "ENG","name": "ENGLISH"}}';
            res.setBody(str);
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
    
    public class MockGetMemberCreditsHttpResponseFailed implements HttpCalloutMock 
    {
        public HTTPResponse respond(HTTPRequest req)
        {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String str = '{"Redeemable":149.00}';
            //str = str + ',"phoneNumber": "1234567890","address": "1252 Some Random Street","city": "Orlando","postalCode": "32555","stateCode": "FL","countryCode": "United States","RenewableYears": 1,"AdvantageWeeksAllocated": 1,"languagePreferred": {"code": "ENG","name": "ENGLISH"}}';
            res.setBody(str);
            res.setStatusCode(500);
            res.setStatus('NOK');
            return res;
        }
    }
}