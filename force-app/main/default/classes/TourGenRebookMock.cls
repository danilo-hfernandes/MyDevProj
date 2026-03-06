@isTest 
global class TourGenRebookMock implements HttpCalloutMock {
    // Implement this interface method 
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
     
       
        // Create a fake response 
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "inputs":[ { "salesCadenceNameOrId":"Tour Gen-Vacation VIP 8/7 Expired", "targetId":"0035j00000Hw5q3AAB" } ] }');
        res.setStatusCode(200);
        return res;
    }
}