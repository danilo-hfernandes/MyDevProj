@isTest
public class RequestAvailabilityMATest {
    
    static testmethod void test1() {
        Account acc = new Account(Name = 'Test Account', Affiliated_Id__c = 1235, Member_Number__c = '13523412');
        insert acc;
        
        Contact con = new Contact(LastNAme = acc.Name, AccountId = acc.Id, Subscriber_Id__c = '123456',Contact_Id__c = 258);
        insert con;
        list<Inventory_Availability__c> tst = New list<Inventory_Availability__c>();
        Inventory_Availability__c inven = New Inventory_Availability__c();
        inven.Available_Weeks__c = 2.00;
        inven.New_Availability__c = 5;
        inven.Program__c = 'MKT';
        inven.Resort_Name__c = 'Mayan Palace';
        inven.Unit_Type__c = '1BR';
        inven.Check_In_Date__c = Date.today();
        tst.add(inven);
        insert tst;
        
        
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        system.debug('inven' + inven);
        
        
        String str = '{"StartDate": "2021-06-23 00:00:00", "EndDate": "", "SubscriberId": "123456", "ContactId": 258}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestURI= 'https://holidaysystems--partial.my.salesforce.com/services/apexrest/Requestavailability';
        system.debug('req.requestURI----'+req.requestURI);
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response= res;
        RequestAvailabilityMA.createOppAndRelatedRecord();
        
        
    }
    static testmethod void test2() {
        list<Inventory_Availability__c> tst = New list<Inventory_Availability__c>();
        Inventory_Availability__c inven = New Inventory_Availability__c();
        inven.Available_Weeks__c = 2.00;
        inven.New_Availability__c = 5;
        inven.Program__c = 'MKT';
        inven.Resort_Name__c = 'Mayan Palace';
        inven.Unit_Type__c = '1BR';
        inven.Check_In_Date__c = Date.today();
        tst.add(inven);
        insert tst;
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        system.debug('inven' + inven);
        
        
        String str = '{"StartDate": "", "EndDate": "2021-06-23 00:00:00", "SubscriberId": "123456", "ContactId": 258}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestURI= 'https://holidaysystems--partial.my.salesforce.com/services/apexrest/Requestavailability';
        system.debug('req.requestURI----'+req.requestURI);
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response= res;
        RequestAvailabilityMA.createOppAndRelatedRecord();
        
        
    }
    static testmethod void test3() {
        list<Inventory_Availability__c> tst = New list<Inventory_Availability__c>();
        Inventory_Availability__c inven = New Inventory_Availability__c();
        inven.Available_Weeks__c = 2.00;
        inven.New_Availability__c = 5;
        inven.Program__c = 'MKT';
        inven.Resort_Name__c = 'Mayan Palace';
        inven.Unit_Type__c = '1BR';
        inven.Check_In_Date__c = Date.today();
        tst.add(inven);
        insert tst;
        //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        system.debug('inven' + inven);
        
        
        String str = '{"StartDate": "2021-06-24 00:00:00", "EndDate": "2021-06-23 00:00:00"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestURI= 'https://holidaysystems--partial.my.salesforce.com/services/apexrest/Requestavailability';
        system.debug('req.requestURI----'+req.requestURI);
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response= res;
        RequestAvailabilityMA.createOppAndRelatedRecord();
        
        
    }
    
}