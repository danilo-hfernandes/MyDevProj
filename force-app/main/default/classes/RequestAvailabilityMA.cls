@RestResource(urlMapping='/RequestAvailabilityMonsterAPI/*')
Global class RequestAvailabilityMA {
    
    private static final String SUCCESS = 'Success';
    private static final String ERROR = 'Error';
    
    @Httppost
    global static ResponseWrapper createOppAndRelatedRecord()
    {
        ResponseWrapper response = new ResponseWrapper();
        response.status = SUCCESS; 
        response.errorMessage = '';
        RestRequest req = RestContext.request;
        system.debug('--req--'+req);
        try {
            Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
            system.debug('--receivedData--'+receivedData);    
            String startDate = receivedData.containsKey('StartDate') ? String.valueOf(receivedData.get('StartDate')) : '';
            String endDate = receivedData.containsKey('EndDate') ? String.valueOf(receivedData.get('EndDate')) : '';
            String SubscriberIdReceived = receivedData.containsKey('SubscriberId') ? String.valueOf(receivedData.get('SubscriberId')) : '';
            Integer ContactIdReceived = receivedData.containsKey('ContactId') ? (Integer)(receivedData.get('ContactId')) : null;
            system.debug('--SubscriberIdReceived--'+SubscriberIdReceived);    
            system.debug('--ContactIdReceived--'+ContactIdReceived);    
            
            if(SubscriberIdReceived != null && SubscriberIdReceived != '' && ContactIdReceived != null){
                system.debug('--SubscriberIdReceived--'+SubscriberIdReceived);
                List<Contact> contactList = [select id,AccountId,Account.Name from Contact where Subscriber_Id__c =: SubscriberIdReceived and Contact_Id__c =:ContactIdReceived];
                
                if(contactList != null && contactList.size() > 0){
                    // Date formate :  2021-06-16 00:00:00
                    system.debug('-startDate---'+startDate);
                    system.debug('---EndDate-'+endDate);
                    
                    List<Inventory_Availability__c> InventoryAvailabilityList = new List<Inventory_Availability__c>();
                    String InventoryQuery = 'select id,Plaza__c,Resort_Name__c,Site_Name__c,Unit_Type__c,Check_In_Date__c, New_Availability__c,Inventory_Management__r.Capacity__c,Inventory_Management__r.Room_Type__c from Inventory_Availability__c ';
                    String QueryWhereCondition = '';
                    if(startDate != null && (endDate == null || endDate == '')){
                        date startDatedate = date.valueof(startDate);
                        QueryWhereCondition = 'where (Unit_Type__c = \'U.H.\' OR Unit_Type__c = \'1BR\') AND Resort_Name__c LIKE \'%Mayan Palace%\' AND Check_In_Date__c = :startDatedate and New_Availability__c > 0 and Program__c = \'MKT\' order by Check_In_Date__c ';
                    }
                    if((startDate == '' || startDate == null) && endDate != null){
                        date endDatedate = date.valueof(endDate);
                        QueryWhereCondition = 'where (Unit_Type__c = \'U.H.\' OR Unit_Type__c = \'1BR\') AND Resort_Name__c LIKE \'%Mayan Palace%\' AND Check_In_Date__c = :endDatedate and New_Availability__c > 0 and Program__c = \'MKT\' order by Check_In_Date__c';
                    }
                    if(startDate != null && startDate != '' && endDate != null  && endDate != ''){
                        date startDatedate = date.valueof(startDate);
                        date endDatedate = date.valueof(endDate);
                        system.debug('-startDatedate---'+startDatedate);
                        system.debug('---endDatedate-'+endDatedate);
                        QueryWhereCondition = 'where (Unit_Type__c = \'U.H.\' OR Unit_Type__c = \'1BR\') AND Resort_Name__c LIKE \'%Mayan Palace%\' AND Check_In_Date__c >= :startDatedate and Check_In_Date__c <= :endDatedate and New_Availability__c > 0 and Program__c = \'MKT\' order by Check_In_Date__c';
                    }
                    system.debug('---find query-'+InventoryQuery+QueryWhereCondition);
                    InventoryAvailabilityList = Database.query(InventoryQuery+QueryWhereCondition); 
                    system.debug('--InventoryAvailabilityList--'+InventoryAvailabilityList.size());
                    
                    if(InventoryAvailabilityList.size() > 0){
                        RequestavailabilityPayloadMACtrl payloadObj = new RequestavailabilityPayloadMACtrl();
                        String payload = payloadObj.getAvailabilityPayload(InventoryAvailabilityList);
                        system.debug('---payload---'+payload);
                        response.status = SUCCESS;
                        response.AvailabilityObject = payload;
                    }else{
                        response.status = 'Error';
                        response.errorMessage = 'No Availability found based on given date';
                        response.AvailabilityObject = null;
                    }
                }else{
                    // If member number not found send an email to team
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','amadeu.lettieri@nerdsoft.com','victor.goncalves@nerdsoft.com'}; 
                        semail.setToAddresses(sendingTo); 
                    semail.setSubject('Subscriber Id not found for profit agility voucher API'); 
                    semail.setPlainTextBody('Request : '+receivedData);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                    
                    
                    response.status = ERROR;
                    response.errorMessage = 'Subscriber Id not found for profit agility voucher API';
                }
            }else{
                // If member number not found send an email to team
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','amadeu.lettieri@nerdsoft.com','victor.goncalves@nerdsoft.com'}; 
                    semail.setToAddresses(sendingTo); 
                semail.setSubject('Subscriber Id not found for profit agility voucher API'); 
                semail.setPlainTextBody('Request : '+receivedData);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                
                response.status = ERROR;
                response.errorMessage = 'Subscriber Id not found for profit agility voucher API';
            }
        }catch (Exception ex){
            System.debug('Exception occurrred on LineNumber:' + ex.getLineNumber() + ', Message:' + ex.getMessage());
            response.status = ERROR;
            response.errorMessage = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
        }
        return response;   
    }
    global class ResponseWrapper{
        webservice String status; 
        webservice String errorMessage;
        webservice string AvailabilityObject;
    }
    public class MyException extends Exception {}

}