({
    doInit: function(component, event, helper){
        var action = component.get("c.fetchUserAccess");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userHasAccess", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    
    onRecordSubmit: function(component, event, helper) {
        console.log('onRecordSubmit ==');
        event.preventDefault();       
        var fields = event.getParam('fields');
        fields.Street = '32 Prince Street';
        component.find('myform').submit(fields);
    },
    handleOnSuccess : function(component, event, helper) {
        console.log('handleOnSuccess');
        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Success!",
                "type" : 'success',
                "mode" : 'dismissible',
                "duration" : 5000,
                "message": "The record has been updated successfully."
            });
            toastEvent.fire();
    },
    
    handleOnError : function(component, event, helper) {
        console.log('handleOnError');    
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
                "title": "Error",
                "type" : 'error',
                "mode" : 'pester',
                "duration" : 5000,
                "message": "Flight Information is Required."
            
        });
        toastEvent.fire();
    },
})