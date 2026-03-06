public class OM {
@future (callout=true)
public static void sendLead (String dataToSend) {
    HttpRequest req = new HttpRequest();
    req.setEndpoint('https://services.oberholtzermedia.com/leads/ringcentral');
    req.setMethod('POST');
    req.setHeader('content-type', 'application/json');
    req.setHeader('accountId', '20740001');
    req.setHeader('campaignId', '266178');
    req.setBody(dataToSend);
    Http http = new Http();
    http.send(req);   
}
}