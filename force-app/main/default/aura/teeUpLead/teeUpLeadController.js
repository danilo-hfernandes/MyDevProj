({
    doInit : function(component, event, helper){
        helper.doInitHelper(component);
    },

    onDivisionChange : function(component, event, helper) {
        
        var selectedId = event.getSource().get("v.value");
        component.set("v.selectedDivision", selectedId);
        
        // derive division name
        var divisions = component.get("v.divisions") || [];
        var name = "";
        
        for (var i = 0; i < divisions.length; i++) {
            if (divisions[i].Value === selectedId) {
                name = divisions[i].Text;
                break;
            }
        }
        
        component.set("v.selectedDivisionName", name);
        
        // reset agents
        component.set("v.selectedAgentExternalId", "");
        component.set("v.selectedAgentName", "");
        component.set("v.agents", []);
        
        helper.loadAgents(component);
    },

    onAgentChange : function(component, event, helper) {
        var selectedId = event.getSource().get("v.value");
        component.set("v.selectedAgentExternalId", selectedId);

        // derive selectedAgentName from agents list
        var agents = component.get("v.agents") || [];
        var name = "";
        for (var i = 0; i < agents.length; i++) {
            if (agents[i].Value === selectedId) {
                name = agents[i].Text;
                break;
            }
        }
        component.set("v.selectedAgentName", name);
    },

    saveLead : function(component, event, helper) {
        helper.saveLeadHelper(component);
    },

    cancelLead : function(component) {
        $A.get("e.force:closeQuickAction").fire();
    }
})