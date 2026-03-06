@isTest 
global class SFXOppBatchTestMock implements HttpCalloutMock {
    // Implement this interface method 
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
     
       
        // Create a fake response 
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "inputs":[ { "salesCadenceNameOrId":"Membership Upgrade-SFX Overflow", "targetId":"0035j00000Hw5q3AAB" } ] }');
        res.setStatusCode(200);
        return res;
    }
}