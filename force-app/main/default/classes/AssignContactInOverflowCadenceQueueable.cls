public class AssignContactInOverflowCadenceQueueable implements Queueable {
    Set<Id> ContactrecordsId;
     public AssignContactInOverflowCadenceQueueable(Set<Id> contactId) {
        system.debug('5='+contactId.size());
        this.ContactrecordsId = contactId;
    }
    public void execute(QueueableContext context) {   
        sendRequest1(ContactrecordsId); 
     }
    
    
    @future(callout=true)
    private static void sendRequest1(Set<Id> ContactrecordsIdSet) {
        if(ContactrecordsIdSet != null){
            String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
            String actionsRestURL = sfdcURL + '/services/data/v45.0/actions';
            String assignTargetRESTUrl = actionsRestURL + '/standard/assignTargetToSalesCadence';
            
            List<Contact> NewContactList = [select id,Account.Enrollment_Date__c from Contact where Id In : ContactrecordsIdSet];
            for(Contact con : NewContactList){
                HttpRequest httpReq = new HttpRequest();
                httpReq.setMethod('POST');
                httpReq.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
                httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                httpReq.setEndpoint(assignTargetRESTUrl);
                httpReq.setHeader('Content-Type', 'application/json');
                
              
                
                // B-08601 - Mitul - One time run - then comment out
                // 2022-06-21 > 2022-05-20 && 2022-06-21 < 2022-05-20
                system.debug('--con.Account.Enrollment_Date__c--'+con.Account.Enrollment_Date__c);
                if(con.Account.Enrollment_Date__c == system.today() -51){
                     httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "HCMU-High Velocity 51 Days", "targetId" : "' + con.Id + '"}]}');
                     system.debug('-sendRequest-'+con.id);
                    
                }
                else if(con.Account.Enrollment_Date__c == system.today() - 90){
                     httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "HCMU-High Velocity 90 Days", "targetId" : "' + con.Id + '"}]}');
                     //sendRequest(con.id, 'HCMU-High Velocity 90 Days');
                     system.debug('--con.Account.Enrollment_Date__c--'+con.Account.Enrollment_Date__c);
                 }
                String response = '';
                try {
                    Http http = new Http();
                    HttpResponse httpResponse = http.send(httpReq);
                    if (httpResponse.getStatusCode() == 200) {
                        response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                    } else {
                        System.debug('http response: ' + httpResponse.getBody());
                        //throw new CalloutException(httpResponse.getBody());
                    }
                } catch (System.Exception e) {
                    System.debug('ERROR! ' + e);
                    //throw e;
                }
            }
        }
        
    } 
}