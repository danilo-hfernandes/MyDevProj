@isTest
Global class MockPaymentAPIFailed implements HTTpCalloutMock {

   global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        //
        
        //SendToCyberSource.ParamTransaction pt = new SendToCyberSource.ParamTransaction(); 
            
        HttpResponse res = new HttpResponse();
        res.setHeader('content-type','application/json');
        res.setHeader('api-key', 'asfasd2323');
        res.setBody('{"message":"service unavailable"}');
        //res.setBody('{"IsValid": true,"Message": null,"Data": true}');
        res.setStatusCode(504);
        return res;
    } 
    
}