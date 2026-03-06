@isTest
public class RequestInventorybookingCtrlTest {
    static testmethod void test1() {
         Account a = new Account();
        a.Name = 'test account';
        a.Member_Number__c = '5655656';
        a.Last_Name__c = 'tett';
        insert a;
        
        Contact ct = New Contact();
        ct.AccountId = a.id;
        ct.Subscriber_Id__c = '1231';
        ct.Contact_Id__c = 44444;
        ct.LastName = 'testse';
        insert ct;
        
        list<Inventory_Availability__c> tst = New list<Inventory_Availability__c>();
        Inventory_Availability__c inven = New Inventory_Availability__c();
        inven.Available_Weeks__c = 2.00;
        inven.New_Availability__c = 5;
        inven.Check_In_Date__c = Date.today();
        tst.add(inven);
        insert tst;
        
         Product2 p = new Product2();
        p.Name = 'Vida Voucher-Profit Agility';
        p.isActive = true;
        insert p;
        
        id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 pb = new Pricebook2();
        pb.isActive = true;
        pb.Name = 'Standard Pricebook';
        insert pb;
        
        
        
        String str = '{"SubscriberId":"1231","ContactId":44444,"SubscriberUserId":106549,"AvailabilityObjectRecord":{"Id":"'+ inven.Id +'","Plaza__c":"VALLARTA","Resort_Name__c": "Grand Luxxe Villa Nuevo Vallarta","Site_Name__c": "Grand Luxxe Nuevo Vallarta","Unit_Type__c": "U.H.","Check_In_Date__c": "2021-06-18 00:00:00","New_Availability__c": 8,"Room_Type__c": "ABC","Capacity__c": "2A + 2K","Size_Upgrade__c":0,"Property_Upgrade__c":0,"Total_Upgrade__c":0,"Base_Price__c":299}';
        str = str + ',"TravelerInformation": {"Traveler_Name__c:": "Mitul","Traveler_Email__c": "Mitul@myemail.com","Traveler_Address__c": "Address","Traveler_City__c": "State","Traveler_State__c": "Phone","Traveler_Country__c": "Country","Traveler_Zip__C": "Zip","Traveler_Phone__c": "Phone"}';
        str = str + ',"PaymentInformation": {"Transaction_Type_Text__c": "Voucher","Transaction_Type__c": "Payment","Payment_Amount__c":799,"Authorization_Code__c:": "123","Base_Price__c":299,"Total_Upgrades__c":500,"Commission__c":100}}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestURI= 'https://holidaysystems--partial.my.salesforce.com/services/apexrest/RequestInventorybooking';
        system.debug('req.requestURI----'+req.requestURI);
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response= res;
        RequestInventorybookingCtrl.createOppAndRelatedRecord();
    }
    static testmethod void test2() {
         Account a = new Account();
        a.Name = 'test account';
        a.Member_Number__c = '5655656';
        a.Last_Name__c = 'tett';
        insert a;
        
        Contact ct = New Contact();
        ct.AccountId = a.id;
        ct.Subscriber_Id__c = '1231';
        ct.Contact_Id__c = 44444;
        ct.LastName = 'testse';
        insert ct;
        
        list<Inventory_Availability__c> tst = New list<Inventory_Availability__c>();
        Inventory_Availability__c inven = New Inventory_Availability__c();
        inven.Available_Weeks__c = 2.00;
        inven.New_Availability__c = 5;
        inven.Check_In_Date__c = Date.today();
        tst.add(inven);
        insert tst;
        
         Product2 p = new Product2();
        p.Name = 'Vida Voucher-Profit Agility';
        p.isActive = true;
        insert p;
        
        id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 pb = new Pricebook2();
        pb.isActive = true;
        pb.Name = 'Standard Pricebook';
        insert pb;
        
        
        
        String str = '{"SubscriberUserId":106549,"AvailabilityObjectRecord":{"Id":"'+ inven.Id +'","Plaza__c":"VALLARTA","Resort_Name__c": "Grand Luxxe Villa Nuevo Vallarta","Site_Name__c": "Grand Luxxe Nuevo Vallarta","Unit_Type__c": "U.H.","Check_In_Date__c": "2021-06-18 00:00:00","New_Availability__c": 8,"Room_Type__c": "ABC","Capacity__c": "2A + 2K","Size_Upgrade__c":0,"Property_Upgrade__c":0,"Total_Upgrade__c":0,"Base_Price__c":299}';
        str = str + ',"TravelerInformation": {"Traveler_Name__c:": "Mitul","Traveler_Email__c": "Mitul@myemail.com","Traveler_Address__c": "Address","Traveler_City__c": "State","Traveler_State__c": "Phone","Traveler_Country__c": "Country","Traveler_Zip__C": "Zip","Traveler_Phone__c": "Phone"}';
        str = str + ',"PaymentInformation": {"Transaction_Type_Text__c": "Voucher","Transaction_Type__c": "Payment","Payment_Amount__c":799,"Authorization_Code__c:": "123","Base_Price__c":299,"Total_Upgrades__c":500,"Commission__c":100}}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestURI= 'https://holidaysystems--partial.my.salesforce.com/services/apexrest/RequestInventorybooking';
        system.debug('req.requestURI----'+req.requestURI);
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response= res;
        RequestInventorybookingCtrl.createOppAndRelatedRecord();
    }
}