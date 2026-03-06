global class SFXMemberTransferBatch implements Database.Batchable<sObject>, Schedulable {
    
    global void execute(SchedulableContext SC) {
        SFXMemberTransferBatch objBatch = new SFXMemberTransferBatch(); 
        database.executebatch(objBatch, 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        String query = '';
        set<Integer> SFXAffilateIdSet = new set<Integer>{1002277,1002275};  //only sfx diamond and gold
        Date startDate = Date.newInstance(2025, 4, 9); //replace by specific date to process historical data from a reference
        Date hundredDaysAgo = System.today().addDays(-100); // 100 days ago from today
        
        query += 'SELECT Id, Name, Affiliated_Id__c, Member_Number__c, Contact_Id__c,Contract_Number__c FROM Account';
        query += ' WHERE Affiliated_Id__c IN :SFXAffilateIdSet';
        query += ' AND CreatedDate > :startDate';
        query += ' AND CreatedDate <= :hundredDaysAgo';
        query += ' AND Membership_Status__c == \'Active\'';
        query += ' AND Contract_Number__c != null';
        query += ' AND Member_Number__c != null';

        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){
        
        Map<Id,Account> accountMap = new Map<Id,Account>();
        Map<Id, String> accountCreditsBalance = new Map<Id, String>();        
        List<Map<String, Object>> members = new List<Map<String, Object>>();
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        
        for(Account acc : scope){
            accountMap.put(acc.Id,acc);
            String gToken = '';            
            String endpoint = '';
            if(runningInASandbox){
                endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/GetAdvantageCredits/GetMemberCredits/'+acc.Member_Number__c;
                //endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/GetAdvantageCredits/GetMemberCredits/'+'AP-SMTNPM-8133';
            }
            else{
                endpoint = 'https://api.advantageprogram.com/api/GetAdvantageCredits/GetMemberCredits/'+acc.Member_Number__c;
                //gToken = DataSyncToSQL.GetToken();
                //system.debug('--gToken--'+gToken);
            }
            //String requestBody = JSON.serialize('"MemberNumber":"'+acc.Member_Number__c+'"');
            
            //system.debug('---requestBody---'+requestBody);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            //request.setBody('');
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
                    system.debug('--SFXMemberTransferBatch credits api call errorMessage-'+message);
                    //accountCreditsBalance.put(acc.Id,'errorMessage = '+message);
                }
                else
                {                    
                    response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                    Map<String,Object> receivedCredits = (Map<String,Object>)JSON.deserializeUntyped(response);
                    system.debug('--receivedCreditsData-'+receivedCredits);
                    accountCreditsBalance.put(acc.Id,/*(Decimal.valueOf*/(String.valueOf(receivedCredits.get('Redeemable'))))/*.setScale(2,RoundingMode.DOWN))*/;                    
                }
            } catch( System.Exception e){
                System.debug('SFXMemberTransferBatch credits salesforce http call errorMessage: '+ e.getMessage());
                //accountCreditsBalance.put(acc.Id,'errorMessage = '+e.getMessage());
            }
            
        }
        
        if(accountCreditsBalance.size()>0 && accountCreditsBalance != null)
        {
            for(Id accountId : accountCreditsBalance.keySet()){
                Map<String, Object> member = new Map<String, Object>();
                member.put('sfxAcctId', accountMap.get(accountId).Contract_Number__c);
                member.put('message', 'test');
                member.put('travelCashAmount', Decimal.valueOf(accountCreditsBalance.get(accountId)).setScale(2,RoundingMode.DOWN));
                members.add(member);
            }
            
            Map<String, Object> body = new Map<String, Object>{'members' => members};                            
            String jsonBody = JSON.serialize(body);
            System.debug('sfxResorts api call body = '+jsonBody);
            
            String endpoint2 = '';
            if(runningInASandbox){
                endpoint2 = 'https://api3-stage.sfxresorts.com/sfxmember/membershipTransfer';
                
            }
            else{
                endpoint2 = 'https://api3.sfxresorts.com/sfxmember/membershipTransfer';
            }
            
            String gToken2 = 'C6FrDk2kTdH4mJJ8peDBcpNFRWRuAsxgPsP6hrg2Xb6JhTgJFPdj9ccMpfmJtJv3';
            Http http2 = new Http();
            HttpRequest request2 = new HttpRequest();
            request2.setEndpoint(endpoint2);
            request2.setMethod('POST');
            request2.setHeader('content-type', 'application/json');
            request2.setHeader('Authorization', 'Bearer '+gToken2);            
            system.debug('--request2--'+request2);
            String response2 = '';            
            
            try {  
                HttpResponse httpResponse2 = http2.send(request2);
                system.debug('--httpResponse2--'+httpResponse2);
                if(httpResponse2.getStatusCode() != 200){
                    response2 = JSON.serializePretty( JSON.deserializeUntyped(httpResponse2.getBody()) );
                    system.debug('--SFXMemberTransferBatch SFX api call errorMessage-'+response2);
                }
                else
                {                    
                    response2 = JSON.serializePretty(JSON.deserializeUntyped(httpResponse2.getBody()));
                    system.debug('--SFXMemberTransferBatch SFX api call worked - response2 = '+response2);
                    List<Account> accountsToMoveToSFXInactive = new List<Account>();
                    for(Id accountId : accountCreditsBalance.keySet()){
                        Account act = new Account(Id=accountId,Membership_Status__c='InactiveBySFX');
                        accountsToMoveToSFXInactive.add(act);
                    }
                    List<Opportunity> openedSFXOpps = [SELECT Id FROM Opportunity WHERE IsWon = false AND IsClosed = false AND RecordType.DeveloperName = 'SFX_Membership' AND StageName != 'Auto Open' AND AccountId IN : accountCreditsBalance.keySet()];
                    List<Opportunity> oppsToMoveToAutoOpen = new List<Opportunity>();
                    
                    if(openedSFXOpps.size() > 0 && openedSFXOpps != null)
                    {
                        for(Opportunity o : openedSFXOpps)
                        {
                            o.stagename = 'Auto Open';
                            oppsToMoveToAutoOpen.add(o);
                        }
                    }
                    if(oppsToMoveToAutoOpen.size()>0 && oppsToMoveToAutoOpen != null)
                    {
                        update oppsToMoveToAutoOpen;   
                    }
                }
            } catch(System.Exception e){
                System.debug('SFXMemberTransferBatch SFX api salesforce http call errorMessage: '+ e.getMessage());
                //accountCreditsBalance.put(acc.Id,'errorMessage = '+e.getMessage());
            }
            
        }

    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}