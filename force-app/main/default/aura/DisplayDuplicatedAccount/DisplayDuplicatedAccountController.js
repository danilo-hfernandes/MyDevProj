({
    doInit : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Account Name', fieldName: 'linkName', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Phone', fieldName: 'Phone', type: 'text'},
            {label: 'Email', fieldName: 'Email__c', type: 'text'},
            {label: 'Affiliate Name', fieldName: 'Affiliate_Name__c', type: 'text'},
            {label: 'Affiliate Id', fieldName: 'Affiliated_Id__c', type: 'text'}
        ]);
        
        helper.getAccountList(component);        
    }
})