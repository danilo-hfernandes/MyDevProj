public class leadTriggerOMHandler implements Queueable {
    Set<Id> recordIds;
    
    public leadTriggerOMHandler(Set<Id> LeadIdSet) {
        this.recordIds = LeadIdSet;
    }
    public void execute(QueueableContext context) { 
        sendRequest1(recordIds); 
    }
    
    @future(callout = true)
    private static void sendRequest1(Set<Id> LeadIdSset) {
        if(LeadIdSset != null){
            String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
            String actionsRestURL = sfdcURL + '/services/data/v45.0/actions';
            String assignTargetRESTUrl = actionsRestURL + '/standard/assignTargetToSalesCadence';
            List<String> errorLog = new List<String>();
            Boolean flag = false;
            List<Lead> leadList = [select id,LeadSource,is_duplicate__C,SMTN_match_group__c,recordtypeid,Owner.Name from Lead where Id In : LeadIdSset and Marketing_Email_opt_out__c = false];
            for(Lead led : leadList){
                system.debug('25=='+led);
                HttpRequest httpReq = new HttpRequest();
                httpReq.setMethod('POST');
                httpReq.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
                httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                httpReq.setEndpoint(assignTargetRESTUrl);
                httpReq.setHeader('Content-Type', 'application/json');
                Id leadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SMTN_Mexico').getRecordTypeId();       
                
                if(led.LeadSource == 'CFD Mexico' || led.LeadSource == 'CFD FB Mexico' || led.LeadSource == 'CFD Mexico FB' || led.LeadSource == 'CFD Riviera Maya' || led.LeadSource == 'CFD FB Riviera Maya' ||
                   led.LeadSource == 'CFD FB Mexico Golf' || led.LeadSource == 'CFD FB Mexico Spring Break' || led.LeadSource == 'CFD FB Acapulco' || led.LeadSource == 'CFD FB Los Cabos' ||
                   led.LeadSource == 'CFD FB Puerto Vallarta' || led.LeadSource == 'CFD FB Nuevo Vallarta' || led.LeadSource == 'CFD FB Puerto Penasco' || led.LeadSource == 'CFD FB Cancun' ||
                   led.LeadSource == 'CFD FB Mexico Summer' || led.LeadSource == 'CFD FB Cinco de Mayo' || led.LeadSource == 'CFD FB Mexico COVID' || led.LeadSource == 'CFD MX Checkout' || led.LeadSource == 'CFD Google Mexico' ||
                   led.LeadSource == 'CFD Google Acapulco' || led.LeadSource == 'CFD Google Cancun' || led.LeadSource == 'CFD Google Riviera Maya' || led.LeadSource == 'CFD Google Puerto Penasco' || led.LeadSource == 'CFD Google Puerto Vallarta' ||
                   led.LeadSource == 'CFD Google Nuevo Vallarta')
                {
                    httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "TourGen-FB-MX *New Lead", "targetId" : "' + led.Id + '"}]}'); 
                    flag = true; 
                }
                else if(led.LeadSource != 'Timeshare Nation TCS' && led.LeadSource != 'SMTN Rental Offer' && led.LeadSource != 'VIN Open Survey' && led.LeadSource != 'SMTN Open Survey' && led.LeadSource != 'VI Referral' && led.LeadSource != 'VVIP Westgate Las Vegas' && led.LeadSource != 'VVIP Westgate Orlando' && led.LeadSource != 'Vacation VIP Retraveler' && led.LeadSource != 'TRM Contactable' && led.LeadSource != 'TRM Open' && led.LeadSource != 'Vacation VIP - Web' && led.LeadSource != 'SMTN MX Voucher'&& led.LeadSource != 'CV - GBT' && led.LeadSource != 'GBT - FBLA - RMKT')
                {
                    httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "TourGen-FB-Other*New Lead", "targetId" : "' + led.Id + '"}]}');
                    flag = true;
                    
                }
                else if(led.LeadSource == 'VI Referral')   //TGR-592
                {
                    httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "TourGen-VI Referral-*New Lead", "targetId" : "' + led.Id + '"}]}');
                    flag = true;
                    
                }
                else if(led.LeadSource == 'Vacation VIP Retraveler')
                {
                    httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "TourGen-Vacation VIP Retraveler", "targetId" : "' + led.Id + '"}]}');
                    flag = true;
                    
                }
                else if(led.LeadSource == 'VVIP Westgate Orlando')
                {
                    httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "TourGen-VVIP Halo Orlando", "targetId" : "' + led.Id + '"}]}');
                    flag = true;
                    
                }
                else if(led.LeadSource == 'VVIP Westgate Las Vegas')
                {
                    httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "TourGen-VVIP Halo Vegas", "targetId" : "' + led.Id + '"}]}');
                    flag = true;
                    
                }
                /*else if(led.LeadSource == 'SMTN Open Survey')
{
httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "TourGen-SMTN Open Survey", "targetId" : "' + led.Id + '"}]}');
}
else if(led.LeadSource == 'VIN Open Survey')
{
httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "TourGen-VIN Open Survey", "targetId" : "' + led.Id + '"}]}');
}*/
                else if(led.LeadSource == 'SMTN Rental Offer')
                {
                    httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "Travel Sales-Rental Inquiries", "targetId" : "' + led.Id + '"}]}');
                    flag = true;
                    
                }
                else if(led.LeadSource == 'Timeshare Nation TCS')
                {
                    httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "Timeshare Nation-TCS", "targetId" : "' + led.Id + '"}]}');
                    flag = true;                    
                }
                
                else if((led.LeadSource == 'GBT - FBLA - RMKT' || led.LeadSource == 'CV - GBT') && led.Is_Duplicate__c == False)
                {
                    httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "Social Ad-Sales - GBT", "targetId" : "' + led.Id + '"}]}');
                    flag = true;                    
                }
                
                else if(led.LeadSource == 'Vacation VIP - Web')
                {
                    httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "TourGen-Vacation VIP Web", "targetId" : "' + led.Id + '"}]}');
                    flag = true;
                    
                }
                /*else if(led.leadSource=='SMTN MX Voucher' && led.is_duplicate__C==false && led.recordtypeid==leadRecTypeId && led.leadassist__Use_Round_Robin__c=='ASSIGNED' && led.SMTN_match_group__c=='TRUE'){

httpReq.setBody('{"inputs" : [{"salesCadenceNameOrId" : "TourGen-SMTN MX *New Lead", "targetId" : "' + led.Id + '"}]}');

}*/
                
                String response = '';
                try {
                    if(flag){
                        Http http = new Http();
                        HttpResponse httpResponse = http.send(httpReq);
                        if (httpResponse.getStatusCode() == 200) {
                            response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                        } else {
                            System.debug('http response: ' + httpResponse.getBody());
                            String responseBodyStr = httpResponse.getBody();
                            if(!responseBodyStr.contains('This target is already in a Cadence.')){
                                errorLog.add('LeadOwner = '+led.Owner.Name+' // httpReqGetBody = '+httpReq.getBody()+'Error : '+httpResponse.getBody()+'//;');
                            }
                            //throw new CalloutException(httpResponse.getBody());
                        }
                    }
                } catch (System.Exception e) {
                    System.debug('ERROR! ' + e);
                    errorLog.add('Error : '+e.getMessage()+'/;/');
                    //throw e;
                }
                
                System.debug('response: ' + response);                
            }
            if(errorLog.size()>0 && errorLog != null)
            {
                try {
                    Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                    if(!runningInASandbox){
                        String message = String.valueOf(errorLog);
                        system.debug('--message-'+message);
                        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                        String[] sendingTo = new String[]{'victor.goncalves@nerdsoft.com'};
                            semail.setToAddresses(sendingTo);
                        semail.setSubject('leadTriggerOMHandler is failed for some Leads Cadence Assignment');
                        semail.setPlainTextBody(message);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                    }
                } 
                catch( System.Exception e){
                    System.debug('ERROR: '+ e);
                }
            }
        }
    }
    
    /* public static void smtnMXLeadMatchGroup(list<lead> newLeads){

Id leadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SMTN_Mexico').getRecordTypeId();        
for(lead l: newLeads){

if(l.leadSource=='SMTN MX Voucher' && l.is_duplicate__C==false && l.recordtypeid==leadRecTypeId){
l.SMTN_match_group__c='TRUE';
l.leadassist__Use_Round_Robin__c='TRUE';
l.Assign_to_Sales_Cadence__c=true;
}
}

}

public static void smtnMXLeadSalesCadence(list<lead> leadList){

list<String> cadenceLeadsId= new list<String>();

Id leadRecTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('SMTN_Mexico').getRecordTypeId();        

for(lead l:leadList){

if(l.leadSource=='SMTN MX Voucher' && l.is_duplicate__C==false && l.recordtypeid==leadRecTypeId && l.leadassist__Use_Round_Robin__c=='ASSIGNED' && l.SMTN_match_group__c=='TRUE'){
cadenceLeadsId.add(l.id);
}

}

if(cadenceLeadsId.size()>0){
for(String Lid: cadenceLeadsId){
sendSalesCadenceRequest(Lid,'TourGen-SMTN MX New Lead');
}
}

}*/
    
}