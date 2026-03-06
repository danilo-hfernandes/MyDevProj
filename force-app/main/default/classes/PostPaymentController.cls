public with sharing class PostPaymentController {
    @AuraEnabled
    public static String getProductId(Id opportunityId) {
        List<OpportunityLineItem> items = [
            SELECT Product_Id__c,Product2Id, Product2.Name, Product2.ProductCode
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId AND Product2.Name LIKE '%Club Venture%'
            ORDER BY Retail_Price__c DESC
            LIMIT 1
        ];
        return (items.size() > 0) ? items[0].Product_Id__c : null;
    }

    @AuraEnabled
    public static Id getRecordTypeId() {
        return [
            SELECT Id FROM RecordType 
            WHERE DeveloperName = 'Membership_Upgrade' 
            AND SObjectType = 'Payment__c' 
            LIMIT 1
        ].Id;
    }

    @AuraEnabled
    public static Payment__c savePayment(Payment__c payment) {
        insert payment;
        if(payment.Id != null)
        {
            if(payment.Opportunity__c != null)
            {
                membershipUpgradeAPICallout(String.valueOf(payment.Id));
            }
        }
        return payment;
    }
    
    @AuraEnabled @future(callout=true)
    public static void membershipUpgradeAPICallout(String payId){
        
        Payment__c objPayment = [select id, Opportunity__c,Paid_On__c,Product_Id__c,Opportunity__r.Account_Affiliate_Id__c, Opportunity__r.Credit_Received__c,Opportunity__r.Dues_Last_Paid_Until__c,Opportunity__r.Enrollment_Fee__c,Opportunity__r.Account.Affiliated_Id__c,Opportunity__r.Account.Contact_Id__c,Opportunity__r.Account.Member_Number__c, opportunity__r.Member_Number__c, Payment_Date__c,Opportunity_Product__r.Product2.Name from Payment__c where Id =: payId LIMIT 1];
        Map<String, String> affiliateMap = new Map<String, String>();
        
        for (Affiliate_Id__c a : [SELECT Affiliate_Name__c, Affiliate_Id__c FROM Affiliate_Id__c])
        {
            affiliateMap.put(a.Affiliate_Name__c != null ? a.Affiliate_Name__c.replaceAll('[^a-zA-Z0-9]', '') : '', a.Affiliate_Id__c);
        }

        System.debug('affiliateMap populated == '+affiliateMap);
        //String gToken = DataSyncToSQL.GetToken();
        //system.debug('--gToken--'+gToken);
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String endpoint = '';
        if(runningInASandbox){            
            endpoint = 'https://webapihsicorev2-qa.azurewebsites.net/api/membership-upgrade-simple';
        }
        else{            
            endpoint = 'https://webapihsicorev2.azurewebsites.net/api/membership-upgrade-simple';
        }
        MembersAPIWrp annualDuePaymentObj = new MembersAPIWrp();
        
        annualDuePaymentObj.ContactId = Integer.valueOf(objPayment.Opportunity__r.Account.Contact_Id__c);        
        annualDuePaymentObj.AffiliateId =  Integer.valueOf(affiliateMap.get(objPayment.Opportunity_Product__r.Product2.Name.replaceAll('[^a-zA-Z0-9]', '')));
        
        String requestBody =JSON.serialize(annualDuePaymentObj);
        system.debug('---requestBody---'+requestBody);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setBody(requestBody);
        request.setHeader('content-type', 'application/json'); 
        
        /*if(!runningInASandbox){            
             request.setHeader('Authorization', 'Bearer '+gToken);
        }*/
        
        system.debug('--request--'+request);
        String response = '';
        try {  
            HttpResponse httpResponse = http.send(request);
            system.debug('--httpResponse--'+httpResponse);
            if(httpResponse.getStatusCode() != 200 && httpResponse.getStatus() != 'OK'){
                response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                System.debug('[Error] response from Club Venture Membership Upgrade API = '+response);
                Map<String,Object> receivedData = (Map<String,Object>)JSON.deserializeUntyped(response);
                String message = String.valueOf(receivedData.get('message'));
                system.debug('--message-'+message);
                Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
                String[] sendingTo = new String[]{'victor.goncalves@nerdsoft.com','danilo.fernandes@nerdsoft.com'};
                semail.setToAddresses(sendingTo); 
                semail.setSubject('Club Venture Membership Upgrade API is failed'); 
                semail.setPlainTextBody('Message : '+message+ 'Request : '+requestBody);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail}); 
            }else{
                response = JSON.serializePretty( JSON.deserializeUntyped(httpResponse.getBody()) );
                System.debug('[200] response from Club Venture Membership Upgrade API = '+response);
            }
        } catch( System.Exception e) {
            System.debug('ERROR: '+ e);
        }
        
    }
    
    public class MembersAPIWrp
    {
        public integer ContactId {get;set;}
        public integer AffiliateId {get;set;}
    }
    
}