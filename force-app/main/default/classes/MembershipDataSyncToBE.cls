public class MembershipDataSyncToBE {
    
    public static string GetToken(){
        String matrixAPI = 'https://matrix.nerdsoft.com/Token';
        string userName =  'salesforceupdatecontact@nerdsoft.com';
        string password =  'SF_uc_password1';
        string clientId =  '2FihOuY0hvaIx9JkscRv23BJaO3dcSjzSD1Dcy0M:2FihOuY0hvaIx9JkscRv23BJaO3dcSjzSD1Dcy0M';
		TokenReturn respObj = new TokenReturn(); 
        
        string msgTokenBody = 'banana='+clientId+'&grant_type=password&username='+ userName +'&password='+ password + '&client_id=' + clientId;
        if(!test.isRunningTest()){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(matrixAPI);
            request.setMethod('POST');
            request.setHeader('Content-Type','application/x-www-form-urlencoded');
            request.setBody(msgTokenBody);
            HttpResponse response = http.send(request);
            respObj = (TokenReturn)JSON.deserialize(response.getBody() , TokenReturn .class);
            system.debug('--msgTokenBody---'+msgTokenBody);
            system.debug('--request---'+request);
            system.debug('--response---'+response);
            system.debug('response.getStatusCode()'+response.getStatusCode());
        }
        else
        {
            respObj.access_token = 'token';
        }
        
        system.debug('respObj'+respObj);
        system.debug('respObj.access_token'+respObj.access_token);
        return respObj.access_token;
    }
    public Class TokenReturn{
        private String access_token {get; set;}
    }
    
    public class SyncMembershipDataToBE{
        public String memberNumber;
        public String membershipStatusName;
    }
    
    @future(callout=true)
    public static void MembershipDataSync(Map<String,String> membersToSendToBE,Set<Id> recordsToSync){
        List<SyncMembershipDataToBE> syncDataList = New List<SyncMembershipDataToBE>();
        for(String mNumber : membersToSendToBE.keySet()){
            SyncMembershipDataToBE syncDataObj = New SyncMembershipDataToBE();
            syncDataObj.memberNumber = mNumber;
            syncDataObj.membershipStatusName = membersToSendToBE.get(mNumber);
            syncDataList.add(syncDataObj);
        }
        if(syncDataList != null && syncDataList.size()>0){
            MembershipDataSyncToBE.callHTTPQuest(syncDataList,recordsToSync);
        }
    }
    
    public static void callHTTPQuest(List<SyncMembershipDataToBE> syncDataList, Set<Id> recordIds){
        if(syncDataList != null){ 
            try{
                String gToken = GetToken();
                system.debug('--gToken--'+gToken);
                String payload = JSON.serialize(syncDataList);
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                String endpoint = '';
                if(runningInASandbox){
                    //endpoint = 'https://hsimemberapi.azurewebsites.net/api/member/updatemembershipstatus';
                    //endpoint = 'https://hsimemberapi-stating.azurewebsites.net/api/member/updatemembershipstatus';
                    //endpoint = 'https://hsimemberapi.azurewebsites.net/api/member/updatemembershipstatus'
                    //Update 2025-03-14 BEFU-223
                    endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/member/updatemembershipstatus';
                }
                else{ 
                    endpoint = 'https://webapihsicorev2.azurewebsites.net/api/member/updatemembershipstatus';
                }
                system.debug('---payload---'+payload);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint); //https://api.advantageprogram.com/api/user/updateuserinformation
                request.setMethod('POST');
                request.setBody(payload);
                request.setHeader('content-type', 'application/json');
                request.setHeader('Authorization', 'Bearer '+gToken);
                system.debug('--request--'+request);
                HttpResponse hhtpResponse = http.send(request);
                system.debug('response.getStatusCode()'+hhtpResponse.getStatusCode());
                system.debug('hhtpResponse.getBody()'+hhtpResponse.getBody());
                
                String response = JSON.serializePretty( JSON.deserializeUntyped(hhtpResponse.getBody()) );
                Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                String message = String.valueOf(receivedData.get('Message'));
                system.debug('--message-'+message);
                if(hhtpResponse.getStatusCode() != 200){
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();                    
                    String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','Victor.Goncalves@nerdsoft.com','danilo.fernandes@nerdsoft.com','daniel.oliveira@nerdsoft.com'};
                        semail.setCcAddresses(new String[]{UserInfo.getuserid()});
                    semail.setToAddresses(sendingTo); 
                    semail.setSubject('Membership status update failed from Salesforce to BE database'); 
                    semail.setPlainTextBody('Message : '+message+ ' Request : '+payload+' record Ids trying to sync : '+String.valueOf(recordIds));
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                }
            }catch(Exception ex){
                System.debug('ERROR: '+ ex);  
                Error_Handler__c err = new Error_Handler__c();
                err.Name = 'Membership Status Data sync to BE , Apex Class : MembershipDataSyncToBE';
                err.Error_Message__c = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
                insert err;
            }
        }
    }
    
}