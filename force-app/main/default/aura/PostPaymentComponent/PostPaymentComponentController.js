({
    init : function(component, event, helper) {
        // Get record type ID
        var actionType = component.get("c.getRecordTypeId");
        actionType.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.recordTypeId", response.getReturnValue());
            }
        });
        $A.enqueueAction(actionType);
        
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        
        var getProductAction = component.get("c.getProductId");
        getProductAction.setParams({ opportunityId: component.get("v.recordId") });
        
        getProductAction.setCallback(this, function(response) {
            var productId = response.getState() === "SUCCESS" ? response.getReturnValue() : null;
            
            if(productId){
                component.set("v.payment", {
                    sobjectType: 'Payment__c',
                    Paid_On__c: today,
                    Payment_Type__c: 'payment',
                    //Payment_Method__c: 'Credit Card In Person',
                    Payment_Method__c: '', // initially blank until picklist chosen
                    Product_Id__c: productId,
                    RecordTypeId: component.get("v.recordTypeId"),
                    Opportunity__c: component.get("v.recordId")
                });
                component.set("v.showModal", true);
            }
            else
            {
                $A.get("e.force:showToast").setParams({
                    title: "Validation Error",
                    message: "There's no Club Venture Product associated with this opportunity",
                    type: "error",
                    duration: 7000
                }).fire();
            }
        });
        
        $A.enqueueAction(getProductAction);
        
    },

    
    onMethodChange : function(component, event, helper) {
        var selected = component.get("v.selectedMethod");
        var payment = component.get("v.payment");
        payment.Payment_Method__c = selected;  
        component.set("v.payment", payment);
    },
    
    cancel : function(component, event, helper) {        
        component.set("v.showModal", false);
        $A.get('e.force:refreshView').fire();
        $A.get("e.force:closeQuickAction").fire();
    },

    submit : function(component, event, helper) {
        var payment = component.get("v.payment");
    
        if (!payment.Payment_Amount__c || payment.Payment_Amount__c < 0) {
            $A.get("e.force:showToast").setParams({
                title: "Validation Error",
                message: "Invalid Payment Amount, It's required.",
                type: "error",
                duration: 7000
            }).fire();
            return;
        }
    
        // Optional: show spinner
        component.set("v.isLoading", true);
    
        var action = component.get("c.savePayment");
        action.setParams({ payment: payment });
        
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                //  Close modal and show success toast            
                $A.get("e.force:showToast").setParams({
                    title: "Success",
                    message: "Payment saved successfully.",
                    type: "success",
                    duration: 7000
                }).fire();
                component.set("v.showModal", false);
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
            } else {
                //  Show error toast and refresh view
                var errors = response.getError();
                var message = errors && errors[0] && errors[0].message ? errors[0].message : "Unknown error";
    
                $A.get("e.force:showToast").setParams({
                    title: "Error",
                    message: "Failed to save payment: " + message,
                    type: "error",
                    duration: 7000
                }).fire();
    
                // Refresh view if there's a failure
                $A.get('e.force:refreshView').fire();
            }
        });
    
        $A.enqueueAction(action);
    }
})