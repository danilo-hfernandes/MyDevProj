({
    init: function(component, event, helper) {
        //event.preventDefault();
        var action = component.get("c.getPaymentDetails");
        action.setParams({ recordId: component.get("v.recordId") });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var data = response.getReturnValue();
                var record = {};
                
                if(data.paymentStatus === '' || data.paymentStatus === 'Not Paid')
                {
                    record.Payment_Status__c = "Approved";
                }
                if(data.paymentStatus === 'Approved')
                {
                    record.Payment_Status__c = 'Paid';
                    record.Paid_By__c = data.userName;
                    record.Amount_Paid_Out__c = data.cost;
                    record.Paid_On__c = data.today;
                    record.Check_Confirmation_Number__c = data.checkNumber;
                }
                
                record.Cost__c = data.cost;
                // Additional fields                
                record.Deposit__c = { Name: data.depositId };
                record.Due_Date__c = data.dueDate;
                record.Name = data.paymentId;
                record.Payment_Type__c = data.paymentType;
				
                component.set("v.depositId", data.depositId);
                component.set("v.depositPayment", record);
                // Delay opening the modal to ensure navigation completes
                /*window.setTimeout(function() {
                    component.set("v.isOpen", true);
                    console.log('window.setTimeout called');
                }, 50000); // Adjust delay if needed
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": data.depositId,
                    "slideDevName": "Detail"
                });
                navEvt.fire();*/
            }
        });
        $A.enqueueAction(action);
    },

    handleFieldChange: function(component, event, helper) {
        var fieldName = event.getSource().get("v.name");
        var fieldValue = event.getSource().get("v.value");

        var record = component.get("v.depositPayment");
        record[fieldName] = fieldValue;
        component.set("v.depositPayment", record);
    },

    closeModal: function(component, event, helper) {
        component.set("v.isOpen", false);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.depositId"),
            "slideDevName": "Detail"
        });
        navEvt.fire();
    },

saveRecord: function(component, event, helper) {        
    // 1. Retrieve data from component attributes
    var depositPayment = component.get("v.depositPayment");
    var recordId = component.get("v.recordId");

    // Debugging: Log retrieved values
    console.log('depositPayment = ', JSON.stringify(depositPayment));
    console.log('recordId = ', recordId);

    // 2. Prepare the Apex action
    var action = component.get("c.savePaymentRecord");
    action.setParams({ 
        payment: depositPayment, 
        recId: recordId 
    });

    // 3. Define callback
    action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
            // Close modal and refresh UI
            component.set("v.isOpen", false);
                        
            // Show success toast
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "message": "Payment confirmed.",
                "type": "success"
            });
            toastEvent.fire();
            
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": component.get("v.depositId"),
                "slideDevName": "Detail"
            });
            navEvt.fire();
            
        } else if (state === "ERROR") {
            // Handle errors gracefully
            var errors = response.getError();
            var errorMessage = "Unknown error";
            if (errors && errors[0] && errors[0].message) {
                errorMessage = errors[0].message;
            }
            
            // Show error toast
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": errorMessage,
                "type": "error"
            });
            toastEvent.fire();
        }
    });

    // 4. Enqueue the action
    $A.enqueueAction(action);
}
    
})