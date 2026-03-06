@isTest
Global class MockMembershipDataSyncToBE implements HTTpCalloutMock {

   global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        //
        
        //SendToCyberSource.ParamTransaction pt = new SendToCyberSource.ParamTransaction(); 
            
        HttpResponse res = new HttpResponse();
        res.setHeader('content-type','application/json');
        res.setHeader('api-key', 'asfasd2323');
        res.setBody('{"Message":"error"}');
        res.setStatusCode(404);
        return res;
    } 
    
}