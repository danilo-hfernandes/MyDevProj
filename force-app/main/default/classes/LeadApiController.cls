/**
* @File Name : LeadApiController.cls
* @Description :
* @Author : Shivani Chauhan
* @Last Modified By :
* @Last Modified On : January 28, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | January 28, 2025 |   | Initial Version
**/

public with sharing class LeadApiController {
    @AuraEnabled
    public static List<Object> getAgents() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://signals.smtnleadtracker.com/api/Agent/AgentsByDivision?DivisionId=24'); 
        request.setMethod('GET');
        request.setHeader('content-type', 'application/json');
        request.setTimeout(60000);
        HttpResponse httpresponse = http.send(request);

        if (httpresponse.getStatusCode() == 200) {
            String response = JSON.serializePretty( JSON.deserializeUntyped(httpresponse.getBody()) );
            List<Object> receivedData = (List<Object>)JSON.deserializeUntyped(response);
            system.debug('>>>>response.getBody()>>>'+receivedData);
            return receivedData;
        } else {
            throw new AuraHandledException('API call failed: ' + httpresponse.getStatus());
        }
    }
    @AuraEnabled
    public static String teeUpLead(Id leadId, String smtnAgentId, String smtnAgentName) {
        Lead leadRecord = [SELECT Id, Name, FirstName, LastName, Email, OwnerId,Owner_Id_Custom__c,Phone,Work_Phone__c FROM Lead WHERE Id = :leadId];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://signals.smtnleadtracker.com/api/owner/TeeUpFromSalesForceToVIN'); 
        request.setMethod('POST');
        request.setHeader('content-type', 'application/json');
        request.setTimeout(60000);
        Id loggedInUserId = UserInfo.getUserId();
        User userObj = [select id,VIN_Agent_Id__c,alias from User where Id =: loggedInUserId  limit 1];
        // Add request body
        Map<String, Object> body = new Map<String, Object>{
            'OwnerId' => leadRecord.Owner_Id_Custom__c,
            'FirstName' => leadRecord.FirstName,
            'LastName' => leadRecord.LastName,
            'Email' => leadRecord.Email,
            'HomePhone' => leadRecord.Phone,
            'CellPhone' => leadRecord.Phone,
            'WorkPhone' => leadRecord.Work_Phone__c,
            'SMTNAgentId' => smtnAgentId,
            'SMTNAgentName' => smtnAgentName,
            'TeeUpAgentId' => userObj.VIN_Agent_Id__c,
            'UserName' => userObj.alias
        };
        system.debug('>>>body'+body);
        request.setBody(JSON.serialize(body));

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            throw new AuraHandledException('API call failed: ' + response.getStatus());
        }
    }
}