({
    fetchSessions: function(component) {
        component.set("v.isLoading", true);
        const recId = component.get("v.recordId");
        const shortId = recId.substring(0, 3);

//        if (shortId === "00Q") {
//			const action = component.get("c.getMessagingSessionsByLead");        
//        } else {
			const action = component.get("c.getMessagingSessions");
//        }
        
        action.setParams({ recordId: component.get("v.recordId") });

        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                let sessions = response.getReturnValue();
                // Add clickable link field
                sessions.forEach(s => { s.linkName = '/' + s.Id; });
                component.set("v.sessions", sessions);
            } else {
                console.error(response.getError());
                component.set("v.sessions", []);
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    fetchConversationEntries: function(component, sessionId, append) {

    console.log(">>> Fetching conversations for sessionId:", sessionId);
    console.log(">>> pageSize:", component.get("v.pageSize"));
    console.log(">>> pageNumber:", component.get("v.pageNumber"));
    console.log(">>> append:", append);
	console.log(">>> fetchConversationEntries called. sessionId=", sessionId, "pageNumber=", component.get("v.pageNumber"));

        component.set("v.isLoading", true);
        const action = component.get("c.getConversationEntriesThread");
        //action.setParams({ sessionId: sessionId });
        action.setParams({
            sessionId: sessionId,
            pageSize: component.get("v.pageSize"),
            pageNumber: component.get("v.pageNumber")
        });
        action.setCallback(this, function(response) {
           console.log(">>> State:", response.getState());
           if (response.getState() === "SUCCESS") {
                let newEntries = response.getReturnValue();
            	console.log(">>> Records returned:", newEntries.length);
                if (append) {
                    let existing = component.get("v.conversationEntries") || [];
                    component.set("v.conversationEntries", existing.concat(newEntries));
	                console.log(">>> Total after append:", component.get("v.conversationEntries").length);
                } else {
                    component.set("v.conversationEntries", newEntries);
                }
                
                // If fewer than pageSize, no more records
                component.set("v.hasMore", newEntries.length === component.get("v.pageSize"));
	            console.log(">>> hasMore?", component.get("v.hasMore"));
                
            } else {
                console.error(response.getError());
                component.set("v.conversationEntries", []);
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    }
})