/*   
  @description       : Uses custom metadata type to set a default callback number for click-to-dial based on User's profile
  @author            : kendra@snowytree.com
  @last modified on  : 11-01-2024
  @last modified by  : kendra@snowytree.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   11-01-2024   kendra@snowytree.com   Initial Version*/

global class SnowytreeSelectCallbackNumber implements VCCCore.ISelectPresentedClid {

    global VCCCore.PresentedClidResult GetPresentedClid(String clickToDialJson) {

        String dialedNumber = getDialedNumber(clickToDialJson);
        String areaCode = extractAreaCode(dialedNumber);
        String profileName = getUserProfileName();
        String presentedClid = getCallbackNumber(areaCode, profileName,dialedNumber);

        return new VCCCore.PresentedClidResult(presentedClid);  
    }

    global String getDialedNumber(String clickToDialJson) {
        Map<String, Object> clickToDialResultMap = (Map<String, Object>) JSON.deserializeUntyped(clickToDialJson);
        return (String) clickToDialResultMap.get('number');
    }

    global String extractAreaCode(String phoneNumber) {
        phoneNumber = phoneNumber.replaceFirst('^(\\+1|1)', '').replaceAll('[()\\-\\s]', '');  // Remove leading "1", "+1", or (), -, ' ' if present
        return phoneNumber.length() >= 3 ? phoneNumber.substring(0, 3) : null;
    }

    global String getUserProfileName() {
        Id profileId = UserInfo.getProfileId();
        return [SELECT Name FROM Profile WHERE Id = :profileId].Name;
    }
    
    global String getCallbackNumber(String areaCode, String profileName, String dialedNumber) {
        String presentedClid = null;
        String outboundNumber = '';
        String outputNumber = '';
        
                Callback_Number_Profiles__mdt callbackProfile = [
                SELECT Call_Type__c
                FROM Callback_Number_Profiles__mdt
                WHERE MasterLabel = :profileName
                LIMIT 1
            ];
        
        List<String> errors = new List<String>();
        try {
            //Retrieve the custom metadata record for the given profile name
            
            String callbackProfileCallType = callbackProfile.Call_Type__c;
            
            String formattedDialedNumber = dialedNumber.replace('+', '').replace('(', '').replace(')', '').replace('-', '').replace(' ', '').replace('.', '').replace('/', '');
                
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                String endpoint = '';
            	// Remove leading "1", "+1", or (), -, ' ' if present from the dialedNumber variable
                if(runningInASandbox){
                    endpoint = 'https://vididmanagerapi.azurewebsites.net/api/NextNumberRotationStg/sourceSystem/Vonage/campaign/'+callbackProfileCallType+'/destinationPhoneNumber/'+formattedDialedNumber;
                }
                else{
                    endpoint = 'https://vididmanagerapi.azurewebsites.net/api/NextNumberRotation/sourceSystem/Vonage/campaign/'+callbackProfileCallType+'/destinationPhoneNumber/'+formattedDialedNumber;
                }
                
                //callout test
                //body only needed for GET
                //String requestBody = '{sourceSystem": "vonage","destinationPhoneNumber":"'+dialedNumber+'","campaign": "'+callbackProfileCallType+'"}';
                //request.setBody(requestBody);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('GET');                
                request.setHeader('content-type', 'application/json'); 
                request.setHeader('Authorization', 'Bearer '+'OWDQj3uNYsNDIM0ixzhrDy4LwhHC425j4zkmXh1q1BrbaHTS2Av0nu7NtKo_CfgOnZqaf0phLF86lqtRbgXNsA');
                request.setTimeout(60000);
                system.debug('--request--'+request);
                String response = '';
                try {  
                HttpResponse httpResponse = http.send(request);
                system.debug('--httpResponse--'+httpResponse);                
                
                if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                    /*response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                    Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                    String message = String.valueOf(receivedData.get('message'));
                    system.debug('--message-'+message);*/            
                    errors.add(endpoint+ ' API Call Failed ; httpResponse.getStatusCode() = '+httpResponse.getStatusCode()+' ; httpResponse.getStatus() = '+httpResponse.getStatus()+' ; httpResponse.getBody() = '+httpResponse.getBody());
                    outboundNumber='';
                }
                else{
                    response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );                    
                    Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                    outboundNumber = String.valueOf(receivedData.get('outboundPhoneNumber'));
                }
                } catch( System.Exception e) {
				System.debug('ERROR: '+ e);
                    errors.add(e.GetMessage());
				}               
            
            
        } catch (Exception e) {
            System.debug('Error retrieving callback number: ' + e.getMessage());
             errors.add(e.getMessage());
        }

        if(outboundNumber != ''){
            outputNumber = outboundNumber;
        }
        else{
            try{
                if(callbackProfile != null) {
                    //Construct the query dynamically
                    String query = 'SELECT Callback_Number__c,Call_Count__c FROM Callback_Number__c WHERE Disabled__c = false AND Area_Code__c = :areaCode AND Call_Profile__c = :callbackProfileCallType ORDER BY Last_Call_Made__c ASC LIMIT 1';                
                    List<Callback_Number__c> mappings = Database.query(query);
                    
                    if(mappings.isEmpty())
                    {
                        query = 'SELECT Callback_Number__c,Call_Count__c FROM Callback_Number__c WHERE Disabled__c = false AND Area_Code__c = \'000\' AND Name = :profileName ORDER BY Last_Call_Made__c ASC LIMIT 1';
                        mappings = Database.query(query);
                    }
                    
                    //Use the retrieved callback number or the default from cmdt
                    presentedClid = (!mappings.isEmpty()) ? 
                    (String) mappings[0].get('Callback_Number__c') : 
                    callbackProfile.Default_Number__c;
                    
                    if(!mappings.isEmpty())
                    {
                        for (Callback_Number__c rec : mappings) {
                            List<Id> callbackIds = new List<Id>();
                            for (Callback_Number__c cbnumber : mappings) {
                                callbackIds.add(cbnumber.Id);
                            }
                            // Run the update asynchronously
                            EventBus.publish(new Callback_Update_Event__e(CallbackId__c = mappings[0].Id));
                        }
                        //update mappings;                    
                    }
                }
            }
            Catch(Exception e){
                errors.add(e.getMessage());
            }
            outputNumber = presentedClid;
        }

        if(errors.size()>0 && errors != null)
        {
            
            /*Annual_Dues_Log__c adlog = new Annual_Dues_Log__c();
            adlog.Key__c = dialedNumber;
            adlog.Log__c = String.valueOf(errors);
            insert adlog;*/
                
            try {
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                if(!runningInASandbox){
                    String message = String.valueOf(errors);
                    system.debug('--message-'+message);
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    String[] sendingTo = new String[]{'victor.goncalves@nerdsoft.com','danilo.fernandes@nerdsoft.com','ivan.moura@nerdsoft.com'};
                    semail.setToAddresses(sendingTo);
                    semail.setSubject('[Vonage] SnowytreeSelectCallbackNumber is failed');
                    semail.setPlainTextBody(message);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                }
            } 
            catch( System.Exception e){
                System.debug('ERROR: '+ e);
            }
        }
        //remove after testing
        //outputNumber = '14075744646';
        return outputNumber;
    }
    
    // ---------------------------------------------------------
    // Helper inner Queueable class for async updates

    /*@future
    private static void updateCallbackCounts(List<Id> callbackIds) {
        List<Callback_Number__c> updates = [
            SELECT Id, Call_Count__c, Last_Call_Made__c
            FROM Callback_Number__c
            WHERE Id IN :callbackIds
        ];
        for (Callback_Number__c rec : updates) {
            rec.Call_Count__c = (rec.Call_Count__c == null ? 1 : rec.Call_Count__c + 1);
            rec.Last_Call_Made__c = System.now();
        }
        update updates;
    }*/
    /*private class CallbackNumberUpdater implements Queueable {
        private List<Id> callbackIds;
        
        public CallbackNumberUpdater(List<Id> ids) {
            this.callbackIds = ids;
        }
        
        public void execute(QueueableContext qc) {
            try {
                List<Callback_Number__c> updates = [
                    SELECT Id, Call_Count__c, Last_Call_Made__c
                    FROM Callback_Number__c
                    WHERE Id IN :callbackIds
                ];
                
                for (Callback_Number__c rec : updates) {
                    rec.Call_Count__c = (rec.Call_Count__c == null ? 1 : rec.Call_Count__c + 1);
                    rec.Last_Call_Made__c = System.now();
                }
                
                if (!updates.isEmpty()) update updates;
                System.debug('[SnowytreeSelectCallbackNumber] Queueable updated ' + updates.size() + ' record(s).');
            } catch (Exception e) {
                System.debug('[SnowytreeSelectCallbackNumber] Queueable update failed: ' + e.getMessage());
            }
        }
    }*/

/*   
  @description       : Uses custom metadata type to set a default callback number for click-to-dial based on User's profile
  @author            : kendra@snowytree.com
  @last modified on  : 11-01-2024
  @last modified by  : kendra@snowytree.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   11-01-2024   kendra@snowytree.com   Initial Version

global class SnowytreeSelectCallbackNumber implements VCCCore.ISelectPresentedClid {
    
    global VCCCore.PresentedClidResult GetPresentedClid(String clickToDialJson) {
        
        String dialedNumber = getDialedNumber(clickToDialJson);
        String areaCode = extractAreaCode(dialedNumber);
        String profileName = getUserProfileName();
        String presentedClid = getCallbackNumber(areaCode, profileName);
        
        return new VCCCore.PresentedClidResult(presentedClid);  
    }
    
    global String getDialedNumber(String clickToDialJson) {
        Map<String, Object> clickToDialResultMap = (Map<String, Object>) JSON.deserializeUntyped(clickToDialJson);
        return (String) clickToDialResultMap.get('number');
    }
    
    global String extractAreaCode(String phoneNumber) {
        phoneNumber = phoneNumber.replaceFirst('^(\\+1|1)', '').replaceAll('[()\\-\\s]', '');  // Remove leading "1", "+1", or (), -, ' ' if present
        return phoneNumber.length() >= 3 ? phoneNumber.substring(0, 3) : null;
    }
    
    global String getUserProfileName() {
        Id profileId = UserInfo.getProfileId();
        return [SELECT Name FROM Profile WHERE Id = :profileId].Name;
    }
    
    global String getCallbackNumber(String areaCode, String profileName) {
        String presentedClid = null;
        
        try {
            //Retrieve the custom metadata record for the given profile name
            Callback_Number_Profiles__mdt callbackProfile = [
                SELECT Type_of_Callback__c, Default_Number__c
                FROM Callback_Number_Profiles__mdt
                WHERE MasterLabel = :profileName
                LIMIT 1
            ];
            
            if(callbackProfile != null) {
                //Construct the query dynamically
                String query = 'SELECT ' + callbackProfile.Type_of_Callback__c + ' FROM Area_Code_to_Phone_Number_Mapping__c WHERE Area_Code__c = :areaCode LIMIT 1';
                
                List<Area_Code_to_Phone_Number_Mapping__c> mappings = Database.query(query);
                
                //Use the retrieved callback number or the default from cmdt
                presentedClid = (!mappings.isEmpty()) ? 
                    (String) mappings[0].get(callbackProfile.Type_of_Callback__c) : 
                callbackProfile.Default_Number__c;
            }
            
        } catch (Exception e) {
            System.debug('Error retrieving callback number: ' + e.getMessage());
        }
        
        return presentedClid;
    }*/


    
}