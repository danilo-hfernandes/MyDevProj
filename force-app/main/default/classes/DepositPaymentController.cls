public with sharing class DepositPaymentController {
    @AuraEnabled
    public static Map<String, Object> getPaymentDetails(Id recordId) {
        Map<String, Object> result = new Map<String, Object>();

        // Get the running user's name
        result.put('userName', UserInfo.getName());

        // Get today's date
        result.put('today', Date.today());

        // Query the necessary fields from Deposit_Payment_Tracking__c and related objects
        Deposit_Payment_Tracking__c payment = [
            SELECT Id, Cost__c, Due_Date__c, Name, Payment_Type__c, Check_Confirmation_Number__c,
                   Deposit__c, Payment_Status__c
            FROM Deposit_Payment_Tracking__c 
            WHERE Id = :recordId
            LIMIT 1
        ];

        result.put('cost', payment.Cost__c);
        result.put('dueDate', payment.Due_Date__c);
        result.put('paymentId', payment.Name);
        result.put('paymentType', payment.Payment_Type__c);
        result.put('checkNumber', payment.Check_Confirmation_Number__c);
        result.put('depositId',payment.Deposit__c);
         result.put('paymentStatus',payment.Payment_Status__c);

        // Case and Deposit info        
        result.put('depositName', payment.Deposit__c);

        return result;
    }

    @AuraEnabled
    public static void savePaymentRecord(Deposit_Payment_Tracking__c payment, String recId) {
        System.debug('payment to update = '+payment);
        Deposit_Payment_Tracking__c p = new Deposit_Payment_Tracking__c();
        p.Id = recId;
        p.Amount_Paid_Out__c = payment.Amount_Paid_Out__c;
        p.Payment_Status__c = payment.Payment_Status__c;
        p.Paid_By__c = payment.Paid_By__c;
        p.Paid_On__c = payment.Paid_On__c;
        p.Check_Confirmation_Number__c = payment.Check_Confirmation_Number__c;        
        try {
            payment.Id = recId;
            update p;
        } catch (Exception e) {
            throw new AuraHandledException('Error saving record: ' + e.getMessage());
        }
    }
}