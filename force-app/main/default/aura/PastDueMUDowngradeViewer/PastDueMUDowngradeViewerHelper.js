({
    formatPayments : function(payments) {
        return payments.map(function(payment) {
            return {
                Id: payment.Id,
                CreatedDate: payment.CreatedDate,
                Payment_Amount__c: payment.Payment_Amount__c
            };
        });
    }
})