public with sharing class TripPilotGetURL {
    @InvocableMethod(label='Get TripPilot URL' description='Calls TripPilot API and returns the login URL')
    public static List<String> getTripPilotURL(List<Id> caseIds) {
        List<String> responseUrls = new List<String>();

        for (Id caseId : caseIds) {
            Case caseRecord = [SELECT Id, Account_Email__c, Member_Number__c, Account.Email__c, Account.Member_Number__c FROM Case WHERE Id = :caseId LIMIT 1];

            if (caseRecord.Account.Email__c == null || caseRecord.Account.Member_Number__c == null) {
                responseUrls.add('Error: Missing Email or Member Number.');
                continue;
            }

            system.debug('caseRecord.Account.Member_Number__c='+caseRecord.Account.Member_Number__c);
            system.debug('caseRecord.Account.Email__c='+caseRecord.Account.Email__c);

            Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            String endpoint = '';
            if(runningInASandbox){
                //endpoint = 'https://webapi.trippilot.com/api/User/SsoUserLogin';  // <<<<
                endpoint = 'https://webapi.trippilot.com/api/User/SsoUserLogin';  // <<<<
                //https://vacationinnovation.alliancetek.net/?Token=
            }
            else{
                endpoint = 'https://webapi.trippilot.com/api/User/SsoUserLogin';
            }
        
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://webapi.trippilot.com/api/User/SsoUserLogin');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
			req.setHeader('AuthKey', '0oxtVQohfcxD6XobnSuvRP762jFVmGwM');

            String requestBody = '';
            if(runningInASandbox){
	        //    requestBody = '{"MemberNumber": "123456", "EmailAddress": "test@test.com"}';
	        	requestBody = JSON.serialize(new Map<String, Object>{
                'MemberNumber' => '123456',
                'EmailAddress' => 'test@test.com'
            	});
            }
            else{
	        //    requestBody = '{"MemberNumber": "' + caseRecord.Account.Member_Number__c + '", "EmailAddress": "' + caseRecord.Account.Email__c + '"}';
            	requestBody = JSON.serialize(new Map<String, Object>{
                'MemberNumber' => caseRecord.Account.Member_Number__c,
                'EmailAddress' => caseRecord.Account.Email__c
            	});
            }

             system.debug('requestBody='+requestBody);
           
            
            req.setBody(requestBody);

            Http http = new Http();
            HttpResponse res;
            
            try {
                res = http.send(req);
                if (res.getStatusCode() == 200) {
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
              		system.debug('res='+res);
                    system.debug('res.getBody()='+res.getBody());
                    system.debug('jsonResponse='+jsonResponse);
                   	Map<String, Object> data = (Map<String, Object>) jsonResponse.get('data');
                    String domainURL = (String) data.get('domainURL');
		            system.debug('domainURL='+domainURL);
                    responseUrls.add(domainURL);
                } else {
                    responseUrls.add('Error: ' + res.getStatus());
                }
            } catch (Exception e) {
                responseUrls.add('Error: ' + e.getMessage());
            }
        }
        return responseUrls;
    }
}