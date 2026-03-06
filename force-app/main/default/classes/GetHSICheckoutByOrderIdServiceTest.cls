@isTest
public class GetHSICheckoutByOrderIdServiceTest {
    @isTest
    static void test1() {
        
        Test.setMock(HttpCalloutMock.class, new MockGetWWPTCheckoutService());
        String userid = UserInfo.getUserId();
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'Mitul';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(o);
        insert o;
        List<Opportunity> orderid = [SELECT id, Order_Id__c from Opportunity WHERE id = :oppList[0].id LIMIT 1];
        
        Test.startTest();
        
        GetHSICheckoutByOrderIdService ps = new GetHSICheckoutByOrderIdService();
        GetHSICheckoutByOrderIdService.ParamTransaction pr = new GetHSICheckoutByOrderIdService.ParamTransaction();
        
        pr.Amount = o.Amount;
        pr.DownPayment = o.Down_Deposit__c;
        
        String JsonMsg='{"OpportunityId" : "'+ o.Id +'","Amount":' + o.Amount + ',"RecurringNumberOfPayments":' + o.Number_of_Payments__c + '}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/getwwptcheckoutbyorderidservice/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        GetHSICheckoutByOrderIdService.responsewrapper rp = new GetHSICheckoutByOrderIdService.responsewrapper();
        GetHSICheckoutByOrderIdService.GetData(orderid[0].Order_Id__c);
        
        test.stopTest();
    }
    
    @isTest
    static void test2() {
        
        Test.setMock(HttpCalloutMock.class, new MockGetWWPTCheckoutService());
        String userid = UserInfo.getUserId();
        Account a = new Account();
        a.First_Name__c = '';
        a.Last_Name__c = 'last';
        a.Name = 'Mitul';
        a.Email__c = 'test@test.com';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(o);
        insert o;
        List<Opportunity> orderid = [SELECT id, Order_Id__c from Opportunity WHERE id = :oppList[0].id LIMIT 1];
        
        Test.startTest();
        
        GetHSICheckoutByOrderIdService ps = new GetHSICheckoutByOrderIdService();
        GetHSICheckoutByOrderIdService.ParamTransaction pr = new GetHSICheckoutByOrderIdService.ParamTransaction();
        
        pr.Amount = o.Amount;
        pr.DownPayment = o.Down_Deposit__c;
        
        String JsonMsg='{"OpportunityId" : "'+ o.Id +'","Amount":' + o.Amount + ',"RecurringNumberOfPayments":' + o.Number_of_Payments__c + '}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/getwwptcheckoutbyorderidservice/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        GetHSICheckoutByOrderIdService.responsewrapper rp = new GetHSICheckoutByOrderIdService.responsewrapper();
        GetHSICheckoutByOrderIdService.GetData(orderid[0].Order_Id__c);
        
        test.stopTest();
    }
    
    @isTest
    static void test3() {
        
        Test.setMock(HttpCalloutMock.class, new MockGetWWPTCheckoutService());
        String userid = UserInfo.getUserId();
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'Mitul';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(o);
        insert o;
        
         Id standardPbId = Test.getStandardPricebookId();

        //product1
        //
        Pricebook2 pbk1 = new Pricebook2 (Name='Test Pricebook Entry 1',Description='Test Pricebook Entry 1', isActive=true);
        insert pbk1;
        
        Product2 prd1 = new Product2 (Name='Membership Upgrade',Upgrade_Product__c = true,ProductCode = 'Membership Upgrade', Description='Test Membership Upgrade Product Entry 1', isActive = true);
        insert prd1;
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPbId,UnitPrice=50, isActive=true);
        insert pbe1;        
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=o.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
        
        //product2
        
        Pricebook2 pbk2 = new Pricebook2 (Name='Test Pricebook Entry 2',Description='Test Pricebook Entry 2', isActive=true);
        insert pbk2;
        
        Product2 prd2 = new Product2 (Name='Voucher-Vidanta',Description='Test Non Membership Upgrade Product Entry 2', isActive = true);
        insert prd2;
        
        PricebookEntry pbe2 = new PricebookEntry (Product2ID=prd2.id,Pricebook2ID=standardPbId,UnitPrice=100, isActive=true);
        insert pbe2;        
        
        OpportunityLineItem lineItem2 = new OpportunityLineItem (OpportunityID=o.id,PriceBookEntryID=pbe2.id, quantity=8, totalprice=400, retail_price__c = 199);
        insert lineItem2;
        
        //
        
        List<Opportunity> orderid = [SELECT id, Order_Id__c from Opportunity WHERE id = :oppList[0].id LIMIT 1];
        
        Test.startTest();
        
        GetHSICheckoutByOrderIdService ps = new GetHSICheckoutByOrderIdService();
        GetHSICheckoutByOrderIdService.ParamTransaction pr = new GetHSICheckoutByOrderIdService.ParamTransaction();
        
        pr.Amount = o.Amount;
        pr.DownPayment = o.Down_Deposit__c;
        
        String JsonMsg='{"OpportunityId" : "'+ o.Id +'","Amount":' + o.Amount + ',"RecurringNumberOfPayments":' + o.Number_of_Payments__c + '}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/getwwptcheckoutbyorderidservice/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        
        GetHSICheckoutByOrderIdService.responsewrapper rp = new GetHSICheckoutByOrderIdService.responsewrapper();
        GetHSICheckoutByOrderIdService.GetData(orderid[0].Order_Id__c);
        
        test.stopTest();
    }
}