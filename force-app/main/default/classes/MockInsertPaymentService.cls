@isTest
Global class MockInsertPaymentService implements HTTpCalloutMock {

   global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        //
        
        //SendToCyberSource.ParamTransaction pt = new SendToCyberSource.ParamTransaction(); 
            
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        res.setBody('{"key":OpportunityId,"value":"0062f00000DSXtXAAX","description":""},{"key":Amount,"value":"100","description":""}');
        res.setStatusCode(200);
        return res;
    } 
    
}