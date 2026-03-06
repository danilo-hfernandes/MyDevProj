public class PastDueMUOpportunitiesDowngradeQueueable implements Queueable {
    
    Map<Id,Integer> contactIds;
    
    public PastDueMUOpportunitiesDowngradeQueueable(Map<Id,Integer> conts) {        
        this.contactIds = conts;
    }
    
    public void execute(QueueableContext context) {    
        sendRequest(contactIds);
    }
    
    @future(callout=true)
    private static void sendRequest(Map<Id,Integer> accountContactIdMap) {
        
        Map<Id,Integer> oppAccountContactId = accountContactIdMap;
        List<String> errorLog = new List<String>();    
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String endpoint = '';
        if(runningInASandbox){
            endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/membership-downgrade-missed-payment';                    
        }
        else{
            endpoint = 'https://webapihsicorev2.azurewebsites.net/api/membership-downgrade-missed-payment';
        }
        
        // Create a list to store the contactId values
        List<Integer> contactIdList = new List<Integer>();
        
        // Iterate over the map and populate the list
        for (Integer contactId : oppAccountContactId.values()) {
            contactIdList.add(contactId);
        }
        // Convert the list to JSON format with the 'contactIds' key
        String jsonOutput = JSON.serialize(new Map<String, List<Integer>>{
            'contactIds' => contactIdList
                });
        
        //for(Id accId : oppAccountContactId.keySet())
        //{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setBody(jsonOutput);
            system.debug('--httpBody-- --> '+jsonOutput);
            request.setHeader('content-type', 'application/json');            
            String response = '';
            try {  
                HttpResponse httpResponse = http.send(request);
                system.debug('--httpResponse--'+httpResponse);
                if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                    errorLog.add('PastDueMUOpportunitiesDowngradeQueueable ERROR calling '+endpoint+': '+ String.valueOf(response)+';;;');         
                    
                }
            } catch( System.Exception e){
                errorLog.add('PastDueMUOpportunitiesDowngradeQueueable ERROR calling '+endpoint+'ERROR: '+ e.getMessage()+';;;');                 
            }
        
        if( (errorLog.size()>0 && errorLog != null) || Test.isRunningTest() )
        {
            try {
                runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                if(!runningInASandbox || Test.isRunningTest()){
                    String message = String.valueOf(errorLog);
                    system.debug('--message-'+message);
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    String[] sendingTo = new String[]{'victor.goncalves@nerdsoft.com'};
                    semail.setToAddresses(sendingTo);
                    semail.setSubject('[DOWNGRADE FAILED] api membership-downgrade-missed-payment is failed');
                    semail.setPlainTextBody(message);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                }
            } 
            catch( System.Exception e){
                System.debug('ERROR: '+ e);
            }
        }
        
        //}
        
    }
    
}