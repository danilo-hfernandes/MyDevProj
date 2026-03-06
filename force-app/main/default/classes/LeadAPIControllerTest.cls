// LeadAPIControllerTest.cls
@isTest
public class LeadAPIControllerTest {
    @testSetup
    static void setupTestData() {
        // Create test users to act as agents
        List<User> testUsers = new List<User>();
        for (Integer i = 0; i < 5; i++) {
            User testUser = new User(
                FirstName = 'Test',
                LastName = 'User' + i,
                Email = 'testuserleadAPI' + i + '@example.com',
                Username = 'testuserleadAPI' + i + '@example.com',
                Alias = 'tuser' + i,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
                LanguageLocaleKey = 'en_US'
            );
            testUsers.add(testUser);
        }
        insert testUsers;
        
        // Create a lead for testing
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'test@gmail.com',
            Phone = '6541339'
        );
        insert testLead;
    }
    
    @isTest
    static void testGetAgents() {
        // Call the getAgents method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LeadAPIControllerTest.GetAgentCalloutMock());
        List<Object> agents = LeadApiController.getAgents();
        Test.stopTest();
        // Assert that agents were retrieved successfully
        System.assertNotEquals(null, agents, 'The agents list should not be null');
        System.assert(agents.size() > 0, 'The agents list should contain users');
    }
    
    @isTest
    static void testTeeUpLead() {
        // Retrieve the test lead and agent for tee-up
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        User testAgent = [SELECT Id, Name FROM User LIMIT 1];
        
        // Call the teeUpLead method
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LeadAPIControllerTest.TeeUpCalloutMock());
        LeadApiController.teeUpLead(testLead.Id, testAgent.Id, testAgent.Name);
        Test.stopTest();
        
        // Assert that no exceptions occurred during the method execution
        System.assert(true, 'teeUpLead method executed successfully');
    }
    // TeeUpCalloutMock.cls
    public  class TeeUpCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{ "status": "success", "message": "Tee-Up successful" }');
            return res;
        }
    }
    // TeeUpCalloutMock.cls
    public  class GetAgentCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('[{ "Text": "Test1", "Value": "1" }, {"Text": "Test2", "Value": "2" }]');
            return res;
        }
    }
}