({
    doInit: function (component, event, helper) {
        console.log('before doInit called');
        helper.fetchEmails(component);
        console.log('Email Columns:', component.get('v.columns'));
		console.log('Email Data:', component.get('v.emailMessages'));

        component.set('v.columns', [
            { label: 'Date', fieldName: 'MessageDate', type: 'date' },
            {
                label: 'Subject',
                fieldName: 'Subject',
                type: 'button',
                typeAttributes: {
                    label: { fieldName: 'Subject' },
                    name: 'subjectClick',
                    variant: 'base',
                    class: 'subject-link'
                }
            },
            { label: 'From', fieldName: 'FromAddress', type: 'text' },
            {
                type: 'action',
                typeAttributes: {
                    rowActions: [{ label: 'View', name: 'viewEmail' }]
                }
            }
        ]);

        
    },

//    handleRowAction: function (component, event, helper) {
//        const selectedEmail = event.getParam('row');
//        console.log('Selected Email:', selectedEmail);
//
//        // Set the selected email to display in the details card
//        component.set('v.selectedEmail', selectedEmail);
//        
//    },

    handleRowAction: function (component, event, helper) {
    const action = event.getParam('action');
    const row = event.getParam('row');

    if (action.name === 'viewEmail' || action.name === 'subjectClick') {
        console.log('Selected Email:', row);
        component.set('v.selectedEmail', row);
    }
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