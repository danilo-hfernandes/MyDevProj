public class tourVidaQueueable implements Queueable {
    Set<Id> cadenceContactsId;
    public tourVidaQueueable(Set<Id> cadenceContactsId) {
        system.debug('5='+cadenceContactsId.size());
        this.cadenceContactsId = cadenceContactsId;
    }
    public void execute(QueueableContext context) {   
        sendRequest1(cadenceContactsId); 
       /* for(Contact con : contactRecords) {
            system.debug('10='+con);
            if(con.Tour_Vida_Active_SSR_Match_Group__c=='TRUE'){
            sendRequest(con.id, 'TourGen-Vida Owners-Active');
            }
            else if(con.Tour_Vida_Inactive_SSR_Match_Group__c=='TRUE'){
            sendRequest(con.id, 'TourGen-Vida Owners-Inactive');
            }
        }*/
    }
    @future(callout=true)
    private static void sendRequest1(Set<Id> ContactrecordsIdSet) {
        system.debug('15 Future');
        if(ContactrecordsIdSet != null){
            String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
            String actionsRestURL = sfdcURL + '/services/data/v45.0/actions';
            String assignTargetRESTUrl = actionsRestURL + '/standard/assignTargetToSalesCadence';
            List<Contact> NewContactList = [select id,Tour_Vida_Inactive_SSR_Match_Group__c,Tour_Vida_Active_SSR_Match_Group__c from Contact where Id In : ContactrecordsIdSet];
            for(Contact con : NewContactList){
                HttpRequest httpReq = new HttpRequest();
                httpReq.setMethod('POST');
                httpReq.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
                httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                httpReq.setEndpoint(assignTargetRESTUrl);
                httpReq.setHeader('Content-Type', 'application/json');
                //httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "' + salesCadenceNameOrId + '", "targetId" : "' + targetId + '"}]}');
                if(con.Tour_Vida_Active_SSR_Match_Group__c=='TRUE'){
                     httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "TourGen-Vida Owners-Active", "targetId" : "' + con.Id + '"}]}');
                     
                }
                /*else if(con.Tour_Vida_Inactive_SSR_Match_Group__c=='TRUE'){
                     httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "TourGen-Vida Owners-Inactive", "targetId" : "' + con.Id + '"}]}');
                  }*/
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
                   // throw e;
                }
                
                System.debug('response: ' + response);    
            }
        }
    }
}