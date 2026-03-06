public class RedeemCreditsController {
@AuraEnabled
public static Decimal getCreditsData(String recordId){
    System.debug('>>>recordId>>'+recordId);
    String returnSuccess = 'true';
    Decimal Credits_Balance = 0.0;
    List<Opportunity> oppList = [SELECT Id,Account.Member_Number__c,Account.Membership_Annual_Due__c,IsWon,Total_Amount__c FROM Opportunity WHERE Account.Member_Number__c != NULL AND Total_Amount__c > 0 AND Id =: recordId];
            
    if(oppList != null && oppList.size()>0){
        String gToken = '';
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String endpoint = '';
        if(runningInASandbox){
            endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/GetAdvantageCredits/GetMemberCredits/'+oppList[0].Account.Member_Number__c;
        }
        else{
            endpoint = 'https://api.advantageprogram.com/api/GetAdvantageCredits/GetMemberCredits/'+oppList[0].Account.Member_Number__c;
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        //request.setBody('');
        request.setHeader('content-type', 'application/json');
        if(gToken != ''){
            request.setHeader('Authorization', 'Bearer '+gToken);
        }
        system.debug('--request--'+request);
        String response = '';
        
        try {  
            HttpResponse httpResponse = http.send(request);
            system.debug('--httpResponse--'+httpResponse);
            if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                String message = String.valueOf(receivedData.get('message'));
                system.debug('--message-'+message);
                returnSuccess = 'false';
            }
            else
            {                    
                response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                Map<String,Object> receivedCredits = (Map<String,Object>)JSON.deserializeUntyped(response);
                system.debug('--receivedCreditsData-'+receivedCredits);
                Credits_Balance = (Decimal.valueOf(String.valueOf(receivedCredits.get('Redeemable')))).setScale(2,RoundingMode.DOWN);                    
            }
        } catch( System.Exception e){
            System.debug('ERROR: '+ e);
        }
    }
    return Credits_Balance; 
}
@AuraEnabled
public static String createPaymentRecord(String recordId,Decimal applyCredits, Decimal actualCreditBalance){
    String errorMessage = '';
    Id recordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Travel').getRecordTypeId();
    Opportunity opp = [select id,AccountId,Account.Name,Account.Email__c,Account.Credits_Balance__c,Amount,IsClosed,Total_Amount_Paid__c,Record_Type_Name__c,(select id,Product_ID__c from OpportunityLineItems) from Opportunity where Id = : recordId];
    if(opp != null && opp.Amount > 0 && opp.OpportunityLineItems.size() > 0){
        //if(!opp.IsClosed){ Removing the validation SCB-49
            //Insert Redeemed Credits Payment
            Payment__c paymentRec = new Payment__c();
            paymentRec.Name = opp.Account.Name;
            paymentRec.Paid_On__c = system.today();
            paymentRec.Payment_Type__c = 'Redeemed Credits';
            paymentRec.Opportunity__c = recordId;
            paymentRec.Account__c = opp.AccountId;
            paymentRec.Payment_Amount__c = applyCredits;
            paymentRec.RecordTypeId = recordTypeId;
            paymentRec.Transaction_Type__c = opp.Record_Type_Name__c;
            paymentRec.Product_Id__c = opp.OpportunityLineItems[0].Product_ID__c;
            paymentRec.Opportunity_Product__c = opp.OpportunityLineItems[0].Id;
            paymentRec.Opportunity_Account_Email__c = opp.Account.Email__c;
			paymentRec.Payment_Method__c = 'CreditOnly';
            insert paymentRec;

            //Update Credit Balance 
            Decimal creditBalance = actualCreditBalance - applyCredits;
            Account objacc = new Account();
            objacc.Id =opp.AccountId;
            objacc.Credits_Balance__c = creditBalance ;
            update objacc;

            System.debug('>>>>'+opp.Amount);
            System.debug('>>>>'+opp.Total_Amount_Paid__c);
            if(opp.Amount == applyCredits || opp.Amount == (opp.Total_Amount_Paid__c+applyCredits)){
                Opportunity Objopp = new Opportunity();
                Objopp.Id = opp.Id;
                if(opp.Record_Type_Name__c == 'Travel')
                    Objopp.StageName = 'Closed Won';
                else {
                    Objopp.StageName = 'Booked Deposit';
                }
                update Objopp;
            }
            RedeemCreditsController.updateCreditBalanceToBE(paymentRec.Id,applyCredits);

            return 'Success';
        /*}
        else {
            errorMessage = 'You cannot post a payment to a closed opportunity. Please contact your administrator.';
            return errorMessage;
        }*/
    }
    else{
        errorMessage = 'Invalid Opportunity Total Amount and/or There are no Product Lines associated with the Opportunity.';
        return errorMessage; 
    }
}

@Future(callout=true)
public static void updateCreditBalanceToBE(String paymentId, Decimal CreditsToRedeem){
    List<Payment__c> listPayment = [select id,CreatedBy.Name, Product_Name__c,Opportunity__c,Paid_On__c, Opportunity__r.Account.Contact_Id__c,Opportunity__r.Account.Member_Number__c, opportunity__r.Member_Number__c,opportunity__r.OwnerId, Payment_Amount__c, Payment_Date__c, Credit_Card_Number__c, Credit_Used__c, Authorization_Code__c, AuthorizeNet_Transaction_Id__c,Payment_Type__c,Payment_Method__c,Notes__c from Payment__c where Id =: paymentId];
    String gToken = DataSyncToSQL.GetToken();
    system.debug('--gToken--'+gToken);
    Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    String endpoint = '';
    if(runningInASandbox){
        endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/GetAdvantageCredits/RedeemCreditsContacts';
    }
    else{
        endpoint = 'https://webapihsicorev2.azurewebsites.net/api/GetAdvantageCredits/RedeemCreditsContacts';
    }
        for(Payment__c objPayment : listPayment){
            RedeemCredits redeemCreditsObj = new RedeemCredits();
            redeemCreditsObj.MemberNumber = objPayment.opportunity__r.Member_Number__c != null ? objPayment.opportunity__r.Member_Number__c : objPayment.Opportunity__r.Account.Member_Number__c;
            redeemCreditsObj.CreditsToRedeem = CreditsToRedeem;
            redeemCreditsObj.TransactionDescription = 'Opportunity Id :'+objPayment.opportunity__c+' Redeemed Credits';
            redeemCreditsObj.TransactionTypeId = (objPayment.Product_Name__c != null && (objPayment.Product_Name__c == 'Cruise' || objPayment.Product_Name__c == 'SF Cruise Booking')) ? 12 :  ((objPayment.Product_Name__c != null && objPayment.Product_Name__c == 'Hotel')? 13 : ((objPayment.Product_Name__c != null && objPayment.Product_Name__c == 'Resort Weeks')? 1: null)) ;
            redeemCreditsObj.OpportunityId = objPayment.opportunity__c;
            redeemCreditsObj.PaymentId= objPayment.Id;
            redeemCreditsObj.CreateBy = objPayment.CreatedBy.Name; 
            redeemCreditsObj.ModifiedBy =  objPayment.CreatedBy.Name;
        String requestBody =JSON.serialize(redeemCreditsObj);
        system.debug('--- RedeemCreditsContacts requestBody---'+requestBody);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setBody(requestBody);
        request.setHeader('content-type', 'application/json'); 
        request.setHeader('Authorization', 'Bearer '+gToken);
        system.debug('--RedeemCreditsContacts request--'+request);
        String response = '';
        try {  
            HttpResponse httpResponse = http.send(request);
            system.debug('--httpResponse--'+httpResponse);
            if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                String message = String.valueOf(receivedData.get('message'));
                system.debug('--RedeemCreditsContacts message-'+message);
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                String[] sendingTo = new String[]{'shivani.chauhan@nersoft.com', 'danilo.fernandes@nersoft.com', 'daniel.oliveira@nersoft.com'};
                semail.setToAddresses(sendingTo); 
                semail.setSubject('RedeemCreditsContacts API is failed'); 
                semail.setPlainTextBody('Message : '+message+ 'Request : '+requestBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
            }
        } catch( System.Exception e) {
            System.debug('ERROR: '+ e);
        }
    }
}
public class RedeemCredits
{
    public String MemberNumber {get;set;}
    public decimal CreditsToRedeem {get;set;}
    public String TransactionDescription{get;set;}
    public decimal TransactionId {get;set;}
    public Integer TransactionTypeId {get;set;}
    public String OpportunityId {get;set;}
    public String PaymentId {get;set;}
    public String CreateBy {get;set;}
    public String ModifiedBy {get;set;}
}

}