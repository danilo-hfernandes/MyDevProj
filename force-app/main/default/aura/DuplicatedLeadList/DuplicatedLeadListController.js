({
    doInit : function(component, event, helper) {

        component.set('v.mycolumns', [
            {
                label: 'Created Date',
                fieldName: 'CreatedDate',
                type: 'date'
            },
            {
                label: 'Source',
                fieldName: 'LeadSource',
                type: 'text'
            },
            {
                label: 'Name',
                fieldName: 'linkName',
                type: 'url',
                typeAttributes: {
                    label: { fieldName: 'Name' },
                    target: '_blank'
                }
            },
            { label: 'Email', fieldName: 'Email', type: 'text' },
            { label: 'Phone', fieldName: 'Phone', type: 'text' },
            {
                label: 'Owner',
                fieldName: 'OwnerName',
                type: 'text'
            }
        ]);

        helper.getLeadList(component);
    }
})