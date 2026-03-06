@isTest
public class certificateTriggerHandlerTest {
    @isTest
    static void Test1() {
        Certificate__c objcert = new Certificate__c();
        objcert.Coupon_Type__c = 'Cancun Card Add On SPA';
        objcert.Certificate_ID__c = 'Test00';
        insert objcert;
        
        Certificate__c objcert1 = new Certificate__c();
        objcert1.Coupon_Type__c = 'Cancun Card Add On SPA';
        objcert1.Certificate_ID__c = 'Test01';
        insert objcert1;
        
        objcert.Certificate_Redeemed__c = true;
        update objcert;
    }
}