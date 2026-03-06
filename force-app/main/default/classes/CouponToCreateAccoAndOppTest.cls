@isTest
public class CouponToCreateAccoAndOppTest {
    static testmethod void test1() {
        Apex_Trigger_On_Off__c tr = new Apex_Trigger_On_Off__c();
        tr.Name = 'CouponToCreateAccoAndOpp';
        tr.isEnable__c = true;
        insert tr;
        
        Product2 p = new Product2();
        p.Name = 'Bulk Sales Coupon-Vidanta';
        p.isActive = true;
        insert p;
        
        id pricebookId = Test.getStandardPricebookId();
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = p.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 pb = new Pricebook2();
        pb.isActive = true;
        pb.Name = 'Standard Pricebook';
        insert pb;
        
        Coupon__c cup = new Coupon__c();
        cup.Street__c = 'State';
        cup.City__c = 'BG';
        cup.Zip_Code__c = '258125';
        cup.State__c = 'AK';
        cup.Country__c = 'US';
        insert cup;
        
        cup.Name__c = 'UNIQKEYCOUPN101';
        cup.Phone_Number__c = '258258152';
        cup.Email__c = 'THUMARMITUL@GMAIL.COM';
        update cup;
        
    }
}