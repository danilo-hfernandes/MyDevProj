@isTest
global class RefundAPIHttpMockError implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"IsValid": false, "message": "Refund failed"}');
        res.setStatusCode(400);
        return res;
    }
}