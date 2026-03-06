@isTest
public class DNCAPICallControllerTest {

    @isTest
    static void sendDNCRequestTest() {
        // Create a test Lead
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            LeadSource = 'CFD FB',
            Phone = '1234567891',
            Email = 'test@ds.com'
        );
        insert testLead;

        // Set mock for HTTP callout
        Test.setMock(HttpCalloutMock.class, new DNCAPICallControllerMockAPI());

        Test.startTest();
            // Call the future method
            DNCAPICallController.sendDNCRequest(testLead.Id);
        Test.stopTest();

        // Query ContentDocumentLink to check if note was created
        List<ContentDocumentLink> links = [
            SELECT Id, ContentDocument.Title, LinkedEntityId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :testLead.Id
        ];

        System.assertEquals(1, links.size(), 'One ContentNote should be linked to the Lead');
        System.assertEquals('Do Not Call Updated', links[0].ContentDocument.Title, 'The ContentNote title should match');
    }

    // Mock HTTP response
    public class DNCAPICallControllerMockAPI implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status":"OK"}');
            res.setStatusCode(200);
            return res;
        }
    }
}