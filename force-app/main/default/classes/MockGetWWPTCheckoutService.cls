@isTest
Global class MockGetWWPTCheckoutService implements HTTpCalloutMock{
	  global HTTPResponse respond(HTTPRequest req) {
            
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody('{"key":myEnvelopId,"value":"49314a3e-9bd7-4831-8497-e697480fa6db","description":""}');
        res.setStatusCode(200);
        return res; 
    } 
}