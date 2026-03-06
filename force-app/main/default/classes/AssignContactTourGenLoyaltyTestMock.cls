@isTest 
global class AssignContactTourGenLoyaltyTestMock implements HttpCalloutMock {
    // Implement this interface method 
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
     
       
        // Create a fake response 
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "inputs":[ { "salesCadenceNameOrId":"TourGen-SMTN Loyalty Survey", "targetId":"003530000089mw4AAA" } ] }');
        res.setStatusCode(200);
        return res;
    }
}