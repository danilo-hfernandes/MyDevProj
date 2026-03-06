@isTest
private class TripPilotGetURLTest {
    
    // Mock class to simulate the HTTP response
    private class TripPilotHttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            System.assertEquals('POST', req.getMethod());
            System.assertEquals('https://webapi.trippilot.com/api/User/SsoUserLogin', req.getEndpoint());
            
            // Create a mock response similar to the real API response
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"message": "Login Successfully.", "code": 200, "data": {"domainURL": "https://vi.trippilot.com?Token=mockedToken"}}');
            return res;
        }
    }

    @isTest
    static void testGetTripPilotURL() {
        // Enable HTTP callout mock
        Test.setMock(HttpCalloutMock.class, new TripPilotHttpMock());
        
        // Create an Account with required fields
        Account acc = new Account(
            Name = 'Test Account',
            Email__c = 'test@example.com',
            Member_Number__c = '123456'
        );
        insert acc;
        
        // Create a Case linked to the Account
        Case testCase = new Case(
            Subject = 'Test Case',
            //ContactEmail = 'test@example.com',
            AccountId = acc.Id
        );
        insert testCase;
        
        // Call the method
        Test.startTest(); // All callouts must happen inside this
        List<String> result = TripPilotGetURL.getTripPilotURL(new List<Id>{ testCase.Id });
        Test.stopTest(); // Ensures the callout executes properly
        
        system.debug('result[0]:'+result[0]);

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Response list should have at least one item');
        System.assert(result[0].contains('https://vi.trippilot.com?Token=mockedToken'), 'Response should contain the expected URL');
    }
    
    
    @isTest
    static void testGetTripPilotURL2() {
        // Enable HTTP callout mock
        Test.setMock(HttpCalloutMock.class, new TripPilotHttpMock());
        
        // Create an Account with required fields
        Account acc = new Account(
            Name = 'Test Account',
            Email__c = 'test@example.com',
            Member_Number__c = ''
        );
        insert acc;
        
        // Create a Case linked to the Account
        Case testCase = new Case(
            Subject = 'Test Case',
            //ContactEmail = 'test@example.com',
            AccountId = acc.Id
        );
        insert testCase;
        
        // Call the method
        List<String> result = TripPilotGetURL.getTripPilotURL(new List<Id>{ testCase.Id });

        // Assertions
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Response list should have at least one item');
        System.assert(result[0].contains('Error: Missing Email or Member Number.'), 'Email not sent');
    }
    
    
}