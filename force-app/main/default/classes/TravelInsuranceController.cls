public class TravelInsuranceController {
    @AuraEnabled(cacheable=true)
    public static WrapperClassDetails validateRecord(String recordId){
        WrapperClassDetails objWrapperDetails = new WrapperClassDetails();
        List<OpportunityLineItem> opplineItem = [select id,Quote_Id__c,Product_Id__c,Check_In_Date__c,Check_Out_Date__c,Destination__c,HSI_Policy_Number__c,Product2.Name, CreatedDate  from OpportunityLineItem where OpportunityId = : recordId];
        if(opplineItem == null || opplineItem.size() == 0){
            objWrapperDetails.errorMessage = 'You cannot proceed further because there is no Opportunity Product linked to the Opportunity.';
            return objWrapperDetails;
        }
        else if(opplineItem != null && opplineItem.size() > 0){
            List<String> listProductIdstoExclude = new List<String>();
            //List<Product2> listMUProducts = [select id, Name, Upgrade_Product__c from Product2 where Upgrade_Product__c = true];
            List<Product2> listZeroDollarProducts = [select id, Name from Product2 where Id IN (select Product2Id from PricebookEntry where UnitPrice = 0)];
            System.debug('>>listZeroDollarProducts>>'+listZeroDollarProducts);
            /*for(Product2 objproduct : listMUProducts){
                listProductIdstoExclude.add(objproduct.Id);)
            }*/
            for(Product2 objproduct : listZeroDollarProducts){
                listProductIdstoExclude.add(objproduct.Id);
            }
            Integer count=0;
            for(OpportunityLineItem objLineItem : opplineItem){ 
                if(listProductIdstoExclude.contains(objLineItem.Product2Id)){
                    count++;
                }
            }
            if(count == opplineItem.size()){
                objWrapperDetails.errorMessage = 'You cannot proceed further because you have Zero Dollar Products added to the Opportunity.';
                return objWrapperDetails;
            }
            else {
                for(OpportunityLineItem objLineItem : opplineItem){
                    if(objLineItem.Product2.Name == 'HSI Travel Insurance'){
                        if(objLineItem.HSI_Policy_Number__c != null){
                            objWrapperDetails.errorMessage = 'Insurance Policy Already Assigned';
                            return objWrapperDetails;
                        }
                        else if(objLineItem.CreatedDate.addMinutes(10) >= System.Now()){
                            List<Payment__c> listpayment = [select id from Payment__c where Opportunity__C =: recordId and Product_Id__c = : objLineItem.Product_Id__c limit 1];
                            objWrapperDetails.quote_id = objLineItem.Quote_Id__c;
                            objWrapperDetails.productId = objLineItem.Product_Id__c;
                            if(listpayment != null && listpayment.size() > 0 && objLineItem.Quote_Id__c != null && objLineItem.Quote_Id__c != ''){
                                objWrapperDetails.paymentFlag = true;
                            }
                            else{
                                objWrapperDetails.paymentFlag = false;
                            }
                        }
                    }
                    else{   
                        objWrapperDetails.startDate = objLineItem.Check_In_Date__c;
                        objWrapperDetails.endDate = objLineItem.Check_Out_Date__c;
                        objWrapperDetails.destination = objLineItem.Destination__c;
                        
                    }
                }
            }
            return objWrapperDetails;
        }
        return null;
    }
    @AuraEnabled
    public static WrapperClassDetails hitProductCreation(String recordId, Decimal netPrice, String quoteId){
        /*List<OpportunityLineItem> existingobjOppline = [select id,Product_Id__c from OpportunityLineItem where OpportunityId = : recordId and Product2.Name = 'HSI Travel Insurance' limit 1];
delete existingobjOppline;*/
        WrapperClassDetails objWrapperDetails = new WrapperClassDetails();
        PriceBook2 pb2Standard = [select Id from Pricebook2 where isStandard=true];
        Product2 objProduct = [select id from Product2 where Name = 'HSI Travel Insurance' limit 1];
        List<PricebookEntry> pbEntry = [select id from PricebookEntry where Pricebook2Id =: pb2Standard.Id and Product2Id =: objProduct.Id limit 1]; 
        
        PricebookEntry objpbEntry = new PricebookEntry();
        if(pbEntry != null && pbEntry.size() >0){
            objpbEntry = pbEntry[0];
        }
        else{
            objpbEntry.Product2Id = objProduct.Id;
            objpbEntry.Pricebook2Id = pb2Standard.Id;
            objpbEntry.IsActive = true;
            objpbEntry.UnitPrice = 0;
            insert objpbEntry;
        }
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        opplineItem.opportunityId = recordId;
        opplineItem.Product2Id = objProduct.Id;
        opplineItem.PricebookEntryId = objpbEntry.Id;
        opplineItem.UnitPrice = netPrice;
        opplineItem.Quote_Id__c = quoteId;
        opplineItem.Notes_Instructions__c = 'Product added by Travel Insurance Button';
        insert opplineItem;
        
        List<OpportunityLineItem> objOppline = [select id,Product_Id__c from OpportunityLineItem where OpportunityId = : recordId and Product2.Name = 'HSI Travel Insurance' and Id =: opplineItem.Id limit 1];
        objWrapperDetails.productId = objoppline[0].Product_Id__c;
        return objWrapperDetails;
    }
    @AuraEnabled
    public static WrapperClassDetails hitQuoteAPI(String recordId, String firstName, String lastName, String street, String city, String state, String country, String email, DateTime startDate, DateTime endDate, String destination, List<Map<String, String>> travelerData){
        system.debug('>>>>>travelerData'+travelerData);
        
        Opportunity opp = [select id,Amount, (select id,Check_In_Date__c,Check_Out_Date__c,Destination__c,Product_Id__c,Quote_Id__c from opportunityLineItems limit 1) from opportunity where Id = : recordId limit 1];
        String quoteId;
        String errorMessage = 'There is an error in the API. Please contact your System Administrator.';
        WrapperClassDetails objQuoteDetails = new WrapperClassDetails();
        OpportunityLineItem opplineItem = new OpportunityLineItem();
        try{
            if(opp != null && opp.opportunityLineItems != null && opp.opportunityLineItems.size() > 0){
                String gToken = DataSyncToSQL.GetToken();
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                String endpoint = '';
                if(runningInASandbox){
                    endpoint = 'https://travelinsuranceapi-qa.azurewebsites.net/Quote/V2';
                }
                else{
                    endpoint = 'https://travelinsuranceapi.azurewebsites.net/Quote/V2';
                }
                QuoteAPiDetailDTO objwrapper = new QuoteAPiDetailDTO();
                objwrapper.total_price = opp.Amount;
                List<QuoteAPICustomerDTO> listCustomerWrapper = new List<QuoteAPICustomerDTO>();
                List<QuoteAPIProductDTO> listProductDetailWrapper = new List<QuoteAPIProductDTO>();
                for(OpportunityLineItem oppLine : opp.opportunityLineItems){
                    //productId = oppLine.Product_Id__c;
                    opplineItem = oppLine ;
                    QuoteAPICustomerDTO objCustomerWrapper = new QuoteAPICustomerDTO();
                    objCustomerWrapper.first_name = firstName;
                    objCustomerWrapper.last_name = lastName;
                    objCustomerWrapper.street = street;
                    objCustomerWrapper.city = city;
                    objCustomerWrapper.state_or_province = state;
                    objCustomerWrapper.country = country; // Use ONLY abbreviation
                    objCustomerWrapper.email = email;
                    objCustomerWrapper.primary_insured = true; //to confirm must be true for one customer
                    listCustomerWrapper.add(objCustomerWrapper);
                    
                    //ProductDetails
                    QuoteAPIProductDTO objProductWrapper = new QuoteAPIProductDTO();
                    objProductWrapper.start_date = startDate; //oppLine.Check_In_Date__c;// to be added //to  confirm Check_In_Date__c
                    objProductWrapper.end_date = endDate; //oppLine.Check_Out_Date__c;// to be added //Check_Out_Date__c
                    objProductWrapper.country_destination = destination; //oppLine.Destination__c; 
                    listProductDetailWrapper.add(objProductWrapper);
                }
                if(travelerData != null && travelerData.size() > 0){
                    for(Map<String, String> objdata : travelerData){ 
                        QuoteAPICustomerDTO objCustomerWrapper = new QuoteAPICustomerDTO();
                        objCustomerWrapper.first_name = objdata.get('firstName');
                        objCustomerWrapper.last_name = objdata.get('lastName');
                        objCustomerWrapper.street = street;
                        objCustomerWrapper.city = city;
                        objCustomerWrapper.state_or_province = state;//objdata.get('billingState');
                        objCustomerWrapper.country = country ; // Use ONLY abbreviation
                        objCustomerWrapper.email = email;//objdata.get('email');
                        objCustomerWrapper.primary_insured = false; 
                        listCustomerWrapper.add(objCustomerWrapper);
                    }
                }
                System.debug('>>>>listCustomerWrapper>>>>'+listCustomerWrapper);
                objwrapper.customers = listCustomerWrapper;
                objwrapper.product_details = listProductDetailWrapper;
                System.debug('>>objwrapper>>'+objwrapper);
                String requestBody = JSON.serialize(objwrapper);
                System.debug('>>requestBody>>'+requestBody);
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setEndpoint(endpoint);
                request.setMethod('POST');
                request.setBody(requestBody);
                request.setHeader('content-type', 'application/json');
                request.setHeader('Authorization', 'Bearer '+gToken);
                system.debug('--request--'+request);
                String response = '';
                HttpResponse httpResponse = http.send(request);
                system.debug('--httpResponse--'+httpResponse);
                if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                    system.debug('--httpResponse.getBody--'+httpResponse.getBody());
                    response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                    Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                    errorMessage = String.valueOf(receivedData.get('errorMessage'));
                    system.debug('--message-'+errorMessage);
                    objQuoteDetails.errorMessage = errorMessage;
                    return objQuoteDetails;  
                }
                else{                    
                    response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                    Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                    system.debug('--receivedData-'+receivedData);
                    quoteId = String.valueOf(receivedData.get('quote_id'));
                    
                    objQuoteDetails.quote_id = quoteId;
                    objQuoteDetails.net_price = double.valueOf(receivedData.get('net_price'));
                    objQuoteDetails.productId = opplineItem.Product_Id__c;
                    
                    /*Update Quote Id
opplineItem.Quote_Id__c = quoteId;
update opplineItem;*/
                    
                    return objQuoteDetails;                 
                }
            }
        }catch( System.Exception ex) {
            System.debug('ERROR: '+ ex);
            Error_Handler__c err = new Error_Handler__c();
            err.Name = 'Apex Class : TravelInsuranceController';
            err.Error_Message__c = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
            insert err;
            return objQuoteDetails;
        }
        return objQuoteDetails;
    }
    @AuraEnabled
    public static WrapperClassDetails hitPurchaseAPI(String recordId, String quoteId, String productId){
        
        WrapperClassDetails objWrapperDetails = new WrapperClassDetails();
        
        Opportunity oppRequestId = [SELECT Request_Id__c FROM Opportunity WHERE Id = :recordId LIMIT 1];
        
        String errorMessage = 'There is an error in the API. Please contact your System Administrator.';
        List<OpportunityLineItem> objOppline = [select id,Quote_Id__c,HSI_Policy_Number__c,Insurance_cost__c,Sales_Price__c,Insurance_provider__c,Insured_amount__c,Purchased_Date__c from OpportunityLineItem where OpportunityId = : recordId and Product2.Name = 'HSI Travel Insurance' and Product_Id__c =: productId limit 1];
        System.debug('hitPurchaseAPI objOppline.size >>>>'+objOppline.size());
        System.debug('hitPurchaseAPI objOppline.Quote_Id__c >>>>'+objOppline[0].Quote_Id__c);
        System.debug('hitPurchaseAPI objOppline.HSI_Policy_Number__c >>>>'+objOppline[0].HSI_Policy_Number__c);
        try{
            if(objOppline != null && objOppline.size() > 0 && objOppline[0].HSI_Policy_Number__c != null){
                objWrapperDetails.errorMessage = 'Insurance Policy Already Assigned';
                return objWrapperDetails;
            }
            else{
                List<Payment__c> listpayment = [select id from Payment__c where Opportunity__C =: recordId and Product_Id__c = : productId limit 1];
                System.debug('hitPurchaseAPI listpayment.size >>>>'+listpayment.size());
                
                if(quoteId == null && objOppline != null && objOppline.size() > 0 && objOppline[0].Quote_Id__c != null){
                    quoteId = objOppline[0].Quote_Id__c;
                }
                if(quoteId != null && recordId != null && listpayment != null && listpayment.size() > 0){
                    String gToken = DataSyncToSQL.GetToken();
                    Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                    String endpoint = '';
                    if(runningInASandbox){
                        endpoint = 'https://travelinsuranceapi-qa.azurewebsites.net/Purchase/V2';
                    }
                    else{
                        endpoint = 'https://travelinsuranceapi.azurewebsites.net/Purchase/V2';
                    }
                    System.debug('hitPurchaseAPI >>>>>>> Endpoint >>>>>>'+endpoint);
                    PurchaseAPiDetailDTO objwrapper = new PurchaseAPiDetailDTO();
                    objwrapper.quote_id = quoteId;
                    objwrapper.itinerary_number = recordId;
                    objwrapper.sourceApp_id = 1;
                    objwrapper.request_id = Integer.valueOf(oppRequestId.Request_Id__c) != null ? Integer.valueOf(oppRequestId.Request_Id__c) : 0;
                    
                    System.debug('hitPurchaseAPI>>objwrapper>>'+objwrapper);
                    String requestBody = JSON.serialize(objwrapper);
                    System.debug('hitPurchaseAPI>>requestBody>>'+requestBody);
                    Http http = new Http();
                    HttpRequest request = new HttpRequest();
                    request.setEndpoint(endpoint);
                    request.setMethod('POST');
                    request.setBody(requestBody);
                    request.setHeader('content-type', 'application/json');
                    request.setHeader('Authorization', 'Bearer '+gToken);
                    system.debug('hitPurchaseAPI --request--'+request);
                    String response = '';
                    HttpResponse httpResponse = http.send(request);
                    system.debug('hitPurchaseAPI --httpResponse--'+httpResponse);
                    if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                        response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                        Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                        errorMessage = String.valueOf(receivedData.get('errorMessage'));
                        system.debug('hitPurchaseAPI--message-'+errorMessage);
                        objWrapperDetails.errorMessage = errorMessage;
                        return objWrapperDetails;
                    }
                    else
                    {                    
                        response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                        Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                        system.debug('--receivedData-'+receivedData);
                        String oppId = String.valueOf(receivedData.get('itinerary_number')); 
                        Integer policyNumber = Integer.valueOf(receivedData.get('policy_number'));  
                        decimal insuranceCost = double.valueOf(receivedData.get('insurance_cost'));  
                        decimal insuranceSalesPrice = double.valueOf(receivedData.get('insurance_sale_price'));  
                        String insuranceProvider = String.valueOf(receivedData.get('insurance_provider'));  
                        decimal insuredAmount = double.valueOf(receivedData.get('insured_amount'));  
                        String apiDateString = String.valueOf(receivedData.get('purchase_date')); 
                        List<String> dateParts = apiDateString.split('/');
                        Integer month = Integer.valueOf(dateParts[0]);
                        Integer day = Integer.valueOf(dateParts[1]);
                        Integer year = Integer.valueOf(dateParts[2]);
                        Date purchaseDate = Date.newInstance(year, month, day);
                        if(objOppline != null && objOppline.size() > 0){
                            if(policyNumber != null){
                                Opportunity opp = new Opportunity();
                                opp.HSI_Policy_Number__c = String.valueOf(policyNumber);
                                opp.Id = recordId; 
                                update opp;
                            }
                            
                            OpportunityLineItem oppLineItem = new OpportunityLineItem();
                            opplineItem.Id = objOppline[0].Id;
                            opplineItem.HSI_Policy_Number__c = policyNumber;
                            opplineItem.Insurance_cost__c = insuranceCost;
                            opplineItem.Sales_Price__c = insuranceSalesPrice;
                            opplineItem.Insurance_provider__c = insuranceProvider;
                            opplineItem.Insured_amount__c = insuredAmount;
                            opplineItem.Purchased_Date__c = purchaseDate;
                            update opplineItem; 
                            
                        }
                        return objWrapperDetails;
                    }
                }
                else{
                    objWrapperDetails.errorMessage = 'Please complete your payment before moving on to the next step.';
                    objWrapperDetails.message = 'NoPayment';
                    return objWrapperDetails;   
                }
            }
        }catch( System.Exception ex) {
            System.debug('hitPurchaseAPI >>objWrapperDetails>>: '+objWrapperDetails + '>>>> ERROR Exception>>:'+ex);
            Error_Handler__c err = new Error_Handler__c();
            err.Name = 'Apex Class : TravelInsuranceController';
            err.Error_Message__c = 'Message:' + ex.getMessage()  + ' - Exception occurrred on LineNumber: ' + ex.getLineNumber();
            insert err;
            objWrapperDetails.errorMessage = 'There was a communication issue with the Travel Insurance API. Please try again or contact support for assistance.';
            
            return objWrapperDetails;
        }
        //return objWrapperDetails;
    }
    public class QuoteAPiDetailDTO
    {
        public decimal total_price { get; set; }
        public List<QuoteAPICustomerDTO> customers { get; set; }
        public List<QuoteAPIProductDTO> product_details { get; set; }
    }
    public class QuoteAPICustomerDTO
    {
        public String first_name { get; set; }
        public string last_name { get; set; }
        public string street { get; set; }
        public string city { get; set; }
        public string state_or_province { get; set; }
        public string country { get; set; }
        public string email { get; set; }
        public boolean primary_insured { get; set; }
    }
    public class QuoteAPIProductDTO
    {
        public datetime start_date { get; set; }
        public datetime end_date { get; set; }
        public string country_destination { get; set; }
    }
    //Purchase API
    public class PurchaseAPiDetailDTO
    {
        @AuraEnabled
        public String quote_id { get; set; }
        @AuraEnabled
        public String itinerary_number { get; set; }
        @AuraEnabled
        public Integer sourceApp_id { get; set; }
        @AuraEnabled
        public Integer request_id { get; set; } 
    }
    public class WrapperClassDetails
    {
        @AuraEnabled
        public String quote_id { get; set; }
        @AuraEnabled
        public decimal net_price { get; set; }
        @AuraEnabled
        public String productId { get; set; }
        @AuraEnabled
        public String errorMessage { get; set;}
        @AuraEnabled
        public Boolean paymentFlag { get; set; }
        @AuraEnabled
        public DateTime startDate { get; set; }
        @AuraEnabled
        public DateTime endDate { get; set;}
        @AuraEnabled
        public String destination { get; set; }
        @AuraEnabled
        public String message { get; set; }
    }
    
    @AuraEnabled
    public static Boolean deleteTravelInsuranceProduct(String productId) { 
        try {
            
            System.debug('deleteTravelInsuranceProduct >>>>>>>>>> Attempting to delete Product ID: '+ productId);
            
            List<Payment__c> existingPayments = [
                SELECT Id 
                FROM Payment__c 
                WHERE Product_Id__c = :productId 
                LIMIT 1
            ];
            
            if (!existingPayments.isEmpty()) {
                System.debug('deleteTravelInsuranceProduct >>>>>>>>>>> Payment found for Product ID: ' + productId + 'Skipping deletion.');
                return true;
            }
            
            List<OpportunityLineItem> itemsToDelete = [
                SELECT Id FROM OpportunityLineItem 
                WHERE Product_Id__c = :productId
            ];
            
            if (!itemsToDelete.isEmpty()) {
                delete itemsToDelete;
                System.debug('deleteTravelInsuranceProduct >>>>>>>>>>>> Product successfully deleted: ' + productId);
            }else {
                System.debug('deleteTravelInsuranceProduct >>>>>>>>>>>> No Product found for Product ID:: ' + productId);
            }
            
            return false;
            
        } catch (Exception ex) {
            System.debug('deleteTravelInsuranceProduct >>>>>>> Error deleting OpportunityLineItem: ' + ex.getMessage());
            throw new AuraHandledException('Error deleting Travel Insurance product.');
        }
    }
    
}