({
    doInitHelper : function(component, event, helper) {
        //alert('call doInit sec');
        var getOldOpportunityOwnerName = component.get("c.fetchOldAgentName");
        getOldOpportunityOwnerName.setParams({
            oppId : component.get("v.recordId")
        });
        
        getOldOpportunityOwnerName.setCallback(this, function(response) {
            var state = response.getState();
            console.log('>>>>>>>.state', state);
            if (state === "SUCCESS") {
                console.log('>>>>response.getReturnValue()>>>>>>>', response.getReturnValue());
                var fetchRecords = response.getReturnValue();
                const profileName = component.get('v.CurrentUser')['Profile'].Name;
                
                console.log('>profileName>>', profileName);
                if(fetchRecords.Record_Type_Name__c == 'Hawaii Collection Membership' || fetchRecords.Record_Type_Name__c == 'SFX Membership'){
                    if((fetchRecords.Opportunity_Appointment_Date__c == null && profileName == 'Membership Upgrade Agent' ) || profileName == 'System Administrator' || profileName == 'Membership Upgrade Manager'){
                        component.set('v.showAppointmentDate', true);
                        component.set('v.appointmentDate',fetchRecords.Opportunity_Appointment_Date__c); 
                    }                   
                }
                if(fetchRecords.Tee_Up_Agent__c != null){
                    console.log('Owner.Name ---> ',fetchRecords.Tee_Up_Agent__r.Name);
                    component.set('v.OldOpportunityOwner',fetchRecords.Tee_Up_Agent__r.Name); 
                }
                if(fetchRecords.Closing_Agent__c != null){
                    component.set('v.NewOpportunityOwner',fetchRecords.Closing_Agent__r.Name);
                }
                if(fetchRecords.Tee_Up_Agent__c != null || fetchRecords.Closing_Agent__c != null || fetchRecords.Referral_Agent__c != null){
                    component.set('v.flag', true);
                }
               
            }
        });
        $A.enqueueAction(getOldOpportunityOwnerName);
        var action = component.get("c.fetchRecord");
        action.setParams({
            oppId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert('state : ' + state);
            if (state === "SUCCESS") {
                var fetchRecords = response.getReturnValue();
                component.set('v.userOption',fetchRecords);  
                //console.log('User option --> ' + JSON.stringify(fetchRecords));
            }
        });
        $A.enqueueAction(action);
        
    },
    
    saveOpportunityHelper: function(component, event, helper) {
        var opportunityId = component.get("v.recordId");
        var selectedUser =  component.get('v.selectedUser');
        var appointmentDate = component.get("v.appointmentDate");
        var action = component.get("c.updateOpportunity");
        action.setParams({
            recordId : opportunityId,
            teeupuserId : selectedUser,
            appointmentDate : appointmentDate            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                //alert('state - ' + state);
                var opp = response.getReturnValue();
                //alert('opp-' + opp);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title':'Success',
                    'type':'Success',
                    'message':'Opportunity records updated'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
            else if (state === "ERROR") {  // Handle errors properly - TGR-512
                var errors = response.getError();
                var errorMessage = "An unknown error occurred."; // Default message
                
                if (errors && errors[0] && errors[0].message) {
                    errorMessage = errors[0].message;
                }
    
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    'title': 'Error',
                    'type': 'error',
                    'message': errorMessage
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action); 
    },
    
    fireToastMessage : function(message,type){
        var showToast = $A.get("e.force:showToast");  
        showToast.setParams({ 
            'duration': 5000,
            'title' : 'Message', 
            'message' : message,
            'type': type
        }); 
        showToast.fire(); 
        $A.get("e.force:closeQuickAction").fire()    
        
    }
    
})