@istest
public class PromoCodeAdminWebserviceTest {

    static testMethod void testGet() {
        Test.startTest();
        PromoCodeAdminWebservice ps = new PromoCodeAdminWebservice();  
        String JsonMsg='{"AutoId" : "0","PromoCodeName" : "Testing", "Status" : "Active", "Type" : "Test", "InvalidErrorMessage":"Testing", "ExpiredErrorMessage" : "Testing", }';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/promocodeadminWebservice/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        PromoCodeAdminWebservice.responsewrapper rp = new PromoCodeAdminWebservice.responsewrapper();
        
        PromoCodeAdminWebservice.createRecord();
        test.stopTest();
    }
    
        static testMethod void testGet2() {
        Test.startTest();
        PromoCodeAdminWebservice ps = new PromoCodeAdminWebservice();  
        String JsonMsg='{"AutoId":3,"PromoCodeName":"TestCreditsBack","Status":"Active","Type":"Resort","StartDate":"2022-12-05","ExpirationDate":"2022-12-09","CheckInDate":"2022-09-08","ExpiredErrorMessage":"TestExpiredErrorMessage","InvalidErrorMessage":"TestInvalidErrorMessage","CreatedBy":"","promoCodeDestinationSettings":[],"promoCodeResortSettings":[],"promoCodePriceRangeSettings":[{"AutoId":3,"PomoCodeAutoId":3,"MinPrice":0.0000,"MaxPrice":5000.0000,"DiscountType":"Percentage","DiscountAmout":10.00,"PriceRangeType":"CreditsBack","ApplyOthersCredits":true}]}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/promocodeadminWebservice/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        PromoCodeAdminWebservice.responsewrapper rp = new PromoCodeAdminWebservice.responsewrapper();
        
        PromoCodeAdminWebservice.createRecord();
        test.stopTest();
    }
    
    static testMethod void testGet3() {
        Test.startTest();
        PromoCodeAdminWebservice ps = new PromoCodeAdminWebservice();  
        String JsonMsg='{{"AutoId":3,"PromoCodeName":"TestCreditsBack","Status":"Active","Type":"Resort","StartDate":"2022-12-05","ExpirationDate":"2022-12-09","CheckInDate":"","ExpiredErrorMessage":"TestExpiredErrorMessage","InvalidErrorMessage":"TestInvalidErrorMessage","CreatedBy":"","promoCodeDestinationSettings":[],"promoCodeResortSettings":[],"PromoCodeApplication":"Test","promoCodePriceRangeSettings":[{"AutoId":3,"PomoCodeAutoId":3,"MinPrice":0.0000,"MaxPrice":5000.0000,"DiscountType":"Percentage","DiscountAmout":10.00,"PriceRangeType":"CreditsBack","ApplyOthersCredits":true}]}}';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = 'services/apexrest/promocodeadminWebservice/*';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;
        PromoCodeAdminWebservice.responsewrapper rp = new PromoCodeAdminWebservice.responsewrapper();
        
        PromoCodeAdminWebservice.createRecord();
        test.stopTest();
    }
}