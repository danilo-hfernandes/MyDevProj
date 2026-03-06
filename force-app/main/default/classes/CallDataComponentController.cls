public with sharing class CallDataComponentController {

    @AuraEnabled
    public static List<CallEventWrapper> getAICallEvents(String recordId) {
        HttpRequest req = new HttpRequest();
        String endpoint = 'https://aidialerintegration.azurewebsites.net/api/CallEvent/by-source-salesforce/'+recordId;//'+recordId;//00Q4z00001xB1sSEAS';
//test VVA-162:
//String endpoint = 'https://aidialerintegration.azurewebsites.net/api/CallEvent/by-source-salesforce/00QVm00000LK7inMAD';
//String endpoint = 'https://aidialerintegration.azurewebsites.net/api/CallEvent/by-source-salesforce/00QVm00000LMUL7MAP';

        //Previous URL 2025-05-28 
        //String endpoint = 'https://aidialerintegration.azurewebsites.net/api/CallEvent/by-source/00Q4z00001xB1sSEAS';// + recordId;
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', 'Bearer OWDQj3uNYsNDIM0ixzhrDy4LwhHC425j4zkmXh1q1BrbaHTS2Av0nu7NtKo_CfgOnZqaf0phLF86lqtRbgXNsA');

        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req);
        } catch (Exception e) {
            throw new AuraHandledException('HTTP callout failed: ' + e.getMessage());
        }

        if (res.getStatusCode() == 200) {
            //String json = res.getBody().replace('"date"', '"createdOn"');
            List<CallEventWrapper> callEvents = (List<CallEventWrapper>) JSON.deserialize(res.getBody().replace('"date"', '"createdOn"'), List<CallEventWrapper>.class);
			System.debug('>>>callEvents>>'+callEvents);
            // Optional: Populate wrapper fields like summary/url from morganCall if not null
            /*for (CallEventWrapper event : callEvents) {
                if (event.events != null && event.activeEventId == null) {
                    for(EventsWrapper objevent : event.events){
                    	event.activeEventId = objevent.conversationId;
                    }
                    event.summary = event.events.summary;
                    event.transcript = event.events.transcript;
                    event.url = event.events.url;
                }
            }*/
          System.debug('API RESPONSE: ' + res.getBody());

            return callEvents;
        } else {
            throw new AuraHandledException('Failed to fetch AI call events. Status: ' + res.getStatus() + ' Body: ' + res.getBody());
        }
    }

    public class CallEventWrapper {
        @AuraEnabled public String media;
        @AuraEnabled public String eventName;
        @AuraEnabled public String disposition;
        @AuraEnabled public String createdOn;
       // @AuraEnabled public String activeEventId;
        @AuraEnabled public String url;
        @AuraEnabled public String campaign;
        @AuraEnabled public String totalCallDuration;
        @AuraEnabled public String transcript;
        @AuraEnabled public String twilioId;
        @AuraEnabled public List<EventsWrapper> events;
    }
	 public class EventsWrapper {
        @AuraEnabled public String conversationId;
        @AuraEnabled public String eventName;
        @AuraEnabled public String summary;
        @AuraEnabled public String transcript;
        @AuraEnabled public String url;
		@AuraEnabled public String duration;
        @AuraEnabled public MorganCallWrapper morganCall;
         @AuraEnabled public String agent;
         @AuraEnabled public String rcCallResult;
    }
   public class MorganCallWrapper {
        @AuraEnabled public String azureBlobUri;
        @AuraEnabled public String summary;
        @AuraEnabled public String transcript;
        @AuraEnabled public String duration;
    }
}