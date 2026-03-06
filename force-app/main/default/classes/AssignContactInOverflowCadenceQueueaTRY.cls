public class AssignContactInOverflowCadenceQueueaTRY implements Queueable {
    list<Contact> Contactrecords;
    String salesCadenceName='';
    public AssignContactInOverflowCadenceQueueaTRY(list<contact> contactList) {
        system.debug('5='+contactList.size());
        this.Contactrecords = contactList;
    }
    public void execute(QueueableContext context) { 
        Set<Id> contactIdSet = new Set<Id>();
        for(contact con : Contactrecords) {
            system.debug('10='+con);
            // B-08601 - Mitul - run time run - then comment out
            //sendRequest(con.id, 'HCMU-Booking2');
            //sendRequest(con.id, 'HCMU-High Velocity 51 Days');
            contactIdSet.add(con.id);
            
        }
        sendRequest(contactIdSet, 'HCMU-High Velocity 51 Days');  
    }
    @future(callout=true)
    private static void sendRequest(Set<Id> targetId, String salesCadenceNameOrId) {
        system.debug('-targetId---'+targetId);
        system.debug('-targetId---'+targetId.size());
        system.debug('-salesCadenceNameOrId---'+salesCadenceNameOrId);  
        String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
        String actionsRestURL = sfdcURL + '/services/data/v45.0/actions';
        String assignTargetRESTUrl = actionsRestURL + '/standard/assignTargetToSalesCadence';
        Set<Id> contactFailedId = new Set<Id>();
        for(Id trgId : targetId){
            HttpRequest httpReq = new HttpRequest();
            httpReq.setMethod('POST');
            httpReq.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
            httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            httpReq.setEndpoint(assignTargetRESTUrl);
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "' + salesCadenceNameOrId + '", "targetId" : "' + trgId + '"}]}');
            
            String response = '';
            try {
                Http http = new Http();
                HttpResponse httpResponse = http.send(httpReq);
                if (httpResponse.getStatusCode() == 200) {
                    response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                } else {
                    System.debug('http response: ' + httpResponse.getBody());
                    contactFailedId.add(trgId);
                    //throw new CalloutException(httpResponse.getBody());
                    // We have to stored the contact Id to revert back the update
                }
            } catch (System.Exception e) {
                System.debug('ERROR! ' + e);
                contactFailedId.add(trgId);
                //throw e;
                // // We have to stored the contact Id to revert back the update
            }
            System.debug('response: ' + response);     
        }
        if(contactFailedId != null && contactFailedId.size() > 0){
            List<Contact> contListNew = [select id from Contact where Id IN : contactFailedId];
            List<Contact> updateContactList = new List<Contact>();
            for(Contact cn : contListNew){
                cn.Assign_to_Sales_Cadence__c = false;
                cn.Cadence_Flag__c = null;
                //cn.Onwer = cn.Custom_Owner__c;
                updateContactList.add(cn);
            }
            if(updateContactList != null && updateContactList.size() > 0){
                try{
                    update updateContactList;
                }catch(Exception E ){
                    system.debug('--e--'+e);
                }
            }
        }
    }
}