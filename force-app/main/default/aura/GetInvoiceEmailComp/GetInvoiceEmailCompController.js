({
    doInit: function (component, event, helper) {
        console.log('before doInit called');
        helper.fetchEmails(component);
    },

    handleRowAction: function (component, event, helper) {
        const selectedEmail = event.getParam('row');
        console.log('Selected Email:', selectedEmail);

        // Set the selected email to display in the details card
        component.set('v.selectedEmail', selectedEmail);
        
    },

    nextPage: function (component, event, helper) {
        const currentPage = component.get('v.currentPage');
        component.set('v.currentPage', currentPage + 1);
        helper.fetchEmails(component); // Fetch the next page
    },

    previousPage: function (component, event, helper) {
        const currentPage = component.get('v.currentPage');
        component.set('v.currentPage', currentPage - 1);
        helper.fetchEmails(component); // Fetch the previous page        
    }
});