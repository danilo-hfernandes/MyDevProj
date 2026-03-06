@isTest
public class CallDataComponentControllerTest {
	@isTest
    static void getDataTest(){
        Lead leadrec = new Lead();
        leadrec.LastName = 'test';
        leadrec.Company = 'test';
        leadrec.LeadSource = 'CFD FB';
        leadrec.Phone = '1234567891';
        leadrec.Email = 'test@ds.com';
        insert leadrec;

		Test.setMock(HttpCalloutMock.class, new CallDataComponentControllerTest.CallDataComponentMockAPI());
        Test.startTest();
        CallDataComponentController.getAICallEvents(leadrec.Id);
        
        Test.stopTest();
		
    }
	public class CallDataComponentMockAPI implements HTTpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            
            HttpResponse res = new HttpResponse();
            res.setHeader('content-type','application/json');
            res.setHeader('api-key', 'asfasd2323');
            res.setBody('[{"media" : "AI Call", "date": "2025-05-19T18:45:43.653", "disposition":"Call Connected", "events": [{}]}]');
            	
            res.setStatusCode(200);
            return res;
        }   
    }
}