public without sharing class TeeUpLeadController {

    private static final String BASE_URL = 'https://signals.smtnleadtracker.com';

    public class ApiOption {
        @AuraEnabled public Boolean Disabled;
        @AuraEnabled public String GroupName;
        @AuraEnabled public Boolean Selected;
        @AuraEnabled public String Text;
        @AuraEnabled public String Value;
    }

    public class OwnerLookupResponse {
        public Integer OwnerId;
        public String FullName;
        public String Email;
        public String HomePhone;
        public String CellPhone;
        public String WorkPhone;
    }

    @AuraEnabled
    public static Lead fetchOldAgentName(String leadId) {
        return [
            SELECT Id, Tee_Up_Agent__c
            FROM Lead
            WHERE Id = :leadId
            LIMIT 1
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<ApiOption> getDivisions() {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(BASE_URL + '/api/Agent/GetDivisions');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');

        HttpResponse res = new Http().send(req);

        if (res.getStatusCode() != 200) {
            throw new AuraHandledException('Division API Error: ' + res.getBody());
        }

        return (List<ApiOption>) JSON.deserialize(res.getBody(), List<ApiOption>.class);
    }

    @AuraEnabled(cacheable=true)
    public static List<ApiOption> getAgentsByDivision(String divisionId) {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(
            BASE_URL + '/api/Agent/AgentsByDivision?DivisionId=' +
            EncodingUtil.urlEncode(divisionId,'UTF-8')
        );
        req.setMethod('GET');
        req.setHeader('Content-Type','application/json');

        HttpResponse res = new Http().send(req);

        if(res.getStatusCode()!=200){
            throw new AuraHandledException('Agents API Error: '+res.getBody());
        }

        return (List<ApiOption>) JSON.deserialize(res.getBody(), List<ApiOption>.class);
    }


    /*
     * MAIN METHOD
     */

    @AuraEnabled
    public static Lead updateLead(
        String recordId,
        String divisionId,
        String divisionName,
        String selectedAgentName,
        String selectedAgentExternalId
    ){

        Lead ld = [
            SELECT Id,
                   Email,
                   Phone,
                   Cellphone1__c,
                   Work_Phone__c,
                   FirstName,
                   LastName,
                   CreatedDate,
                   Tee_Up_Agent__c
            FROM Lead
            WHERE Id = :recordId
            LIMIT 1
        ];

        if(ld.Tee_Up_Agent__c != null){
            throw new AuraHandledException('Lead already Tee’d Up.');
        }

        /*
         * STEP 1
         * FIND OWNER IN SMTN
         */

        Integer smtnOwnerId;

        HttpRequest ownerReq = new HttpRequest();
        ownerReq.setEndpoint(BASE_URL + '/api/Owner/GetOwner_ByEmailPhone');
        ownerReq.setMethod('POST');
        ownerReq.setHeader('Content-Type','application/json');

        Map<String,Object> ownerPayload = new Map<String,Object>{
            'Email' => blank(ld.Email),
            'Phone' => blank(ld.Phone),
            'CellPhone' => blank(ld.Cellphone1__c),
            'WorkPhone' => blank(ld.Work_Phone__c)
        };

        ownerReq.setBody(JSON.serialize(ownerPayload));

        HttpResponse ownerRes = new Http().send(ownerReq);
        
        System.debug('/api/Owner/GetOwner_ByEmailPhone http response => '+ownerRes);
        System.debug('/api/Owner/GetOwner_ByEmailPhone response body => '+ownerRes.getBody());

        if(ownerRes.getStatusCode()!=200){
            throw new AuraHandledException('Owner lookup failed: '+ownerRes.getBody());
        }

        List<OwnerLookupResponse> owners =
            (List<OwnerLookupResponse>) JSON.deserialize(ownerRes.getBody(), List<OwnerLookupResponse>.class);

        if(!owners.isEmpty()){
            smtnOwnerId = owners[0].OwnerId;
        }

        /*
         * STEP 2
         * SEND TO SMTN
         */

        HttpRequest sendReq = new HttpRequest();
        sendReq.setEndpoint(BASE_URL + '/api/Owner/SendToSMTN');
        sendReq.setMethod('POST');
        sendReq.setHeader('Content-Type','application/json');

        String ownerIdGenerated = String.valueOf(ld.CreatedDate.getTime());

        Map<String,Object> payload = new Map<String,Object>{

            'OwnerId' => ownerIdGenerated,
            'FirstName' => blank(ld.FirstName),
            'LastName' => blank(ld.LastName),
            'Email' => blank(ld.Email),

            'HomePhone' => blank(ld.Phone),
            'CellPhone' => blank(ld.Cellphone1__c),
            'WorkPhone' => blank(ld.Work_Phone__c),

            'SMTNAgentId' => selectedAgentExternalId,
            'DivisionId' => divisionId,

            'SMTNOwnerId' => smtnOwnerId == null ? '' : String.valueOf(smtnOwnerId),

            'SMTNAgentName' => selectedAgentName,
            'UserName' => UserInfo.getFirstName() + ' ' + UserInfo.getLastName()

        };

        sendReq.setBody(JSON.serialize(payload));
        
        System.debug('/api/Owner/SendToSMTN call payload => '+JSON.serialize(payload));

        HttpResponse sendRes = new Http().send(sendReq);
        
         System.debug('/api/Owner/SendToSMTN call response => '+sendRes);
        System.debug('/api/Owner/SendToSMTN response body => '+sendRes.getBody());

        if(sendRes.getStatusCode()!=200){
            throw new AuraHandledException('SMTN integration failed: '+sendRes.getBody());
        }

        /*
         * STEP 3
         * UPDATE SALESFORCE LEAD
         */

        Lead upd = new Lead(
            Id = ld.Id,
            Tee_Up_Agent__c = UserInfo.getUserId(),
            Closing_Agent__c = selectedAgentName,
            Closing_Agent_Id__c = selectedAgentExternalId,
            Closing_Agent_Division__c = divisionName,
            Closing_Agent_Division_Id__c = divisionId,
            Tee_Up_Date__c = System.now()
        );

        update upd;

        return upd;
    }


    /*
     * Helper
     */

    private static String blank(String val){
        return String.isBlank(val) ? '' : val;
    }
}