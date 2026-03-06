({
    save : function(component, event, helper) {
        component.find("timeshareForm").submit();
    },

    handleSuccess : function(component, event, helper) {

        $A.get("e.force:showToast").setParams({
            title: "Success",
            message: "Timeshare created successfully",
            type: "success"
        }).fire();

        $A.get("e.force:closeQuickAction").fire();
    },

    close : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})