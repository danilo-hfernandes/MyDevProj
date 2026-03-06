({
    doInitHelper : function(component) {

        // Minimal lead fetch (to block duplicates)
        var actionLead = component.get("c.fetchOldAgentName");
        actionLead.setParams({ leadId : component.get("v.recordId") });

        actionLead.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var ld = response.getReturnValue();
                if (ld && ld.Tee_Up_Agent__c) {
                    component.set("v.flag", true);
                }
            } else {
                this.showError(response);
            }
        });
        $A.enqueueAction(actionLead);

        // Load divisions
        var actionDiv = component.get("c.getDivisions");
        actionDiv.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.divisions", response.getReturnValue());
            } else {
                this.showError(response);
            }
        });
        $A.enqueueAction(actionDiv);
    },

    loadAgents : function(component) {
        var divisionId = component.get("v.selectedDivision");
        if (!divisionId) {
            component.set("v.agents", []);
            return;
        }

        var action = component.get("c.getAgentsByDivision");
        action.setParams({ divisionId : divisionId });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.agents", response.getReturnValue());
            } else {
                this.showError(response);
            }
        });

        $A.enqueueAction(action);
    },

    saveLeadHelper : function(component) {

        var action = component.get("c.updateLead");
        action.setParams({
            recordId : component.get("v.recordId"),
            divisionId : component.get("v.selectedDivision"),
            divisionName : component.get("v.selectedDivisionName"),
            selectedAgentName : component.get("v.selectedAgentName"),
            selectedAgentExternalId : component.get("v.selectedAgentExternalId")
        });

        action.setCallback(this, function(response) {

            var toast = $A.get("e.force:showToast");

            if (response.getState() === "SUCCESS") {
                toast.setParams({
                    title: "Success",
                    type: "success",
                    message: "Lead updated"
                });
                toast.fire();
                $A.get("e.force:closeQuickAction").fire();
                return;
            }

            this.showError(response);
        });

        $A.enqueueAction(action);
    },

    showError : function(response) {
        var toast = $A.get("e.force:showToast");

        var errors = response.getError();
        var msg = (errors && errors[0] && errors[0].message)
            ? errors[0].message
            : "Unknown error";

        toast.setParams({
            title: "Error",
            type: "error",
            message: msg
        });
        toast.fire();
    }
})