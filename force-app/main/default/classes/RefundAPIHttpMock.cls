@isTest
global class RefundAPIHttpMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"IsValid": true, "message": "Refund processed successfully"}');
        res.setStatusCode(200);
        return res;
    }
}