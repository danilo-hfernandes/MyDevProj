public class RemoveTrackerFromSalesCadenceQueueable implements Queueable, Database.AllowsCallouts {

    private final Set<Id> trackerIds;
    private final String completionReasonCode;

    // Default reason kept as "ManuallyRemoved", but allow override if needed
    public RemoveTrackerFromSalesCadenceQueueable(Set<Id> actionCadenceTrackerIds, String completionReasonCodeOpt) {
        System.debug('RemoveTrackerFromSalesCadenceQueueable: received ' + actionCadenceTrackerIds.size() + ' trackerIds');
        this.trackerIds = new Set<Id>(actionCadenceTrackerIds);
        this.completionReasonCode = String.isBlank(completionReasonCodeOpt) ? 'ManuallyRemoved' : completionReasonCodeOpt;
    }

    public void execute(QueueableContext context) {
        for (Id trackerId : trackerIds) {
            System.debug('Processing actionCadenceTrackerId=' + trackerId);
            callRemoveByTracker(trackerId, completionReasonCode);
        }
    }

    @TestVisible
    private static String buildRequestBody(String trackerId, String reason) {
        return '{"inputs":[{"completionReasonCode":"' + String.escapeSingleQuotes(reason) + '",'
             + '"actionCadenceTrackerId":"' + String.escapeSingleQuotes(trackerId) + '"}]}';
    }

    private static void callRemoveByTracker(Id trackerId, String reason) {       
        String sfdcURL = URL.getOrgDomainUrl().toExternalForm();

        // Build endpoint for removeTargetFromSalesCadence action
        String endpoint = sfdcURL + '/services/data/v63.0/actions/standard/removeTargetFromSalesCadence';

        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setBody(buildRequestBody((String)trackerId, reason));

        Http http = new Http();
        try {
            HttpResponse res = http.send(req);
            System.debug('removeTargetFromSalesCadence status=' + res.getStatus() + ' code=' + res.getStatusCode());
            System.debug('response body=' + res.getBody());

            if (res.getStatusCode() != 200) {
                throw new CalloutException('Failed to remove from cadence for trackerId ' + trackerId + '. Body: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('ERROR removing from cadence for trackerId ' + trackerId + ': ' + e.getMessage());
            throw e;
        }
    }
}