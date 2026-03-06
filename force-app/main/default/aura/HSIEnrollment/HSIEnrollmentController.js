({
    doInit : function(component, event, helper) {
        var action = component.get("c.registerRecordToHSI");
        var toastEvent = $A.get("e.force:showToast");
        action.setParams({
            'accId' : component.get('v.recordId')
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                
                console.log(response.getReturnValue());
                if(response.getReturnValue() == 'Success'){
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "The record has been updated successfully."
                    });
                    toastEvent.fire();
                }else{
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": response.getReturnValue()
                    });
                    toastEvent.fire();
                }
            }else{
                toastEvent.setParams({
                        "title": "Error!",
                    	"type": "error",
                        "message": 'Unexpected Error'
                    });
                    toastEvent.fire();
            }
            $A.get("e.force:closeQuickAction").fire()
        });
        
        $A.enqueueAction(action);
    }
})