@isTest
public class TourGenerationCtrlTest {
    static testmethod void test1(){
        String str = '{"FirstName": "D","LastName": "D", "Email": "ds@dd.com", "MainPhone":"123456789", "Address":"add","City":"Orlando","State":"Florida","Country":"United States of America","Zip":"12345"}';
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
System.debug('baseUrl =' + baseUrl);
        req.requestURI= baseUrl + '/services/apexrest/TourGenerationCtrl';
        system.debug('req.requestURI----'+req.requestURI);
        req.requestBody = Blob.valueOf(str);
        RestContext.request = req;
        RestContext.response= res;
        TourGenerationCtrl.createAccountRecord();
    }
}