public class AssignTargetsToActionCadenceQueueble implements Queueable {
    List<ActionCadenceStepTracker> actionCadenceRecords;
    
    public AssignTargetsToActionCadenceQueueble(List<ActionCadenceStepTracker> actions) {
        this.actionCadenceRecords = actions;
    }

    public void execute(QueueableContext context) {  
        for (ActionCadenceStepTracker tracker : actionCadenceRecords) {
            assignTargetToSalesCadence(tracker.TargetId, tracker.ActionCadenceId);
        }        
    }

@future(callout=true)
public static void assignTargetToSalesCadence(String targetId, String actionCadenceId) {
    // Use System.Url.getOrgDomainUrl() to get the base URL dynamically
    String sfdcURL = System.Url.getOrgDomainUrl().toExternalForm();
    String actionsRestURL = sfdcURL + '/services/data/v58.0/actions';
    String assignTargetRESTUrl = actionsRestURL + '/standard/assignTargetToSalesCadence';
    
    HttpRequest httpReq = new HttpRequest();
    httpReq.setMethod('POST');
    httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    httpReq.setEndpoint(assignTargetRESTUrl);
    httpReq.setHeader('Content-Type', 'application/json');
    httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "' + actionCadenceId + '", "targetId" : "' + targetId + '"}]}');
    
    try {
        Http http = new Http();
        HttpResponse httpResponse = http.send(httpReq);
        if (httpResponse.getStatusCode() != 200) {
            System.debug('Callout Error: ' + httpResponse.getBody());
        }
    } catch (Exception e) {
        System.debug('Exception in HTTP Callout: ' + e.getMessage());
    }
}
    
    
}