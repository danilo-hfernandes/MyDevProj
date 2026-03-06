public class ApplyCreditsController {
    
    @AuraEnabled
    public static Map<String,Map<String,Decimal>> tryToGetCreditsData(String recordId){
        Map<String,Map<String,Decimal>> stateAndLog = new Map<String,Map<String,Decimal>>();
        Map<String,Decimal> creditsData = new Map<String,Decimal>();
        String returnSuccess = 'true';
        List<Opportunity> oppList = [SELECT Id,Account.Member_Number__c,Account.Membership_Annual_Due__c,IsWon,Total_Amount__c, (SELECT Id,Balance_to_Pay__c,Quantity FROM OpportunityLineItems WHERE (Product2.Name = 'Annual Dues-Renewal' OR Product2.Name = 'Annual Dues Voucher Bundle')),(SELECT Id,Credit_Used__c,Notes__c,Opportunity_Product__c FROM Payments__r WHERE Opportunity_Product__r.Product2.Name = 'Annual Dues-Renewal') FROM Opportunity WHERE Account.Member_Number__c != NULL AND Total_Amount__c > 0 AND Id =: recordId];
		List<OpportunityLineItem> existingOppProducts = new List<OpportunityLineItem>();
        /*List<Payment__c> existingPayments = new List<Payment__c>();
        if(oppList[0].OpportunityLineItems != null && oppList[0].OpportunityLineItems.size()>0)
        {
            existingOppProducts = oppList[0].OpportunityLineItems;
        }
        if(oppList[0].Payments__r != null && oppList[0].Payments__r.size()>0)
        {
            existingPayments = oppList[0].Payments__r;
        }*/
        
        if(oppList != null && oppList.size()>0){
            if(!oppList[0].isWon){
                String gToken = '';
                
                Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
                String endpoint = '';
                if(runningInASandbox){
                    endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/GetAdvantageCredits/GetMemberCredits/'+oppList[0].Account.Member_Number__c;
                    //endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/GetAdvantageCredits/GetMemberCredits/'+'AP-SMTNPM-8133';
                }
                else{
                    endpoint = 'https://api.advantageprogram.com/api/GetAdvantageCredits/GetMemberCredits/'+oppList[0].Account.Member_Number__c;
                    //gToken = DataSyncToSQL.GetToken();
                    //system.debug('--gToken--'+gToken);
                }
                //String requestBody = JSON.serialize('"MemberNumber":"'+oppList[0].Account.Member_Number__c+'"');
                
                //system.debug('---requestBody---'+requestBody);
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
                        creditsData.put('errorMessage = '+creditsData,0);
                        returnSuccess = 'false';
                    }
                    else
                    {                    
                        response = JSON.serializePretty(JSON.deserializeUntyped(httpResponse.getBody()));
                        Map<String,Object> receivedCredits = (Map<String,Object>)JSON.deserializeUntyped(response);
                        system.debug('--receivedCreditsData-'+receivedCredits);
                        creditsData.put('Credits_Balance_c',(Decimal.valueOf(String.valueOf(receivedCredits.get('Redeemable')))).setScale(2,RoundingMode.DOWN));                    
                    }
                } catch( System.Exception e){
                    System.debug('ERROR: '+ e);
                    creditsData.put('errorMessage = '+e,0);
                    returnSuccess = 'false';
                }
                
                //add Credits_Balance_c check            
                //creditsData.put('Membership_Annual_Due_c',oppList[0].Account.Membership_Annual_Due__c);
                creditsData.put('Opportunity_Total_Amount_c',oppList[0].Total_Amount__c);
                creditsData.put('Number_Of_Years_To_Pay_c',oppList[0].OpportunityLineItems[0].Quantity);
                
                stateAndLog.put(returnSuccess,creditsData);
            }
            else
            {
                creditsData.put('errorMessage = Opportunity already Closed - It is not possible to add new products and payments.',0);
                returnSuccess = 'false';
                stateAndLog.put(returnSuccess,creditsData);
            }
        }
        else
        {
            creditsData.put('errorMessage = Invalid Opportunity Total Amount and/or Account Member Number',0);
            returnSuccess = 'false';
            stateAndLog.put(returnSuccess,creditsData);
        }
        return stateAndLog;
        
    }
    
    @AuraEnabled 
    public static Map<String,String> tryToUseCredits(oliCreditsData creditsData,String recordId){
        String returnSuccess = 'true';
        String returnResults = '';
        Map<String,String> stateAndLog = new Map<String,String>();
        
        List<Opportunity> oppList = [SELECT Id,Account.Member_Number__c,Account.Membership_Annual_Due__c,IsWon,StageName,Total_Amount__c, (SELECT Id,Balance_to_Pay__c FROM OpportunityLineItems WHERE (Product2.Name = 'Annual Dues-Renewal' OR Product2.Name = 'Annual Dues Voucher Bundle') AND TotalPrice > 0),(SELECT Id,Credit_Used__c,Notes__c,Opportunity_Product__c FROM Payments__r WHERE Opportunity_Product__r.Product2.Name = 'Annual Dues-Renewal' OR Opportunity_Product__r.Product2.Name = 'Annual Dues Voucher Bundle') FROM Opportunity WHERE Account.Member_Number__c != NULL AND Total_Amount__c > 0 AND Id =: recordId];
        List<OpportunityLineItem> existingOppProducts = new List<OpportunityLineItem>();
        List<Payment__c> existingPayments = new List<Payment__c>();
        if(oppList[0].OpportunityLineItems != null && oppList[0].OpportunityLineItems.size()>0)
        {
            existingOppProducts = oppList[0].OpportunityLineItems;
        }
        if(oppList[0].Payments__r != null && oppList[0].Payments__r.size()>0)
        {
            existingPayments = oppList[0].Payments__r;
        }
        
        try{
            System.debug('creditsData.Credits_Balance_c = '+creditsData.Credits_Balance_c);
            System.debug('creditsData.Membership_Annual_Due_c = '+creditsData.Membership_Annual_Due_c);
            System.debug('creditsData.Number_Of_Years_To_Pay_c = '+creditsData.Number_Of_Years_To_Pay_c);
            System.debug('creditsData.Total_Due_c = '+creditsData.Total_Due_c);
            System.debug('creditsData.Apply_Credits_c = '+creditsData.Apply_Credits_c);
            System.debug('creditsData.Balance_To_Pay_c = '+creditsData.Balance_To_Pay_c);
            
            Id existingOliId = null;
            Id existingPaymentId = null;
            
            if(existingOppProducts != null && existingOppProducts.size()>0)
            {
                if(existingPayments.size() == 1 && existingOppProducts.size() == 1)
                {
                    if(existingPayments[0].Opportunity_Product__c == existingOppProducts[0].Id && 
                       existingOppProducts[0].Balance_to_Pay__c > 0 
                       && existingPayments[0].Notes__c == 'Annual Dues Payment With Advantage Credits created by salesforce - partially paid by credits')                    
                    {
                        existingOliId = existingOppProducts[0].Id;
                        existingPaymentId = existingPayments[0].Id;
                    }
                }
                if(existingPayments.size() == 0 && existingOppProducts.size() == 1)
                {
                    existingOliId = existingOppProducts[0].Id;
                }                
            }

            OpportunityLineItem oli = new OpportunityLineItem();
            //oli.Quantity = creditsData.Number_Of_Years_To_Pay_c;
            oli.Number_of_Years_To_Pay__c = creditsData.Number_Of_Years_To_Pay_c;            
            //oli.UnitPrice = creditsData.Membership_Annual_Due_c;
            //oli.Retail_Price__c = oli.UnitPrice;
            //oli.Membership_Annual_Due__c = creditsData.Membership_Annual_Due_c;
            oli.Credits_Balance__c = creditsData.Credits_Balance_c;
            oli.Total_Due__c = creditsData.Total_Due_c;
            oli.Apply_Credits__c = creditsData.Apply_Credits_c;
            oli.Balance_to_Pay__c = creditsData.Balance_To_Pay_c;
            //oli.OpportunityId = recordId;
            //oli.PriceBookEntryID = [SELECT Id, Name, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2.Name = 'Annual Dues-Renewal' LIMIT 1].Id;
            if(existingOliId == null){
                oli.Quantity = creditsData.Number_Of_Years_To_Pay_c;
                oli.UnitPrice = creditsData.Membership_Annual_Due_c;
                oli.Retail_Price__c = oli.UnitPrice;
                //oli.Membership_Annual_Due__c = creditsData.Membership_Annual_Due_c;
                oli.OpportunityId = recordId;
                oli.PriceBookEntryID = [SELECT Id, Name, Product2Id, Product2.Id, Product2.Name FROM PriceBookEntry WHERE Product2.Name = 'Annual Dues-Renewal' LIMIT 1].Id;
                insert oli;
            }
            else
            {
                oli.Id = existingOliId;
                update oli;
            }
            
            oli = [SELECT Id, Product_ID__c, Product2.Id, OpportunityId, Opportunity.AccountId,Opportunity.Account.First_Name__c,Opportunity.Account.Last_Name__c,Opportunity.Total_Amount__c FROM OpportunityLineItem WHERE Id =: oli.Id LIMIT 1];
            
            Payment__c objpayment = new Payment__c();
            
            if(creditsData.Balance_To_Pay_c == 0)
            {                
                if(oli.Opportunity.Account.First_Name__c != null && oli.Opportunity.Account.Last_Name__c != null)
                {
                    objpayment.Name = oli.Opportunity.Account.First_Name__c + ' ' + oli.Opportunity.Account.Last_Name__c + '' +system.today().year()+'-'+system.today().month()+'-'+system.today().day();
                }                
                objpayment.Paid_On__c = system.today();
                objpayment.Opportunity__c = oli.OpportunityId;
                objpayment.Payment_Type__c = 'Redeemed Credits';
                objpayment.Payment_Method__c = 'Credits';
                objpayment.Notes__c = 'Annual Dues Payment With Advantage Credits created by salesforce - full paid by credits';
                objpayment.Payment_Amount__c = creditsData.Apply_Credits_c;
                objpayment.Credit_Used__c = creditsData.Apply_Credits_c; // >> to be used in the certificate redemption checkout page - corev2 will identify this to subtract the credits applied if there's a balance to pay
                objpayment.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Membership').getRecordTypeId();
                objpayment.Transaction_Type__c = 'Membership Annual Dues';
                objpayment.Account__c = oli.Opportunity.AccountId;
                objpayment.Product_Id__c = oli.Product_ID__c;
                objpayment.Product_Salesforce_Id__c = oli.Product2.Id;
                objpayment.Opportunity_Product__c = oli.Id;
                //insert objpayment;
            }
            else
            {                
                if(oli.Opportunity.Account.First_Name__c != null && oli.Opportunity.Account.Last_Name__c != null)
                {
                    objpayment.Name = oli.Opportunity.Account.First_Name__c + ' ' + oli.Opportunity.Account.Last_Name__c + '' +system.today().year()+'-'+system.today().month()+'-'+system.today().day();
                }                
                objpayment.Paid_On__c = system.today();
                objpayment.Opportunity__c = oli.OpportunityId;                
                objpayment.Payment_Type__c = 'Redeemed Credits';
                objpayment.Payment_Method__c = 'Credits';
                objpayment.Notes__c = 'Annual Dues Payment With Advantage Credits created by salesforce - partially paid by credits';
                objpayment.Payment_Amount__c = creditsData.Apply_Credits_c;
                //objpayment.Credit_Used__c = creditsData.Apply_Credits_c; // >> to be used by the certificate redemption checkout page - corev2 will identify this to subtract the credits applied if there's a balance to pay
                objpayment.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Membership').getRecordTypeId();
                objpayment.Transaction_Type__c = 'Membership Annual Dues';
                objpayment.Account__c = oli.Opportunity.AccountId;
                objpayment.Product_Id__c = oli.Product_ID__c;
                objpayment.Product_Salesforce_Id__c = oli.Product2.Id;
                objpayment.Opportunity_Product__c = oli.Id;
                //insert objpayment;
            }
            if(existingPaymentId == null){
                insert objpayment;
            }
            else
            {
                objpayment.Id = existingPaymentId;
                update objpayment;
            }
            if(creditsData.Balance_To_Pay_c == 0){
                System.debug('creditsData.Balance_To_Pay_c == 0 enter');
                System.debug('oli.Opportunity.Total_Amount__c == '+oli.Opportunity.Total_Amount__c);
                System.debug('objpayment.Payment_Amount__c == '+objpayment.Payment_Amount__c);
                System.debug('oppList[0].isWon == '+oppList[0].isWon);
                if(oli.Opportunity.Total_Amount__c == objpayment.Payment_Amount__c && oppList[0].isWon == false)
                {
                    for(Opportunity opp : oppList){
                        System.debug('update oppList[0] == enter');
                        System.debug('opp == '+opp);
                        opp.StageName = 'Closed Won';                        
                    }
                    update oppList;
                }
            }
            
        }
        Catch(Exception e)
        {
            returnSuccess = 'false';
            returnResults = e.getMessage();
        }
        stateAndLog.put(returnSuccess,returnResults);
        return stateAndLog;        
    }
    
    public class oliCreditsData{
        @AuraEnabled
        public decimal Credits_Balance_c{get;set;}
        @AuraEnabled
        public decimal Membership_Annual_Due_c{get;set;}
        @AuraEnabled
        public decimal Number_Of_Years_To_Pay_c{get;set;}
        @AuraEnabled
        public decimal Total_Due_c{get;set;}
        @AuraEnabled
        public decimal Apply_Credits_c{get;set;}
        @AuraEnabled
        public decimal Balance_To_Pay_c{get;set;}
    }
    
}