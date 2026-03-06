public class MonsterProductsWebservice {
    @AuraEnabled
    public static string hitSubmissionAPI(String oppId, String token, String cardNumber, String cardType, String cardExp, Boolean flag, String firstName, String lastName, String street, String city, String state, String country, String zipCode,String email, String phone){
        try{
            System.debug('>>>>ZipCode'+zipCode+'flag'+flag);
            String errorMessage = 'Success';
            List<Payment__c> paymentList = new List<Payment__c>();
            //system.debug('>>paymentId>>>'+paymentId);
            //List<Payment__c> paymentList = [select id, Payment_Amount__c,Opportunity__c,Product_Name__c,Product_Id__c,Opportunity_Product__c, Opportunity__r.AccountId from Payment__c where Id =: paymentId];
            set<String> setproductName = new set<String>{'M-Domestic 5 Days/4 Nights', 'M-International 6 Days/5 Nights', 'M-Week 8 Days/7 Nights'};
                List<Opportunity> oppList = [select id,AccountId, (select id,Product2.Name,TotalPrice,Product_Id__c from OpportunityLineItems where Product2.Name IN : setproductName) from Opportunity where Id =: oppId];
            if(oppList != null && oppList.size() > 0 && oppList[0].OpportunityLineItems.size() > 0){
                List<Account> listAccount = [select id,Name,Phone,Email__c,First_Name__c,Last_Name__c,BillingCity,BillingCountry,BillingState,BillingStreet,BillingPostalCode from Account where Id =: oppList[0].AccountId];
                String endpoint = 'https://us-central1-monster-partner-portal.cloudfunctions.net/receiveSubmission';
                //Request Body
                SubmissionAPIDetailDTO objsubmissionData = new SubmissionAPIDetailDTO();
                objsubmissionData.test = 'bGVcIG1lIrtub3cgAWYgeW91IGRlY295ZSB0aGlzIGFuZCBJJ2xsIGxhdWdoIGF0ITlvdSEh'; //static value
                Decimal amount = 0.0;
                System.debug('>>>>flag'+flag);
                dataDTO objData = new dataDTO();
                List<selectedChargesDTO> listSelectedCharges = new List<selectedChargesDTO>();
                List<preppedCardsDTO> listpreppedCards = new List<preppedCardsDTO>();
                //guestContact & billingInfo
                guestContactDTO objGuestContact = new guestContactDTO();
                objGuestContact.address1 = listAccount[0].BillingStreet;
                objGuestContact.city = listAccount[0].BillingCity;
                objGuestContact.first_name = listAccount[0].First_Name__c+' '+listAccount[0].Last_Name__c; //'Test Fail 1';
                objGuestContact.last_name = '';
                objGuestContact.state = listAccount[0].BillingState;
                objGuestContact.zip = listAccount[0].BillingPostalCode;
                objGuestContact.email = listAccount[0].Email__c;
                objGuestContact.phone = listAccount[0].Phone;
                objGuestContact.salesOffice = 'MBP'; //Will always be "MBP".
                //objGuestContact.maritalStatus = '';
                
                for(OpportunityLineItem objLineItems : oppList[0].OpportunityLineItems){
                    amount += objLineItems.TotalPrice; 
                    //Selected Charges
                    selectedChargesDTO objSelectedCharges = new selectedChargesDTO();
                    if(objLineItems.TotalPrice > 0){
                        objSelectedCharges.chargeLabel = 'NEW PACKAGE REVENUE';
                    }
                    else{
                        objSelectedCharges.chargeLabel = objLineItems.Product2.Name; 
                    }
                    objSelectedCharges.amount = objLineItems.TotalPrice;
                    objSelectedCharges.recurring = false;
                    listSelectedCharges.add(objSelectedCharges);
                    
                }
                selectedDataDTO objselectedData = new selectedDataDTO();
                objselectedData.genieNumber = 'No genie';
                objselectedData.selectedRep = '';
                objselectedData.selectedSource = 'Package Sales';
                objselectedData.selectedTo = '';
                objselectedData.selectedVo = '';
                objselectedData.notes = '';
                
                preppedCardsDTO objpreppedCards = new preppedCardsDTO();
                //Passed parameter from component
                tokenDTO objtoken = new tokenDTO();
                objtoken.cardExp = cardExp; 
                objtoken.cardType = cardType; 
                objtoken.lastFour = cardNumber.right(4); 
                objtoken.token = token;
                
                objpreppedCards.token = objtoken;
                if(flag){
                    objpreppedCards.billingInfo = objGuestContact;
                }
                else{
                    guestContactDTO objBillingInfo = new guestContactDTO();
                    objBillingInfo.address1 = street;
                    objBillingInfo.city = city;
                    objBillingInfo.first_name = firstName+' '+lastName; //'Test Fail 1';
                    objBillingInfo.last_name = '';
                    objBillingInfo.state = State;
                    objBillingInfo.zip = zipCode;
                    objBillingInfo.email = email;
                    objBillingInfo.phone = phone;
                    objBillingInfo.salesOffice = 'MBP'; //Will always be "MBP".
                    objpreppedCards.billingInfo = objBillingInfo;
                }
                objpreppedCards.amount = amount;
                objpreppedCards.recurring = false;
                listpreppedCards.add(objpreppedCards);
                
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                //Data
                objData.isTest = runningInASandbox;
                objData.runPayment = true;
                objData.amountToday = amount;
                objData.isPartial = false;
                objData.monthsOpen = '18' ;
                objData.packagePrice = amount;
                objData.selectedCharges = listSelectedCharges;
                objData.selectedData = objselectedData;
                objData.guestContact = objGuestContact;
                objData.preppedCards = listpreppedCards;
                
                objsubmissionData.data = objData;
                System.debug('>>objsubmissionData>>'+objsubmissionData);
                String requestBody = JSON.serializePretty(objsubmissionData);
                System.debug('>>requestBody>>'+requestBody);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setBody(requestBody);
                request.setHeader('content-type', 'application/json');
                request.setTimeout(60000);
                system.debug('--request--'+request);
                String response = '';
                HttpResponse httpResponse = http.send(request);
                system.debug('--httpResponse--'+httpResponse);
                String crmStatus;
                Boolean paymentStatus;
                Map<String,Object> receivedData = new Map<String,Object>();
                if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                    System.debug('>>> response ' + httpResponse.getBody());
                    response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()));
                    receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                    crmStatus = receivedData.containsKey('crmStatus') ? String.valueOf(receivedData.get('crmStatus')) : null;
                    paymentStatus = Boolean.valueOf(receivedData.get('paymentStatus'));
                    /*Opportunity opp = new Opportunity();
opp.Id = oppId;
opp.Partner_Response__c = 'Error Message - '+errorMessage;
update opp;
return errorMessage;*/
                }
                else{                    
                    response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                    receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                    system.debug('--receivedData-'+receivedData);
                    crmStatus = receivedData.containsKey('crmStatus') ? String.valueOf(receivedData.get('crmStatus')) : null;
                    paymentStatus = Boolean.valueOf(receivedData.get('paymentStatus'));
                }
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                opp.Partner_Confirmation_Number__c = crmStatus;
                opp.Partner_Response__c = 'crmStatus - '+crmStatus+' paymentStatus - '+paymentStatus;
                opp.Partner_ResponseDate__c = System.now();
                if(paymentStatus){
                    for(OpportunityLineItem objLineItems : oppList[0].OpportunityLineItems){
                        Id payRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Voucher').getRecordTypeId();
                        Payment__c paymentRec = new Payment__c();
                        paymentRec.Name = listAccount[0].Name;
                        paymentRec.Paid_On__c = system.today();
                        paymentRec.Payment_Type__c = 'Payment';
                        paymentRec.Opportunity__c = oppId;
                        paymentRec.Payment_Amount__c = objLineItems.TotalPrice;
                        paymentRec.RecordTypeId = payRecordTypeId;
                        paymentRec.Product_Id__c = objLineItems.Product_Id__c;
                        paymentRec.Opportunity_Product__c = objLineItems.Id;
                        paymentRec.Opportunity_Account_Email__c = listAccount[0].email__c;
                        paymentRec.Transaction_Type__c = 'Payment';
                        paymentList.add(paymentRec);
                    }
                    if(paymentList != null && paymentList.size() > 0){
                        insert paymentList;
                    }
                }
                else{
                    Error_Handler__c err = new Error_Handler__c();
                    err.Name = 'Apex Class : MonsterProductsWebservice, OpportunityId : '+oppId;
                    err.Error_Message__c = 'Request Data:'+ String.valueOf(receivedData);
                    insert err;  
                }
                
                if(crmStatus == 'false' && !paymentStatus){
                    errorMessage = 'The CRM status was not generated, and the payment has not been processed; please contact your administrator.';
                }
                else if(crmStatus == 'false' && paymentStatus) {
                    errorMessage = 'The CRM status was not generated; please contact your administrator.';
                }
                else if(crmStatus != 'false' && !paymentStatus){
                    errorMessage = 'The payment was not processed; please contact your administrator.';
                }
                update opp;
                return errorMessage;
                
            }
            return null;
        }catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
            Error_Handler__c err = new Error_Handler__c();
            err.Name = 'Apex Class : MonsterProductsWebservice, OpportunityId : '+oppId;
            err.Error_Message__c = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
            insert err; 
        }
        return null;
    }
    public class SubmissionAPIDetailDTO{
        public String test { get; set; }
        public dataDTO data {get;set;}
    }
    public class dataDTO{
        public Boolean isTest{get;set;}
        public guestContactDTO guestContact{get;set;}
        public Boolean runPayment{get;set;}
        public decimal amountToday{get;set;}
        public Boolean isPartial{get;set;}
        public Decimal packagePrice{get;set;}
        public String monthsOpen {get;set;}
        public List<preppedCardsDTO> preppedCards { get; set; }
        public List<selectedChargesDTO> selectedCharges { get; set; }
        public selectedDataDTO selectedData{get;set;}
    }
    //guestContact & billingInfo
    public class guestContactDTO{
        public String address1 { get; set; }
        public String city { get; set; }
        public String first_name { get; set; }
        public String last_name { get; set; }
        public String state { get; set; }
        public String zip { get; set; }
        public String email { get; set; }
        public String phone { get; set; }
        public String salesOffice { get; set; } //Will always be "MBP".
        public String maritalStatus { get; set; }
    }
    public class preppedCardsDTO{
        public tokenDTO token{get;set;}
        public guestContactDTO billingInfo{get;set;}
        public decimal amount{get;set;}
        public Boolean recurring{get;set;}
        
    }
    public class tokenDTO{
        public String cardExp{get;set;}
        public String cardType{get;set;}
        public String lastFour{get;set;}
        public String token{get;set;}
    }
    public class selectedChargesDTO{
        public String chargeLabel { get; set; }
        public double amount { get; set; }
        public Boolean recurring { get; set; }
    }
    public class selectedDataDTO{
        public String genieNumber { get; set; }
        public String selectedRep { get; set; }
        public String selectedSource { get; set; }
        public String selectedTo { get; set; }
        public String selectedVo { get; set; }
        public String notes { get; set; }
    }
    
}