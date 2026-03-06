@isTest
public class InsertFlexibleCheckoutAPITest {
    @isTest
    static void test1() {
        String userid = UserInfo.getUserId();
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'test';
        a.Member_Number__c = 'abc1234ad';
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        insert o;
        
        
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '23431231234';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'USCA';
        p.CC_Processing_Fee__c = 10.0;
        insert p;
        
        //Create Product
        Product2 pro = new product2(name='Voucher test classes');
        insert pro;
        
         
        
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        //It should return true
        System.assertEquals(true, standardPricebook.IsStandard);
        
        
        //Create the PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = pro.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe;
        Test.startTest();
        InsertpaymentService ps = new InsertPaymentService();  
        
        String JsonMsg='{"FirstName" : "Mitul Test","LastName" : "Test","Email" : "mitul@test.test12s.com","MemberNumber" : "'+ a.Member_Number__c +'","Amount":"' + p.Payment_Amount__c + '","ProductID":"'+ pro.Id+'"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/InsertFlexibleCheckoutAPI/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        InsertFlexibleCheckoutAPI.responsewrapper rp = new InsertFlexibleCheckoutAPI.responsewrapper();
        
        InsertFlexibleCheckoutAPI.createOppAndRelatedRecord();
        test.stopTest();
    }
    static void test2() {
        String userid = UserInfo.getUserId();
        Test.setMock(HttpCalloutMock.class, new MockPaymentAPI());
        Account a = new Account();
        a.First_Name__c = 'first';
        a.Last_Name__c = 'last';
        a.Name = 'test';
        
        insert a;
        
        Opportunity o = new Opportunity();
        o.AccountId = a.id;
        o.name = 'test opp';
        o.StageName = 'CallDocuSign';
        o.CloseDate = System.today();
        o.Amount = 500;
        insert o;
        
        
        
        Payment__c p = new Payment__c();
        p.Name = 'payment';
        p.Opportunity__c = o.id;
        p.Transaction_Type__c = 'Payment';
        p.Payment_Amount__c = 500;
        p.Credit_Card_Number__c = '23431231234';
        p.Paid_On__c = System.today();
        p.Payment_Type__c = 'USCA';
        p.CC_Processing_Fee__c = 10.0;
        insert p;
        
        //Create Product
        Product2 pro = new product2(name='Voucher test classes');
        insert pro;
        
         
        
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        //It should return true
        System.assertEquals(true, standardPricebook.IsStandard);
        
        
        //Create the PricebookEntry
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = pro.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe;
        Test.startTest();
        InsertpaymentService ps = new InsertPaymentService();  
        
        String JsonMsg='{"FirstName" : "Mitul Test","LastName" : "Test","Email" : "mitul@test.test12s.com","MemberNumber" : "null","Amount":"' + p.Payment_Amount__c + '","ProductID":"'+ pro.Id+'"}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/InsertFlexibleCheckoutAPI/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        InsertFlexibleCheckoutAPI.responsewrapper rp = new InsertFlexibleCheckoutAPI.responsewrapper();
        
        InsertFlexibleCheckoutAPI.createOppAndRelatedRecord();
        test.stopTest();
    }

}