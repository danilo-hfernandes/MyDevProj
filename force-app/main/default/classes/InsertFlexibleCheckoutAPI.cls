@RestResource(urlMapping='/InsertFlexibleCheckoutAPI/*')
Global class InsertFlexibleCheckoutAPI {
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
            
            String MembershipNumber = receivedData.containsKey('MemberNumber') ? String.valueOf(receivedData.get('MemberNumber')) : '';
            system.debug('--MembershipNumber--'+MembershipNumber);
            Id AccountId = null;
            String AccountName = '';
            // Check if Account exist based on member number else create new account.
            if(MembershipNumber != null && MembershipNumber != ''){
                system.debug('--MembershipNumber--'+MembershipNumber);
                List<Account> accList = [select id,Name from Account where Member_Number__c =: MembershipNumber];
                if(accList != null && accList.size() > 0){
                    AccountId = accList[0].Id;
                    AccountName = accList[0].Name;
                    
                }else{
                    Account acc = new Account();
                    String FirstName = receivedData.containsKey('FirstName') ? String.valueOf(receivedData.get('FirstName')) : '';
                    String LastName = receivedData.containsKey('LastName') ? String.valueOf(receivedData.get('LastName')) : '';
                    acc.Name = FirstName+' '+LastName;
                    acc.Member_Number__c = receivedData.containsKey('MemberNumber') ? String.valueOf(receivedData.get('MemberNumber')) : '';
                    acc.Master_Record_Id__c = receivedData.containsKey('Master_Record_Id') ? String.valueOf(receivedData.get('Master_Record_Id')) : '';
                    acc.Email__c = receivedData.containsKey('Email') ? String.valueOf(receivedData.get('Email')) : '';
                    insert acc;
                    AccountId = acc.Id;
                    AccountName = acc.Name;
                    
                }
            }
            // Query Product
            string productId = receivedData.containsKey('ProductID') ? String.valueOf(receivedData.get('ProductID')) : '';
            system.debug('-productId-'+productId);
            List<product2> product2List  = [SELECT Id,Name from product2 where Id =: productId];
            system.debug('-product2List-'+product2List);
            Id OpportunityRecordtypeId = null;
            Id PaymentRecordtypeId = null;
            if(product2List != null && product2List.size() > 0){
                system.debug('--product2List[0].Name--'+product2List[0].Name);
                if(product2List[0].Name.contains('Voucher')){
                    system.debug('--OpportunityRecordtypeId-');
                   OpportunityRecordtypeId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
                   PaymentRecordtypeId =  Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Voucher').getRecordTypeId();
                }
            }
            
            // Create Opportunity
            Opportunity opp = new Opportunity();
            opp.AccountId = AccountId;
            Opp.CloseDate = system.today();
            opp.StageName = 'Closed Won';
            Opp.RecordTypeId = OpportunityRecordtypeId;
            system.debug('--OpportunityRecordtypeId-'+OpportunityRecordtypeId);
            opp.Name = AccountName;
            insert opp;
            
            
            
            Payment__c newPmnt = new Payment__c();
            System.debug('InsertPaymentService => @receivedData='+ receivedData);
            newPmnt.RecordTypeId = PaymentRecordtypeId;
            newPmnt.Name = AccountName +''+system.now().format('yyyyMMdd');
            newPmnt.Payment_Type__c = 'Payment';
            newPmnt.Payment_Date__c = system.today();
            newPmnt.Opportunity__c = opp.Id;
            //newPmnt.Payment_Number__c = receivedData.containsKey('TransactionID') ? String.valueOf(receivedData.get('TransactionID')) : '';
            newPmnt.Paid_On__c = system.today();
            newPmnt.Payment_Processed__c = true;
            newPmnt.Transaction_Type__c = 'Voucher';
            newPmnt.Product_Salesforce_Id__c = receivedData.containsKey('ProductID') ? String.valueOf(receivedData.get('ProductID')) : '';
            
            String FirstName = receivedData.containsKey('FirstName') ? String.valueOf(receivedData.get('FirstName')) : '';
            String LastName = receivedData.containsKey('LastName') ? String.valueOf(receivedData.get('LastName')) : '';
            newPmnt.CC_Holder_Name__c = FirstName+' '+LastName;
            
            
            
            newPmnt.Payment_Amount__c = receivedData.containsKey('NetAmount') ? (Decimal)receivedData.get('NetAmount') : 0;
            newPmnt.PromoCode_Name__c = receivedData.containsKey('PromoCodeName') ? String.valueOf(receivedData.get('PromoCodeName')) : '';
			newPmnt.PromoCode_Discount_Amount__c = receivedData.containsKey('PromoCodeAmount') ? (Decimal)receivedData.get('PromoCodeAmount') : 0; 
            newPmnt.Credit_Used__c = receivedData.containsKey('CreditUsed') ? (Decimal)receivedData.get('CreditUsed') : 0; 
            
            Insert newPmnt;
            
            // Creat Opportunity Line item here
            List<PricebookEntry> pricebookList = [select id ,Product2.Family,Name,Pricebook2Id ,Product2Id,UnitPrice from PricebookEntry where IsActive= true and Product2Id =:productId];
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = opp.Id;
            oli.PricebookEntryId=pricebookList[0].Id;
            oli.Retail_Price__c = receivedData.containsKey('NetAmount') ? (Decimal)receivedData.get('NetAmount') : 0;
            insert oli;
            
            response.opportunityId = opp.Id;
            response.paymentId = newPmnt.Id;
             
            
         } catch (Exception ex){
            System.debug('Exception occurrred on LineNumber:' + ex.getLineNumber() + ', Message:' + ex.getMessage());
            response.status = ERROR;
            response.errorMessage = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
        }
        
        return response;   
    }
    
    global class ResponseWrapper{
        webservice String status; 
        webservice String errorMessage;
        webservice String opportunityId;
        webservice String paymentId;
    }
    
    public class MyException extends Exception {}
}