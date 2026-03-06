({
    doInitHelper: function(component, event, helper) {
        var contactId = component.get("v.recordId");
        var action = component.get("c.tryToUpgradeVacationVIP");
        action.setParams({
            recordId : contactId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state : '+state);
            if (state === "SUCCESS"){
                var map = response.getReturnValue();
                console.log('map : '+map);
                var stateStr = Object.keys(map)[0];
                console.log('stateStr : '+stateStr);
                var log = Object.values(map)[0];
                console.log('log : '+log);                
                if(stateStr == 'error'){
                    this.fireToastMessage(log,'error');
                }else{
                    this.fireToastMessage('Voucher Opportunity records created','success');
                }
            }
            else{
                this.fireToastMessage(state,'error');                
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