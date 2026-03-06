public class ChangeTargetAssigneeQueueable implements Queueable {
    
     Set<Id> recordIds;
     String userid=System.Label.NewOwner_ChangingAssignee;
    public ChangeTargetAssigneeQueueable(Set<Id> recordIds) {
        system.debug('5='+recordIds.size());
        this.recordIds = recordIds;
    }
    public void execute(QueueableContext context) {        
        for(Id conId : recordIds) {
            system.debug('10='+conId);
            sendRequest(conId, this.userid);
        }
    }
    
    @future(callout=true)
     private static void sendRequest(String targetId, String userid) {
       system.debug('23');
       String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
       String actionsRestURL = sfdcURL + '/services/data/v50.0/actions';
       String removeTargetRESTUrl = actionsRestURL + '/standard/changeSalesCadenceTargetAssignee';

       HttpRequest httpReq = new HttpRequest();
       httpReq.setMethod('POST');
       httpReq.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
       httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
       httpReq.setEndpoint(removeTargetRESTUrl);
       httpReq.setHeader('Content-Type', 'application/json');
       httpReq.setBody('{"inputs" : [{"userId" : "' + userid + '", "targetId" : "' + targetId + '"}]}');

       String response = '';
       try {
           system.debug('38');
           Http http = new Http();
           HttpResponse httpResponse = http.send(httpReq);
           System.debug('httpResponse ' + httpResponse);
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