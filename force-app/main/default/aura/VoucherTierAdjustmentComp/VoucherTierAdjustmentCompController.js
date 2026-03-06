({
    initComponent: function(component, event, helper) {
        var action = component.get("c.getOpportunitiesData");
        action.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.opportunityData", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
        var oppAction = component.get("c.getOpportunitiesList");
        oppAction.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") {
                component.set("v.opportunityList", response.getReturnValue());
                var opportunities = component.get("v.opportunityList");
                // Enable button only if there is at least one opportunity
                component.set("v.isButtonDisabled", opportunities.length === 0);
            }
        });
        $A.enqueueAction(oppAction);
    },
    
    handleAddTierAdjustment: function(component, event, helper) {
        component.set("v.isButtonDisabled", true);
        var oppList = component.get("v.opportunityList");
        var oppMap = {};
        
        // Populate the map with opportunity Id and tier adjustment values
        oppList.forEach(function(oppWrapper) {
            oppMap[oppWrapper.oppId] = oppWrapper.tierAdjustment;
        });
        
        console.log('Opportunity Map:', JSON.stringify(oppMap));
        
        var action = component.get("c.addTierAdjustmentToAllOpps");
        action.setParams({
            "oppMap": oppMap
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Handle success
                console.log("Tier adjustments added successfully.");
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Tier adjustments are being added. Please refresh this screen in few minutes.",
                    "type": "success"
                });
                toastEvent.fire();                
                                
                var a = component.get('c.initComponent');
                $A.enqueueAction(a);
                
            } else {
                console.error("Failed with state: " + state);
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error",
                    "message": "Failed with state: " + state,
                    "type": "error"
                });
                toastEvent.fire();
                
                var a = component.get('c.initComponent');
                $A.enqueueAction(a);
            }
        });
        
        $A.enqueueAction(action);
    }
})