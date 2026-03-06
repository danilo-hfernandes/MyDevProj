({
    doInit : function(component, event, helper) {
        var action = component.get("c.getOpportunitiesToDowngrade");
        const baseUrl = 'https://holidaysystems--full.sandbox.my.salesforce.com/';
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var opportunities = response.getReturnValue();
                component.set("v.opportunities", opportunities);
                console.log('v.opportunities = '+opportunities);
                component.set('v.columns', [
                    {
                        label: 'Opportunity Name',
                        fieldName: 'Program__c', // This field now contains the full URL
                        type: 'url',
                        typeAttributes: {
                            label: { fieldName: 'Name' }, // The text of the link will be the Opportunity Name
                            target: '_blank' // Opens the link in a new tab
                        }
                    },
                    {label: 'OppId', fieldName: 'Id', type: 'text'},
                    {label: 'Current AffiliateId', fieldName: 'X2nd_Owner__c', type: 'text'},
                    {label: 'Current AffiliateName', fieldName: 'Access_Code__c', type: 'text'},
                    {label: 'New AffiliateId', fieldName: 'Affiliate_Name__c', type: 'text'},
                    {label: 'New AffiliateName', fieldName: 'Affiliated_Id__c', type: 'text'},
                    {label: 'Down Deposit', fieldName: 'Down_Deposit__c', type: 'currency'},
                    {label: 'Number of Payments', fieldName: 'Number_of_Payments__c', type: 'number'},
                    {label: 'Monthly Payment', fieldName: 'Monthly_Payment__c', type: 'currency'},
                    {label: 'Payment Type', fieldName: 'Payment_Type__c', type: 'text'},
                    {label: 'Total Amount', fieldName: 'Total_Amount__c', type: 'currency'},
                    {label: 'Total Amount Paid', fieldName: 'Total_Amount_Paid__c', type: 'currency'},
                    {label: 'Total Refund', fieldName: 'Total_Refund__c', type: 'currency'},
                    {label: 'Balance (Total Amount - (Paid - Refund))', fieldName: 'Base_Price__c', type: 'currency'},
                    {label: 'Last Payment Date', fieldName: 'Opportunity_Closed_Date__c', type: 'text'},                    
                    {label: 'Payments', fieldName: 'Product_Summary__c', type: 'text'}
                    /*{label: 'Payments (JSON)', fieldName: 'Payments__r', type: 'text', 
                     cellAttributes: {
                         class: 'wrap-text',
                         fieldName: 'Payments__r', 
                         formatter: function(value) {
                             return JSON.stringify(value);
                         }
                     }
                    }*/
                ]);
            }
        });
        $A.enqueueAction(action);
    }
})