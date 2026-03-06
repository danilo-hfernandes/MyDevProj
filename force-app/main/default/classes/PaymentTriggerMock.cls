@isTest
public class PaymentTriggerMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        // Providing both message keys used in your code
        res.setBody('{"message":"Error Message", "Message":"Error Message"}');
        res.setStatusCode(400); // Using 400 to trigger the email error blocks
        return res;
    }
}