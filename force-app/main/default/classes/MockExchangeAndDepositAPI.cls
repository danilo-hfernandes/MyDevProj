@isTest
Global class MockExchangeAndDepositAPI implements HTTpCalloutMock {

   global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('content-type','application/json');
        res.setHeader('api-key', 'asfasd2323');
        res.setBody('[{"companyId":100548,"trackingCode":"86","companyName":"Accommodations Unlimited (Advantage Travel) (86)"},{"companyId":1000281,"trackingCode":"714","companyName":"All Points Vacations, LLC. (714)"}]');
       
        res.setStatusCode(200);
        return res;
    } 
    
}