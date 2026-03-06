({
	onRecordSubmit: function(component, event, helper) {
        console.log('onRecordSubmit ==');
        
    },
    
    handleEdit: function(component, event, helper) {
        component.set('v.isEdit',true);
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
        component.set('v.isEdit',false);
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