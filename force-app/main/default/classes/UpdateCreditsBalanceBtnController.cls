public with sharing class UpdateCreditsBalanceBtnController {
    @AuraEnabled
    public static Account getAccountData(Id accountId) {
        return [SELECT Id, Credits_Balance__c, Member_Number__c FROM Account WHERE Id = :accountId];
    }
    
    @AuraEnabled
    public static Map<String,String> updateAccountCredits(Id accountId) {
        
        Map<String,String> resultLog = new Map<String,String>();

        Account currentAccount = [SELECT Id,Member_Number__c FROM Account WHERE Id = :accountId];
        
        if(currentAccount.Member_Number__c != null && currentAccount.Member_Number__c != ''){
            String gToken = '';
            
            Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            String endpoint = '';
            if(runningInASandbox){
                endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/GetAdvantageCredits/GetMemberCredits/'+currentAccount.Member_Number__c;
                
            }
            else{
                endpoint = 'https://api.advantageprogram.com/api/GetAdvantageCredits/GetMemberCredits/'+currentAccount.Member_Number__c;
                
            }
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            
            request.setHeader('content-type', 'application/json');
            if(gToken != ''){
                request.setHeader('Authorization', 'Bearer '+gToken);
            }
            system.debug('--request--'+request);
            String response = '';
            
            try {  
                HttpResponse httpResponse = http.send(request);
                system.debug('--httpResponse--'+httpResponse);
                if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                    response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                    Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                    String message = String.valueOf(receivedData.get('message'));
                    system.debug('--message-'+message);
                    resultLog.put('error','errorMessage = '+response);
                }
                else
                {                    
                    response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                    //test - response = JSON.serializePretty( JSON.deserializeUntyped('{"Redeemable":0.83}'));
                    //response = '{"Redeemable":149.00}';
                    Map<String,Object> receivedCredits = (Map<String,Object>)JSON.deserializeUntyped(response);
                    system.debug('--receivedCreditsData-'+receivedCredits);                
                    Account acc = new Account(Id = accountId);
                    acc.Credits_Balance__c = (Decimal.valueOf(String.valueOf(receivedCredits.get('Redeemable')))).setScale(2,RoundingMode.DOWN);
                    resultLog.put('success','Account Credits Balance was successfully updated to = '+acc.Credits_Balance__c);
                    update acc;
                }
            } catch( System.Exception e){
                System.debug('ERROR: '+ e);
                resultLog.put('error','errorMessage = '+e);            
            }
        }
        else
        {
            resultLog.put('error','Invalid Member Number'); 
        }
           
        return resultLog;
    }
}