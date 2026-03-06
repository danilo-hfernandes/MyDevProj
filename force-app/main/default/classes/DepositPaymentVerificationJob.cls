public class DepositPaymentVerificationJob implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        String emailBody = '';
        List<Deposit_Payment_Tracking__c> paymentsToInsert = new List<Deposit_Payment_Tracking__c>();
        
        try {
            // Find deposits that should have payments but have none
            List<Deposits__c> depositsMissingPayments = [
                SELECT Id, Case__c, Client_Deposit_Payment_Schedule_Profile__c, Payment_Type__c, Inventory_Cost__c, Check_in_Date__c
                FROM Deposits__c
                WHERE Client_Deposit_Payment_Schedule_Profile__c != null 
                AND Status__c = 'Approved'
                AND Id NOT IN (SELECT Deposit__c FROM Deposit_Payment_Tracking__c WHERE Deposit__c != null)
            ];
            
            if (depositsMissingPayments.isEmpty()) {
                emailBody = 'No missing Deposit Payment Tracking records were found.';
            } else {
                emailBody = 'The system detected and recreated missing Deposit Payment Tracking records for the following deposits:\n\n';
                
                for (Deposits__c deposit : depositsMissingPayments) {
                    
                    List<Deposit_Payment_Tracking__c> dpTracking = DepositTriggerHandler.generatePaymentTrackingRecords(deposit);
                    if(dpTracking != null && dpTracking.size()>0){
                        paymentsToInsert.addAll(dpTracking);
                    }
                    
                    /*if (deposit.Client_Deposit_Payment_Schedule_Profile__c == 'Payment after Check In') {
                        paymentsToInsert.add(new Deposit_Payment_Tracking__c(
                            Case__c = deposit.Case__c,
                            Payment_Type__c = deposit.Payment_Type__c,
                            Deposit__c = deposit.Id,
                            Payment_Status__c = 'Not Paid',
                            Cost__c = deposit.Inventory_Cost__c,
                            Due_Date__c = deposit.Check_in_Date__c
                        ));
                    } else if (deposit.Client_Deposit_Payment_Schedule_Profile__c == '25%Down Payment + Balance at 270 Days') {
                        Decimal twentyFivePercent = (deposit.Inventory_Cost__c * 0.25).setScale(2);
                        Decimal seventyFivePercent = (deposit.Inventory_Cost__c * 0.75).setScale(2);
                        
                        paymentsToInsert.add(new Deposit_Payment_Tracking__c(
                            Case__c = deposit.Case__c,
                            Payment_Type__c = deposit.Payment_Type__c,
                            Deposit__c = deposit.Id,
                            Payment_Status__c = 'Not Paid',
                            Cost__c = twentyFivePercent,
                            Due_Date__c = System.today()
                        ));
                        paymentsToInsert.add(new Deposit_Payment_Tracking__c(
                            Case__c = deposit.Case__c,
                            Payment_Type__c = deposit.Payment_Type__c,
                            Deposit__c = deposit.Id,
                            Payment_Status__c = 'Not Paid',
                            Cost__c = seventyFivePercent,
                            Due_Date__c = System.today().addDays(270)
                        ));
                    } else if (deposit.Client_Deposit_Payment_Schedule_Profile__c == 'Full Payment at Deposit') {
                        paymentsToInsert.add(new Deposit_Payment_Tracking__c(
                            Case__c = deposit.Case__c,
                            Payment_Type__c = deposit.Payment_Type__c,
                            Deposit__c = deposit.Id,
                            Payment_Status__c = 'Not Paid',
                            Cost__c = deposit.Inventory_Cost__c,
                            Due_Date__c = System.today()
                        ));
                    }*/
                    
                    // Append deposit info to email body
                    emailBody += 
                        'Deposit Id: ' + deposit.Id + '\n' +
                        'Case Id: ' + deposit.Case__c + '\n' +
                        'Payment Profile: ' + deposit.Client_Deposit_Payment_Schedule_Profile__c + '\n' +
                        'Payment Type: ' + deposit.Payment_Type__c + '\n' +
                        'Inventory Cost: ' + deposit.Inventory_Cost__c + '\n' +
                        '-------------------------\n';
                }
                
                if (!paymentsToInsert.isEmpty()) {
                    insert paymentsToInsert;
                }
            }
            
        } catch (Exception ex) {
            // Catch any unexpected error and put it into the email
            emailBody = 'An error occurred during the Deposit Payment Verification Job.\n\n';
            emailBody += 'Error Message: ' + ex.getMessage() + '\n';            
        }
        
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String environment = isSandbox ? 'Sandbox' : 'Production';
        // Send notification email (always)
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { 'victor.goncalves@nerdsoft.com', 'danilo.fernandes@nerdsoft.com', 'raphael.fogaca@nerdsoft.com'});
        mail.setSubject('['+environment+']Deposit Payment Verification Job Results Alert');
        mail.setPlainTextBody(emailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}