public class GenericAssignToSalesCadence implements Queueable, Database.AllowsCallouts {
	Set<Id> recordIds;
    String salesCadenceName;
    public GenericAssignToSalesCadence(Set<Id> recordIds, String salesCadenceName) {
        this.recordIds = recordIds;
        this.salesCadenceName = salesCadenceName;
    }
    public void execute(QueueableContext context) {        
        for(Id conId : recordIds) {
            sendRequest(conId, this.salesCadenceName);
        }
    }
    //@future(callout=true) 
    private static void sendRequest(String targetId, String salesCadenceNameOrId) {
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String actionsRestURL = sfdcURL + '/services/data/v45.0/actions';
        String assignTargetRESTUrl = actionsRestURL + '/standard/assignTargetToSalesCadence';
        
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('POST');
        httpReq.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        httpReq.setEndpoint(assignTargetRESTUrl);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "' + salesCadenceNameOrId + '", "targetId" : "' + targetId + '"}]}');
        
        String response = '';
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpReq);
            if (httpResponse.getStatusCode() == 200) {
                response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
            } else {
                System.debug('http response: ' + httpResponse.getBody());
                throw new CalloutException(httpResponse.getBody());
            }
        } catch (System.Exception e) {
            System.debug('ERROR! ' + e);
            throw e;
        }
        
        System.debug('response: ' + response);     
    }
}