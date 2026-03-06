// Mock HttpResponse generator class for HTTP callouts addCreditonRedemptionControllerTest
public class MockHttpResponseGenerator implements HttpCalloutMock {
    private HttpResponse mockResponse;

    public MockHttpResponseGenerator(HttpResponse response) {
        this.mockResponse = response;
    }

    public HTTPResponse respond(HTTPRequest req) {
        return mockResponse;
    }
}