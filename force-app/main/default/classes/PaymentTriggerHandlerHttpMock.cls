/**
 * HTTP Callout Mock for PaymentTriggerHandler @future callouts.
 * Returns 200 OK or 201 Created so handler code paths execute without real callouts.
 */
@isTest
global class PaymentTriggerHandlerHttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String body = req.getBody();
        // EarnCreditsContacts expects 201 Created
        if (req.getEndpoint() != null && req.getEndpoint().contains('EarnCreditsContacts')) {
            res.setStatusCode(201);
            res.setStatus('Created');
        } else {
            res.setStatusCode(200);
            res.setStatus('OK');
        }
        res.setBody('{}');
        return res;
    }
}
