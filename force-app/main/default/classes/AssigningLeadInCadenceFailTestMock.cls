@isTest 
global class AssigningLeadInCadenceFailTestMock implements HttpCalloutMock {    
    // Implement this interface method 
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.        
        
        // Create a fake response 
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"actionName":"assignTargetToSalesCadence","errors":[{"statusCode":"INVALID_API_INPUT","message":"The target assignee doesnt have any Sales Engagement permissions.","fields":[]}],"isSuccess":false,"outputValues":{"error":"The target assignee doesnt have any Sales Engagement permissions."}}');
        res.setStatusCode(400);
        return res;
    }    
}