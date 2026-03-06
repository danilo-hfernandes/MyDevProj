({
    fetchEmails: function (component) {
        component.set('v.isLoading', true);
        const action = component.get("c.sendRequestInvoice");
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
                            
                            AffiliateName: email.Affiliate_Name,
                            MarketingBrand: email.Marketing_Brand,
                            ParentBrand: email.Parent_Brand,
                            Logo: email.Logo,
                            MemberName: email.Member_Name,
                            MembershipSubType: email.Membership_SubType,
                            MemberNumber: email.Member_Number,
                            MembershipStatus: email.Membership_Status,
                            PreferredLanguage: email.Preferred_Language,
                            Address: email.Address,
                            City: email.City,
                            State: email.State,
                            Country: email.Country,
                            ZipCode: email.Zip_Code,
                            AnnualDues: email.Annual_Dues,
                            DueDate: email.Due_Date,
                            WebAddress: email.Web_Address,
                            QRCodeLink: email.QR_Code_Link,
                            SendDate: email.Send_Date

/*
                             AffiliateName: email.AffiliateName,
                            MarketingBrand: email.MarketingBrand,
                            ParentBrand: email.ParentBrand,
                            Logo: email.Logo,
                            MemberName: email.MemberName,
                            MembershipSubType: email.MembershipSubType,
                            MemberNumber: email.MemberNumber,
                            MembershipStatus: email.MembershipStatus,
                            PreferredLanguage: email.PreferredLanguage,
                            Address: email.Address,
                            City: email.City,
                            State: email.State,
                            Country: email.Country,
                            ZipCode: email.ZipCode,
                            AnnualDues: email.AnnualDues,
                            DueDate: email.DueDate,
                            WebAddress: email.WebAddress,
                            QRCodeLink: email.QRCodeLink,
                            SendDate: email.SendDate
*/
                            
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