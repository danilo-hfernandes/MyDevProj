@isTest
public class SendOpportunityDataMock implements HttpCalloutMock {

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('content-type','application/json');
        res.setBody('{\"data\":[{\"event_name\":\"Purchase\",\"action_source\":\"system_generated\",\"user_data\":{\"em\":[\"wllmredman57@gmail.com\"],\"ph\":[\"2402051108\"],\"fn\":[\"William\"],\"ln\":[\"Redman\"],\"external_id\":[\"00Q4z0000202xnN\"]},\"custom_data\":{\"currency\":\"USD\",\"value\":\"333.59\"}}]}');
        res.setStatusCode(200);
        return res;
    }
}