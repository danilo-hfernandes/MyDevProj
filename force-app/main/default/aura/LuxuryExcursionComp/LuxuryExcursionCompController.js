({
    doInit : function(component, event, helper) {
        helper.loadData(component);
    },

    editRecord : function(component, event, helper) {
        var recordId = event.getSource().get("v.value");

        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId
        });
        editRecordEvent.fire();
    },

    addRecord : function(component, event, helper) {
        var recordId = event.getSource().get("v.value");

        var action = component.get("c.cloneExcursion");
        action.setParams({ recordId : recordId });

        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                helper.loadData(component);
            }
        });

        $A.enqueueAction(action);
    }
})