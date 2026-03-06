@isTest
public class GetEmailDataTest {
    
    // Test class to mock HTTP responses
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);

            // Mock response body
            String mockResponseBody = '{ "Result": { "TotalPages": 3, "Emails": [ { "Id": "02s4z00001xHJ4MAAW", "Subject": "Test Email Subject", "FromAddress": "test@example.com", "MessageDate": "2023-11-29T10:15:30Z", "HtmlBody": "<p>Test email body</p>" } ] } }';
            response.setBody(mockResponseBody);

            return response;
        }
    }
    
    @isTest
    static void testSendRequest() {
        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create mock data
        Id mockRecordId = Id.valueOf('001000000000001'); // Replace with a valid Id structure if necessary
        Integer mockPage = 1;
        
        Test.startTest();
        // Call the method
        String result = GetEmailData.sendRequest(mockRecordId, mockPage);
        Test.stopTest();
        
        // Validate the result
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Parse the result to validate JSON structure
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(responseMap.containsKey('Result'), 'Response should contain "Result" key');
        
        Map<String, Object> resultData = (Map<String, Object>) responseMap.get('Result');
        System.assertEquals(3, Integer.valueOf(resultData.get('TotalPages')), 'TotalPages should match the mock data');
        
        List<Object> emails = (List<Object>) resultData.get('Emails');
        System.assert(emails.size() > 0, 'Emails list should not be empty');
        
        Map<String, Object> firstEmail = (Map<String, Object>) emails[0];
        System.assertEquals('Test Email Subject', firstEmail.get('Subject'), 'Subject should match the mock data');
        System.assertEquals('test@example.com', firstEmail.get('FromAddress'), 'FromAddress should match the mock data');
    }
    
    
    @isTest
    static void testSendRequestAcoustic() {
        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create mock data
        Id mockRecordId = Id.valueOf('001000000000001'); // Replace with a valid Id structure if necessary
        Integer mockPage = 1;
        
        Test.startTest();
        // Call the method
        String result = GetEmailData.sendRequestAcoustic(mockRecordId, mockPage);
        Test.stopTest();
        
        // Validate the result
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Parse the result to validate JSON structure
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(responseMap.containsKey('Result'), 'Response should contain "Result" key');
        
        Map<String, Object> resultData = (Map<String, Object>) responseMap.get('Result');
        System.assertEquals(3, Integer.valueOf(resultData.get('TotalPages')), 'TotalPages should match the mock data');
        
        List<Object> emails = (List<Object>) resultData.get('Emails');
        System.assert(emails.size() > 0, 'Emails list should not be empty');
        
        Map<String, Object> firstEmail = (Map<String, Object>) emails[0];
        System.assertEquals('Test Email Subject', firstEmail.get('Subject'), 'Subject should match the mock data');
        System.assertEquals('test@example.com', firstEmail.get('FromAddress'), 'FromAddress should match the mock data');
    }
    
    
    
    @isTest
    static void testsendRequestInvoice() {
        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create mock data
        Id mockRecordId = Id.valueOf('0013t00001bI5ppAAC'); // Replace with a valid Id structure if necessary
        Integer mockPage = 1;
         
        Test.startTest();
        // Call the method
        String result = GetEmailData.sendRequestInvoice(mockRecordId, mockPage);
        Test.stopTest();
        
        // Validate the result
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Parse the result to validate JSON structure
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(responseMap.containsKey('Result'), 'Response should contain "Result" key');
        
        Map<String, Object> resultData = (Map<String, Object>) responseMap.get('Result');
        System.assertEquals(3, Integer.valueOf(resultData.get('TotalPages')), 'TotalPages should match the mock data');
        
        List<Object> emails = (List<Object>) resultData.get('Emails');
        System.assert(emails.size() > 0, 'Emails list should not be empty');
        
        Map<String, Object> firstEmail = (Map<String, Object>) emails[0];
        System.assertEquals('Test Email Subject', firstEmail.get('Subject'), 'Subject should match the mock data');
        System.assertEquals('test@example.com', firstEmail.get('FromAddress'), 'FromAddress should match the mock data');
    }
    
    
        
    @isTest
    static void testSendRequestSingleEmail() {
        // Set up mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create mock data
        Id mockRecordId = Id.valueOf('001000000000001'); // Replace with a valid Id structure if necessary
        Integer mockPage = 1;
        
        Test.startTest();
        // Call the method
        String result = GetEmailData.sendRequestSingleEmail(mockRecordId, mockPage);
        Test.stopTest();
        
        // Validate the result
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Parse the result to validate JSON structure
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(responseMap.containsKey('Result'), 'Response should contain "Result" key');
        
        Map<String, Object> resultData = (Map<String, Object>) responseMap.get('Result');
        System.assertEquals(3, Integer.valueOf(resultData.get('TotalPages')), 'TotalPages should match the mock data');
        
        List<Object> emails = (List<Object>) resultData.get('Emails');
        System.assert(emails.size() > 0, 'Emails list should not be empty');
        
        Map<String, Object> firstEmail = (Map<String, Object>) emails[0];
        System.assertEquals('Test Email Subject', firstEmail.get('Subject'), 'Subject should match the mock data');
        System.assertEquals('test@example.com', firstEmail.get('FromAddress'), 'FromAddress should match the mock data');
    }
    
    
        
    
    
}