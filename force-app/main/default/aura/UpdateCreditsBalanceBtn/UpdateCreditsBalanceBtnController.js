({
    init: function(component, event, helper) {
        helper.getAccountDetails(component);
    },
    
    updateCreditsBalance: function(component, event, helper) {
        helper.updateAccountCreditsBalance(component);
    },
    
    handleUpdateSuccess: function(component, event, helper) {
        // Handle successful record update here if needed
        helper.getAccountDetails(component);
    },
    
    handleUpdateError: function(component, event, helper) {
        // Handle record update error here if needed
        console.error("Error updating record: ", event.getParams());
    }
})