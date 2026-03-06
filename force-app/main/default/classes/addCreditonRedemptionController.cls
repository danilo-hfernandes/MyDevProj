/*
*********************************************************
Apex Controller    : addCreditonRedemptionController
Created Date       : August 23, 2024
@description       : This is class is controller of AddCreditonRedemption LWC Component
Test class          : addCreditonRedemptionControllerTest
Modification Log:
Ver   Date         Author                               Modification
1.0   23-08-2024    sifra                                  Initial Version
*********************************************************
*/
public class addCreditonRedemptionController {
    
    // method for Making API call
    @AuraEnabled(cacheable=false)
    public static void makeApiCallout(ID recordId) {
        
        System.debug('Received Param: ' + recordId);
        
        // Query the record data using the ID
        Redemption__c redemption = [
            select Id ,Opportunity__r.Member_Number__c,CreatedBy.name,LastModifiedBy.Name ,Redemption_Amount__c,Opportunity__c,Status__c,Redemption_Type__c from Redemption__c 
            WHERE Id = :recordId 
            LIMIT 1
        ];
        if (redemption.Redemption_Type__c !='Credits' ){
            throw new AuraHandledException('Redemption Type should be Credits.');
        }
        
        // Construct the TransactionDescription
        String transactionDescription = 'Received Redemption, Credits: ' + redemption.Redemption_Amount__c + ' RedeemptionId: ' + redemption.ID;
        
        system.debug('QueryData'+redemption);
        // String url = 'https://webapihsicorev2-qa.azurewebsites.net/api/GetAdvantageCredits/EarnCreditsContacts';
        
        // Retrieve the DeveloperName from the custom label
        String devName = Label.Add_Credit_Prod_Developer_Name;
        
        // Query the custom metadata type using the DeveloperName from the custom label
        Add_Credit_Redemption_URL__mdt urlSetting = [
            SELECT API_Endpoint_URL__c 
            FROM Add_Credit_Redemption_URL__mdt 
            WHERE DeveloperName = :devName 
            LIMIT 1
        ];
        String url = urlSetting.API_Endpoint_URL__c;
        System.debug('Endpoint URL from metadata: ' + url);
        
        String requestBody = JSON.serialize(new Map<String, Object>{
            'MemberNumber' => redemption.Opportunity__r.Member_Number__c,
                'CreditEarned' => redemption.Redemption_Amount__c,
                'TransactionDescription' => transactionDescription,
                'CreateBy' => redemption.CreatedBy.name,
                'SFOpportunityId' => redemption.Opportunity__c,
                'SFPaymentId' => '',
                'ModifiedBy' =>  redemption.LastModifiedBy.Name,
                'TransactionTypeId' => 2
                });
        System.debug('Request Body: ' + requestBody);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(url);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(requestBody);
        System.debug('line 28');
        String responseBody;
        String updateStatus;
        
        try {
            HttpResponse response = http.send(request);
            System.debug('Response Status: ' + response.getStatusCode());
            
            if (response.getStatusCode() == 200 ||response.getStatusCode() == 201 ) {
                responseBody = response.getBody();
                updateStatus = 'Success';
                //Update Field on Redemption Obejct
                if (recordId != null) {
                    try {
                        Redemption__c redemptionRecord = new Redemption__c(
                            Id = recordId,
                            Add_Credit_Status__c = updateStatus + ': ' + responseBody,
                            Status__c='Redemption Confirmed',
                            Add_Credit_Status_Check_Button__c=True
                        );
                        update redemptionRecord;
                        System.debug('Record Updated Successfully');
                    } catch (DmlException dmlEx) {
                        System.debug('DML Error: ' + dmlEx.getMessage());
                    }
                    
                } else {
                    responseBody = 'API callout failed with status code ' + response.getStatusCode();
                    updateStatus = 'Error';
                }
                System.debug('Response Body: ' + responseBody);
                
            }
        }catch (Exception e) {
            responseBody = 'API callout failed: ' + e.getMessage();
            updateStatus = 'Error';
            System.debug('Error: ' + e.getMessage());
        }
        
        
    }
}