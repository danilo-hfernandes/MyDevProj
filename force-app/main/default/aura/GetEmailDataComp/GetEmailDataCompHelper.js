({
    fetchEmails: function (component) {
    component.set('v.isLoading', true);
    const action = component.get("c.sendRequest");
    action.setParams({
        recordId: component.get("v.recordId"),
        page: component.get("v.currentPage") // Pass the current page
    });

    action.setCallback(this, function (response) {
        const state = response.getState();
        if (state === "SUCCESS") {
            try {
				//alert('response.getReturnValue() ='+response.getReturnValue());
                const responseData = JSON.parse(response.getReturnValue());
                const emails = responseData.Result.Items || [];
                const emailMessages = emails.map(email => ({
                    Id: email.Id,
                    Subject: email.Subject,
                    FromAddress: email.FromAddress,
                    ToAddress: email.ToAddress,
                    BccAddress: email.BccAddress,
                    MessageDate: email.MessageDate,
                    HtmlBody: email.HtmlBody
                    
                }));
                component.set('v.emailMessages', emailMessages);
                
                const TotalPages = responseData.Result.TotalPages ;
                component.set('v.totalPages', TotalPages); // Update total pages
                
                console.log('Raw Apex response:', response.getReturnValue());
                console.log('Parsed Items:', responseData.Result.Items);
                console.log('Mapped Email Messages:', emailMessages);


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