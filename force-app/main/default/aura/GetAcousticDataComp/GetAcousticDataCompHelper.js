({
    fetchEmails: function (component) {
    component.set('v.isLoading', true);
    const action = component.get("c.sendRequestAcoustic");
    action.setParams({
        recordId: component.get("v.recordId"),
        page: component.get("v.currentPage") // Pass the current page
    });

    action.setCallback(this, function (response) {
        const state = response.getState();
        console.log("[DEBUG] Response State:", state);
        
        if (state === "SUCCESS") {
            try {
				//alert('response.getReturnValue() ='+response.getReturnValue());
                console.log("[DEBUG] API Raw Response:", response.getReturnValue());
                const responseData = JSON.parse(response.getReturnValue());
                
                console.log("[DEBUG] Parsed responseData:", responseData);
                
                
                    if (responseData.Items) {
                
                    const emails = responseData.Items || [];
                    console.log("[DEBUG] Emails Data:", emails);
                    
                    const emailMessages = emails.map(email => ({
                        Id: email.Id,
                        Name: email.Name,
                        SilverpopLead: email.SilverpopLead,
                        SilverpopEmailName: email.SilverpopEmailName,
                        SilverpopContact: email.SilverpopContact,
                        SilverpopSubject: email.SilverpopSubject,
                        SilverpopEngage: email.SilverpopEngage,
                        SilverpopSentDateTime: email.SilverpopSentDateTime,
                        SilverpopSilverpopId: email.SilverpopSilverpopId,
                        SilverpopOpened: email.SilverpopOpened,
                        SilverpopStatus: email.SilverpopStatus,
                        SilverpopDateUnsubscribed: email.SilverpopDateUnsubscribed,
                        SilverpopOpenDateTime: email.SilverpopOpenDateTime,
                        SilverpopDateBounced: email.SilverpopDateBounced,
                        
                        CreatedById: email.CreatedById,
                        CreatedDate: email.CreatedDate,
                        IsDeleted: email.IsDeleted,
                        LastModifiedById: email.LastModifiedById,
                        LastModifiedDate: email.LastModifiedDate,
                        LastReferencedDate: email.LastReferencedDate,
                        LastViewedDate: email.LastViewedDate,
                        OwnerId: email.OwnerId,
                        SystemModstamp: email.SystemModstamp
                    

                        
                    }));
 
                    console.log("[DEBUG] emailMessages:", emailMessages);
                    
                    component.set('v.emailMessages', emailMessages);
                    const TotalPages = responseData.TotalPages ;
                    component.set('v.totalPages', TotalPages); // Update total pages
                } else {
                    console.warn("[WARNING] No Emails found in response.");
                    component.set('v.emailMessages', []);
                }
                    
                    
            } catch (error) {
                console.error('Error parsing response:', error);
                component.set('v.emailMessages', []);
            }
        } else {
            console.error('Failed to fetch email messages:', response.getError());
            component.set('v.emailMessages', []);
        }
        component.set('v.isLoading', false);
    });

    $A.enqueueAction(action);
}
});