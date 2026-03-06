@isTest
public class VoucherDetailsServiceTest {
    @isTest
    static void test1() {
        //Test.setMock(HttpCalloutMock.class, new VoucherDetailsServiceMockAPI());
        Account objacc = new Account();
        objacc.Name = 'Test';
        objacc.Contact_Id__c = 123;
        //objacc.Master_Record_Id__c = ;
        insert objacc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp';
        opp.CloseDate = System.today();
        opp.StageName = 'Closed Won';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
        insert opp;
        
        Id  standardPb = Test.getStandardPricebookId();
        
        Product2 prd1 = new Product2 (Name='Guest Voucher',Description='Test Product Entry 1', isActive = true);
        insert prd1;
        
        
        PricebookEntry pbe1 = new PricebookEntry (Product2ID=prd1.id,Pricebook2ID=standardPb,UnitPrice=50, isActive=true);
        insert pbe1;
        
        OpportunityLineItem lineItem1 = new OpportunityLineItem (OpportunityID=opp.id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=200, retail_price__c = 99);
        insert lineItem1;
         
        Test.startTest();
        
        RestRequest request = new RestRequest();
        request.requestUri ='https://holidaysystems--full.my.salesforce.com/services/apexrest/getVoucherDetails?voucherType=GuestVoucher&masterRecordId=123';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof('{}');
        request.addParameter('voucherType', 'MexicoVoucher');
        request.addParameter('masterRecordId', '');
        RestContext.request = request;
        
        // Call the method to test
        VoucherDetailsService.voucherList();
        
        RestRequest request1 = new RestRequest();
        request1.requestUri ='https://holidaysystems--full.my.salesforce.com/services/apexrest/getVoucherDetails?voucherType=GuestVoucher&masterRecordId=123';
        request1.httpMethod = 'POST';
        request1.requestBody = Blob.valueof('{}');
        request1.addParameter('voucherType', 'CruiseVoucher');
        request1.addParameter('masterRecordId', '');
        RestContext.request = request1;
        
        // Call the method to test
        VoucherDetailsService.voucherList();
        
        RestRequest request2 = new RestRequest();
        request2.requestUri ='https://holidaysystems--full.my.salesforce.com/services/apexrest/getVoucherDetails?voucherType=GuestVoucher&masterRecordId=123';
        request2.httpMethod = 'POST';
        request2.requestBody = Blob.valueof('{}');
        request2.addParameter('voucherType', 'GuestVoucher');
        request2.addParameter('masterRecordId', '');
        RestContext.request = request2;
        
        // Call the method to test
        VoucherDetailsService.voucherList();
        
        
        test.stopTest();
        
    }
}