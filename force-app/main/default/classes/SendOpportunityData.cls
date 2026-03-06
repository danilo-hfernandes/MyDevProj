public class SendOpportunityData {
    
    @InvocableMethod(label='Call Send Opportunity')
    public static void callFutureMethod(List<Id> recordIds){
        system.debug('recordIds=== '+recordIds);
        sendOppData(recordIds);
    }
    
    @future(callout=true)
    Public static void sendOppData(List<Id> recordIds){
        //system.debug('calling future method=== ');
        List<Opportunity> oppList = [Select Id,FBCLID__c,Webhook_Synced__c,Account.Email__c,Account.Phone,Account.First_Name__c,Account.Last_Name__c,AccountId,Amount from Opportunity
                                     where Id In : recordIds Limit 1];
        
        if(oppList.size()>0 && oppList[0].Amount > 0){
            List<Opportunity> updateOpportunity = new List<Opportunity>();
            system.debug('send opportunity data=== ');
            String fbclid = oppList[0].FBCLID__c != null ? oppList[0].FBCLID__c : '';
            String payload = '{"data":[{"event_name":"Purchase","action_source":"system_generated","user_data":{"em":["'+oppList[0].Account.Email__c+'"],"ph":["'+oppList[0].Account.Phone+'"],"fn":["'+oppList[0].Account.First_Name__c+'"],"ln":["'+oppList[0].Account.Last_Name__c+'"],"external_id":["'+oppList[0].AccountId+'"]},"fbclid":["'+fbclid+'"],"custom_data":{"currency":"USD","value":"'+oppList[0].Amount+'"}}]}';
            String endpointURL = 'https://connect.pabbly.com/workflow/sendwebhookdata/IjU3NjYwNTZjMDYzZjA0MzM1MjY1NTUzZDUxM2Ii_pc'; 
            System.debug('payload=== '+payload);
            try{
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpointURL);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setBody(payload);
                
                HttpResponse res = http.send(request);
                system.debug('GET RESPOSE: ' + res.getStatusCode() + ' --- ' + res.getStatus());
                system.debug('GET BODY : ' + res.getBody());
                
                if(res.getStatusCode() == 200){
                    oppList[0].Webhook_Synced__c = system.now();
                    updateOpportunity.add(oppList[0]);
                }
                
                if(updateOpportunity.size()>0){
                    update updateOpportunity;
                }
                
                System.debug('updateOpportunity=== '+updateOpportunity);
                
            }catch(Exception ex){
                system.debug('error == '+ex.getMessage());
                system.debug('error line== '+ex.getLineNumber());
            }
            
        }
        
    }
}