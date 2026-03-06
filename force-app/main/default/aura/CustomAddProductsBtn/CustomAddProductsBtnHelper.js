({
    fetchPriceBookEntries: function(component, event, helper) {
        var action = component.get("c.fetchPriceBookEntries");
        var opptyId = component.get("v.recordId");
        
        action.setParams({                
            oppId: opptyId
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('fetchPriceBookEntries entered');
            if (state === "SUCCESS") {
                console.log('fetchPriceBookEntries SUCCESS entered');
                var map = response.getReturnValue();                
                var stateStr = Object.keys(map)[0];                
                var pbes = Object.values(map)[0];
                
                if (pbes != null && pbes != undefined) {
                    // Check if the key-string is 'true'
                    if (stateStr == 'true') {
                        // Set the attribute values
                        component.set("v.priceBookEntries", pbes);
                        console.log('pbes = '+JSON.stringify(pbes));
                        component.set("v.showSpin", false);
                    } else if (stateStr == 'false') {
                        var errorMsg = stateStr;
                        // Display error message
                        helper.showToast(component, "Error", errorMsg, "error");
                        component.set("v.showSpin", false);
                    } else {
                        helper.showToast(component, "Error", "Invalid response from the server", "error");
                        component.set("v.showSpin", false);
                    }
                } else {
                    helper.showToast(component, "Error", "No data returned from the server", "error");
                    component.set("v.showSpin", false);
                }
            } else {
                helper.showToast(component, "Error", "An error occurred while fetching data", "error");
                component.set("v.showSpin", false);
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function(component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: 10000,
            type: type
        });
        toastEvent.fire();
    }
})