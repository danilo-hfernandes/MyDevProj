public class ResortWeekPremiumCashBackReturn {

  	@InvocableMethod 
   //    @future(callout = true) 
		public static List<ReturnValueClass> sendResortWeekRefundAPI(List<RequestWrapper> requests) {
            

        List<ReturnValueClass> results = new List<ReturnValueClass>();
        ReturnValueClass result = new ReturnValueClass();

        if (requests.isEmpty() || String.isBlank(requests[0].TransactionTypeId)) {
            result.returnValue = 'No input received from the Flow.';
            results.add(result);
            return results;
        }

        // Extract the Opportunity ID and variable from the Flow
        List<String> oppIds = new List<String>();
        String TransactionTypeId = requests[0].TransactionTypeId;
 
        for (RequestWrapper request : requests) {
            oppIds.add(request.OppId);
        }  
 
        // Query opportunities based on the provided IDs
        List <OpportunityLineItem> OppLI = [select  Id, Travel_Apply_Credits__c, Opportunity.Account.Member_Number__c, Opportunity.Account.Name, createddate , 
                                            Opportunity.account.Contact_Id__c , Opportunity.account.Id, Opportunity.Id, Payment__r.id, 
                                            Inventory_Id__c, Opportunity.Amount, Request_Id__c , Opportunity.Total_Amount_Paid__c
                                            from OpportunityLineItem where Product2.Name = 'Resort Weeks' and Opportunity.Id IN: OppIds];
        system.debug('OppLI = '+OppLI);
        

        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String endpoint = runningInASandbox
            ? 'https://webapihsicorev2-qa.azurewebsites.net/api/SFResort/Refund'
            : 'https://webapihsicorev2.azurewebsites.net/api/SFResort/Refund';     
            
        if(OppLI.size()>0 && OppLI != null){
            String gToken = ResortWeekPremiumCashBackReturn.GetToken();
            system.debug('--gToken--'+gToken);
            
            //Contact Cont = [SELECT Id, name, Contact_Id__c FROM Contact where AccountId = :OppLI[0].Opportunity.account.Id 
            //                order by Is_Main_Contact__c LIMIT 1];
             
            String TransactionDescription = '';
            If (TransactionTypeId == '76') {
                TransactionDescription  = 'Premium Cash Back Credits issued on refund of SF OpportunityId {' + OppLI[0].Opportunity.Id + '}';
            }
            else{ //77
                TransactionDescription  = 'Transfer Funds Credits issued on refund of SF OpportunityId {' + OppLI[0].Opportunity.Id + '}';
            }
            
            // Construct the Credits object
            TransactionWrapper credits = new TransactionWrapper();
            credits.RequestId = OppLI[0].Request_Id__c;  
            credits.InventoryId = OppLI[0].Inventory_Id__c;  
            credits.TransactionTypeId = TransactionTypeId ; //'76' or '77'
            credits.ContactId = String.valueOf(OppLI[0].Opportunity.account.Contact_Id__c); //String.valueOf(Cont.Contact_Id__c); //fix 2025-01-16
            credits.MemberNumber = OppLI[0].Opportunity.Account.Member_Number__c;
            credits.ContactName =  OppLI[0].Opportunity.Account.Name; //Cont.name;  
            credits.CreditEarned = (OppLI[0].Opportunity.Total_Amount_Paid__c != null && OppLI[0].Opportunity.Total_Amount_Paid__c != 0) ? OppLI[0].Opportunity.Total_Amount_Paid__c : 0;
            credits.CreditRedeemed = '0' ;  
            credits.TransactionDescription = TransactionDescription;
            credits.CreditTransactionStatusTypeId = '2' ;  
            credits.SFOpportunityId = OppLI[0].Opportunity.Id ;  
            credits.SFPaymentId = OppLI[0].Payment__r.id ;  
            
            // Construct the CancelResort object
            CancelResortWrapper cancelResort = new CancelResortWrapper();
            cancelResort.RequestId = OppLI[0].Request_Id__c;
            cancelResort.InventoryId = OppLI[0].Inventory_Id__c;
            cancelResort.Notes = TransactionDescription; 

            // Combine Credits and CancelResort into a single request
            FullRequestWrapper requestWrapper = new FullRequestWrapper();
            requestWrapper.Credits = credits;
            requestWrapper.CancelResort = cancelResort;
            
            // Serialize the entire request
			String requestBody =JSON.serialize(requestWrapper);
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setBody(requestBody);
            request.setHeader('content-type', 'application/json');
            request.setHeader('Authorization', 'Bearer '+gToken);
            system.debug('--request--'+request);
            system.debug('--requestBody--'+requestBody);
            String response = '';
            try {  
                HttpResponse httpResponse = http.send(request);
                system.debug('--httpResponse--'+httpResponse);
                response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                system.debug('--response-'+response);
                Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                system.debug('--receivedData-'+receivedData);
                String message = String.valueOf(receivedData.get('message'));
                system.debug('--message-'+message);
                String IsValid = String.valueOf(receivedData.get('IsValid'));
                system.debug('--IsValid-'+IsValid);
                //if(httpResponse.getStatusCode() != 200 || httpResponse.getStatus() != 'OK' || IsValid != 'true'){
                if(IsValid != 'true'){
                    Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                    String[] sendingTo = new String[]{'cicero.schoeps@nerdsoft.com','shivani.chauhan@nerdsoft.com', 'danilo.fernandes@nerdsoft.com','daniel.oliveira@nerdsoft.com'};
                    semail.setToAddresses(sendingTo);
                    semail.setSubject('sendResortWeekRefundAPI is failed');
                    semail.setPlainTextBody('Message : '+message+ 'Request : '+requestBody);
                    if(!runningInASandbox){
                        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
                    }
                    result.returnValue = 'We could not complete the cancellation.'; 
                }
                else{
                    result.returnValue = 'Refund was sent successfully.'; 
                }
                // Return the result to the flow
                results.add(result);
                return results;                        
                
            } catch( System.Exception e) {
                System.debug('ERROR: '+ e);
                result.returnValue = 'ERROR: '+ e; 
                results.add(result);
                return results;                        
                
            }
  
        }
        result.returnValue = 'No Opportunity found.'; 
        results.add(result);
        return results;
    }  
    
    public class TransactionWrapper {
        // Declare the variables as per the provided parameters
        public String MemberNumber { get; set; }
        public Decimal CreditEarned { get; set; }
        public String TransactionDescription { get; set; }
        public String SFOpportunityId { get; set; }
        public String SFPaymentId { get; set; }
        public String TransactionTypeId { get; set; }
        public String CreditRedeemed { get; set; }
        public String CreditTransactionStatusTypeId { get; set; }
        public String RequestId { get; set; }
        public String InventoryId { get; set; }
 		public String ContactId { get; set; }
        public String ContactName { get; set; }
                
        // Constructor to initialize the wrapper with values
        public TransactionWrapper(){
        } 
    }

    public class FullRequestWrapper {
        public TransactionWrapper Credits;
        public CancelResortWrapper CancelResort;
    }
    
    public class CancelResortWrapper {
        public String RequestId;
        public String InventoryId;
        public String Notes;
    }
    
    
    public static string GetToken(){
        String matrixAPI = 'https://matrix.nerdsoft.com/Token';
        string userName =  'resortrefundapi@nerdsoft.com';
        string password =  '0raCBP*4yl*7';
        string clientId =  '2FihOuY0hvaIx9JkscRv23BJaO3dcSjzSD1Dcy0M:2FihOuY0hvaIx9JkscRv23BJaO3dcSjzSD1Dcy0M';
        
        string msgTokenBody = 'banana='+clientId+'&grant_type=password&username='+ userName +'&password='+ password + '&client_id=' + clientId;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(matrixAPI);
        request.setMethod('POST');
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        request.setBody(msgTokenBody);
        TokenReturn respObj = new TokenReturn();
        if(!test.isRunningTest()){
            HttpResponse response = http.send(request);
            system.debug('--msgTokenBody---'+msgTokenBody);
            system.debug('--request---'+request);
            system.debug('--response---'+response);
            respObj = (TokenReturn)JSON.deserialize(response.getBody() , TokenReturn .class);
        }else{
            respObj.access_token = 'token';
        }
//        system.debug('response.getStatusCode()'+response.getStatusCode());
        system.debug('respObj'+respObj);
        system.debug('respObj.access_token'+respObj.access_token);
        return respObj.access_token;      
    }
    public Class TokenReturn{
        private String access_token {get; set;}
    }

    public Class ReturnValueClass {
        @InvocableVariable
        public String returnValue;
    }

    // Define the RequestWrapper class for input
    public class RequestWrapper {
        @InvocableVariable(required = true)
        public String OppId;

        @InvocableVariable
        public String TransactionTypeId; //  variable to accept input from Flow
    }
    
}