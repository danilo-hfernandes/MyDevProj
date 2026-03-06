public class EnrollmentQueueAPICallout implements Queueable, Database.AllowsCallouts {
    private List<HSI_Enrollment_Queue__c> records;

    public EnrollmentQueueAPICallout(List<HSI_Enrollment_Queue__c> recs) {
        this.records = recs.deepClone(true);
        System.debug('📥 Queueable initialized with ' + records.size() + ' records.');
    }

    public void execute(QueueableContext qc) {
        List<HSI_Enrollment_Queue__c> updates = new List<HSI_Enrollment_Queue__c>();

        for (HSI_Enrollment_Queue__c callbatch : records) {
            try {
                if (String.isBlank(callbatch.Member_Number__c)) {
                    System.debug('⚠️ Skipping record ' + callbatch.Id + ' because Member_Number__c is blank.');
                    continue;
                }
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                String endpoint = '';
                if(runningInASandbox){
                    endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/member/GetMembershipInformation';
                    //endpoint = 'https://webapihsicorev2.azurewebsites.net/api/member/memberCheckStats';
                }
                else{ 
                    endpoint = 'https://webapihsicorev2.azurewebsites.net/api/member/GetMembershipInformation';
                }
                endpoint += '?memberNumber=' + EncodingUtil.urlEncode(callbatch.Member_Number__c, 'UTF-8');

                Http http = new Http();
                HttpRequest httpRequest = new HttpRequest();
                httpRequest.setEndpoint(endpoint);
                httpRequest.setMethod('GET');
                httpRequest.setHeader('Content-Type', 'application/json');
                // httpRequest.setHeader('Authorization', 'Bearer ' + token); // when token is available

                HttpResponse res = http.send(httpRequest);

                if (res.getStatusCode() == 200) {
                    Map<String, Object> receivedData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

                    Boolean success = receivedData.containsKey('IsValid') 
                                      ? Boolean.valueOf(receivedData.get('IsValid')) 
                                      : false;
                    System.debug('♣ Found record ' + receivedData + ' found record.' + success );
                    if (success) {

                        HSI_Enrollment_Queue__c updhsi = new HSI_Enrollment_Queue__c();
                        updhsi.Id = callbatch.Id;
                    
                         if (updhsi.Id == null) {
                            System.debug(LoggingLevel.ERROR, '❌ Skipping update: Id is null for record ' + callbatch);
                            continue;
                        }
                    
                        updhsi.Processed_On__c = Date.today();
                        updhsi.Successful_Processed__c = true;
                        updhsi.Comments__c = 'enrollment processed public class EnrollmentQueueAPICallout from enrollmentQueueTrigger by the api : ' + httpRequest.getEndpoint();
                        updhsi.Update_Account__c = true;

                        if (receivedData.containsKey('ContactId')) {
                            updhsi.Contact_Id__c = String.valueOf(receivedData.get('ContactId'));
                        }
                        System.debug(LoggingLevel.INFO, 'Preparing HSI_Enrollment_Queue__c update: ' +
                                     'Id=' + updhsi.Id + 
                                     ', Processed_On__c=' + updhsi.Processed_On__c + 
                                     ', Successful_Processed__c=' + updhsi.Successful_Processed__c + 
                                     ', Comments__c=' + updhsi.Comments__c + 
                                     ', Update_Account__c=' + updhsi.Update_Account__c + 
                                     ', Contact_Id__c=' + updhsi.Contact_Id__c
);
                        
                        updates.add(updhsi);
                }
                } else {
                    System.debug('API error for ' + callbatch.Id + ': ' + res.getStatus() + ' - ' + res.getBody());
                }
            } catch (Exception e) {
                System.debug('Exception for ' + callbatch.Id + ': ' + e.getMessage());
            }
           }

        if (!updates.isEmpty()) {
            System.debug('🔹 Performing DML update on ' + updates.size() + ' records.');
            update updates;
        }else {
            System.debug('⚠️ No records to update.');
        }
    }
}