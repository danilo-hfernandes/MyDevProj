@IsTest
global class AcousticHttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);

        // Mock responses based on the endpoint content
        if (req.getEndpoint().contains('/oauth/token')) {
            res.setBody('{"access_token": "mockAccessToken", "expires_in": 14400}');
        } else if (req.getBody().contains('SelectRecipientData')) {
            res.setBody('<Envelope><Body><RESULT><SUCCESS>TRUE</SUCCESS><RecipientId>12345</RecipientId></RESULT></Body></Envelope>');
        } else if (req.getBody().contains('AddContactToProgram')) {
            res.setBody('<Envelope><Body><RESULT><SUCCESS>TRUE</SUCCESS></RESULT></Body></Envelope>');
        } else {
            res.setBody('<Envelope><Body><RESULT><SUCCESS>TRUE</SUCCESS></RESULT></Body></Envelope>');
        }
        return res;
    }
}