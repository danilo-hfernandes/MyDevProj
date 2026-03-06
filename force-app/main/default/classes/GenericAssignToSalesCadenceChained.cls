public class GenericAssignToSalesCadenceChained implements Queueable, Database.AllowsCallouts {
/* Purpose:
 * This Queueable class assigns Contacts to a Sales Cadence in small batches (50 records at a time),
 * by calling the Salesforce Engage API endpoint `/actions/standard/assignTargetToSalesCadence`.
 * It is used to avoid hitting the governor limit on future callouts and ensures callouts are made within platform limits.
 *
 * Key Features:
 * - Batches the input records using `startIndex` and `batchSize`.
 * - Calls the external API using synchronous callouts with `HttpRequest`.
 * - Designed to be invoked by a driver class like `AssignCadenceWithChaining`.
 *
 * Important Notes:
 * - This class does not chain itself — chaining is handled by the driver class.
 * - It uses `Database.AllowsCallouts` to enable callouts from within Queueable context.
 * - Salesforce enforces a 1 `enqueueJob()` limit per execution, so chaining must be externally managed.
 */

    
    private List<Id> allIds;
    private String salesCadenceName;
    private Integer startIndex;
    private Integer batchSize = 50; // Safe chunk size

    public GenericAssignToSalesCadenceChained(Set<Id> recordIds, String salesCadenceName, Integer startIndex) {
        this.allIds = new List<Id>(recordIds);
        this.salesCadenceName = salesCadenceName;
        this.startIndex = startIndex;
    }

    public void execute(QueueableContext context) {
        List<Id> batchIds = new List<Id>();

        Integer endIndex = Math.min(startIndex + batchSize, allIds.size());
        for (Integer i = startIndex; i < endIndex; i++) {
            batchIds.add(allIds[i]);
        }

        System.debug('Processing ' + batchIds.size() + ' contacts for cadence: ' + salesCadenceName);

        for (Id contactId : batchIds) {
            sendRequest(contactId, salesCadenceName);
        }

        // Chain the next job if there are more IDs to process
        if (endIndex < allIds.size()) {
            System.enqueueJob(new GenericAssignToSalesCadenceChained(
                new Set<Id>(allIds), salesCadenceName, endIndex
            ));
        }
    }

    private void sendRequest(String targetId, String salesCadenceNameOrId) {
//        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        String baseUrl = System.Url.getOrgDomainUrl().toExternalForm();
        String assignUrl = baseUrl + '/services/data/v45.0/actions/standard/assignTargetToSalesCadence';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(assignUrl);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{"inputs" : [{"salesCadenceNameOrId" : "' + salesCadenceNameOrId + '", "targetId" : "' + targetId + '"}]}');

        try {
            HttpResponse res = new Http().send(req);
            if (res.getStatusCode() != 200) {
                System.debug('Failed for ' + targetId + ': ' + res.getBody());
                
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();                    
                String[] sendingTo = new String[]{'danilo.fernandes@nerdsoft.com','cicero.schoeps@nerdsoft.com'};
				semail.setCcAddresses(new String[]{UserInfo.getuserid()});
				semail.setToAddresses(sendingTo); 
				semail.setSubject('GenericAssignToSalesCadenceChained Failed'); 
				semail.setPlainTextBody('GenericAssignToSalesCadenceChained failed ' + ' ContactId : '+ targetId );
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                
            }
        } catch (Exception ex) {
            System.debug('Exception for ' + targetId + ': ' + ex.getMessage());

            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();                    
            String[] sendingTo = new String[]{'danilo.fernandes@nerdsoft.com','cicero.schoeps@nerdsoft.com'};
                semail.setCcAddresses(new String[]{UserInfo.getuserid()});
            semail.setToAddresses(sendingTo); 
            semail.setSubject('GenericAssignToSalesCadenceChained Failed'); 
            semail.setPlainTextBody('GenericAssignToSalesCadenceChained failed ' + ' ContactId : '+ targetId  + ' Message: ' + ex.getMessage());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 

        }
    }
}