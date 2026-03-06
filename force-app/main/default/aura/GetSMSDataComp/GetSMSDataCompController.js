({
    doInit: function(component, event, helper) {
        component.set('v.columns', [
            { label: 'Date', fieldName: 'CreatedDate', type: 'date' },
            //{ label: 'Preview', fieldName: 'PreviewDetails', type: 'text' },
            { 
                label: 'Conversation', fieldName: 'linkName', type: 'url',
                typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }
            },
            
            { 
                label: 'Detail', type: 'button', initialWidth: 100,
                typeAttributes: { label: 'View', name: 'viewSession', variant: 'base' }
            }
            
//            {
//                type: 'action',
//                typeAttributes: { rowActions: [{ label: 'View', name: 'viewSession' }] }
//            }
        ]);
        helper.fetchSessions(component);
    },

    handleRowAction: function(component, event, helper) {
        const action = event.getParam('action');
        const row = event.getParam('row');

        if (action.name === 'viewSession') {
            component.set('v.selectedSession', row);
            component.set("v.selectedSessionId", row.Id);  // <-- persist sessionId for pagination
            component.set("v.pageNumber", 0);              // <-- reset pagination when new session chosen
            helper.fetchConversationEntries(component, row.Id, false);
        }        
    },
    
    // Called when user selects a session from list
    showConversationEntries: function(component, event, helper) {
        let sessionId = event.currentTarget.dataset.sessionid;
        component.set("v.selectedSessionId", sessionId);
        component.set("v.pageNumber", 0);  // reset pagination
        helper.fetchConversationEntries(component, sessionId, false);
    },

    // Called when user clicks Load More
    loadMore: function(component, event, helper) {
	    console.log(">>> Load More clicked");
        let sessionId = component.get("v.selectedSessionId");
	    console.log(">>> selectedSessionId:", sessionId);
        if (!sessionId) {
            console.error("No session selected.");
            return;
        }
        let page = component.get("v.pageNumber");
        component.set("v.pageNumber", page + 1);
	    console.log(">>> New pageNumber:", component.get("v.pageNumber"));

        helper.fetchConversationEntries(component, sessionId, true);
    }
    
})