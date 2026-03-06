({
    fetchAICallEvents: function (component) {
        component.set("v.isLoading", true);
        const action = component.get("c.getAICallEvents");

        action.setParams({
            recordId: component.get("v.recordId")
        });

        action.setCallback(this, function (response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                try {
                    const raw = response.getReturnValue();
                    console.log("Raw API response:", raw);
                   //const data = JSON.parse(raw);
					  const data = raw;
                    // Optional: filter and clean null values or transform if needed
                    console.log("Raw events:", JSON.stringify(raw[0].events, null, 2));

                    const formattedData = data.map(item => ({
                        media: item.media || '',
                        disposition: item.disposition || '',
                        createdOn: item.createdOn || '',
                        campaign: item.campaign || '',
                        totalCallDuration: item.totalCallDuration || '',
                        events: (item.events || []).map(ev => {
                            return {
                            eventName: ev.eventName || '',
                            duration: ev.duration || '',
                            url: ev.url || '',
                            summary: ev.summary || (ev.morganCall && ev.morganCall.summary ? ev.morganCall.summary : ''),
                            transcript: ev.transcript || (ev.morganCall && ev.morganCall.transcript ? ev.morganCall.transcript : ''),
                            conversationId: ev.conversationId || '',
                            
                            // Agent Call fields
                            agent: ev.agent || (ev.transfer && ev.transfer.agentName ? ev.transfer.agentName : ''),
                            rcCallResult: ev.rcCallResult || (ev.transfer && ev.transfer.callResult ? ev.transfer.callResult : '')
                        };
                                                        }),



                        twilioId: item.twilioId || Math.random().toString(36).substring(2)
                    }));
                    
                    
                    if (formattedData.length > 0 && formattedData[0].events.length > 0) {
                        component.set("v.activeRowId", formattedData[0].events[0].conversationId);  // First event ID
                    }
					console.log("Formatted Data (events):", JSON.stringify(formattedData, null, 2));
                    component.set("v.callEvents", formattedData);
                    console.log('>>>>>'+component.get("v.callEvents"));
                    console.log("CallEvents", response.getReturnValue());
                    console.log("Formatted Data:", formattedData);
                } catch (e) {
                    console.error("Failed to parse API response:", e);
                    component.set("v.callEvents", []);
                }
            } else {
                console.error("Apex error:", response.getError());
                component.set("v.callEvents", []);
            }
            component.set("v.isLoading", false);
        });

        $A.enqueueAction(action);
    }
});