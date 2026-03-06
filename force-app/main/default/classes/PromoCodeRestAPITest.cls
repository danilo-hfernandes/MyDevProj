@istest
public class PromoCodeRestAPITest{
    static testMethod void testGet() {
        Promotional_Code__c pm = new Promotional_Code__c();
        pm.Name = 'Test prmo code test classes';
        pm.Status__c = 'Active';
        insert pm;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.httpMethod = 'Get';
        req.requestURI= 'https://holidaysystems--partial.my.salesforce.com/services/apexrest/Promotionalcode/'+pm.Name;
        system.debug('req.requestURI----'+req.requestURI);
        RestContext.request = req;
        RestContext.response= res;
        PromoCodeRestAPI.PromocodeResponseWrapper.promoCodeQueryReturn();
        PromoCodeRestAPI.PromocodeResponseWrapper wrper = new PromoCodeRestAPI.PromocodeResponseWrapper(); 
        
    }
    static testMethod void testGet2() {
        // Create promo code record
        Promotional_Code__c pm = new Promotional_Code__c();
        pm.Name = 'Test prmo code test classes s';
        insert pm;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.httpMethod = 'Get';
        req.requestURI= 'https://holidaysystems--partial.my.salesforce.com/services/apexrest/Promotionalcode/'+pm.Name;
        system.debug('req.requestURI----'+req.requestURI);
        RestContext.request = req;
        RestContext.response= res;
        
        PromoCodeRestAPI.PromocodeResponseWrapper.promoCodeQueryReturn();
        PromoCodeRestAPI.PromocodeResponseWrapper wrper = new PromoCodeRestAPI.PromocodeResponseWrapper(); 
    }
}