@RestResource(urlMapping='/RequestInventorybooking/*')
Global class RequestInventorybookingCtrl {
    private static final String SUCCESS = 'Success';
    private static final String ERROR = 'Error';
    @Httppost
    global static ResponseWrapper createOppAndRelatedRecord()
    {
        ResponseWrapper response = new ResponseWrapper();
        response.Message = SUCCESS; 
        response.errorMessage = '';
        RestRequest req = RestContext.request;
        system.debug('--req--'+req);
        try {
            Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
            Object AvailabilityObj = (Object)receivedData.get('AvailabilityObjectRecord');
            Map<String,Object> AvailabilityObjMap = (Map<String,Object>)AvailabilityObj;
            
            Object TravelerInformationObj = (Object)receivedData.get('TravelerInformation');
            Map<String,Object> TravelerInformationObjMap = (Map<String,Object>)TravelerInformationObj;
            
            Object PaymentInformationObj = (Object)receivedData.get('PaymentInformation');
            Map<String,Object> PaymentInformationObjMap = (Map<String,Object>)PaymentInformationObj;
            
            String SubscriberIdReceived = receivedData.containsKey('SubscriberId') ? String.valueOf(receivedData.get('SubscriberId')) : '';
            Integer ContactIdReceived = receivedData.containsKey('ContactId') ? (Integer)(receivedData.get('ContactId')) : null;
             
            // Check if Account exist based on member number else create new account.
            if(SubscriberIdReceived != null && SubscriberIdReceived != '' && ContactIdReceived != null){
                system.debug('--SubscriberIdReceived--'+SubscriberIdReceived);
                List<Contact> contactList = [select id,AccountId,Account.Name from Contact where Subscriber_Id__c =: SubscriberIdReceived and Contact_Id__c =:ContactIdReceived];
                String invId = AvailabilityObjMap.containsKey('Id') ? String.valueOf(AvailabilityObjMap.get('Id')) : '';
                system.debug('--invId---'+invId);
                List<Inventory_Availability__c> invList = new List<Inventory_Availability__c>();
                if(invId != null && invId!=''){
                    invList = [select id,New_Availability__c,Inventory_Management__r.Total_Upgrade__c from Inventory_Availability__c where id =:invId];
                    system.debug('--invList---'+invList);
                }
                if(contactList != null && contactList.size() > 0){
                    // Create Opportunity
                    // Map all the reservation related field
                    if(invList != null && invList.size() > 0){
                        Opportunity opp = new Opportunity();
                        Opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Profit Agility Voucher').getRecordTypeId();
                        Opp.Name = contactList[0].Account.Name;
                        opp.AccountId = contactList[0].AccountId;
                        Opp.CloseDate = system.today();
                        
                        // Mapp all the travel information feild
                        Opp.Traveler_Name__c = TravelerInformationObjMap.containsKey('Traveler_Name__c') ? String.valueOf(TravelerInformationObjMap.get('Traveler_Name__c')) : '';
                        Opp.Traveler_Email__c = TravelerInformationObjMap.containsKey('Traveler_Email__c') ? String.valueOf(TravelerInformationObjMap.get('Traveler_Email__c')) : '';
                        Opp.Traveler_Address__c = TravelerInformationObjMap.containsKey('Traveler_Address__c') ? String.valueOf(TravelerInformationObjMap.get('Traveler_Address__c')) : '';
                        Opp.Traveler_State__c = TravelerInformationObjMap.containsKey('Traveler_State__c') ? String.valueOf(TravelerInformationObjMap.get('Traveler_State__c')) : '';
                        Opp.Traveler_Phone__c = TravelerInformationObjMap.containsKey('Traveler_Phone__c') ? String.valueOf(TravelerInformationObjMap.get('Traveler_Phone__c')) : '';
                        Opp.Traveler_Country__c = TravelerInformationObjMap.containsKey('Traveler_Country__c') ? String.valueOf(TravelerInformationObjMap.get('Traveler_Country__c')) : '';
                        Opp.Traveler_City__c = TravelerInformationObjMap.containsKey('Traveler_City__c') ? String.valueOf(TravelerInformationObjMap.get('Traveler_City__c')) : '';
                        Opp.Traveler_Zip__c = TravelerInformationObjMap.containsKey('Traveler_Zip__c') ? String.valueOf(TravelerInformationObjMap.get('Traveler_Zip__c')) : '';
                        opp.StageName = 'Closed Won';
                        // Map Inventory id to track the inventory availability check
                        
                        Opp.Inventory_Availability_Id__c  = invList[0].Id;
                        Opp.Destination__c = AvailabilityObjMap.containsKey('Plaza__c') ? String.valueOf(AvailabilityObjMap.get('Plaza__c')) : '';
                        Opp.Property__c = AvailabilityObjMap.containsKey('Resort_Name__c') ? String.valueOf(AvailabilityObjMap.get('Resort_Name__c')) : '';
                        Opp.Site_Name__c = AvailabilityObjMap.containsKey('Site_Name__c') ? String.valueOf(AvailabilityObjMap.get('Site_Name__c')) : '';
                        Opp.Rooms__c = AvailabilityObjMap.containsKey('Unit_Type__c') ? String.valueOf(AvailabilityObjMap.get('Unit_Type__c')) : '';
                        Opp.Room_Type__c = AvailabilityObjMap.containsKey('Room_Type__c') ? String.valueOf(AvailabilityObjMap.get('Room_Type__c')) : '';
                        string checkingdate = AvailabilityObjMap.containsKey('Check_In_Date__c') ? String.valueOf(AvailabilityObjMap.get('Check_In_Date__c')) : '';
                        system.debug('--checkingdate---'+checkingdate);
                        Opp.Check_in__c = date.valueof(checkingdate);
                        if(Opp.Check_in__c != null){
                            Opp.Check_Out__c = Opp.Check_in__c.addDays(7);
                        }
                        Opp.Reservation_Status__c = 'Pending';
                        if(Opp.Reservation_Status__c == 'Pending'){
                            Opp.StageName = 'Closed Booked';
                        }
                        //oppRecord.Booking_Agent__c = userinfo.getUserId();
                        Opp.Capacity__c = AvailabilityObjMap.containsKey('Capacity__c') ? String.valueOf(AvailabilityObjMap.get('Capacity__c')) : '';
                        opp.Base_Price__c = PaymentInformationObjMap.containsKey('Base_Price__c') ? (Decimal)PaymentInformationObjMap.get('Base_Price__c') : 0;
                        opp.Total_Upgrades__c = PaymentInformationObjMap.containsKey('Total_Upgrades__c') ? (Decimal)PaymentInformationObjMap.get('Total_Upgrades__c') : 0;
                        system.debug('--opp.Base_Price__c---'+opp.Base_Price__c);
                        system.debug('-Total_Upgrades__c---'+opp.Total_Upgrades__c);
                        
                        insert opp;
                        
                        // Update inventory
                        if(invList != null){
                            invList[0].New_Availability__c = invList[0].New_Availability__c - 1;
                            update invList[0];
                        }
                        // Create Opportunity line item
                         List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
                        if(opp.Id != null){
                            system.debug('--PaymentInformationObjMap--'+PaymentInformationObjMap);                            						 
                            List<PricebookEntry> pricebookListStandard = [select id ,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true and Product2.Name = 'Vida Voucher-Profit Agility'];
                            OpportunityLineItem oliStd = new OpportunityLineItem();
                            oliStd.OpportunityId = opp.Id;
                            oliStd.PricebookEntryId=pricebookListStandard[0].Id;
                            //oliStd.Retail_Price__c = (PaymentInformationObjMap.containsKey('Base_Price__c') ? (Decimal)PaymentInformationObjMap.get('Base_Price__c') : 0) + (PaymentInformationObjMap.containsKey('Total_Upgrades__c') ? (Decimal)PaymentInformationObjMap.get('Total_Upgrades__c') : 0);
                            oliStd.Retail_Price__c = PaymentInformationObjMap.containsKey('Payment_Amount__c') ? (Decimal)PaymentInformationObjMap.get('Payment_Amount__c') : 0;
                            system.debug('-oliStd.Retail_Price__c---'+oliStd.Retail_Price__c);
                            insert oliStd;
                            oppLineItemList = [select id,Product_Id__c from OpportunityLineItem where Id =:oliStd.Id];
                            system.debug('--oppLineItemList--'+oppLineItemList);
                        }        
                         
                        // Create payment
                        Payment__c newPmnt = new Payment__c();
                        System.debug('InsertPaymentService => @receivedData='+ PaymentInformationObjMap);
                        newPmnt.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Profit Agility Voucher').getRecordTypeId();
                        newPmnt.Name = contactList[0].Account.Name +''+system.now().format('yyyyMMdd');
                        newPmnt.Payment_Type__c = 'Payment';
                        newPmnt.Payment_Date__c = system.today();
                        newPmnt.Opportunity__c = opp.Id;
                        newPmnt.Paid_On__c = system.today();
                        if(oppLineItemList != null){
                        	newPmnt.Product_Id__c = oppLineItemList[0].Product_Id__c;
                        }
                        newPmnt.Payment_Processed__c = true;
                        newPmnt.Transaction_Type__c = 'Profit Agility Voucher';
                        newPmnt.Authorization_Code__c = PaymentInformationObjMap.containsKey('Authorization_Code__c') ? (String)PaymentInformationObjMap.get('Authorization_Code__c') : '';
                        newPmnt.Payment_Amount__c = PaymentInformationObjMap.containsKey('Payment_Amount__c') ? (Decimal)PaymentInformationObjMap.get('Payment_Amount__c') : 0;
                        newPmnt.AuthorizeNet_Transaction_Id__c = PaymentInformationObjMap.containsKey('AuthorizeNet_Transaction_Id__c') ? (String)PaymentInformationObjMap.get('AuthorizeNet_Transaction_Id__c') : '';
                        
                        decimal dm = PaymentInformationObjMap.containsKey('Payment_Amount__c') ? (Decimal)PaymentInformationObjMap.get('Payment_Amount__c') : 0;
                        system.debug('dm---'+dm);
                        system.debug('---newPmnt.Payment_Amount__c---'+newPmnt.Payment_Amount__c);
                        Insert newPmnt;
                        
                        response.Message = SUCCESS;
                        response.OpportunityId = opp.Id;
                        response.Success = true;
                    }
                    else{
                        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                        String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','amadeu.lettieri@nerdsoft.com','mitul.thumar@nerdsoft.com','jc.yalcin@nerdsoft.com'}; 
                        semail.setToAddresses(sendingTo); 
                        semail.setSubject('Selected Inventory not found in Salesforce for profit agility voucher API'); 
                        semail.setPlainTextBody('Request : '+receivedData);
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                        
                        response.Message = ERROR;
                        response.OpportunityId = '';
                        response.errorMessage = 'Selected Inventory not found in Salesforce for profit agility voucher API';
                        response.Success = false;
                    }
                }else{
                    // If member number not found send an email to team
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','amadeu.lettieri@nerdsoft.com','mitul.thumar@nerdsoft.com','jc.yalcin@nerdsoft.com'}; 
					semail.setToAddresses(sendingTo); 
                    semail.setSubject('Subscriber Id not found for profit agility voucher API'); 
                    semail.setPlainTextBody('Request : '+receivedData);
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                    
                    response.Message = ERROR;
                    response.OpportunityId = '';
                    response.errorMessage = 'Member number not found, Email sent to the team with details';
                    response.Success = false;
                }
            }else{
                // If member number not found send an email to team
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    String[] sendingTo = new String[]{'amadeu.lettieri@nerdsoft.com','amadeu.lettieri@nerdsoft.com','mitul.thumar@nerdsoft.com'}; 
					semail.setToAddresses(sendingTo); 
                    semail.setSubject('Subscriber Id not found for profit agility voucher API'); 
                    semail.setPlainTextBody('Request : '+receivedData);
                	Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                    
                    response.Message = ERROR;
                    response.OpportunityId = '';
                    response.errorMessage = 'Member number not found, Email sent to the team with details';
                    response.Success = false;
            }
        } catch (Exception ex){
            Error_Handler__c err = new Error_Handler__c();
            err.Name = 'Servic : RequestInventorybooking, Apex Class : RequestInventorybookingCtrl';
            err.Error_Message__c = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
            insert err;
            
            System.debug('Exception occurrred on LineNumber:' + ex.getLineNumber() + ', Message:' + ex.getMessage());
            response.Message = ERROR;
            response.errorMessage = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
            response.Success = False;
        }
        return response;   
    }
    global class ResponseWrapper{
        webservice String Message; 
        webservice Boolean Success;
        webservice String errorMessage;
        webservice string OpportunityId;
    }
    public class MyException extends Exception {}
}