({
    fetchRecordTypeName: function(component) {
        var action = component.get("c.getRecordTypeName");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var recordTypeName = response.getReturnValue();
                component.set("v.recordTypeName", recordTypeName);
                component.set("v.isRequired", recordTypeName === "Hooked Voucher"); // Adjust the record type name accordingly
            } else {
                console.error("Error fetching record type name:", response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})