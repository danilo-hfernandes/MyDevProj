public class VoucherTierAdjustmentQueueable implements Queueable {
    private Map<Id, Decimal> oppMap;

    // Constructor to initialize the Opportunity map
    public VoucherTierAdjustmentQueueable(Map<Id, Decimal> oppMap) {
        this.oppMap = oppMap;
    }

    public void execute(QueueableContext context) {
        System.debug('Received Opportunity Map: ' + oppMap);

        if (oppMap == null || oppMap.isEmpty()) {
            System.debug('oppMap is null or empty');
            return;
        }

        // Step 1: Insert Opportunity Line Items
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        PriceBookEntry pbe = [SELECT Id FROM PriceBookEntry WHERE Product2.Name = 'LuxGive-Tier Adjustment' LIMIT 1];
        Product2 prod = [SELECT Id FROM Product2 WHERE Name = 'LuxGive-Tier Adjustment' LIMIT 1];

        for (Id oppId : oppMap.keySet()) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.OpportunityId = oppId;
            oli.Product2Id = prod.Id;
            oli.PriceBookEntryId = pbe.Id;
            oli.UnitPrice = oppMap.get(oppId);
            oli.Quantity = 1;
            oliList.add(oli);
        }

        if (!oliList.isEmpty()) {
            insert oliList;
        }

        // Step 2: Query the Opportunities with the newly inserted Line Items
        Map<Id, Opportunity> opportunitiesMap = new Map<Id, Opportunity>([
            SELECT Id, Name,
                   (SELECT Product_Id__c, Product2.Name FROM OpportunityLineItems WHERE Product2.Name = 'LuxGive-Tier Adjustment')
            FROM Opportunity
            WHERE Id IN :oppMap.keySet()
        ]);

        // Step 3: Create Payments
        List<Payment__c> paymentList = new List<Payment__c>();

        for (Id oppId : oppMap.keySet()) {
            Opportunity opp = opportunitiesMap.get(oppId);

            if (opp != null && !opp.OpportunityLineItems.isEmpty()) {
                for (OpportunityLineItem lineItem : opp.OpportunityLineItems) {
                    if (lineItem.Product2.Name == 'LuxGive-Tier Adjustment') {
                        Payment__c payment = new Payment__c();
                        payment.RecordTypeId = '0123t0000006A27AAE'; // Voucher RecordType
                        payment.Name = opp.Name;
                        payment.Product_Id__c = lineItem.Product_Id__c;
                        payment.Payment_Type__c = 'Payment';
                        payment.Payment_Amount__c = oppMap.get(oppId);
                        payment.Paid_On__c = Date.today().toStartOfMonth().addDays(-1); // End of previous month
                        payment.Opportunity__c = oppId;
                        paymentList.add(payment);
                    }
                }
            }
        }

        if (!paymentList.isEmpty()) {
            insert paymentList;
        }
    }
}