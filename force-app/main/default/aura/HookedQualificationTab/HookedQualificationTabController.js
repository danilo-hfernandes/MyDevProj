({
    doInit: function(component, event, helper) {
        helper.fetchRecordTypeName(component);
    },

    handleSave: function(component, event, helper) {
        event.preventDefault();
        var fields = event.getParam('fields');
        component.find("recordEditForm").submit();
    },

    handleSuccess: function(component, event, helper) {
        // Reset fields and disable save button
        component.set("v.isSaveDisabled", true);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Success!",
            message: "Record saved successfully.",
            type: "success"
        });
        toastEvent.fire();
    },

    handleError: function(component, event, helper) {
        var errors = event.getParam("error");
        console.error("Error:", errors);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: "Error!",
            message: errors[0].message,
            type: "error"
        });
        toastEvent.fire();
    }
})